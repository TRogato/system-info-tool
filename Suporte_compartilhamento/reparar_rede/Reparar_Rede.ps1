# Script de Reparo de Rede e Impressoras
# Compativel com Windows 7, 8, 8.1, 10 e 11
# Execute como Administrador

# Requer elevation
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
if (-not $isAdmin) {
    Write-Host "ERROR: Execute como Administrador!" -ForegroundColor Red
    exit 1
}

# Forcar TLS 1.2 para conexoes HTTPS (necessario no Win7 para GitHub)
try {
    [System.Net.ServicePointManager]::SecurityProtocol = 3072
} catch { }

$osVersion = [Environment]::OSVersion.Version
$isWin8OrLater = $osVersion -ge (New-Object 'Version' 6,2)
$isWin10OrLater = $osVersion -ge (New-Object 'Version' 10,0)

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   REPARO DE REDE E ACESSO A IMPRESSORAS" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Sistema: Windows $($osVersion.Major).$($osVersion.Minor)" -ForegroundColor Gray
Write-Host ""

# ============================================================
# 1. VERIFICAR PERFIL DE REDE (manter como Privada)
# ============================================================
Write-Host "[1/15] Verificando perfil de rede..." -ForegroundColor Yellow
try {
    $profiles = Get-NetConnectionProfile -ErrorAction SilentlyContinue
    foreach ($profile in $profiles) {
        if ($profile.NetworkCategory -ne "Private") {
            Set-NetConnectionProfile -InterfaceIndex $profile.InterfaceIndex -NetworkCategory Private -ErrorAction SilentlyContinue
            Write-Host " - Perfil '$($profile.Name)' alterado para Privado" -ForegroundColor Gray
        } else {
            Write-Host " - Perfil '$($profile.Name)' ja esta como Privado" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host " - Nao foi possivel verificar perfis (comando indisponivel no Win7)" -ForegroundColor DarkYellow
}

# ============================================================
# 2. SERVICOS CRITICOS DE REDE
# ============================================================
Write-Host "[2/15] Configurando servicos de rede..." -ForegroundColor Yellow
$services = @(
    @{Name="LanmanWorkstation"; Startup="Auto"; Desc="Cliente de Rede"}
    @{Name="LanmanServer"; Startup="Auto"; Desc="Servidor"}
    @{Name="Netlogon"; Startup="Auto"; Desc="Logon de Rede"}
    @{Name="NlaSvc"; Startup="Auto"; Desc="Localizador de Rede"}
    @{Name="Dhcp"; Startup="Auto"; Desc="Cliente DHCP"}
    @{Name="Dnscache"; Startup="Auto"; Desc="Cache DNS"}
    @{Name="EventLog"; Startup="Auto"; Desc="Log de Eventos"}
)
foreach ($svc in $services) {
    try {
        if ($isWin10OrLater) {
            Set-Service -Name $svc.Name -StartupType Automatic -ErrorAction SilentlyContinue
        } else {
            sc.exe config $svc.Name start=auto | Out-Null
        }
        Write-Host " - $($svc.Desc) configurado" -ForegroundColor Gray
    } catch { }
}

# ============================================================
# 3. SERVICOS DE DESCOBERTA DE IMPRESSORAS
# ============================================================
Write-Host "[3/15] Ativando servicos de descoberta de dispositivos..." -ForegroundColor Yellow
$discoveryServices = @(
    @{Name="FDResPub"; Desc="Publicacao de Recursos de Descoberta de Funcionalidades"}
    @{Name="FunctionDiscoveryProviderHost"; Desc="Host do Provedor de Descoberta de Funcionalidades"}
    @{Name="FunctionDiscoveryResourcePublication"; Desc="Publicacao de Recursos de Descoberta de Funcionalidades"}
    @{Name="SSDPSRV"; Desc="Descoberta SSDP"}
    @{Name="upnphost"; Desc="Host de Dispositivo UPnP"}
    @{Name="Spooler"; Desc="Spooler de Impressao"}
)
foreach ($svc in $discoveryServices) {
    try {
        $s = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($s) {
            if ($isWin10OrLater) {
                Set-Service -Name $svc.Name -StartupType Automatic -ErrorAction SilentlyContinue
            } else {
                sc.exe config $svc.Name start=auto | Out-Null
            }
            Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
            Write-Host " - $($svc.Desc) ativado e executando" -ForegroundColor Gray
        }
    } catch { }
}

# ============================================================
# 4. LIMPAR FILA DE IMPRESSAO
# ============================================================
Write-Host "[4/15] Limpando fila de impressao..." -ForegroundColor Yellow
try {
    Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
    Start-Sleep 2
    $spoolPath = "$env:SystemRoot\System32\spool\PRINTERS"
    if (Test-Path $spoolPath) {
        Remove-Item -Path "$spoolPath\*" -Force -ErrorAction SilentlyContinue
        Write-Host " - Fila de impressao limpa" -ForegroundColor Gray
    }
    Start-Service -Name Spooler -ErrorAction SilentlyContinue
} catch { }

# ============================================================
# 5. POLITICAS DE GRUPO
# ============================================================
Write-Host "[5/15] Ajustando politicas de rede..." -ForegroundColor Yellow
$policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections"
if (-not (Test-Path $policyPath)) {
    New-Item -Path $policyPath -Force | Out-Null
}
Set-ItemProperty -Path $policyPath -Name "NC_AllowNetBridge_NLA" -Value 1 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $policyPath -Name "NC_ShowSharedAccessUI" -Value 1 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $policyPath -Name "NC_StdDomainUserSetLocation" -Value 1 -Type DWord -ErrorAction SilentlyContinue

# ============================================================
# 6. MAPEAMENTOS PERSISTENTES NO REGISTRO
# ============================================================
Write-Host "[6/15] Configurando mapeamentos persistentes..." -ForegroundColor Yellow
$netProvidersPath = "HKLM:\SYSTEM\CurrentControlSet\Control\NetworkProvider"
if (Test-Path $netProvidersPath) {
    Set-ItemProperty -Path $netProvidersPath -Name "RestoreConnection" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $netProvidersPath -Name "Order" -Value "LanmanWorkstation" -ErrorAction SilentlyContinue
}

# ============================================================
# 7. PARAMETROS TCP/IP
# ============================================================
Write-Host "[7/15] Ajustando parametros TCP/IP..." -ForegroundColor Yellow
$tcpipPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
if (Test-Path $tcpipPath) {
    Set-ItemProperty -Path $tcpipPath -Name "DisableTaskOffload" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $tcpipPath -Name "EnableSecurityFilters" -Value 0 -Type DWord -ErrorAction SilentlyContinue
}

# ============================================================
# 8. PARAMETROS LANMANWORKSTATION
# ============================================================
Write-Host "[8/15] Ajustando parametros da estacao de trabalho..." -ForegroundColor Yellow
$wkPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
if (Test-Path $wkPath) {
    Set-ItemProperty -Path $wkPath -Name "EnablePlainTextPassword" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $wkPath -Name "EnableSecuritySignature" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $wkPath -Name "RequireSecuritySignature" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $wkPath -Name "ConnectionCount" -Value 3 -Type DWord -ErrorAction SilentlyContinue
}

# ============================================================
# 9. HABILITAR SMB 1.0 (se necessario para impressoras antigas)
# ============================================================
Write-Host "[9/15] Verificando SMB 1.0..." -ForegroundColor Yellow
try {
    $smb1 = Get-Service -Name "mrxsmb10" -ErrorAction SilentlyContinue
    if (-not $smb1) {
        Write-Host " - SMB 1.0 nao instalado (padrao do Windows 10/11)" -ForegroundColor Gray
        Write-Host "   Se tiver impressoras muito antigas, instale com:" -ForegroundColor DarkYellow
        Write-Host "   dism /online /Enable-Feature /FeatureName:SMB1Protocol" -ForegroundColor DarkYellow
    } else {
        Write-Host " - SMB 1.0 instalado" -ForegroundColor Gray
    }
} catch { }

# ============================================================
# 10. REDEFINIR PILHAS DE REDE
# ============================================================
Write-Host "[10/15] Redefinindo pilhas de rede..." -ForegroundColor Yellow
netsh int ip reset reset.log | Out-Null
netsh winsock reset | Out-Null
netsh interface ipv4 reset | Out-Null
if ($isWin8OrLater) {
    netsh interface ipv6 reset | Out-Null
}

# ============================================================
# 11. RENOVAR CONFIGURACOES IP
# ============================================================
Write-Host "[11/15] Renovando configuracoes IP..." -ForegroundColor Yellow
ipconfig /release | Out-Null
ipconfig /renew | Out-Null
ipconfig /flushdns | Out-Null
ipconfig /registerdns | Out-Null

# ============================================================
# 12. FIREWALL - REGRAS PARA IMPRESSORA E DESCOBERTA
# ============================================================
Write-Host "[12/15] Configurando firewall para compartilhamento..." -ForegroundColor Yellow
netsh advfirewall firewall set rule group="Compartilhamento de Arquivo e Impressora" new enable=Yes | Out-Null
netsh advfirewall firewall set rule group="Descoberta de Rede" new enable=Yes | Out-Null
if ($isWin8OrLater) {
    netsh advfirewall firewall set rule group="Compartilhamento de Arquivo com Senha" new enable=Yes | Out-Null
}

# ============================================================
# 13. NETBIOS SOBRE TCP/IP
# ============================================================
Write-Host "[13/15] Ativando NetBIOS sobre TCP/IP..." -ForegroundColor Yellow
try {
    $nics = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True"
    foreach ($nic in $nics) {
        $nic.SetTcpipNetbios(1) | Out-Null
    }
    Write-Host " - NetBIOS ativado em todas as interfaces" -ForegroundColor Gray
} catch {
    Write-Host " - Nao foi possivel configurar NetBIOS" -ForegroundColor DarkYellow
}

# ============================================================
# 14. LIMPAR CACHE DE CREDENCIAIS (corrige falhas de autenticacao)
# ============================================================
Write-Host "[14/15] Limpando cache de credenciais..." -ForegroundColor Yellow
try {
    cmdkey /list | ForEach-Object {
        if ($_ -match "^    Target: (.*)$") {
            $target = $matches[1]
            if ($target -ne "LegacyGeneric:target=DefaultUICredential") {
                cmdkey /delete:$target | Out-Null
            }
        }
    }
    Write-Host " - Cache de credenciais limpo" -ForegroundColor Gray
} catch { }

# ============================================================
# 15. CRIAR SCRIPT DE VERIFICACAO NA INICIALIZACAO
# ============================================================
Write-Host "[15/15] Criando script de verificacao na inicializacao..." -ForegroundColor Yellow
$scriptContent = @'
Start-Sleep 30
$svcs = @("LanmanWorkstation","LanmanServer","FDResPub","FunctionDiscoveryProviderHost","FunctionDiscoveryResourcePublication","Spooler")
foreach ($s in $svcs) {
    try {
        $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
        if ($svc -and $svc.Status -ne "Running") { Start-Service -Name $s }
    } catch {}
}
try {
    $ping = New-Object System.Net.NetworkInformation.Ping
    $ping.Send("127.0.0.1", 1000) | Out-Null
} catch {}
'@

$startupPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
if (-not (Test-Path $startupPath)) {
    $startupPath = [Environment]::GetFolderPath('Startup')
}
$scriptPath = Join-Path $startupPath "NetworkRepair.ps1"
try {
    Set-Content -Path $scriptPath -Value $scriptContent -Force
    Write-Host " - Script de verificacao criado: $scriptPath" -ForegroundColor Gray
} catch {
    Write-Host " - Nao foi possivel criar script de inicializacao" -ForegroundColor DarkYellow
}

# ============================================================
# FINALIZACAO
# ============================================================
Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "   REPARO CONCLUIDO!" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""
Write-Host " Recomenda-se REINICIAR o computador." -ForegroundColor Yellow
Write-Host " Apos reiniciar, teste o acesso aa impressora de rede." -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Deseja reiniciar agora? (S/N)"
if ($choice -eq 'S' -or $choice -eq 's') {
    Write-Host "Reiniciando em 5 segundos..." -ForegroundColor Yellow
    Start-Sleep 5
    Restart-Computer -Force
}
