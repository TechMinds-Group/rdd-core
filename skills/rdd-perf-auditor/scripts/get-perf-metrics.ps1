# get-perf-metrics.ps1 — Métricas de performance do runtime OpenCode (read-only)
#
# Coleta latência/turnos/tokens do SQLite local do OpenCode via `opencode db`
# (SELECT apenas — NUNCA escreve no banco) e produz JSON agregado com
# percentis nearest-rank, agregações por dia/agente/modelo, top-N de turnos
# lentos e flags de context bloat.
# Turnos duplicados por forks de sessao sao deduplicados pela assinatura temporal (IMP-062).
# session_id truncado em 12 chars nos campos "session" do JSON de saida.
#
# Uso:
#   .\get-perf-metrics.ps1                          # últimos 7 dias, JSON no stdout
#   .\get-perf-metrics.ps1 -Days 14                 # janela customizada
#   .\get-perf-metrics.ps1 -Days 7 -TopSlow 10 -OutFile .\perf-metrics.json
#
# Disciplina de código (obrigatória — rdd-perf-auditor):
#   PowerShell 5.1+; SOMENTE cmdlets com nome completo; aliases nativos
#   PROIBIDOS (ri, rd, gc, iex, select, sort, where, foreach...) — colisão
#   de alias com cmdlets destrutivos apaga arquivos. Sem Invoke-Expression.
#   Sem paths de máquina hardcoded (portabilidade — IMP-016).
#
# Exit codes: 0 = sucesso (inclusive janela vazia) | 1 = falha (ver mensagem)

param(
  [ValidateRange(1, 3650)]
  [int]$Days = 7,

  [ValidateRange(1, 100)]
  [int]$TopSlow = 10,

  [ValidateRange(1000, 10000000)]
  [int]$RunawayTokIn = 200000,

  [string]$OutFile = ""
)

$ErrorActionPreference = 'Stop'

# ---------- helpers (nomes completos de cmdlet, sem aliases) ----------

function Get-NearestRankValue {
  param(
    [long[]]$SortedValues,
    [double]$Percent
  )
  if ($null -eq $SortedValues -or $SortedValues.Count -eq 0) { return $null }
  $idx = [int][math]::Ceiling(($Percent / 100.0) * $SortedValues.Count)
  if ($idx -lt 1) { $idx = 1 }
  if ($idx -gt $SortedValues.Count) { $idx = $SortedValues.Count }
  return [long]$SortedValues[$idx - 1]
}

function Get-LatencyStats {
  param([long[]]$Values)
  if ($null -eq $Values -or $Values.Count -eq 0) { return $null }
  $sorted = @($Values | Sort-Object)
  return [pscustomobject]@{
    count = $sorted.Count
    p50   = Get-NearestRankValue -SortedValues $sorted -Percent 50
    p95   = Get-NearestRankValue -SortedValues $sorted -Percent 95
    max   = [long]$sorted[$sorted.Count - 1]
  }
}

function Get-Verdict {
  param($P95Ms)
  if ($null -eq $P95Ms) { return 'N/A' }
  if ([long]$P95Ms -gt 120000) { return 'CRITICO' }
  if ([long]$P95Ms -gt 30000) { return 'WARNING' }
  return 'OK'
}

function Get-ShortId {
  param([string]$Id)
  if ($null -eq $Id) { return '' }
  if ($Id.Length -gt 12) { return $Id.Substring(0, 12) }
  return $Id
}

function Invoke-OpencodeDb {
  param([string]$Sql)
  $raw = & opencode db $Sql --format json
  if ($LASTEXITCODE -ne 0) { throw "opencode db falhou (exit code $LASTEXITCODE)" }
  if ($raw -is [System.Array]) { $text = ($raw -join "`n") } else { $text = [string]$raw }
  if ([string]::IsNullOrWhiteSpace($text)) { return ,@() }
  $trimmed = $text.Trim()
  if ($trimmed.StartsWith('{')) { $trimmed = '[' + $trimmed + ']' }
  $parsed = ConvertFrom-Json -InputObject $trimmed
  return ,@($parsed)
}

# ---------- coleta ----------

