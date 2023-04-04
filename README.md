# Dockerized Tibia OTserver

### O que tem nesse repositório?
Alguns scripts shell, arquivos sql e arquivos yaml para criar um ambiente e executar um otserver com banco de dados, gerenciador de banco de dados e servidor web para login.

### Requisitos
- docker
- docker-compose
- dependencias vistas em [Compiling on Ubuntu 22.04](https://github.com/opentibiabr/canary/wiki/Compiling-on-Ubuntu-22.04) podem ser necessarias para iniciar o servidor
- client tibia 12x


### Arquivos do repositório
No arquivo `start.sh` são definidas as credenciais do banco de dados e as configurações de rede do Docker(_gateway e subnet CIDR_). Em poucos casos será preciso ajustar as configurações de rede. O arquivo ainda é responsável executar os comandos que iniciam os containers docker, realizam alterações nos arquivos `server/config.lua`, `site/login.php` e instalam extensões no container php.

O arquivo `destroy.sh` é usado para limpar o ambiente. Excuta-lo é uma boa opção para parar o servidor e limpar seus rastros antes de iniciar um novo ambiente do zero. Todos os dados armazenados nos containers são perdidos quando o ambiente é limpo.

`site/login.php` é uma simplificação do login.php encontrado no [MyAAC](https://github.com/otsoft/myaac/blob/master/login.php). O objetivo desta simplificação é conseguir realizar a autenticação no servidor sem precisar instalar ou configurar um AAC(_Gesior2012 ou MyAAC_) toda vez que o ambiente for iniciado ou reiniciado. Só é possível criar contas e personagens diretamente no banco de dados.

O arquivo `logs.php` serve para fins de debug e pode ser acessado em `localhost:8080/logs.php`.

O schema do banco de dados e algumas contas são criados de forma automática na inicialização do container `MySQL`, veja os arquivos [schema.sql](https://github.com/RafaelClaumann/dockerized-otserver/blob/main/sql/00-schema.sql) e [data.sql](https://github.com/RafaelClaumann/dockerized-otserver/blob/main/sql/01-data.sql).

`docker-compose.yaml` contém a declaração dos containers(_ubuntu, mysql, phpmyadmin e php-apache_) que são iniciados quando o arquivo `start.sh` é executado. Os campos no formato `${SERVER_NAME}` referenciam e obtém os valores das variaveis exportadas pelo arquivo `start.sh`.

### Informações Importantes
Para acessar o otserver é preciso de um client [Tibia](http://tibia.com/) versão 12 ou superior com `loginWebService` e `clientWebService` apontando para http://127.0.0.1:8080/login.php.

Os downloads do `Tibia Client 12x` e do `Servidor OpenTibiaBR Canary` podem ser feitos através das [tags](https://github.com/opentibiabr/canary/tags) do repositório [opentibiabr/canary](https://github.com/opentibiabr/canary). Demais informações podem ser obtidas na [documentação opentibiabr canary](https://docs.opentibiabr.com/home/introduction).

O phpmyadmin pode ser acessado em http://localhost:9090.

<br>

---

<br>

### Alterando loginWebService e clientWebService do tibia client
Supondo que o download do client ja tenha sido feito a partir do repositório [opentibiabr/canary](https://github.com/opentibiabr/canary/tags).

Após a instalação do [notepad++](https://notepad-plus-plus.org/downloads/) clique com o botão direito do mouse sob o arquivo `/bin/127.0.0.1_client.exe` e em abrir com notepad++.

Selecione as linhas abaixo e veja que existe uma série de espaços em branco após a URL, a quantidade de espaços deve se balanceada e mantida de acordo com o tamanho da URL. Supondo que a URL original de `loginWebService` possui *dez caracteres* e foi substituida por uma URL de *quinze caracteres* será preciso excluir *cinco espaços em branco* após a URL e vice-versa.

Se a URL que será substituída é menor, será preciso adicionar espaços.

Se a URL que será substituída é maior, será preciso remover espaços.
``` txt
loginWebService=http://127.0.0.1:8080/login.php                       
clientWebService=http://127.0.0.1:8080/login.php                         
```

### Listando as redes do docker
``` bash
$docker network list    
    NETWORK ID     NAME                 DRIVER    SCOPE
    bd83d906d3d1   bridge               bridge    local
    2546338521e9   host                 host      local
    42e631403bda   none                 null      local
    0a96c09c01b1   opentibia_otserver   bridge    local

$docker network inspect --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' opentibia_otserver
    192.168.128.1

$docker network inspect --format='{{range .IPAM.Config}}{{.Subnet}}{{end}}' opentibia_otserver
    192.168.128.0/20
```

### Gesior2012 e myAAC
Caso queira instalar os AACs(Automatic Account Creator) [Gesior2012](https://github.com/gesior/Gesior2012) ou [myAAC](https://github.com/otsoft/myaac) será preciso adicionar algumas extensões no container php. Mais informações a respeito das extensões necessárias podem ser encontradas nos repositórios dos respectivos AACs.
``` bash
chmod -R 777 /var/www/*
apt update && \
apt install libxml2-dev \
            libcurl4-openssl-dev \
            zlib1g-dev \
            libzip-dev \
            libluajit-5.1-dev -y

# https://gist.github.com/hoandang/88bfb1e30805df6d1539640fc1719d12
docker-php-ext-install bcmath
docker-php-ext-install curl
docker-php-ext-install dom
docker-php-ext-install mysqli
docker-php-ext-install pdo
docker-php-ext-install pdo_mysql
docker-php-ext-install xml
docker-php-ext-install zip
apachectl restart
```

Para instalar o Gesior2012 é preciso inserir o endereço IP do gateway da rede docker em `site/install.txt`. Para a instalação do myAAC o endereço deverá ser inserido em `site/install/ip.txt`. O endereço do gateway de rede pode ser obtido na varivel `DOCKER_NETWORK_GATEWAY` do arquivo `start.sh` ou através do comando `docker network inspect --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' otserver_otserver`.
``` bash
# instalacao myAAC
rm -r site/config.local.php &> /dev/null  # removendo configuração de instalações anteriores
echo $DOCKER_NETWORK_GATEWAY > site/install/ip.txt

# Gesior2012
echo $DOCKER_NETWORK_GATEWAY > site/install.txt
```

### MySQL
Em algumas situações houveram erros ao logar no PhpMyAdmin e tive que executar as seguintes consultas no banco de dados
``` sql
# Create database and import schema
mysql -u root -e "CREATE DATABASE $DATABASE_NAME;"
mysql -u root -D <DATABASE_NAME> < schema.sql
mysql -u root -D <DATABASE_NAME> < data.sql

# Create user
mysql -u root -e "CREATE USER '<MYSQL_USER>'@localhost IDENTIFIED BY '<MYSQL_PASSWORD>';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '<MYSQL_USER>'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '<MYSQL_USER>'@'%' WITH GRANT OPTION">

#> Make our changes take effect
mysql -u root -e "FLUSH PRIVILEGES;"
```

<br>

## login.php
RequestBody
``` json
{
	"email": "@god",
	"password": "god",
	"stayloggedin": true,
	"type": "login"
}
```

ResponseBody
``` json
{
	"session": {
		"sessionkey": "@god\ngod",
		"lastlogintime": 0,
		"ispremium": true,
		"premiumuntil": 0,
		"status": "active",
		"returnernotification": false,
		"showrewardnews": false,
		"isreturner": true,
		"fpstracking": false,
		"optiontracking": false,
		"tournamentticketpurchasestate": 0,
		"emailcoderequest": false
	},
	"playdata": {
		"worlds": [
			{
				"id": 0,
				"name": "OTServBR-Global",
				"externaladdress": "192.168.128.1",
				"externalport": 7172,
				"externaladdressprotected": "192.168.128.1",
				"externalportprotected": 7172,
				"externaladdressunprotected": "192.168.128.1",
				"externalportunprotected": 7172,
				"previewstate": 0,
				"location": "BRA",
				"anticheatprotection": false,
				"pvptype": "pvp",
				"istournamentworld": false,
				"restrictedstore": false,
				"currenttournamentphase": 2
			}
		],
		"characters": [
			{
				"worldid": 0,
				"name": "GOD",
				"ismale": true,
				"tutorial": false,
				"level": 2,
				"vocation": "No Vocation",
				"outfitid": 75,
				"headcolor": 95,
				"torsocolor": 113,
				"legscolor": 39,
				"detailcolor": 115,
				"addonsflags": 0,
				"ishidden": false,
				"istournamentparticipant": false,
				"ismaincharacter": false,
				"dailyrewardstate": 0,
				"remainingdailytournamentplaytime": 0
			}
		]
	}
}
```
