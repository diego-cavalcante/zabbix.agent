#####################################################################################################
# Script Title:   ZAWIN                                                                             #
# Script Descr:   ZABBIX AGENT INSTALL WINDOWS                                                      #
# Script Name:    zabbix.agent.install.win.ps1                                                      #
# Author:         Diego Cavalcante                                                                  #
# E-Mail:         diego@suportecavalcante.com.br                                                    #
# Telegram:       @diego_cavalcante                                                                 #
# Description BR: Instalação e configuração interativa do agente zabbix windows.                    #
#                 Instalação, upgrade/downgrade e remoção do agente zabbix windows.                 #
# Description EN: Installation and interactive configuration of the zabbix windows agent.           #
#                 Installation, upgrade/downgrade and removal of the zabbix windows agent.          #
# Help:           Execute .\zabbix.agent.install.win.ps1 para informacoes de uso.                   #
#                 Run .\zabbix.agent.install.win.ps1 for usage information.                         #
# Create v1.0.0:  29/08/2017 17:55:32 (Script básico de instalação do zabbix agent)                 #
# Update v1.1.0:  30/08/2017 22:14:49 (ADD campos pasta de instalação, porta, firewall)             #
# Update v1.2.0:  31/08/2017 11:07:28 (ADD Opção que remove o agente + backup)                      #
# Update v1.3.0:  31/08/2017 21:10:58 (ADD Seleciona versão de instalação/upgrade/downgrade)        #
# Update v1.4.0:  01/09/2017 14:12:44 (ADD Teste de conectividade na porta 10051 do server/proxy)   #
# Update v1.5.0:  02/09/2017 08:07:23 (ADD Opção LOCALCHANGE upgrade/downgrade do zabbix agente)    #
# Update v1.6.0:  05/09/2017 10:10:12 (ADD Verifica se a versão escolhida existe no instalador)     #
# Update v1.7.0:  08/12/2017 23:55:10 (ADD Substitui no zabbix_agentd.conf tudo que foi digitado)   #
# Update v1.8.0:  09/12/2017 07:14:22 (ADD Verifica em todas as opções a versão escolhida)          #
# Update v1.9.0:  11/12/2017 19:10:37 (@Mário Alves - Instalação via compartilhamento de rede)      #
# Update v1.9.1:  16/12/2017 22:34:10 (@amarodefarias - Correção diretórios com espaços)            #
# Update v1.9.2:  11/11/2018 15:22:08 (ADD Correções e validações de campos em branco)              #
# Update v1.9.3:  12/11/2018 09:15:10 (ADD valores default em todos os campos)                      #
# Update v2.0.0:  13/11/2018 14:04:18 (ADD help ao executar o script sem parêmetros)                #
#####################################################################################################

# REQUIREMENTS ######################################################################################
# Powershell Unrestricted, execute Powershell for Administrator.                                    #
# END ###############################################################################################

# PARAMETERS ########################################################################################
Param(                                                                                              #
  [string]$select                                                                                   #
)                                                                                                   #
#####################################################################################################

# GLOBAL VARIABLES ##################################################################################
$VERS = "2.0.0"                                                                                     #
$VERCREATE = "29/08/2017"                                                                           #
$VERUPDATE = "13/11/2018"                                                                           #
$VERSCRIPTAUTHOR = "Diego Cavalcante"                                                               #
#####################################################################################################

# DEFAULT VALUES ####################################################################################
$DEFAULTFOLDER    = "zabbix"                                                                        #
$DEFAULTVERSION   = "4.0.0"                                                                         #
$DEFAULTSERVER    = "192.168.1.100"                                                                 #
$DEFAULTHOST      = "TESTE"                                                                         #
$DEFAULTTIMEOUT   = "30"                                                                            #
$DEFAULTREMOTECOM = "1"                                                                             #
$DEFAULTREMOTELOG = "0"                                                                             #
$DEFAULTPORT      = "10050"                                                                         #
$DEFAULTPORTCON   = "10051"                                                                         #
#####################################################################################################

# NETWORK SHARING VARIABLES #########################################################################
$INSTALADOR = "zabbix.agent.install.win"                                                            #
$SRV = "\\192.168.1.100"                                                                            #
$SHARE = "$SRV\compartilhamento\$INSTALADOR"                                                        #
#####################################################################################################

# OPTION LOCALINSTALL ###############################################################################
# BR - Instalação do zabbix agente windows x.x.x local.                                             #
# EN - Installation of zabbix agent windows x.x.x local.                                            #
#####################################################################################################

