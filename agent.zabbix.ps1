# Desenvolvido por Diego Cavalcante - 29/08/2017
# Script: agent.zabbix.ps1
# E-Mail: diego@suportecavalcante.com.br
# Skype: suportecavalcante
# Contribuição: Mário Alves - marioalves_2009@uninove.edu.br ( Instalação via compartilhamento de rede e validações )
#
# Criação = Versão 1.0.0 29/08/2017 (Script Básico de instalação do Zabbix Agent).
# Update  = Versão 1.1.0 30/08/2017 (ADD Campo "Pasta de Instalação", ADD Selecionar Porta, ADD Liberar Firewall).
# Update  = Versão 1.2.0 31/08/2017 (ADD Opção REMOVE Agent Full e cria um backup da pasta original com a data atual).
# Update  = Versão 1.3.0 31/08/2017 (ADD Opção de selecionar a versão de instalação).
# Update  = Versão 1.4.0 01/09/2017 (ADD Teste de conectividade na porta 10051 do Server/Proxy).
# Update  = Versão 1.5.0 02/09/2017 (ADD Opção CHANGE para Upgrade/Downgrade de versão do Zabbix Agent).
# Update  = Versão 1.6.0 05/09/2017 (ADD INSTALL Opção que verifica se a versão escolhida existe no instalador).
# Update  = Versão 1.7.0 08/12/2017 (ADD Variável que substitui no zabbix_agentd.conf tudo que foi digitado interativamente).
# Update  = Versão 1.8.0 09/12/2017 (ADD CHANGE Opção que verifica se a versão escolhida existe no instalador).
# Update  = Versão 1.9.0 11/12/2017 (Contribuição Mário Alves - ADD parâmetros para instalação via compartilhamento de rede e validações).
# Update  = Versão 1.9.1 16/12/2017 (Obrigado @amarodefarias - Correção ao fazer upgrade/downgrade em diretórios que contêm espaços).

# Parametros
Param(
  [string]$select
)

#############################################
# Variáveis da versão                       #
#############################################
$UPDATE = "16/12/2017"
$UPDATEV = "1.9.1"


#############################################
# Variáveis da pasta compartilhada em rede  #
#############################################
$INSTALADOR = "agent.zabbix"
$SRV = "\\IPSERVIDOR"
$SHARE = "$SRV\compartilhamento\$INSTALADOR"

########################################
# Instalação Zabbix Agent x.x.x Local  #
########################################

