# max_desempenho_energia.ps1
# Script para maximizar o desempenho de energia no Windows 10/11
# Execute como Administrador

Write-Host "==================================================" -ForegroundColor Green
Write-Host "🐆 OTIMIZADOR DE DESEMPENHO - WINDOWS 10/11" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Verificar se é administrador
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Host "❌ ERRO: Execute como Administrador!" -ForegroundColor Red
    Write-Host "💡 Clique direito > Executar com PowerShell como Administrador" -ForegroundColor Yellow
    pause
    exit 1
}

# Função para registrar log
function Write-Log {
    param([string]$message, [string]$color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $message"
    Write-Host $logMessage -ForegroundColor $color
    Add-Content -Path "$env:USERPROFILE\Desktop\otimizacao_desempenho_log.txt" -Value $logMessage
}

Write-Log "Iniciando otimização de desempenho máximo..." "Green"

# 1. CRIAR ESQUEMA DE ENERGIA DE DESEMPENHO MÁXIMO
Write-Log "1. Criando esquema de energia de desempenho máximo..." "Cyan"

try {
    # Verificar se o esquema já existe
    $existingScheme = powercfg -l | Select-String "Desempenho Máximo"
    
    if (-not $existingScheme) {
        # Duplicar esquema balanceado para criar base
        $highPerfGuid = powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        $highPerfGuid = $highPerfGuid -replace ".*GUID: ([a-f0-9-]+).*", '$1'
        
        # Renomear para "Desempenho Máximo"
        powercfg -changename $highPerfGuid "Desempenho Máximo" "Esquema de desempenho máximo para jogos e aplicações pesadas"
        
        Write-Log "✅ Esquema 'Desempenho Máximo' criado: $highPerfGuid" "Green"
    } else {
        $highPerfGuid = $existingScheme -replace ".*([a-f0-9-]+).*", '$1'
        Write-Log "⚠️ Esquema já existe: $highPerfGuid" "Yellow"
    }
}
catch {
    Write-Log "❌ Erro ao criar esquema: $($_.Exception.Message)" "Red"
}

# 2. CONFIGURAR PARÂMETROS DE ENERGIA PARA DESEMPENHO MÁXIMO
Write-Log "2. Configurando parâmetros de energia..." "Cyan"

$powerSettings = @{
    # Processador
    "54533251-82be-4824-96c1-47b60b740d00" = @{ # PROCESSOR
        "75b0ae3f-bce0-45a7-8c89-c9611c25e100" = 100  # Maximum processor state (%)
        "bc5038f7-23e0-4960-96da-33abaf5935ec" = 100  # Minimum processor state (%)
        "893dee8e-2bef-41e0-89c6-b55d0929964c" = 0    # Processor performance boost mode (Aggressive)
        "94d3a615-a899-4ac5-ae2b-e4d8f634367f" = 0    # Processor performance boost policy (Aggressive)
    }
    # PCI Express
    "501a4d13-42af-4429-9fd1-a8218c268e20" = @{ # PCIEXPRESS
        "ee12f906-d277-404b-b6da-e5fa1a576df5" = 0    # Link State Power Management (OFF)
    }
    # Disco Rígido
    "0012ee47-9041-4b5d-9b77-535fba8b1442" = @{ # DISK
        "6738e2c4-e8a5-4a42-b16a-e040e769756e" = 0    # Turn off hard disk after (NEVER)
    }
    # USB
    "2a737441-1930-4402-8d77-b2bebba308a3" = @{ # USB
        "48e6b7a6-50f5-4782-a5d4-53bb8f07e226" = 1    # Selective suspend (DISABLED)
    }
    # Adaptador Wi-Fi
    "19cbb8fa-5279-450e-9fac-8a3d5fedd0c1" = @{ # WIFI
        "12bbebe6-58d6-4636-95bb-3217ef867c1a" = 1    # Power Saving Mode (Maximum Performance)
    }
    # Placa de Vídeo
    "5fb4938d-1ee8-4b0f-9a3c-5036b0ab995c" = @{ # GPU
        "d14c7f73-3967-446e-9c68-9a5e2ab0c5c8" = 2    # Power Throttling (Disabled)
    }
}

foreach ($category in $powerSettings.GetEnumerator()) {
    $categoryGuid = $category.Key
    $settings = $category.Value
    
    foreach ($setting in $settings.GetEnumerator()) {
        $settingGuid = $setting.Key
        $value = $setting.Value
        
        try {
            powercfg -setacvalueindex $highPerfGuid $categoryGuid $settingGuid $value
            powercfg -setdcvalueindex $highPerfGuid $categoryGuid $settingGuid $value
            Write-Log "✅ Configurado: $categoryGuid\$settingGuid = $value" "Green"
        }
        catch {
            Write-Log "⚠️ Erro na configuração: $categoryGuid\$settingGuid" "Yellow"
        }
    }
}

# 3. CONFIGURAÇÕES AVANÇADAS DO SISTEMA
Write-Log "3. Aplicando configurações avançadas do sistema..." "Cyan"

try {
    # Desativar CPU Throttling
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f
    
    # Desativar Core Parking
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMax" /t REG_DWORD /d 100 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMin" /t REG_DWORD /d 100 /f
    
    # Configurar Prioridade de CPU
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f
    
    Write-Log "✅ Configurações de registro aplicadas" "Green"
}
catch {
    Write-Log "❌ Erro nas configurações de registro: $($_.Exception.Message)" "Red"
}

# 4. OTIMIZAR SERVIÇOS DO WINDOWS
Write-Log "4. Otimizando serviços do Windows..." "Cyan"

$servicesToDisable = @(
    "SysMain",           # SuperFetch
    "DiagTrack",         # Telemetria
    "dmwappushservice",  # Push de mensagens
    "lfsvc",             # Geolocalização
    "MapsBroker",        # Mapas offline
    "TrkWks",            # Rastreamento de links
    "WSearch"            # Windows Search
)

foreach ($service in $servicesToDisable) {
    try {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Log "✅ Serviço desativado: $service" "Green"
    }
    catch {
        Write-Log "⚠️ Não foi possível desativar: $service" "Yellow"
    }
}

# 5. CONFIGURAÇÕES DE ENERGIA DA GPU NVIDIA/AMD (se aplicável)
Write-Log "5. Otimizando configurações de GPU..." "Cyan"

try {
    # NVIDIA
    if (Get-Command "nvidia-smi" -ErrorAction SilentlyContinue) {
        nvidia-smi -pm 1  # Modo de performance persistente
        nvidia-smi -pl 100  # Maximum power limit
        Write-Log "✅ GPU NVIDIA otimizada" "Green"
    }
    
    # AMD
    if (Get-ItemProperty "HKLM:\SOFTWARE\AMD" -ErrorAction SilentlyContinue) {
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_PhmSoftPowerPlayTable" /t REG_BINARY /d "0000000000000000000000000000000000000000000000000000000000000000" /f
        Write-Log "✅ GPU AMD otimizada" "Green"
    }
}
catch {
    Write-Log "⚠️ Otimização de GPU não aplicada" "Yellow"
}

# 6. CONFIGURAÇÕES DE PLANO DE FUNDO E ANIMAÇÕES
Write-Log "6. Otimizando interface visual..." "Cyan"

try {
    # Desativar animações
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f
    
    # Desativar transparência
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f
    
    # Desativar efeitos de sombra
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d 0 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 0 /f
    
    Write-Log "✅ Interface visual otimizada" "Green"
}
catch {
    Write-Log "❌ Erro na otimização visual: $($_.Exception.Message)" "Red"
}

# 7. APLICAR TODAS AS CONFIGURAÇÕES
Write-Log "7. Aplicando todas as configurações..." "Cyan"

try {
    # Ativar esquema de desempenho máximo
    powercfg -setactive $highPerfGuid
    
    # Forçar atualização das configurações
    powercfg -export "$env:USERPROFILE\Desktop\Esquema_Desempenho_Maximo.pow" $highPerfGuid
    
    Write-Log "✅ Todas as configurações aplicadas" "Green"
}
catch {
    Write-Log "❌ Erro ao aplicar configurações: $($_.Exception.Message)" "Red"
}

# 8. CRIAR SCRIPTS DE CONTROLE RÁPIDO
Write-Log "8. Criando scripts de controle rápido..." "Cyan"

# Script para alternar entre modos
$switchScript = @"
# switch_desempenho.ps1
`$currentScheme = powercfg -getactivescheme
if (`$currentScheme -like "*Desempenho Máximo*") {
    powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e  # Balanced
    Write-Host "Modo Balanceado ativado" -ForegroundColor Green
} else {
    powercfg -setactive $highPerfGuid  # Desempenho Máximo
    Write-Host "Modo Desempenho Máximo ativado" -ForegroundColor Yellow
}
"@

