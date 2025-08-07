<#
.SYNOPSIS
    System Information Tool - Ferramenta para coleta de informacoes do sistema Windows
    
.DESCRIPTION
    Script PowerShell que coleta e exibe informacoes detalhadas sobre hardware, software,
    rede e armazenamento do sistema Windows. Ideal para tecnicos de TI e administradores
    de sistema que precisam de relatorios rapidos e organizados.
    
.PARAMETER None
    Este script nao aceita parametros.
    
.EXAMPLE
    .\Get-SystemInfo.ps1
    Executa o script e exibe todas as informacoes do sistema.
    
.NOTES
    Autor: Isaac Oolibama R. Lacerda
    Versao: 2.0
    Data: $(Get-Date -Format 'dd/MM/yyyy')
    Requer: Windows 10/11, PowerShell 5.1+
    Permissoes: Administrador (recomendado)
    LinkedIn: https://www.linkedin.com/in/tiago-rogato-da-silveira-095563b6/
    
.LINK
    https://github.com/TRogato/system-info-tool
#>

# =============================================================================
# CONFIGURACOES INICIAIS E FUNCOES AUXILIARES
# =============================================================================

# Configuracao de codificacao para suporte a caracteres especiais
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Funcao para simular loading visual ---
function Show-Loading {
    param([string[]]$Steps)
    
    foreach ($step in $Steps) {
        Write-Host $step -ForegroundColor Yellow
        Start-Sleep -Milliseconds 600
    }
}

# --- Funcoes de formatacao e exibicao ---
function Write-Header($t) {
    Write-Host "`n===== $t =====`n" -ForegroundColor Magenta
}

function Write-Field($k, $v) {
    $fmtKey = "{0,-25}:" -f $k
    Write-Host -NoNewline $fmtKey -ForegroundColor Cyan
    Write-Host " $v"
}

# --- Funcao para limpar caracteres especiais e normalizar acentos ---
function Clean-SpecialCharacters {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) { return $Text }
    # Remove caracteres de controle problematicos
    $cleaned = $Text -replace "[\u0000-\u001F\u007F-\u009F]", ""
    $cleaned = $cleaned -replace "[\u2028\u2029]", " "
    $cleaned = $cleaned -replace "[\u00A0]", " "
    # Substitui aspas e travessões
    $cleaned = $cleaned -replace "[\u201C\u201D]", '"'
    $cleaned = $cleaned -replace "[\u2018\u2019]", "'"
    $cleaned = $cleaned -replace "[\u2013\u2014]", "-"
    # Normaliza acentos usando .NET
    $normalized = [Text.NormalizationForm]::FormD
    $cleaned = [string]::Join('', ($cleaned.Normalize($normalized).ToCharArray() | Where-Object { [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne 'NonSpacingMark' }))
    # Remove outros caracteres especiais
    $cleaned = $cleaned -replace '[^\x00-\x7F]', ''
    # Converte para maiusculo
    $cleaned = $cleaned.ToUpper()
    return $cleaned.Trim()
}

