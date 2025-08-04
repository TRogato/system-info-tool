@echo off
title Menu de Reparo e Ferramentas de TI - v2.2
color 0A
set LOGFILE=C:\TI_Tools_Log.txt
echo [%date% %time%] Script iniciado >> %LOGFILE%

rem ***************************************************
rem *        Criado por Tiago Rogato           *
rem * Menu de Reparo e Ferramentas de TI - v2.2      *
rem * Data de Atualizacao: Agosto de 2025             *
rem * Contato: t.rogato@gmail.com      *
rem ***************************************************

:: Verifica se o script está sendo executado como administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Este script requer privilegios administrativos. Execute como administrador.
    echo [%date% %time%] Erro: Script nao executado como administrador >> %LOGFILE%
    pause
    exit
)

:pause_and_return
pause
goto menu

:menu
cls
echo ==================================================
echo     MENU DE REPARO E FERRAMENTAS DE TI - v2.2
echo     Criado por Tiago Rogato
echo ==================================================
echo 1.  Verificar e Reparar Disco (CHKDSK)
echo 2.  Reparar Arquivos de Sistema (SFC)
echo 3.  Limpar Arquivos Temporarios
echo 4.  Verificar Erros de Memoria (Diagnostico)
echo 5.  Restaurar Sistema
echo 6.  Verificar Conectividade de Rede (Ping/Teste)
echo 7.  Gerenciar Processos (Task Manager)
echo 8.  Backup de Drivers
echo 9.  Verificar Atualizacoes do Windows
echo 10. Informacoes do Sistema
echo 11. Limpar Cache DNS
echo 12. Reiniciar Servicos de Rede
echo 13. Desfragmentar Disco
echo 14. Gerenciar Usuarios Locais
echo 15. Verificar Integridade de Arquivos (DISM)
echo 16. Ativar/Desativar Firewall do Windows
echo 17. Verificar Logs de Eventos
echo 18. Testar Velocidade de Disco
echo 19. Criar Ponto de Restauracao
echo 20. Executar Comando Personalizado (CMD)
echo 21. Gerenciar Aplicativos com Winget
echo 22. Reiniciar Computador
echo 23. Sair
echo ==================================================
set /p opcao=Escolha uma opcao (1-23): 
if not defined opcao (
    echo Entrada vazia! Tente novamente.
    echo [%date% %time%] Erro: Entrada vazia no menu principal >> %LOGFILE%
    call :pause_and_return
)
if %opcao% LSS 1 (
    echo Opcao invalida! Tente novamente.
    echo [%date% %time%] Erro: Opcao invalida %opcao% no menu principal >> %LOGFILE%
    call :pause_and_return
)
if %opcao% GTR 23 (
    echo Opcao invalida! Tente novamente.
    echo [%date% %time%] Erro: Opcao invalida %opcao% no menu principal >> %LOGFILE%
    call :pause_and_return
)
if %opcao%==1 goto chkdsk
if %opcao%==2 goto sfc
if %opcao%==3 goto cleanup
if %opcao%==4 goto memory
if %opcao%==5 goto restore
if %opcao%==6 goto network
if %opcao%==7 goto taskmgr
if %opcao%==8 goto driverbackup
if %opcao%==9 goto updates
if %opcao%==10 goto sysinfo
if %opcao%==11 goto dnscache
if %opcao%==12 goto netrestart
if %opcao%==13 goto defrag
if %opcao%==14 goto usermgmt
if %opcao%==15 goto dism
if %opcao%==16 goto firewall
if %opcao%==17 goto eventlog
if %opcao%==18 goto disktest
if %opcao%==19 goto restorepoint
if %opcao%==20 goto customcmd
if %opcao%==21 goto winget
if %opcao%==22 goto reboot
if %opcao%==23 goto exit

:chkdsk
cls
set /p drive=Digite a letra da unidade (ex.: C): 
if not defined drive set drive=C
echo Executando verificacao e reparo de disco em %drive%:...
echo ATENCAO: Isso pode levar muito tempo e exige reinicializacao. Deseja continuar? (S/N)
set /p confirm=Confirme (S/N): 
if /i "%confirm%"=="S" (
    echo [%date% %time%] Executando chkdsk %drive%: /f /r >> %LOGFILE%
    chkdsk %drive%: /f /r >> %LOGFILE% 2>&1
    if %errorlevel%==0 (
        echo Verificacao concluida com sucesso!
    ) else (
        echo Erro ao executar chkdsk. Verifique o log em %LOGFILE%.
    )
) else (
    echo Operacao cancelada.
    echo [%date% %time%] Operacao chkdsk cancelada >> %LOGFILE%
)
call :pause_and_return

