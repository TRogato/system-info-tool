# Função para tentar obter o serial do Office (última chave instalada)
function Get-OfficeProductKey {
    try {
        $officePaths = @(
            'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration',
            'HKLM:\SOFTWARE\Microsoft\Office\16.0\Registration',
            'HKLM:\SOFTWARE\Microsoft\Office\15.0\Registration',
            'HKLM:\SOFTWARE\Microsoft\Office\14.0\Registration',
            'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\16.0\Registration',
            'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\15.0\Registration',
            'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\14.0\Registration'
        )
        foreach ($path in $officePaths) {
            if (Test-Path $path) {
                $keys = Get-ChildItem $path -ErrorAction SilentlyContinue
                foreach ($key in $keys) {
                    $prod = Get-ItemProperty $key.PSPath -ErrorAction SilentlyContinue
                    if ($prod.ProductID) {
                        return $prod.ProductID
                    }
                }
            }
        }
        $wmi = Get-WmiObject -Query "SELECT * FROM SoftwareLicensingService WHERE ApplicationID IS NOT NULL AND Name LIKE '%Office%'" -ErrorAction SilentlyContinue
        if ($wmi -and $wmi.Count -gt 0) {
            return $wmi[0].PartialProductKey
        }
        return "N/A"
    } catch {
        return "N/A"
    }
}

<#
.SYNOPSIS
    System Information Tool - Ferramenta para coleta de informações do sistema Windows
    
.DESCRIPTION
    Script PowerShell que coleta e exibe informações detalhadas sobre hardware, software,
    rede, armazenamento e segurança do sistema Windows. Inclui exportação para CSV e suporte
    a múltiplas línguas. Ideal para técnicos de TI e administradores de sistema.
    
.PARAMETER NoClear
    Desativa a limpeza da tela para execuções automatizadas.
    
.PARAMETER OutputPath
    Especifica o caminho para salvar o arquivo CSV. Padrão: Desktop.

.EXAMPLE
    .\Get-SystemInfo.ps1
    Executa o script e exibe informações no console com opção de exportar para CSV.
    
.EXAMPLE
    .\Get-SystemInfo.ps1 -NoClear -OutputPath "C:\Relatorios\SystemInfo.csv"
    Executa sem limpar a tela e salva o CSV no caminho especificado.

.NOTES
    Autor: Isaac Oolibama R. Lacerda
    Versão: 1.3
    Data: 06/08/2025
    Requer: Windows 10/11, PowerShell 5.1+
    Permissões: Administrador (obrigatório)
    LinkedIn: https://www.linkedin.com/in/tiago-rogato-da-silveira-095563b6/
    
.LINK
    https://github.com/TRogato/system-info-tool
#>

# =============================================================================
# CONFIGURAÇÕES INICIAIS E FUNÇÕES AUXILIARES
# =============================================================================

# Configuração de codificação para suporte a caracteres especiais
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Verifica permissões administrativas
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ Este script requer permissões administrativas. Execute como administrador." -ForegroundColor Red
    [Environment]::Exit(1)
}

# --- Função para simular loading visual ---
function Show-Loading {
    param([string[]]$Steps)
    foreach ($step in $Steps) {
        Write-Host "$step" -ForegroundColor Yellow
        Start-Sleep -Milliseconds 400
    }
}

# --- Funções de formatação e exibição ---
function Write-Header($t) {
    Write-Host "`n┌────────────────────── $t ──────────────────────┐" -ForegroundColor Magenta
}

function Write-Footer {
    Write-Host "└────────────────────────────────────────────────┘" -ForegroundColor Magenta
}

function Write-Field($k, $v) {
    $fmtKey = "{0,-22}:" -f $k
    Write-Host -NoNewline $fmtKey -ForegroundColor Cyan
    Write-Host " $v"
}

