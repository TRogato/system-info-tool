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
if ($NET -is [array] -and $NETDETAILS.Count -gt 0) {
    Write-Host "Interfaces de Rede Ativas:" -ForegroundColor Cyan
    foreach ($nic in $NETDETAILS) {
        Write-Host "  Interface: $($nic.Nome)" -ForegroundColor White
        Write-Field "Tipo" $nic.Tipo
        Write-Field "MAC Address" $nic.MAC
        Write-Field "IPv4" $nic.IPv4
        Write-Field "IPv6" $nic.IPv6
        Write-Field "Máscara" $nic.Mascara
        Write-Field "Gateway" $nic.Gateway
        Write-Field "DNS" $nic.DNS
        Write-Field "Status" $nic.Status
        Write-Host ""
    }
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

# Mensagem de confirmação
Write-Header "Informações Coletadas"
Write-Host "Todas as informações do sistema foram exibidas acima." -ForegroundColor Yellow
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