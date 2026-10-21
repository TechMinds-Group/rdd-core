# run-evals.ps1 — Golden Set Runner (Windows / PowerShell 5.1+)
# Executa os checks dos criteria.yaml contra os baselines (baseline-mode)
# ou contra um modulo arbitrario (--module <path>).
#
# Uso:
#   .\run-evals.ps1                          # todas as fixtures
#   .\run-evals.ps1 -All                     # idem
#   .\run-evals.ps1 -Skill rdd-data-model    # uma skill
#   .\run-evals.ps1 -Fixture rdd-data-model/fixture-001
#   .\run-evals.ps1 -Changed                 # so skills com mudanca no git
#   .\run-evals.ps1 -Golden                  # so golden set humano (IMP-100)
#   .\run-evals.ps1 -Module C:\caminho\modulo  # valida outputs de um modulo real
#
# Exit codes: 0 = sem FAIL de severity error | 1 = ha FAIL error | 2 = erro de uso

param(
  [string]$Skill = "",
  [string]$Fixture = "",
  [switch]$All,
  [switch]$Changed,
  [switch]$Registry,
  [switch]$Golden,
  [string]$Module = ""
)

$ErrorActionPreference = "Continue"
$EvalsRoot  = $PSScriptRoot
$RepoRoot   = Split-Path -Parent $EvalsRoot
$script:CKS = @()
$script:Skipped = @()

# ---------- helpers (nomes seguros: sem colisao com aliases nativos) ----------

function Read-Doc([string]$p) {
  if (-not (Test-Path -LiteralPath $p)) { return $null }
  Get-Content -LiteralPath $p -Raw -Encoding UTF8
}

function Count-Lines([string]$p) {
  if (-not (Test-Path -LiteralPath $p)) { return 0 }
  (Get-Content -LiteralPath $p -Encoding UTF8).Count
}

function Get-NumList([string]$text, [string]$pattern) {
  $l = @()
  foreach ($m in [regex]::Matches($text, $pattern)) {
    $v = [int]$m.Groups[1].Value
    if ($l -notcontains $v) { $l += $v }
  }
  return $l
}

function ConvertTo-Normalized([string]$s) {
  if ($null -eq $s) { return "" }
  $s = $s -replace '\d{4}-\d{2}-\d{2}', '<DATE>'
  $s = $s -replace '\d{2}/\d{2}/\d{4}', '<DATE>'
  $s = $s -replace '\d{2}:\d{2}', '<TIME>'
  $lines = ($s -split "`r?`n") | ForEach-Object { $_ -replace "[ `t]+$", "" }
  $out = @(); $blank = $false
  foreach ($l in $lines) {
    if ($l -match '^\s*$') { if (-not $blank) { $out += $l }; $blank = $true }
    else { $out += $l; $blank = $false }
  }
  return ($out -join "`n")
}

function Test-MermaidBlocks([string]$text) {
  $blocks = [regex]::Matches($text, '(?s)```mermaid\s*\r?\n(.*?)```')
  if ($blocks.Count -eq 0) { return $false }
  $types = @('erDiagram','flowchart','graph','sequenceDiagram','classDiagram','stateDiagram','gantt','pie','mindmap','timeline','journey','gitGraph')
  foreach ($b in $blocks) {
    $body = $b.Groups[1].Value.TrimStart()
    if ($body.Length -eq 0) { return $false }
    $first = ($body -split "`r?`n")[0].Trim()
    $ok = $false
    foreach ($t in $types) { if ($first.StartsWith($t)) { $ok = $true; break } }
    if (-not $ok) { return $false }
    $code = (($body -split "`r?`n") | Where-Object { $_ -notmatch '--' }) -join "`n"
    $ob = ([regex]::Matches($code, '\{')).Count; $cb = ([regex]::Matches($code, '\}')).Count
    if ($ob -ne $cb) { return $false }
    $obk = ([regex]::Matches($code, '\[')).Count; $cbk = ([regex]::Matches($code, '\]')).Count
    if ($obk -ne $cbk) { return $false }
  }
  return $true
}

