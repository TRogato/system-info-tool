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