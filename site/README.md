# Site

O arquivo `login.php` é copiado((compose.yaml#L74)[https://github.com/RafaelClaumann/dockerized-otserver/blob/main/compose.yaml#L74]) para o sistema de arquivos do container `php:8.0-apache` e é exposto em http://localhost:8080/login.php, servindo como endpoint de autenticação.

Não é preciso instalar um AAC(Gesior2012 ou MyAAC) para conseguir se autenticar no servidor.
