Solução Manual Alternativa
Se o script não resolver, tente estas etapas manuais:

1. Verificar e corrigir manualmente o registro:
Pressione Win + R, digite regedit e pressione Enter

Navegue até: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName

Verifique se o valor "ComputerName" corresponde ao nome real do computador
````
Navegue até: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters
````
Procure por qualquer valor chamado "NameCache", "Domain" ou "SessionCache" e exclua-os

Reinicie o computador

2. Verificar SMB (Server Message Block):
Abra "Recursos do Windows" no Painel de Controle

Certifique-se de que "Suporte para compartilhamento de arquivos SMB 1.0/CIFS" está desativado
````
Ative "Cliente SMB 1.0/CIFS" e "Servidor SMB 1.0/CIFS" temporariamente
````
Reinicie e teste a conexão

Se funcionar, desative-os novamente e reinicie

3. Criar um novo perfil de rede:
Abra "Configurações de Rede e Internet"
````
Vá para "Estado" > "Configurações de rede" > "Configurações de compartilhamento avançadas"
````
Clique em "Redefinir configurações de rede" na parte inferior

Reinicie o computador

Verificação Final
Após executar o script e reiniciar, verifique se o problema foi resolvido com estes comandos:
````
powershell
Test-NetConnection -ComputerName LOCALHOST
````
Get-SmbConnection
````
nbtstat -n
````
Se o problema persistir, pode indicar uma corrupção mais profunda do sistema que pode exigir um reparo de instalação do Windows ou restauração do sistema.