# --- Função para limpar caracteres especiais e normalizar acentos ---
function Clean-SpecialCharacters {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) { return $Text }
    $cleaned = $Text -replace "[\x00-\x1F\x7F-\x9F]", ""
    $cleaned = $cleaned -replace "\xA0", " "
    $cleaned = $cleaned -replace "[\x201C\x201D]", '"'
    $cleaned = $cleaned -replace "[\x2018\x2019]", "'"
    $cleaned = $cleaned -replace "[\x2013\x2014]", "-"
    $normalized = [Text.NormalizationForm]::FormD
    $cleaned = [string]::Join('', ($cleaned.Normalize($normalized).ToCharArray() | Where-Object { [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne 'NonSpacingMark' }))
    $cleaned = $cleaned -replace '[^\x00-\x7F]', ''
    return $cleaned.Trim()
}

# --- Função para mascarar chaves de produto ---
function Mask-ProductKey($key) {
    if ($key -eq "N/A" -or $key.Length -lt 5) { return $key }
    return "*****" + $key.Substring($key.Length - 5)
}

# --- Função para gerar arquivo CSV ---
function Export-SystemInfoToCSV {
    param([hashtable]$SystemData, [string]$OutputPath, [switch]$Utf8)
    try {
        if (-not $OutputPath) {
            $desktopPath = [Environment]::GetFolderPath("Desktop")
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $OutputPath = Join-Path $desktopPath "SystemInfo_$timestamp.csv"
        }
        $csvData = @()
        # Informações do Sistema Operacional
        $csvData += [PSCustomObject]@{
            Categoria = "SISTEMA OPERACIONAL"
            Campo = "NOME"
            Valor = Clean-SpecialCharacters $SystemData.SO
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SISTEMA OPERACIONAL"
            Campo = "VERSAO"
            Valor = Clean-SpecialCharacters $SystemData.VERS
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SISTEMA OPERACIONAL"
            Campo = "ARQUITETURA"
            Valor = Clean-SpecialCharacters $SystemData.ARCH
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SISTEMA OPERACIONAL"
            Campo = "PRODUCT KEY WINDOWS"
            Valor = Clean-SpecialCharacters $SystemData.PKEY
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SISTEMA OPERACIONAL"
            Campo = "PRODUCT KEY OFFICE"
            Valor = Clean-SpecialCharacters $SystemData.OFFICEKEY
        }
        # Informações do Hardware
        $csvData += [PSCustomObject]@{
            Categoria = "HARDWARE"
            Campo = "PROCESSADOR"
            Valor = Clean-SpecialCharacters $SystemData.CPU
        }
        $csvData += [PSCustomObject]@{
            Categoria = "HARDWARE"
            Campo = "MEMORIA RAM"
            Valor = Clean-SpecialCharacters $SystemData.RAM
        }
        $csvData += [PSCustomObject]@{
            Categoria = "HARDWARE"
            Campo = "CONFIGURACAO DE CANAIS"
            Valor = Clean-SpecialCharacters $SystemData.Channel
        }
        $csvData += [PSCustomObject]@{
            Categoria = "HARDWARE"
            Campo = "VELOCIDADE DA MEMORIA"
            Valor = Clean-SpecialCharacters $SystemData.Speeds
        }
        $csvData += [PSCustomObject]@{
            Categoria = "HARDWARE"
            Campo = "PLACA DE VIDEO"
            Valor = Clean-SpecialCharacters $SystemData.GPU
        }
        $csvData += [PSCustomObject]@{
            Categoria = "HARDWARE"
            Campo = "PLACA-MAE"
            Valor = Clean-SpecialCharacters $SystemData.BOARD
        }
        $csvData += [PSCustomObject]@{
            Categoria = "HARDWARE"
            Campo = "BIOS"
            Valor = Clean-SpecialCharacters $SystemData.BIOS
        }
        $csvData += [PSCustomObject]@{
            Categoria = "HARDWARE"
            Campo = "NUMERO DE SERIE"
            Valor = Clean-SpecialCharacters $SystemData.SERIAL
        }
        # Informações de Rede
        if ($SystemData.NET -is [array]) {
            for ($i = 0; $i -lt $SystemData.NET.Count; $i++) {
                $csvData += [PSCustomObject]@{
                    Categoria = "REDE"
                    Campo = "INTERFACE $($i + 1)"
                    Valor = Clean-SpecialCharacters $SystemData.NET[$i]
                }
            }
        } else {
            $csvData += [PSCustomObject]@{
                Categoria = "REDE"
                Campo = "INTERFACES"
                Valor = Clean-SpecialCharacters $SystemData.NET
            }
        }
        # Informações Detalhadas de Rede
        if ($SystemData.NETDETAILS -and $SystemData.NETDETAILS.Count -gt 0) {
            foreach ($nic in $SystemData.NETDETAILS) {
                $csvData += [PSCustomObject]@{
                    Categoria = "REDE"
                    Campo = "INTERFACE $($nic.Nome) - TIPO"
                    Valor = Clean-SpecialCharacters $nic.Tipo
                }
                $csvData += [PSCustomObject]@{
                    Categoria = "REDE"
                    Campo = "INTERFACE $($nic.Nome) - MAC"
                    Valor = Clean-SpecialCharacters $nic.MAC
                }
                $csvData += [PSCustomObject]@{
                    Categoria = "REDE"
                    Campo = "INTERFACE $($nic.Nome) - IPV4"
                    Valor = Clean-SpecialCharacters $nic.IPv4
                }
                $csvData += [PSCustomObject]@{
                    Categoria = "REDE"
                    Campo = "INTERFACE $($nic.Nome) - IPV6"
                    Valor = Clean-SpecialCharacters $nic.IPv6
                }
                $csvData += [PSCustomObject]@{
                    Categoria = "REDE"
                    Campo = "INTERFACE $($nic.Nome) - MASCARA"
                    Valor = Clean-SpecialCharacters $nic.Mascara
                }
                $csvData += [PSCustomObject]@{
                    Categoria = "REDE"
                    Campo = "INTERFACE $($nic.Nome) - GATEWAY"
                    Valor = Clean-SpecialCharacters $nic.Gateway
                }
                $csvData += [PSCustomObject]@{
                    Categoria = "REDE"
                    Campo = "INTERFACE $($nic.Nome) - DNS"
                    Valor = Clean-SpecialCharacters $nic.DNS
                }
                $csvData += [PSCustomObject]@{
                    Categoria = "REDE"
                    Campo = "INTERFACE $($nic.Nome) - STATUS"
                    Valor = Clean-SpecialCharacters $nic.Status
                }
            }
        }
        # Informações de Segurança
        $csvData += [PSCustomObject]@{
            Categoria = "SEGURANCA"
            Campo = "GRUPO/DOMINIO"
            Valor = Clean-SpecialCharacters $SystemData.WorkgroupOrDomain
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SEGURANCA"
            Campo = "ADMINISTRADORES LOCAIS"
            Valor = Clean-SpecialCharacters $SystemData.LocalAdmins
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SEGURANCA"
            Campo = "FIREWALL"
            Valor = Clean-SpecialCharacters $SystemData.FirewallStatus
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SEGURANCA"
            Campo = "ANTIVIRUS"
            Valor = Clean-SpecialCharacters $SystemData.Antivirus
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SEGURANCA"
            Campo = "ATUALIZACOES RECENTES"
            Valor = Clean-SpecialCharacters $SystemData.RecentUpdates
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SEGURANCA"
            Campo = "POLITICA DE SENHA"
            Valor = Clean-SpecialCharacters $SystemData.PasswordPolicy
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SEGURANCA"
            Campo = "COMPARTILHAMENTOS"
            Valor = Clean-SpecialCharacters $SystemData.NetworkShares
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SEGURANCA"
            Campo = "SERVICOS CRITICOS"
            Valor = Clean-SpecialCharacters $SystemData.CriticalServices
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SEGURANCA"
            Campo = "IP PUBLICO"
            Valor = Clean-SpecialCharacters $SystemData.PublicIP
        }
        $csvData += [PSCustomObject]@{
            Categoria = "SEGURANCA"
            Campo = "BITLOCKER"
            Valor = Clean-SpecialCharacters $SystemData.BitLocker
        }
        # Informações de Armazenamento
        for ($i = 0; $i -lt $SystemData.DISKS.Count; $i++) {
            $csvData += [PSCustomObject]@{
                Categoria = "ARMAZENAMENTO"
                Campo = "DISCO $($i + 1)"
                Valor = Clean-SpecialCharacters $SystemData.DISKS[$i]
            }
        }
        # Informações Adicionais
        $csvData += [PSCustomObject]@{
            Categoria = "INFORMACOES ADICIONAIS"
            Campo = "DATA DE COLETA"
            Valor = (Get-Date -Format "dd/MM/yyyy HH:mm:ss")
        }
        $csvData += [PSCustomObject]@{
            Categoria = "INFORMACOES ADICIONAIS"
            Campo = "USUARIO"
            Valor = Clean-SpecialCharacters $env:USERNAME
        }
        $csvData += [PSCustomObject]@{
            Categoria = "INFORMACOES ADICIONAIS"
            Campo = "COMPUTADOR"
            Valor = Clean-SpecialCharacters $env:COMPUTERNAME
        }
        # Gera CSV manualmente
        $csvContent = "CATEGORIA,CAMPO,VALOR`n"
        foreach ($row in $csvData) {
            $categoria = $row.Categoria -replace '"', '""'
            $campo = $row.Campo -replace '"', '""'
            $valor = $row.Valor -replace '"', '""'
            $csvContent += "`"$categoria`",`"$campo`",`"$valor`"`n"
        }
        if ($Utf8) {
            [System.IO.File]::WriteAllText($OutputPath, $csvContent, [System.Text.Encoding]::UTF8)
        } else {
            [System.IO.File]::WriteAllText($OutputPath, $csvContent, [System.Text.Encoding]::Default)
        }
        return @{ Path = $OutputPath; RecordCount = $csvData.Count }
    } catch {
        Write-Host "`n❌ Erro ao gerar arquivo CSV: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Função para obter o serial (Product Key) do Windows
function Get-WindowsProductKey {
    try {
        $key = (Get-WmiObject -Query 'SELECT * FROM SoftwareLicensingService').OA3xOriginalProductKey
        if ([string]::IsNullOrWhiteSpace($key)) {
            return "N/A"
        }
        return $key
    } catch {
        return "N/A"
    }
}

# Função para obter informações de segurança de rede
function Get-SecurityInfo {
    $info = @{}
    # Cache de chamadas WMI/CIM
    $comp = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
    # Grupo de trabalho ou domínio
    try {
        $info.WorkgroupOrDomain = if ($comp.PartOfDomain) { $comp.Domain } else { $comp.Workgroup }
    } catch { $info.WorkgroupOrDomain = 'N/A' }
    # Usuários administradores locais (usando SID para suporte multilíngue)
    try {
        $admins = Get-LocalGroupMember -SID S-1-5-32-544 -ErrorAction Stop | Select-Object -ExpandProperty Name
        $info.LocalAdmins = if ($admins) { $admins -join ', ' } else { 'Nenhum' }
    } catch { $info.LocalAdmins = 'N/A' }
    # Firewall do Windows
    try {
        $fw = Get-NetFirewallProfile -ErrorAction Stop | Where-Object { $_.Enabled -eq $true } | Select-Object -ExpandProperty Name
        $info.FirewallStatus = if ($fw) { $fw -join ', ' } else { 'Desativado' }
    } catch { $info.FirewallStatus = 'N/A' }
    # Antivírus instalado
    try {
        $av = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct -ErrorAction Stop | Select-Object -ExpandProperty displayName
        $info.Antivirus = if ($av) { $av -join ', ' } else { 'Nenhum' }
    } catch { $info.Antivirus = 'N/A' }
    # Atualizações recentes
    try {
        $updates = Get-HotFix | Sort-Object -Property InstalledOn -Descending | Select-Object -First 3 | ForEach-Object { "$($_.Description) $($_.HotFixID) ($($_.InstalledOn))" }
        $info.RecentUpdates = if ($updates) { $updates -join '; ' } else { 'Nenhuma' }
    } catch { $info.RecentUpdates = 'N/A' }
    # Políticas de senha
    try {
        $pol = net accounts | Out-String
        $info.PasswordPolicy = $pol -replace '[\r\n]+', ' | '
    } catch { $info.PasswordPolicy = 'N/A' }
    # Compartilhamentos de rede
    try {
        $shares = Get-SmbShare -ErrorAction Stop | Where-Object { $_.Name -notin @('ADMIN$', 'C$', 'IPC$') } | Select-Object -ExpandProperty Name
        $info.NetworkShares = if ($shares) { $shares -join ', ' } else { 'Nenhum' }
    } catch { $info.NetworkShares = 'N/A' }
    # Serviços de rede críticos
    try {
        $services = @('TermService','LanmanServer','LanmanWorkstation','WinRM')
        $svcStatus = foreach ($svc in $services) {
            $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
            if ($s) { "$($s.Name): $($s.Status)" } else { "$svc: N/A" }
        }
        $info.CriticalServices = $svcStatus -join ', '
    } catch { $info.CriticalServices = 'N/A' }
    # IP público
    try {
        $publicIP = Invoke-RestMethod -Uri 'https://api.ipify.org?format=text' -TimeoutSec 5 -ErrorAction Stop
        $info.PublicIP = $publicIP
    } catch { $info.PublicIP = 'N/A' }
    # BitLocker
    try {
        $bitlocker = Get-BitLockerVolume -ErrorAction Stop | Where-Object { $_.VolumeStatus -eq 'FullyEncrypted' } | Select-Object -ExpandProperty MountPoint
        $info.BitLocker = if ($bitlocker) { $bitlocker -join ', ' } else { 'Desativado' }
    } catch { $info.BitLocker = 'N/A' }
    return $info
}

# =============================================================================
# SEQUÊNCIA DE LOADING VISUAL
# =============================================================================

$loadingSteps = @(
    "Carregando informações do sistema...",
    "Coletando dados de hardware...",
    "Verificando configurações de rede...",
    "Analisando discos..."
)
param(
    [switch]$NoClear,
    [string]$OutputPath
)
Show-Loading $loadingSteps
Start-Sleep -Milliseconds 300
if (-not $NoClear) {
    Clear-Host
    try { $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, 0 } catch {}
    try { [Console]::Clear() } catch {}
}

# =============================================================================
# COLETA DE DADOS DO SISTEMA OPERACIONAL
# =============================================================================

function Get-OSInfo {
    try {
        $o = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        return @{
            SO   = $o.Caption
            VERS = "v$($o.Version) Build $($o.BuildNumber)"
            ARCH = $o.OSArchitecture
        }
    } catch {
        return @{ SO = 'N/A'; VERS = 'N/A'; ARCH = 'N/A' }
    }
}
$osInfo = Get-OSInfo
$SO = $osInfo.SO
$VERS = $osInfo.VERS
$ARCH = $osInfo.ARCH

# =============================================================================
# COLETA DE DADOS DO PROCESSADOR
# =============================================================================

function Get-CPUInfo {
    try {
        $c = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
        $baseGHz = [math]::Round($c.CurrentClockSpeed/1000,1)
        $boostGHz = [math]::Round($c.MaxClockSpeed/1000,1)
        return "$($c.Name.Trim()) | Cores: $($c.NumberOfCores) | Threads: $($c.NumberOfLogicalProcessors) | Base: ${baseGHz}GHz"
    } catch {
        return 'N/A'
    }
}
$CPU = Get-CPUInfo

# =============================================================================
# COLETA DE DADOS DA MEMÓRIA RAM
# =============================================================================

function Get-RAMInfo {
    try {
        $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        $memModules = Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop
        $RAMGB = [math]::Round($cs.TotalPhysicalMemory/1GB,0)
        $RAM = "$RAMGB GB"
        $speedsList = $memModules | Select-Object -ExpandProperty Speed -Unique
        $Speeds = if ($speedsList) { ($speedsList -join ', ') + ' MHz' } else { 'N/A' }
        $Channel = switch ($memModules.Count) {
            1 { 'Single Channel' }
            2 { 'Dual Channel' }
            4 { 'Quad Channel' }
            Default { "$($memModules.Count)-Channel" }
        }
        return @{ RAM = $RAM; Channel = $Channel; Speeds = $Speeds }
    } catch {
        return @{ RAM = 'N/A'; Channel = 'N/A'; Speeds = 'N/A' }
    }
}
$ramInfo = Get-RAMInfo
$RAM = $ramInfo.RAM
$Channel = $ramInfo.Channel
$Speeds = $ramInfo.Speeds

# =============================================================================
# COLETA DE DADOS DA PLACA DE VÍDEO
# =============================================================================

function Get-GPUInfo {
    try {
        $g = Get-CimInstance Win32_VideoController -ErrorAction Stop | Where-Object { $_.AdapterRAM -gt 0 } | Select-Object -First 1
        return "$($g.Name) | $([math]::Round($g.AdapterRAM/1MB)) MB | Driver: $($g.DriverVersion)"
    } catch {
        return 'N/A'
    }
}
$GPU = Get-GPUInfo

# =============================================================================
# COLETA DE DADOS DO SISTEMA E BIOS
# =============================================================================

function Get-BoardBiosInfo {
    try {
        $prod = Get-CimInstance Win32_ComputerSystemProduct -ErrorAction Stop
        $SERIAL = if ($prod.IdentifyingNumber) { $prod.IdentifyingNumber } else { 'N/A' }
        $b = Get-CimInstance Win32_BIOS -ErrorAction Stop
        $BIOS = "$($b.Manufacturer) v$($b.SMBIOSBIOSVersion) ($(Get-Date $b.ReleaseDate -Format 'dd/MM/yyyy'))"
        $mb = Get-CimInstance Win32_BaseBoard -ErrorAction Stop
        $BOARD = "$($mb.Manufacturer) $($mb.Product) S/N: $($mb.SerialNumber)"
        return @{ SERIAL = $SERIAL; BIOS = $BIOS; BOARD = $BOARD }
    } catch {
        return @{ SERIAL = 'N/A'; BIOS = 'N/A'; BOARD = 'N/A' }
    }
}
$boardInfo = Get-BoardBiosInfo
$SERIAL = $boardInfo.SERIAL
$BIOS = $boardInfo.BIOS
$BOARD = $boardInfo.BOARD

# =============================================================================
# COLETA DE DADOS DE REDE (APRIMORADA)
# =============================================================================

function Get-NetworkInfo {
    $NET = @()
    $NETINFO = @()
    $NETDETAILS = @()
    try {
        $allNics = Get-CimInstance Win32_NetworkAdapter -ErrorAction Stop |
            Where-Object { $_.NetEnabled -eq $true } |
            Sort-Object -Property Name
        foreach ($nic in $allNics) {
            $conf = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "Index=$($nic.DeviceID)" -ErrorAction SilentlyContinue
            $mac = if ($nic.MACAddress) { $nic.MACAddress -replace '(.{2})(?!$)', '$1:' } else { 'N/A' }
            $isWifi = ($nic.AdapterType -match "Wireless") -or ($nic.Name -match "Wi.?Fi|802\.11|Wireless")
            $isVirtual = ($nic.Name -match "vEthernet|Hyper-V|Virtual|TAP|OpenVPN|Tailscale")
            $isBluetooth = ($nic.Name -match "Bluetooth")
            $tipoCon = if ($isWifi) { "WiFi" } elseif ($isVirtual) { "Virtual" } elseif ($isBluetooth) { "Bluetooth" } else { "Ethernet" }
            $ipv4 = $conf.IPAddress | Where-Object { $_ -match "\." } | Select-Object -First 1
            $ipv6 = $conf.IPAddress | Where-Object { $_ -match ":" } | Select-Object -First 1
            $mask = $conf.IPSubnet | Where-Object { $_ -match "\." } | Select-Object -First 1
            $gateway = $conf.DefaultIPGateway | Where-Object { $_ -match "\." } | Select-Object -First 1
            $dns = $conf.DNSServerSearchOrder | Where-Object { $_ -match "\." }
            $dnsString = if ($dns) { $dns -join ", " } else { "N/A" }
            $NET += "$($nic.Name) ($($nic.NetConnectionID))"
            $NETINFO += @(
                "  [$tipoCon] $($nic.Name)"
                "    MAC Address        : $mac"
                "    IPv4               : $ipv4"
                "    IPv6               : $ipv6"
                "    Máscara            : $mask"
                "    Gateway            : $gateway"
                "    DNS                : $dnsString"
                ""
            ) -join "`n"
            $NETDETAILS += [PSCustomObject]@{
                Nome = $nic.Name
                Tipo = $tipoCon
                MAC = $mac
                IPv4 = $ipv4
                IPv6 = $ipv6
                Mascara = $mask
                Gateway = $gateway
                DNS = $dnsString
                Status = if ($nic.NetEnabled) { "Ativo" } else { "Inativo" }
            }
        }
        if ($NET.Count -eq 0) {
            $NET = "N/A"
            $NETINFO = "N/A"
            $NETDETAILS = @()
        }
    } catch {
        $NET = "N/A"
        $NETINFO = "N/A"
        $NETDETAILS = @()
    }
    return @{ NET = $NET; NETINFO = $NETINFO; NETDETAILS = $NETDETAILS }
}
$netInfo = Get-NetworkInfo
$NET = $netInfo.NET
$NETINFO = $netInfo.NETINFO
$NETDETAILS = $netInfo.NETDETAILS

# =============================================================================
# COLETA DE DADOS DE ARMAZENAMENTO
# =============================================================================

function Get-DisksInfo {
    try {
        return Get-CimInstance Win32_DiskDrive -ErrorAction Stop |
            ForEach-Object { "{0}: {1:N1} GB ({2})" -f $_.Model, ($_.Size/1GB), $_.InterfaceType }
    } catch {
        return @("N/A")
    }
}
$DISKS = Get-DisksInfo

# =============================================================================
# COLETA DE INFORMAÇÕES DE SEGURANÇA
# =============================================================================

$securityInfo = Get-SecurityInfo
$winKey = Get-WindowsProductKey
$officeKey = Get-OfficeProductKey

# =============================================================================
# EXIBIÇÃO ESTILIZADA DOS RESULTADOS
# =============================================================================

Write-Header "Resumo do Sistema"
Write-Field "Sistema Operacional" $SO
Write-Field "Versão" $VERS
Write-Field "Arquitetura" $ARCH
Write-Field "Product Key Windows" (Mask-ProductKey $winKey)
Write-Field "Product Key Office" (Mask-ProductKey $officeKey)
Write-Footer

Write-Header "Segurança de Rede"
Write-Field "Grupo/Domínio" $securityInfo.WorkgroupOrDomain
Write-Field "Admins Locais" $securityInfo.LocalAdmins
Write-Field "Firewall" $securityInfo.FirewallStatus
Write-Field "Antivírus" $securityInfo.Antivirus
Write-Field "Atualizações Recentes" $securityInfo.RecentUpdates
Write-Field "Política de Senha" $securityInfo.PasswordPolicy
Write-Field "Compartilhamentos" $securityInfo.NetworkShares
Write-Field "Serviços Críticos" $securityInfo.CriticalServices
Write-Field "IP Público" $securityInfo.PublicIP
Write-Field "BitLocker" $securityInfo.BitLocker
Write-Footer

Write-Header "Hardware"
Write-Field "Processador" $CPU
Write-Field "Memória" "$RAM - $Channel - $Speeds"
Write-Field "GPU" $GPU
Write-Field "Placa-Mãe" $BOARD
Write-Field "BIOS" $BIOS
Write-Field "Número de Série" $SERIAL
Write-Footer

Write-Header "Rede"
if ($NET -is [array]) {
    Write-Host "Interfaces de Rede Ativas:" -ForegroundColor Cyan
    Write-Host $NETINFO
} else {
    Write-Field "Rede" $NET
    Write-Host $NETINFO
}
Write-Footer

Write-Header "Discos"
foreach ($d in $DISKS) {
    Write-Host "  $d" -ForegroundColor White
}
Write-Footer

# =============================================================================
# OPÇÃO DE EXPORTAÇÃO PARA CSV
# =============================================================================

Write-Header "Opções Adicionais"
Write-Host "1 - Gerar arquivo CSV com todas as informações"
Write-Host "2 - Sair"
Write-Host "`nEscolha uma opção (1 ou 2): " -NoNewline -ForegroundColor Yellow
$choice = Read-Host

while ($choice -ne "1" -and $choice -ne "2") {
    Write-Host "`nOpção inválida! Digite 1 ou 2." -ForegroundColor Red
    Start-Sleep -Seconds 1
    if (-not $NoClear) { Clear-Host }
    Write-Header "Opções Adicionais"
    Write-Host "1 - Gerar arquivo CSV com todas as informações"
    Write-Host "2 - Sair"
    Write-Host "`nEscolha uma opção (1 ou 2): " -NoNewline -ForegroundColor Yellow
    $choice = Read-Host
}

if ($choice -eq "1") {
    # Cria hashtable com todos os dados coletados
    $systemData = @{
        SO = $SO
        VERS = $VERS
        ARCH = $ARCH
        CPU = $CPU
        RAM = $RAM
        Channel = $Channel
        Speeds = $Speeds
        GPU = $GPU
        BOARD = $BOARD
        BIOS = $BIOS
        SERIAL = $SERIAL
        NET = $NET
        NETINFO = $NETINFO
        NETDETAILS = $NETDETAILS
        DISKS = $DISKS
        PKEY = $winKey
        OFFICEKEY = $officeKey
        WorkgroupOrDomain = $securityInfo.WorkgroupOrDomain
        LocalAdmins = $securityInfo.LocalAdmins
        FirewallStatus = $securityInfo.FirewallStatus
        Antivirus = $securityInfo.Antivirus
        RecentUpdates = $securityInfo.RecentUpdates
        PasswordPolicy = $securityInfo.PasswordPolicy
        NetworkShares = $securityInfo.NetworkShares
        CriticalServices = $securityInfo.CriticalServices
        PublicIP = $securityInfo.PublicIP
        BitLocker = $securityInfo.BitLocker
    }
    # Gera o arquivo CSV
    $csvResult = Export-SystemInfoToCSV -SystemData $systemData -OutputPath $OutputPath -Utf8
    if ($csvResult) {
        Write-Header "Arquivo Gerado com Sucesso"
        Write-Host "Localização: $($csvResult.Path)" -ForegroundColor Cyan
        Write-Host "Total de informações coletadas: $($csvResult.RecordCount) registros" -ForegroundColor Magenta
        Write-Host "Você pode abrir o arquivo no Excel ou em qualquer editor de planilhas." -ForegroundColor Yellow
        Write-Footer
        Write-Host "`nObrigado por usar o System Information Tool!" -ForegroundColor Cyan
        Write-Host "GitHub: https://github.com/TRogato/system-info-tool" -ForegroundColor Yellow
        Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        [Environment]::Exit(0)
    }
} elseif ($choice -eq "2") {
    [Environment]::Exit(0)
}