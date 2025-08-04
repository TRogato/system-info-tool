@echo off
title Menu de Reparo e Ferramentas de TI - v2.1
color 0A
rem ***************************************************
rem *        Criado por Tiago Rogato           *
rem * Menu de Reparo e Ferramentas de TI - v2.1      *
rem * Data de Criacao: Agosto de 2024                 *
rem * Contato: t.rogato@gmail.com      *
rem ***************************************************

:menu
cls
echo ==================================================
echo     MENU DE REPARO E FERRAMENTAS DE TI - v2.1
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
echo 22. Sair
echo ==================================================
set /p opcao=Escolha uma opcao (1-22): 

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
if %opcao%==22 goto exit
echo Opcao invalida! Tente novamente.
pause
goto menu

:chkdsk
cls
rem * Verificacao de disco por Estefanio Correia *
echo Executando verificacao e reparo de disco...
echo Isso pode levar algum tempo. Por favor, aguarde.
chkdsk C: /f /r
echo Verificacao concluida!
pause
goto menu

:sfc
cls
rem * Reparo de sistema por Estefanio Correia *
echo Executando reparo de arquivos de sistema...
echo Isso pode levar algum tempo. Por favor, aguarde.
sfc /scannow
echo Reparo concluido!
pause
goto menu

:cleanup
cls
rem * Limpeza de temporarios por Estefanio Correia *
echo Limpando arquivos temporarios...
cleanmgr /sagerun:1
echo Limpeza concluida!
pause
goto menu

:memory
cls
rem * Diagnostico de memoria por Estefanio Correia *
echo Abrindo Diagnostico de Memoria do Windows...
mdsched.exe
echo Siga as instrucoes na tela para verificar a memoria.
pause
goto menu

:restore
cls
rem * Restauracao do sistema por Estefanio Correia *
echo Abrindo Restauracao do Sistema...
rstrui.exe
echo Siga as instrucoes na tela para restaurar o sistema.
pause
goto menu

:network
cls
rem * Teste de rede por Estefanio Correia *
echo Verificando conectividade de rede...
echo Testando conexao com google.com...
ping google.com -n 4
echo.
echo Testando conexao com gateway padrao...
ipconfig | findstr "Gateway"
echo.
echo Resultados exibidos acima.
pause
goto menu

:taskmgr
cls
rem * Gerenciador de tarefas por Estefanio Correia *
echo Abrindo Gerenciador de Tarefas...
taskmgr.exe
echo Use o Gerenciador de Tarefas para monitorar ou encerrar processos.
pause
goto menu

:driverbackup
cls
rem * Backup de drivers por Estefanio Correia *
echo Realizando backup de drivers...
echo Isso pode levar algum tempo. Por favor, aguarde.
mkdir C:\DriverBackup
dism /online /export-driver /destination:C:\DriverBackup
echo Backup de drivers concluido! Salvo em C:\DriverBackup
pause
goto menu

:updates
cls
rem * Atualizacoes do Windows por Estefanio Correia *
echo Verificando atualizacoes do Windows...
wuauclt /detectnow /updatenow
echo Verificacao de atualizacoes iniciada. Verifique o Windows Update para mais detalhes.
pause
goto menu

:sysinfo
cls
rem * Informacoes do sistema por Estefanio Correia *
echo Exibindo informacoes do sistema...
systeminfo
echo Informacoes exibidas acima.
pause
goto menu

:dnscache
cls
rem * Limpeza de DNS por Estefanio Correia *
echo Limpando cache DNS...
ipconfig /flushdns
echo Cache DNS limpo com sucesso!
pause
goto menu

:netrestart
cls
rem * Reinicio de rede por Estefanio Correia *
echo Reiniciando servicos de rede...
netsh winsock reset
netsh int ip reset
echo Servicos de rede reiniciados! Pode ser necessario reiniciar o computador.
pause
goto menu

:defrag
cls
rem * Desfragmentacao de disco por Estefanio Correia *
echo Executando desfragmentacao de disco...
defrag C: /O
echo Desfragmentacao concluida!
pause
goto menu

