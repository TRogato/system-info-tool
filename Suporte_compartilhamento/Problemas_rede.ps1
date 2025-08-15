<#
.SYNOPSIS
    Menu interativo para solução de problemas de Windows Update e rede
.DESCRIPTION
    Script com menu para resolver problemas de atualização e conexões de rede
.NOTES
    Autor: Sistema
    Versão: 1.2
    Requer: PowerShell 5.1 ou superior (executar como Administrador)
#>

function Show-Menu {
    param (
        [string]$Title = 'MENU DE SOLUÇÃO DE PROBLEMAS'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "1. Solucionar problemas de Windows Update"
    Write-Host "2. Reparar conexões de rede"
    Write-Host "3. Mapear unidade de rede"
    Write-Host "4. Verificar serviços críticos"
    Write-Host "5. Executar todas as verificações"
    Write-Host "Q. Sair"
}

function Repair-WindowsUpdate {
    Write-Host "`n[1] Reparando Windows Update..."
    
    # Parar serviços
    $services = 'wuauserv','cryptSvc','bits','msiserver'
    $services | ForEach-Object {
        Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
        Write-Host " - Serviço $_ parado"
    }
    
    # Renomear pastas de cache
    $folders = @(
        @{Path = "$env:windir\SoftwareDistribution"; NewName = "SoftwareDistribution.old"},
        @{Path = "$env:windir\System32\catroot2"; NewName = "catroot2.old"}
    )
    
    foreach ($folder in $folders) {
        if (Test-Path $folder.Path) {
            Rename-Item -Path $folder.Path -NewName $folder.NewName -Force
            Write-Host " - Pasta $($folder.Path) renomeada"
        }
    }
    
    # Reiniciar serviços
    $services | ForEach-Object {
        Start-Service -Name $_
        Write-Host " - Serviço $_ iniciado"
    }
    
    # Executar verificações do sistema
    Write-Host "`n[1.1] Executando SFC..."
    sfc /scannow
    
    Write-Host "`n[1.2] Executando DISM..."
    DISM /Online /Cleanup-Image /RestoreHealth
    
    Write-Host "`n[1.3] Forçando detecção de atualizações..."
    usoclient StartScan
    
    Write-Host "`n[1] Reparo do Windows Update completo!"
    Pause
}

function Repair-Network {
    Write-Host "`n[2] Reparando conexões de rede..."
    
    # Redefinir pilha TCP/IP
    Write-Host " - Redefinindo pilha TCP/IP"
    netsh int ip reset | Out-Null
    netsh winsock reset | Out-Null
    
    # Reiniciar serviços de rede
    $netServices = 'Netlogon','LanmanWorkstation','LanmanServer'
    $netServices | ForEach-Object {
        Restart-Service -Name $_ -Force
        Write-Host " - Serviço $_ reiniciado"
    }
    
    # Liberar e renovar IP
    Write-Host " - Liberando configurações de rede"
    ipconfig /release | Out-Null
    ipconfig /renew | Out-Null
    ipconfig /flushdns | Out-Null
    
    Write-Host "`n[2] Reparo de rede completo!"
    Pause
}

function Map-NetworkDrive {
    Write-Host "`n[3] Mapeamento de unidade de rede"
    
    $driveLetter = Read-Host "Digite a letra da unidade (ex: X:)"
    $networkPath = Read-Host "Digite o caminho de rede (ex: \\servidor\pasta)"
    $username = Read-Host "Digite o nome de usuário"
    $password = Read-Host "Digite a senha" -AsSecureString
    
    try {
        $cred = New-Object System.Management.Automation.PSCredential($username, $password)
        New-PSDrive -Name $driveLetter[0] -PSProvider FileSystem -Root $networkPath -Credential $cred -Persist -ErrorAction Stop
        Write-Host "`nUnidade $driveLetter mapeada com sucesso para $networkPath"
    } catch {
        Write-Host "`nErro ao mapear unidade: $_" -ForegroundColor Red
    }
    
    Pause
}

function Check-CriticalServices {
    Write-Host "`n[4] Verificando serviços críticos..."
    
    $services = @(
        @{Name='wuauserv'; Description='Windows Update'},
        @{Name='BITS'; Description='Transferência Inteligente'},
        @{Name='Dhcp'; Description='Cliente DHCP'},
        @{Name='Dnscache'; Description='DNS Client'},
        @{Name='LanmanWorkstation'; Description='Workstation'}
    )
    
    foreach ($service in $services) {
        $status = Get-Service -Name $service.Name -ErrorAction SilentlyContinue
        if ($status) {
            Write-Host " - $($service.Description): $($status.Status)"
        } else {
            Write-Host " - $($service.Description): NÃO ENCONTRADO" -ForegroundColor Red
        }
    }
    
    Pause
}

# Menu principal
do {
    Show-Menu
    $selection = Read-Host "`nSelecione uma opção"
    
    switch ($selection) {
        '1' { Repair-WindowsUpdate }
        '2' { Repair-Network }
        '3' { Map-NetworkDrive }
        '4' { Check-CriticalServices }
        '5' { 
            Repair-WindowsUpdate
            Repair-Network
            Check-CriticalServices
        }
    }
}
until ($selection -eq 'Q' -or $selection -eq 'q')

Write-Host "`nScript finalizado. Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')