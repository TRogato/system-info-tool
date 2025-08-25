# Script para configurar o Windows 10/11 para máximo desempenho de energia
# Deve ser executado como administrador

# Verifica se o script está sendo executado como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Este script precisa ser executado como administrador. Inicie o PowerShell como administrador e tente novamente."
    exit
}

# Ativa o plano de energia "Alto Desempenho"
$highPerf = powercfg /list | Select-String "Alto desempenho"
if ($highPerf) {
    $guid = ($highPerf -split '\s+')[3]
    powercfg /setactive $guid
    Write-Host "Plano de energia 'Alto Desempenho' ativado."
} else {
    Write-Host "Plano de energia 'Alto Desempenho' não encontrado. Criando um novo plano..."
    powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    Start-Sleep -Seconds 2
    $newPlan = powercfg /list | Select-String "Alto desempenho"
    if ($newPlan) {
        $guid = ($newPlan -split '\s+')[3]
        powercfg /setactive $guid
        Write-Host "Novo plano de energia 'Alto Desempenho' criado e ativado."
    } else {
        Write-Host "Erro ao criar o plano de energia."
        exit
    }
}

# Configurações adicionais para máximo desempenho
# Desativa hibernação
powercfg /hibernate off

# Configura tempo de desligamento do monitor e suspensão para "Nunca"
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0

# Desativa economia de energia no disco rígido
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0

# Configura desempenho máximo do processador
powercfg /setacvalueindex $guid SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg /setdcvalueindex $guid SUB_PROCESSOR PROCTHROTTLEMIN 100

# Aplica as configurações
powercfg /setactive $guid

Write-Host "Configurações de energia otimizadas para máximo desempenho."
Write-Host "As alterações foram aplicadas com sucesso!"
