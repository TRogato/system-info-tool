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

1. Baixe o arquivo `Reparar_Rede.ps1` e salve em `C:\`
2. Abra o **Prompt de Comando** (cmd.exe) como Administrador
3. Execute:
```powershell
powershell -ExecutionPolicy Bypass -File C:\Reparar_Rede.ps1
```
4. Reinicie o computador quando solicitado

### Opcao 2 — Execucao direta (sem download)

**Metodo mais confiavel** — download manual, depois executa local:

1. Acesse o link e salve o arquivo como `C:\Reparar_Rede.ps1`
2. Abra o **Prompt de Comando** (cmd.exe) como Administrador
3. Execute:
```powershell
powershell -ExecutionPolicy Bypass -File C:\Reparar_Rede.ps1
```

**Ja no PowerShell** (prompt `PS>`), execute como Administrador:
```powershell
.\Reparar_Rede.ps1
```

**Se nao puder usar pendrive** — via PowerShell (se tiver .NET 4.5+ instalado no Win7):
```powershell
[System.Net.ServicePointManager]::SecurityProtocol = 3072
$c = New-Object System.Net.WebClient; $c.Headers.Add('User-Agent','PowerShell'); $c.DownloadFile('https://raw.githubusercontent.com/TRogato/system-info-tool/main/Suporte_compartilhamento/reparar_rede/Reparar_Rede.ps1', "$env:TEMP\r.ps1")
& "$env:TEMP\r.ps1"
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
