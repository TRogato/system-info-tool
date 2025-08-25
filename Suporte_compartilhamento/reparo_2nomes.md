# 🛠️ Script de Reparação para Windows 10/11

Script PowerShell completo para diagnóstico e reparação de problemas comuns no Windows 10 e 11, incluindo corrupção do .NET Framework, PowerShell e conexões de rede.

## 📋 Funcionalidades

### 🔧 Reparação do Sistema
- Verificação de integridade de arquivos (SFC)
- Reparação da imagem do sistema (DISM)
- Verificação de disco (CHKDSK)
- Reparo do .NET Framework
- Reinstalação do PowerShell

### 🌐 Conexões de Rede
- Limpeza de conexões de rede antigas
- Remoção de credenciais salvas
- Correção de conflitos de nome de computador
- Reparo de unidades de rede mapeadas

### 📊 Relatórios
- Log detalhado de execução
- Relatório completo do sistema
- Backup automático do registro

## 🚀 Como Usar

### Execução Rápida
powershell
# Download e execução direta (como Administrador)
```
irm https://raw.githubusercontent.com/seu-usuario/reparacao-windows/main/reparacao_sistema.ps1 | iex
```
Execução Local
Salve o script:
````
# Copie o conteúdo para um arquivo .ps1
Reparacao-Sistema.ps1
````
Execute como Administrador:

cmd
````
# Método 1 - Clique direito > "Executar com PowerShell"
# Método 2 - Prompt administrativo:
powershell -ExecutionPolicy Bypass -File "C:\caminho\Reparacao-Sistema.ps1"
````
Permissões necessárias
powershell
````
# Se necessário, permita execução de scripts:
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
````
⚡ Comandos Rápidos
Para problemas específicos:
powershell
````
# Apenas reparar .NET Framework
.\Reparacao-Sistema.ps1 -Action NetFramework
````
````
# Apenas corrigir conexões de rede  
.\Reparacao-Sistema.ps1 -Action Network
````
````
# Modo silencioso (sem prompts)
.\Reparacao-Sistema.ps1 -Silent
````
📁 Estrutura do Projeto
reparacao-windows/
│
├── Reparacao-Sistema.ps1      # Script principal
├── Modules/
│   ├── NetFramework-Repair.ps1   # Módulo .NET
│   ├── Network-Repair.ps1        # Módulo rede
│   └── System-Repair.ps1         # Módulo sistema
├── Docs/
│   ├── Troubleshooting.md       # Guia de solução de problemas
│   └── Common-Errors.md         # Erros comuns e soluções
└── Examples/
    └── Usage-Examples.ps1       # Exemplos de uso

🎯 Problemas Resolvidos
❌ Erros de PowerShell
"Não foi possível carregar arquivo ou assembly 'System'"

PowerShell abre e fecha rapidamente

Execution Policy restritiva

❌ Problemas de .NET Framework
Assembly missing ou corrompido

Versões conflitantes

Falha no registro

❌ Erros de Rede
"O nome do dispositivo local já está em uso"

Conexões de rede não restauradas

Unidades mapeadas com problemas

❌ Outros Problemas
Corrupção de arquivos do sistema

Configurações de registro inválidas

Conflitos de nome de computador

📊 Saídas e Logs
O script gera automaticamente:

📝 Arquivos de Log
reparacao_log.txt - Log detalhado da execução

relatorio_reparacao.txt - Relatório completo do sistema

Backups do registro na área de trabalho

📋 Exemplo de Relatório
````
RELATÓRIO DE REPARAÇÃO DO SISTEMA
Data: 2024-01-15 14:30:25
Computador: MEU-PC
Usuário: Admin

VERSÕES INSTALADAS:
.NET Framework: v4.8.03761
PowerShell: 5.1.19041.3570

PROBLEMAS IDENTIFICADOS:
- 3 arquivos corrompidos reparados
- 2 conexões de rede problemáticas
- Conflito de nome resolvido

AÇÕES EXECUTADAS:
- SFC: 3 arquivos reparados
- DISM: Imagem restaurada
- .NET: Reparado com sucesso
````
⚠️ Requisitos do Sistema
✅ Sistemas Suportados
Windows 10 (todas as versões)

Windows 11 (todas as versões)

Windows Server 2016/2019/2022

📦 Pré-requisitos
PowerShell 5.0 ou superior

Acesso administrativo

Conexão com internet (para download de reparos)

🔧 Personalização
Variáveis de Configuração
````
# Edite o script para personalizar:
$global:LogPath = "C:\Logs\Reparacao"    # Pasta de logs
$global:BackupPath = "D:\Backups"        # Pasta de backups  
$global:EmailReport = $true              # Enviar email com relatório
````
Adicionar Módulos
````
# Importar módulos personalizados
Import-Module .\Modules\Custom-Repair.ps1
````
🛡️ Segurança
✅ Verificação de Integridade
````
# Verificar hash do script
Get-FileHash .\Reparacao-Sistema.ps1 -Algorithm SHA256
````
🔒 Permissões
Execução requer privilégios administrativos

Backup automático do registro antes de modificações

Confirmação para ações críticas

🤝 Contribuição
Como Contribuir
Fork o projeto

Crie uma branch para sua feature

Commit suas mudanças

Push para a branch

Abra um Pull Request

📋 Padrões de Código
Use verbs apropriados (Get, Set, Repair, Test)

Documente todas as funções

Mantenha compatibilidade com PS 5.0+

📝 Licença
Este projeto está sob licença MIT. Veja o arquivo LICENSE para detalhes.

⚠️ Aviso Legal
Disclaimer
````
ESTE SCRIPT É FORNECIDO "COMO ESTÁ", SEM GARANTIAS. USE POR SUA CONTA E RISCO.
SEMPRE FAÇA BACKUP DE SEUS DADOS ANTES DE EXECUTAR QUALQUER REPARAÇÃO DO SISTEMA.
````
Responsabilidades
Teste em ambiente controlado antes de usar em produção

Mantenha backups atualizados

Verifique logs após execução

📞 Suporte
📚 Documentação
Wiki do Projeto
Guia de Troubleshooting
Perguntas Frequentes

🐛 Reportar Bugs
Verifique se o bug já foi reportado
Use o template de issue fornecido
Inclua logs e relatórios relevantes

💬 Comunidade
Discussions
Examples
Contributing Guidelines
⭐ Se este projeto ajudou você, considere dar uma estrela no GitHub!

````
## 📁 Estrutura de Arquivos Adicionais

Crie também estes arquivos no repositório:

### 1. `LICENSE`
```text
MIT License
Copyright (c) 2024 [Seu Nome]
...
````
2. .gitignore
````
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
````
3. CHANGELOG.md
````
# Changelog

## [1.0.0] - 2024-01-15
### Added
- Script principal de reparação
- Módulos de .NET, rede e sistema
- Documentação completa
- Exemplos de uso
````