# --- Funcao para gerar arquivo CSV ---
function Export-SystemInfoToCSV {
    param([hashtable]$SystemData, [switch]$Utf8)
    try {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $csvPath = Join-Path $desktopPath "SystemInfo_$timestamp.csv"
        $csvData = @()
        
        # SISTEMA OPERACIONAL
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "NOME"; Valor = Clean-SpecialCharacters $SystemData.SO }
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "VERSAO"; Valor = Clean-SpecialCharacters $SystemData.VERS }
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "ARQUITETURA"; Valor = Clean-SpecialCharacters $SystemData.ARCH }
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "PRODUCT KEY"; Valor = Clean-SpecialCharacters $SystemData.PKEY }
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "DIRETORIO WINDOWS"; Valor = Clean-SpecialCharacters $SystemData.WINDIR }
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "TEMPO DE ATIVIDADE"; Valor = Clean-SpecialCharacters $SystemData.UPTIME }
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "ULTIMO BOOT"; Valor = Clean-SpecialCharacters $SystemData.LASTBOOT }
        
        # HARDWARE
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "FABRICANTE"; Valor = Clean-SpecialCharacters $SystemData.MANUFACTURER }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "MODELO"; Valor = Clean-SpecialCharacters $SystemData.MODEL }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "PROCESSADOR"; Valor = Clean-SpecialCharacters $SystemData.CPU }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "NUCLEOS FISICOS"; Valor = Clean-SpecialCharacters $SystemData.CORES }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "THREADS"; Valor = Clean-SpecialCharacters $SystemData.THREADS }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "MEMORIA RAM TOTAL"; Valor = Clean-SpecialCharacters $SystemData.RAM }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "CONFIGURACAO DE CANAIS"; Valor = Clean-SpecialCharacters $SystemData.Channel }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "VELOCIDADE DA MEMORIA"; Valor = Clean-SpecialCharacters $SystemData.Speeds }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "PLACA DE VIDEO"; Valor = Clean-SpecialCharacters $SystemData.GPU }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "PLACA-MAE"; Valor = Clean-SpecialCharacters $SystemData.BOARD }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "BIOS"; Valor = Clean-SpecialCharacters $SystemData.BIOS }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "NUMERO DE SERIE"; Valor = Clean-SpecialCharacters $SystemData.SERIAL }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "TIPO DE SISTEMA"; Valor = Clean-SpecialCharacters $SystemData.SYSTEMTYPE }
        
        # MEMORIA RAM DETALHADA
        foreach ($ramModule in $SystemData.RAMMODULES) {
            $csvData += [PSCustomObject]@{ 
                Categoria = "MEMORIA RAM DETALHADA"
                Campo = "MODULO $($ramModule.BankLabel)"
                Valor = Clean-SpecialCharacters "$($ramModule.Capacity/1GB) GB | $($ramModule.Speed) MHz | $($ramModule.Manufacturer) | $($ramModule.PartNumber)"
            }
        }
        
        # BATERIA (PARA NOTEBOOKS)
        if ($SystemData.BATTERY) {
            $csvData += [PSCustomObject]@{ Categoria = "BATERIA"; Campo = "FABRICANTE"; Valor = Clean-SpecialCharacters $SystemData.BATTERY.Manufacturer }
            $csvData += [PSCustomObject]@{ Categoria = "BATERIA"; Campo = "QUIMICA"; Valor = Clean-SpecialCharacters $SystemData.BATTERY.Chemistry }
            $csvData += [PSCustomObject]@{ Categoria = "BATERIA"; Campo = "CAPACIDADE"; Valor = Clean-SpecialCharacters "$($SystemData.BATTERY.DesignCapacity) mWh" }
            $csvData += [PSCustomObject]@{ Categoria = "BATERIA"; Campo = "CARGA ATUAL"; Valor = Clean-SpecialCharacters "$($SystemData.BATTERY.EstimatedChargeRemaining)%" }
            $csvData += [PSCustomObject]@{ Categoria = "BATERIA"; Campo = "STATUS"; Valor = Clean-SpecialCharacters $SystemData.BATTERY.Status }
        }
        
        # MONITOR
        foreach ($monitor in $SystemData.MONITORS) {
            $csvData += [PSCustomObject]@{ 
                Categoria = "MONITOR"
                Campo = "$($monitor.Name)"
                Valor = Clean-SpecialCharacters "$($monitor.ScreenWidth)x$($monitor.ScreenHeight) @ $($monitor.ScreenRefreshRate)Hz | $($monitor.Manufacturer)"
            }
        }
        
        # REDE
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
        
        if ($SystemData.NETDETAILS -and $SystemData.NETDETAILS.Count -gt 0) {
            foreach ($nic in $SystemData.NETDETAILS) {
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - TIPO"; Valor = Clean-SpecialCharacters $nic.Tipo }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - MAC"; Valor = Clean-SpecialCharacters $nic.MAC }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - IPV4"; Valor = Clean-SpecialCharacters $nic.IPv4 }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - IPV6"; Valor = Clean-SpecialCharacters $nic.IPv6 }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - MASCARA"; Valor = Clean-SpecialCharacters $nic.Mascara }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - GATEWAY"; Valor = Clean-SpecialCharacters $nic.Gateway }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - DNS"; Valor = Clean-SpecialCharacters $nic.DNS }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - STATUS"; Valor = Clean-SpecialCharacters $nic.Status }
            }
        }
        
        $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "CONEXOES ATIVAS"; Valor = Clean-SpecialCharacters $SystemData.NETCONNECTIONS }
        $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "STATUS FIREWALL"; Valor = Clean-SpecialCharacters $SystemData.FIREWALL }
        
        # ARMAZENAMENTO
        for ($i = 0; $i -lt $SystemData.DISKS.Count; $i++) {
            $csvData += [PSCustomObject]@{
                Categoria = "ARMAZENAMENTO"
                Campo = "DISCO $($i + 1)"
                Valor = Clean-SpecialCharacters $SystemData.DISKS[$i]
            }
        }
        
        foreach ($partition in $SystemData.PARTITIONS) {
            $csvData += [PSCustomObject]@{
                Categoria = "PARTICOES"
                Campo = "$($partition.DeviceID)"
                Valor = Clean-SpecialCharacters "$($partition.Size/1GB) GB | $($partition.FileSystem) | $($partition.FreeSpace/1GB) GB livre"
            }
        }
        
        # SOFTWARE
        $csvData += [PSCustomObject]@{ Categoria = "SOFTWARE"; Campo = "APLICATIVOS INSTALADOS"; Valor = Clean-SpecialCharacters $SystemData.APPS.Count }
        $csvData += [PSCustomObject]@{ Categoria = "SOFTWARE"; Campo = "ATUALIZACOES INSTALADAS"; Valor = Clean-SpecialCharacters $SystemData.UPDATES.Count }
        $csvData += [PSCustomObject]@{ Categoria = "SOFTWARE"; Campo = "SERVICOS EM EXECUCAO"; Valor = Clean-SpecialCharacters $SystemData.SERVICES.Count }
        
        # Informações adicionais
        $csvData += [PSCustomObject]@{ Categoria = "INFORMACOES ADICIONAIS"; Campo = "DATA DE COLETA"; Valor = (Get-Date -Format "dd/MM/yyyy HH:mm:ss").ToUpper() }
        $csvData += [PSCustomObject]@{ Categoria = "INFORMACOES ADICIONAIS"; Campo = "USUARIO"; Valor = Clean-SpecialCharacters $env:USERNAME }
        $csvData += [PSCustomObject]@{ Categoria = "INFORMACOES ADICIONAIS"; Campo = "COMPUTADOR"; Valor = Clean-SpecialCharacters $env:COMPUTERNAME }
        $csvData += [PSCustomObject]@{ Categoria = "INFORMACOES ADICIONAIS"; Campo = "DOMINIO"; Valor = Clean-SpecialCharacters $env:USERDOMAIN }
        
        # Gera CSV manualmente para melhor controle de codificacao
        $csvContent = "CATEGORIA,CAMPO,VALOR`n"
        foreach ($row in $csvData) {
            $categoria = $row.Categoria -replace '"', '""'
            $campo = $row.Campo -replace '"', '""'
            $valor = $row.Valor -replace '"', '""'
            $csvContent += "`"$categoria`"`,`"$campo`"`,`"$valor`"`n"
        }
        
        if ($Utf8) {
            [System.IO.File]::WriteAllText($csvPath, $csvContent, [System.Text.Encoding]::UTF8)
        } else {
            [System.IO.File]::WriteAllText($csvPath, $csvContent, [System.Text.Encoding]::Default)
        }
        
        return @{ Path = $csvPath; RecordCount = $csvData.Count }
    } catch {
        Write-Host "`n❌ Erro ao gerar arquivo CSV: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Função para obter o serial (Product Key) do Windows
function Get-WindowsProductKey {
    try {
        $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
        if ([string]::IsNullOrWhiteSpace($key)) {
            return "N/A"
        }
        return $key
    } catch {
        return "N/A"
    }
}

# Função para obter tempo de atividade do sistema
function Get-SystemUptime {
    try {
        $lastBoot = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
        $uptime = (Get-Date) - $lastBoot
        return @{
            Uptime = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
            LastBoot = $lastBoot.ToString("dd/MM/yyyy HH:mm:ss")
        }
    } catch {
        return @{ Uptime = "N/A"; LastBoot = "N/A" }
    }
}

# Função para obter informações detalhadas da RAM
function Get-DetailedRAMInfo {
    try {
        $modules = Get-CimInstance Win32_PhysicalMemory | ForEach-Object {
            [PSCustomObject]@{
                BankLabel = $_.BankLabel
                Capacity = $_.Capacity
                Speed = $_.Speed
                Manufacturer = $_.Manufacturer
                PartNumber = $_.PartNumber
                SerialNumber = $_.SerialNumber
            }
        }
        return $modules
    } catch {
        return @()
    }
}

# Função para obter informações da bateria
function Get-BatteryInfo {
    try {
        $battery = Get-CimInstance Win32_Battery | Select-Object -First 1
        if ($battery) {
            return [PSCustomObject]@{
                Manufacturer = $battery.Manufacturer
                Chemistry = $battery.Chemistry
                DesignCapacity = $battery.DesignCapacity
                EstimatedChargeRemaining = $battery.EstimatedChargeRemaining
                Status = $battery.Status
            }
        }
        return $null
    } catch {
        return $null
    }
}

# Função para obter informações do monitor
function Get-MonitorInfo {
    try {
        $monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.InstanceName.Split('\')[2]
                ScreenWidth = $_.MaxHorizontalImageSize
                ScreenHeight = $_.MaxVerticalImageSize
                ScreenRefreshRate = $_.VideoOutputTechnology
                Manufacturer = $_.ManufacturerName
            }
        }
        return $monitors
    } catch {
        return @()
    }
}

