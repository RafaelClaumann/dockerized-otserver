# Dockerized Tibia OTserver

## O que tem nesse repositório?
Alguns scripts shell, arquivos sql e arquivos yaml para criar o ambiente e executar um otserver com banco de dados, gerenciador de banco de dados e servidor web para login.

## Requisitos
- docker
- docker-compose

<br>

## Informações Gerais
Os downloads do `Tibia Client 12x` e do `Servidor OpenTibiaBR Canary` podem ser feitos através das [tags](https://github.com/opentibiabr/canary/tags) do repositório [opentibiabr/canary](https://github.com/opentibiabr/canary). Também é possível obter o servidor clonando a branch main do mesmo repositório. Demais informações podem ser obtidas na [documentação opentibiabr canary](https://docs.opentibiabr.com/home/introduction).

<br>

## start.sh
No arquivo `start.sh` são definidas as credenciais do banco de dados e as configurações de rede do Docker(_gateway e subnet CIDR_). Em poucos casos será preciso ajustar as configurações de rede. O arquivo ainda é responsável executar os comandos que iniciam os containers docker, realizam alterações nos arquivos `server/config.lua`, `site/login.php` e instalam extensões no container php.

O arquivo `destroy.sh` é usado para limpar o ambiente, ele pode ser utilizado para recriar o otserver e os containers auxiliares. Todos os dados armazenados nos containers são perdidos quando o ambiente é limpo.

<br>

## Listando as redes do docker
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

<br>

## Gesior2012 e myAAC
Caso queira instalar os AACs(Automatic Account Creator) [Gesior2012](https://github.com/gesior/Gesior2012) ou [myAAC](https://github.com/otsoft/myaac) será preciso adicionar algumas extensões no container php. Informações a respeito das extensões necessárias podem ser encontradas nos repositórios dos respectivos AACs.
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

A instalação do Gesior2012 precisa que o endereço IP de gateway docker seja colocado no arquivo `site/install.txt`, por outro lado, a instalação do myAAC espera esse endereço no arquivo `site/install/ip.txt`.
``` bash
# instalacao myAAC
rm -r site/config.local.php &> /dev/null  # removendo configuração de instalações anteriores
echo $DOCKER_NETWORK_GATEWAY > site/install/ip.txt

# Gesior2012
echo $DOCKER_NETWORK_GATEWAY > site/install.txt
```

<br>

## MySQL
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

## Detalhes da rota de login - localhost:8080/login.php
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