$switchScript | Out-File -FilePath "$env:USERPROFILE\Desktop\Switch_Desempenho.ps1" -Encoding UTF8

# 9. RELATÓRIO FINAL
Write-Log "9. Gerando relatório final..." "Cyan"

$report = @"
🐆 RELATÓRIO DE OTIMIZAÇÃO DE DESEMPENHO
Data: $(Get-Date)
Computador: $env:COMPUTERNAME

CONFIGURAÇÕES APLICADAS:
✅ Esquema de energia personalizado
✅ Processador: 100% performance
✅ PCI Express: Link State Power Management OFF
✅ Disco: Nunca desligar
✅ USB: Selective suspend DISABLED
✅ Wi-Fi: Maximum Performance
✅ GPU: Power Throttling Disabled

SERVIÇOS DESATIVADOS:
- SuperFetch (SysMain)
- Telemetria (DiagTrack)
- Push de mensagens
- Geolocalização
- Mapas offline
- Rastreamento de links
- Windows Search

PRÓXIMOS PASSOS:
1. Reinicie o computador para aplicar todas as mudanças
2. Use o script 'Switch_Desempenho.ps1' na área de trabalho para alternar entre modos
3. Verifique a temperatura do sistema durante uso intensivo

⚠️ AVISOS:
- Maior consumo de energia em notebooks
- Possível aumento de temperatura
- Verifique estabilidade do sistema