if ( $select -like 'LOCALINSTALL' )
{   
   cls
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Verificando Existência do Zabbix Agent no Host                                              #"
   Write-Host "#############################################################################################"
   Write-Host ""
### VERIFICA SE O SERVIÇO ZABBIX AGENT JA EXISTE
$VERIFICA_INSTALL = Get-Service "Zabbix Agent" -ErrorAction SilentlyContinue | Measure-Object -Line | select-object Lines | select-object -ExpandProperty Lines
### VERIFICA A ARQUITETURA DO S.O "X86" OU "X64"
$VERIFICA_SO      = Test-Path "c:\Program Files (x86)" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### VERIFICA WINDOWS VERSÃO
$WINDOWS_SO = (Get-WmiObject -class Win32_OperatingSystem).Caption
### VERIFICA WINDOWS ARQUITETURA
$WINDOWS_ARQ = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

### IF VERIFICA_INSTALL #################################################################################### 
   If ($VERIFICA_INSTALL –eq 1) {

   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Zabbix Agent já existe, instalação abortada.                                                #"
   Write-Host "Se deseja remover o Zabbix Agent por completo, execute o script com o parâmetro LOCALREMOVE #"
   Write-Host "Se deseja realizar Upgrade/Downgrade, execute o script com o parâmetro LOCALCHANGE          #"
   Write-Host "#############################################################################################"
   Write-Host ""

### ELSE VERIFICA_INSTALL ##################################################################################
   } else {

### IF VERIFICA_SO #########################################################################################
   If ($VERIFICA_SO –eq 1) {

### 1º Parte IF VERIFICA_SO = 1 = Windows 64 Bits ##########################################################

   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "                    Bem vindo ao Assistente de Instalação do Zabbix Agent                    "
   Write-Host "                           Script Desenvolvido por Diego Cavalcante                          "
   Write-Host "                                  Update: $UPDATE - $UPDATEV                                 "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host "0000000000          10000000   00000000        10000         00000  00001  00000  00000000000"
   Write-Host "00000000000000000  00000000  0  0000000 .00000  0000  000000  0000  000000  010  000000000000"
   Write-Host "000000000000000  100000001  000  100000 .00000   000  00000.  0000  0000000  0  0000000000000"
   Write-Host "0000000000000  1000000000  00000  00000        =0000         =0000  00000000   00000000000000"
   Write-Host "000000000000  1000000000           0000 .00000   000  000000   000  0000000  0  0000000000000"
   Write-Host "00000000000  1000000000   0000000   000 .00000   000  000000   000  000000  010  000000000000"
   Write-Host "0000000001          00   000000000   00         1000          1000  00000  00000  00000000000"
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""

   cls

   Write-Host "#############################################################################################"
   Write-Host "Zabbix Agent não encontrado, iniciando instalaçao...                                         "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "$WINDOWS_SO $WINDOWS_ARQ, continuando instalação...                                          "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Configurando Zabbix Agent                                                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Qual a versão do Zabbix Agent deseja instalar? Ex: 3.2.7 ou 3.4.1                            "
   Write-Host "#############################################################################################"
   Write-Host ""
   $VERSION    = Read-Host 'Versão'
   Write-Host ""

$VERIFICAVERSION = Test-Path "c:\agent.zabbix\versao\$VERSION" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### IF VERIFICAVERSION = 0 = NÃO ENCONTRADO ################################################################  
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "#############################################################################################"
   Write-Host "Desculpe, a versão $CHANGEVERSION não foi encontrada no instalador.                          "
   Write-Host "Por esse motivo a instalação será abortada.                                                  "
   Write-Host "Por favor, verifique a pasta C:\agent.zabbix\versao\ para ver as versões disponíveis.        "
   Write-Host "#############################################################################################"
   Write-Host ""

### ELSE VERIFICAVERSION = 1 = ENCONTRADO ##################################################################
   } else {

   Write-Host "#############################################################################################"
   Write-Host "Onde Deseja Instalar o Zabbix Agent?                                                         "
   Write-Host "Digite apenas o diretório, a raiz c:\ será preenchida automaticamente.                       "
   Write-Host "Digite apenas o diretório sem a \ no final.                                                  "
   Write-Host "Ex: c:\zabbix ou c:\empresa\zabbix                                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   $PASTA   = Read-Host 'c:\'
   md "c:\$PASTA\monitoramento\scripts\"
   md "c:\$PASTA\monitoramento\userparameters\"
   Copy-Item "c:\agent.zabbix\versao\$VERSION\win64\*.*" -Destination "c:\$PASTA\" -Recurse
   Copy-Item "c:\agent.zabbix\monitoramento\scripts\*.*" -Destination "c:\$PASTA\monitoramento\scripts\" -Recurse
   Copy-Item "c:\agent.zabbix\monitoramento\userparameters\*.*" -Destination "c:\$PASTA\monitoramento\userparameters\" -Recurse
   copy-Item "c:\agent.zabbix\zabbix_agentd.conf" -Destination "c:\$PASTA" -Recurse
   Rename-Item "c:\$PASTA\zabbix_agentd.conf" "c:\$PASTA\zabbix_agentd.conf.txt"

   cls

   Write-Host "#############################################################################################"
   Write-Host "                                 Configurando Zabbix Agent                                   "
   Write-Host "                             Todos os Campos são Obrigatórios                                "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $IP         = Read-Host 'Qual o IP/DNS do Zabbix Server ou Proxy?'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $HOSTNAME   = Read-Host 'Qual o Nome do Host?'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $TIMEOUT    = Read-Host 'Qual o Timeout do Host? Entre 0 e 30 segundos'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $REMOTE     = Read-Host 'Deseja Habilitar o Comando Remoto no Host? (0)Desabilita (1)Habilita'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $REMOTELOG  = Read-Host 'Deseja Habilitar o LOG do Comando Remoto no Host? (0)Desabilita (1)Habilita'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $PORTA      = Read-Host 'Qual a Porta de Comunicação do Zabbix Agent? Ex: 10050 (Padrão)'
   Write-Host "#############################################################################################"
   Write-Host ""

### PREENCHENDO .CONF COM AS INFRMAÇÕES DIGITADAS ##########################################################
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
   Write-Host "#############################################################################################"
   Write-Host "Instalando e iniciando serviço...                                                            "
   Write-Host "#############################################################################################"
   Write-Host ""
   & "c:\$PASTA\zabbix_agentd.exe" -i -c "c:\$PASTA\zabbix_agentd.conf"
   & "c:\$PASTA\zabbix_agentd.exe" -s -c "c:\$PASTA\zabbix_agentd.conf"
   Start-Sleep -s 2
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço instalado com sucesso.                                                               "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Liberando porta $PORTA no Firewall do Windows                                                "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   Write-Host ""
   netsh advfirewall firewall add rule name="ZABBIX" dir=in action=allow protocol=TCP localport=$PORTA
   Write-Host "#############################################################################################"
   Write-Host "Porta $PORTA no Firewall liberada com sucesso, nome da regra = ZABBIX                        "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Testando conectividade do Server/Proxy $IP na porta 10051                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2

### TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = SUCESSO ######################################################
Try   {
   $connection = (New-Object Net.Sockets.TcpClient)
   $connection.Connect("$IP",10051)
   Write-Host "#############################################################################################"
   Write-Host "                                    Resumo da Instalação                                     "
   Write-Host "#############################################################################################"
   Write-Host "Server                        = $IP                                                          "
   Write-Host "ServerActive                  = $IP                                                          "
   Write-Host "Hostname                      = $HOSTNAME                                                    "
   Write-Host "Timeout                       = $TIMEOUT                                                     "
   Write-Host "EnableRemoteCommands          = $REMOTE                                                      "
   Write-Host "LogRemoteCommands             = $REMOTELOG                                                   "
   Write-Host "ListenPort                    = $PORTA                                                       "
   Write-Host "Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX                "
   Write-Host "UserParameters                = c:\$PASTA\monitoramento\userparameters\                      "
   Write-Host "Scripts                       = c:\$PASTA\monitoramento\scripts\                             "
   Write-Host "LogFile                       = c:\$PASTA\zabbix_agentd.log                                  "
   Write-Host "Diretório                     = c:\$PASTA                                                    "
   Write-Host "Versão                        = $VERSION                                                     "
   Write-Host "S.O                           = $WINDOWS_SO $WINDOWS_ARQ                                     "
   Write-Host "Conectividade em Server/Proxy = Conexão em $IP 10051 Sucesso                                 "
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, Zabbix Agent Instalado com Sucesso.                                                "
   Write-Host "#############################################################################################"
   cd c:\agent.zabbix
      }

### TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = FALHA ########################################################
Catch {
   Write-Host "#############################################################################################"
   Write-Host "                                    Resumo da Instalação                                     "
   Write-Host "#############################################################################################"
   Write-Host "Server                        = $IP                                                          "
   Write-Host "ServerActive                  = $IP                                                          "
   Write-Host "Hostname                      = $HOSTNAME                                                    "
   Write-Host "Timeout                       = $TIMEOUT                                                     "
   Write-Host "EnableRemoteCommands          = $REMOTE                                                      "
   Write-Host "LogRemoteCommands             = $REMOTELOG                                                   "
   Write-Host "ListenPort                    = $PORTA                                                       "
   Write-Host "Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX                "
   Write-Host "UserParameters                = c:\$PASTA\monitoramento\userparameters\                      "
   Write-Host "Scripts                       = c:\$PASTA\monitoramento\scripts\                             "
   Write-Host "LogFile                       = c:\$PASTA\zabbix_agentd.log                                  "
   Write-Host "Diretório                     = c:\$PASTA                                                    "
   Write-Host "Versão                        = $VERSION                                                     "
   Write-Host "S.O                           = $WINDOWS_SO $WINDOWS_ARQ                                     "
   Write-Host "Conectividade em Server/Proxy = Conexão em $IP 10051 Falhou                                  "
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, Zabbix Agent Instalado com Sucesso.                                                "
   Write-Host "#############################################################################################"
   cd c:\agent.zabbix
   }
 }

### 2º Parte IF VERIFICA_SO = 0 = Windows 32 Bits ########################################################## 

### ELSE VERIFICA_SO #######################################################################################
   } else {

   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "                    Bem vindo ao Assistente de Instalação do Zabbix Agent                    "
   Write-Host "                           Script Desenvolvido por Diego Cavalcante                          "
   Write-Host "                                  Update: $UPDATE - $UPDATEV                                 "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host "0000000000          10000000   00000000        10000         00000  00001  00000  00000000000"
   Write-Host "00000000000000000  00000000  0  0000000 .00000  0000  000000  0000  000000  010  000000000000"
   Write-Host "000000000000000  100000001  000  100000 .00000   000  00000.  0000  0000000  0  0000000000000"
   Write-Host "0000000000000  1000000000  00000  00000        =0000         =0000  00000000   00000000000000"
   Write-Host "000000000000  1000000000           0000 .00000   000  000000   000  0000000  0  0000000000000"
   Write-Host "00000000000  1000000000   0000000   000 .00000   000  000000   000  000000  010  000000000000"
   Write-Host "0000000001          00   000000000   00         1000          1000  00000  00000  00000000000"
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""

   cls

   Write-Host "#############################################################################################"
   Write-Host "Zabbix Agent não encontrado, iniciando instalaçao...                                         "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "$WINDOWS_SO $WINDOWS_ARQ, continuando instalação...                                          "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Configurando Zabbix Agent                                                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Qual a versão do Zabbix Agent deseja instalar? Ex: 3.2.7 ou 3.4.1"
   Write-Host "#############################################################################################"
   Write-Host ""
   $VERSION    = Read-Host 'Versão'
   Write-Host ""

$VERIFICAVERSION = Test-Path "c:\agent.zabbix\versao\$VERSION" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### IF VERIFICAVERSION = 0 = NÃO ENCONTRADO ################################################################     
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "#############################################################################################"
   Write-Host "Desculpe, a versão $CHANGEVERSION não foi encontrada no instalador.                          "
   Write-Host "Por esse motivo a instalação será abortada.                                                  "
   Write-Host "Por favor, verifique a pasta C:\agent.zabbix\versao\ para ver as versões disponíveis.        "
   Write-Host "#############################################################################################"
   Write-Host ""

### ELSE VERIFICAVERSION = 1 = ENCONTRADO ##################################################################
   } else {

   Write-Host "#############################################################################################"
   Write-Host "Onde Deseja Instalar o Zabbix Agent?                                                         "
   Write-Host "Digite apenas o diretório, a raiz c:\ será preenchida automaticamente.                       "
   Write-Host "Digite apenas o diretório sem a \ no final.                                                  "
   Write-Host "Ex: c:\zabbix ou c:\empresa\zabbix                                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   $PASTA   = Read-Host 'c:\'
   md "c:\$PASTA\monitoramento\scripts\"
   md "c:\$PASTA\monitoramento\userparameters\"
   Copy-Item "c:\agent.zabbix\versao\$VERSION\win32\*.*" -Destination "c:\$PASTA\" -Recurse
   Copy-Item "c:\agent.zabbix\monitoramento\scripts\*.*" -Destination "c:\$PASTA\monitoramento\scripts\" -Recurse
   Copy-Item "c:\agent.zabbix\monitoramento\userparameters\*.*" -Destination "c:\$PASTA\monitoramento\userparameters\" -Recurse
   copy-Item "c:\agent.zabbix\zabbix_agentd.conf" -Destination "c:\$PASTA" -Recurse
   Rename-Item "c:\$PASTA\zabbix_agentd.conf" "c:\$PASTA\zabbix_agentd.conf.txt"

   cls

   Write-Host "#############################################################################################"
   Write-Host "                                 Configurando Zabbix Agent                                   "
   Write-Host "                             Todos os Campos são Obrigatórios                                "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $IP         = Read-Host 'Qual o IP/DNS do Zabbix Server ou Proxy?'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $HOSTNAME   = Read-Host 'Qual o Nome do Host?'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $TIMEOUT    = Read-Host 'Qual o Timeout do Host? Entre 0 e 30 segundos'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $REMOTE     = Read-Host 'Deseja Habilitar o Comando Remoto no Host? (0)Desabilita (1)Habilita'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $REMOTELOG  = Read-Host 'Deseja Habilitar o LOG do Comando Remoto no Host? (0)Desabilita (1)Habilita'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $PORTA      = Read-Host 'Qual a Porta de Comunicação do Zabbix Agent? Ex: 10050 (Padrão)'
   Write-Host "#############################################################################################"
   Write-Host ""

### PREENCHENDO .CONF COM AS INFRMAÇÕES DIGITADAS ##########################################################
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
   Rename-Item "c:\$PASTA\zabbix_agentd.conf.txt c:\$PASTA\zabbix_agentd.conf"

   cls

   cd "c:\$PASTA"
   Write-Host "#############################################################################################"
   Write-Host "Instalando e iniciando serviço...                                                            "
   Write-Host "#############################################################################################"
   Write-Host ""
   & "c:\$PASTA\zabbix_agentd.exe" -i -c "c:\$PASTA\zabbix_agentd.conf"
   & "c:\$PASTA\zabbix_agentd.exe" -s -c "c:\$PASTA\zabbix_agentd.conf"
   Start-Sleep -s 2
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço instalado com sucesso.                                                               "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Liberando porta $PORTA no Firewall do Windows                                                "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   Write-Host ""
   netsh advfirewall firewall add rule name="ZABBIX" dir=in action=allow protocol=TCP localport=$PORTA
   Write-Host "#############################################################################################"
   Write-Host "Porta $PORTA no Firewall liberada com sucesso, nome da regra = ZABBIX                        "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Testando conectividade do Server/Proxy $IP na porta 10051                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2

### TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = SUCESSO ######################################################
Try   {
   $connection = (New-Object Net.Sockets.TcpClient)
   $connection.Connect("$IP",10051)
   Write-Host "#############################################################################################"
   Write-Host "                                    Resumo da Instalação                                     "
   Write-Host "#############################################################################################"
   Write-Host "Server                        = $IP                                                          "
   Write-Host "ServerActive                  = $IP                                                          "
   Write-Host "Hostname                      = $HOSTNAME                                                    "
   Write-Host "Timeout                       = $TIMEOUT                                                     "
   Write-Host "EnableRemoteCommands          = $REMOTE                                                      "
   Write-Host "LogRemoteCommands             = $REMOTELOG                                                   "
   Write-Host "ListenPort                    = $PORTA                                                       "
   Write-Host "Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX                "
   Write-Host "UserParameters                = c:\$PASTA\monitoramento\userparameters\                      "
   Write-Host "Scripts                       = c:\$PASTA\monitoramento\scripts\                             "
   Write-Host "LogFile                       = c:\$PASTA\zabbix_agentd.log                                  "
   Write-Host "Diretório                     = c:\$PASTA                                                    "
   Write-Host "Versão                        = $VERSION                                                     "
   Write-Host "S.O                           = $WINDOWS_SO $WINDOWS_ARQ                                     "
   Write-Host "Conectividade em Server/Proxy = Conexão em $IP 10051 Sucesso                                 "
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, Zabbix Agent Instalado com Sucesso.                                                "
   Write-Host "#############################################################################################"
   cd c:\agent.zabbix
      }

### TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = FALHA ########################################################
Catch {
   Write-Host "#############################################################################################"
   Write-Host "                                    Resumo da Instalação                                     "
   Write-Host "#############################################################################################"
   Write-Host "Server                        = $IP                                                          "
   Write-Host "ServerActive                  = $IP                                                          "
   Write-Host "Hostname                      = $HOSTNAME                                                    "
   Write-Host "Timeout                       = $TIMEOUT                                                     "
   Write-Host "EnableRemoteCommands          = $REMOTE                                                      "
   Write-Host "LogRemoteCommands             = $REMOTELOG                                                   "
   Write-Host "ListenPort                    = $PORTA                                                       "
   Write-Host "Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX                "
   Write-Host "UserParameters                = c:\$PASTA\monitoramento\userparameters\                      "
   Write-Host "Scripts                       = c:\$PASTA\monitoramento\scripts\                             "
   Write-Host "LogFile                       = c:\$PASTA\zabbix_agentd.log                                  "
   Write-Host "Diretório                     = c:\$PASTA                                                    "
   Write-Host "Versão                        = $VERSION                                                     "
   Write-Host "S.O                           = $WINDOWS_SO $WINDOWS_ARQ                                     "
   Write-Host "Conectividade em Server/Proxy = Conexão em $IP 10051 Falhou                                  "
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, Zabbix Agent Instalado com Sucesso.                                                "
   Write-Host "#############################################################################################"
   cd c:\agent.zabbix
    }
   }
  }
 }
}

