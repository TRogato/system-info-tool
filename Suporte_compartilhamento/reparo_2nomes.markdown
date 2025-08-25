# 🛠️ Script de Reparação para Windows 10/11

Um script PowerShell completo para diagnóstico e reparação de problemas comuns no Windows 10 e 11, incluindo corrupção do .NET Framework, PowerShell e conexões de rede.

---

## 📋 Funcionalidades

### 🔧 Reparos do Sistema
- **Verificação de Integridade**: Executa o System File Checker (SFC) para corrigir arquivos corrompidos.
- **Reparação de Imagem**: Usa o DISM para restaurar a imagem do sistema.
- **Verificação de Disco**: Executa o CHKDSK para corrigir erros no disco.
- **Reparo do .NET Framework**: Corrige problemas de corrupção ou versões conflitantes.
- **Reinstalação do PowerShell**: Restaura o ambiente PowerShell.

### 🌐 Conexões de Rede
- Limpa conexões de rede antigas.
- Remove credenciais salvas.
- Resolve conflitos de nome de computador.
- Corrige unidades de rede mapeadas.

### 📊 Relatórios
- Gera logs detalhados da execução.
- Produz relatórios completos do sistema.
- Realiza backup automático do registro antes de alterações.

---

## 🚀 Como Usar

### Pré-requisitos
- **Sistemas Suportados**: Windows 10, Windows 11, Windows Server 2016/2019/2022.
- **Requisitos**: PowerShell 5.0 ou superior, privilégios administrativos, conexão à internet (para reparos online).
- **Permissões**: Execute o script como administrador.

### Execução Rápida
Baixe e execute diretamente com PowerShell (como administrador):
```powershell
irm https://raw.githubusercontent.com/seu-usuario/reparacao-windows/main/reparacao_sistema.ps1 | iex
```

### Execução Local
1. Salve o script como `Reparacao-Sistema.ps1`.
2. Execute com um dos métodos abaixo:
   ```powershell
   # Método 1: Clique direito no arquivo > "Executar com PowerShell como Administrador"
   # Método 2: Em um prompt administrativo
   powershell -ExecutionPolicy Bypass -File "C:\caminho\Reparacao-Sistema.ps1"
   ```
3. Se necessário, ajuste a política de execução:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```

### Comandos Específicos
Execute reparos direcionados:
```powershell
# Reparar apenas .NET Framework
.\Reparacao-Sistema.ps1 -Action NetFramework

# Corrigir apenas conexões de rede
.\Reparacao-Sistema.ps1 -Action Network

# Modo silencioso (sem prompts interativos)
.\Reparacao-Sistema.ps1 -Silent
```

---

## 📁 Estrutura do Projeto
```
reparacao-windows/
├── Reparacao-Sistema.ps1         # Script principal
├── Modules/
│   ├── NetFramework-Repair.ps1   # Módulo para reparo do .NET
│   ├── Network-Repair.ps1        # Módulo para reparo de rede
│   └── System-Repair.ps1         # Módulo para reparo do sistema
├── Docs/
│   ├── Troubleshooting.md        # Guia de solução de problemas
│   └── Common-Errors.md          # Erros comuns e soluções
└── Examples/
    └── Usage-Examples.ps1        # Exemplos de uso
```

---

## 🎯 Problemas Resolvidos
- **Erros de PowerShell**:
  - "Não foi possível carregar arquivo ou assembly 'System'".
  - PowerShell abre e fecha rapidamente.
  - Restrições de Execution Policy.
- **Problemas de .NET Framework**:
  - Assemblies corrompidos ou ausentes.
  - Conflitos entre versões.
  - Falhas no registro.
- **Erros de Rede**:
  - "O nome do dispositivo local já está em uso".
  - Conexões de rede não restauradas.
  - Problemas com unidades mapeadas.
- **Outros**:
  - Corrupção de arquivos do sistema.
  - Configurações de registro inválidas.
  - Conflitos de nome de computador.

---

## 📊 Saídas e Logs
O script gera automaticamente:
- **Logs**: `reparacao_log.txt` com detalhes da execução.
- **Relatórios**: `relatorio_reparacao.txt` com informações do sistema.
- **Backups**: Arquivos de registro salvos na área de trabalho.

### Exemplo de Relatório
```
RELATÓRIO DE REPARAÇÃO DO SISTEMA
Data: 2024-01-15 14:30:25
Computador: MEU-PC
Usuário: Admin

VERSÕES INSTALADAS:
- .NET Framework: v4.8.03761
- PowerShell: 5.1.19041.3570

PROBLEMAS IDENTIFICADOS:
- 3 arquivos corrompidos reparados
- 2 conexões de rede problemáticas
- Conflito de nome resolvido

AÇÕES EXECUTADAS:
- SFC: 3 arquivos reparados
- DISM: Imagem restaurada
- .NET: Reparado com sucesso
```

---

## 🔧 Personalização
### Variáveis de Configuração
Edite o script para ajustar:
```powershell
$global:LogPath = "C:\Logs\Reparacao"    # Pasta para logs
$global:BackupPath = "D:\Backups"        # Pasta para backups
$global:EmailReport = $true              # Enviar relatório por email
```

### Adicionar Módulos
Inclua módulos personalizados:
```powershell
Import-Module .\Modules\Custom-Repair.ps1
```

---

## 🛡️ Segurança
- **Verificação de Integridade**: Confirme o hash do script:
  ```powershell
  Get-FileHash .\Reparacao-Sistema.ps1 -Algorithm SHA256
  ```
- **Permissões**: Requer privilégios administrativos.
- **Backups**: O script cria backups automáticos do registro antes de alterações.
- **Confirmações**: Ações críticas exigem confirmação do usuário.

---

## 🤝 Contribuição
1. Faça um fork do projeto.
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`).
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`).
4. Push para a branch (`git push origin feature/nova-funcionalidade`).
5. Abra um Pull Request.

### Padrões de Código
- Use verbos padrão do PowerShell (Get, Set, Repair, Test).
- Documente todas as funções.
- Mantenha compatibilidade com PowerShell 5.0+.

---

## 📝 Licença
Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para detalhes.

---

## ⚠️ Aviso Legal
> Este script é fornecido "como está", sem garantias. Use por sua conta e risco. Sempre faça backup dos seus dados antes de executar reparos no sistema.

### Boas Práticas
- Teste o script em um ambiente controlado antes de usar em produção.
- Mantenha backups atualizados.
- Verifique os logs após a execução.

---

## 📞 Suporte
- **Documentação**: Consulte a [Wiki do Projeto](#) ou os arquivos em `Docs/`.
- **Reportar Bugs**: Use o [template de issue](#) e inclua logs relevantes.
- **Comunidade**: Participe das [Discussions](#) no GitHub.

⭐ **Gostou do projeto?** Dê uma estrela no GitHub!

---

## 📁 Arquivos Adicionais

### 1. `LICENSE`
```text
MIT License
Copyright (c) 2024 [Seu Nome]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### 2. `.gitignore`
```text
# Logs e relatórios
*.log
*.txt
/reports/

# Backups do Windows
*.reg
*.bak

# Arquivos temporários
*.tmp
*.temp

# Pastas de cache
__pycache__/
*.pyc
```

### 3. `CHANGELOG.md`
```markdown
# Changelog

## [1.0.0] - 2024-01-15
### Adicionado
- Script principal de reparação do sistema.
- Módulos para reparo de .NET, rede e sistema.
- Documentação completa com exemplos de uso.
- Suporte para Windows 10, 11 e Server 2016/2019/2022.
```