# ⚡ Otimizador de Desempenho Máximo - Windows 10/11

Script PowerShell para maximizar o desempenho de energia e sistema no Windows 10 e 11.

## 🚀 Funcionalidades

### 🎯 Otimizações de Energia
- Esquema personalizado "Desempenho Máximo"
- Processador 100% performance
- PCI Express Link State OFF
- Wi-Fi Maximum Performance
- GPU Power Throttling Disabled

### ⚡ Otimizações de Sistema
- Desativa CPU Throttling
- Remove Core Parking
- Otimiza prioridade de CPU
- Desativa serviços desnecessários

### 🎮 Otimizações de GPU
- NVIDIA: Modo performance persistente
- AMD: PowerPlay table otimizada
- Configurações agressivas de performance

## 📦 Como Usar

### Execução Rápida
````powershell
# Executar como Administrador
irm https://raw.githubusercontent.com/seu-usuario/otimizador-desempenho/main/max_desempenho_energia.ps1 | iex
````
# 1. Salvar script
# 2. Executar como Admin
````
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\max_desempenho_energia.ps1
````

⚙️ Configurações Aplicadas
🔧 Esquema de Energia
Processador: 100% estado máximo/mínimo

PCI Express: Link State Power Management OFF

Disco: Nunca desligar

USB: Selective suspend DISABLED

Wi-Fi: Maximum Performance

🛑 Serviços Desativados
SuperFetch (SysMain)

Telemetria (DiagTrack)

Push de mensagens

Geolocalização

Windows Search

🎨 Interface
Animações desativadas

Transparência desativada

Efeitos de sombra removidos

📊 Saídas
📋 Arquivos Gerados
relatorio_otimizacao.txt - Relatório completo

Switch_Desempenho.ps1 - Script de alternância

Esquema_Desempenho_Maximo.pow - Backup do esquema

🔄 Controle Rápido
````powershell
# Alternar entre modos
.\Switch_Desempenho.ps1
````
⚠️ Avisos Importantes
🔥 Temperatura
Monitorar temperaturas durante uso intensivo

Verificar cooling system

🔋 Bateria (Notebooks)
Maior consumo de energia

Redução de autonomia

🎯 Compatibilidade
Windows 10/11 64-bit

PowerShell 5.0+

Privilégios administrativos

🔧 Personalização
Edite as variáveis no script:

````powershell
# Modificar configurações de CPU
$powerSettings["54533251-82be-4824-96c1-47b60b740d00"]["75b0ae3f-bce0-45a7-8c89-c9611c25e100"] = 100
````
📞 Suporte
📚 Documentação
Wiki

Troubleshooting

🐛 Reportar Problemas
Verificar logs em Desktop\otimizacao_desempenho_log.txt

Incluir configurações do sistema

📜 Licença
MIT License - veja LICENSE para detalhes.

⭐ Se este projeto ajudou você, considere dar uma estrela no GitHub!

text
````
Este script fornece otimizações completas de desempenho para Windows 10/11 com controle total sobre as configurações de energia! 🚀
````
