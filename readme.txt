docker network inspect --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' opentibia_default
echo $(docker network inspect --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' opentibia_default) > site/install/ip.txt 

chown -R www-data:www-data /var/www/

apt update && apt install -y                   &&
apt install libxml2-dev -y                     &&
apt install install libcurl4-openssl-dev -y    &&
apt install install zlib1g-dev -y              &&

docker-php-ext-install bcmath       &&
docker-php-ext-install curl         &&
docker-php-ext-install dom          &&
docker-php-ext-install mysqli       &&
docker-php-ext-install pdo          &&
docker-php-ext-install pdo_mysql    &&
docker-php-ext-install xml          &&
apachectl restart

cd /usr/local/etc/php
cp php.ini-development php.ini

apt update && apt install vim -y

vim php.ini
extension=pdo_mysql
extension=curl
extension=gd
extension=mbstring
extension=mysqli
zend.multibyte=On


apt install \
    git \
    cmake build-essential \
    libluajit-5.1-dev \
    libboost-system-dev \
    libboost-iostreams-dev \
    libboost-filesystem-dev \
    libpugixml-dev \
    libcrypto++-dev \
    libfmt-dev


INSERT INTO `accounts` (`id`, `name`, `password`, `secret`, `type`, `premium_ends_at`, `email`, `creation`) VALUES ('1', 'rafael@rafael.com', '1', NULL, '1', '365', '', '0');

INSERT INTO `players` (`id`, `name`, `group_id`, `account_id`, `level`, `vocation`, `health`, `healthmax`, `experience`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`, `maglevel`, `mana`, `manamax`, `manaspent`, `soul`, `town_id`, `posx`, `posy`, `posz`, `conditions`, `cap`, `sex`, `lastlogin`, `lastip`, `save`, `skull`, `skulltime`, `lastlogout`, `blessings`, `onlinetime`, `deletion`, `balance`, `offlinetraining_time`, `offlinetraining_skill`, `stamina`, `skill_fist`, `skill_fist_tries`, `skill_club`, `skill_club_tries`, `skill_sword`, `skill_sword_tries`, `skill_axe`, `skill_axe_tries`, `skill_dist`, `skill_dist_tries`, `skill_shielding`, `skill_shielding_tries`, `skill_fishing`, `skill_fishing_tries`) VALUES ('1', 'God', '3', '1', '500', '0', '150', '150', '0', '0', '0', '0', '0', '136', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', 0x0, '40000', '1', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '43200', '-1', '2520', '10', '0', '10', '0', '10', '0', '10', '0', '10', '0', '10', '0', '10', '0');


docker run -it \
    --env MYSQL_DBNAME=forgottenserver \
    --env MYSQL_HOST=mysql-svc \
    --env MYSQL_PORT=3306 \
    --env MYSQL_PASS=noob \
    --env MYSQL_USER=forgottenserver \
    --env ENV_LOG_LEVEL=debug \
    --env LOGIN_PORT=8080 \
    --env LOGIN_HTTP_PORT=8080 \
    --env SERVER_NAME=OTServBR-Global \
    --env SERVER_LOCATION=Bra \
    --env SERVER_IP=172.18.0.1 \
    --env SERVER_PORT=7172 \
    --env VOCATIONS=druid,paladin,sorcerer,knight \
    --network opentibia_default \
    -p 8080:8080 \
    opentibiabr/login-server

  login-svc:
    restart: on-failure
    image: opentibiabr/login-server
    container_name: login
    depends_on:
      - mysql-svc
      - phpmyadmin-svc
    environment:
      MYSQL_DBNAME: forgottenserver
      MYSQL_HOST: mysql-svc
      MYSQL_PORT: 3306
      MYSQL_USER: forgottenserver
      MYSQL_PASS: noob
      LOGIN_HTTP_PORT: 8080
      SERVER_NAME: OTServBR-Global
      SERVER_LOCATION: BRA
      SERVER_IP: localhost
      SERVER_PORT: 7172
    ports:
      - 8080:8080

CREATE USER 'forgottenserver'@'localhost' IDENTIFIED BY 'noob';
GRANT ALL PRIVILEGES ON *.* TO 'forgottenserver'@'localhost' WITH GRANT OPTION;

CREATE USER 'forgottenserver'@'%' IDENTIFIED BY 'noob';
GRANT ALL PRIVILEGES ON *.* TO 'forgottenserver'@'%' WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;

CREATE DATABASE forgottenserver;
USE forgottenserver;


until [ "$(docker inspect -f {{.State.Running}} php)" == "true" ] &&
      [ "$(docker inspect -f {{.State.Running}} phpmyadmin)" == "true" ]; do
    sleep 0.1
done

if [ "$(docker inspect -f {{.State.Running}} mysql)" = "true" ]; then
    docker container restart mysql &> /dev/null
fi

until [ "$(docker inspect -f {{.State.Running}} mysql)" == "true" ]; do
    sleep 0.1
done



CREATE USER 'forgottenserver'@'localhost' IDENTIFIED BY 'noob';
GRANT ALL PRIVILEGES ON *.* TO 'forgottenserver'@'localhost' WITH GRANT OPTION;
CREATE USER 'forgottenserver'@'%' IDENTIFIED BY 'noob';
GRANT ALL PRIVILEGES ON *.* TO 'forgottenserver'@'%' WITH GRANT OPTION;

export DOCKER_NETWORK_GATEWAY=$(docker network inspect --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' opentibia_otserver)


docker exec -i mysql mysql <<EOF
    mysql -u root -e "CREATE DATABASE $DATABASE_NAME;"
    mysql -u root -D $DATABASE_NAME < schema.sql
    mysql -u root -D $DATABASE_NAME < data.sql
EOF



docker exec mysql mysql -u $MYSQL_USER  $DATABASE_NAME <<EOF
    CREATE DATABASE $DATABASE_NAME;
    USE $DATABASE_NAME;
    SOURCE schema.sql;
    SOURCE $DATABASE_NAME < data.sql;
    CREATE USER '$MYSQL_USER'@localhost IDENTIFIED BY '$MYSQL_PASSWORD';
    GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'localhost' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;
    FLUSH 



https://github.com/docker-library/docs/tree/master/mysql#initializing-a-fresh-instance
- ${PWD}/data.sql:/docker-entrypoint-initdb.d/01-data.sql


    entrypoint: ["/bin/sh","-c"]
    command:
      - |
        apk add gdb
        server/start_gdb.sh