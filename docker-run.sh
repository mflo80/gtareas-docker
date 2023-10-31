#!/bin/bash

FILE="docker-compose.yml"

if ping -c 1 -t 100 192.168.66.1; then
	echo La RED gtnet ya se encuentra creada
else
	docker network create --driver=bridge --subnet=192.168.66.0/24 gtnet
fi

if [ ! -d "gtapi" ]; then
	mkdir gtapi
fi

if [ ! -d "gtdb" ]; then
	mkdir gtdb
fi

if [ ! -d "gtfrontend" ]; then
	mkdir gtfrontend
fi

if [ ! -d "gtlogin" ]; then
	mkdir gtlogin
fi

if [ ! -d "gtoauth" ]; then
	mkdir gtoauth
fi

if [ -f "$FILE" ];  then
    docker compose up -d
	wait
	if ping -c 1 -t 100 192.168.66.5; then
		docker exec -d gtoauth php artisan schedule:run >> /dev/null 2>&1
	fi
fi