# Função para obter conexões de rede ativas
function Get-NetworkConnections {
    try {
        $connections = Get-NetTCPConnection -State Established | 
            Where-Object { $_.RemoteAddress -ne '0.0.0.0' } |
            Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess |
            ForEach-Object {
                $process = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
                "$($_.LocalAddress):$($_.LocalPort) -> $($_.RemoteAddress):$($_.RemotePort) ($($process.Name))"
            }
        return $connections -join "`n"
    } catch {
        return "N/A"
    }
}

# Função para obter status do firewall
function Get-FirewallStatus {
    try {
        $fw = Get-NetFirewallProfile | Where-Object { $_.Enabled -eq $true }
        if ($fw) {
            return "ATIVO (" + ($fw.Name -join ", ") + ")"
        }
        return "INATIVO"
    } catch {
        return "N/A"
    }
}

# Função para obter aplicativos instalados
function Get-InstalledApps {
    try {
        $apps = @()
        # Aplicativos de 32 bits
        $apps += Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
            Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
            Where-Object { $_.DisplayName }
        # Aplicativos de 64 bits
        $apps += Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
            Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
            Where-Object { $_.DisplayName }
        return $apps | Sort-Object DisplayName
    } catch {
        return @()
    }
}

# Função para obter atualizações instaladas
function Get-InstalledUpdates {
    try {
        $updates = Get-HotFix | 
            Select-Object HotFixID, Description, InstalledOn, InstalledBy |
            Sort-Object InstalledOn -Descending
        return $updates
    } catch {
        return @()
    }
}

