#!/bin/bash
FILE=docker-compose.yml

if ping -c 1 -t 100 192.168.66.1; then
	echo La RED gtnet ya se encuentra creada
else
	docker network create --driver=bridge --subnet=192.168.66.0/24 gtnet
fi

if [ ! -d gtareas-api ]; then
	mkdir gtareas-api
fi

if [ ! -d gtareas-db ]; then
	mkdir gtareas-db
fi

if [ ! -d gtareas-frontend ]; then
	mkdir gtareas-frontend
fi

if [ ! -d gtareas-login ]; then
	mkdir gtareas-login
fi

if [ ! -d gtareas-oauth ]; then
	mkdir gtareas-oauth
fi

if [ -f "$FILE" ]; then
    docker compose up -d
	wait
	if ping -c 1 -t 100 192.168.66.5; then
		docker exec -d gtoauth php artisan schedule:run >> /dev/null 2>&1
	fi
fi