########################################
# Remoção Zabbix Agent Full Local      #
########################################

if ( $select -like 'LOCALREMOVE' )
{
   cls

   Write-Host "#############################################################################################"
   Write-Host "                     Bem vindo ao Assistente de Remoção do Zabbix Agent                      "
   Write-Host "                         Script Desenvolvido por Diego Cavalcante                            "
   Write-Host "                                  Update: $UPDATE - $UPDATEV                                 "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host "0000000000          10000000   00000000        10000         00000  00001  00000  00000000000"
   Write-Host "00000000000000000  00000000  0  0000000 .00000  0000  000000  0000  000000  010  000000000000"
   Write-Host "000000000000000  100000001  000  100000 .00000   000  00000.  0000  0000000  0  0000000000000"
   Write-Host "0000000000000  1000000000  00000  00000        =0000         =0000  00000000   00000000000000"
   Write-Host "000000000000  1000000000           0000 .00000   000  000000   000  0000000  0  0000000000000"
   Write-Host "00000000000  1000000000   0000000   000 .00000   000  000000   000  000000  010  000000000000"
   Write-Host "0000000001          00   000000000   00         1000          1000  00000  00000  00000000000"
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""

   cls

   Write-Host "#############################################################################################"
   Write-Host "Este script irá desinstalar por completo o Zabbix Agent.                                     "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Qual a pasta onde seu Zabbix Agent foi instalado?                                            "
   Write-Host "Digite apenas o diretório, a raiz c:\ será preenchida automaticamente.                       "
   Write-Host "Digite apenas o diretório sem a \ no final.                                                  "
   Write-Host "Ex: c:\zabbix ou c:\empresa\zabbix                                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   $PASTA          = Read-Host 'c:\'
   $DATAATUAL      = Get-Date -Uformat "%d-%m-%Y"
   $VERIFICA_PASTA = Test-Path "c:\$PASTA" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   Write-Host ""

### IF VERIFICA_PASTA = 0 = NÃO ENCONTRADA ################################################################# 
   If ($VERIFICA_PASTA –eq 0) {

   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Diretório não encontrado, verifique se é o diretório correto e tente novamente.              "
   Write-Host "#############################################################################################"
   Write-Host ""
   cd c:\agent.zabbix

### ELSE VERIFICA_PASTA = 1 = ENCONTRADA ################################################################### 
   } else {

   Write-Host "#############################################################################################"
   Write-Host "Realizando backup, aguarde um momento...                                                     "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Copy-Item -Path "c:\$PASTA\" -Destination "c:\$PASTA.backup.$DATAATUAL" -Recurse

   cls

   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Parando e removendo o serviço do Zabbix Agent, aguarde um momento...                         "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   net stop "Zabbix Agent"
   & "c:\$PASTA\zabbix_agentd.exe" -d -c "c:\$PASTA\zabbix_agentd.conf"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço Zabbix Agent removido com sucesso.                                                   "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Removendo regra de firewall do Zabbix Agent no Windows.                                      "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   netsh advfirewall firewall delete rule name="ZABBIX"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Regra ZABBIX removida com sucesso do firewall do Windows.                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Removendo diretório de instalação c:\$PASTA                                                  "
   Write-Host "#############################################################################################"
   Remove-Item "c:\$PASTA" -Recurse
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Diretório de instalação original c:\$PASTA removido com sucesso.                             "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, seu Zabbix Agent foi removido com sucesso do Host.                                 "
   Write-Host "Backup: Salvo em c:\$PASTA.backup.$DATAATUAL                                                  "
   Write-Host "#############################################################################################"
   Write-Host ""
   cd c:\agent.zabbix
 }
}

##############################################
# Upgrade/Downgrade Zabbix Agent x.x.x Local #
##############################################