# Função para obter serviços em execução
function Get-RunningServices {
    try {
        $services = Get-Service | 
            Where-Object { $_.Status -eq 'Running' } |
            Select-Object DisplayName, Name, Status, StartType |
            Sort-Object DisplayName
        return $services
    } catch {
        return @()
    }
}

# Função para obter informações de partições
function Get-DiskPartitions {
    try {
        $partitions = Get-CimInstance Win32_LogicalDisk | 
            Where-Object { $_.DriveType -eq 3 } |
            Select-Object DeviceID, FileSystem, Size, FreeSpace
        return $partitions
    } catch {
        return @()
    }
}

# =============================================================================
# SEQUENCIA DE LOADING VISUAL (opcional)
# =============================================================================

$loadingSteps = @(
    "Carregando informacoes do sistema..."
    "Carregando hardware..."
    "Carregando informacoes de memoria..."
    "Carregando informacoes de rede..."
    "Carregando discos e particoes..."
    "Carregando informacoes de software..."
)
# Permite desabilitar a limpeza de tela para execuções automatizadas
param(
    [switch]$NoClear
)
Show-Loading $loadingSteps
Start-Sleep -Milliseconds 500
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
        $uptimeInfo = Get-SystemUptime
        return @{
            SO       = $o.Caption
            VERS     = "v$($o.Version) Build $($o.BuildNumber)"
            ARCH     = $o.OSArchitecture
            WINDIR   = $o.WindowsDirectory
            UPTIME   = $uptimeInfo.Uptime
            LASTBOOT = $uptimeInfo.LastBoot
        }
    } catch {
        return @{ SO = 'N/A'; VERS = 'N/A'; ARCH = 'N/A'; WINDIR = 'N/A'; UPTIME = 'N/A'; LASTBOOT = 'N/A' }
    }
}
$osInfo = Get-OSInfo
$SO = $osInfo.SO
$VERS = $osInfo.VERS
$ARCH = $osInfo.ARCH
$WINDIR = $osInfo.WINDIR
$UPTIME = $osInfo.UPTIME
$LASTBOOT = $osInfo.LASTBOOT

