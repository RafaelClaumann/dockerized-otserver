########################################
#### PARA USER COM GESIOR2012/myAAC ####
########################################
# chmod -R 777 /var/www/*
# apt update && \
# apt install libxml2-dev \
#            libcurl4-openssl-dev \
#            zlib1g-dev \
#            libzip-dev \
#            libluajit-5.1-dev -y

# https://gist.github.com/hoandang/88bfb1e30805df6d1539640fc1719d12
# docker-php-ext-install bcmath
# docker-php-ext-install curl
# docker-php-ext-install dom
# docker-php-ext-install mysqli
# docker-php-ext-install pdo
# docker-php-ext-install pdo_mysql
# docker-php-ext-install xml
# docker-php-ext-install zip
# apachectl restart

############################################
#### PARA USAR COM UM SIMPLES LOGIN.PHP ####
############################################
chmod -R 777 /var/www/*
docker-php-ext-install mysqli
apachectl restart