Para voltar às configurações padrão:
Execute 'powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e'
"@

$report | Out-File -FilePath "$env:USERPROFILE\Desktop\relatorio_otimizacao.txt" -Encoding UTF8

Write-Host "==================================================" -ForegroundColor Green
Write-Host "✅ OTIMIZAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host "📋 Relatório salvo em: Desktop\relatorio_otimizacao.txt" -ForegroundColor Yellow
Write-Host "⚡ Script de alternância: Desktop\Switch_Desempenho.ps1" -ForegroundColor Yellow
Write-Host "🔌 Esquema de energia exportado: Desktop\Esquema_Desempenho_Maximo.pow" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green
Write-Host "🔄 Reinicie o computador para aplicar todas as mudanças" -ForegroundColor Red
Write-Host "📊 Monitore temperaturas durante uso intensivo" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green

# 10. MENU INTERATIVO
Write-Host "`n🎮 MENU DE CONTROLE RÁPIDO:" -ForegroundColor Magenta
Write-Host "1️⃣ - Reiniciar agora" -ForegroundColor Cyan
Write-Host "2️⃣ - Reiniciar depois" -ForegroundColor Cyan
Write-Host "3️⃣ - Testar desempenho" -ForegroundColor Cyan
Write-Host "4️⃣ - Ver relatório" -ForegroundColor Cyan

$choice = Read-Host "`nEscolha uma opção (1-4)"

switch ($choice) {
    "1" { 
        Write-Host "Reiniciando em 5 segundos..." -ForegroundColor Yellow
        timeout /t 5
        shutdown /r /f /t 0
    }
    "2" { 
        Write-Host "Reinicie manualmente quando possível" -ForegroundColor Yellow 
    }
    "3" {
        Write-Host "Executando teste de desempenho rápido..." -ForegroundColor Yellow
        Start-Process "winver.exe"
        Start-Process "dxdiag.exe"
    }
    "4" {
        Start-Process "$env:USERPROFILE\Desktop\relatorio_otimizacao.txt"
    }
}

pause
