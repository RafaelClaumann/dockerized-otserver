export SERVER_NAME=OTServBR-Global

export DATABASE_USER=forgottenserver
export DATABASE_PASSWORD=noob
export DATABASE_NAME=forgottenserver

export DOCKER_NETWORK_CIDR=192.168.128.0/20
export DOCKER_NETWORK_GATEWAY=192.168.128.1

# verifica se o usuario quer fazer o download do servidor
if [ "$1" = "--download" ] || [ "$1" = "-d" ]; then
    echo "iniciando download do servidor!"
    wget --quiet \
         --show-progress \
         -P server/ https://github.com/opentibiabr/canary/releases/download/v2.6.1/canary-v2.6.1-ubuntu-22.04-executable+server.zip
    unzip -o -d server/ server/canary-v2.6.1-ubuntu-22.04-executable+server.zip
    rm -r server/canary-v2.6.1-ubuntu-22.04-executable+server.zip
    chmod +x server/canary
    echo "download concluído!"
fi


# obtendo o schema original do servidor
rm -r sql/00-schema.sql &> /dev/null
cp server/schema.sql sql/00-schema.sql

# iniciando os containers
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
    echo "configuring php extensions"
    echo
    docker exec -i php bash <<-EOF
        chmod -R 777 /var/www/*
        docker-php-ext-install mysqli &> /dev/null
        apachectl restart &> /dev/null
EOF
fi;

# exibindo status dos containers
echo
echo "is php        running? $(docker inspect -f {{.State.Running}} php)"
echo "is mysql      running? $(docker inspect -f {{.State.Running}} mysql)"
echo "is server     running? $(docker inspect -f {{.State.Running}} server)"
echo "is phpmyadmin running? $(docker inspect -f {{.State.Running}} phpmyadmin)"
echo
echo "otserver_otserver network gateway: $DOCKER_NETWORK_GATEWAY"
echo
