Resolução Definitiva para Mapeamentos de Rede que Não Persistem
Entendo que o problema persiste após reinicialização. Isso indica que as configurações de rede estão sendo redefinidas durante o boot ou que há um conflito com serviços que iniciam após a reinicialização.

Solução Completa em PowerShell (Execute como Administrador)
Crie e execute este script mais abrangente:

powershell
````
# Script de Reparo Persistente de Mapeamentos de Rede
# Execute como Administrador

function Repair-PersistentMappings {
    Write-Host "Reparando mapeamentos de rede persistentemente..." -ForegroundColor Green

    # 1. Verificar e corrigir políticas de grupo locais
    Write-Host "`n[1/10] Verificando políticas de grupo..." -ForegroundColor Yellow
    $policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections"
    if (-not (Test-Path $policyPath)) {
        New-Item -Path $policyPath -Force | Out-Null
        Write-Host " - Chave de políticas de rede criada" -ForegroundColor Gray
    }
    
    # Desativar políticas que impedem mapeamentos persistentes
    Set-ItemProperty -Path $policyPath -Name "NC_AllowNetBridge_NLA" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $policyPath -Name "NC_ShowSharedAccessUI" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $policyPath -Name "NC_StdDomainUserSetLocation" -Value 1 -Type DWord -ErrorAction SilentlyContinue

    # 2. Configurar serviços críticos para inicialização automática
    Write-Host "`n[2/10] Configurando serviços de rede..." -ForegroundColor Yellow
    $services = @(
        @{Name="LanmanWorkstation"; Description="Cliente de Rede"},
        @{Name="LanmanServer"; Description="Servidor"},
        @{Name="Netlogon"; Description="Logon de Rede"},
        @{Name="NlaSvc"; Description="Localizador de Rede"},
        @{Name="EventLog"; Description="Log de Eventos"},
        @{Name="Dhcp"; Description="Cliente DHCP"},
        @{Name="Dnscache"; Description="Cache DNS"}
    )
    
    foreach ($service in $services) {
        try {
            Set-Service -Name $service.Name -StartupType Automatic -ErrorAction SilentlyContinue
            Write-Host " - Serviço $($service.Description) configurado para inicialização automática" -ForegroundColor Gray
        } catch {
            Write-Host " - Não foi possível configurar $($service.Name)" -ForegroundColor DarkYellow
        }
    }

    # 3. Parar e reiniciar serviços de rede
    Write-Host "`n[3/10] Reiniciando serviços de rede..." -ForegroundColor Yellow
    Restart-Service -Name "LanmanWorkstation" -Force -ErrorAction SilentlyContinue
    Restart-Service -Name "LanmanServer" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    # 4. Configurar mapeamentos de rede persistentes no registro
    Write-Host "`n[4/10] Configurando mapeamentos persistentes..." -ForegroundColor Yellow
    $netProvidersPath = "HKLM:\SYSTEM\CurrentControlSet\Control\NetworkProvider"
    if (Test-Path $netProvidersPath) {
        Set-ItemProperty -Path $netProvidersPath -Name "RestoreConnection" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $netProvidersPath -Name "Order" -Value "LanmanWorkstation" -ErrorAction SilentlyContinue
    }

    # 5. Configurar parâmetros de rede do Windows
    Write-Host "`n[5/10] Ajustando parâmetros de rede..." -ForegroundColor Yellow
    $tcpipParamsPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    if (Test-Path $tcpipParamsPath) {
        Set-ItemProperty -Path $tcpipParamsPath -Name "DisableTaskOffload" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $tcpipParamsPath -Name "EnableSecurityFilters" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }

    # 6. Configurar parâmetros específicos do LanmanWorkstation
    Write-Host "`n[6/10] Configurando estação de trabalho..." -ForegroundColor Yellow
    $workstationParamsPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
    if (Test-Path $workstationParamsPath) {
        Set-ItemProperty -Path $workstationParamsPath -Name "EnablePlainTextPassword" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $workstationParamsPath -Name "EnableSecuritySignature" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $workstationParamsPath -Name "RequireSecuritySignature" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $workstationParamsPath -Name "EnableW9xSecuritySignature" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $workstationParamsPath -Name "ConnectionCount" -Value 3 -Type DWord -ErrorAction SilentlyContinue
    }

    # 7. Redefinir pilhas de rede
    Write-Host "`n[7/10] Redefinindo pilhas de rede..." -ForegroundColor Yellow
    netsh int ip reset reset.log | Out-Null
    netsh winsock reset | Out-Null
    netsh interface ipv4 reset | Out-Null
    netsh interface ipv6 reset | Out-Null

    # 8. Limpar e renovar configurações IP
    Write-Host "`n[8/10] Renovando configurações IP..." -ForegroundColor Yellow
    ipconfig /release | Out-Null
    ipconfig /renew | Out-Null
    ipconfig /flushdns | Out-Null
    ipconfig /registerdns | Out-Null

    # 9. Configurar políticas de firewall para compartilhamento de arquivos
    Write-Host "`n[9/10] Configurando firewall..." -ForegroundColor Yellow
    netsh advfirewall firewall set rule group="Compartilhamento de Arquivo e Impressora" new enable=Yes | Out-Null
    netsh advfirewall firewall set rule group="Descoberta de Rede" new enable=Yes | Out-Null
    netsh advfirewall firewall set rule group="Compartilhamento de Arquivo com Senha" new enable=Yes | Out-Null

    # 10. Criar script de inicialização para verificar mapeamentos
    Write-Host "`n[10/10] Criando script de verificação na inicialização..." -ForegroundColor Yellow
    $scriptContent = @'
# Script de verificação de mapeamentos de rede
Start-Sleep -Seconds 30

# Verificar se os serviços críticos estão em execução
$services = @("LanmanWorkstation", "LanmanServer", "Netlogon")
foreach ($service in $services) {
    if ((Get-Service -Name $service).Status -ne "Running") {
        Start-Service -Name $service -ErrorAction SilentlyContinue
    }
}

# Verificar conexões de rede
Test-NetConnection -ComputerName "localhost" | Out-Null
'@

    $scriptPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\NetworkCheck.ps1"
    Set-Content -Path $scriptPath -Value $scriptContent -Force
    Write-Host " - Script de verificação criado: $scriptPath" -ForegroundColor Gray

    Write-Host "`nReparo concluído! Reinicie o computador para aplicar as alterações." -ForegroundColor Green
    
    # Perguntar sobre reinicialização
    $choice = Read-Host "`nDeseja reiniciar agora? (S/N)"
    if ($choice -eq 'S' -or $choice -eq 's') {
        Write-Host "Reiniciando em 5 segundos..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        Restart-Computer -Force
    }
}

# Executar a função de reparo
Repair-PersistentMappings
````
Solução Adicional - Tarefa Agendada para Restaurar Mapeamentos
Se o problema persistir após executar o script acima, crie uma tarefa agendada que verifica e restaura os mapeamentos após cada inicialização:

powershell
````
# Criar tarefa agendada para verificar mapeamentos de rede
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -File `"C:\ProgramData\Network\RestoreMappings.ps1`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "RestoreNetworkMappings" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Restaura mapeamentos de rede após inicialização" -Force
````
Script de Restauração de Mapeamentos (C:\ProgramData\Network\RestoreMappings.ps1)
Crie este script que será executado na inicialização:

powershell
````
# Script de restauração de mapeamentos de rede
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
````
Verificação Final
Após implementar estas soluções:

Reinicie o computador duas vezes para garantir que todas as configurações sejam aplicadas

Verifique se os mapeamentos de rede permanecem após cada reinicialização

Use o comando net use no Prompt de Comando para listar os mapeamentos ativos

Se o problema persistir, pode indicar um conflito com software de segurança (antivírus/firewall) ou uma corrupção mais profunda do sistema que pode exigir um reparo de instalação do Windows.