try {
  $nowMs = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
  $cutoff = $nowMs - ([int64]$Days * 86400000L)

  $sql = @"
SELECT m.id AS message_id, m.session_id AS session_id, json_extract(m.data, '`$.role') AS role, CAST(COALESCE(json_extract(m.data, '`$.time.created'), m.time_created) AS INTEGER) AS t_created, CAST(json_extract(m.data, '`$.time.completed') AS INTEGER) AS t_completed, CAST(json_extract(m.data, '`$.tokens.input') AS INTEGER) AS tok_in, CAST(json_extract(m.data, '`$.tokens.output') AS INTEGER) AS tok_out, json_extract(m.data, '`$.modelID') AS model_id, s.agent AS agent FROM message m LEFT JOIN session s ON s.id = m.session_id WHERE m.time_created >= $cutoff AND json_extract(m.data, '`$.role') IN ('user', 'assistant') AND (json_extract(m.data, '`$.role') = 'user' OR json_extract(m.data, '`$.time.completed') IS NOT NULL) ORDER BY m.session_id, t_created
"@
  $rows = Invoke-OpencodeDb -Sql $sql.Trim()

  # ---------- dedupe de turnos duplicados por forks de sessao (IMP-062) ----------
  # Forks copiam mensagens com ids novos: a chave efetiva e a assinatura
  # temporal do turno t_created|t_completed|role (evidencia: ses_f5d4/ses_f98d
  # guardam os mesmos turnos com message.id diferentes).

  $seenKeys = New-Object 'System.Collections.Generic.HashSet[string]'
  $uniqueRows = New-Object System.Collections.Generic.List[pscustomobject]
  foreach ($r in $rows) {
    $key = ([string]$r.t_created) + '|' + ([string]$r.t_completed) + '|' + ([string]$r.role)
    if ($seenKeys.Add($key)) { [void]$uniqueRows.Add($r) }
  }
  $rows = @($uniqueRows.ToArray())

  # ---------- turnos (assistant concluídos) ----------

  $turnList = New-Object System.Collections.Generic.List[pscustomobject]
  foreach ($r in $rows) {
    if ($r.role -ne 'assistant') { continue }
    if (($null -eq $r.t_created) -or ($null -eq $r.t_completed)) { continue }
    $t0 = [int64]$r.t_created
    $t1 = [int64]$r.t_completed
    $ms = $t1 - $t0
    if ($ms -lt 0) { continue }
    $dt = [DateTimeOffset]::FromUnixTimeMilliseconds($t0).LocalDateTime
    $agent = 'desconhecido'
    if (-not [string]::IsNullOrEmpty([string]$r.agent)) { $agent = [string]$r.agent }
    $model = 'desconhecido'
    if (-not [string]::IsNullOrEmpty([string]$r.model_id)) { $model = [string]$r.model_id }
    $tokIn = [int64]0
    if ($null -ne $r.tok_in) { $tokIn = [int64]$r.tok_in }
    [void]$turnList.Add([pscustomobject]@{
        session_id = [string]$r.session_id
        t_created  = $t0
        turn_ms    = [long]$ms
        day        = $dt.ToString('yyyy-MM-dd')
        agent      = $agent
        model      = $model
        tok_in     = $tokIn
      })
  }

  # ---------- janela user -> resposta ----------

  $frList = New-Object System.Collections.Generic.List[long]
  $irList = New-Object System.Collections.Generic.List[long]
  foreach ($g in ($rows | Group-Object -Property session_id)) {
    $seq = @($g.Group | Sort-Object -Property { [int64]$_.t_created })
    for ($i = 0; $i -lt $seq.Count; $i++) {
      $m = $seq[$i]
      if ($m.role -ne 'user') { continue }
      if ($null -eq $m.t_created) { continue }
      $uT = [int64]$m.t_created
      $firstDone = $false
      $lastDoneMs = $null
      for ($j = $i + 1; $j -lt $seq.Count; $j++) {
        $a = $seq[$j]
        if ($a.role -eq 'user') { break }
        if ($a.role -ne 'assistant') { continue }
        if ($null -eq $a.t_completed) { continue }
        $aDone = [int64]$a.t_completed
        if (-not $firstDone) {
          $frMs = $aDone - $uT
          if ($frMs -ge 0) { [void]$frList.Add($frMs) }
          $firstDone = $true
        }
        $lastDoneMs = $aDone
      }
      if ($null -ne $lastDoneMs) {
        $irMs = $lastDoneMs - $uT
        if ($irMs -ge 0) { [void]$irList.Add($irMs) }
      }
    }
  }

  # ---------- janela vazia ----------

  if ($turnList.Count -eq 0) {
    $empty = [pscustomobject]@{
      generated_at   = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
      days           = $Days
      cutoff_ms      = $cutoff
      source         = 'opencode.db (read-only via opencode db)'
      has_data       = $false
      message        = 'sem dados na janela - aumente -Days ou verifique o opencode.db'
      summary        = $null
      by_day         = @()
      by_agent       = @()
      by_model       = @()
      top_slow       = @()
      context_bloat  = @()
      context_runaway = @()
      interaction    = $null
    }
    $emptyJson = ConvertTo-Json -InputObject $empty -Depth 8
    if (-not [string]::IsNullOrEmpty($OutFile)) {
      Set-Content -LiteralPath $OutFile -Value $emptyJson -Encoding UTF8
    } else {
      Write-Output $emptyJson
    }
    exit 0
  }

  $turns = @($turnList.ToArray())

  # ---------- agregações ----------

  $byDay = @()
  foreach ($g in ($turns | Group-Object -Property day | Sort-Object -Property Name)) {
    $vals = @($g.Group | ForEach-Object { [long]$_.turn_ms })
    $st = Get-LatencyStats -Values $vals
    $byDay += [pscustomobject]@{
      day = $g.Name; turns = $st.count; p50_ms = $st.p50
      p95_ms = $st.p95; max_ms = $st.max; verdict = (Get-Verdict -P95Ms $st.p95)
    }
  }

  $byAgent = @()
  foreach ($g in ($turns | Group-Object -Property agent | Sort-Object -Property Name)) {
    $vals = @($g.Group | ForEach-Object { [long]$_.turn_ms })
    $st = Get-LatencyStats -Values $vals
    $byAgent += [pscustomobject]@{
      agent = $g.Name; turns = $st.count; p50_ms = $st.p50
      p95_ms = $st.p95; max_ms = $st.max; verdict = (Get-Verdict -P95Ms $st.p95)
    }
  }

  $byModel = @()
  foreach ($g in ($turns | Group-Object -Property model | Sort-Object -Property Name)) {
    $vals = @($g.Group | ForEach-Object { [long]$_.turn_ms })
    $st = Get-LatencyStats -Values $vals
    $byModel += [pscustomobject]@{
      model = $g.Name; turns = $st.count; p50_ms = $st.p50
      p95_ms = $st.p95; max_ms = $st.max; verdict = (Get-Verdict -P95Ms $st.p95)
    }
  }

  # ---------- top-N turnos mais lentos ----------

  $topSlowRows = @($turns | Sort-Object -Property turn_ms -Descending | Select-Object -First $TopSlow | ForEach-Object {
      [pscustomobject]@{
        session = (Get-ShortId -Id ([string]$_.session_id))
        agent   = $_.agent
        model   = $_.model
        day     = $_.day
        tok_in  = $_.tok_in
        turn_ms = $_.turn_ms
      }
    })

  # ---------- context bloat por sessão (>= 4 turnos) ----------

  $bloat = @()
  $insufficient = 0
  foreach ($g in ($turns | Group-Object -Property session_id)) {
    $stArr = @($g.Group | Sort-Object -Property t_created)
    $n = $stArr.Count
    if ($n -lt 4) { $insufficient++; continue }
    $firstTok = [long]$stArr[0].tok_in
    $lastTok = [long]$stArr[$n - 1].tok_in
    $ratio = $null
    if ($firstTok -gt 0) { $ratio = [math]::Round(($lastTok / [double]$firstTok), 2) }
    $half = [int][math]::Floor($n / 2)
    $earlyVals = @()
    $lateVals = @()
    for ($k = 0; $k -lt $n; $k++) {
      if ($k -lt $half) { $earlyVals += [long]$stArr[$k].turn_ms }
      else { $lateVals += [long]$stArr[$k].turn_ms }
    }
    $early = Get-LatencyStats -Values $earlyVals
    $late = Get-LatencyStats -Values $lateVals
    $latencyGrew = $false
    if (($null -ne $early) -and ($null -ne $late) -and ($early.p95 -gt 0)) {
      if ($late.p95 -gt (2 * $early.p95)) { $latencyGrew = $true }
    }
    $flag = ''
    if (($null -ne $ratio) -and ($ratio -gt 3) -and $latencyGrew) { $flag = 'CONTEXT BLOAT' }
    elseif ($latencyGrew -and ($null -eq $ratio)) { $flag = 'LATENCIA CRESCENTA (tok N/A)' }
    if ($flag -ne '') {
      $bloat += [pscustomobject]@{
        session      = (Get-ShortId -Id ([string]$g.Name))
        turns        = $n
        tok_in_first = $firstTok
        tok_in_last  = $lastTok
        ratio        = $ratio
        p95_early_ms = $early.p95
        p95_late_ms  = $late.p95
        flag         = $flag
      }
    }
  }

  # ---------- contexto runaway (tamanho absoluto, IMP-042) ----------

  $runaway = @()
  foreach ($g in ($turns | Group-Object -Property session_id)) {
    $over = @($g.Group | Where-Object { [long]$_.tok_in -gt [int64]$RunawayTokIn })
    if ($over.Count -gt 0) {
      $overMax = [long](($over | ForEach-Object { [long]$_.tok_in } | Measure-Object -Maximum).Maximum)
      $runaway += [pscustomobject]@{
        session     = (Get-ShortId -Id ([string]$g.Name))
        agent       = ([string]($over | Select-Object -First 1).agent)
        turns       = $g.Group.Count
        turns_over  = $over.Count
        max_tok_in  = $overMax
        flag        = 'RUNAWAY CONTEXT'
      }
    }
  }

  # ---------- resumo global + interação ----------

  $allVals = @($turns | ForEach-Object { [long]$_.turn_ms })
  $global = Get-LatencyStats -Values $allVals
  $verdict = Get-Verdict -P95Ms $global.p95
  $sessionCount = @($turns | ForEach-Object { $_.session_id } | Sort-Object -Unique).Count

  $frStats = Get-LatencyStats -Values ($frList.ToArray())
  $irStats = Get-LatencyStats -Values ($irList.ToArray())
  $frCount = 0; $frP50 = $null; $frP95 = $null
  if ($null -ne $frStats) { $frCount = $frStats.count; $frP50 = $frStats.p50; $frP95 = $frStats.p95 }
  $irCount = 0; $irP50 = $null; $irP95 = $null
  if ($null -ne $irStats) { $irCount = $irStats.count; $irP50 = $irStats.p50; $irP95 = $irStats.p95 }

  $result = [pscustomobject]@{
    generated_at = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
    days         = $Days
    cutoff_ms    = $cutoff
    source       = 'opencode.db (read-only via opencode db)'
    has_data     = $true
    summary      = [pscustomobject]@{
      turns                = $global.count
      sessions             = $sessionCount
      p50_ms               = $global.p50
      p95_ms               = $global.p95
      max_ms               = $global.max
      verdict              = $verdict
      bloat_sessions       = $bloat.Count
      runaway_sessions     = $runaway.Count
      insufficient_sessions = $insufficient
    }
    by_day         = $byDay
    by_agent       = $byAgent
    by_model       = $byModel
    top_slow       = $topSlowRows
    context_bloat  = $bloat
    context_runaway = $runaway
    interaction   = [pscustomobject]@{
      samples_first        = $frCount
      p50_first_ms         = $frP50
      p95_first_ms         = $frP95
      samples_interaction  = $irCount
      p50_interaction_ms   = $irP50
      p95_interaction_ms   = $irP95
    }
  }

  $json = ConvertTo-Json -InputObject $result -Depth 8
  if (-not [string]::IsNullOrEmpty($OutFile)) {
    Set-Content -LiteralPath $OutFile -Value $json -Encoding UTF8
  } else {
    Write-Output $json
  }
  exit 0
}
catch {
  Write-Output ('ERRO rdd-perf-auditor: ' + $_.Exception.Message)
  exit 1
}