if ( $select -like 'LOCALCHANGE' )
{
   cls
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Verificando Existência do Zabbix Agent no Host                                              #"
   Write-Host "#############################################################################################"
   Write-Host ""

### VERIFICA SE O SERVIÇO ZABBIX AGENT JA EXISTE
$VERIFICA_SERVICO = Get-Service "Zabbix Agent" -ErrorAction SilentlyContinue | Measure-Object -Line | select-object Lines | select-object -ExpandProperty Lines
### VERIFICA A ARQUITETURA DO S.O "X86" OU "X64"
$VERIFICA_SO = Test-Path "c:\Program Files (x86)" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### VERIFICA DATA ATUAL NO FORMATO DD-MM-YYYY
$DATAATUAL = Get-Date -Uformat "%d-%m-%Y"
### VERIFICA WINDOWS VERSÃO
$WINDOWS_SO = (Get-WmiObject -class Win32_OperatingSystem).Caption
### VERIFICA WINDOWS ARQUITETURA
$WINDOWS_ARQ = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

### IF VERIFICA_SERVICO ####################################################################################
   If ($VERIFICA_SERVICO –eq 0) {

   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Desculpe, o serviço Zabbix Agent não foi encontrado no Host.                                #"
   Write-Host "Por esse motivo não será possível executar o Upgrade/Downgrade do Agent.                    #"
   Write-Host "Por favor, execute a instalação com o parâmetro LOCALINSTALL                                #"
   Write-Host "#############################################################################################"
   cd c:\agent.zabbix

### ELSE VERIFICA_SERVICO ##################################################################################
   } else {

### IF VERIFICA_SO #########################################################################################
   If ($VERIFICA_SO –eq 1) {

### 1º Parte IF VERIFICA_SO = 1 = Windows 64 Bits ##########################################################

   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "                Bem vindo ao Assistente de Upgrade/Downgrade do Zabbix Agent                 "
   Write-Host "                          Script Desenvolvido por Diego Cavalcante                           "
   Write-Host "                                  Update: $UPDATE - $UPDATEV                                 "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host "0000000000          10000000   00000000        10000         00000  00001  00000  00000000000"
   Write-Host "00000000000000000  00000000  0  0000000 .00000  0000  000000  0000  000000  010  000000000000"
   Write-Host "000000000000000  100000001  000  100000 .00000   000  00000.  0000  0000000  0  0000000000000"
   Write-Host "0000000000000  1000000000  00000  00000        =0000         =0000  00000000   00000000000000"
   Write-Host "000000000000  1000000000           0000 .00000   000  000000   000  0000000  0  0000000000000"
   Write-Host "00000000000  1000000000   0000000   000 .00000   000  000000   000  000000  010  000000000000"
   Write-Host "0000000001          00   000000000   00         1000          1000  00000  00000  00000000000"
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""

   cls

   Write-Host "#############################################################################################"
   Write-Host "Serviço Zabbix Agent encontrado, iniciando assistente de Upgrade/Downgrade                   "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "$WINDOWS_SO $WINDOWS_ARQ, continuando instalação...                                          "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Qual a pasta onde seu Zabbix Agent foi instalado?                                            "
   Write-Host "Digite apenas o diretório, a raiz c:\ será preenchida automaticamente.                       "
   Write-Host "Digite apenas o diretório sem a \ no final.                                                  "
   Write-Host "Ex: c:\zabbix ou c:\empresa\zabbix                                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   $PASTA           = Read-Host 'c:\'
   Write-Host ""
   
$VERIFICAVERSION = Test-Path "c:\$PASTA\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### IF VERIFICAVERSION = 0 = NÃO ENCONTRADO ################################################################   
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "#############################################################################################"
   Write-Host "Verificando versão atual do Zabbix Agent, aguarde um momento...                              "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Não foi possível identificar a versão do Zabbix Agent.                                       "
   Write-Host "Talvez o zabbix_agentd.exe não esteja localizado no diretório c:\$PASTA                      "
   Write-Host "Por esse motivo o Upgrade/Downgrade será abortado.                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   cd c:\agent.zabbix

### ELSE VERIFICAVERSION = 1 = ENCONTRADO ##################################################################
   } else {

   $VERSIONOLD = Get-ChildItem "c:\$PASTA\zabbix_agentd.exe" | Select-Object -ExpandProperty VersionInfo | select-object ProductVersion | select-object -ExpandProperty ProductVersion
   Write-Host "#############################################################################################"
   Write-Host "Verificando versão atual do Zabbix Agent, aguarde um momento...                              "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Versão $VERSIONOLD encontrada, continuando instalação...                                     "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Digite a versão que deseja realizar Upgrade/Downgrade Ex: 3.2.7 ou 3.4.1                     "
   Write-Host "#############################################################################################"
   Write-Host ""
   $CHANGEVERSION    = Read-Host 'Versão'
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "                                         Atenção!                                           #"
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "Versão: $VERSIONOLD será removida.                                                           "
   Write-Host "Versão: $CHANGEVERSION será instalada.                                                       "
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""
   cls

$INSTALLVERSION = Test-Path "c:\agent.zabbix\versao\$CHANGEVERSION\win64\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### IF INSTALLVERSION = 0 = NÃO ENCONTRADO #################################################################
   If ($INSTALLVERSION –eq 0) {
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Verificando Instalador, aguarde um momento...                                                "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Desculpe, a versão $CHANGEVERSION não foi encontrada no instalador.                          "
   Write-Host "Por esse motivo o Upgrade/Downgrade será abortado.                                           "
   Write-Host "Por favor, verifique a pasta c:\agent.zabbix\versao\ para ver as versões disponíveis.        "
   Write-Host "#############################################################################################"
   Write-Host ""

### ELSE INSTALLVERSION = 1 = ENCONTRADO ###################################################################   
   } else {

   Write-Host "#############################################################################################"
   Write-Host "Versão $CHANGEVERSION encontrada, continuando instalacao.                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Parando e removendo o serviço do Zabbix Agent $VERSIONOLD, aguarde um momento...             "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   net stop "Zabbix Agent"
   & "c:\$PASTA\zabbix_agentd.exe" -d -c "c:\$PASTA\zabbix_agentd.conf"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço Zabbix Agent $VERSIONOLD removido com sucesso.                                       "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Copiando executáveis da versão $CHANGEVERSION, aguarde um momento...                         "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   Remove-Item "c:\$PASTA\*.exe" -Recurse
   Copy-Item "c:\agent.zabbix\versao\$CHANGEVERSION\win32\*.*" -Destination "c:\$PASTA\" -Recurse
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Instalando e iniciando serviço do Zabbix Agent $CHANGEVERSION, aguarde um momento...         "
   Write-Host "#############################################################################################"
   Write-Host ""
   & "c:\$PASTA\zabbix_agentd.exe" -i -c "c:\$PASTA\zabbix_agentd.conf"
   & "c:\$PASTA\zabbix_agentd.exe" -s -c "c:\$PASTA\zabbix_agentd.conf"
   Start-Sleep -s 2
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço instalado com sucesso.                                                               "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "                                Resumo do Upgrade/Downgrade                                 #"
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "S.O: $WINDOWS_SO $WINDOWS_ARQ                                                                "
   Write-Host "Versão: $VERSIONOLD removida com sucesso.                                                    "
   Write-Host "Versão: $CHANGEVERSION instalada com sucesso.                                                "
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, Zabbix Agent atualizado com sucesso.                                               "
   Write-Host "#############################################################################################"
   Write-Host ""
   cd c:\agent.zabbix
 }
}

### 2º Parte IF VERIFICA_SO = 0 = Windows 32 Bits ########################################################## 

### ELSE VERIFICA_SO #######################################################################################
   } else {

   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "                Bem vindo ao Assistente de Upgrade/Downgrade do Zabbix Agent                 "
   Write-Host "                          Script Desenvolvido por Diego Cavalcante                           "
   Write-Host "                                  Update: $UPDATE - $UPDATEV                                 "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host "0000000000          10000000   00000000        10000         00000  00001  00000  00000000000"
   Write-Host "00000000000000000  00000000  0  0000000 .00000  0000  000000  0000  000000  010  000000000000"
   Write-Host "000000000000000  100000001  000  100000 .00000   000  00000.  0000  0000000  0  0000000000000"
   Write-Host "0000000000000  1000000000  00000  00000        =0000         =0000  00000000   00000000000000"
   Write-Host "000000000000  1000000000           0000 .00000   000  000000   000  0000000  0  0000000000000"
   Write-Host "00000000000  1000000000   0000000   000 .00000   000  000000   000  000000  010  000000000000"
   Write-Host "0000000001          00   000000000   00         1000          1000  00000  00000  00000000000"
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""

   cls

   Write-Host "#############################################################################################"
   Write-Host "Serviço Zabbix Agent encontrado, iniciando assistente de Upgrade/Downgrade                   "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "$WINDOWS_SO $WINDOWS_ARQ, continuando instalação...                                          "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Qual a pasta onde seu Zabbix Agent foi instalado?                                            "
   Write-Host "Digite apenas o diretório, a raiz c:\ será preenchida automaticamente.                       "
   Write-Host "Digite apenas o diretório sem a \ no final.                                                  "
   Write-Host "Ex: c:\zabbix ou c:\empresa\zabbix                                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   $PASTA           = Read-Host 'c:\'
   Write-Host ""

$VERIFICAVERSION = Test-Path "c:\$PASTA\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### IF VERIFICAVERSION = 0 = NÃO ENCONTRADO ################################################################   
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "#############################################################################################"
   Write-Host "Verificando versão atual do Zabbix Agent, aguarde um momento...                              "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Não foi possível identificar a versão do Zabbix Agent.                                       "
   Write-Host "Talvez o zabbix_agentd.exe não esteja localizado no diretório c:\$PASTA                      "
   Write-Host "Por esse motivo o Upgrade/Downgrade será abortado.                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   cd c:\agent.zabbix

### ELSE VERIFICAVERSION = 1 = ENCONTRADO ##################################################################
   } else {

   $VERSIONOLD = Get-ChildItem "c:\$PASTA\zabbix_agentd.exe" | Select-Object -ExpandProperty VersionInfo | select-object ProductVersion | select-object -ExpandProperty ProductVersion
   Write-Host "#############################################################################################"
   Write-Host "Verificando versão atual do Zabbix Agent, aguarde um momento...                              "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Versão $VERSIONOLD encontrada, continuando instalação...                                     "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Digite a versão que deseja realizar Upgrade/Downgrade Ex: 3.2.7 ou 3.4.1                     "
   Write-Host "#############################################################################################"
   Write-Host ""
   $CHANGEVERSION    = Read-Host 'Versão'
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "                                         Atenção!                                           #"
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "Versão: $VERSIONOLD será removida.                                                           "
   Write-Host "Versão: $CHANGEVERSION será instalada.                                                       "
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""
   cls

$INSTALLVERSION = Test-Path "c:\agent.zabbix\versao\$CHANGEVERSION\win32\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### IF INSTALLVERSION = 0 = NÃO ENCONTRADO #################################################################
   If ($INSTALLVERSION –eq 0) {
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Verificando Instalador, aguarde um momento...                                                "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Desculpe, a versão $CHANGEVERSION não foi encontrada no instalador.                          "
   Write-Host "Por esse motivo o Upgrade/Downgrade será abortado.                                           "
   Write-Host "Por favor, verifique a pasta c:\agent.zabbix\versao\ para ver as versões disponíveis.        "
   Write-Host "#############################################################################################"
   Write-Host ""
### ELSE INSTALLVERSION = 1 = ENCONTRADO ###################################################################
   } else {

   Write-Host "#############################################################################################"
   Write-Host "Versão $CHANGEVERSION encontrada, continuando instalacao.                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Parando e removendo o serviço do Zabbix Agent $VERSIONOLD, aguarde um momento...             "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   net stop "Zabbix Agent"
   & "c:\$PASTA\zabbix_agentd.exe" -d -c "c:\$PASTA\zabbix_agentd.conf"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço Zabbix Agent $VERSIONOLD removido com sucesso.                                       "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Copiando executáveis da versão $CHANGEVERSION, aguarde um momento...                         "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   Remove-Item "c:\$PASTA\*.exe" -Recurse
   Copy-Item "c:\agent.zabbix\versao\$CHANGEVERSION\win32\*.*" -Destination "c:\$PASTA\" -Recurse
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Instalando e iniciando serviço do Zabbix Agent $CHANGEVERSION, aguarde um momento...         "
   Write-Host "#############################################################################################"
   Write-Host ""
   & "c:\$PASTA\zabbix_agentd.exe" -i -c "c:\$PASTA\zabbix_agentd.conf"
   & "c:\$PASTA\zabbix_agentd.exe" -s -c "c:\$PASTA\zabbix_agentd.conf"
   Start-Sleep -s 2
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço instalado com sucesso.                                                               "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "                                Resumo do Upgrade/Downgrade                                 #"
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "S.O: $WINDOWS_SO $WINDOWS_ARQ                                                                "
   Write-Host "Versão: $VERSIONOLD removida com sucesso.                                                    "
   Write-Host "Versão: $CHANGEVERSION instalada com sucesso.                                                "
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, Zabbix Agent atualizado com sucesso.                                               "
   Write-Host "#############################################################################################"
   Write-Host ""
   cd c:\agent.zabbix
    }
   }
  }
 }
}