# =============================================================================
# COLETA DE DADOS DO COMPUTADOR
# =============================================================================

function Get-ComputerInfo {
    try {
        $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        return @{
            MANUFACTURER = $cs.Manufacturer
            MODEL        = $cs.Model
            SYSTEMTYPE   = $cs.SystemType
        }
    } catch {
        return @{ MANUFACTURER = 'N/A'; MODEL = 'N/A'; SYSTEMTYPE = 'N/A' }
    }
}
$computerInfo = Get-ComputerInfo
$MANUFACTURER = $computerInfo.MANUFACTURER
$MODEL = $computerInfo.MODEL
$SYSTEMTYPE = $computerInfo.SYSTEMTYPE

# =============================================================================
# COLETA DE DADOS DO PROCESSADOR
# =============================================================================

function Get-CPUInfo {
    try {
        $c = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
        $baseGHz = [math]::Round($c.CurrentClockSpeed/1000,1)
        $boostGHz = [math]::Round($c.MaxClockSpeed/1000,1)
        return @{
            CPU     = "$($c.Name.Trim()) | Cores: $($c.NumberOfCores) | Threads: $($c.NumberOfLogicalProcessors) | Base: ${baseGHz}GHz"
            CORES   = $c.NumberOfCores
            THREADS = $c.NumberOfLogicalProcessors
        }
    } catch {
        return @{ CPU = 'N/A'; CORES = 'N/A'; THREADS = 'N/A' }
    }
}
$cpuInfo = Get-CPUInfo
$CPU = $cpuInfo.CPU
$CORES = $cpuInfo.CORES
$THREADS = $cpuInfo.THREADS

# =============================================================================
# COLETA DE DADOS DA MEMORIA RAM
# =============================================================================

function Get-RAMInfo {
    try {
        $memModules = Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop
        $RAMGB = [math]::Round((Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).TotalPhysicalMemory/1GB,0)
        $RAM = "$RAMGB GB"
        $speedsList = $memModules | Select-Object -ExpandProperty Speed -Unique
        $Speeds = if ($speedsList) { ($speedsList -join ', ') + ' MHz' } else { 'N/A' }
        $Channel = switch ($memModules.Count) {
            1 { 'Single Channel' }
            2 { 'Dual Channel' }
            4 { 'Quad Channel' }
            Default { "$($memModules.Count)-Channel" }
        }
        return @{ RAM = $RAM; Channel = $Channel; Speeds = $Speeds; RAMMODULES = (Get-DetailedRAMInfo) }
    } catch {
        return @{ RAM = 'N/A'; Channel = 'N/A'; Speeds = 'N/A'; RAMMODULES = @() }
    }
}
$ramInfo = Get-RAMInfo
$RAM = $ramInfo.RAM
$Channel = $ramInfo.Channel
$Speeds = $ramInfo.Speeds
$RAMMODULES = $ramInfo.RAMMODULES

# =============================================================================
# COLETA DE DADOS DA PLACA DE VIDEO
# =============================================================================

