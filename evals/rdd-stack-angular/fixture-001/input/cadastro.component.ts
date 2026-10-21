import { Component } from '@angular/core';

@Component({
  selector: 'app-cadastro',
  standalone: true,
  templateUrl: './cadastro.component.html'
})
export class CadastroComponent {
  nome = '';
  email = '';

  // violação: lógica de exibição hardcoded no component
  get mostrarCampoEmpresa(): boolean {
    return this.email.includes('@corp');
  }

  salvar(): void {
    // violação: validação manual espalhada em vez de Reactive Forms
    if (!this.nome || this.nome.length < 3) {
      alert('Nome inválido');
      return;
    }
    if (!this.email) {
      alert('E-mail obrigatório');
      return;
    }
  }
}