# ---------- parser mini-YAML (schema criteria.yaml) ----------

function ConvertFrom-SimpleYaml([string]$file) {
  $checks = @(); $cur = $null; $blockKey = ""
  foreach ($line in (Get-Content -LiteralPath $file -Encoding UTF8)) {
    $t = $line.Trim()
    if ($t -match '^-\s*type:\s*(.+)$') {
      if ($null -ne $cur) { $checks += $cur }
      $cur = @{ type = $Matches[1].Trim().Trim('"').Trim("'") }; $blockKey = ""
    }
    elseif (($null -ne $cur) -and $t -match '^-\s*(.+)$' -and $blockKey -ne "") {
      $cur[$blockKey] += $Matches[1].Trim().Trim('"').Trim("'")
    }
    elseif (($null -ne $cur) -and $t -match '^([A-Za-z_]+):\s*(.*)$') {
      $k = $Matches[1]; $v = $Matches[2].Trim()
      if ($v -eq "") { $cur[$k] = @(); $blockKey = $k }
      else {
        $blockKey = ""
        if ($v -match '^\[(.*)\]$') {
          $arr = @()
          foreach ($item in ($Matches[1] -split ',')) { $it = $item.Trim().Trim('"').Trim("'"); if ($it) { $arr += $it } }
          $cur[$k] = $arr
        }
        elseif ($v -match '^(true|false)$') { $cur[$k] = ($v -eq 'true') }
        else { $cur[$k] = $v.Trim('"').Trim("'") }
      }
    }
  }
  if ($null -ne $cur) { $checks += $cur }
  return $checks
}

# ---------- execucao de checks ----------

