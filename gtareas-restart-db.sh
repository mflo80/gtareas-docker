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
	docker exec -d gtoauth php artisan schedule:run >> /dev/null 2>&1
}

gtapi_uno() {
	docker exec -ti gtapi php artisan key:generate &&
	docker exec -ti gtapi php artisan migrate --seed
}

gtfrontend_uno() {
	docker exec -ti gtfrontend php artisan key:generate
}

echo "------------------------------------------------------"
echo "            INICIANDO GESTOR DE TAREAS                "
echo "------------------------------------------------------"

if ping -c 1 -t 100 192.168.66.1; then
	echo La RED gtnet ya se encuentra creada
else
	docker network create --driver=bridge --subnet=192.168.66.0/24 --gateway=192.168.66.1 gtnet
fi

if [ -f "$FILE" ]; then
	echo "------------------------------------------------------"
	echo "               INICIANDO CONTENEDORES                 "
	echo "------------------------------------------------------"
    	docker compose up -d
	wait
	if ping -c 1 -t 100 192.168.66.5; then
		echo "------------------------------------------------------"
		echo "            CONFIGURANDO GTAREAS-OAUTH                "
		echo "------------------------------------------------------"
		echo Cambiando a directorio gtareas-oauth
		cd gtareas-oauth
		echo Creando .env
		cp -f ".env.example" .env
		echo Ejecutando función uno
		gtoauth_uno
		echo Cambiando a directorio raíz
		cd ..
		echo Ejecutando función dos
		gtoauth_dos
	else
		echo ¡¡¡GTAREAS-OAUTH NO SE ENCUENTRA ACTIVA!!!
	fi

	if ping -c 1 -t 100 192.168.66.6; then
		echo "------------------------------------------------------"
		echo "            CONFIGURANDO GTAREAS-API                  "
		echo "------------------------------------------------------"
		echo Cambiando a directorio gtareas-api
		cd gtareas-api
		echo Creando .env
		cp -f ".env.example" .env
		echo Ejecutando funciones
		gtapi_uno
		echo Cambiando a directorio raíz
		cd ..
	else
		echo ¡¡¡GTAREAS-API NO SE ENCUENTRA ACTIVA!!!
	fi

	if ping -c 1 -t 100 192.168.66.7; then
		echo "------------------------------------------------------"
		echo "            CONFIGURANDO GTAREAS-FRONTEND             "
		echo "------------------------------------------------------"
		echo Cambiando a directorio gtareas-frontend
		cd gtareas-frontend
		echo Creando .env
		cp -f ".env.example" .env
		echo Ejecutando funciones
		gtfrontend_uno
		echo Cambiando a directorio raíz
		cd ..
	else
		echo ¡¡¡GTAREAS-FRONTEND NO SE ENCUENTRA ACTIVA!!!
	fi
fi
echo
docker ps
echo "------------------------------------------------------"
echo " Para probar Gestor de Tareas, en tu PC ingresa a la  "
echo " dirección: $(hostname -I | cut -d' ' -f1):8000       "
echo "------------------------------------------------------"
echo "------------------------------------------------------"
echo "          GRACIAS POR USAR GESTOR DE TAREAS           "
echo "------------------------------------------------------"
