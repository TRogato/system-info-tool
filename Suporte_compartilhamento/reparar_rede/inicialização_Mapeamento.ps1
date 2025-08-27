# Script de restauração de mapeamentos de rede
#Script de Restauração de Mapeamentos (C:\ProgramData\Network\RestoreMappings.ps1)
#Crie este script que será executado na inicialização:
Start-Sleep -Seconds 45

# Verificar e iniciar serviços críticos
$services = @("LanmanWorkstation", "LanmanServer", "Netlogon")
foreach ($service in $services) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -ne "Running") {
        Start-Service -Name $service
    }
}

# Verificar conexões de rede
try {
    $networkTest = Test-NetConnection -ComputerName "localhost" -InformationLevel Quiet
    if (-not $networkTest) {
        # Rede não está funcionando, tentar reparar
        netsh winsock reset | Out-Null
        ipconfig /renew | Out-Null
    }
} catch {
    # Em caso de erro, tentar reparos básicos
    netsh int ip reset | Out-Null
    ipconfig /flushdns | Out-Null
}

# Registrar no log de eventos
$eventMessage = "Mapeamentos de rede verificados e restaurados em: $(Get-Date)"
Write-EventLog -LogName "Application" -Source "NetworkRestore" -EventId 1001 -EntryType Information -Message $eventMessage -ErrorAction SilentlyContinue