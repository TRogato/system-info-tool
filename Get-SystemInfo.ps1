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
    Versao: 1.0
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
    $fmtKey = "{0,-18}:" -f $k
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
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "PRODUCT KEY WINDOWS"; Valor = Clean-SpecialCharacters $SystemData.PKEY }
        # HARDWARE
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "PROCESSADOR"; Valor = Clean-SpecialCharacters $SystemData.CPU }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "MEMORIA RAM"; Valor = Clean-SpecialCharacters $SystemData.RAM }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "CONFIGURACAO DE CANAIS"; Valor = Clean-SpecialCharacters $SystemData.Channel }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "VELOCIDADE DA MEMORIA"; Valor = Clean-SpecialCharacters $SystemData.Speeds }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "PLACA DE VIDEO"; Valor = Clean-SpecialCharacters $SystemData.GPU }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "PLACA-MAE"; Valor = Clean-SpecialCharacters $SystemData.BOARD }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "BIOS"; Valor = Clean-SpecialCharacters $SystemData.BIOS }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "NUMERO DE SERIE"; Valor = Clean-SpecialCharacters $SystemData.SERIAL }
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
        # ARMAZENAMENTO
        for ($i = 0; $i -lt $SystemData.DISKS.Count; $i++) {
            $csvData += [PSCustomObject]@{
                Categoria = "ARMAZENAMENTO"
                Campo = "DISCO $($i + 1)"
                Valor = Clean-SpecialCharacters $SystemData.DISKS[$i]
            }
        }
        # Informações adicionais
        $csvData += [PSCustomObject]@{ Categoria = "INFORMACOES ADICIONAIS"; Campo = "DATA DE COLETA"; Valor = (Get-Date -Format "dd/MM/yyyy HH:mm:ss").ToUpper() }
        $csvData += [PSCustomObject]@{ Categoria = "INFORMACOES ADICIONAIS"; Campo = "USUARIO"; Valor = Clean-SpecialCharacters $env:USERNAME }
        $csvData += [PSCustomObject]@{ Categoria = "INFORMACOES ADICIONAIS"; Campo = "COMPUTADOR"; Valor = Clean-SpecialCharacters $env:COMPUTERNAME }
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

# =============================================================================
# SEQUENCIA DE LOADING VISUAL (opcional)
# =============================================================================

$loadingSteps = @(
    "Carregando informacoes do sistema..."
    "Carregando hardware..."
    "Carregando informacoes de rede..."
    "Carregando discos..."
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
# COLETA DE DADOS DA PLACA DE VIDEO
# =============================================================================

function Get-GPUInfo {
    try {
        $g = Get-CimInstance Win32_VideoController -ErrorAction Stop | Select-Object -First 1
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
# EXIBICAO ESTILIZADA DOS RESULTADOS
# =============================================================================

# Exibe todas as informações coletadas na tela
Write-Header "Resumo do Sistema"
Write-Field "Sistema Operacional" $SO
Write-Field "Versao"             $VERS
Write-Field "Arquitetura"        $ARCH
Write-Field "Product Key Windows" (Get-WindowsProductKey)

Write-Header "Hardware"
Write-Field "Processador"        $CPU
Write-Field "Memoria"            "$RAM - $Channel - $Speeds"
Write-Field "GPU"                $GPU
Write-Field "Placa-Mae"          $BOARD
Write-Field "BIOS"               $BIOS
Write-Field "Número de Série"    $SERIAL

Write-Header "Rede"
if ($NET -is [array]) {
    Write-Host "Interfaces de Rede Ativas:" -ForegroundColor Cyan
    Write-Host $NETINFO
} else {
    Write-Field "Rede" $NET
    Write-Host $NETINFO
}

Write-Header "Discos"
foreach ($d in $DISKS) {
    Write-Host "  $d"
}

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
        PKEY = Get-WindowsProductKey
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
