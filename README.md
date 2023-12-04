# Dockerized Tibia OTserver

### O que tem nesse repositório?
Neste repositório você encontrará scripts shell, arquivos SQL, yaml e PHP para iniciar um ambiente docker e executar um OTserver(_open tibia server_).

Quatro containers são utilizados e cada um deles poussui uma responsabilidade específica:
- OTserver(_open tibia server_)
- banco de dados(_mysql_)
- gerenciador de banco de dados(_phpmyadmin_)
- servidor web para login(_php+apache_)

### Requisitos
- docker
- docker-compose
- unzip
- wget
- notepad++
- client tibia 12x
- dependencias vistas em [Compiling on Ubuntu 22.04](https://github.com/opentibiabr/canary/wiki/Compiling-on-Ubuntu-22.04)

## Indo ao que interessa
Para iniciar o servidor basta executar o script `start.sh`.

O banco de dados pode ser gerenciado através do `phpMyAdmin` exposto em http://localhost:9090, as credenciais para acessa-lo são: `otserv`/`noob`.

O servidor pode ser acessado usando o `Tibia Client 12x`, porém é preciso alterar os valores dos campos `loginWebService` e `clientWebService`([tutorial](https://github.com/RafaelClaumann/dockerized-otserver/blob/main/README.md#alterando-tibia-client)). O download do `Tibia Client 12x` pode ser feito através das [tags](https://github.com/opentibiabr/canary/tags) do repositório [opentibiabr/canary](https://github.com/opentibiabr/canary).

As contas listadas abaixo são criadas na inicialização do banco de dados(MySQL).
| email 	| password 	| chars                                                      	|
|-------	|----------	|------------------------------------------------------------	|
| @god    	| god       | GOD, paladin/sorcerer/druid/knight sample 					|
| @a    	| 1        	| Paladin(800) Sorcerer(800) Druid(800) Knight(800) 			|
| @b    	| 1        	| ADM1                                                       	|
| @c    	| 1        	| ADM2                                                       	|

### Arquivos do repositório
No script `start.sh` são definidas as credenciais do banco de dados e as configurações de rede do Docker, em poucos casos será preciso alterar as credenciais ou configurações de rede. O script também é responsável por iniciar os containers, realizar alterações nos arquivos `server/config.lua`, `site/login.php` e instalar extensões no container php.

Parâmetros disponiveis para iniciar o script `start.sh`:
| parâmetro			| descrição																								|
|-------------------|-------------------------------------------------------------------------------------------------------|
| -s ou --schema 	| Realiza uma cópia do `server/schema.sql` para `sql/00_schema.sql`. O arquivo `00_schema.sql` no diretório `/sql` é o schema que será criado automáticamente na inicialização do container MySQL. Se você tem um schema personalizado basta coloca-lo na pasta `sql` com o nome `00_schema.sql` e não usar a flag -s ou --schema. |
| -d ou --download	| Realiza o download e extração do servidor [canary](https://github.com/opentibiabr/canary) na pasta `/server`. Se os arquivos do servidor não forem encontrados e você não fornecer a flag -d ou --download o script será interrompido.	|


O script `destroy.sh` é usado para limpar o ambiente, você pode usa-lo para encerrar o servidor e limpar seus rastros antes de iniciar um novo ambiente do zero. Todos os containers são encerrados e seus dados são perdidos.

O arquivo `login.php` é uma simplificação do login.php encontrado no [MyAAC](https://github.com/otsoft/myaac/blob/master/login.php).
Essa simplificação facilita a autenticação no servidor/banco de dados e evita a instalação e configuração de um AAC(_Gesior2012 ou MyAAC_).
Durante o login, o client do tibia 12x envia requisições nas URLs `loginWebService` e `clientWebService` configuradas previamente([tutorial](https://github.com/RafaelClaumann/dockerized-otserver/blob/main/README.md#alterando-tibia-client)).
Essas URLs levam até o arquivo `login.php` do servidor web(php+apache) que se comunicará com o banco de dados(MySQL) para realizar a autenticação do usuário.
O servidor web não tem interface gráfica, só é possível criar contas e personagens no banco de dados usando comandos SQL.

O schema do banco de dados e algumas contas são criados de forma automática na inicialização do container `MySQL`, veja os arquivos [00_schema.sql](https://github.com/RafaelClaumann/dockerized-otserver/blob/main/sql/00_schema.sql) e [01_data.sql](https://github.com/RafaelClaumann/dockerized-otserver/blob/main/sql/01_data.sql).

O `docker-compose.yaml` contém a declaração dos containers(_ubuntu, mysql, phpmyadmin e php-apache_) que são iniciados quando o script `start.sh` é executado. Os campos no formato `${xxxx}` em `docker-compose.yaml` recebem os valores das variaveis exportadas no script `start.sh`.

## Alterando URL de autenticação no Tibia Client
Supondo que o [download](https://github.com/opentibiabr/canary/tags) do client ja tenha sido realizando e o [notepad++](https://notepad-plus-plus.org/downloads/) esteja instalado, navegue até a pasta `/bin` do client, clique com o botão direito do mouse sob o arquivo `127.0.0.1_client.exe`, abrir com notepad++ e localize as palavras `loginWebService` e `clientWebService`.

O valor atribuído a `loginWebService` e `clientWebService` deve ser igual a URL do webserver, ou seja, `http://127.0.0.1:8080/login.php` exposta pelo container `php:8.0-apache`.

As linhas no **quadro abaixo** são um exemplo do que pode ser encontrado ao abrir o client com o notepad++. Selecionado as linhas é possível ver que existe uma série de espaços em branco após o término da URL, a quantidade de espaços varia de acordo com o tamanho da URL.
``` txt
loginWebService=http://127.0.0.1:8080/login.php                       
clientWebService=http://127.0.0.1:8080/login.php                         
```

Supondo que as URLs originais(`loginWebService`, `clientWebService`) possuem *dez caracteres* e serão substituidas por uma nova URL de *quinze caracteres*, precisamos remover *cinco espaços em branco* após o termino da nova URL.

- **Se** NOVA_URL **>** URL_ORIGINAL **então** remova espaços ao final da URL para equilibrar o tamanho inicial do campo
- **Se** NOVA_URL **<** URL_ORIGINAL **então** adicione espaços ao final da URL para equilibrar o tamanho inicial do campo


[Tibia 11 Discussion(+Tutorial how to able to use it)](https://otland.net/threads/tibia-11-discussion-tutorial-how-to-able-to-use-it.242719/)

[Cliente Tibia 12 com Notepad++](https://forums.otserv.com.br/index.php?/forums/topic/169530-cliente-tibia-12-com-notepad/&tab=comments#comment-1255507)

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
