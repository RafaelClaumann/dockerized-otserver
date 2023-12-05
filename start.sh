#!/bin/bash

#
# sh start.sh
# sh start.sh -d
# sh start.sh --download
#

export SERVER_NAME=OTServBR

export DATABASE_NAME=otservdb
export DATABASE_USER=otserv
export DATABASE_PASSWORD=noob

export DOCKER_NETWORK_GATEWAY=192.168.128.1
export DOCKER_NETWORK_CIDR=192.168.128.0/20

# realiza o download do servidor quando o parâmetro posicional '-d' ou '--download' é fornecido
if [[ "$1" == "-d" ]] || [[ "$1" == "--download" ]]; then
    printf "[INFO] iniciando download do servidor! \n"

    download_url=https://github.com/opentibiabr/canary/releases/download/v2.6.1/canary-v2.6.1-ubuntu-22.04-executable+server.zip
    wget --show-progress -P server/ $download_url

    # se a saída do comando anterior(wget) for diferente de 0 significa que ocorreu um erro
    # https://www.gnu.org/software/wget/manual/html_node/Exit-Status.html
    exit_status=$?
    if [ ! $exit_status -eq 0 ]; then
        echo "[ERROR] erro durante o wget - $exit_status"
        exit 1
    fi

    # descompacta os arquivos do servidor na pasta 'server/'
    # copia o 'server/schema.sql' para 'sql/00_schema.sql'
    # altera as permissões do arquivo 'server/canary' para que seja possível executa-lo
    unzip -o -d server/ server/canary-v2.6.1-ubuntu-22.04-executable+server.zip &> /dev/null
    cp server/schema.sql sql/00_schema.sql 
    chmod +x server/canary

    # remove arquivos desnecessarios
    rm -r server/.github server/cmake server/data-canary server/docker \
        server/docs server/src server/tests server/.editorconfig server/.gitignore \
        server/.reviewdog.yml server/.yamllint.yaml server/canary.rc server/CMakeLists.txt \
        server/CMakePresets.json server/CODE_OF_CONDUCT.md server/gdb_debug server/GitVersion.yml \
        server/Jenkinsfile server/package.json server/recompile.sh server/sonar-project.properties \
        server/start_gdb.sh server/start.sh server/vcpkg.json

    echo "[INFO] download concluído, arquivos do servidor extraídos em 'server/'"
    echo
fi

# verifica a presença dos arquivos que compõe o servidor
if [ ! -d "server/" ]                       ||
   [ ! -d "server/data" ]                   ||
   [ ! -d "server/data-otservbr-global" ]   ||  
   [ ! -f "server/canary" ];
then
   echo "[ERROR] arquivos do servidor não foram encontrados! reexecute o script com a flag '-d' ou '--download'"
   exit 1
fi


# iniciando os containers
docker-compose up -d

# instalando extensão no container php
if [ "$(docker exec php bash -c "php -m | grep mysqli")" = "" ]; then
    docker exec -i php bash <<-EOF
        chmod -R 777 /var/www/*
        docker-php-ext-install mysqli &> /dev/null
        apachectl restart &> /dev/null
EOF
fi;

# exibindo status dos containers
echo
echo "[INFO] phpMyAdmin address                ->  http://localhost:9090/"
echo "[INFO] php login server address          ->  http://localhost:8080/login.php"
echo "[INFO] server name                       ->  $SERVER_NAME"
echo "[INFO] database name                     ->  $DATABASE_NAME"
echo "[INFO] database user/pass                ->  $DATABASE_USER / $DATABASE_PASSWORD"
echo

echo "[INFO] inicialização concluida"
echo