if ( $select -like 'LOCALINSTALL' )
{   
   cls
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "= Verificando existência do zabbix agente no host, aguarde um momento...                                        ="
   Write-Host "================================================================================================================="
   #VERIFICA SE O SERVIÇO ZABBIX AGENT JA EXISTE
   $VERIFICA_INSTALL = Get-Service "Zabbix Agent" -ErrorAction SilentlyContinue | Measure-Object -Line | select-object Lines | select-object -ExpandProperty Lines
   #VERIFICA A ARQUITETURA DO S.O "X86" OU "X64"
   $VERIFICA_SO = Test-Path "c:\Program Files (x86)" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #VERIFICA WINDOWS VERSÃO
   $WINDOWS_SO = (Get-WmiObject -class Win32_OperatingSystem).Caption
   #VERIFICA WINDOWS ARQUITETURA
   $WINDOWS_ARQ = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

   #IF VERIFICA_INSTALL
   If ($VERIFICA_INSTALL –eq 1) {
   Start-Sleep -s 2
   cls
   Write-Host "================================================================================================================="
   Write-Host "ERRO: Zabbix agente já existe, instalação cancelada."
   Write-Host "ERRO: Se deseja remover o zabbix agente por completo, execute o script com o parâmetro LOCALREMOVE"
   Write-Host "ERRO: Se deseja realizar upgrade/downgrade, execute o script com o parâmetro LOCALCHANGE"
   Write-Host "================================================================================================================="
   Write-Host ""

   #ELSE VERIFICA_INSTALL
   } else {

   #IF VERIFICA_SO
   If ($VERIFICA_SO –eq 1) {

   #1º Parte IF VERIFICA_SO = 1 = Windows 64 Bits
   Start-Sleep -s 2
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __  NAME: ZAWIN ====================================================="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /  DESCRIPTION: ZABBIX AGENT INSTALL WINDOWS ======================="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /   VERSION: $VERS =================================================="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /    CREATE: $VERCREATE =============================================="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/     UPDATE: $VERUPDATE =============================================="
   Write-Host "=                                               AUTHOR: $VERSCRIPTAUTHOR ========================================"
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                        INSTALL: Bem vindo ao assistente de instalação do zabbix agente                        ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""
   cls

   Write-Host "================================================================================================================="
   Write-Host "INFO: Zabbix agente não encontrado, iniciando instalação."
   Write-Host "INFO: Detectado $WINDOWS_SO$WINDOWS_ARQ, continuando instalação."
   Write-Host "INFO: Configurando zabbix agente."
   Write-Host "INFO: Qual a versão do zabbix agente deseja instalar? Ex: 3.0.x, 3.2.x, 3.4.x ou 4.0.x"
   Write-Host "INFO: Default $DEFAULTVERSION"
   Write-Host "================================================================================================================="
   Write-Host ""
   $VERSION = if(($result = Read-Host "Versão") -eq ''){"$DEFAULTVERSION"}else{$result}
   Write-Host ""

   $VERIFICAVERSION = Test-Path "c:\$INSTALADOR\versao\$VERSION" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #IF VERIFICAVERSION = 0 = NÃO ENCONTRADO
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "================================================================================================================="
   Write-Host "ERRO: Desculpe, a versão escolhida não foi encontrada no instalador."
   Write-Host "ERRO: A instalação foi cancelada."
   Write-Host "ERRO: Verifique as versões disponíveis em c:\$INSTALADOR\versao\"
   Write-Host "================================================================================================================="
   Write-Host ""

   #ELSE VERIFICAVERSION = 1 = ENCONTRADO
   } else {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Qual o diretório onde deseja instalar o zabbix agente?"
   Write-Host "INFO: Digite apenas o diretório, a raiz c:\ será preenchida automaticamente."
   Write-Host "INFO: Digite apenas o diretório sem a \ no final."
   Write-Host "INFO: Ex: digitando o diretório zabbix, o agente será instalado em c:\zabbix"
   Write-Host "INFO: Default c:\$DEFAULTFOLDER"
   Write-Host "================================================================================================================="
   Write-Host ""
   $PASTA = if(($result = Read-Host "c:\") -eq ''){"$DEFAULTFOLDER"}else{$result}
   md "c:\$PASTA\monitoramento\scripts\"
   md "c:\$PASTA\monitoramento\userparameters\"
   Copy-Item "c:\$INSTALADOR\versao\$VERSION\win64\*.*" -Destination "c:\$PASTA\" -Recurse
   Copy-Item "c:\$INSTALADOR\monitoramento\scripts\*.*" -Destination "c:\$PASTA\monitoramento\scripts\" -Recurse
   Copy-Item "c:\$INSTALADOR\monitoramento\userparameters\*.*" -Destination "c:\$PASTA\monitoramento\userparameters\" -Recurse
   copy-Item "c:\$INSTALADOR\zabbix_agentd.conf" -Destination "c:\$PASTA" -Recurse
   Rename-Item "c:\$PASTA\zabbix_agentd.conf" "c:\$PASTA\zabbix_agentd.conf.txt"

   cls
   Write-Host "================================================================================================================="
   Write-Host "=                                          Configurando zabbix agente                                           ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Server/ServerActive = Qual o IP/DNS do zabbix server/zabbix proxy?"
   Write-Host "INFO: Default $DEFAULTSERVER"
   Write-Host "================================================================================================================="
   $IP         = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTSERVER"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: Hostname = Qual o nome do host?"
   Write-Host "INFO: Default $DEFAULTHOST"
   Write-Host "================================================================================================================="
   $HOSTNAME   = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTHOST"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: Timeout = Qual o timeout do host? Entre 0 e 30 segundos?"
   Write-Host "INFO: Default $DEFAULTTIMEOUT"
   Write-Host "================================================================================================================="
   $TIMEOUT    = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTTIMEOUT"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: EnableRemoteCommands = Deseja habilitar o comando remoto no host? (0)desabilita (1)habilita"
   Write-Host "INFO: Default ($DEFAULTREMOTECOM)habilita"
   Write-Host "================================================================================================================="
   $REMOTE     = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTREMOTECOM"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: LogRemoteCommands = Deseja habilitar o log do comando remoto no host? (0)desabilita (1)habilita"
   Write-Host "INFO: Default ($DEFAULTREMOTELOG)desabilita"
   Write-Host "================================================================================================================="
   $REMOTELOG  = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTREMOTELOG"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: ListenPort = Qual a porta de comunicação do zabbix agent?"
   Write-Host "INFO: Default $DEFAULTPORT"
   Write-Host "================================================================================================================="
   $PORTA      = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTPORT"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host ""

   #PREENCHENDO .CONF COM AS INFORMAÇÕES INSERIDAS
   $alteraconf_mudapasta = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudapasta","$PASTA")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudapasta)
   $alteraconf_mudaip = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudaip","$IP")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudaip)
   $alteraconf_mudahostname = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudahostname","$HOSTNAME")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudahostname)
   $alteraconf_mudatimeout = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudatimeout","$TIMEOUT")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudatimeout)
   $alteraconf_mudaremotecom = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudaremotecom","$REMOTE")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudaremotecom)
   $alteraconf_mudalogremotecom = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudalogremotecom","$REMOTELOG")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudalogremotecom)
   $alteraconf_mudaporta = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudaporta","$PORTA")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudaporta)
   Rename-Item "c:\$PASTA\zabbix_agentd.conf.txt" "c:\$PASTA\zabbix_agentd.conf"

   cls
   cd "c:\$PASTA"
   Write-Host "================================================================================================================="
   Write-Host "= Instalando e iniciando serviço, aguarde um momento.                                                           ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   & "c:\$PASTA\zabbix_agentd.exe" -i -c "c:\$PASTA\zabbix_agentd.conf"
   & "c:\$PASTA\zabbix_agentd.exe" -s -c "c:\$PASTA\zabbix_agentd.conf"
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "= Liberando porta no firewall do windows, aguarde um momento.                                                   ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   netsh advfirewall firewall add rule name="ZABBIX" dir=in action=allow protocol=TCP localport=$PORTA
   Write-Host "================================================================================================================="
   Write-Host "= Testando conectividade do Server/Proxy, aguarde um momento.                                                   ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2

   #TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = SUCESSO
   Try {
   $connection = (New-Object Net.Sockets.TcpClient)
   $connection.Connect("$IP",$DEFAULTPORTCON)
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __                                                                  ="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /                                                                  ="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /                               ZAWIN                               ="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /                         RESUMO DE INSTALAÇÃO                       ="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/                                                                     ="
   Write-Host "=                                                                                                               ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Server/ServerActive           = $IP"
   Write-Host "INFO: Hostname                      = $HOSTNAME"
   Write-Host "INFO: Timeout                       = $TIMEOUT"
   Write-Host "INFO: EnableRemoteCommands          = $REMOTE"
   Write-Host "INFO: LogRemoteCommands             = $REMOTELOG"
   Write-Host "INFO: ListenPort                    = $PORTA"
   Write-Host "INFO: Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX"
   Write-Host "INFO: UserParameters                = c:\$PASTA\monitoramento\userparameters\"
   Write-Host "INFO: Scripts                       = c:\$PASTA\monitoramento\scripts\"
   Write-Host "INFO: LogFile                       = c:\$PASTA\zabbix_agentd.log"
   Write-Host "INFO: Diretório                     = c:\$PASTA"
   Write-Host "INFO: Versão                        = $VERSION"
   Write-Host "INFO: S.O                           = $WINDOWS_SO$WINDOWS_ARQ"
   Write-Host "INFO: Conectividade Server/Proxy    = Conexão em $IP $DEFAULTPORTCON Sucesso"
   Write-Host "================================================================================================================="
   cd c:\$INSTALADOR
   }

   #TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = FALHA
   Catch {
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __                                                                  ="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /                                                                  ="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /                               ZAWIN                               ="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /                         RESUMO DE INSTALAÇÃO                       ="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/                                                                     ="
   Write-Host "=                                                                                                               ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Server/ServerActive           = $IP"
   Write-Host "INFO: Hostname                      = $HOSTNAME"
   Write-Host "INFO: Timeout                       = $TIMEOUT"
   Write-Host "INFO: EnableRemoteCommands          = $REMOTE"
   Write-Host "INFO: LogRemoteCommands             = $REMOTELOG"
   Write-Host "INFO: ListenPort                    = $PORTA"
   Write-Host "INFO: Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX"
   Write-Host "INFO: UserParameters                = c:\$PASTA\monitoramento\userparameters\"
   Write-Host "INFO: Scripts                       = c:\$PASTA\monitoramento\scripts\"
   Write-Host "INFO: LogFile                       = c:\$PASTA\zabbix_agentd.log"
   Write-Host "INFO: Diretório                     = c:\$PASTA"
   Write-Host "INFO: Versão                        = $VERSION"
   Write-Host "INFO: S.O                           = $WINDOWS_SO$WINDOWS_ARQ"
   Write-Host "ERRO: Conectividade Server/Proxy    = Conexão em $IP $DEFAULTPORTCON Falhou"
   Write-Host "================================================================================================================="
   cd c:\$INSTALADOR
   }
 }

   #ELSE VERIFICA_SO
   } else {

   #2º Parte IF VERIFICA_SO = 0 = Windows 32 Bits
   Start-Sleep -s 2
   cls

   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __  NAME: ZAWIN ====================================================="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /  DESCRIPTION: ZABBIX AGENT INSTALL WINDOWS ======================="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /   VERSION: $VERS =================================================="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /    CREATE: $VERCREATE =============================================="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/     UPDATE: $VERUPDATE =============================================="
   Write-Host "=                                               AUTHOR: $VERSCRIPTAUTHOR ========================================"
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                        INSTALL: Bem vindo ao assistente de instalação do zabbix agente                        ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""

   cls
   Write-Host "================================================================================================================="
   Write-Host "INFO: Zabbix agente não encontrado, iniciando instalação."
   Write-Host "INFO: Detectado $WINDOWS_SO$WINDOWS_ARQ, continuando instalação."
   Write-Host "INFO: Configurando zabbix agente."
   Write-Host "INFO: Qual a versão do zabbix agente deseja instalar? Ex: 3.0.x, 3.2.x, 3.4.x ou 4.0.x"
   Write-Host "INFO: Default $DEFAULTVERSION"
   Write-Host "================================================================================================================="
   Write-Host ""
   $VERSION = if(($result = Read-Host "Versão") -eq ''){"$DEFAULTVERSION"}else{$result}
   Write-Host ""

   $VERIFICAVERSION = Test-Path "c:\$INSTALADOR\versao\$VERSION" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #IF VERIFICAVERSION = 0 = NÃO ENCONTRADO    
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "================================================================================================================="
   Write-Host "ERRO: Desculpe, a versão escolhida não foi encontrada no instalador."
   Write-Host "ERRO: A instalação foi cancelada."
   Write-Host "ERRO: Verifique as versões disponíveis em c:\$INSTALADOR\versao\"
   Write-Host "================================================================================================================="
   Write-Host ""

   #ELSE VERIFICAVERSION = 1 = ENCONTRADO
   } else {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Qual o diretório onde deseja instalar o zabbix agente?"
   Write-Host "INFO: Digite apenas o diretório, a raiz c:\ será preenchida automaticamente."
   Write-Host "INFO: Digite apenas o diretório sem a \ no final."
   Write-Host "INFO: Ex: digitando o diretório zabbix, o agente será instalado em c:\zabbix"
   Write-Host "INFO: Default c:\$DEFAULTFOLDER"
   Write-Host "================================================================================================================="
   Write-Host ""
   $PASTA = if(($result = Read-Host "c:\") -eq ''){"$DEFAULTFOLDER"}else{$result}
   md "c:\$PASTA\monitoramento\scripts\"
   md "c:\$PASTA\monitoramento\userparameters\"
   Copy-Item "c:\$INSTALADOR\versao\$VERSION\win32\*.*" -Destination "c:\$PASTA\" -Recurse
   Copy-Item "c:\$INSTALADOR\monitoramento\scripts\*.*" -Destination "c:\$PASTA\monitoramento\scripts\" -Recurse
   Copy-Item "c:\$INSTALADOR\monitoramento\userparameters\*.*" -Destination "c:\$PASTA\monitoramento\userparameters\" -Recurse
   copy-Item "c:\$INSTALADOR\zabbix_agentd.conf" -Destination "c:\$PASTA" -Recurse
   Rename-Item "c:\$PASTA\zabbix_agentd.conf" "c:\$PASTA\zabbix_agentd.conf.txt"

   cls
   Write-Host "================================================================================================================="
   Write-Host "=                                          Configurando zabbix agente                                           ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Server/ServerActive = Qual o IP/DNS do zabbix server/zabbix proxy?"
   Write-Host "INFO: Default $DEFAULTSERVER"
   Write-Host "================================================================================================================="
   $IP         = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTSERVER"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: Hostname = Qual o nome do host?"
   Write-Host "INFO: Default $DEFAULTHOST"
   Write-Host "================================================================================================================="
   $HOSTNAME   = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTHOST"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: Timeout = Qual o timeout do host? Entre 0 e 30 segundos?"
   Write-Host "INFO: Default $DEFAULTTIMEOUT"
   Write-Host "================================================================================================================="
   $TIMEOUT    = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTTIMEOUT"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: EnableRemoteCommands = Deseja habilitar o comando remoto no host? (0)desabilita (1)habilita"
   Write-Host "INFO: Default ($DEFAULTREMOTECOM)habilita"
   Write-Host "================================================================================================================="
   $REMOTE     = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTREMOTECOM"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: LogRemoteCommands = Deseja habilitar o log do comando remoto no host? (0)desabilita (1)habilita"
   Write-Host "INFO: Default ($DEFAULTREMOTELOG)desabilita"
   Write-Host "================================================================================================================="
   $REMOTELOG  = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTREMOTELOG"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: ListenPort = Qual a porta de comunicação do zabbix agent?"
   Write-Host "INFO: Default $DEFAULTPORT"
   Write-Host "================================================================================================================="
   $PORTA      = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTPORT"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host ""

   #PREENCHENDO .CONF COM AS INFORMAÇÕES INSERIDAS
   $alteraconf_mudapasta = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudapasta","$PASTA")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudapasta)
   $alteraconf_mudaip = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudaip","$IP")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudaip)
   $alteraconf_mudahostname = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudahostname","$HOSTNAME")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudahostname)
   $alteraconf_mudatimeout = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudatimeout","$TIMEOUT")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudatimeout)
   $alteraconf_mudaremotecom = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudaremotecom","$REMOTE")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudaremotecom)
   $alteraconf_mudalogremotecom = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudalogremotecom","$REMOTELOG")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudalogremotecom)
   $alteraconf_mudaporta = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudaporta","$PORTA")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudaporta)
   Rename-Item "c:\$PASTA\zabbix_agentd.conf.txt" "c:\$PASTA\zabbix_agentd.conf"

   cls
   cd "c:\$PASTA"
   Write-Host "================================================================================================================="
   Write-Host "= Instalando e iniciando serviço, aguarde um momento.                                                           ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   & "c:\$PASTA\zabbix_agentd.exe" -i -c "c:\$PASTA\zabbix_agentd.conf"
   & "c:\$PASTA\zabbix_agentd.exe" -s -c "c:\$PASTA\zabbix_agentd.conf"
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "= Liberando porta no firewall do windows, aguarde um momento.                                                   ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   netsh advfirewall firewall add rule name="ZABBIX" dir=in action=allow protocol=TCP localport=$PORTA
   Write-Host "================================================================================================================="
   Write-Host "= Testando conectividade do Server/Proxy, aguarde um momento.                                                   ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2

   #TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = SUCESSO
   Try   {
   $connection = (New-Object Net.Sockets.TcpClient)
   $connection.Connect("$IP",$DEFAULTPORTCON)
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __                                                                  ="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /                                                                  ="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /                               ZAWIN                               ="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /                         RESUMO DE INSTALAÇÃO                       ="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/                                                                     ="
   Write-Host "=                                                                                                               ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Server/ServerActive           = $IP"
   Write-Host "INFO: Hostname                      = $HOSTNAME"
   Write-Host "INFO: Timeout                       = $TIMEOUT"
   Write-Host "INFO: EnableRemoteCommands          = $REMOTE"
   Write-Host "INFO: LogRemoteCommands             = $REMOTELOG"
   Write-Host "INFO: ListenPort                    = $PORTA"
   Write-Host "INFO: Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX"
   Write-Host "INFO: UserParameters                = c:\$PASTA\monitoramento\userparameters\"
   Write-Host "INFO: Scripts                       = c:\$PASTA\monitoramento\scripts\"
   Write-Host "INFO: LogFile                       = c:\$PASTA\zabbix_agentd.log"
   Write-Host "INFO: Diretório                     = c:\$PASTA"
   Write-Host "INFO: Versão                        = $VERSION"
   Write-Host "INFO: S.O                           = $WINDOWS_SO$WINDOWS_ARQ"
   Write-Host "INFO: Conectividade Server/Proxy    = Conexão em $IP $DEFAULTPORTCON Sucesso"
   Write-Host "================================================================================================================="
   cd c:\$INSTALADOR
   }

   #TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = FALHA
   Catch {
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __                                                                  ="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /                                                                  ="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /                               ZAWIN                               ="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /                         RESUMO DE INSTALAÇÃO                       ="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/                                                                     ="
   Write-Host "=                                                                                                               ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Server/ServerActive           = $IP"
   Write-Host "INFO: Hostname                      = $HOSTNAME"
   Write-Host "INFO: Timeout                       = $TIMEOUT"
   Write-Host "INFO: EnableRemoteCommands          = $REMOTE"
   Write-Host "INFO: LogRemoteCommands             = $REMOTELOG"
   Write-Host "INFO: ListenPort                    = $PORTA"
   Write-Host "INFO: Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX"
   Write-Host "INFO: UserParameters                = c:\$PASTA\monitoramento\userparameters\"
   Write-Host "INFO: Scripts                       = c:\$PASTA\monitoramento\scripts\"
   Write-Host "INFO: LogFile                       = c:\$PASTA\zabbix_agentd.log"
   Write-Host "INFO: Diretório                     = c:\$PASTA"
   Write-Host "INFO: Versão                        = $VERSION"
   Write-Host "INFO: S.O                           = $WINDOWS_SO$WINDOWS_ARQ"
   Write-Host "ERRO: Conectividade Server/Proxy    = Conexão em $IP $DEFAULTPORTCON Falhou"
   Write-Host "================================================================================================================="
   cd c:\$INSTALADOR
    }
   }
  }
 }
}

# OPTION LOCALREMOVE ################################################################################
# BR - Remove zabbix agente windows x.x.x local.                                                    #
# EN - Remove zabbix agent windows x.x.x local.                                                     #
#####################################################################################################

if ( $select -like 'LOCALREMOVE' )
{
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __  NAME: ZAWIN ====================================================="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /  DESCRIPTION: ZABBIX AGENT INSTALL WINDOWS ======================="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /   VERSION: $VERS =================================================="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /    CREATE: $VERCREATE =============================================="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/     UPDATE: $VERUPDATE =============================================="
   Write-Host "=                                               AUTHOR: $VERSCRIPTAUTHOR ========================================"
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                          REMOVE: Bem vindo ao assistente de remoção do zabbix agente                          ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""
   cls

   Write-Host "================================================================================================================="
   Write-Host "= O script irá desinstalar por completo o zabbix agente, aguarde um momento.                                    ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "INFO: Qual o diretório onde seu zabbix agente foi instalado?"
   Write-Host "INFO: Digite apenas o diretório, a raiz c:\ será preenchida automaticamente."
   Write-Host "INFO: Digite apenas o diretório sem a \ no final."
   Write-Host "INFO: Ex: digitando o diretório zabbix, o agente será removido de c:\zabbix"
   Write-Host "INFO: Default c:\$DEFAULTFOLDER"
   Write-Host "================================================================================================================="
   Write-Host ""

   $PASTA = if(($result = Read-Host "c:\") -eq ''){"$DEFAULTFOLDER"}else{$result}
   $DATAATUAL = Get-Date -Uformat "%d-%m-%Y"
   $VERIFICA_PASTA = Test-Path "c:\$PASTA" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   Write-Host ""

   #IF VERIFICA_PASTA = 0 = NÃO ENCONTRADA
   If ($VERIFICA_PASTA –eq 0) {

   Write-Host "================================================================================================================="
   Write-Host "ERRO: Diretório c:\$PASTA não encontrado, verifique se é o diretório correto e tente novamente."
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\$INSTALADOR

   #ELSE VERIFICA_PASTA = 1 = ENCONTRADA 
   } else {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Realizando backup, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 3
   Copy-Item -Path "c:\$PASTA\" -Destination "c:\$PASTA.backup.$DATAATUAL" -Recurse

   cls
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Parando o serviço do zabbix agente, aguarde um momento."
   Write-Host "================================================================================================================="
   Start-Sleep -s 2
   net stop "Zabbix Agent"
   Write-Host "================================================================================================================="
   Write-Host "INFO: Removendo o serviço do zabbix agente, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   & "c:\$PASTA\zabbix_agentd.exe" -d -c "c:\$PASTA\zabbix_agentd.conf"
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Removendo regra de firewall do zabbix agente no windows, aguarde um momento."
   Write-Host "================================================================================================================="
   Start-Sleep -s 2
   netsh advfirewall firewall delete rule name="ZABBIX"
   Write-Host "================================================================================================================="
   Write-Host "INFO: Removendo diretório de instalação em c:\$PASTA"
   Write-Host "================================================================================================================="
   Remove-Item "c:\$PASTA" -Recurse
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Diretório de instalação original c:\$PASTA removido com sucesso."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Seu zabbix agente foi removido com sucesso."
   Write-Host "INFO: Backup salvo em c:\$PASTA.backup.$DATAATUAL"
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\$INSTALADOR
 }
}

# OPTION LOCALCHANGE ################################################################################
# BR - Upgrade/Downgrade do zabbix agente windows x.x.x local.                                      #
# EN - Upgrade/Downgrade of zabbix agent windows x.x.x local.                                       #
#####################################################################################################

if ( $select -like 'LOCALCHANGE' )
{
   cls
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "= Verificando existência do zabbix agente no host, aguarde um momento...                                        ="
   Write-Host "================================================================================================================="
   Write-Host ""
   #VERIFICA SE O SERVIÇO ZABBIX AGENT JA EXISTE
   $VERIFICA_SERVICO = Get-Service "Zabbix Agent" -ErrorAction SilentlyContinue | Measure-Object -Line | select-object Lines | select-object -ExpandProperty Lines
   #VERIFICA A ARQUITETURA DO S.O "X86" OU "X64"
   $VERIFICA_SO = Test-Path "c:\Program Files (x86)" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #VERIFICA DATA ATUAL NO FORMATO DD-MM-YYYY
   $DATAATUAL = Get-Date -Uformat "%d-%m-%Y"
   #VERIFICA WINDOWS VERSÃO
   $WINDOWS_SO = (Get-WmiObject -class Win32_OperatingSystem).Caption
   #VERIFICA WINDOWS ARQUITETURA
   $WINDOWS_ARQ = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

   #IF VERIFICA_SERVICO
   If ($VERIFICA_SERVICO –eq 0) {

   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "ERRO: Desculpe, o zabbix agente não foi encontrado."
   Write-Host "ERRO: O assistente de upgrade/downgrade será cancelado."
   Write-Host "ERRO: Por favor, execute a instalação com o parâmetro LOCALINSTALL"
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\$INSTALADOR

   #ELSE VERIFICA_SERVICO
   } else {

   #IF VERIFICA_SO
   If ($VERIFICA_SO –eq 1) {

   #1º Parte IF VERIFICA_SO = 1 = Windows 64 Bits
   Start-Sleep -s 2
   cls

   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __  NAME: ZAWIN ====================================================="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /  DESCRIPTION: ZABBIX AGENT INSTALL WINDOWS ======================="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /   VERSION: $VERS =================================================="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /    CREATE: $VERCREATE =============================================="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/     UPDATE: $VERUPDATE =============================================="
   Write-Host "=                                               AUTHOR: $VERSCRIPTAUTHOR ========================================"
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                     CHANGE: Bem vindo ao assistente de upgrade/downgrade do zabbix agente                     ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""
   cls

   Write-Host "================================================================================================================="
   Write-Host "INFO: Serviço zabbix agente encontrado, iniciando assistente de upgrade/downgrade"
   Write-Host "INFO: Detectado $WINDOWS_SO$WINDOWS_ARQ, continuando atualização."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Qual o diretório onde seu zabbix agente foi instalado?"
   Write-Host "INFO: Digite apenas o diretório, a raiz c:\ será preenchida automaticamente."
   Write-Host "INFO: Digite apenas o diretório sem a \ no final."
   Write-Host "INFO: Ex: digitando o diretório zabbix, o agente será atualizado em c:\zabbix"
   Write-Host "INFO: Default c:\$DEFAULTFOLDER"
   Write-Host "================================================================================================================="
   Write-Host ""
   $PASTA = if(($result = Read-Host "c:\") -eq ''){"$DEFAULTFOLDER"}else{$result}
   Write-Host ""
   cls
   
   $VERIFICAVERSION = Test-Path "c:\$PASTA\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #IF VERIFICAVERSION = 0 = NÃO ENCONTRADO
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Verificando versão atual do zabbix agente, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "ERRO: Não foi possível identificar a versão do zabbix agente."
   Write-Host "ERRO: Talvez o zabbix_agentd.exe não esteja localizado no diretório c:\$PASTA"
   Write-Host "ERRO: O assistente de upgrade/downgrade será cancelado."
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\$INSTALADOR

   #ELSE VERIFICAVERSION = 1 = ENCONTRADO
   } else {

   $VERSIONOLD = Get-ChildItem "c:\$PASTA\zabbix_agentd.exe" | Select-Object -ExpandProperty VersionInfo | select-object ProductVersion | select-object -ExpandProperty ProductVersion
   Write-Host "================================================================================================================="
   Write-Host "INFO: Verificando versão atual do zabbix agente, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão $VERSIONOLD encontrada, continuando atualização."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Digite a versão que deseja realizar upgrade/downgrade Ex: 3.0.x, 3.2.x, 3.4.x ou 4.0.x"
   Write-Host "INFO: Default $DEFAULTVERSION"
   Write-Host "================================================================================================================="
   Write-Host ""
   $CHANGEVERSION = if(($result = Read-Host "Versão") -eq ''){"$DEFAULTVERSION"}else{$result}
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                                                   ATENÇÃO!                                                    ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão $VERSIONOLD será removida."
   Write-Host "INFO: Versão $CHANGEVERSION será instalada."
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""
   cls

   $INSTALLVERSION = Test-Path "c:\$INSTALADOR\versao\$CHANGEVERSION\win64\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #IF INSTALLVERSION = 0 = NÃO ENCONTRADO
   If ($INSTALLVERSION –eq 0) {

   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Verificando Instalador, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "ERRO: Desculpe, a versão $CHANGEVERSION não foi encontrada no instalador."
   Write-Host "ERRO: O assistente de upgrade/downgrade será cancelado."
   Write-Host "ERRO: Verifique as versões disponíveis em c:\$INSTALADOR\versao\"
   Write-Host "================================================================================================================="
   Write-Host ""

   #ELSE INSTALLVERSION = 1 = ENCONTRADO
   } else {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão $CHANGEVERSION encontrada, continuando atualização."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Removendo zabbix agente $VERSIONOLD, aguarde um momento."
   Write-Host "================================================================================================================="
   Start-Sleep -s 2
   net stop "Zabbix Agent"
   Write-Host "================================================================================================================="
   Write-Host "INFO: Copiando executáveis da versão $CHANGEVERSION, aguarde um momento."
   Write-Host "================================================================================================================="
   Start-Sleep -s 2
   Remove-Item "c:\$PASTA\*.exe" -Recurse
   Copy-Item "c:\$INSTALADOR\versao\$CHANGEVERSION\win64\*.*" -Destination "c:\$PASTA\" -Recurse
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Iniciando serviço do zabbix agente $CHANGEVERSION, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   net start "Zabbix Agent"
   Start-Sleep -s 2
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __                                                                  ="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /                                                                  ="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /                               ZAWIN                               ="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /                     RESUMO DO UPGRADE/DOWNGRADE                    ="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/                                                                     ="
   Write-Host "=                                                                                                               ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão = $VERSIONOLD removida com sucesso"
   Write-Host "INFO: Versão = $CHANGEVERSION instalada com sucesso"
   Write-Host "INFO: S.O    = $WINDOWS_SO$WINDOWS_ARQ"
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\$INSTALADOR
 }
}

   #ELSE VERIFICA_SO
   } else {

   #2º Parte IF VERIFICA_SO = 0 = Windows 32 Bits
   Start-Sleep -s 2
   cls

   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __  NAME: ZAWIN ====================================================="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /  DESCRIPTION: ZABBIX AGENT INSTALL WINDOWS ======================="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /   VERSION: $VERS =================================================="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /    CREATE: $VERCREATE =============================================="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/     UPDATE: $VERUPDATE =============================================="
   Write-Host "=                                               AUTHOR: $VERSCRIPTAUTHOR ========================================"
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                        INSTALL: Bem vindo ao assistente de instalação do zabbix agente                        ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""

   cls
   Write-Host "================================================================================================================="
   Write-Host "INFO: Serviço zabbix agente encontrado, iniciando assistente de upgrade/downgrade"
   Write-Host "INFO: Detectado $WINDOWS_SO$WINDOWS_ARQ, continuando atualização."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Qual o diretório onde seu zabbix agente foi instalado?"
   Write-Host "INFO: Digite apenas o diretório, a raiz c:\ será preenchida automaticamente."
   Write-Host "INFO: Digite apenas o diretório sem a \ no final."
   Write-Host "INFO: Ex: digitando o diretório zabbix, o agente será atualizado em c:\zabbix"
   Write-Host "INFO: Default c:\$DEFAULTFOLDER"
   Write-Host "================================================================================================================="
   Write-Host ""
   $PASTA = if(($result = Read-Host "c:\") -eq ''){"$DEFAULTFOLDER"}else{$result}
   Write-Host ""
   cls

   $VERIFICAVERSION = Test-Path "c:\$PASTA\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #IF VERIFICAVERSION = 0 = NÃO ENCONTRADO
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Verificando versão atual do zabbix agente, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "ERRO: Não foi possível identificar a versão do zabbix agente."
   Write-Host "ERRO: Talvez o zabbix_agentd.exe não esteja localizado no diretório c:\$PASTA"
   Write-Host "ERRO: O assistente de upgrade/downgrade será cancelado."
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\$INSTALADOR

   #ELSE VERIFICAVERSION = 1 = ENCONTRADO
   } else {

   $VERSIONOLD = Get-ChildItem "c:\$PASTA\zabbix_agentd.exe" | Select-Object -ExpandProperty VersionInfo | select-object ProductVersion | select-object -ExpandProperty ProductVersion
   Write-Host "================================================================================================================="
   Write-Host "INFO: Verificando versão atual do zabbix agente, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão $VERSIONOLD encontrada, continuando atualização."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Digite a versão que deseja realizar upgrade/downgrade Ex: 3.0.x, 3.2.x, 3.4.x ou 4.0.x"
   Write-Host "INFO: Default $DEFAULTVERSION"
   Write-Host "================================================================================================================="
   Write-Host ""
   $CHANGEVERSION = if(($result = Read-Host "Versão") -eq ''){"$DEFAULTVERSION"}else{$result}
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                                                   ATENÇÃO!                                                    ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão $VERSIONOLD será removida."
   Write-Host "INFO: Versão $CHANGEVERSION será instalada."
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""
   cls

   $INSTALLVERSION = Test-Path "c:\$INSTALADOR\versao\$CHANGEVERSION\win32\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #IF INSTALLVERSION = 0 = NÃO ENCONTRADO
   If ($INSTALLVERSION –eq 0) {

   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Verificando Instalador, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "ERRO: Desculpe, a versão $CHANGEVERSION não foi encontrada no instalador."
   Write-Host "ERRO: O assistente de upgrade/downgrade será cancelado."
   Write-Host "ERRO: Verifique as versões disponíveis em c:\$INSTALADOR\versao\"
   Write-Host "================================================================================================================="
   Write-Host ""

   #ELSE INSTALLVERSION = 1 = ENCONTRADO
   } else {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão $CHANGEVERSION encontrada, continuando atualização."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Removendo zabbix agente $VERSIONOLD, aguarde um momento."
   Write-Host "================================================================================================================="
   Start-Sleep -s 2
   net stop "Zabbix Agent"
   Write-Host "================================================================================================================="
   Write-Host "INFO: Copiando executáveis da versão $CHANGEVERSION, aguarde um momento."
   Write-Host "================================================================================================================="
   Start-Sleep -s 2
   Remove-Item "c:\$PASTA\*.exe" -Recurse
   Copy-Item "c:\$INSTALADOR\versao\$CHANGEVERSION\win32\*.*" -Destination "c:\$PASTA\" -Recurse
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Iniciando serviço do zabbix agente $CHANGEVERSION, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   net start "Zabbix Agent"
   Start-Sleep -s 2
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __                                                                  ="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /                                                                  ="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /                               ZAWIN                               ="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /                     RESUMO DO UPGRADE/DOWNGRADE                    ="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/                                                                     ="
   Write-Host "=                                                                                                               ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão = $VERSIONOLD removida com sucesso"
   Write-Host "INFO: Versão = $CHANGEVERSION instalada com sucesso"
   Write-Host "INFO: S.O    = $WINDOWS_SO$WINDOWS_ARQ"
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\$INSTALADOR
    }
   }
  }
 }
}

# OPTION SHAREINSTALL ###############################################################################
# BR - Instalação do zabbix agente windows x.x.x rede.                                              #
# EN - Installation of zabbix agent windows x.x.x rede.                                             #
#####################################################################################################

if ( $select -like 'SHAREINSTALL' )
{
   cls
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "= Verificando existência do zabbix agente no host, aguarde um momento...                                        ="
   Write-Host "================================================================================================================="
   #VERIFICA SE O SERVIÇO ZABBIX AGENT JA EXISTE
   $VERIFICA_INSTALL = Get-Service "Zabbix Agent" -ErrorAction SilentlyContinue | Measure-Object -Line | select-object Lines | select-object -ExpandProperty Lines
   #VERIFICA A ARQUITETURA DO S.O "X86" OU "X64"
   $VERIFICA_SO = Test-Path "c:\Program Files (x86)" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #VERIFICA WINDOWS VERSÃO
   $WINDOWS_SO = (Get-WmiObject -class Win32_OperatingSystem).Caption
   #VERIFICA WINDOWS ARQUITETURA
   $WINDOWS_ARQ = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

   #IF VERIFICA_INSTALL
   If ($VERIFICA_INSTALL –eq 1) {
   Start-Sleep -s 2
   cls
   Write-Host "================================================================================================================="
   Write-Host "ERRO: Zabbix agente já existe, instalação cancelada."
   Write-Host "ERRO: Se deseja remover o zabbix agente por completo, execute o script com o parâmetro SHAREREMOVE"
   Write-Host "ERRO: Se deseja realizar upgrade/downgrade, execute o script com o parâmetro SHARECHANGE"
   Write-Host "================================================================================================================="
   Write-Host ""

   #ELSE VERIFICA_INSTALL
   } else {

   #IF VERIFICA_SO
   If ($VERIFICA_SO –eq 1) {

   #1º Parte IF VERIFICA_SO = 1 = Windows 64 Bits
   Start-Sleep -s 2
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __  NAME: ZAWIN ====================================================="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /  DESCRIPTION: ZABBIX AGENT INSTALL WINDOWS ======================="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /   VERSION: $VERS =================================================="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /    CREATE: $VERCREATE =============================================="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/     UPDATE: $VERUPDATE =============================================="
   Write-Host "=                                               AUTHOR: $VERSCRIPTAUTHOR ========================================"
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                        INSTALL: Bem vindo ao assistente de instalação do zabbix agente                        ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""
   cls

   Write-Host "================================================================================================================="
   Write-Host "INFO: Zabbix agente não encontrado, iniciando instalação."
   Write-Host "INFO: Detectado $WINDOWS_SO$WINDOWS_ARQ, continuando instalação."
   Write-Host "INFO: Configurando zabbix agente."
   Write-Host "INFO: Qual a versão do zabbix agente deseja instalar? Ex: 3.0.x, 3.2.x, 3.4.x ou 4.0.x"
   Write-Host "INFO: Default $DEFAULTVERSION"
   Write-Host "================================================================================================================="
   Write-Host ""
   $VERSION = if(($result = Read-Host "Versão") -eq ''){"$DEFAULTVERSION"}else{$result}
   Write-Host ""

   $VERIFICAVERSION = Test-Path $SHARE\versao\$VERSION | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #IF VERIFICAVERSION = 0 = NÃO ENCONTRADO
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "================================================================================================================="
   Write-Host "ERRO: Desculpe, a versão escolhida não foi encontrada no instalador."
   Write-Host "ERRO: A instalação foi cancelada."
   Write-Host "ERRO: Verifique as versões disponíveis em $SHARE\versao\"
   Write-Host "================================================================================================================="
   Write-Host ""

   #ELSE VERIFICAVERSION = 1 = ENCONTRADO
   } else {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Qual o diretório onde deseja instalar o zabbix agente?"
   Write-Host "INFO: Digite apenas o diretório, a raiz c:\ será preenchida automaticamente."
   Write-Host "INFO: Digite apenas o diretório sem a \ no final."
   Write-Host "INFO: Ex: digitando o diretório zabbix, o agente será instalado em c:\zabbix"
   Write-Host "INFO: Default c:\$DEFAULTFOLDER"
   Write-Host "================================================================================================================="
   Write-Host ""
   $PASTA = if(($result = Read-Host "c:\") -eq ''){"$DEFAULTFOLDER"}else{$result}
   md "c:\$PASTA\monitoramento\scripts\"
   md "c:\$PASTA\monitoramento\userparameters\"
   Copy-Item "$SHARE\versao\$VERSION\win64\*.*" -Destination "c:\$PASTA\" -Recurse
   Copy-Item "$SHARE\monitoramento\scripts\*.*" -Destination "c:\$PASTA\monitoramento\scripts\" -Recurse
   Copy-Item "$SHARE\monitoramento\userparameters\*.*" -Destination "c:\$PASTA\monitoramento\userparameters\" -Recurse
   copy-Item "$SHARE\zabbix_agentd.conf" -Destination "c:\$PASTA" -Recurse
   Rename-Item "c:\$PASTA\zabbix_agentd.conf" "c:\$PASTA\zabbix_agentd.conf.txt"

   cls
   Write-Host "================================================================================================================="
   Write-Host "=                                          Configurando zabbix agente                                           ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Server/ServerActive = Qual o IP/DNS do zabbix server/zabbix proxy?"
   Write-Host "INFO: Default $DEFAULTSERVER"
   Write-Host "================================================================================================================="
   $IP         = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTSERVER"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: Hostname = Qual o nome do host?"
   Write-Host "INFO: Default $DEFAULTHOST"
   Write-Host "================================================================================================================="
   $HOSTNAME   = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTHOST"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: Timeout = Qual o timeout do host? Entre 0 e 30 segundos?"
   Write-Host "INFO: Default $DEFAULTTIMEOUT"
   Write-Host "================================================================================================================="
   $TIMEOUT    = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTTIMEOUT"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: EnableRemoteCommands = Deseja habilitar o comando remoto no host? (0)desabilita (1)habilita"
   Write-Host "INFO: Default ($DEFAULTREMOTECOM)habilita"
   Write-Host "================================================================================================================="
   $REMOTE     = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTREMOTECOM"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: LogRemoteCommands = Deseja habilitar o log do comando remoto no host? (0)desabilita (1)habilita"
   Write-Host "INFO: Default ($DEFAULTREMOTELOG)desabilita"
   Write-Host "================================================================================================================="
   $REMOTELOG  = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTREMOTELOG"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: ListenPort = Qual a porta de comunicação do zabbix agent?"
   Write-Host "INFO: Default $DEFAULTPORT"
   Write-Host "================================================================================================================="
   $PORTA      = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTPORT"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host ""

   #PREENCHENDO .CONF COM AS INFORMAÇÕES INSERIDAS
   $alteraconf_mudapasta = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudapasta","$PASTA")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudapasta)
   $alteraconf_mudaip = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudaip","$IP")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudaip)
   $alteraconf_mudahostname = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudahostname","$HOSTNAME")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudahostname)
   $alteraconf_mudatimeout = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudatimeout","$TIMEOUT")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudatimeout)
   $alteraconf_mudaremotecom = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudaremotecom","$REMOTE")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudaremotecom)
   $alteraconf_mudalogremotecom = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudalogremotecom","$REMOTELOG")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudalogremotecom)
   $alteraconf_mudaporta = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudaporta","$PORTA")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudaporta)
   Rename-Item "c:\$PASTA\zabbix_agentd.conf.txt" "c:\$PASTA\zabbix_agentd.conf"

   cls
   cd "c:\$PASTA"
   Write-Host "================================================================================================================="
   Write-Host "= Instalando e iniciando serviço, aguarde um momento.                                                           ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   & "c:\$PASTA\zabbix_agentd.exe" -i -c "c:\$PASTA\zabbix_agentd.conf"
   & "c:\$PASTA\zabbix_agentd.exe" -s -c "c:\$PASTA\zabbix_agentd.conf"
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "= Liberando porta no firewall do windows, aguarde um momento.                                                   ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   netsh advfirewall firewall add rule name="ZABBIX" dir=in action=allow protocol=TCP localport=$PORTA
   Write-Host "================================================================================================================="
   Write-Host "= Testando conectividade do Server/Proxy, aguarde um momento.                                                   ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2

   #TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = SUCESSO
   Try   {
   $connection = (New-Object Net.Sockets.TcpClient)
   $connection.Connect("$IP",$DEFAULTPORTCON)
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __                                                                  ="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /                                                                  ="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /                               ZAWIN                               ="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /                         RESUMO DE INSTALAÇÃO                       ="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/                                                                     ="
   Write-Host "=                                                                                                               ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Server/ServerActive           = $IP"
   Write-Host "INFO: Hostname                      = $HOSTNAME"
   Write-Host "INFO: Timeout                       = $TIMEOUT"
   Write-Host "INFO: EnableRemoteCommands          = $REMOTE"
   Write-Host "INFO: LogRemoteCommands             = $REMOTELOG"
   Write-Host "INFO: ListenPort                    = $PORTA"
   Write-Host "INFO: Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX"
   Write-Host "INFO: UserParameters                = c:\$PASTA\monitoramento\userparameters\"
   Write-Host "INFO: Scripts                       = c:\$PASTA\monitoramento\scripts\"
   Write-Host "INFO: LogFile                       = c:\$PASTA\zabbix_agentd.log"
   Write-Host "INFO: Diretório                     = c:\$PASTA"
   Write-Host "INFO: Versão                        = $VERSION"
   Write-Host "INFO: S.O                           = $WINDOWS_SO$WINDOWS_ARQ"
   Write-Host "INFO: Share                         = $SHARE"
   Write-Host "INFO: Conectividade Server/Proxy    = Conexão em $IP $DEFAULTPORTCON Sucesso"
   Write-Host "================================================================================================================="
   cd c:\
   }

   #TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = FALHA
   Catch {
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __                                                                  ="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /                                                                  ="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /                               ZAWIN                               ="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /                         RESUMO DE INSTALAÇÃO                       ="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/                                                                     ="
   Write-Host "=                                                                                                               ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Server/ServerActive           = $IP"
   Write-Host "INFO: Hostname                      = $HOSTNAME"
   Write-Host "INFO: Timeout                       = $TIMEOUT"
   Write-Host "INFO: EnableRemoteCommands          = $REMOTE"
   Write-Host "INFO: LogRemoteCommands             = $REMOTELOG"
   Write-Host "INFO: ListenPort                    = $PORTA"
   Write-Host "INFO: Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX"
   Write-Host "INFO: UserParameters                = c:\$PASTA\monitoramento\userparameters\"
   Write-Host "INFO: Scripts                       = c:\$PASTA\monitoramento\scripts\"
   Write-Host "INFO: LogFile                       = c:\$PASTA\zabbix_agentd.log"
   Write-Host "INFO: Diretório                     = c:\$PASTA"
   Write-Host "INFO: Versão                        = $VERSION"
   Write-Host "INFO: S.O                           = $WINDOWS_SO$WINDOWS_ARQ"
   Write-Host "INFO: Share                         = $SHARE"
   Write-Host "ERRO: Conectividade Server/Proxy    = Conexão em $IP $DEFAULTPORTCON Falhou"
   Write-Host "================================================================================================================="
   cd c:\
   }
 }

   #ELSE VERIFICA_SO
   } else {

   #2º Parte IF VERIFICA_SO = 0 = Windows 32 Bits
   Start-Sleep -s 2
   cls

   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __  NAME: ZAWIN ====================================================="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /  DESCRIPTION: ZABBIX AGENT INSTALL WINDOWS ======================="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /   VERSION: $VERS =================================================="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /    CREATE: $VERCREATE =============================================="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/     UPDATE: $VERUPDATE =============================================="
   Write-Host "=                                               AUTHOR: $VERSCRIPTAUTHOR ========================================"
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                        INSTALL: Bem vindo ao assistente de instalação do zabbix agente                        ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""

   cls
   Write-Host "================================================================================================================="
   Write-Host "INFO: Zabbix agente não encontrado, iniciando instalação."
   Write-Host "INFO: Detectado $WINDOWS_SO$WINDOWS_ARQ, continuando instalação."
   Write-Host "INFO: Configurando zabbix agente."
   Write-Host "INFO: Qual a versão do zabbix agente deseja instalar? Ex: 3.0.x, 3.2.x, 3.4.x ou 4.0.x"
   Write-Host "INFO: Default $DEFAULTVERSION"
   Write-Host "================================================================================================================="
   Write-Host ""
   $VERSION = if(($result = Read-Host "Versão") -eq ''){"$DEFAULTVERSION"}else{$result}
   Write-Host ""

   $VERIFICAVERSION = Test-Path "$SHARE\versao\$VERSION" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #IF VERIFICAVERSION = 0 = NÃO ENCONTRADO
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "================================================================================================================="
   Write-Host "ERRO: Desculpe, a versão escolhida não foi encontrada no instalador."
   Write-Host "ERRO: A instalação foi cancelada."
   Write-Host "ERRO: Verifique as versões disponíveis em $SHARE\versao\"
   Write-Host "================================================================================================================="
   Write-Host ""

   #ELSE VERIFICAVERSION = 1 = ENCONTRADO
   } else {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Qual o diretório onde deseja instalar o zabbix agente?"
   Write-Host "INFO: Digite apenas o diretório, a raiz c:\ será preenchida automaticamente."
   Write-Host "INFO: Digite apenas o diretório sem a \ no final."
   Write-Host "INFO: Ex: digitando o diretório zabbix, o agente será instalado em c:\zabbix"
   Write-Host "INFO: Default c:\$DEFAULTFOLDER"
   Write-Host "================================================================================================================="
   Write-Host ""
   $PASTA = if(($result = Read-Host "c:\") -eq ''){"$DEFAULTFOLDER"}else{$result}
   md "c:\$PASTA\monitoramento\scripts\"
   md "c:\$PASTA\monitoramento\userparameters\"
   Copy-Item "$SHARE\versao\$VERSION\win32\*.*" -Destination "c:\$PASTA\" -Recurse
   Copy-Item "$SHARE\monitoramento\scripts\*.*" -Destination "c:\$PASTA\monitoramento\scripts\" -Recurse
   Copy-Item "$SHARE\monitoramento\userparameters\*.*" -Destination "c:\$PASTA\monitoramento\userparameters\" -Recurse
   copy-Item "$SHARE\zabbix_agentd.conf" -Destination "c:\$PASTA" -Recurse
   Rename-Item "c:\$PASTA\zabbix_agentd.conf" "c:\$PASTA\zabbix_agentd.conf.txt"

   cls
   Write-Host "================================================================================================================="
   Write-Host "=                                          Configurando zabbix agente                                           ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Server/ServerActive = Qual o IP/DNS do zabbix server/zabbix proxy?"
   Write-Host "INFO: Default $DEFAULTSERVER"
   Write-Host "================================================================================================================="
   $IP         = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTSERVER"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: Hostname = Qual o nome do host?"
   Write-Host "INFO: Default $DEFAULTHOST"
   Write-Host "================================================================================================================="
   $HOSTNAME   = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTHOST"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: Timeout = Qual o timeout do host? Entre 0 e 30 segundos?"
   Write-Host "INFO: Default $DEFAULTTIMEOUT"
   Write-Host "================================================================================================================="
   $TIMEOUT    = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTTIMEOUT"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: EnableRemoteCommands = Deseja habilitar o comando remoto no host? (0)desabilita (1)habilita"
   Write-Host "INFO: Default ($DEFAULTREMOTECOM)habilita"
   Write-Host "================================================================================================================="
   $REMOTE     = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTREMOTECOM"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: LogRemoteCommands = Deseja habilitar o log do comando remoto no host? (0)desabilita (1)habilita"
   Write-Host "INFO: Default ($DEFAULTREMOTELOG)desabilita"
   Write-Host "================================================================================================================="
   $REMOTELOG  = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTREMOTELOG"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host "INFO: ListenPort = Qual a porta de comunicação do zabbix agent?"
   Write-Host "INFO: Default $DEFAULTPORT"
   Write-Host "================================================================================================================="
   $PORTA      = if(($result = Read-Host "Resposta") -eq ''){"$DEFAULTPORT"}else{$result}
   Write-Host "================================================================================================================="
   Write-Host ""

   #PREENCHENDO .CONF COM AS INFORMAÇÕES INSERIDAS
   $alteraconf_mudapasta = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudapasta","$PASTA")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudapasta)
   $alteraconf_mudaip = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudaip","$IP")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudaip)
   $alteraconf_mudahostname = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudahostname","$HOSTNAME")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudahostname)
   $alteraconf_mudatimeout = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudatimeout","$TIMEOUT")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudatimeout)
   $alteraconf_mudaremotecom = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudaremotecom","$REMOTE")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudaremotecom)
   $alteraconf_mudalogremotecom = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudalogremotecom","$REMOTELOG")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudalogremotecom)
   $alteraconf_mudaporta = [System.IO.File]::ReadAllText("c:\$PASTA\zabbix_agentd.conf.txt").Replace("mudaporta","$PORTA")
   [System.IO.File]::WriteAllText("c:\$PASTA\zabbix_agentd.conf.txt", $alteraconf_mudaporta)
   Rename-Item "c:\$PASTA\zabbix_agentd.conf.txt" "c:\$PASTA\zabbix_agentd.conf"

   cls
   cd "c:\$PASTA"
   Write-Host "================================================================================================================="
   Write-Host "= Instalando e iniciando serviço, aguarde um momento.                                                           ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   & "c:\$PASTA\zabbix_agentd.exe" -i -c "c:\$PASTA\zabbix_agentd.conf"
   & "c:\$PASTA\zabbix_agentd.exe" -s -c "c:\$PASTA\zabbix_agentd.conf"
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "= Liberando porta no firewall do windows, aguarde um momento.                                                   ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   netsh advfirewall firewall add rule name="ZABBIX" dir=in action=allow protocol=TCP localport=$PORTA
   Write-Host "================================================================================================================="
   Write-Host "= Testando conectividade do Server/Proxy, aguarde um momento.                                                   ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2


   #TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = SUCESSO
   Try   {
   $connection = (New-Object Net.Sockets.TcpClient)
   $connection.Connect("$IP",10051)
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __                                                                  ="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /                                                                  ="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /                               ZAWIN                               ="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /                         RESUMO DE INSTALAÇÃO                       ="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/                                                                     ="
   Write-Host "=                                                                                                               ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Server/ServerActive           = $IP"
   Write-Host "INFO: Hostname                      = $HOSTNAME"
   Write-Host "INFO: Timeout                       = $TIMEOUT"
   Write-Host "INFO: EnableRemoteCommands          = $REMOTE"
   Write-Host "INFO: LogRemoteCommands             = $REMOTELOG"
   Write-Host "INFO: ListenPort                    = $PORTA"
   Write-Host "INFO: Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX"
   Write-Host "INFO: UserParameters                = c:\$PASTA\monitoramento\userparameters\"
   Write-Host "INFO: Scripts                       = c:\$PASTA\monitoramento\scripts\"
   Write-Host "INFO: LogFile                       = c:\$PASTA\zabbix_agentd.log"
   Write-Host "INFO: Diretório                     = c:\$PASTA"
   Write-Host "INFO: Versão                        = $VERSION"
   Write-Host "INFO: S.O                           = $WINDOWS_SO$WINDOWS_ARQ"
   Write-Host "INFO: Share                         = $SHARE"
   Write-Host "INFO: Conectividade Server/Proxy    = Conexão em $IP $DEFAULTPORTCON Sucesso"
   Write-Host "================================================================================================================="
   cd c:\
   }

   #TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = FALHA
   Catch {
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __                                                                  ="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /                                                                  ="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /                               ZAWIN                               ="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /                         RESUMO DE INSTALAÇÃO                       ="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/                                                                     ="
   Write-Host "=                                                                                                               ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Server/ServerActive           = $IP"
   Write-Host "INFO: Hostname                      = $HOSTNAME"
   Write-Host "INFO: Timeout                       = $TIMEOUT"
   Write-Host "INFO: EnableRemoteCommands          = $REMOTE"
   Write-Host "INFO: LogRemoteCommands             = $REMOTELOG"
   Write-Host "INFO: ListenPort                    = $PORTA"
   Write-Host "INFO: Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX"
   Write-Host "INFO: UserParameters                = c:\$PASTA\monitoramento\userparameters\"
   Write-Host "INFO: Scripts                       = c:\$PASTA\monitoramento\scripts\"
   Write-Host "INFO: LogFile                       = c:\$PASTA\zabbix_agentd.log"
   Write-Host "INFO: Diretório                     = c:\$PASTA"
   Write-Host "INFO: Versão                        = $VERSION"
   Write-Host "INFO: S.O                           = $WINDOWS_SO$WINDOWS_ARQ"
   Write-Host "INFO: Share                         = $SHARE"
   Write-Host "ERRO: Conectividade Server/Proxy    = Conexão em $IP $DEFAULTPORTCON Falhou"
   Write-Host "================================================================================================================="
   cd c:\
    }
   }
  }
 }
}

# OPTION SHAREREMOVE ################################################################################
# BR - Remove zabbix agente windows x.x.x rede.                                                     #
# EN - Remove zabbix agent windows x.x.x rede.                                                      #
#####################################################################################################

if ( $select -like 'SHAREREMOVE' )
{
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __  NAME: ZAWIN ====================================================="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /  DESCRIPTION: ZABBIX AGENT INSTALL WINDOWS ======================="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /   VERSION: $VERS =================================================="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /    CREATE: $VERCREATE =============================================="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/     UPDATE: $VERUPDATE =============================================="
   Write-Host "=                                               AUTHOR: $VERSCRIPTAUTHOR ========================================"
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                          REMOVE: Bem vindo ao assistente de remoção do zabbix agente                          ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""
   cls

   Write-Host "================================================================================================================="
   Write-Host "= O script irá desinstalar por completo o zabbix agente, aguarde um momento.                                    ="
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "INFO: Qual o diretório onde seu zabbix agente foi instalado?"
   Write-Host "INFO: Digite apenas o diretório, a raiz c:\ será preenchida automaticamente."
   Write-Host "INFO: Digite apenas o diretório sem a \ no final."
   Write-Host "INFO: Ex: digitando o diretório zabbix, o agente será removido de c:\zabbix"
   Write-Host "INFO: Default c:\$DEFAULTFOLDER"
   Write-Host "================================================================================================================="
   Write-Host ""

   $PASTA = if(($result = Read-Host "c:\") -eq ''){"$DEFAULTFOLDER"}else{$result}
   $DATAATUAL      = Get-Date -Uformat "%d-%m-%Y"
   $VERIFICA_PASTA = Test-Path "c:\$PASTA" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   Write-Host ""

   #IF VERIFICA_PASTA = 0 = NÃO ENCONTRADA
   If ($VERIFICA_PASTA –eq 0) {

   Write-Host "================================================================================================================="
   Write-Host "ERRO: Diretório c:\$PASTA não encontrado, verifique se é o diretório correto e tente novamente."
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\

   #ELSE VERIFICA_PASTA = 1 = ENCONTRADA
   } else {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Realizando backup, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 3
   Copy-Item -Path "c:\$PASTA\" -Destination "c:\$PASTA.backup.$DATAATUAL" -Recurse

   cls
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Parando o serviço do zabbix agente, aguarde um momento."
   Write-Host "================================================================================================================="
   Start-Sleep -s 2
   net stop "Zabbix Agent"
   Write-Host "================================================================================================================="
   Write-Host "INFO: Removendo o serviço do zabbix agente, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   & "c:\$PASTA\zabbix_agentd.exe" -d -c "c:\$PASTA\zabbix_agentd.conf"
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Removendo regra de firewall do zabbix agente no windows, aguarde um momento."
   Write-Host "================================================================================================================="
   Start-Sleep -s 2
   netsh advfirewall firewall delete rule name="ZABBIX"
   Write-Host "================================================================================================================="
   Write-Host "INFO: Removendo diretório de instalação em c:\$PASTA"
   Write-Host "================================================================================================================="
   Remove-Item "c:\$PASTA" -Recurse
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Diretório de instalação original c:\$PASTA removido com sucesso."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Seu zabbix agente foi removido com sucesso."
   Write-Host "INFO: Backup salvo em c:\$PASTA.backup.$DATAATUAL"
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\
 }
}

# OPTION SHARECHANGE ################################################################################
# BR - Upgrade/Downgrade do zabbix agente windows x.x.x rede.                                       #
# EN - Upgrade/Downgrade of zabbix agent windows x.x.x rede.                                        #
#####################################################################################################

if ( $select -like 'SHARECHANGE' )
{
   cls
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "= Verificando existência do zabbix agente no host, aguarde um momento...                                        ="
   Write-Host "================================================================================================================="
   Write-Host ""
   #VERIFICA SE O SERVIÇO ZABBIX AGENT JA EXISTE
   $VERIFICA_SERVICO = Get-Service "Zabbix Agent" -ErrorAction SilentlyContinue | Measure-Object -Line | select-object Lines | select-object -ExpandProperty Lines
   #VERIFICA A ARQUITETURA DO S.O "X86" OU "X64"
   $VERIFICA_SO = Test-Path "c:\Program Files (x86)" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #VERIFICA WINDOWS VERSÃO
   $WINDOWS_SO = (Get-WmiObject -class Win32_OperatingSystem).Caption
   #VERIFICA WINDOWS ARQUITETURA
   $WINDOWS_ARQ = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

   #IF VERIFICA_SERVICO
   If ($VERIFICA_SERVICO –eq 0) {

   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "ERRO: Desculpe, o zabbix agente não foi encontrado."
   Write-Host "ERRO: O assistente de upgrade/downgrade será cancelado."
   Write-Host "ERRO: Por favor, execute a instalação com o parâmetro SHAREINSTALL"
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\

   #ELSE VERIFICA_SERVICO
   } else {

   #IF VERIFICA_SO
   If ($VERIFICA_SO –eq 1) {

   #1º Parte IF VERIFICA_SO = 1 = Windows 64 Bits
   Start-Sleep -s 2
   cls

   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __  NAME: ZAWIN ====================================================="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /  DESCRIPTION: ZABBIX AGENT INSTALL WINDOWS ======================="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /   VERSION: $VERS =================================================="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /    CREATE: $VERCREATE =============================================="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/     UPDATE: $VERUPDATE =============================================="
   Write-Host "=                                               AUTHOR: $VERSCRIPTAUTHOR ========================================"
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                     CHANGE: Bem vindo ao assistente de upgrade/downgrade do zabbix agente                     ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""
   cls

   Write-Host "================================================================================================================="
   Write-Host "INFO: Serviço zabbix agente encontrado, iniciando assistente de upgrade/downgrade"
   Write-Host "INFO: Detectado $WINDOWS_SO$WINDOWS_ARQ, continuando atualização."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Qual o diretório onde seu zabbix agente foi instalado?"
   Write-Host "INFO: Digite apenas o diretório, a raiz c:\ será preenchida automaticamente."
   Write-Host "INFO: Digite apenas o diretório sem a \ no final."
   Write-Host "INFO: Ex: digitando o diretório zabbix, o agente será atualizado em c:\zabbix"
   Write-Host "INFO: Default c:\$DEFAULTFOLDER"
   Write-Host "================================================================================================================="
   Write-Host ""
   $PASTA = if(($result = Read-Host "c:\") -eq ''){"$DEFAULTFOLDER"}else{$result}
   Write-Host ""
   cls
   
   $VERIFICAVERSION = Test-Path "c:\$PASTA\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #IF VERIFICAVERSION = 0 = NÃO ENCONTRADO
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Verificando versão atual do zabbix agente, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "ERRO: Não foi possível identificar a versão do zabbix agente."
   Write-Host "ERRO: Talvez o zabbix_agentd.exe não esteja localizado no diretório c:\$PASTA"
   Write-Host "ERRO: O assistente de upgrade/downgrade será cancelado."
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\

   #ELSE VERIFICAVERSION = 1 = ENCONTRADO
   } else {

   $VERSIONOLD = Get-ChildItem "c:\$PASTA\zabbix_agentd.exe" | Select-Object -ExpandProperty VersionInfo | select-object ProductVersion | select-object -ExpandProperty ProductVersion
   Write-Host "================================================================================================================="
   Write-Host "INFO: Verificando versão atual do zabbix agente, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão $VERSIONOLD encontrada, continuando atualização."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Digite a versão que deseja realizar upgrade/downgrade Ex: 3.0.x, 3.2.x, 3.4.x ou 4.0.x"
   Write-Host "INFO: Default $DEFAULTVERSION"
   Write-Host "================================================================================================================="
   Write-Host ""
   $CHANGEVERSION = if(($result = Read-Host "Versão") -eq ''){"$DEFAULTVERSION"}else{$result}
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                                                   ATENÇÃO!                                                    ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão $VERSIONOLD será removida."
   Write-Host "INFO: Versão $CHANGEVERSION será instalada."
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""
   cls

   $INSTALLVERSION = Test-Path "$SHARE\versao\$CHANGEVERSION\win64\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #IF INSTALLVERSION = 0 = NÃO ENCONTRADO
   If ($INSTALLVERSION –eq 0) {

   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Verificando Instalador, aguarde um momento."
   Write-Host "INFO: Buscando versão em $SHARE"
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "ERRO: Desculpe, a versão $CHANGEVERSION não foi encontrada no instalador."
   Write-Host "ERRO: O assistente de upgrade/downgrade será cancelado."
   Write-Host "ERRO: Verifique as versões disponíveis em $SHARE\versao\"
   Write-Host "================================================================================================================="
   Write-Host ""

   #ELSE INSTALLVERSION = 1 = ENCONTRADO
   } else {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão $CHANGEVERSION encontrada, continuando atualização."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Removendo zabbix agente $VERSIONOLD, aguarde um momento."
   Write-Host "================================================================================================================="
   Start-Sleep -s 2
   net stop "Zabbix Agent"
   Write-Host "================================================================================================================="
   Write-Host "INFO: Copiando executáveis da versão $CHANGEVERSION, aguarde um momento."
   Write-Host "================================================================================================================="
   Start-Sleep -s 2
   Remove-Item "c:\$PASTA\*.exe" -Recurse
   Copy-Item "$SHARE\versao\$CHANGEVERSION\win64\*.*" -Destination "c:\$PASTA\" -Recurse
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Iniciando serviço do zabbix agente $CHANGEVERSION, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   net start "Zabbix Agent"
   Start-Sleep -s 2
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __                                                                  ="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /                                                                  ="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /                               ZAWIN                               ="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /                     RESUMO DO UPGRADE/DOWNGRADE                    ="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/                                                                     ="
   Write-Host "=                                                                                                               ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão = $VERSIONOLD removida com sucesso"
   Write-Host "INFO: Versão = $CHANGEVERSION instalada com sucesso"
   Write-Host "INFO: S.O    = $WINDOWS_SO$WINDOWS_ARQ"
   Write-Host "INFO: Share  = $SHARE"
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\
 }
}

   #ELSE VERIFICA_SO
   } else {

   #2º Parte IF VERIFICA_SO = 0 = Windows 32 Bits
   Start-Sleep -s 2
   cls

   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __  NAME: ZAWIN ====================================================="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /  DESCRIPTION: ZABBIX AGENT INSTALL WINDOWS ======================="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /   VERSION: $VERS =================================================="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /    CREATE: $VERCREATE =============================================="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/     UPDATE: $VERUPDATE =============================================="
   Write-Host "=                                               AUTHOR: $VERSCRIPTAUTHOR ========================================"
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                     CHANGE: Bem vindo ao assistente de upgrade/downgrade do zabbix agente                     ="
   Write-Host "= ATENÇÃO: Todos os campos são obrigatórios, se deixado em branco o valor será preenchido com o valor (Default) ="
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""
   cls

   Write-Host "================================================================================================================="
   Write-Host "INFO: Serviço zabbix agente encontrado, iniciando assistente de upgrade/downgrade"
   Write-Host "INFO: Detectado $WINDOWS_SO$WINDOWS_ARQ, continuando atualização."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Qual o diretório onde seu zabbix agente foi instalado?"
   Write-Host "INFO: Digite apenas o diretório, a raiz c:\ será preenchida automaticamente."
   Write-Host "INFO: Digite apenas o diretório sem a \ no final."
   Write-Host "INFO: Ex: digitando o diretório zabbix, o agente será atualizado em c:\zabbix"
   Write-Host "INFO: Default c:\$DEFAULTFOLDER"
   Write-Host "================================================================================================================="
   Write-Host ""
   $PASTA = if(($result = Read-Host "c:\") -eq ''){"$DEFAULTFOLDER"}else{$result}
   Write-Host ""
   cls

   $VERIFICAVERSION = Test-Path "c:\$PASTA\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #IF VERIFICAVERSION = 0 = NÃO ENCONTRADO
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Verificando versão atual do zabbix agente, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "ERRO: Não foi possível identificar a versão do zabbix agente."
   Write-Host "ERRO: Talvez o zabbix_agentd.exe não esteja localizado no diretório c:\$PASTA"
   Write-Host "ERRO: O assistente de upgrade/downgrade será cancelado."
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\

   #ELSE VERIFICAVERSION = 1 = ENCONTRADO
   } else {

   $VERSIONOLD = Get-ChildItem "c:\$PASTA\zabbix_agentd.exe" | Select-Object -ExpandProperty VersionInfo | select-object ProductVersion | select-object -ExpandProperty ProductVersion
   Write-Host "================================================================================================================="
   Write-Host "INFO: Verificando versão atual do zabbix agente, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão $VERSIONOLD encontrada, continuando atualização."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Digite a versão que deseja realizar upgrade/downgrade Ex: 3.0.x, 3.2.x, 3.4.x ou 4.0.x"
   Write-Host "INFO: Default $DEFAULTVERSION"
   Write-Host "================================================================================================================="
   Write-Host ""
   $CHANGEVERSION = if(($result = Read-Host "Versão") -eq ''){"$DEFAULTVERSION"}else{$result}
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "=                                                   ATENÇÃO!                                                    ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão $VERSIONOLD será removida."
   Write-Host "INFO: Versão $CHANGEVERSION será instalada."
   Write-Host "================================================================================================================="
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione ENTER para continuar'
   Write-Host ""
   cls

   $INSTALLVERSION = Test-Path "$SHARE\versao\$CHANGEVERSION\win32\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   #IF INSTALLVERSION = 0 = NÃO ENCONTRADO
   If ($INSTALLVERSION –eq 0) {

   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Verificando Instalador, aguarde um momento."
   Write-Host "INFO: Buscando versão em $SHARE"
   Write-Host "================================================================================================================="
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "================================================================================================================="
   Write-Host "ERRO: Desculpe, a versão $CHANGEVERSION não foi encontrada no instalador."
   Write-Host "ERRO: O assistente de upgrade/downgrade será cancelado."
   Write-Host "ERRO: Verifique as versões disponíveis em $SHARE\versao\"
   Write-Host "================================================================================================================="
   Write-Host ""

   #ELSE INSTALLVERSION = 1 = ENCONTRADO
   } else {

   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão $CHANGEVERSION encontrada, continuando atualização."
   Write-Host "================================================================================================================="
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Removendo zabbix agente $VERSIONOLD, aguarde um momento."
   Write-Host "================================================================================================================="
   Start-Sleep -s 2
   net stop "Zabbix Agent"
   Write-Host "================================================================================================================="
   Write-Host "INFO: Copiando executáveis da versão $CHANGEVERSION, aguarde um momento."
   Write-Host "================================================================================================================="
   Start-Sleep -s 2
   Remove-Item "c:\$PASTA\*.exe" -Recurse
   Copy-Item "$SHARE\versao\$CHANGEVERSION\win32\*.*" -Destination "c:\$PASTA\" -Recurse
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "INFO: Iniciando serviço do zabbix agente $CHANGEVERSION, aguarde um momento."
   Write-Host "================================================================================================================="
   Write-Host ""
   net start "Zabbix Agent"
   Start-Sleep -s 2
   cls
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __                                                                  ="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /                                                                  ="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /                               ZAWIN                               ="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /                     RESUMO DO UPGRADE/DOWNGRADE                    ="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/                                                                     ="
   Write-Host "=                                                                                                               ="
   Write-Host "================================================================================================================="
   Write-Host "INFO: Versão = $VERSIONOLD removida com sucesso"
   Write-Host "INFO: Versão = $CHANGEVERSION instalada com sucesso"
   Write-Host "INFO: S.O    = $WINDOWS_SO$WINDOWS_ARQ"
   Write-Host "INFO: Share  = $SHARE"
   Write-Host "================================================================================================================="
   Write-Host ""
   cd c:\
    }
   }
  }
 }
}

if ( $select -like '' )
{
   Write-Host ""
   Write-Host "================================================================================================================="
   Write-Host "= _____________ ___       _______________   __  NAME: ZAWIN ====================================================="
   Write-Host "= ___  /___    |__ |     / /____  _/___  | / /  DESCRIPTION: ZABBIX AGENT INSTALL WINDOWS ======================="
   Write-Host "= __  / __  /| |__ | /| / /  __  /  __   |/ /   VERSION: $VERS =================================================="
   Write-Host "= _  /___  ___ |__ |/ |/ /  __/ /   _  /|  /    CREATE: $VERCREATE =============================================="
   Write-Host "= /____//_/  |_|____/|__/   /___/   /_/ |_/     UPDATE: $VERUPDATE =============================================="
   Write-Host "=                                               AUTHOR: $VERSCRIPTAUTHOR ========================================"
   Write-Host "================================================================================================================="
   Write-Host "= USAGE: LOCALINSTALL | LOCALREMOVE | LOCALCHANGE                                                               ="
   Write-Host "= USAGE: SHAREINSTALL | SHAREREMOVE | SHARECHANGE                                                               ="
   Write-Host "=                                                                                                               ="
   Write-Host "= Ex: .\zabbix.agent.install.win.ps1 LOCALINSTALL                                                               ="
   Write-Host "= Ex: .\zabbix.agent.install.win.ps1 LOCALREMOVE                                                                ="
   Write-Host "= Ex: .\zabbix.agent.install.win.ps1 LOCALCHANGE                                                                ="
   Write-Host "= Ex: \\IPSERVIDOR\SHARE\INSTALADOR\zabbix.agent.install.win.ps1 SHAREINSTALL                                   ="
   Write-Host "= Ex: \\IPSERVIDOR\SHARE\INSTALADOR\zabbix.agent.install.win.ps1 SHAREREMOVE                                    ="
   Write-Host "= Ex: \\IPSERVIDOR\SHARE\INSTALADOR\zabbix.agent.install.win.ps1 SHARECHANGE                                    ="
   Write-Host "================================================================================================================="
   Write-Host "= IPSERVIDOR: Endereço IP/DNS do Fileserver. (Ex: 192.168.1.100)                                                ="
   Write-Host "= SHARE:      Nome do compartilhamento que irá conter o instalador. (Ex: zabbix)                                ="
   Write-Host "= INSTALADOR: Nome do diretório que contém o .conf, versões e script. (Ex: zabbix.agent.install.win)            ="
   Write-Host "= OBS:        \\IPSERVIDOR\SHARE\INSTALADOR = \\192.168.1.100\zabbix\zabbix.agent.install.win                   ="
   Write-Host "================================================================================================================="
   Write-Host ""
}