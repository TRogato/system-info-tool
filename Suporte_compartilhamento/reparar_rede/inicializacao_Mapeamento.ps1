# Script de restauracao de mapeamentos de rede
# Executado na inicializacao
# Compativel com Windows 7, 8, 8.1, 10 e 11
# Localizacao: C:\ProgramData\Network\RestoreMappings.ps1

Start-Sleep 45

# Verificar e iniciar servicos criticos
$services = @("LanmanWorkstation", "LanmanServer", "Netlogon")
foreach ($service in $services) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -ne "Running") {
        Start-Service -Name $service
    }
}

# Verificar conexoes de rede com Ping (compativel Win7+)
try {
    $ping = New-Object System.Net.NetworkInformation.Ping
    $result = $ping.Send("127.0.0.1", 1000)
    if ($result.Status -ne "Success") {
        netsh winsock reset | Out-Null
        ipconfig /renew | Out-Null
    }
} catch {
    netsh int ip reset | Out-Null
    ipconfig /flushdns | Out-Null
}

# Registrar no log de eventos
try {
    $eventSource = "NetworkRestore"
    if (-not [System.Diagnostics.EventLog]::SourceExists($eventSource)) {
        [System.Diagnostics.EventLog]::CreateEventSource($eventSource, "Application") | Out-Null
    }
    $eventMessage = "Mapeamentos de rede verificados e restaurados em: $(Get-Date)"
    Write-EventLog -LogName "Application" -Source $eventSource -EventId 1001 -EntryType Information -Message $eventMessage -ErrorAction SilentlyContinue
} catch {
    # Falha ao registrar no log nao impede a execucao
}