<#
.SYNOPSIS
    System Information Tool - Ferramenta para coleta de informacoes do sistema Windows

.DESCRIPTION
    Script PowerShell que coleta e exibe informacoes detalhadas sobre hardware, software,
    rede e armazenamento do sistema Windows. Inclui exportacao para CSV com formatacao aprimorada.

.PARAMETER NoClear
    Impede a limpeza da tela durante a execucao para uso em scripts automatizados.

.PARAMETER OutputPath
    Especifica o caminho para salvar o arquivo CSV. Padrao e a area de trabalho.

.EXAMPLE
    .\Get-SystemInfo.ps1
    Executa o script e exibe todas as informacoes do sistema.

.EXAMPLE
    .\Get-SystemInfo.ps1 -NoClear -OutputPath "C:\Reports"
    Executa sem limpar a tela e salva o CSV em "C:\Reports".

.NOTES
    Autor: Isaac Oolibama R. Lacerda
    Versao: 2.0
    Data: 07/08/2025
    Requer: Windows 10/11, PowerShell 5.1+
    Permissoes: Administrador (recomendado)
    LinkedIn: https://www.linkedin.com/in/tiago-rogato-da-silveira-095563b6/
    GitHub: https://github.com/TRogato/system-info-tool
#>

# =============================================================================
# CONFIGURACOES INICIAIS
# =============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

param(
    [switch]$NoClear,
    [string]$OutputPath = [Environment]::GetFolderPath("Desktop")
)

function Show-Loading {
    param([string[]]$Steps)
    foreach ($step in $Steps) {
        Write-Host "Carregando $step" -ForegroundColor Yellow
        Start-Sleep -Milliseconds 400
    }
}

function Write-Header($Title) {
    Write-Host "`n" -NoNewline
    Write-Host ("=" * 50) -ForegroundColor Magenta
    Write-Host $Title.ToUpper() -ForegroundColor Magenta
    Write-Host ("=" * 50) -ForegroundColor Magenta
}

function Write-Field($Key, $Value) {
    $formattedKey = "{0,-20}:" -f $Key
    Write-Host -NoNewline $formattedKey -ForegroundColor Cyan
    Write-Host " $Value" -ForegroundColor White
}

function Clean-SpecialCharacters {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) { return "N/A" }
    $cleaned = $Text -replace "[-\u001F\u007F-\u009F]", ""
    $cleaned = $cleaned -replace "[\u2028\u2029\u00A0]", " "
    $cleaned = $cleaned -replace "[\u201C\u201D]", '"' -replace "[\u2018\u2019]", "'"
    $cleaned = $cleaned -replace "[\u2013\u2014]", "-"
    $normalized = [Text.NormalizationForm]::FormD
    $cleaned = [string]::Join('', ($cleaned.Normalize($normalized).ToCharArray() | Where-Object { [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne 'NonSpacingMark' }))
    $cleaned = $cleaned -replace '[^\x00-\x7F]', ''
    return $cleaned.Trim().ToUpper()
}

function Get-WindowsProductKey {
    try {
        $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
        if ([string]::IsNullOrWhiteSpace($key)) {
            return "N/A"
        } else {
            return $key
        }
    } catch {
        return "N/A"
    }
}

function Export-SystemInfoToCSV {
    param(
        [hashtable]$SystemData,
        [string]$Path,
        [switch]$Utf8
    )
    try {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $csvPath = Join-Path $Path "SystemInfo_$timestamp.csv"
        $csvData = @()

        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "NOME"; Valor = Clean-SpecialCharacters $SystemData.SO }
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "VERSAO"; Valor = Clean-SpecialCharacters $SystemData.VERS }
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "ARQUITETURA"; Valor = Clean-SpecialCharacters $SystemData.ARCH }
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "PRODUCT KEY"; Valor = Clean-SpecialCharacters $SystemData.PKEY }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "PROCESSADOR"; Valor = Clean-SpecialCharacters $SystemData.CPU }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "MEMORIA RAM"; Valor = Clean-SpecialCharacters $SystemData.RAM }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "CONFIGURACAO DE CANAIS"; Valor = Clean-SpecialCharacters $SystemData.Channel }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "VELOCIDADE DA MEMORIA"; Valor = Clean-SpecialCharacters $SystemData.Speeds }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "PLACA DE VIDEO"; Valor = Clean-SpecialCharacters $SystemData.GPU }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "PLACA-MAE"; Valor = Clean-SpecialCharacters $SystemData.BOARD }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "BIOS"; Valor = Clean-SpecialCharacters $SystemData.BIOS }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "NUMERO DE SERIE"; Valor = Clean-SpecialCharacters $SystemData.SERIAL }

        if ($SystemData.NETDETAILS) {
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

        for ($i = 0; $i -lt $SystemData.DISKS.Count; $i++) {
            $csvData += [PSCustomObject]@{
                Categoria = "ARMAZENAMENTO"
                Campo = "DISCO $($i + 1)"
                Valor = Clean-SpecialCharacters $SystemData.DISKS[$i]
            }
        }

        $csvData += [PSCustomObject]@{ Categoria = "INFORMACOES ADICIONAIS"; Campo = "DATA DE COLETA"; Valor = (Get-Date -Format "dd/MM/yyyy HH:mm:ss").ToUpper() }
        $csvData += [PSCustomObject]@{ Categoria = "INFORMACOES ADICIONAIS"; Campo = "USUARIO"; Valor = Clean-SpecialCharacters $env:USERNAME }
        $csvData += [PSCustomObject]@{ Categoria = "INFORMACOES ADICIONAIS"; Campo = "COMPUTADOR"; Valor = Clean-SpecialCharacters $env:COMPUTERNAME }

        $csvContent = "CATEGORIA,CAMPO,VALOR`n"
        foreach ($row in $csvData) {
            $categoria = ($row.Categoria ?? "N/A") -replace '"', '""'
            $campo = ($row.Campo ?? "N/A") -replace '"', '""'
            $valor = ($row.Valor ?? "N/A") -replace '"', '""'
            $csvContent += "`"$categoria`",`"$campo`",`"$valor`"`n"
        }

        if ($Utf8) {
            [System.IO.File]::WriteAllText($csvPath, $csvContent, [System.Text.Encoding]::UTF8)
        } else {
            [System.IO.File]::WriteAllText($csvPath, $csvContent, [System.Text.Encoding]::Default)
        }
        return @{ Path = $csvPath; RecordCount = $csvData.Count }
    } catch {
        Write-Host "Erro ao gerar CSV: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

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

function Get-CPUInfo {
    try {
        $c = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
        $baseGHz = [math]::Round($c.CurrentClockSpeed/1000,1)
        return "$($c.Name.Trim()) | Cores: $($c.NumberOfCores) | Threads: $($c.NumberOfLogicalProcessors) | Base: ${baseGHz}GHz"
    } catch {
        return 'N/A'
    }
}

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

function Get-GPUInfo {
    try {
        $g = Get-CimInstance Win32_VideoController -ErrorAction Stop | Select-Object -First 1
        return "$($g.Name) | $([math]::Round($g.AdapterRAM/1MB)) MB | Driver: $($g.DriverVersion)"
    } catch {
        return 'N/A'
    }
}

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

function Get-NetworkInfo {
    $NET = @()
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
        if ($NET.Count -eq 0) { $NET = @("N/A"); $NETDETAILS = @() }
    } catch {
        $NET = @("N/A")
        $NETDETAILS = @()
    }
    return @{ NET = $NET; NETDETAILS = $NETDETAILS }
}