function Invoke-Check([string]$skill, [string]$fx, [hashtable]$c, [string]$moduleRoot, [string]$fxRoot) {
  $type = $c['type']
  $sev  = if ($c.ContainsKey('severity')) { $c['severity'] } else { 'error' }
  $rel  = if ($c.ContainsKey('path')) { $c['path'] } else { '' }
  $abs  = if ($rel) { Join-Path $moduleRoot ($rel -replace '/', [System.IO.Path]::DirectorySeparatorChar) } else { $moduleRoot }
  $isDirRel = $rel.EndsWith('/') -or $rel.EndsWith('\')
  $isDir = $isDirRel -or (Test-Path -LiteralPath $abs -PathType Container)

  $label = "$fx/$type" + $(if ($rel) { ":$rel" } else { '' })
  # IMP-100 - evals negativos: expect: fail = o check DEVE falhar
  # (output quebra-pratos). PASS num check expect:fail = runner nao
  # discriminou -> vira FAIL do eval.
  $expectFail = ($c.ContainsKey('expect') -and "$($c['expect'])" -eq 'fail')

  function Res([bool]$ok, [string]$d) {
    if ($expectFail) {
      if ($ok) {
        $script:CKS = $script:CKS + @([pscustomobject]@{ Skill = $skill; Fixture = $fx; Check = $label; Result = 'FAIL'; Severity = 'error'; Detail = 'runner nao discriminou (esperado fail, obteve PASS)'; ExpectFail = $true; Caught = $false })
      } else {
        $script:CKS = $script:CKS + @([pscustomobject]@{ Skill = $skill; Fixture = $fx; Check = $label; Result = 'PASS'; Severity = $sev; Detail = "prato pego: $d"; ExpectFail = $true; Caught = $true })
      }
      return
    }
    $state = if ($ok) { 'PASS' } elseif ($sev -eq 'error') { 'FAIL' } else { 'WARN' }
    $script:CKS = $script:CKS + @([pscustomobject]@{ Skill = $skill; Fixture = $fx; Check = $label; Result = $state; Severity = $sev; Detail = $d; ExpectFail = $false; Caught = $false })
  }

  switch ($type) {
    'file_exists'      { Res (Test-Path -LiteralPath $abs -PathType Leaf) "" }
    'not_file_exists'  { Res (-not (Test-Path -LiteralPath $abs)) "" }
    'dir_has_files'    {
      $files = @(Get-ChildItem -LiteralPath $abs -File -Recurse -ErrorAction SilentlyContinue)
      Res ($files.Count -ge 1) "arquivos=$($files.Count)"
    }
    'frontmatter_valid' {
      $doc = Read-Doc $abs
      Res (($null -ne $doc) -and ($doc.StartsWith("---`n") -or $doc.StartsWith("---`r`n"))) ""
    }
    'contains' {
      $pat = $c['pattern']
      if ($isDir) {
        $found = $false
        Get-ChildItem -LiteralPath $abs -Filter '*.md' -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
          $d = Read-Doc $_.FullName
          if (($null -ne $d) -and $d.Contains($pat)) { $found = $true }
        }
        Res $found ""
      } else { $doc = Read-Doc $abs; Res (($null -ne $doc) -and $doc.Contains($pat)) "" }
    }
    'not_contains' {
      $pat = $c['pattern']
      if ($isDir) {
        $found = $false
        Get-ChildItem -LiteralPath $abs -Filter '*.md' -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
          $d = Read-Doc $_.FullName
          if (($null -ne $d) -and $d.Contains($pat)) { $found = $true }
        }
        Res (-not $found) ""
      } else { $doc = Read-Doc $abs; Res (($null -eq $doc) -or (-not $doc.Contains($pat))) "" }
    }
    'no_todos' {
      $pats = @($c['patterns']); $hits = @()
      foreach ($p in $pats) { $doc = Read-Doc $abs; if (($null -ne $doc) -and $doc.Contains($p)) { $hits += $p } }
      Res ($hits.Count -eq 0) ($hits -join ',')
    }
    'section_exists' {
      $doc = Read-Doc $abs
      Res (($null -ne $doc) -and $doc.Contains($c['section'])) ""
    }
    'section_order' {
      $doc = Read-Doc $abs; $idx = @(); $missing = @()
      foreach ($s in @($c['sections'])) { $i = $doc.IndexOf($s); if ($i -lt 0) { $missing += $s } else { $idx += $i } }
      $ordered = $true
      for ($i = 1; $i -lt $idx.Count; $i++) { if ($idx[$i] -le $idx[$i-1]) { $ordered = $false } }
      Res (($missing.Count -eq 0) -and $ordered) $(if ($missing.Count) { "ausentes: $($missing -join '; ')" } else { 'ordem ok' })
    }
    'line_count_range' {
      if ($isDir) {
        $total = 0
        Get-ChildItem -LiteralPath $abs -Filter '*.md' -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $total += (Count-Lines $_.FullName) }
      } else { $total = Count-Lines $abs }
      $min = [int]$c['min']; $max = [int]$c['max']
      Res (($total -ge $min) -and ($total -le $max)) "linhas=$total (faixa $min-$max)"
    }
    'id_sequence' {
      $doc = Read-Doc $abs; $pat = $c['pattern']
      $ids = Get-NumList $doc $pat
      $asc = $true
      for ($i = 1; $i -lt $ids.Count; $i++) { if ($ids[$i] -lt $ids[$i-1]) { $asc = $false } }
      $okRes = $asc
      if (-not $c.ContainsKey('allow_gaps') -or $c['allow_gaps'] -eq $false) {
        for ($i = 1; $i -lt $ids.Count; $i++) { if ($ids[$i] -ne ($ids[$i-1] + 1)) { $okRes = $false } }
      }
      Res $okRes "primeira aparicao: $($ids -join '->')"
    }
    'cross_ref' {
      if ($isDir) {
        $parts = @()
        Get-ChildItem -LiteralPath $abs -Filter '*.md' -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $parts += (Read-Doc $_.FullName) }
        $doc = $parts -join "`n"
      } else { $doc = Read-Doc $abs }
      $pat = $c['pattern']
      $ids = Get-NumList $doc $pat; $srcIds = @()
      foreach ($s in @($c['sources'])) {
        $sp = Join-Path $moduleRoot ($s -replace '/', [System.IO.Path]::DirectorySeparatorChar)
        $sd = Read-Doc $sp; if ($null -ne $sd) { $srcIds = @(Get-NumList $sd $pat) + $srcIds }
      }
      $hall = @($ids | Where-Object { $srcIds -notcontains $_ })
      Res ($hall.Count -eq 0) $(if ($hall.Count) { "alucinados: $($hall -join ',')" } else { "fonte: $(($srcIds | Select-Object -Unique) -join ',')" })
    }
    'mermaid_valid' {
      $doc = Read-Doc $abs
      Res (($null -ne $doc) -and (Test-MermaidBlocks $doc)) ""
    }
    'table_has_columns' {
      $doc = Read-Doc $abs; $cols = @($c['columns']); $found = $false
      foreach ($line in ($doc -split "`r?`n")) {
        if ($line.TrimStart().StartsWith('|')) {
          $all = $true; foreach ($col in $cols) { if (-not $line.Contains($col)) { $all = $false } }
          if ($all) { $found = $true; break }
        }
      }
      Res $found ""
    }
    'reference_match' {
      $doc = Read-Doc $abs
      $expRel = if ($c.ContainsKey('expected')) { $c['expected'] } else { '' }
      $exp = Join-Path $fxRoot ($expRel -replace '/', '\')
      if (-not (Test-Path -LiteralPath $exp)) { $exp = Join-Path $moduleRoot ($rel -replace '/', '\') }
      if (-not (Test-Path -LiteralPath $exp)) { Res $false "baseline ausente: $expRel"; break }
      $expDoc = Read-Doc $exp
      Res ((ConvertTo-Normalized $doc) -eq (ConvertTo-Normalized $expDoc)) ""
    }
    default { $script:Skipped += "$label (tipo desconhecido: $type)" }
  }
}

# ---------- modo registry (IMP-027): consistencia registry.yaml x agentes/skills ----------

if ($Registry) {
  $regPath = Join-Path $RepoRoot 'registry.yaml'
  if (-not (Test-Path -LiteralPath $regPath)) { Write-Output "registry.yaml nao encontrado em $RepoRoot"; exit 1 }
  $regIds = @(); $agentIds = @(); $skillIds = @(); $regRefs = @()
  $section = ""
  foreach ($line in (Get-Content -LiteralPath $regPath -Encoding UTF8)) {
    if ($line -match '^([A-Za-z_]+):') { $section = $Matches[1]; continue }
    if ($line -match '^\s*-\s*id:\s*([\w-]+)\s*$') {
      $id = $Matches[1]; $regIds += $id
      if ($section -in @('primary_agents', 'subagents')) { $agentIds += $id }
      elseif ($section -eq 'skills') { $skillIds += $id }
      continue
    }
    if ($line -match '^\s{4,}-\s*([\w-]+)\s*$') { $regRefs += $Matches[1]; continue }
    if ($line -match '^\s+(owner|registered_by|orchestrator):\s*([\w-]+)\s*$') {
      if ($Matches[2] -ne 'null') { $regRefs += $Matches[2] }  # orchestrator: null = sem orquestrador fixo (legitimo)
    }
  }

  function Add-RegCheck([string]$nome, [bool]$ok, [string]$d) {
    $state = if ($ok) { 'PASS' } else { 'FAIL' }
    $script:CKS = $script:CKS + @([pscustomobject]@{ Skill = '_registry'; Fixture = 'registry'; Check = $nome; Result = $state; Severity = 'error'; Detail = $d })
  }

  $dangling = @($regRefs | Where-Object { $regIds -notcontains $_ } | Sort-Object -Unique)
  Add-RegCheck 'registry:referencias_resolvem' ($dangling.Count -eq 0) ($dangling -join ',')

  $diskAgents = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'agents') -Filter 'rdd-*.md' -ErrorAction SilentlyContinue | ForEach-Object { $_.BaseName })
  $orphanAgents = @($diskAgents | Where-Object { $regIds -notcontains $_ } | Sort-Object -Unique)
  Add-RegCheck 'registry:agentes_em_disco_registrados' ($orphanAgents.Count -eq 0) ($orphanAgents -join ',')

  $missingAgents = @($agentIds | Where-Object { $diskAgents -notcontains $_ } | Sort-Object -Unique)
  Add-RegCheck 'registry:agentes_registrados_tem_arquivo' ($missingAgents.Count -eq 0) ($missingAgents -join ',')

  $diskSkills = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'skills') -Directory -Filter 'rdd-*' -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
  $orphanSkills = @($diskSkills | Where-Object { $skillIds -notcontains $_ } | Sort-Object -Unique)
  Add-RegCheck 'registry:skills_em_disco_registradas' ($orphanSkills.Count -eq 0) ($orphanSkills -join ',')

  $missingSkills = @($skillIds | Where-Object { -not (Test-Path -LiteralPath (Join-Path $RepoRoot "skills/$_/SKILL.md")) } | Sort-Object -Unique)
  Add-RegCheck 'registry:skills_registradas_tem_skill_md' ($missingSkills.Count -eq 0) ($missingSkills -join ',')
}

