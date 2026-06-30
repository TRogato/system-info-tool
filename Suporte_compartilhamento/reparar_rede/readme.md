# Reparo de Rede - System Info Tool

Scripts PowerShell para reparo de mapeamentos de rede persistentes.

## Compatibilidade

- **Windows 7** (PowerShell 2.0+)
- **Windows 8 / 8.1**
- **Windows 10**
- **Windows 11**

## Scripts

| Script | Funcao |
|--------|--------|
| `Reparar_Rede.ps1` | Reparo completo: politicas, servicos, pilha TCP/IP, firewall, inicializacao |
| `Restaurar_Mapeamentos.ps1` | Cria tarefa agendada para restaurar mapeamentos no boot |
| `inicializacao_Mapeamento.ps1` | Script executado na inicializacao (C:\ProgramData\Network\RestoreMappings.ps1) |

## Como usar

1. Execute o PowerShell como **Administrador**
2. Execute: `.\Reparar_Rede.ps1`
3. Reinicie o computador quando solicitado

Se o problema persistir, execute `.\Restaurar_Mapeamentos.ps1` para criar uma tarefa agendada de reparo automatico no boot.

## Alteracoes para compatibilidade

- `Test-NetConnection` substituido por `System.Net.NetworkInformation.Ping` (Win7+)
- `Restart-Service -Force` substituido por `Stop-Service` + `Start-Service`
- `Set-Service -StartupType` substituido por `sc.exe config` no Win7
- `New-ScheduledTask*` cmdlets substituidos por `schtasks.exe` no Win7
- `netsh interface ipv6 reset` pulado no Win7 (nao suportado)
- `Start-Sleep -Seconds` substituido por `Start-Sleep` (PS2.0+)
- Criacao automatica de `EventLog Source` quando inexistente
