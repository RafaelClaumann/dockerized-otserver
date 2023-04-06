# Dockerized Tibia OTserver

## O que tem nesse repositório?
Nesse repositório você encontrará scripts shell, arquivos SQL, yaml e PHP que são usados para criar um ambiente com OTserver, banco de dados, gerenciador de banco de dados e servidor web para login em containers docker.
O objetivo principal é criar o ambiente sem complicações executando um único comando. Todos os arquivos desse repositório foram executados e testaods em sistemas linux.

## Requisitos
- docker
- docker-compose
- unzip
- wget
- client tibia 12x 
- dependencias vistas em [Compiling on Ubuntu 22.04](https://github.com/opentibiabr/canary/wiki/Compiling-on-Ubuntu-22.04) podem ser necessarias para iniciar o servidor

## Indo ao que interessa
Para iniciar o servidor basta executar o script `start.sh`. O script oferece a opção `--download` ou `-d` para fazer o download e extração dos arquivos do servidor [canary](https://github.com/opentibiabr/canary) na pasta `server`.
 
O arquivo `destroy.sh` destroi os recursos(_networks_, _containers_, _volumes_) inutilizados do docker.

O banco de dados pode ser gerenciado através do `phpMyAdmin`, ele fica exposto em localhost na porta 9090. As credenciais para acessa-lo são: usuário=`otserv` senha=`noob`. É possível alterar as credenciais do banco de dados no arquivo `start.sh` antes de iniciar o servidor.

As seguintes contas para login no otserver são criadas na inicialização do MySQL.
| email 	| password 	| chars                                                      	|
|-------	|----------	|------------------------------------------------------------	|
| @god    	| god       | GOD, paladin/sorcerer/druid/knight sample 					|
| @a    	| 1        	| Paladin(800) Sorcerer(800) Druid(800) Knight(800) 			|
| @b    	| 1        	| ADM1                                                       	|
| @c    	| 1        	| ADM2                                                       	|

Para acessar o servidor usando o client tibia 12x é preciso alterar os valores das chaves `loginWebService` e `clientWebService`. O valor dessas chaves deve ser `localhost:8080/login.php` para que ao clicar em login a requisição seja encaminhada ao container PHP a as credenciais validadas no MySQL. Veja como realizar as alterações no client seguindo [esse guia](https://github.com/RafaelClaumann/dockerized-otserver/blob/main/README.md#alterando-tibia-client).

Os downloads do `Tibia Client 12x` e `Servidor OpenTibiaBR Canary` podem ser feitos através das [tags](https://github.com/opentibiabr/canary/tags) do repositório [opentibiabr/canary](https://github.com/opentibiabr/canary). Demais informações estão presentes na [documentação opentibiabr canary](https://docs.opentibiabr.com/home/introduction).

## Arquivos do repositório
No arquivo `start.sh` são definidas as credenciais do banco de dados e as configurações de rede do Docker(_gateway e subnet CIDR_). Em poucos casos será preciso ajustar as configurações de rede. O arquivo ainda é responsável executar os comandos que iniciam os containers docker, realizam alterações nos arquivos `server/config.lua`, `site/login.php` e instalam extensões no container php. O script `start.sh` pode ser iniciado com os parâmetros `--download` ou `--schema`, a ordem não importa.

| parâmetro			| descrição																								|
|-------------------|-------------------------------------------------------------------------------------------------------|
| -s ou --schema 	| realiza uma cópia do `server/schema.sql` para `sql/00_schema.sql`									 	|
| -d ou --download	| faz o download e extrai o servidor [canary](https://github.com/opentibiabr/canary) na pasta server/	|


O arquivo `destroy.sh` é usado para limpar o ambiente. Excuta-lo é uma boa opção para parar o servidor e limpar seus rastros antes de iniciar um novo ambiente do zero. Todos os dados armazenados nos containers são perdidos quando o ambiente é limpo.

`login.php` é uma simplificação do login.php encontrado no [MyAAC](https://github.com/otsoft/myaac/blob/master/login.php). O objetivo desta simplificação é conseguir realizar a autenticação no servidor/banco de dados sem precisar instalar ou configurar um AAC(_Gesior2012 ou MyAAC_) toda vez que o ambiente for iniciado ou reiniciado. Só é possível criar contas e personagens diretamente no banco de dados.

O arquivo `logs.php` serve para fins de debug e pode ser acessado em `localhost:8080/logs.php`.

O schema do banco de dados e algumas contas são criados de forma automática na inicialização do container `MySQL`, veja os arquivos [00_schema.sql](https://github.com/RafaelClaumann/dockerized-otserver/blob/main/sql/00_schema.sql) e [data.sql](https://github.com/RafaelClaumann/dockerized-otserver/blob/main/sql/01-data.sql).

`docker-compose.yaml` contém a declaração dos containers(_ubuntu, mysql, phpmyadmin e php-apache_) que são iniciados quando o arquivo `start.sh` é executado. Os campos no formato `${SERVER_NAME}` referenciam e obtém os valores das variaveis exportadas pelo arquivo `start.sh`.

## Alterando tibia client
Supondo que o [download](https://github.com/opentibiabr/canary/tags) do client ja tenha sido realizando e o [notepad++](https://notepad-plus-plus.org/downloads/) esteja instalado, navegue até a pasta  `/bin` do client extraído, clique com o botão direito do mouse sob o arquivo `127.0.0.1_client.exe` e em abrir com notepad++.

Localize as palavras `loginWebService` e `clientWebService` no arquivo aberto com o notepad++ e leia as instruções abaixo.

As linhas no **quadro abaixo** são um exemplo do que pode ser encontrado ao abrir o client com o notepad++. Selecionado as linhas é possível ver que existe uma série de espaços em branco após o término da URL, a quantidade de espaços varia de acordo com o tamanho da URL.

É preciso calcular a diferença da quantidade de caracteres entre a URL original e a nova URL. O resultado dessa diferença é a quantidade de espaços em branco que devem ser adicionados ou removidos.

Supondo que a URL original possui *dez caracteres* e será substituida por uma URL de *quinze caracteres*, precisamos remover *cinco espaços em branco* após o termino da nova URL.

- NOVA_URL > URL_ORIGINAL -> remova espaços ao final da url
- NOVA_URL < URL_ORIGINAL -> adicione espaços ao final da url

``` txt
loginWebService=http://127.0.0.1:8080/login.php                       
clientWebService=http://127.0.0.1:8080/login.php                         
```
- [Tibia 11 Discussion(+Tutorial how to able to use it)](https://otland.net/threads/tibia-11-discussion-tutorial-how-to-able-to-use-it.242719/)
- [Cliente Tibia 12 com Notepad++](https://forums.otserv.com.br/index.php?/forums/topic/169530-cliente-tibia-12-com-notepad/&tab=comments#comment-1255507)

## Opcional - Gesior2012 ou myAAC
Os AACs(Automatic Account Creator) citados são sites criados com aparencia e funcionalidades parecidas com as encontradas no site oficial do tibia.

Caso queira instalar um dos AACs [Gesior2012](https://github.com/gesior/Gesior2012) ou [myAAC](https://github.com/otsoft/myaac) será preciso adicionar algumas extensões no container PHP.

Mais informações a respeito das extensões necessárias podem ser encontradas nos repositórios dos respectivos AACs.
``` bash
# Os comandos mostrados abaixo devem ser executados dentro do container PHP.
# docker exec -it php bash
#
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

Para instalar o Gesior2012 é preciso inserir o endereço IP do gateway da rede docker em `site/install.txt`, enquanto no myAAC o endereço deve ser inserido em `site/install/ip.txt`.

O endereço do gateway de rede pode ser obtido na varivel `DOCKER_NETWORK_GATEWAY` do arquivo `start.sh` ou através do comando `docker network inspect --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' otserver_otserver`.
``` bash
# instalacao myAAC, endereço IP em site/install/ip.txt
rm -r site/config.local.php &> /dev/null  # removendo configuração de instalações anteriores
echo $DOCKER_NETWORK_GATEWAY > site/install/ip.txt

# instalacao Gesior2012, endereço IP em site/install.txt
echo $DOCKER_NETWORK_GATEWAY > site/install.txt
```

## Links
- [Tibia 11 Discussion(+Tutorial how to able to use it)](https://otland.net/threads/tibia-11-discussion-tutorial-how-to-able-to-use-it.242719/)
- [Cliente Tibia 12 com Notepad++](https://forums.otserv.com.br/index.php?/forums/topic/169530-cliente-tibia-12-com-notepad/&tab=comments#comment-1255507)
- [Otserv Brasil: Tutoriais Infraestrutura](https://forums.otserv.com.br/index.php?/forums/forum/445-infraestrutura/)

---

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
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

<br>

## NGROK
```bash
# https://ngrok.com/
# https://tech.aufomm.com/how-to-use-ngrok-with-docker/
docker network create ngrok_net

docker container run --rm -it \
  --name ngrok \
  --env NGROK_AUTHTOKEN=$(cat .ngrok_token) \
  --network ngrok_net \
  ngrok/ngrok http nginx:80

docker container run --rm -it \
  --name nginx \
  --network ngrok_net \
  nginx
```

<br>
