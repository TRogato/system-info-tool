# Menu de Reparo e Ferramentas de TI - v2.1

Um script em lote simples e eficaz para Windows, que consolida diversas ferramentas e comandos de TI úteis para diagnóstico, reparo e manutenção do sistema.

**Criado por:** Tiago Rogato (t.rogato@gmail.com)
**Desenvolvimento/Adaptação das Seções por:** Estefanio Correia
**Versão:** 2.1
**Data de Criação:** Agosto de 2024 (Original por Tiago Rogato)

## 🎨 Exemplo de Saída

![Screenshot do Terminal](/Suporte_menu/Menu_Ti.png)
## Sobre o Projeto
Este script foi desenvolvido para simplificar o acesso a várias ferramentas de sistema, eliminando a necessidade de lembrar comandos específicos ou navegar por múltiplos menus do Windows. É uma ferramenta robusta para técnicos de TI, usuários avançados ou qualquer pessoa que precise de uma maneira rápida de executar tarefas comuns de manutenção.

## Funcionalidades

O menu principal oferece as seguintes opções detalhadas:

1.  **Verificar e Reparar Disco (CHKDSK):** Executa `chkdsk C: /f /r` para verificar e reparar erros no disco `C:`.
2.  **Reparar Arquivos de Sistema (SFC):** Executa `sfc /scannow` para verificar e reparar arquivos de sistema corrompidos.
3.  **Limpar Arquivos Temporários:** Inicia o `cleanmgr` para limpeza de disco, removendo arquivos temporários e desnecessários.
4.  **Verificar Erros de Memória (Diagnóstico):** Abre o Diagnóstico de Memória do Windows (`mdsched.exe`) para testar a RAM do sistema.
5.  **Restaurar Sistema:** Abre a Restauração do Sistema (`rstrui.exe`) para reverter o sistema para um ponto anterior.
6.  **Verificar Conectividade de Rede (Ping/Teste):** Realiza um teste de ping para `google.com` e exibe o gateway padrão para verificar a conectividade de rede.
7.  **Gerenciar Processos (Task Manager):** Abre o Gerenciador de Tarefas (`taskmgr.exe`) para monitorar e gerenciar processos.
8.  **Backup de Drivers:** Cria um backup de todos os drivers instalados no sistema, salvando-os na pasta `C:\DriverBackup` usando DISM.
9.  **Verificar Atualizações do Windows:** Inicia o processo de detecção e download de atualizações do Windows.
10. **Informações do Sistema:** Exibe informações detalhadas sobre o hardware e software do sistema (`systeminfo`).
11. **Limpar Cache DNS:** Executa `ipconfig /flushdns` para limpar o cache de resolução de nomes DNS.
12. **Reiniciar Serviços de Rede:** Reseta as configurações de Winsock e IP, o que pode resolver problemas de conectividade de rede. (Pode exigir reinício do PC).
13. **Desfragmentar Disco:** Desfragmenta o disco `C:` (`defrag C: /O`) para otimizar o desempenho.
14. **Gerenciar Usuários Locais:** Abre o Gerenciamento de Usuários e Grupos Locais (`lusrmgr.msc`) para administrar contas de usuário e grupos.
15. **Verificar Integridade de Arquivos (DISM):** Executa `dism /online /cleanup-image /restorehealth` para verificar e reparar a imagem do Windows.
16. **Ativar/Desativar Firewall do Windows:** Abre as configurações do Firewall do Windows (`firewall.cpl`).
17. **Verificar Logs de Eventos:** Abre o Visualizador de Eventos (`eventvwr.msc`) para analisar logs de sistema, segurança, etc.
18. **Testar Velocidade de Disco:** Executa um teste de velocidade de leitura/escrita para o drive `C:` usando `winsat`.
19. **Criar Ponto de Restauração:** Cria um novo ponto de restauração do sistema para futura recuperação.
20. **Executar Comando Personalizado (CMD):** Abre um prompt de comando interativo para que o usuário possa executar comandos personalizados diretamente.
21. **Gerenciar Aplicativos com Winget:** Um submenu dedicado que oferece as seguintes opções:
    * **Listar aplicativos instalados:** Exibe uma lista de aplicativos gerenciais pelo Winget.
    * **Procurar por um aplicativo:** Permite buscar aplicativos no repositório Winget.
    * **Instalar um aplicativo:** Instala um aplicativo especificado pelo ID ou nome.
    * **Atualizar todos os aplicativos:** Atualiza todos os aplicativos instalados via Winget.
    * **Desinstalar um aplicativo:** Desinstala um aplicativo especificado pelo ID ou nome.
22. **Sair:** Encerra o script.

## Como Usar

1.  Baixe o arquivo `MENU-WINDOWS.bat` (ou o arquivo .bat correspondente à sua versão) do repositório.
2.  **Execute o arquivo `.bat` como Administrador.** Para fazer isso, clique com o botão direito do mouse no arquivo e selecione "Executar como administrador" para garantir que todas as funções tenham as permissões necessárias.
3.  Um menu interativo será exibido no Prompt de Comando.
4.  Digite o número correspondente à opção desejada e pressione `Enter`.
5.  Siga as instruções na tela para cada ferramenta selecionada.

### Executando via PowerShell (Alternativo)

Para usuários que preferem o PowerShell, você pode baixar e executar o script temporariamente. **Lembre-se de sempre revisar o código antes de executá-lo.**

1.  Abra o **PowerShell como Administrador**.
2.  Cole o seguinte código e pressione `Enter`:

    ```powershell
    # URL do arquivo BAT raw no GitHub
    $url = "https://raw.githubusercontent.com/TRogato/system-info-tool/main/Suporte_menu/MENU-WINDOWS.bat"

    # Caminho para salvar o arquivo temporariamente (ex: na pasta Temp do usuário)
    $filePath = Join-Path $env:TEMP "MENU-WINDOWS.bat"

    Write-Host "Baixando o script $url para $filePath..."

    # Baixa o arquivo
    try {
    Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction Stop
    Write-Host "Download concluído."

    # Executa o arquivo BAT. É crucial executar como administrador para que o menu funcione completamente.
    Write-Host "Executando o script. Por favor, certifique-se de executar esta janela do PowerShell como ADMINISTRADOR."
    Start-Process -FilePath $filePath -Wait
    
    Write-Host "Script finalizado."
    }
    catch {
    Write-Error "Erro ao baixar ou executar o script: $($_.Exception.Message)"
    Write-Host "Verifique sua conexão com a internet e se o link do GitHub está correto."
    }

    # Opcional: Remover o arquivo temporário após a execução
    # Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
    ```

## Pré-requisitos

* **Sistema Operacional:** Microsoft Windows (testado e otimizado para Windows 10/11).
* **Privilégios de Administrador:** É **essencial** executar o script como administrador para que a maioria das ferramentas funcione corretamente.
* **Winget (Gerenciador de Pacotes do Windows):** As opções do menu "Gerenciar Aplicativos com Winget" (Opção 21) exigem que o Winget esteja instalado. Ele geralmente vem pré-instalado no Windows 11 e em versões recentes do Windows 10. Caso não tenha, ele pode ser obtido na Microsoft Store ou como parte do Instalador de Aplicativos (App Installer).

## Contato

Para dúvidas, sugestões ou suporte:

* **Criador Original:** Tiago Rogato (t.rogato@gmail.com)


## Licença

Este projeto é de código aberto. Sinta-se à vontade para usar, modificar e distribuir.


---