function Get-GPUInfo {
    try {
        $gpus = Get-CimInstance Win32_VideoController -ErrorAction Stop | ForEach-Object {
            "$($_.Name) | $([math]::Round($_.AdapterRAM/1MB)) MB | Driver: $($_.DriverVersion)"
        }
        return $gpus -join "`n"
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
            $mac = $nic.MACAddress
            if ($mac) { $mac = $mac -replace "(.{2})(?!$)", '${1}:' } else { $mac = 'N/A' }
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
                "    Mascara            : $mask"
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
    return @{ 
        NET = $NET 
        NETINFO = $NETINFO 
        NETDETAILS = $NETDETAILS 
        NETCONNECTIONS = (Get-NetworkConnections)
        FIREWALL = (Get-FirewallStatus)
    }
}
$netInfo = Get-NetworkInfo
$NET = $netInfo.NET
$NETINFO = $netInfo.NETINFO
$NETDETAILS = $netInfo.NETDETAILS
$NETCONNECTIONS = $netInfo.NETCONNECTIONS
$FIREWALL = $netInfo.FIREWALL

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
$PARTITIONS = Get-DiskPartitions

# =============================================================================
# COLETA DE DADOS DE BATERIA (PARA NOTEBOOKS)
# =============================================================================

$BATTERY = Get-BatteryInfo

# =============================================================================
# COLETA DE DADOS DE MONITOR
# =============================================================================

$MONITORS = Get-MonitorInfo

# =============================================================================
# COLETA DE DADOS DE SOFTWARE
# =============================================================================

$APPS = Get-InstalledApps
$UPDATES = Get-InstalledUpdates
$SERVICES = Get-RunningServices

# =============================================================================
# EXIBICAO ESTILIZADA DOS RESULTADOS
# =============================================================================

# Exibe todas as informações coletadas na tela
Write-Header "Resumo do Sistema"
Write-Field "Sistema Operacional" $SO
Write-Field "Versao"             $VERS
Write-Field "Arquitetura"        $ARCH
Write-Field "Diretorio Windows"  $WINDIR
Write-Field "Tempo de Atividade" $UPTIME
Write-Field "Ultimo Boot"        $LASTBOOT
Write-Field "Product Key"        (Get-WindowsProductKey)

Write-Header "Hardware"
Write-Field "Fabricante"         $MANUFACTURER
Write-Field "Modelo"             $MODEL
Write-Field "Tipo de Sistema"    $SYSTEMTYPE
Write-Field "Processador"        $CPU
Write-Field "Nucleos Fisicos"    $CORES
Write-Field "Threads"           $THREADS
Write-Field "Memoria"            "$RAM - $Channel - $Speeds"
Write-Field "GPU"                $GPU
Write-Field "Placa-Mae"          $BOARD
Write-Field "BIOS"               $BIOS
Write-Field "Numero de Serie"    $SERIAL

if ($BATTERY) {
    Write-Header "Bateria"
    Write-Field "Fabricante"      $BATTERY.Manufacturer
    Write-Field "Quimica"         $BATTERY.Chemistry
    Write-Field "Capacidade"      "$($BATTERY.DesignCapacity) mWh"
    Write-Field "Carga Atual"     "$($BATTERY.EstimatedChargeRemaining)%"
    Write-Field "Status"          $BATTERY.Status
}

if ($MONITORS -and $MONITORS.Count -gt 0) {
    Write-Header "Monitor(es)"
    foreach ($monitor in $MONITORS) {
        Write-Field "$($monitor.Name)" "$($monitor.ScreenWidth)x$($monitor.ScreenHeight) @ $($monitor.ScreenRefreshRate)Hz | $($monitor.Manufacturer)"
    }
}

Write-Header "Rede"
Write-Field "Status Firewall"    $FIREWALL
if ($NET -is [array]) {
    Write-Host "Interfaces de Rede Ativas:" -ForegroundColor Cyan
    Write-Host $NETINFO
} else {
    Write-Field "Rede" $NET
    Write-Host $NETINFO
}

if ($NETCONNECTIONS -ne "N/A") {
    Write-Header "Conexoes Ativas"
    Write-Host $NETCONNECTIONS
}

Write-Header "Discos"
foreach ($d in $DISKS) {
    Write-Host "  $d"
}

if ($PARTITIONS -and $PARTITIONS.Count -gt 0) {
    Write-Header "Particoes"
    foreach ($partition in $PARTITIONS) {
        Write-Host "  $($partition.DeviceID): $([math]::Round($partition.Size/1GB)) GB ($($partition.FileSystem)) - $([math]::Round($partition.FreeSpace/1GB)) GB livre"
    }
}

Write-Header "Software"
Write-Field "Aplicativos Instalados" "$($APPS.Count)"
Write-Field "Atualizacoes Instaladas" "$($UPDATES.Count)"
Write-Field "Servicos em Execucao" "$($SERVICES.Count)"

# =============================================================================
# OPCAO DE EXPORTACAO PARA CSV
# =============================================================================

Write-Host "`n" -NoNewline
Write-Host "==============================================" -ForegroundColor Magenta
Write-Host "              OPCOES ADICIONAIS              " -ForegroundColor Magenta
Write-Host "==============================================" -ForegroundColor Magenta

do {
    Write-Host "`n1 - Gerar arquivo CSV com todas as informacoes"
    Write-Host "2 - Sair"
    Write-Host "`nEscolha uma opcao (1 ou 2): " -NoNewline -ForegroundColor Yellow
    
    $choice = Read-Host
    
    if ($choice -eq "1") {
        break
    } elseif ($choice -eq "2") {
        break
    } else {
        Write-Host "`nOpcao invalida! Digite 1 ou 2." -ForegroundColor Red
        Start-Sleep -Seconds 1
        Clear-Host
        Write-Host "==============================================" -ForegroundColor Magenta
        Write-Host "              OPCOES ADICIONAIS              " -ForegroundColor Magenta
        Write-Host "==============================================" -ForegroundColor Magenta
    }
} while ($true)

if ($choice -eq "1") {
    # Cria hashtable com todos os dados coletados
    $systemData = @{
        SO = $SO
        VERS = $VERS
        ARCH = $ARCH
        WINDIR = $WINDIR
        UPTIME = $UPTIME
        LASTBOOT = $LASTBOOT
        MANUFACTURER = $MANUFACTURER
        MODEL = $MODEL
        SYSTEMTYPE = $SYSTEMTYPE
        CPU = $CPU
        CORES = $CORES
        THREADS = $THREADS
        RAM = $RAM
        Channel = $Channel
        Speeds = $Speeds
        RAMMODULES = $RAMMODULES
        GPU = $GPU
        BOARD = $BOARD
        BIOS = $BIOS
        SERIAL = $SERIAL
        BATTERY = $BATTERY
        MONITORS = $MONITORS
        NET = $NET
        NETINFO = $NETINFO
        NETDETAILS = $NETDETAILS
        NETCONNECTIONS = $NETCONNECTIONS
        FIREWALL = $FIREWALL
        DISKS = $DISKS
        PARTITIONS = $PARTITIONS
        PKEY = (Get-WindowsProductKey)
        APPS = $APPS
        UPDATES = $UPDATES
        SERVICES = $SERVICES
    }
    
    # Gera o arquivo CSV
    $csvResult = Export-SystemInfoToCSV -SystemData $systemData
    if ($csvResult) {
        Write-Host "`n" -NoNewline
        Write-Host "===============================================" -ForegroundColor Green
        Write-Host "        ARQUIVO GERADO COM SUCESSO!        " -ForegroundColor Green
        Write-Host "===============================================" -ForegroundColor Green
        Write-Host "`nLocalizacao: $($csvResult.Path)" -ForegroundColor Cyan
        Write-Host "Voce pode abrir o arquivo no Excel ou em qualquer editor de planilhas." -ForegroundColor Yellow
        Write-Host "Total de informacoes coletadas: $($csvResult.RecordCount) registros" -ForegroundColor Magenta
        Write-Host "`n" -NoNewline
        Write-Host "==================================================" -ForegroundColor Gray
        Write-Host "`nObrigado por usar o System Information Tool!" -ForegroundColor Cyan
        Write-Host "GitHub: https://github.com/TRogato/system-info-tool" -ForegroundColor Yellow
        Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        [Environment]::Exit(0)
    }
} elseif ($choice -eq "2") {
    # Fecha o terminal completamente
    [Environment]::Exit(0)
}