# ---------- selecao de fixtures ----------

$allFixtures = @()
Get-ChildItem -LiteralPath $EvalsRoot -Directory | Where-Object { $_.Name -like 'rdd-*' } | ForEach-Object {
  $sk = $_.Name
  Get-ChildItem -LiteralPath $_.FullName -Directory | Where-Object { $_.Name -like 'fixture-*' } | ForEach-Object {
    if (Test-Path (Join-Path $_.FullName 'criteria.yaml')) { $allFixtures += [pscustomobject]@{ Skill = $sk; Name = $_.Name; Dir = $_.FullName } }
  }
}
# IMP-100 - golden set humano e selftest do runner (case-* em vez de fixture-*)
foreach ($specialRoot in @('golden-human', 'runner-selftest')) {
  $sp = Join-Path $EvalsRoot $specialRoot
  if (-not (Test-Path -LiteralPath $sp)) { continue }
  Get-ChildItem -LiteralPath $sp -Directory | Where-Object { $_.Name -like 'case-*' } | ForEach-Object {
    if (Test-Path (Join-Path $_.FullName 'criteria.yaml')) { $allFixtures += [pscustomobject]@{ Skill = $specialRoot; Name = $_.Name; Dir = $_.FullName } }
  }
}

$targets = $allFixtures
if ($Golden) { $targets = $allFixtures | Where-Object { $_.Skill -eq 'golden-human' } }
elseif ($Fixture) { $parts = $Fixture -split '/'; $targets = $allFixtures | Where-Object { $_.Skill -eq $parts[0] -and $_.Name -eq $parts[1] } }
elseif ($Skill) { $targets = $allFixtures | Where-Object { $_.Skill -eq $Skill } }
elseif ($Changed) {
  $dirty = git -C $RepoRoot status --porcelain 2>$null
  $changedSkills = @()
  foreach ($line in $dirty) {
    if ($line -match 'evals/([^/]+)/') { $changedSkills += $Matches[1] }
    elseif ($line -match 'skills/([^/]+)/SKILL\.md') { $changedSkills += $Matches[1] }
  }
  $targets = $allFixtures | Where-Object { $changedSkills -contains $_.Skill }
  if ($targets.Count -eq 0) { Write-Output "nenhuma skill alterada tem fixture - nada a rodar"; exit 0 }
}

