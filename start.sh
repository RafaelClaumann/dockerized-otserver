export DATABASE_USER=forgottenserver
export DATABASE_PASSWORD=noob
export DATABASE_NAME=forgottenserver
export SERVER_NAME=OTServBR-Global

export DOCKER_NETWORK_CIDR=192.168.128.0/20
export DOCKER_NETWORK_GATEWAY=192.168.128.1

rm -r sql/00-schema.sql &> /dev/null
cp server/schema.sql sql/00-schema.sql

docker-compose up -d

echo
echo "is php        running? $(docker inspect -f {{.State.Running}} php)"
echo "is mysql      running? $(docker inspect -f {{.State.Running}} mysql)"
echo "is phpmyadmin running? $(docker inspect -f {{.State.Running}} phpmyadmin)"
echo
echo "opentibia_otserver docker network gateway: $DOCKER_NETWORK_GATEWAY"
echo

sed -i "s/^serverName\s=\s.*\"$/serverName = \"$SERVER_NAME\"/g" server/config.lua
sed -i "s/^mysqlHost\s=\s.*\"$/mysqlHost = \"$DOCKER_NETWORK_GATEWAY\"/g" server/config.lua
sed -i "s/^mysqlUser\s=\s.*\"$/mysqlUser = \"$DATABASE_USER\"/g" server/config.lua
sed -i "s/^mysqlPass\s=\s.*\"$/mysqlPass = \"$DATABASE_PASSWORD\"/g" server/config.lua
sed -i "s/^mysqlDatabase\s=\s.*\"$/mysqlDatabase = \"$DATABASE_NAME\"/g" server/config.lua
sed -i "s/^ip\s=\s.*\"$/ip = \"$DOCKER_NETWORK_GATEWAY\"/g" server/config.lua

sed -i "s/^\$databaseURL\s.*=\s.*;$/\$databaseURL = \"$DOCKER_NETWORK_GATEWAY\";/g" site/login.php
sed -i "s/^\$databaseUser\s.*=\s.*;$/\$databaseUser = \"$DATABASE_USER\";/g" site/login.php
sed -i "s/^\$databaseUserPassword\s.*=\s.*;$/\$databaseUserPassword = \"$DATABASE_PASSWORD\";/g" site/login.php
sed -i "s/^\$databaseName\s.*=\s.*;$/\$databaseName = \"$DATABASE_NAME\";/g" site/login.php

until [ "$(docker inspect -f {{.State.Running}} php)" == "true" ] &&
      [ "$(docker inspect -f {{.State.Running}} phpmyadmin)" == "true" ]; do
    sleep 0.1
done
echo "configuring php extensions"
echo
if [ "$(docker exec php bash -c "php -m | grep mysqli")" = "" ]; then
    docker exec -i php bash <<-EOF
        chmod -R 777 /var/www/*
        docker-php-ext-install mysqli
        apachectl restart
EOF
fi;