:sfc
cls
echo Executando reparo de arquivos de sistema...
echo ATENCAO: Isso pode levar algum tempo. Deseja continuar? (S/N)
set /p confirm=Confirme (S/N): 
if /i "%confirm%"=="S" (
    echo [%date% %time%] Executando sfc /scannow >> %LOGFILE%
    sfc /scannow >> %LOGFILE% 2>&1
    if %errorlevel%==0 (
        echo Reparo concluido com sucesso!
    ) else (
        echo Erro ao executar sfc. Verifique o log em %LOGFILE%.
    )
) else (
    echo Operacao cancelada.
    echo [%date% %time%] Operacao sfc cancelada >> %LOGFILE%
)
call :pause_and_return

:cleanup
cls
echo Limpando arquivos temporarios...
echo [%date% %time%] Executando cleanmgr /sagerun:1 >> %LOGFILE%
cleanmgr /sagerun:1 >> %LOGFILE% 2>&1
if %errorlevel%==0 (
    echo Limpeza concluida com sucesso!
) else (
    echo Erro ao executar cleanmgr. Verifique o log em %LOGFILE%.
)
call :pause_and_return

:memory
cls
echo Abrindo Diagnostico de Memoria do Windows...
echo [%date% %time%] Abrindo mdsched.exe >> %LOGFILE%
mdsched.exe
echo Siga as instrucoes na tela para verificar a memoria.
call :pause_and_return

:restore
cls
echo Abrindo Restauracao do Sistema...
echo [%date% %time%] Abrindo rstrui.exe >> %LOGFILE%
rstrui.exe
echo Siga as instrucoes na tela para restaurar o sistema.
call :pause_and_return

:network
cls
echo Verificando conectividade de rede...
echo Testando conexao com google.com...
echo [%date% %time%] Executando ping google.com -n 4 >> %LOGFILE%
ping google.com -n 4 >> %LOGFILE% 2>&1
echo.
echo Testando conexao com gateway padrao...
echo [%date% %time%] Executando ipconfig | findstr "Gateway" >> %LOGFILE%
ipconfig | findstr "Gateway" >> %LOGFILE% 2>&1
echo Resultados exibidos acima.
call :pause_and_return

:taskmgr
cls
echo Abrindo Gerenciador de Tarefas...
echo [%date% %time%] Abrindo taskmgr.exe >> %LOGFILE%
taskmgr.exe
echo Use o Gerenciador de Tarefas para monitorar ou encerrar processos.
call :pause_and_return

:driverbackup
cls
echo Realizando backup de drivers...
echo Isso pode levar algum tempo. Por favor, aguarde.
echo [%date% %time%] Criando diretorio C:\DriverBackup >> %LOGFILE%
mkdir C:\DriverBackup >> %LOGFILE% 2>&1
echo [%date% %time%] Executando dism /online /export-driver /destination:C:\DriverBackup >> %LOGFILE%
dism /online /export-driver /destination:C:\DriverBackup >> %LOGFILE% 2>&1
if %errorlevel%==0 (
    echo Backup de drivers concluido! Salvo em C:\DriverBackup
) else (
    echo Erro ao executar backup de drivers. Verifique o log em %LOGFILE%.
)
call :pause_and_return

:updates
cls
echo Verificando atualizacoes do Windows...
echo [%date% %time%] Executando verificacao de atualizacoes via PowerShell >> %LOGFILE%
powershell -command "Install-Module PSWindowsUpdate -Force -SkipPublisherCheck; Get-WUInstall -AcceptAll -AutoReboot" >> %LOGFILE% 2>&1
if %errorlevel%==0 (
    echo Verificacao de atualizacoes iniciada com sucesso.
) else (
    echo Erro ao verificar atualizacoes. Verifique o log em %LOGFILE%.
)
call :pause_and_return

:sysinfo
cls
echo Exibindo informacoes do sistema...
echo [%date% %time%] Executando systeminfo >> %LOGFILE%
systeminfo >> %LOGFILE% 2>&1
echo Informacoes exibidas acima.
call :pause_and_return

:dnscache
cls
echo Limpando cache DNS...
echo [%date% %time%] Executando ipconfig /flushdns >> %LOGFILE%
ipconfig /flushdns >> %LOGFILE% 2>&1
if %errorlevel%==0 (
    echo Cache DNS limpo com sucesso!
) else (
    echo Erro ao limpar cache DNS. Verifique o log em %LOGFILE%.
)
call :pause_and_return