:usermgmt
cls
rem * Gerenciamento de usuarios por Estefanio Correia *
echo Abrindo Gerenciamento de Usuarios Locais...
lusrmgr.msc
echo Use a ferramenta para criar, editar ou excluir usuarios locais.
pause
goto menu

:dism
cls
rem * Integridade de imagem por Estefanio Correia *
echo Verificando integridade da imagem do Windows...
echo Isso pode levar algum tempo. Por favor, aguarde.
dism /online /cleanup-image /restorehealth
echo Verificacao e reparo concluidos!
pause
goto menu

:firewall
cls
rem * Configuracao de firewall por Estefanio Correia *
echo Abrindo configuracoes do Firewall do Windows...
firewall.cpl
echo Use a ferramenta para ativar ou desativar o firewall.
pause
goto menu

:eventlog
cls
rem * Visualizacao de logs por Estefanio Correia *
echo Abrindo Visualizador de Eventos...
eventvwr.msc
echo Use a ferramenta para verificar logs de erros e eventos do sistema.
pause
goto menu

:disktest
cls
rem * Teste de disco por Estefanio Correia *
echo Testando velocidade de disco...
winsat disk -drive C
echo Resultados exibidos acima.
pause
goto menu

:restorepoint
cls
rem * Criacao de ponto de restauracao por Estefanio Correia *
echo Criando ponto de restauracao...
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Ponto de Restauracao - Estefanio Correia", 100, 7
echo Ponto de restauracao criado com sucesso!
pause
goto menu

:customcmd
cls
rem * Comando personalizado por Estefanio Correia *
echo Abrindo prompt de comando para comandos personalizados...
cmd.exe
echo Prompt de comando fechado. Retornando ao menu.
pause
goto menu

:winget
cls
rem * Gerenciamento de aplicativos com Winget por Estefanio Correia *
echo ==================================================
echo     GERENCIADOR DE APLICATIVOS COM WINGET
echo ==================================================
echo 1. Listar aplicativos instalados
echo 2. Procurar por um aplicativo
echo 3. Instalar um aplicativo
echo 4. Atualizar todos os aplicativos
echo 5. Desinstalar um aplicativo
echo 6. Voltar ao Menu Principal
echo ==================================================
set /p wingetopcao=Escolha uma opcao (1-6): 

if %wingetopcao%==1 goto wingetlist
if %wingetopcao%==2 goto wingetsearch
if %wingetopcao%==3 goto wingetinstall
if %wingetopcao%==4 goto wingetupgrade
if %wingetopcao%==5 goto wingetuninstall
if %wingetopcao%==6 goto menu
echo Opcao invalida! Tente novamente.
pause
goto winget

:wingetlist
cls
rem * Listagem de aplicativos com Winget por Estefanio Correia *
echo Listando aplicativos instalados...
winget list
echo Lista exibida acima.
pause
goto winget

:wingetsearch
cls
rem * Pesquisa de aplicativos com Winget por Estefanio Correia *
set /p appsearch=Digite o nome do aplicativo para procurar: 
echo Procurando por "%appsearch%"...
winget search "%appsearch%"
echo Resultados exibidos acima.
pause
goto winget

:wingetinstall
cls
rem * Instalacao de aplicativos com Winget por Estefanio Correia *
set /p appinstall=Digite o ID ou nome do aplicativo para instalar: 
echo Instalando "%appinstall%"...
winget install "%appinstall%"
echo Instalacao concluida ou erro exibido acima.
pause
goto winget

:wingetupgrade
cls
rem * Atualizacao de aplicativos com Winget por Estefanio Correia *
echo Atualizando todos os aplicativos...
winget upgrade --all
echo Atualizacao concluida ou erros exibidos acima.
pause
goto winget

:wingetuninstall
cls
rem * Desinstalacao de aplicativos com Winget por Estefanio Correia *
set /p appuninstall=Digite o ID ou nome do aplicativo para desinstalar: 
echo Desinstalando "%appuninstall%"...
winget uninstall "%appuninstall%"
echo Desinstalacao concluida ou erro exibido acima.
pause
goto winget

:exit
cls
rem * Encerramento do script por Estefanio Correia *
echo Obrigado por usar o Menu de Reparo e Ferramentas de TI - v2.1!
echo Criado por Estefanio Correia.
pause
exit
