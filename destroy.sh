docker-compose down --remove-orphans -v
docker network prune -f
docker container prune -f
docker volume prune -f
docker builder prune -f
docker volume rm $(docker volume list -q)