:netrestart
cls
echo ATENCAO: Reiniciar os servicos de rede pode interromper conexoes ativas. Deseja continuar? (S/N)
set /p confirm=Confirme (S/N): 
if /i "%confirm%"=="S" (
    echo [%date% %time%] Executando netsh winsock reset >> %LOGFILE%
    netsh winsock reset >> %LOGFILE% 2>&1
    echo [%date% %time%] Executando netsh int ip reset >> %LOGFILE%
    netsh int ip reset >> %LOGFILE% 2>&1
    if %errorlevel%==0 (
        echo Servicos de rede reiniciados! Pode ser necessario reiniciar o computador.
    ) else (
        echo Erro ao reiniciar servicos de rede. Verifique o log em %LOGFILE%.
    )
) else (
    echo Operacao cancelada.
    echo [%date% %time%] Operacao netrestart cancelada >> %LOGFILE%
)
call :pause_and_return

:defrag
cls
set /p drive=Digite a letra da unidade (ex.: C): 
if not defined drive set drive=C
echo Executando desfragmentacao de disco em %drive%:...
echo [%date% %time%] Executando defrag %drive%: /O >> %LOGFILE%
defrag %drive%: /O >> %LOGFILE% 2>&1
if %errorlevel%==0 (
    echo Desfragmentacao concluida com sucesso!
) else (
    echo Erro ao desfragmentar disco. Verifique o log em %LOGFILE%.
)
call :pause_and_return

:usermgmt
cls
echo Abrindo Gerenciamento de Usuarios Locais...
echo [%date% %time%] Abrindo lusrmgr.msc >> %LOGFILE%
lusrmgr.msc
echo Use a ferramenta para criar, editar ou excluir usuarios locais.
call :pause_and_return

:dism
cls
echo Verificando integridade da imagem do Windows...
echo ATENCAO: Isso pode levar algum tempo. Deseja continuar? (S/N)
set /p confirm=Confirme (S/N): 
if /i "%confirm%"=="S" (
    echo [%date% %time%] Executando dism /online /cleanup-image /restorehealth >> %LOGFILE%
    dism /online /cleanup-image /restorehealth >> %LOGFILE% 2>&1
    if %errorlevel%==0 (
        echo Verificacao e reparo concluidos com sucesso!
    ) else (
        echo Erro ao executar DISM. Verifique o log em %LOGFILE%.
    )
) else (
    echo Operacao cancelada.
    echo [%date% %time%] Operacao DISM cancelada >> %LOGFILE%
)
call :pause_and_return

:firewall
cls
echo Abrindo configuracoes do Firewall do Windows...
echo [%date% %time%] Abrindo firewall.cpl >> %LOGFILE%
firewall.cpl
echo Use a ferramenta para ativar ou desativar o firewall.
call :pause_and_return

:eventlog
cls
echo Abrindo Visualizador de Eventos...
echo [%date% %time%] Abrindo eventvwr.msc >> %LOGFILE%
eventvwr.msc
echo Use a ferramenta para verificar logs de erros e eventos do sistema.
call :pause_and_return

:disktest
cls
echo Testando velocidade de disco...
echo [%date% %time%] Executando winsat disk -drive C >> %LOGFILE%
winsat disk -drive C >> %LOGFILE% 2>&1
echo Resultados exibidos acima. Para resultados mais detalhados, considere usar CrystalDiskMark.
call :pause_and_return

:restorepoint
cls
echo Criando ponto de restauracao...
echo [%date% %time%] Executando wmic.exe para criar ponto de restauracao >> %LOGFILE%
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Ponto de Restauracao - Tiago Rogato", 100, 7 >> %LOGFILE% 2>&1
if %errorlevel%==0 (
    echo Ponto de restauracao criado com sucesso!
) else (
    echo Erro ao criar ponto de restauracao. Verifique o log em %LOGFILE%.
)
call :pause_and_return

:customcmd
cls
echo Abrindo prompt de comando para comandos personalizados...
echo [%date% %time%] Abrindo cmd.exe >> %LOGFILE%
cmd.exe
echo Prompt de comando fechado. Retornando ao menu.
call :pause_and_return