function Get-DisksInfo {
    try {
        return Get-CimInstance Win32_DiskDrive -ErrorAction Stop |
            ForEach-Object { "{0}: {1:N1} GB ({2})" -f $_.Model, ($_.Size/1GB), $_.InterfaceType }
    } catch {
        return @("N/A")
    }
}

$loadingSteps = @(
    "Coletando informacoes do sistema...",
    "Verificando hardware...",
    "Analisando configuracoes de rede...",
    "Listando discos de armazenamento..."
)
Show-Loading $loadingSteps

if (-not $NoClear) {
    try { [Console]::Clear() } catch {}
}

$osInfo = Get-OSInfo
$SO = $osInfo.SO
$VERS = $osInfo.VERS
$ARCH = $osInfo.ARCH
$CPU = Get-CPUInfo
$ramInfo = Get-RAMInfo
$RAM = $ramInfo.RAM
$Channel = $ramInfo.Channel
$Speeds = $ramInfo.Speeds
$GPU = Get-GPUInfo
$boardInfo = Get-BoardBiosInfo
$SERIAL = $boardInfo.SERIAL
$BIOS = $boardInfo.BIOS
$BOARD = $boardInfo.BOARD
$netInfo = Get-NetworkInfo
$NET = $netInfo.NET
$NETDETAILS = $netInfo.NETDETAILS
$DISKS = Get-DisksInfo
$PKEY = Get-WindowsProductKey

Write-Header "Resumo do Sistema"
Write-Field "Sistema Operacional" $SO
Write-Field "Versao" $VERS
Write-Field "Arquitetura" $ARCH
Write-Field "Product Key" $PKEY

Write-Header "Hardware"
Write-Field "Processador" $CPU
Write-Field "Memoria" "$RAM - $Channel - $Speeds"
Write-Field "Placa de Video" $GPU
Write-Field "Placa-Mae" $BOARD
Write-Field "BIOS" $BIOS
Write-Field "Numero de Serie" $SERIAL

Write-Header "Rede"
if ($NET -is [array] -and $NET -notcontains "N/A") {
    Write-Host "Interfaces de Rede Ativas:" -ForegroundColor Cyan
    foreach ($nic in $NETDETAILS) {
        Write-Host "`n  [$($nic.Tipo)] $($nic.Nome)" -ForegroundColor Yellow
        Write-Field "MAC Address" $nic.MAC
        Write-Field "IPv4" $nic.IPv4
        Write-Field "IPv6" $nic.IPv6
        Write-Field "Mascara" $nic.Mascara
        Write-Field "Gateway" $nic.Gateway
        Write-Field "DNS" $nic.DNS
        Write-Field "Status" $nic.Status
    }
} else {
    Write-Field "Rede" "N/A"
}

Write-Header "Discos"
foreach ($d in $DISKS) {
    Write-Host "  Disco $d" -ForegroundColor White
}

Write-Header "Opcoes Adicionais"
Write-Host "1 - Gerar relatorio CSV"
Write-Host "2 - Sair"
Write-Host "`nEscolha uma opcao (1 ou 2): " -NoNewline -ForegroundColor Yellow
$choice = Read-Host

if ($choice -eq "1") {
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
        NET = \(NET
        NETDETAILS = $NETDETAILS
        DISKS = $DISKS
        PKEY = $PKEY
    }
    $csvResult = Export-SystemInfoToCSV -SystemData $systemData -Path $OutputPath -Utf8
    if ($csvResult) {
        Write-Header "Relatorio Gerado"
        Write-Host "Arquivo salvo em: $($csvResult.Path)" -ForegroundColor Green
        Write-Host "Total de registros: $($csvResult.RecordCount)" -ForegroundColor Magenta
        Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

Write-Host "`nObrigado por usar o System Information Tool!" -ForegroundColor Cyan
Write-Host "GitHub: https://github.com/TRogato/system-info-tool" -ForegroundColor Yellow
[Environment]::Exit(0)