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

### Opcao 1 — Download e execucao local

1. Execute o PowerShell como **Administrador**
2. Baixe e execute:
```powershell
.\Reparar_Rede.ps1
```
3. Reinicie o computador quando solicitado

### Opcao 2 — Execucao direta (sem download)

Se ja estiver no PowerShell (prompt `PS>`), cole direto:
```powershell
$c = New-Object System.Net.WebClient; $c.Headers.Add('User-Agent','PowerShell'); iex $c.DownloadString('https://raw.githubusercontent.com/TRogato/system-info-tool/main/Suporte_compartilhamento/reparar_rede/Reparar_Rede.ps1')
```

No **cmd.exe** (Prompt de Comando), Win7:
```powershell
powershell -ExecutionPolicy Bypass -Command "& { $c = New-Object System.Net.WebClient; $c.Headers.Add('User-Agent','PowerShell'); iex $c.DownloadString('https://raw.githubusercontent.com/TRogato/system-info-tool/main/Suporte_compartilhamento/reparar_rede/Reparar_Rede.ps1') }"
```

No **cmd.exe**, Win8+:
```powershell
powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/TRogato/system-info-tool/main/Suporte_compartilhamento/reparar_rede/Reparar_Rede.ps1' -UseBasicParsing).Content"
```

Se o problema persistir, execute `.\Restaurar_Mapeamentos.ps1` para criar uma tarefa agendada de reparo automatico no boot.

## Alteracoes para compatibilidade

- `Test-NetConnection` substituido por `System.Net.NetworkInformation.Ping` (Win7+)
- `Restart-Service -Force` substituido por `Stop-Service` + `Start-Service`
- `Set-Service -StartupType` substituido por `sc.exe config` no Win7
- `New-ScheduledTask*` cmdlets substituidos por `schtasks.exe` no Win7
- `netsh interface ipv6 reset` pulado no Win7 (nao suportado)
- `Start-Sleep -Seconds` substituido por `Start-Sleep` (PS2.0+)
- Criacao automatica de `EventLog Source` quando inexistente
