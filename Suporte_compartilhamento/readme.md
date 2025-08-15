Script de Suporte para Compartilhamento de Rede e Windows Update
📌 Descrição
Este script PowerShell fornece um menu interativo para solucionar problemas comuns de:

Windows Update

Conexões de rede

Mapeamento de compartilhamentos de rede

Verificação de serviços críticos

📥 Instalação/Execução
Método Rápido (execução direta):
powershell
irm https://raw.githubusercontent.com/TRogato/system-info-tool/main/Suporte_compartilhamento/Problemas_rede.ps1 | iex
Método Alternativo (download + execução):
powershell
$url = "https://raw.githubusercontent.com/TRogato/system-info-tool/main/Suporte_compartilhamento/Problemas_rede.ps1"
$path = "$env:TEMP\Problemas_rede.ps1"
irm $url -OutFile $path
& $path
🛠️ Funcionalidades
1. Reparar Windows Update
Reseta componentes do Windows Update

Executa verificações de integridade do sistema (SFC/DISM)

Limpa cache de atualizações

2. Reparar Conexões de Rede
Reseta pilha TCP/IP

Reinicia serviços de rede críticos

Libera/renew DHCP e limpa cache DNS

3. Mapear Unidade de Rede
Interface interativa para mapeamento seguro

Suporte a autenticação com credenciais

4. Verificar Serviços Críticos
Verifica status dos serviços essenciais

Inclui Windows Update, BITS, DHCP e outros

⚠️ Requisitos
PowerShell 5.1 ou superior

Executar como Administrador

Conexão com internet (para algumas funções)

🔒 Segurança
O script não faz alterações permanentes sem confirmação

Todo o código é visível no repositório GitHub

Recomendado revisar o código antes da execução

📜 Licença
MIT License - Livre para uso e modificação

🤝 Contribuições
Contribuições são bem-vindas! Abra uma issue ou pull request no repositório.
