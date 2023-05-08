#!/bin/bash

export SERVER_NAME=OTServBR

export DATABASE_NAME=otservdb
export DATABASE_USER=otserv
export DATABASE_PASSWORD=noob

export DOCKER_NETWORK_GATEWAY=192.168.128.1
export DOCKER_NETWORK_CIDR=192.168.128.0/20

################################
#### como executar o script ####
################################
#  sh ./start.sh -d -s                 # faz o download do servidor em 'server/' e copia o 'server/schema.sql' para 'sql/00_schema.sql'
#  sh ./start.sh -d                    # faz o download do servidor em 'server/'
#  sh ./start.sh -s                    # copia o 'server/schema.sql' para 'sql/00_schema.sql'
#  sh ./start.sh                       # espera que o servidor esteja em 'server/' e schema.sql em 'sql/00_schema.sql'

# avalia se o download do servidor e/ou copia do schema foi solicitado pelo usuário
# a ordem dos parametros(--download e --schema) ou suas abreviações(-d e -s) não faz diferença
readonly NUM_ARGS=$#
download=false
schema=false
while [ "$1" ]
do    
    if [[ "$1" == "-d" ]] || [[ "$1" == "--download" ]] && [ $download == false ]; then
        printf "[INFO] iniciando download do servidor! \n"

        download_url=https://github.com/opentibiabr/canary/releases/download/v2.6.1/canary-v2.6.1-ubuntu-22.04-executable+server.zip
        wget --show-progress -P server/ $download_url

        # https://www.gnu.org/software/wget/manual/html_node/Exit-Status.html
        exit_status=$?
        if [ ! $exit_status -eq 0 ]; then
            echo "[ERROR] erro durante o wget - $exit_status"
            exit 1
        fi

        unzip -o -d server/ server/canary-v2.6.1-ubuntu-22.04-executable+server.zip &> /dev/null
        rm -r server/canary-v2.6.1-ubuntu-22.04-executable+server.zip
        chmod +x server/canary
        echo "[INFO] download concluído e extraído em 'otserver/server/'!"
        download=true
    fi

    if [[ "$1" == "-s" ]] || [[ "$1" == "--schema" ]] && [ $schema == false ]; then
        if [ ! -f "server/schema.sql" ]; then
            echo "[ERROR] arquivo 'otserver/server/schema.sql' não encontrado"
            exit 1
        fi

        echo "[INFO] copiando schema 'otserver/server/schema.sql' para 'otserver/sql/00_schema.sql'"
        rm -r sql/00_schema.sql &> /dev/null
        cp server/schema.sql sql/00_schema.sql
        schema=true
    fi

    shift
done

# verifica se alguns arquivos e diretórios do servidor existem
if [ ! -d "server/" ]                       ||
   [ ! -d "server/data" ]                   ||
   [ ! -d "server/data-otservbr-global" ]   ||   
   [ ! -f "server/canary" ];
then
   echo "[ERROR] arquivos do servidor não encontrados! reexecute o script com a flag '-d' ou '--download'"
   exit 1
fi

# garante que o 'sql/00_schema.sql' existe antes de iniciar o servidor
# copia o 'server/schema.sql' para 'sql/00_schema.sql'
if [ ! -f "sql/00_schema.sql" ] && [ -f "server/schema.sql" ]; then
    echo "[INFO] copiando schema 'otserver/server/schema.sql' para 'otserver/sql/00_schema.sql'"
    cp server/schema.sql sql/00_schema.sql
fi

#################################
#### iniciando os containers ####
#################################
docker-compose up -d

# substituindo valores no arquivo config.lua
sed -i "s/^serverName\s=\s.*\"$/serverName = \"$SERVER_NAME\"/g" server/config.lua
sed -i "s/^mysqlHost\s=\s.*\"$/mysqlHost = \"$DOCKER_NETWORK_GATEWAY\"/g" server/config.lua
sed -i "s/^mysqlUser\s=\s.*\"$/mysqlUser = \"$DATABASE_USER\"/g" server/config.lua
sed -i "s/^mysqlPass\s=\s.*\"$/mysqlPass = \"$DATABASE_PASSWORD\"/g" server/config.lua
sed -i "s/^mysqlDatabase\s=\s.*\"$/mysqlDatabase = \"$DATABASE_NAME\"/g" server/config.lua
sed -i "s/^ip\s=\s.*\"$/ip = \"$DOCKER_NETWORK_GATEWAY\"/g" server/config.lua

# substituindo valores no arquivo login.php
sed -i "s/^\$databaseURL\s.*=\s.*;$/\$databaseURL = \"$DOCKER_NETWORK_GATEWAY\";/g" site/login.php
sed -i "s/^\$databaseUser\s.*=\s.*;$/\$databaseUser = \"$DATABASE_USER\";/g" site/login.php
sed -i "s/^\$databaseUserPassword\s.*=\s.*;$/\$databaseUserPassword = \"$DATABASE_PASSWORD\";/g" site/login.php
sed -i "s/^\$databaseName\s.*=\s.*;$/\$databaseName = \"$DATABASE_NAME\";/g" site/login.php

# instalando extensão no container php
if [ "$(docker exec php bash -c "php -m | grep mysqli")" = "" ]; then
    echo
    echo "[INFO] configuring php extensions"
    echo
    docker exec -i php bash <<-EOF
        chmod -R 777 /var/www/*
        docker-php-ext-install mysqli &> /dev/null
        apachectl restart &> /dev/null
EOF
fi;

# exibindo status dos containers
echo
echo "[INFO] is php        running? $(docker inspect -f {{.State.Running}} php)"
echo "[INFO] is mysql      running? $(docker inspect -f {{.State.Running}} mysql)"
echo "[INFO] is server     running? $(docker inspect -f {{.State.Running}} server)"
echo "[INFO] is phpmyadmin running? $(docker inspect -f {{.State.Running}} phpmyadmin)"
echo

echo  
echo "[INFO] docker network gateway address    ->  $DOCKER_NETWORK_GATEWAY"
echo "[INFO] docker subnet cidr                ->  $DOCKER_NETWORK_CIDR"
echo
echo "[INFO] phpMyAdmin address                ->  http://localhost:9090/"
echo "[INFO] php login server address          ->  http://localhost:8080/login.php"
echo
echo "[INFO] server name                       ->  $SERVER_NAME"
echo "[INFO] database name                     ->  $DATABASE_NAME"
echo "[INFO] database user/pass                ->  $DATABASE_USER / $DATABASE_PASSWORD"
echo

echo "[INFO] inicialização concluida"
echo
