import { Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';

@Component({
  selector: 'app-cadastro',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './cadastro.component.html'
})
export class CadastroComponent {
  private readonly fb = inject(FormBuilder);

  // validações exatamente como em UI_SPEC.md (obrigatório, formato, tamanho)
  readonly form = this.fb.nonNullable.group({
    nome: ['', [Validators.required, Validators.minLength(3)]],
    email: ['', [Validators.required, Validators.email]]
  });

  salvar(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    // persistir via service HttpClient (um por recurso do API_CONTRACTS.md)
  }
}
