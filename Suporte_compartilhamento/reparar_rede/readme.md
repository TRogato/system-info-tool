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

**Metodo mais confiavel (qualquer versao)** — download + execucao em 2 passos:

Passo 1 — baixar o script:
```powershell
$c = New-Object System.Net.WebClient; $c.Headers.Add('User-Agent','PowerShell'); $c.DownloadFile('https://raw.githubusercontent.com/TRogato/system-info-tool/main/Suporte_compartilhamento/reparar_rede/Reparar_Rede.ps1', "$env:TEMP\r.ps1")
```

Passo 2 — executar:
```powershell
& "$env:TEMP\r.ps1"
```

**Metodo inline (uma linha)** — se o terminal nao quebrar a linha:

No PowerShell ja aberto (prompt `PS>`):
```powershell
iex (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/TRogato/system-info-tool/main/Suporte_compartilhamento/reparar_rede/Reparar_Rede.ps1')
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
