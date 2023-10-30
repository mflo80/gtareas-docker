#!/bin/bash

FILE="docker-compose.yml"

docker network create --driver=bridge --subnet=192.168.1.0/24 gtnet

if [ -f "$FILE" ];  then
    docker compose up -d
    docker exec -d gtoauth php artisan schedule:run >> /dev/null 2>&1
fi
