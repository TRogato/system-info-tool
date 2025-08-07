<#
.SYNOPSIS
    System Information Tool - Ferramenta para coleta de informações do sistema Windows

.DESCRIPTION
    Script PowerShell que coleta e exibe informações detalhadas sobre hardware, software,
    rede e armazenamento do sistema Windows. Inclui exportação para CSV com formatação aprimorada.

.PARAMETER NoClear
    Impede a limpeza da tela durante a execução para uso em scripts automatizados.

.PARAMETER OutputPath
    Especifica o caminho para salvar o arquivo CSV. Padrão é a área de trabalho.

.EXAMPLE
    .\Get-SystemInfo.ps1
    Executa o script e exibe todas as informações do sistema.

.EXAMPLE
    .\Get-SystemInfo.ps1 -NoClear -OutputPath "C:\Reports"
    Executa sem limpar a tela e salva o CSV em "C:\Reports".

.NOTES
    Autor: Isaac Oolibama R. Lacerda
    Versão: 2.0
    Data: 06/08/2025
    Requer: Windows 10/11, PowerShell 5.1+
    Permissões: Administrador (recomendado)
    LinkedIn: https://www.linkedin.com/in/tiago-rogato-da-silveira-095563b6/
    GitHub: https://github.com/TRogato/system-info-tool
#>

# =============================================================================
# CONFIGURAÇÕES INICIAIS
# =============================================================================

# Configuração de codificação para suporte a caracteres especiais
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Parâmetros do script
param(
    [switch]$NoClear,
    [string]$OutputPath = [Environment]::GetFolderPath("Desktop")
)

# Função para simular loading visual
function Show-Loading {
    param([string[]]$Steps)
    foreach ($step in $Steps) {
        Write-Host "🔄 $step" -ForegroundColor Yellow
        Start-Sleep -Milliseconds 400
    }
}

# Função para formatar cabeçalhos
function Write-Header($Title) {
    Write-Host "`n" -NoNewline
    Write-Host ("=" * 50) -ForegroundColor Magenta
    Write-Host $Title.ToUpper() -ForegroundColor Magenta
    Write-Host ("=" * 50) -ForegroundColor Magenta
}

# Função para formatar campos
function Write-Field($Key, $Value) {
    $formattedKey = "{0,-20}:" -f $Key
    Write-Host -NoNewline $formattedKey -ForegroundColor Cyan
    Write-Host " $Value" -ForegroundColor White
}

# Função para limpar caracteres especiais
function Clean-SpecialCharacters {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) { return "N/A" }
    $cleaned = $Text -replace "[\u0000-\u001F\u007F-\u009F]", ""
    $cleaned = $cleaned -replace "[\u2028\u2029\u00A0]", " "
    $cleaned = $cleaned -replace "[\u201C\u201D]", '"' -replace "[\u2018\u2019]", "'"
    $cleaned = $cleaned -replace "[\u2013\u2014]", "-"
    $normalized = [Text.NormalizationForm]::FormD
    $cleaned = [string]::Join('', ($cleaned.Normalize($normalized).ToCharArray() | Where-Object { [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne 'NonSpacingMark' }))
    $cleaned = $cleaned -replace '[^\x00-\x7F]', ''
    return $cleaned.Trim().ToUpper()
}

# Função para obter a chave do Windows
function Get-WindowsProductKey {
    try {
        $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
        return [string]::IsNullOrWhiteSpace($key) ? "N/A" : $key
    } catch {
        return "N/A"
    }
}

