# Cria tarefa agendada para verificar mapeamentos de rede
# Compatível com Windows 7, 8, 8.1, 10 e 11
# Execute como Administrador

$osVersion = [Environment]::OSVersion.Version
$isWin8OrLater = $osVersion -ge (New-Object 'Version' 6,2)

$restoreScriptPath = "C:\ProgramData\Network\RestoreMappings.ps1"
$restoreDir = Split-Path $restoreScriptPath -Parent

if (-not (Test-Path $restoreDir)) {
    New-Item -ItemType Directory -Path $restoreDir -Force | Out-Null
}

if ($isWin8OrLater) {
    # Windows 8+ - usa cmdlets do ScheduledTasks
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -File `"$restoreScriptPath`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

    Register-ScheduledTask -TaskName "RestoreNetworkMappings" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Restaura mapeamentos de rede apos inicializacao" -Force
} else {
    # Windows 7 - usa schtasks.exe
    $xmlPath = "$env:TEMP\RestoreNetworkMappings.xml"
    $xmlContent = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Restaura mapeamentos de rede apos inicializacao</Description>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <Enabled>true</Enabled>
    <AllowStartOnBatteries>true</AllowStartOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>true</RunOnlyIfNetworkAvailable>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>PowerShell.exe</Command>
      <Arguments>-WindowStyle Hidden -File "$restoreScriptPath"</Arguments>
    </Exec>
  </Actions>
</Task>
"@
    Set-Content -Path $xmlPath -Value $xmlContent -Force
    schtasks /Create /TN "RestoreNetworkMappings" /XML $xmlPath /F | Out-Null
    Remove-Item -Path $xmlPath -Force -ErrorAction SilentlyContinue
}

Write-Host "Tarefa agendada 'RestoreNetworkMappings' criada com sucesso!" -ForegroundColor Green