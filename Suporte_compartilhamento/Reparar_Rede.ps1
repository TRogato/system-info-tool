# Script Avançado de Reparo de Rede Persistente
# Execute como Administrador

function Repair-AdvancedNetwork {
    Write-Host "Iniciando reparo avançado de rede..." -ForegroundColor Green
    
    # 1. Verificar e corrigir o nome do computador na rede
    Write-Host "`n[1/8] Verificando configurações de nome do computador..." -ForegroundColor Yellow
    $computerName = $env:COMPUTERNAME
    $currentName = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" -Name "ComputerName" -ErrorAction SilentlyContinue
    $activeComputerName = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" -Name "ComputerName" -ErrorAction SilentlyContinue
    
    if ($currentName.ComputerName -ne $activeComputerName.ComputerName) {
        Write-Host " - Conflito de nome detectado no registro" -ForegroundColor Red
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" -Name "ComputerName" -Value $currentName.ComputerName
        Write-Host " - Nome do computador sincronizado no registro" -ForegroundColor Green
    }
    
    # 2. Parar todos os serviços relacionados a rede
    Write-Host "`n[2/8] Parando serviços de rede..." -ForegroundColor Yellow
    $networkServices = @(
        'Netlogon', 'LanmanWorkstation', 'LanmanServer', 
        'Dnscache', 'Dhcp', 'NlaSvc', 'EventLog', 'Netman'
    )
    
    foreach ($service in $networkServices) {
        try {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Write-Host " - Serviço $service parado" -ForegroundColor Gray
        } catch {
            Write-Host " - Não foi possível parar $service" -ForegroundColor DarkYellow
        }
        Start-Sleep -Milliseconds 200
    }
    
    # 3. Limpar configurações de rede antigas
    Write-Host "`n[3/8] Limpando configurações de rede antigas..." -ForegroundColor Yellow
    $pathsToClear = @(
        "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters",
        "HKLM:\SYSTEM\CurrentControlSet\Services\Dhcp",
        "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache",
        "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters"
    )
    
    foreach ($path in $pathsToClear) {
        if (Test-Path $path) {
            try {
                Remove-ItemProperty -Path $path -Name "NameServer" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $path -Name "DhcpNameServer" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $path -Name "DhcpDomain" -ErrorAction SilentlyContinue
                Write-Host " - Configurações limpas em $path" -ForegroundColor Gray
            } catch {
                Write-Host " - Não foi possível limpar $path" -ForegroundColor DarkYellow
            }
        }
    }
    
    # 4. Redefinir completamente a pilha TCP/IP
    Write-Host "`n[4/8] Redefinindo pilha TCP/IP..." -ForegroundColor Yellow
    netsh int ip reset reset.log | Out-Null
    netsh winsock reset | Out-Null
    netsh interface ipv4 reset | Out-Null
    netsh interface ipv6 reset | Out-Null
    netsh interface tcp reset | Out-Null
    netsh http reset iplog | Out-Null
    
    # 5. Reconstruir configurações de compartilhamento
    Write-Host "`n[5/8] Reconstruindo configurações de compartilhamento..." -ForegroundColor Yellow
    $sharingPaths = @(
        "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters",
        "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
    )
    
    foreach ($path in $sharingPaths) {
        if (Test-Path $path) {
            try {
                Remove-ItemProperty -Path $path -Name "Domain" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $path -Name "NameCache" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $path -Name "SessionCache" -ErrorAction SilentlyContinue
                Write-Host " - Configurações de compartilhamento resetadas em $path" -ForegroundColor Gray
            } catch {
                Write-Host " - Não foi possível resetar $path" -ForegroundColor DarkYellow
            }
        }
    }
    
    # 6. Reconfigurar políticas de firewall
    Write-Host "`n[6/8] Reconfigurando firewall..." -ForegroundColor Yellow
    netsh advfirewall reset | Out-Null
    netsh advfirewall firewall set rule group="Compartilhamento de Arquivo e Impressora" new enable=Yes | Out-Null
    netsh advfirewall firewall set rule group="Descoberta de Rede" new enable=Yes | Out-Null
    netsh advfirewall firewall set rule group="Compartilhamento de Arquivo com Senha" new enable=Yes | Out-Null
    
    # 7. Reiniciar serviços de rede
    Write-Host "`n[7/8] Reiniciando serviços de rede..." -ForegroundColor Yellow
    foreach ($service in $networkServices) {
        try {
            Start-Service -Name $service -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Automatic -ErrorAction SilentlyContinue
            Write-Host " - Serviço $service iniciado" -ForegroundColor Gray
        } catch {
            Write-Host " - Não foi possível iniciar $service" -ForegroundColor DarkYellow
        }
        Start-Sleep -Milliseconds 300
    }
    
    # 8. Renovar configurações de IP
    Write-Host "`n[8/8] Renovando configurações IP..." -ForegroundColor Yellow
    ipconfig /release | Out-Null
    ipconfig /renew | Out-Null
    ipconfig /flushdns | Out-Null
    ipconfig /registerdns | Out-Null
    
    Write-Host "`nReparo avançado concluído!" -ForegroundColor Green
    Write-Host "Reinicie o computador para aplicar todas as alterações permanentemente." -ForegroundColor Yellow
    
    # Oferecer para reiniciar agora
    $restart = Read-Host "`nDeseja reiniciar agora? (S/N)"
    if ($restart -eq 'S' -or $restart -eq 's') {
        Write-Host "Reiniciando o computador..." -ForegroundColor Green
        Start-Sleep -Seconds 3
        Restart-Computer -Force
    }
}

# Executar a função de reparo
Repair-AdvancedNetwork
