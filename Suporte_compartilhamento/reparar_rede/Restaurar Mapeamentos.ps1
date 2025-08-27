#Se o problema persistir após executar o script acima, 
#crie uma tarefa agendada que verifica e restaura os mapeamentos após cada inicialização:

# Criar tarefa agendada para verificar mapeamentos de rede
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -File `"C:\ProgramData\Network\RestoreMappings.ps1`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "RestoreNetworkMappings" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Restaura mapeamentos de rede após inicialização" -Force