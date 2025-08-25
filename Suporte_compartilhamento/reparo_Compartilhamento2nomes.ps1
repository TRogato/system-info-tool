# reparacao_sistema.ps1
# Script de reparação para Windows 10/11 - Corrige PowerShell e conexões de rede
# Execute como Administrador

Write-Host "==================================================" -ForegroundColor Green
Write-Host "SCRIPT DE REPARAÇÃO DO SISTEMA WINDOWS 10/11" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Função para verificar se é administrador
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Verificar privilégios de administrador
if (-not (Test-Admin)) {
    Write-Host "ERRO: Execute este script como Administrador!" -ForegroundColor Red
    Write-Host "Clique com botão direito > Executar com PowerShell como Administrador" -ForegroundColor Yellow
    pause
    exit 1
}

# Função para registrar log
function Write-Log {
    param([string]$message, [string]$color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $message"
    Write-Host $logMessage -ForegroundColor $color
    Add-Content -Path "$env:USERPROFILE\Desktop\reparacao_log.txt" -Value $logMessage
}

# Criar arquivo de log
Write-Log "Iniciando processo de reparação do sistema" "Green"

# 1. VERIFICAÇÃO INICIAL DO SISTEMA
Write-Log "1. Verificando integridade do sistema..." "Cyan"
sfc /scannow
Write-Log "Verificação SFC concluída" "Green"

# 2. REPARAÇÃO DISM
Write-Log "2. Executando DISM para reparação da imagem..." "Cyan"
dism /online /cleanup-image /restorehealth
Write-Log "Reparação DISM concluída" "Green"

# 3. VERIFICAÇÃO DE DISCO
Write-Log "3. Verificando integridade do disco..." "Cyan"
chkdsk C: /f /r
Write-Log "Verificação de disco agendada para próxima reinicialização" "Yellow"

# 4. REPARAR .NET FRAMEWORK
Write-Log "4. Reparando .NET Framework..." "Cyan"
try {
    # Parar serviços relacionados
    Stop-Service -Name "Windows Update" -Force -ErrorAction SilentlyContinue
    Stop-Service -Name "wuuauserv" -Force -ErrorAction SilentlyContinue
    
    # Executar reparador oficial
    $netFixPath = "$env:TEMP\netfx_repairetool.exe"
    if (-not (Test-Path $netFixPath)) {
        Invoke-WebRequest -Uri "https://aka.ms/netfxrepairtool" -OutFile $netFixPath
    }
    Start-Process -FilePath $netFixPath -ArgumentList "/q /norestart" -Wait
    Write-Log "Reparo .NET Framework concluído" "Green"
}
catch {
    Write-Log "Erro no reparo .NET: $($_.Exception.Message)" "Red"
}

# 5. REINSTALAR POWERSHELL
Write-Log "5. Reinstalando PowerShell..." "Cyan"
try {
    # Desregistrar componentes
    regsvr32 /s %windir%\Microsoft.NET\Framework\v4.0.30319\mscoree.dll
    
    # Reinstalar via DISM
    dism /online /Remove-Capability -Name "Microsoft.Windows.PowerShell~~~~0.0.1.0"
    dism /online /Add-Capability -Name "Microsoft.Windows.PowerShell~~~~0.0.1.0"
    
    Write-Log "Reinstalação do PowerShell concluída" "Green"
}
catch {
    Write-Log "Erro na reinstalação do PowerShell: $($_.Exception.Message)" "Red"
}

# 6. CORRIGIR CONEXÕES DE REDE
Write-Log "6. Corrigindo conexões de rede..." "Cyan"
try {
    # Limpar conexões antigas
    net use * /delete /y
    net stop workstation /y
    net start workstation
    
    # Limpar credenciais
    cmdkey /list | ForEach-Object {
        if ($_ -like "*172.16.0.11*" -or $_ -like "*diretoria*") {
            cmdkey /delete:$_
        }
    }
    
    Write-Log "Conexões de rede limpas" "Green"
}
catch {
    Write-Log "Erro ao limpar conexões de rede: $($_.Exception.Message)" "Red"
}

# 7. REPARAR REGISTRO
Write-Log "7. Reparando registro do sistema..." "Cyan"
try {
    # Backup do registro
    $regBackup = "$env:USERPROFILE\Desktop\registry_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
    reg export "HKLM\SOFTWARE\Microsoft\.NETFramework" $regBackup /y
    reg export "HKLM\SOFTWARE\Microsoft\NET Framework Setup" "$env:USERPROFILE\Desktop\netframework_backup.reg" /y
    
    # Reparar chaves de registro
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework" -Name "InstallRoot" -Value "$env:windir\Microsoft.NET\Framework" -ErrorAction SilentlyContinue
    Write-Log "Registro reparado" "Green"
}
catch {
    Write-Log "Erro no reparo do registro: $($_.Exception.Message)" "Red"
}

# 8. VERIFICAR E CORRIGIR NOME DO COMPUTADOR
Write-Log "8. Verificando nome do computador..." "Cyan"
$currentName = $env:COMPUTERNAME
$newName = "${currentName}_FIXED"

try {
    if ($currentName -like "* *" -or $currentName.Length -gt 15) {
        Write-Log "Nome atual: $currentName - Recomendado alterar para nome sem espaços e até 15 caracteres" "Yellow"
        $changeName = Read-Host "Deseja alterar o nome do computador? (S/N)"
        if ($changeName -eq "S" -or $changeName -eq "s") {
            $newName = Read-Host "Digite o novo nome (até 15 caracteres, sem espaços)"
            Rename-Computer -NewName $newName -Force
            Write-Log "Nome do computador alterado para: $newName" "Green"
            Write-Log "Reinicie o computador para aplicar a mudança" "Yellow"
        }
    }
}
catch {
    Write-Log "Erro ao verificar nome: $($_.Exception.Message)" "Red"
}

# 9. CONFIGURAÇÕES FINAIS
Write-Log "9. Aplicando configurações finais..." "Cyan"
try {
    # Configurar Execution Policy
    Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
    
    # Reparar associações de arquivo
    ftype Microsoft.PowerShellScript.1="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -File "%1"
    
    Write-Log "Configurações aplicadas" "Green"
}
catch {
    Write-Log "Erro nas configurações finais: $($_.Exception.Message)" "Red"
}

# 10. RELATÓRIO FINAL
Write-Log "10. Gerando relatório final..." "Cyan"
$systemInfo = systeminfo
$netVersion = Get-ChildItem "$env:windir\Microsoft.NET\Framework\v4*" | Select-Object Name
$psVersion = $PSVersionTable.PSVersion

$report = @"
RELATÓRIO DE REPARAÇÃO DO SISTEMA
Data: $(Get-Date)
Computador: $env:COMPUTERNAME
Usuário: $env:USERNAME

INFORMAÇÕES DO SISTEMA:
$systemInfo

VERSÃO .NET INSTALADA:
$($netVersion | Out-String)

VERSÃO POWERSHELL:
$psVersion

LOG DE EXECUÇÃO:
Consulte $env:USERPROFILE\Desktop\reparacao_log.txt

RECOMENDAÇÕES:
- Reinicie o computador para completar todas as reparações
- Verifique se o PowerShell está funcionando normalmente
- Teste as conexões de rede após reinicialização
"@

$report | Out-File -FilePath "$env:USERPROFILE\Desktop\relatorio_reparacao.txt" -Encoding UTF8

Write-Host "==================================================" -ForegroundColor Green
Write-Host "REPARAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Green
Write-Host "Relatório salvo em: $env:USERPROFILE\Desktop\relatorio_reparacao.txt" -ForegroundColor Yellow
Write-Host "LOG completo em: $env:USERPROFILE\Desktop\reparacao_log.txt" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green
Write-Host "Reinicie o computador para aplicar todas as mudanças" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green

pause