########################################
# Instalação Zabbix Agent x.x.x Rede   #
########################################

if ( $select -like 'REDEINSTALL' )
{
   cls
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Verificando Existência do Zabbix Agent no Host                                              #"
   Write-Host "#############################################################################################"
   Write-Host ""
### VERIFICA SE O SERVIÇO ZABBIX AGENT JA EXISTE
$VERIFICA_INSTALL = Get-Service "Zabbix Agent" -ErrorAction SilentlyContinue | Measure-Object -Line | select-object Lines | select-object -ExpandProperty Lines
### VERIFICA A ARQUITETURA DO S.O "X86" OU "X64"
$VERIFICA_SO      = Test-Path "c:\Program Files (x86)" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### VERIFICA WINDOWS VERSÃO
$WINDOWS_SO = (Get-WmiObject -class Win32_OperatingSystem).Caption
### VERIFICA WINDOWS ARQUITETURA
$WINDOWS_ARQ = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

### IF VERIFICA_INSTALL #################################################################################### 
   If ($VERIFICA_INSTALL –eq 1) {

   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Zabbix Agent já existe, instalação abortada.                                                #"
   Write-Host "Se deseja remover o Zabbix Agent por completo, execute o script com o parâmetro REDEREMOVE  #"
   Write-Host "Se deseja realizar Upgrade/Downgrade, execute o script com o parâmetro REDECHANGE           #"
   Write-Host "#############################################################################################"
   Write-Host ""

### ELSE VERIFICA_INSTALL ##################################################################################
   } else {

### IF VERIFICA_SO #########################################################################################
   If ($VERIFICA_SO –eq 1) {

### 1º Parte IF VERIFICA_SO = 1 = Windows 64 Bits ##########################################################

   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "                    Bem vindo ao Assistente de Instalação do Zabbix Agent                    "
   Write-Host "                           Script Desenvolvido por Diego Cavalcante                          "
   Write-Host "                                  Update: $UPDATE - $UPDATEV                                 "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host "0000000000          10000000   00000000        10000         00000  00001  00000  00000000000"
   Write-Host "00000000000000000  00000000  0  0000000 .00000  0000  000000  0000  000000  010  000000000000"
   Write-Host "000000000000000  100000001  000  100000 .00000   000  00000.  0000  0000000  0  0000000000000"
   Write-Host "0000000000000  1000000000  00000  00000        =0000         =0000  00000000   00000000000000"
   Write-Host "000000000000  1000000000           0000 .00000   000  000000   000  0000000  0  0000000000000"
   Write-Host "00000000000  1000000000   0000000   000 .00000   000  000000   000  000000  010  000000000000"
   Write-Host "0000000001          00   000000000   00         1000          1000  00000  00000  00000000000"
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""

   cls

   Write-Host "#############################################################################################"
   Write-Host "Zabbix Agent não encontrado, iniciando instalaçao...                                         "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "$WINDOWS_SO $WINDOWS_ARQ, continuando instalação...                                          "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Configurando Zabbix Agent                                                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Qual a versão do Zabbix Agent deseja instalar? Ex: 3.2.7 ou 3.4.1"
   Write-Host "#############################################################################################"
   Write-Host ""
   $VERSION    = Read-Host 'Versão'
   Write-Host ""

$VERIFICAVERSION = Test-Path "$SHARE\versao\$VERSION" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### IF VERIFICAVERSION = 0 = NÃO ENCONTRADO ################################################################  
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "#############################################################################################"
   Write-Host "Desculpe, a versão $CHANGEVERSION não foi encontrada no instalador.                          "
   Write-Host "Por esse motivo a instalação será abortada.                                                  "
   Write-Host "Por favor, verifique a pasta $SHARE\versao\ para ver as versões disponíveis.                 "
   Write-Host "#############################################################################################"
   Write-Host ""

### ELSE VERIFICAVERSION = 1 = ENCONTRADO ##################################################################
   } else {

   Write-Host "#############################################################################################"
   Write-Host "Onde Deseja Instalar o Zabbix Agent?                                                         "
   Write-Host "Digite apenas o diretório, a raiz c:\ será preenchida automaticamente.                       "
   Write-Host "Digite apenas o diretório sem a \ no final.                                                  "
   Write-Host "Ex: c:\zabbix ou c:\empresa\zabbix                                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   $PASTA   = Read-Host 'c:\'
   md "c:\$PASTA\monitoramento\scripts\"
   md "c:\$PASTA\monitoramento\userparameters\"
   Copy-Item "$SHARE\versao\$VERSION\win64\*.*" -Destination "c:\$PASTA\" -Recurse
   Copy-Item "$SHARE\monitoramento\scripts\*.*" -Destination "c:\$PASTA\monitoramento\scripts\" -Recurse
   Copy-Item "$SHARE\monitoramento\userparameters\*.*" -Destination "c:\$PASTA\monitoramento\userparameters\" -Recurse
   copy-Item "$SHARE\zabbix_agentd.conf" -Destination "c:\$PASTA" -Recurse
   Rename-Item "c:\$PASTA\zabbix_agentd.conf" "c:\$PASTA\zabbix_agentd.conf.txt"

   cls

   Write-Host "#############################################################################################"
   Write-Host "                                 Configurando Zabbix Agent                                   "
   Write-Host "                             Todos os Campos são Obrigatórios                                "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $IP         = Read-Host 'Qual o IP/DNS do Zabbix Server ou Proxy?'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $HOSTNAME   = Read-Host 'Qual o Nome do Host?'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $TIMEOUT    = Read-Host 'Qual o Timeout do Host? Entre 0 e 30 segundos'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $REMOTE     = Read-Host 'Deseja Habilitar o Comando Remoto no Host? (0)Desabilita (1)Habilita'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $REMOTELOG  = Read-Host 'Deseja Habilitar o LOG do Comando Remoto no Host? (0)Desabilita (1)Habilita'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $PORTA      = Read-Host 'Qual a Porta de Comunicação do Zabbix Agent? Ex: 10050 (Padrão)'
   Write-Host "#############################################################################################"
   Write-Host ""

### PREENCHENDO .CONF COM AS INFRMAÇÕES DIGITADAS ##########################################################
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

   cd c:\$PASTA
   Write-Host "#############################################################################################"
   Write-Host "Instalando e iniciando serviço...                                                            "
   Write-Host "#############################################################################################"
   Write-Host ""
   & "c:\$PASTA\zabbix_agentd.exe" -i -c "c:\$PASTA\zabbix_agentd.conf"
   & "c:\$PASTA\zabbix_agentd.exe" -s -c "c:\$PASTA\zabbix_agentd.conf"
   Start-Sleep -s 2
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço instalado com sucesso.                                                               "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Liberando porta $PORTA no Firewall do Windows                                                "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   Write-Host ""
   netsh advfirewall firewall add rule name="ZABBIX" dir=in action=allow protocol=TCP localport=$PORTA
   Write-Host "#############################################################################################"
   Write-Host "Porta $PORTA no Firewall liberada com sucesso, nome da regra = ZABBIX                        "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Testando conectividade do Server/Proxy $IP na porta 10051                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2

### TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = SUCESSO ######################################################
Try   {
   $connection = (New-Object Net.Sockets.TcpClient)
   $connection.Connect("$IP",10051)
   Write-Host "#############################################################################################"
   Write-Host "                                    Resumo da Instalação                                     "
   Write-Host "#############################################################################################"
   Write-Host "Server                        = $IP                                                          "
   Write-Host "ServerActive                  = $IP                                                          "
   Write-Host "Hostname                      = $HOSTNAME                                                    "
   Write-Host "Timeout                       = $TIMEOUT                                                     "
   Write-Host "EnableRemoteCommands          = $REMOTE                                                      "
   Write-Host "LogRemoteCommands             = $REMOTELOG                                                   "
   Write-Host "ListenPort                    = $PORTA                                                       "
   Write-Host "Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX                "
   Write-Host "UserParameters                = c:\$PASTA\monitoramento\userparameters\                      "
   Write-Host "Scripts                       = c:\$PASTA\monitoramento\scripts\                             "
   Write-Host "LogFile                       = c:\$PASTA\zabbix_agentd.log                                  "
   Write-Host "Diretório                     = c:\$PASTA                                                    "
   Write-Host "Versão                        = $VERSION                                                     "
   Write-Host "S.O                           = $WINDOWS_SO $WINDOWS_ARQ                                     "
   Write-Host "Conectividade em Server/Proxy = Conexão em $IP 10051 Sucesso                                 "
   Write-Host "Share                         = $SHARE                                                       "
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, Zabbix Agent Instalado com Sucesso.                                                "
   Write-Host "#############################################################################################"
   cd c:\
      }

### TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = FALHA ########################################################
Catch {
   Write-Host "#############################################################################################"
   Write-Host "                                    Resumo da Instalação                                     "
   Write-Host "#############################################################################################"
   Write-Host "Server                        = $IP                                                          "
   Write-Host "ServerActive                  = $IP                                                          "
   Write-Host "Hostname                      = $HOSTNAME                                                    "
   Write-Host "Timeout                       = $TIMEOUT                                                     "
   Write-Host "EnableRemoteCommands          = $REMOTE                                                      "
   Write-Host "LogRemoteCommands             = $REMOTELOG                                                   "
   Write-Host "ListenPort                    = $PORTA                                                       "
   Write-Host "Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX                "
   Write-Host "UserParameters                = c:\$PASTA\monitoramento\userparameters\                      "
   Write-Host "Scripts                       = c:\$PASTA\monitoramento\scripts\                             "
   Write-Host "LogFile                       = c:\$PASTA\zabbix_agentd.log                                  "
   Write-Host "Diretório                     = c:\$PASTA                                                    "
   Write-Host "Versão                        = $VERSION                                                     "
   Write-Host "S.O                           = $WINDOWS_SO $WINDOWS_ARQ                                     "
   Write-Host "Conectividade em Server/Proxy = Conexão em $IP 10051 Falhou                                  "
   Write-Host "Share                         = $SHARE                                                       "
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, Zabbix Agent Instalado com Sucesso.                                                "
   Write-Host "#############################################################################################"
   cd c:\
   }
 }

### 2º Parte IF VERIFICA_SO = 0 = Windows 32 Bits ########################################################## 

### ELSE VERIFICA_SO #######################################################################################
   } else {

   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "                    Bem vindo ao Assistente de Instalação do Zabbix Agent                    "
   Write-Host "                           Script Desenvolvido por Diego Cavalcante                          "
   Write-Host "                                  Update: $UPDATE - $UPDATEV                                 "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host "0000000000          10000000   00000000        10000         00000  00001  00000  00000000000"
   Write-Host "00000000000000000  00000000  0  0000000 .00000  0000  000000  0000  000000  010  000000000000"
   Write-Host "000000000000000  100000001  000  100000 .00000   000  00000.  0000  0000000  0  0000000000000"
   Write-Host "0000000000000  1000000000  00000  00000        =0000         =0000  00000000   00000000000000"
   Write-Host "000000000000  1000000000           0000 .00000   000  000000   000  0000000  0  0000000000000"
   Write-Host "00000000000  1000000000   0000000   000 .00000   000  000000   000  000000  010  000000000000"
   Write-Host "0000000001          00   000000000   00         1000          1000  00000  00000  00000000000"
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""

   cls

   Write-Host "#############################################################################################"
   Write-Host "Zabbix Agent não encontrado, iniciando instalaçao...                                         "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "$WINDOWS_SO $WINDOWS_ARQ, continuando instalação...                                          "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Configurando Zabbix Agent                                                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Qual a versão do Zabbix Agent deseja instalar? Ex: 3.2.7 ou 3.4.1"
   Write-Host "#############################################################################################"
   Write-Host ""
   $VERSION    = Read-Host 'Versão'
   Write-Host ""

$VERIFICAVERSION = Test-Path "$SHARE\versao\$VERSION" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### IF VERIFICAVERSION = 0 = NÃO ENCONTRADO ################################################################     
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "#############################################################################################"
   Write-Host "Desculpe, a versão $CHANGEVERSION não foi encontrada no instalador.                          "
   Write-Host "Por esse motivo a instalação será abortada.                                                  "
   Write-Host "Por favor, verifique a pasta $SHARE\versao\ para ver as versões disponíveis.                 "
   Write-Host "#############################################################################################"
   Write-Host ""

### ELSE VERIFICAVERSION = 1 = ENCONTRADO ##################################################################
   } else {

   Write-Host "#############################################################################################"
   Write-Host "Onde Deseja Instalar o Zabbix Agent?                                                         "
   Write-Host "Digite apenas o diretório, a raiz c:\ será preenchida automaticamente.                       "
   Write-Host "Digite apenas o diretório sem a \ no final.                                                  "
   Write-Host "Ex: c:\zabbix ou c:\empresa\zabbix                                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   $PASTA   = Read-Host 'c:\'
   md "c:\$PASTA\monitoramento\scripts\"
   md "c:\$PASTA\monitoramento\userparameters\"
   Copy-Item "$SHARE\versao\$VERSION\win32\*.*" -Destination "c:\$PASTA\" -Recurse
   Copy-Item "$SHARE\monitoramento\scripts\*.*" -Destination "c:\$PASTA\monitoramento\scripts\" -Recurse
   Copy-Item "$SHARE\monitoramento\userparameters\*.*" -Destination "c:\$PASTA\monitoramento\userparameters\" -Recurse
   copy-Item "$SHARE\zabbix_agentd.conf" -Destination "c:\$PASTA" -Recurse
   Rename-Item "c:\$PASTA\zabbix_agentd.conf" "c:\$PASTA\zabbix_agentd.conf.txt"

   cls

   Write-Host "#############################################################################################"
   Write-Host "                                 Configurando Zabbix Agent                                   "
   Write-Host "                             Todos os Campos são Obrigatórios                                "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $IP         = Read-Host 'Qual o IP/DNS do Zabbix Server ou Proxy?'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $HOSTNAME   = Read-Host 'Qual o Nome do Host?'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $TIMEOUT    = Read-Host 'Qual o Timeout do Host? Entre 0 e 30 segundos'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $REMOTE     = Read-Host 'Deseja Habilitar o Comando Remoto no Host? (0)Desabilita (1)Habilita'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $REMOTELOG  = Read-Host 'Deseja Habilitar o LOG do Comando Remoto no Host? (0)Desabilita (1)Habilita'
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   $PORTA      = Read-Host 'Qual a Porta de Comunicação do Zabbix Agent? Ex: 10050 (Padrão)'
   Write-Host "#############################################################################################"
   Write-Host ""

### PREENCHENDO .CONF COM AS INFRMAÇÕES DIGITADAS ##########################################################
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

   cd c:\$PASTA
   Write-Host "#############################################################################################"
   Write-Host "Instalando e iniciando serviço...                                                            "
   Write-Host "#############################################################################################"
   Write-Host ""
   & "c:\$PASTA\zabbix_agentd.exe" -i -c "c:\$PASTA\zabbix_agentd.conf"
   & "c:\$PASTA\zabbix_agentd.exe" -s -c "c:\$PASTA\zabbix_agentd.conf"
   Start-Sleep -s 2
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço instalado com sucesso.                                                               "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Liberando porta $PORTA no Firewall do Windows                                                "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   Write-Host ""
   netsh advfirewall firewall add rule name="ZABBIX" dir=in action=allow protocol=TCP localport=$PORTA
   Write-Host "#############################################################################################"
   Write-Host "Porta $PORTA no Firewall liberada com sucesso, nome da regra = ZABBIX                        "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Testando conectividade do Server/Proxy $IP na porta 10051                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2

### TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = SUCESSO ######################################################
Try   {
   $connection = (New-Object Net.Sockets.TcpClient)
   $connection.Connect("$IP",10051)
   Write-Host "#############################################################################################"
   Write-Host "                                    Resumo da Instalação                                     "
   Write-Host "#############################################################################################"
   Write-Host "Server                        = $IP                                                          "
   Write-Host "ServerActive                  = $IP                                                          "
   Write-Host "Hostname                      = $HOSTNAME                                                    "
   Write-Host "Timeout                       = $TIMEOUT                                                     "
   Write-Host "EnableRemoteCommands          = $REMOTE                                                      "
   Write-Host "LogRemoteCommands             = $REMOTELOG                                                   "
   Write-Host "ListenPort                    = $PORTA                                                       "
   Write-Host "Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX                "
   Write-Host "UserParameters                = c:\$PASTA\monitoramento\userparameters\                      "
   Write-Host "Scripts                       = c:\$PASTA\monitoramento\scripts\                             "
   Write-Host "LogFile                       = c:\$PASTA\zabbix_agentd.log                                  "
   Write-Host "Diretório                     = c:\$PASTA                                                    "
   Write-Host "Versão                        = $VERSION                                                     "
   Write-Host "S.O                           = $WINDOWS_SO $WINDOWS_ARQ                                     "
   Write-Host "Conectividade em Server/Proxy = Conexão em $IP 10051 Sucesso                                 "
   Write-Host "Share                         = $SHARE                                                       "
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, Zabbix Agent Instalado com Sucesso.                                                "
   Write-Host "#############################################################################################"
   cd c:\
      }

### TESTE DE CONEXÃO E RESUMO DE INSTALAÇÃO = FALHA ########################################################
Catch {
   Write-Host "#############################################################################################"
   Write-Host "                                    Resumo da Instalação                                     "
   Write-Host "#############################################################################################"
   Write-Host "Server                        = $IP                                                          "
   Write-Host "ServerActive                  = $IP                                                          "
   Write-Host "Hostname                      = $HOSTNAME                                                    "
   Write-Host "Timeout                       = $TIMEOUT                                                     "
   Write-Host "EnableRemoteCommands          = $REMOTE                                                      "
   Write-Host "LogRemoteCommands             = $REMOTELOG                                                   "
   Write-Host "ListenPort                    = $PORTA                                                       "
   Write-Host "Firewall                      = Porta $PORTA Liberada, nome da regra = ZABBIX                "
   Write-Host "UserParameters                = c:\$PASTA\monitoramento\userparameters\                      "
   Write-Host "Scripts                       = c:\$PASTA\monitoramento\scripts\                             "
   Write-Host "LogFile                       = c:\$PASTA\zabbix_agentd.log                                  "
   Write-Host "Diretório                     = c:\$PASTA                                                    "
   Write-Host "Versão                        = $VERSION                                                     "
   Write-Host "S.O                           = $WINDOWS_SO $WINDOWS_ARQ                                     "
   Write-Host "Conectividade em Server/Proxy = Conexão em $IP 10051 Falhou                                  "
   Write-Host "Share                         = $SHARE                                                       "
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, Zabbix Agent Instalado com Sucesso.                                                "
   Write-Host "#############################################################################################"
   cd c:\
    }
   }
  }
 }
}

