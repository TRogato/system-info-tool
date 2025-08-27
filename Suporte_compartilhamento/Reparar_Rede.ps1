# Script de Reparo Persistente de Rede do Windows
# Execute como Administrador

function Repair-PersistentNetwork {
    Write-Host "Reparando conexões de rede persistentemente..." -ForegroundColor Green
    
    # 1. Parar serviços críticos de rede
    Write-Host "`n[1/7] Parando serviços de rede..." -ForegroundColor Yellow
    $services = @('Netlogon', 'LanmanWorkstation', 'LanmanServer', 'Dnscache', 'Dhcp')
    foreach ($service in $services) {
        try {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Write-Host " - Serviço $service parado" -ForegroundColor Gray
        } catch {
            Write-Host " - Não foi possível parar $service" -ForegroundColor DarkYellow
        }
    }
    
    # 2. Renomear arquivos de configuração problemáticos
    Write-Host "`n[2/7] Fazendo backup de configurações de rede..." -ForegroundColor Yellow
    $networkFiles = @(
        "$env:SYSTEMROOT\System32\drivers\etc\hosts",
        "$env:SYSTEMROOT\System32\drivers\etc\networks",
        "$env:SYSTEMROOT\System32\drivers\etc\protocol",
        "$env:SYSTEMROOT\System32\drivers\etc\services"
    )
    
    foreach ($file in $networkFiles) {
        if (Test-Path $file) {
            $backupPath = "$file.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item $file $backupPath -Force
            Write-Host " - Backup de $file criado" -ForegroundColor Gray
        }
    }
    
    # 3. Redefinir pilha TCP/IP completamente
    Write-Host "`n[3/7] Redefinindo pilha TCP/IP..." -ForegroundColor Yellow
    netsh int ip reset reset.log | Out-Null
    netsh winsock reset | Out-Null
    netsh interface ipv4 reset | Out-Null
    netsh interface ipv6 reset | Out-Null
    
    # 4. Limpar configurações de rede
    Write-Host "`n[4/7] Limpando configurações de rede..." -ForegroundColor Yellow
    ipconfig /release | Out-Null
    ipconfig /flushdns | Out-Null
    ipconfig /registerdns | Out-Null
    
    # 5. Reconfigurar compartilhamento e descoberta de rede
    Write-Host "`n[5/7] Reconfigurando compartilhamento de rede..." -ForegroundColor Yellow
    netsh advfirewall firewall set rule group="Compartilhamento de Arquivo e Impressora" new enable=Yes | Out-Null
    netsh advfirewall firewall set rule group="Descoberta de Rede" new enable=Yes | Out-Null
    
    # 6. Reiniciar serviços de rede
    Write-Host "`n[6/7] Reiniciando serviços de rede..." -ForegroundColor Yellow
    foreach ($service in $services) {
        try {
            Start-Service -Name $service -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Automatic
            Write-Host " - Serviço $service iniciado e configurado como automático" -ForegroundColor Gray
        } catch {
            Write-Host " - Não foi possível iniciar $service" -ForegroundColor DarkYellow
        }
    }
    
    # 7. Renovar configurações IP
    Write-Host "`n[7/7] Obtendo novas configurações de rede..." -ForegroundColor Yellow
    ipconfig /renew | Out-Null
    
    Write-Host "`nReparo completo! Reinicie o computador para aplicar todas as alterações." -ForegroundColor Green
    
    # Perguntar se deseja reiniciar agora
    $choice = Read-Host "`nDeseja reiniciar agora? (S/N)"
    if ($choice -eq 'S' -or $choice -eq 's') {
        Restart-Computer -Force
    }
}

# Executar a função de reparo
Repair-PersistentNetwork
