#!/bin/bash
FILE=docker-compose.yml

gtoauth_uno() {
	docker exec -ti gtoauth php artisan key:generate &&
	docker exec -ti gtoauth php artisan migrate:fresh --seed
}

gtoauth_dos() {
	docker exec -ti gtoauth php artisan passport:keys 
	docker exec -ti gtoauth php artisan passport:client --password --no-interaction --name="gtareas"
	docker exec -ti gtoauth php artisan passport:client --personal --no-interaction --name="gtareas"
}

gtapi_uno() {
	docker exec -ti gtapi php artisan key:generate &&
	docker exec -ti gtapi php artisan migrate --seed
}

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
		if [ ! -f gtareas-oauth/.env ]; then
			echo Cambiando a directorio gtareas-oauth
			cd gtareas-oauth
			echo Creando .env
			cp .env.example .env
			echo Actualizando composer
			composer update
			echo Cambiando a directorio raíz
			cd ..
			echo Ejecutando funciones
			gtoauth_uno &&
			gtoauth_dos
		else
			gtoauth_dos
		fi
		docker exec -d gtoauth php artisan schedule:run >> /dev/null 2>&1
	fi

	if ping -c 1 -t 100 192.168.66.6; then
		if [ ! -f gtareas-api/.env ]; then
			echo Cambiando a directorio gtareas-api
			cd gtareas-api
			echo Creando .env
			cp .env.example .env
			echo Actualizando composer
			composer update
			echo Cambiando a directorio raíz
			cd ..
			echo Ejecutando funciones
			gtapi_uno
		fi
	fi
fi