########################################
# Remoção Zabbix Agent Full Rede       #
########################################

if ( $select -like 'REDEREMOVE' )
{
   cls

   Write-Host "#############################################################################################"
   Write-Host "                     Bem vindo ao Assistente de Remoção do Zabbix Agent                      "
   Write-Host "                         Script Desenvolvido por Diego Cavalcante                            "
   Write-Host "                                  Update: $UPDATE - $UPDATEV                                 "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host "0000000000          10000000   00000000        10000         00000  00001  00000  00000000000"
   Write-Host "00000000000000000  00000000  0  0000000 .00000  0000  000000  0000  000000  010  000000000000"
   Write-Host "000000000000000  100000001  000  100000 .00000   000  00000.  0000  0000000  0  0000000000000"
   Write-Host "0000000000000  1000000000  00000  00000        =0000         =0000  00000000   00000000000000"
   Write-Host "000000000000  1000000000           0000 .00000   000  000000   000  0000000  0  0000000000000"
   Write-Host "00000000000  1000000000   0000000   000 .00000   000  000000   000  000000  010  000000000000"
   Write-Host "0000000001          00   000000000   00         1000          1000  00000  00000  00000000000"
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""

   cls

   Write-Host "#############################################################################################"
   Write-Host "Este script irá desinstalar por completo o Zabbix Agent.                                     "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Qual a pasta onde seu Zabbix Agent foi instalado?                                            "
   Write-Host "Digite apenas o diretório, a raiz c:\ será preenchida automaticamente.                       "
   Write-Host "Digite apenas o diretório sem a \ no final.                                                  "
   Write-Host "Ex: c:\zabbix ou c:\empresa\zabbix                                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   $PASTA          = Read-Host 'c:\'
   $DATAATUAL      = Get-Date -Uformat "%d-%m-%Y"
   $VERIFICA_PASTA = Test-Path "c:\$PASTA" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
   Write-Host ""

### IF VERIFICA_PASTA = 0 = NÃO ENCONTRADA ################################################################# 
   If ($VERIFICA_PASTA –eq 0) {

   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Diretório não encontrado, verifique se é o diretório correto e tente novamente.              "
   Write-Host "#############################################################################################"
   Write-Host ""
   cd c:\

### ELSE VERIFICA_PASTA = 1 = ENCONTRADA ################################################################### 
   } else {

   Write-Host "#############################################################################################"
   Write-Host "Realizando backup, aguarde um momento...                                                     "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Copy-Item -Path "c:\$PASTA\" -Destination "c:\$PASTA.backup.$DATAATUAL" -Recurse

   cls

   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Parando e removendo o serviço do Zabbix Agent, aguarde um momento...                         "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   net stop "Zabbix Agent"
   & "c:\$PASTA\zabbix_agentd.exe" -d -c "c:\$PASTA\zabbix_agentd.conf"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço Zabbix Agent removido com sucesso.                                                   "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Removendo regra de firewall do Zabbix Agent no Windows.                                      "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   netsh advfirewall firewall delete rule name="ZABBIX"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Regra ZABBIX removida com sucesso do firewall do Windows.                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Removendo diretório de instalação c:\$PASTA                                                  "
   Write-Host "#############################################################################################"
   Remove-Item "c:\$PASTA" -Recurse
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Diretório de instalação original c:\$PASTA removido com sucesso.                             "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, seu Zabbix Agent foi removido com sucesso do Host.                                 "
   Write-Host "Backup: Salvo em c:\$PASTA.backup.$DATAATUAL                                                 "
   Write-Host "#############################################################################################"
   Write-Host ""
   cd c:\
 }
}