# Função para gerar arquivo CSV
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

        # Adiciona informações ao CSV
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "NOME"; Valor = Clean-SpecialCharacters $SystemData.SO }
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "VERSÃO"; Valor = Clean-SpecialCharacters $SystemData.VERS }
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "ARQUITETURA"; Valor = Clean-SpecialCharacters $SystemData.ARCH }
        $csvData += [PSCustomObject]@{ Categoria = "SISTEMA OPERACIONAL"; Campo = "PRODUCT KEY"; Valor = Clean-SpecialCharacters $SystemData.PKEY }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "PROCESSADOR"; Valor = Clean-SpecialCharacters $SystemData.CPU }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "MEMÓRIA RAM"; Valor = Clean-SpecialCharacters $SystemData.RAM }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "CONFIGURAÇÃO DE CANAIS"; Valor = Clean-SpecialCharacters $SystemData.Channel }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "VELOCIDADE DA MEMÓRIA"; Valor = Clean-SpecialCharacters $SystemData.Speeds }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "PLACA DE VÍDEO"; Valor = Clean-SpecialCharacters $SystemData.GPU }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "PLACA-MÃE"; Valor = Clean-SpecialCharacters $SystemData.BOARD }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "BIOS"; Valor = Clean-SpecialCharacters $SystemData.BIOS }
        $csvData += [PSCustomObject]@{ Categoria = "HARDWARE"; Campo = "NÚMERO DE SÉRIE"; Valor = Clean-SpecialCharacters $SystemData.SERIAL }
        
        # Rede
        if ($SystemData.NETDETAILS) {
            foreach ($nic in $SystemData.NETDETAILS) {
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - TIPO"; Valor = Clean-SpecialCharacters $nic.Tipo }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - MAC"; Valor = Clean-SpecialCharacters $nic.MAC }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - IPV4"; Valor = Clean-SpecialCharacters $nic.IPv4 }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - IPV6"; Valor = Clean-SpecialCharacters $nic.IPv6 }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - MÁSCARA"; Valor = Clean-SpecialCharacters $nic.Mascara }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - GATEWAY"; Valor = Clean-SpecialCharacters $nic.Gateway }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - DNS"; Valor = Clean-SpecialCharacters $nic.DNS }
                $csvData += [PSCustomObject]@{ Categoria = "REDE"; Campo = "INTERFACE $($nic.Nome) - STATUS"; Valor = Clean-SpecialCharacters $nic.Status }
            }
        }

        # Discos
        for ($i = 0; $i -lt $SystemData.DISKS.Count; $i++) {
            $csvData += [PSCustomObject]@{
                Categoria = "ARMAZENAMENTO"
                Campo = "DISCO $($i + 1)"
                Valor = Clean-SpecialCharacters $SystemData.DISKS[$i]
            }
        }

        # Informações adicionais
        $csvData += [PSCustomObject]@{ Categoria = "INFORMAÇÕES ADICIONAIS"; Campo = "DATA DE COLETA"; Valor = (Get-Date -Format "dd/MM/yyyy HH:mm:ss").ToUpper() }
        $csvData += [PSCustomObject]@{ Categoria = "INFORMAÇÕES ADICIONAIS"; Campo = "USUÁRIO"; Valor = Clean-SpecialCharacters $env:USERNAME }
        $csvData += [PSCustomObject]@{ Categoria = "INFORMAÇÕES ADICIONAIS"; Campo = "COMPUTADOR"; Valor = Clean-SpecialCharacters $env:COMPUTERNAME }

        # Gera CSV
        $csvContent = "CATEGORIA,CAMPO,VALOR`n"
        foreach ($row in $csvData) {
            $categoria = $row.Categoria -replace '"', '""'
            $campo = $row.Campo -replace '"', '""'
            $valor = $row.Valor -replace '"', '""'
            $csvContent += "`"$categoria`","`"$campo`","`"$valor`"`n"
        }

        if ($Utf8) {
            [System.IO.File]::WriteAllText($csvPath, $csvContent, [System.Text.Encoding]::UTF8)
        } else {
            [System.IO.File]::WriteAllText($csvPath, $csvContent, [System.Text.Encoding]::Default)
        }
        return @{ Path = $csvPath; RecordCount = $csvData.Count }
    } catch {
        Write-Host "❌ Erro ao gerar CSV: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Função para coletar informações do sistema operacional
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

# Função para coletar informações do processador
function Get-CPUInfo {
    try {
        $c = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
        $baseGHz = [math]::Round($c.CurrentClockSpeed/1000,1)
        return "$($c.Name.Trim()) | Cores: $($c.NumberOfCores) | Threads: $($c.NumberOfLogicalProcessors) | Base: ${baseGHz}GHz"
    } catch {
        return 'N/A'
    }
}

# Função para coletar informações da memória RAM
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

# Função para coletar informações da placa de vídeo
function Get-GPUInfo {
    try {
        $g = Get-CimInstance Win32_VideoController -ErrorAction Stop | Select-Object -First 1
        return "$($g.Name) | $([math]::Round($g.AdapterRAM/1MB)) MB | Driver: $($g.DriverVersion)"
    } catch {
        return 'N/A'
    }
}

# Função para coletar informações da placa-mãe e BIOS
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

# Função para coletar informações de rede
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

# Função para coletar informações de armazenamento
function Get-DisksInfo {
    try {
        return Get-CimInstance Win32_DiskDrive -ErrorAction Stop |
            ForEach-Object { "{0}: {1:N1} GB ({2})" -f $_.Model, ($_.Size/1GB), $_.InterfaceType }
    } catch {
        return @("N/A")
    }
}

# =============================================================================
# EXECUÇÃO PRINCIPAL
# =============================================================================

# Loading visual
$loadingSteps = @(
    "Coletando informações do sistema...",
    "Verificando hardware...",
    "Analisando configurações de rede...",
    "Listando discos de armazenamento..."
)
Show-Loading $loadingSteps

# Limpar tela, se permitido
if (-not $NoClear) {
    try { [Console]::Clear() } catch {}
}

# Coleta de dados
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

# Exibição dos resultados
Write-Header "Resumo do Sistema"
Write-Field "Sistema Operacional" $SO
Write-Field "Versão" $VERS
Write-Field "Arquitetura" $ARCH
Write-Field "Product Key" $PKEY

Write-Header "Hardware"
Write-Field "Processador" $CPU
Write-Field "Memória" "$RAM - $Channel - $Speeds"
Write-Field "Placa de Vídeo" $GPU
Write-Field "Placa-Mãe" $BOARD
Write-Field "BIOS" $BIOS
Write-Field "Nº de Série" $SERIAL

Write-Header "Rede"
if ($NET -is [array] -and $NET -notcontains "N/A") {
    Write-Host "Interfaces de Rede Ativas:" -ForegroundColor Cyan
    foreach ($nic in $NETDETAILS) {
        Write-Host "`n  [$($nic.Tipo)] $($nic.Nome)" -ForegroundColor Yellow
        Write-Field "MAC Address" $nic.MAC
        Write-Field "IPv4" $nic.IPv4
        Write-Field "IPv6" $nic.IPv6
        Write-Field "Máscara" $nic.Mascara
        Write-Field "Gateway" $nic.Gateway
        Write-Field "DNS" $nic.DNS
        Write-Field "Status" $nic.Status
    }
} else {
    Write-Field "Rede" "N/A"
}

Write-Header "Discos"
foreach ($d in $DISKS) {
    Write-Host "  📀 $d" -ForegroundColor White
}

# Menu de opções
Write-Header "Opções Adicionais"
Write-Host "1 - Gerar relatório CSV"
Write-Host "2 - Sair"
Write-Host "`nEscolha uma opção (1 ou 2): " -NoNewline -ForegroundColor Yellow
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
        NET = $NET
        NETDETAILS = $NETDETAILS
        DISKS = $DISKS
        PKEY = $PKEY
    }
    $csvResult = Export-SystemInfoToCSV -SystemData $systemData -Path $OutputPath -Utf8
    if ($csvResult) {
        Write-Header "Relatório Gerado"
        Write-Host "✅ Arquivo salvo em: $($csvResult.Path)" -ForegroundColor Green
        Write-Host "Total de registros: $($csvResult.RecordCount)" -ForegroundColor Magenta
        Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

Write-Host "`nObrigado por usar o System Information Tool!" -ForegroundColor Cyan
Write-Host "GitHub: https://github.com/TRogato/system-info-tool" -ForegroundColor Yellow
[Environment]::Exit(0)