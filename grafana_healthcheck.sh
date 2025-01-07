#!/bin/bash

GRAFANA_LOGIN=${GRAFANA_LOGIN:-admin}
GRAFANA_PASSWORD=${GRAFANA_PASSWORD:-aos-aos}

source ./variables.env

function check_grafana () {
    curl -s http://$GRAFANA_LOGIN:$GRAFANA_PASSWORD@localhost:3000/api/search
}

until [ "$(check_grafana)" = '[]' ]
do 
    sleep 1;
done