if ($Registry) { $targets = @() }  # modo registry nao executa fixtures (IMP-027)

# ---------- execucao ----------

foreach ($t in $targets) {
  $moduleRoot = if ($Module) { $Module } else { Join-Path $t.Dir 'output-expected' }
  if (-not (Test-Path -LiteralPath $moduleRoot -PathType Container)) { $moduleRoot = $null }
  $criteria = ConvertFrom-SimpleYaml (Join-Path $t.Dir 'criteria.yaml')
  foreach ($c in $criteria) {
    if ($null -eq $moduleRoot) {
      if ($c['type'] -eq 'not_file_exists') { $script:CKS = $script:CKS + @([pscustomobject]@{ Skill = $t.Skill; Fixture = $t.Name; Check = "$($t.Name)/not_file_exists"; Result = 'PASS'; Severity = 'error'; Detail = 'sem modulo (abort) - PASS' }) }
      else { $script:Skipped += "$($t.Name)/$($c['type']) (modulo ausente)" }
      continue
    }
    Invoke-Check $t.Skill $t.Name $c $moduleRoot $t.Dir
  }
}

# ---------- relatorio ----------

$pass = @($CKS | Where-Object Result -eq 'PASS').Count
$fail = @($CKS | Where-Object Result -eq 'FAIL').Count
$warn = @($CKS | Where-Object Result -eq 'WARN').Count
$total = $CKS.Count