##############################################
# Upgrade/Downgrade Zabbix Agent x.x.x Rede  #
##############################################

if ( $select -like 'REDECHANGE' )
{
   cls
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Verificando Existência do Zabbix Agent no Host                                              #"
   Write-Host "#############################################################################################"
   Write-Host ""

### VERIFICA SE O SERVIÇO ZABBIX AGENT JA EXISTE
$VERIFICA_SERVICO = Get-Service "Zabbix Agent" -ErrorAction SilentlyContinue | Measure-Object -Line | select-object Lines | select-object -ExpandProperty Lines
### VERIFICA A ARQUITETURA DO S.O "X86" OU "X64"
$VERIFICA_SO = Test-Path "c:\Program Files (x86)" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### VERIFICA WINDOWS VERSÃO
$WINDOWS_SO = (Get-WmiObject -class Win32_OperatingSystem).Caption
### VERIFICA WINDOWS ARQUITETURA
$WINDOWS_ARQ = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

### IF VERIFICA_SERVICO ####################################################################################
   If ($VERIFICA_SERVICO –eq 0) {

   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Desculpe, o serviço Zabbix Agent não foi encontrado no Host.                                #"
   Write-Host "Por esse motivo não será possível executar o Upgrade/Downgrade do Agent.                    #"
   Write-Host "Por favor, execute a instalação com o parâmetro "REDEINSTALL"                               #"
   Write-Host "#############################################################################################"
   cd c:\

### ELSE VERIFICA_SERVICO ##################################################################################
   } else {

### IF VERIFICA_SO #########################################################################################
   If ($VERIFICA_SO –eq 1) {

### 1º Parte IF VERIFICA_SO = 1 = Windows 64 Bits ##########################################################

   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "                Bem vindo ao Assistente de Upgrade/Downgrade do Zabbix Agent                 "
   Write-Host "                          Script Desenvolvido por Diego Cavalcante                           "
   Write-Host "                                  Update: $UPDATE - $UPDATEV                                 "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host "0000000000          10000000   00000000        10000         00000  00001  00000  00000000000"
   Write-Host "00000000000000000  00000000  0  0000000 .00000  0000  000000  0000  000000  010  000000000000"
   Write-Host "000000000000000  100000001  000  100000 .00000   000  00000.  0000  0000000  0  0000000000000"
   Write-Host "0000000000000  1000000000  00000  00000        =0000         =0000  00000000   00000000000000"
   Write-Host "000000000000  1000000000           0000 .00000   000  000000   000  0000000  0  0000000000000"
   Write-Host "00000000000  1000000000   0000000   000 .00000   000  000000   000  000000  010  000000000000"
   Write-Host "0000000001          00   000000000   00         1000          1000  00000  00000  00000000000"
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""

   cls

   Write-Host "#############################################################################################"
   Write-Host "Serviço Zabbix Agent encontrado, iniciando assistente de Upgrade/Downgrade                   "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "$WINDOWS_SO $WINDOWS_ARQ, continuando instalação...                                          "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Qual a pasta onde seu Zabbix Agent foi instalado?                                            "
   Write-Host "Digite apenas o diretório, a raiz c:\ será preenchida automaticamente.                       "
   Write-Host "Digite apenas o diretório sem a \ no final.                                                  "
   Write-Host "Ex: c:\zabbix ou c:\empresa\zabbix                                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   $PASTA     = Read-Host 'c:\'
   Write-Host ""
   
$VERIFICAVERSION = Test-Path "c:\$PASTA\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### IF VERIFICAVERSION = 0 = NÃO ENCONTRADO ################################################################   
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "#############################################################################################"
   Write-Host "Verificando versão atual do Zabbix Agent, aguarde um momento...                              "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Não foi possível identificar a versão do Zabbix Agent.                                       "
   Write-Host "Talvez o zabbix_agentd.exe não esteja localizado no diretório c:\$PASTA                      "
   Write-Host "Por esse motivo o Upgrade/Downgrade será abortado.                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   cd c:\

### ELSE VERIFICAVERSION = 1 = ENCONTRADO ##################################################################
   } else {

   $VERSIONOLD = Get-ChildItem "c:\$PASTA\zabbix_agentd.exe" | Select-Object -ExpandProperty VersionInfo | select-object ProductVersion | select-object -ExpandProperty ProductVersion
   Write-Host "#############################################################################################"
   Write-Host "Verificando versão atual do Zabbix Agent, aguarde um momento...                              "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Versão $VERSIONOLD encontrada, continuando instalação...                                     "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Digite a versão que deseja realizar Upgrade/Downgrade Ex: 3.2.7 ou 3.4.1                     "
   Write-Host "#############################################################################################"
   Write-Host ""
   $CHANGEVERSION    = Read-Host 'Versão'
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "                                         Atenção!                                           #"
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "Versão: $VERSIONOLD será removida.                                                           "
   Write-Host "Versão: $CHANGEVERSION será instalada.                                                       "
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""
   cls

$INSTALLVERSION = Test-Path "$SHARE\versao\$CHANGEVERSION\win64\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### IF INSTALLVERSION = 0 = NÃO ENCONTRADO #################################################################
   If ($INSTALLVERSION –eq 0) {
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Verificando Instalador na rede, aguarde um momento...                                        "
   Write-Host "Buscando em $SHARE                                                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Desculpe, a versão $CHANGEVERSION não foi encontrada no instalador.                          "
   Write-Host "Por esse motivo o Upgrade/Downgrade será abortado.                                           "
   Write-Host "Por favor, verifique o diretório na rede para ver as versões disponíveis.                    "
   Write-Host "Diretório: $SHARE\versao\                                                                    "
   Write-Host "#############################################################################################"
   Write-Host ""

### ELSE INSTALLVERSION = 1 = ENCONTRADO ###################################################################   
   } else {

   Write-Host "#############################################################################################"
   Write-Host "Versão $CHANGEVERSION encontrada, continuando instalacao.                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Parando e removendo o serviço do Zabbix Agent $VERSIONOLD, aguarde um momento...             "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   net stop "Zabbix Agent"
   & "c:\$PASTA\zabbix_agentd.exe" -d -c "c:\$PASTA\zabbix_agentd.conf"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço Zabbix Agent $VERSIONOLD removido com sucesso.                                       "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Copiando executáveis da versão $CHANGEVERSION, aguarde um momento...                         "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   Remove-Item "c:\$PASTA\*.exe" -Recurse
   Copy-Item "$SHARE\versao\$CHANGEVERSION\win32\*.*" -Destination "c:\$PASTA\" -Recurse
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Instalando e iniciando serviço do Zabbix Agent $CHANGEVERSION, aguarde um momento...         "
   Write-Host "#############################################################################################"
   Write-Host ""
   & "c:\$PASTA\zabbix_agentd.exe" -i -c "c:\$PASTA\zabbix_agentd.conf"
   & "c:\$PASTA\zabbix_agentd.exe" -s -c "c:\$PASTA\zabbix_agentd.conf"
   Start-Sleep -s 2
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço instalado com sucesso.                                                               "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "                                Resumo do Upgrade/Downgrade                                 #"
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "Share: $SHARE                                                                                "
   Write-Host "S.O: $WINDOWS_SO $WINDOWS_ARQ                                                                "
   Write-Host "Versão: $VERSIONOLD removida com sucesso.                                                    "
   Write-Host "Versão: $CHANGEVERSION instalada com sucesso.                                                "
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, Zabbix Agent atualizado com sucesso.                                               "
   Write-Host "#############################################################################################"
   Write-Host ""
   cd c:\
 }
}

### 2º Parte IF VERIFICA_SO = 0 = Windows 32 Bits ########################################################## 

### ELSE VERIFICA_SO #######################################################################################
   } else {

   Write-Host "Aguarde um momento..."
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "                Bem vindo ao Assistente de Upgrade/Downgrade do Zabbix Agent                 "
   Write-Host "                          Script Desenvolvido por Diego Cavalcante                           "
   Write-Host "                                  Update: $UPDATE - $UPDATEV                                 "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host "0000000000          10000000   00000000        10000         00000  00001  00000  00000000000"
   Write-Host "00000000000000000  00000000  0  0000000 .00000  0000  000000  0000  000000  010  000000000000"
   Write-Host "000000000000000  100000001  000  100000 .00000   000  00000.  0000  0000000  0  0000000000000"
   Write-Host "0000000000000  1000000000  00000  00000        =0000         =0000  00000000   00000000000000"
   Write-Host "000000000000  1000000000           0000 .00000   000  000000   000  0000000  0  0000000000000"
   Write-Host "00000000000  1000000000   0000000   000 .00000   000  000000   000  000000  010  000000000000"
   Write-Host "0000000001          00   000000000   00         1000          1000  00000  00000  00000000000"
   Write-Host "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""

   cls

   Write-Host "#############################################################################################"
   Write-Host "Serviço Zabbix Agent encontrado, iniciando assistente de Upgrade/Downgrade                   "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "$WINDOWS_SO $WINDOWS_ARQ, continuando instalação...                                          "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Qual a pasta onde seu Zabbix Agent foi instalado?                                            "
   Write-Host "Digite apenas o diretório, a raiz c:\ será preenchida automaticamente.                       "
   Write-Host "Digite apenas o diretório sem a \ no final.                                                  "
   Write-Host "Ex: c:\zabbix ou c:\empresa\zabbix                                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   $PASTA     = Read-Host 'c:\'
   Write-Host ""

$VERIFICAVERSION = Test-Path "c:\$PASTA\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### IF VERIFICAVERSION = 0 = NÃO ENCONTRADO ################################################################   
   If ($VERIFICAVERSION –eq 0) {

   Write-Host "#############################################################################################"
   Write-Host "Verificando versão atual do Zabbix Agent, aguarde um momento...                              "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Não foi possível identificar a versão do Zabbix Agent.                                       "
   Write-Host "Talvez o zabbix_agentd.exe não esteja localizado no diretório c:\$PASTA                      "
   Write-Host "Por esse motivo o Upgrade/Downgrade será abortado.                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   cd c:\

### ELSE VERIFICAVERSION = 1 = ENCONTRADO ##################################################################
   } else {

   $VERSIONOLD = Get-ChildItem "c:\$PASTA\zabbix_agentd.exe" | Select-Object -ExpandProperty VersionInfo | select-object ProductVersion | select-object -ExpandProperty ProductVersion
   Write-Host "#############################################################################################"
   Write-Host "Verificando versão atual do Zabbix Agent, aguarde um momento...                              "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Versão $VERSIONOLD encontrada, continuando instalação...                                     "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Digite a versão que deseja realizar Upgrade/Downgrade Ex: 3.2.7 ou 3.4.1                     "
   Write-Host "#############################################################################################"
   Write-Host ""
   $CHANGEVERSION    = Read-Host 'Versão'
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "                                         Atenção!                                           #"
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "Versão: $VERSIONOLD será removida.                                                           "
   Write-Host "Versão: $CHANGEVERSION será instalada.                                                       "
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host ""
   $CONTINUAR = Read-Host 'Pressione qualquer tecla para continuar'
   Write-Host ""
   cls

$INSTALLVERSION = Test-Path "$SHARE\versao\$CHANGEVERSION\win32\zabbix_agentd.exe" | ForEach-Object {$_ -Replace "True", "1"} | ForEach-Object {$_ -Replace "False", "0"}
### IF INSTALLVERSION = 0 = NÃO ENCONTRADO #################################################################
   If ($INSTALLVERSION –eq 0) {
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Verificando Instalador na rede, aguarde um momento...                                        "
   Write-Host "Buscando em $SHARE                                                                           "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "Desculpe, a versão $CHANGEVERSION não foi encontrada no instalador.                          "
   Write-Host "Por esse motivo o Upgrade/Downgrade será abortado.                                           "
   Write-Host "Por favor, verifique o diretório na rede para ver as versões disponíveis.                    "
   Write-Host "Diretório: $SHARE\versao\                                                                    "
   Write-Host "#############################################################################################"
   Write-Host ""

### ELSE INSTALLVERSION = 1 = ENCONTRADO ###################################################################
   } else {

   Write-Host "#############################################################################################"
   Write-Host "Versão $CHANGEVERSION encontrada, continuando instalacao.                                    "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Parando e removendo o serviço do Zabbix Agent $VERSIONOLD, aguarde um momento...             "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   net stop "Zabbix Agent"
   & "c:\$PASTA\zabbix_agentd.exe" -d -c "c:\$PASTA\zabbix_agentd.conf"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço Zabbix Agent $VERSIONOLD removido com sucesso.                                       "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Copiando executáveis da versão $CHANGEVERSION, aguarde um momento...                         "
   Write-Host "#############################################################################################"
   Start-Sleep -s 2
   Remove-Item "c:\$PASTA\*.exe" -Recurse
   Copy-Item "$SHARE\versao\$CHANGEVERSION\win32\*.*" -Destination "c:\$PASTA\" -Recurse
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Instalando e iniciando serviço do Zabbix Agent $CHANGEVERSION, aguarde um momento...         "
   Write-Host "#############################################################################################"
   Write-Host ""
   & "c:\$PASTA\zabbix_agentd.exe" -i -c "c:\$PASTA\zabbix_agentd.conf"
   & "c:\$PASTA\zabbix_agentd.exe" -s -c "c:\$PASTA\zabbix_agentd.conf"
   Start-Sleep -s 2
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Serviço instalado com sucesso.                                                               "
   Write-Host "#############################################################################################"
   Write-Host ""
   Start-Sleep -s 2
   Write-Host "#############################################################################################"
   Write-Host "                                Resumo do Upgrade/Downgrade                                 #"
   Write-Host "#############################################################################################"
   Write-Host "                                                                                             "
   Write-Host "Share: $SHARE                                                                                "
   Write-Host "S.O: $WINDOWS_SO $WINDOWS_ARQ                                                                "
   Write-Host "Versão: $VERSIONOLD removida com sucesso.                                                    "
   Write-Host "Versão: $CHANGEVERSION instalada com sucesso.                                                "
   Write-Host "                                                                                             "
   Write-Host "#############################################################################################"
   Write-Host ""
   Write-Host "#############################################################################################"
   Write-Host "Parabéns, Zabbix Agent atualizado com sucesso.                                               "
   Write-Host "#############################################################################################"
   Write-Host ""
   cd c:\
    }
   }
  }
 }
}