:winget
cls
echo ==================================================
echo     GERENCIADOR DE APLICATIVOS COM WINGET
echo ==================================================
echo 1. Listar aplicativos instalados
echo 2. Procurar por um aplicativo
echo 3. Instalar um aplicativo
echo 4. Atualizar todos os aplicativos
echo 5. Desinstalar um aplicativo
echo 6. Listar atualizacoes disponiveis
echo 7. Verificar versao do Winget
echo 8. Voltar ao Menu Principal
echo ==================================================
set /p wingetopcao=Escolha uma opcao (1-8): 
if not defined wingetopcao (
    echo Entrada vazia! Tente novamente.
    echo [%date% %time%] Erro: Entrada vazia no menu winget >> %LOGFILE%
    call :pause_and_return
)
if %wingetopcao% LSS 1 (
    echo Opcao invalida! Tente novamente.
    echo [%date% %time%] Erro: Opcao invalida %wingetopcao% no menu winget >> %LOGFILE%
    call :pause_and_return
)
if %wingetopcao% GTR 8 (
    echo Opcao invalida! Tente novamente.
    echo [%date% %time%] Erro: Opcao invalida %wingetopcao% no menu winget >> %LOGFILE%
    call :pause_and_return
)
if %wingetopcao%==1 goto wingetlist
if %wingetopcao%==2 goto wingetsearch
if %wingetopcao%==3 goto wingetinstall
if %wingetopcao%==4 goto wingetupgrade
if %wingetopcao%==5 goto wingetuninstall
if %wingetopcao%==6 goto wingetupgradelist
if %wingetopcao%==7 goto wingetversion
if %wingetopcao%==8 goto menu

:wingetlist
cls
echo Listando aplicativos instalados...
echo [%date% %time%] Executando winget list >> %LOGFILE%
winget list >> %LOGFILE% 2>&1
echo Lista exibida acima.
call :pause_and_return

:wingetsearch
cls
set /p appsearch=Digite o nome do aplicativo para procurar: 
if not defined appsearch (
    echo Entrada vazia! Tente novamente.
    echo [%date% %time%] Erro: Entrada vazia em winget search >> %LOGFILE%
    call :pause_and_return
)
echo Procurando por "%appsearch%"...
echo [%date% %time%] Executando winget search "%appsearch%" >> %LOGFILE%
winget search "%appsearch%" >> %LOGFILE% 2>&1
echo Resultados exibidos acima.
call :pause_and_return

:wingetinstall
cls
set /p appinstall=Digite o ID ou nome do aplicativo para instalar: 
if not defined appinstall (
    echo Entrada vazia! Tente novamente.
    echo [%date% %time%] Erro: Entrada vazia em winget install >> %LOGFILE%
    call :pause_and_return
)
echo Instalando "%appinstall%"...
echo [%date% %time%] Executando winget install "%appinstall%" >> %LOGFILE%
winget install "%appinstall%" >> %LOGFILE% 2>&1
if %errorlevel%==0 (
    echo Instalacao concluida com sucesso!
) else (
    echo Erro ao instalar aplicativo. Verifique o log em %LOGFILE%.
)
call :pause_and_return

:wingetupgrade
cls
echo Atualizando todos os aplicativos...
echo [%date% %time%] Executando winget upgrade --all >> %LOGFILE%
winget upgrade --all >> %LOGFILE% 2>&1
if %errorlevel%==0 (
    echo Atualizacao concluida com sucesso!
) else (
    echo Erro ao atualizar aplicativos. Verifique o log em %LOGFILE%.
)
call :pause_and_return

:wingetuninstall
cls
set /p appuninstall=Digite o ID ou nome do aplicativo para desinstalar: 
if not defined appuninstall (
    echo Entrada vazia! Tente novamente.
    echo [%date% %time%] Erro: Entrada vazia em winget uninstall >> %LOGFILE%
    call :pause_and_return
)
echo Desinstalando "%appuninstall%"...
echo [%date% %time%] Executando winget uninstall "%appuninstall%" >> %LOGFILE%
winget uninstall "%appuninstall%" >> %LOGFILE% 2>&1
if %errorlevel%==0 (
    echo Desinstalacao concluida com sucesso!
) else (
    echo Erro ao desinstalar aplicativo. Verifique o log em %LOGFILE%.
)
call :pause_and_return

:wingetupgradelist
cls
echo Listando atualizacoes disponiveis...
echo [%date% %time%] Executando winget upgrade >> %LOGFILE%
winget upgrade >> %LOGFILE% 2>&1
echo Lista exibida acima.
call :pause_and_return

:wingetversion
cls
echo Verificando versao do Winget...
echo [%date% %time%] Executando winget --version >> %LOGFILE%
winget --version >> %LOGFILE% 2>&1
echo Versao exibida acima.
call :pause_and_return

:reboot
cls
echo Deseja reiniciar o computador agora? (S/N)
set /p confirm=Confirme (S/N): 
if /i "%confirm%"=="S" (
    echo [%date% %time%] Reiniciando o computador >> %LOGFILE%
    shutdown /r /t 10
    echo Computador sera reiniciado em 10 segundos.
) else (
    echo Operacao cancelada.
    echo [%date% %time%] Operacao de reinicio cancelada >> %LOGFILE%
)
call :pause_and_return

:exit
cls
echo Obrigado por usar o Menu de Reparo e Ferramentas de TI - v2.2!
echo Criado por Tiago Rogato.
echo [%date% %time%] Script encerrado >> %LOGFILE%
pause
exit