$mode = if ($Golden) { 'golden' } elseif ($Fixture) { "fixture:$Fixture" } elseif ($Skill) { "skill:$Skill" } elseif ($Changed) { 'changed' } elseif ($Registry) { 'registry' } else { 'all' }
Write-Output ""
Write-Output "================ run-evals [$mode] ================"
$CKS | Where-Object { $_.Result -ne 'PASS' } | Format-Table Skill, Fixture, Check, Result, Detail -AutoSize | Out-String -Width 140 | Write-Output
Write-Output "TOTAL: $pass PASS / $fail FAIL / $warn WARN de $total checks $(if ($Skipped.Count) { "($($Skipped.Count) skipped)" })"

# IMP-100 - discriminacao do runner (selftest: pratos quebrados conhecidos)
$stChecks = @($CKS | Where-Object { $_.ExpectFail })
if ($stChecks.Count -gt 0) {
  $caught = @($stChecks | Where-Object { $_.Caught }).Count
  Write-Output "Discriminacao do runner: $caught/$($stChecks.Count) pratos pegos $(if ($caught -lt $stChecks.Count) { '<< RUNNER NAO DISCRIMINA' } else { '(ok)' })"
}

# trends.json (append)
try {
  $trendsPath = Join-Path $EvalsRoot 'trends\trends.json'
  $trends = Get-Content $trendsPath -Raw -Encoding UTF8 | ConvertFrom-Json
  $ts = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
  $skillStats = @{}
  foreach ($g in ($CKS | Group-Object Skill)) {
    $p = @($g.Group | Where-Object Result -eq 'PASS').Count
    $f = @($g.Group | Where-Object Result -ne 'PASS').Count
    $skillStats[$g.Name] = [pscustomobject]@{ score = [math]::Round($p / [math]::Max(1, ($p + $f)), 2); passed = $p; failed = $f; skipped = 0 }
  }
  $entry = [pscustomobject]@{ trigger = 'runner'; mode = $mode; skills = $skillStats }
  $trends | Add-Member -MemberType NoteProperty -Name $ts -Value $entry -Force
  $trends | ConvertTo-Json -Depth 10 | Set-Content $trendsPath -Encoding UTF8
} catch { Write-Output "aviso: trends.json nao atualizado ($($_.Exception.Message))" }

# relatorio markdown
$tsFile = (Get-Date).ToString('yyyy-MM-dd-HHmmss')
$reportPath = Join-Path $EvalsRoot "reports\EVAL_REPORT_runner_$($mode -replace '[:/]', '-')_$tsFile.md"
$rows = ($CKS | ForEach-Object { "| $($_.Skill) | $($_.Fixture) | $($_.Check) | $($_.Result) | $($_.Severity) | $($_.Detail) |" }) -join "`n"
$report = @"
# EVAL REPORT — runner deterministico

> **Data:** $(Get-Date -Format 'dd/MM/yyyy HH:mm')
> **Modo:** $mode
> **Resultado:** $pass PASS / $fail FAIL / $warn WARN de $total checks

| Skill | Fixture | Check | Resultado | Severidade | Detalhe |
|---|---|---|---|---|---|
$rows
"@
Set-Content -Path $reportPath -Value $report -Encoding UTF8
Write-Output "Relatorio: $reportPath"

if ($fail -gt 0) { exit 1 } else { exit 0 }
