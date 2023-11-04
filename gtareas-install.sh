#!/bin/bash
echo "------------------------------------------------------"
echo "                  GESTOR DE TAREAS                    "
echo "------------------------------------------------------"

if [ ! -d gtareas-api ]; then
	git clone git@github.com:mflo80/gtareas-api.git
fi

if [ ! -d gtareas-db ]; then
	mkdir gtareas-db
fi

if [ ! -d gtareas-frontend ]; then
	git clone git@github.com:mflo80/gtareas-frontend.git
fi

if [ ! -d gtareas-login ]; then
	git clone git@github.com:mflo80/gtareas-login.git
fi

if [ ! -d gtareas-oauth ]; then
	git clone git@github.com:mflo80/gtareas-oauth.git
fi

echo "------------------------------------------------------"
echo " SE HA DESCARGADO EL PROYECTO GESTOR DE TAREAS, PARA  " 
echo " INICIAR EL MISMO, EJECUTE EL SCRIPT gtareas-run.sh   "
echo "------------------------------------------------------"
