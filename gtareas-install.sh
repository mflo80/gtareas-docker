#!/bin/bash
FILE=docker-compose.yml

gtoauth_uno() {
	echo "------------------------------------------------------"
	echo "          GENERANDO KEY PARA GTOAUTH                  "
	echo "------------------------------------------------------"
	docker exec -ti gtoauth php artisan key:generate &&
	echo "------------------------------------------------------"
	echo "            CARGANDO BASE DE DATOS                    "
	echo "------------------------------------------------------"
	docker exec -ti gtoauth php artisan migrate:fresh --seed
}

gtoauth_dos() {
	echo "------------------------------------------------------"
	echo "           GENERANDO PASSPORT KEYS                    "
	echo "------------------------------------------------------"
	docker exec -ti gtoauth php artisan passport:keys
	docker exec -ti gtoauth php artisan passport:client --password --no-interaction --name="gtareas"
	docker exec -ti gtoauth php artisan passport:client --personal --no-interaction --name="gtareas"
	echo "------------------------------------------------------"
	echo "         EJECUTANDO TAREAS PROGRAMADAS                "
	echo "------------------------------------------------------"
	docker exec -d gtoauth php artisan schedule:run >> /dev/null 2>&1
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
	echo "       FINALIZADA CONFIGURACIÓN DE GTOAUTH            "
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
}

gtapi_uno() {
	echo "------------------------------------------------------"
	echo "           GENERANDO KEY PARA GTAPI                   "
	echo "------------------------------------------------------"
	docker exec -ti gtapi php artisan key:generate &&
	echo "------------------------------------------------------"
	echo "            CARGANDO BASE DE DATOS                    "
	echo "------------------------------------------------------"
	docker exec -ti gtapi php artisan migrate --seed
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
	echo "        FINALIZADA CONFIGURACIÓN DE GTAPI             "
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
}

gtfrontend_uno() {
	echo "------------------------------------------------------"
	echo "          GENERANDO KEY PARA GTFRONTEND               "
	echo "------------------------------------------------------"
	docker exec -ti gtfrontend php artisan key:generate
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
	echo "      FINALIZADA CONFIGURACIÓN DE GTFRONTEND          "
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
}

gttest() {
	echo "------------------------------------------------------"
	echo " ///////        GENERANDO UNIT TEST           /////// "
	echo "------------------------------------------------------"
	docker exec -ti gtoauth php artisan test
	docker exec -ti gtapi php artisan test
}

echo "------------------------------------------------------"
echo "            INICIANDO GESTOR DE TAREAS                "
echo "------------------------------------------------------"

echo "------------------------------------------------------"
echo "         VERIFICANDO SI YA EXISTE RED GTNET           "
echo "------------------------------------------------------"

if ping -c 1 -t 100 192.168.66.1; then
	echo La RED gtnet ya se encuentra creada
else
	echo "------------------------------------------------------"
	echo "                CREANDO RED GTNET                     "
	echo "------------------------------------------------------"
	docker network create --driver=bridge --subnet=192.168.66.0/24 --gateway=192.168.66.1 gtnet
fi

echo "------------------------------------------------------"
echo "               CREANDO DIRECTORIOS                    "
echo "------------------------------------------------------"

if [ ! -d gtareas-db ]; then
	mkdir gtareas-db
fi

if [ ! -d gtareas-oauth ]; then
	echo "------------------------------------------------------"
	echo "             INSTALANDO GTAREAS-OAUTH                 "
	echo "------------------------------------------------------"
	git clone https://github.com/mflo80/gtareas-oauth.git
	wait
	echo Cambiando a directorio gtareas-oauth
	cd gtareas-oauth
	echo Actualizando composer
	composer update
	wait
	echo Cambiando a directorio raíz
	cd ..
fi

if [ ! -d gtareas-api ]; then
	echo "------------------------------------------------------"
	echo "             INSTALANDO GTAREAS-API                   "
	echo "------------------------------------------------------"
	git clone https://github.com/mflo80/gtareas-api.git
	wait
	echo Cambiando a directorio gtareas-api
	cd gtareas-api
	echo Actualizando composer
	composer update
	wait
	echo Cambiando a directorio raíz
	cd ..
fi

if [ ! -d gtareas-frontend ]; then
	echo "------------------------------------------------------"
	echo "             INSTALANDO GTAREAS-FRONTEND              "
	echo "------------------------------------------------------"
	git clone https://github.com/mflo80/gtareas-frontend.git
	wait
	echo Cambiando a directorio gtareas-frontend
	cd gtareas-frontend
	echo Actualizando composer
	composer update
	wait
	echo Cambiando a directorio raíz
	cd ..
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
gttest
echo "------------------------------------------------------"
echo "                   TEST FINALIZADO                    "
echo "------------------------------------------------------"
docker ps
echo "------------------------------------------------------"
echo " Para probar Gestor de Tareas, en tu PC ingresa a la  "
echo " dirección: $(hostname -I | cut -d' ' -f1):8000       "
echo "------------------------------------------------------"
echo "------------------------------------------------------"
echo "------------------------------------------------------"
echo "          GRACIAS POR USAR GESTOR DE TAREAS           "
echo "------------------------------------------------------"
echo "------------------------------------------------------"
