
VAR_FILE=variables.env
include $(VAR_FILE)

.SILENT:
.PHONY: help

# Based on https://gist.github.com/prwhite/8168133#comment-1313022

## This help screen
help:
	printf "Available targets\n\n"
	awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-30s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Start all components
start:
	@echo "-- Start all components --"
	docker-compose up -d

## Stop all components
stop:
	@echo "-- Stop all components --"
	@docker-compose down

## Create datasources (proxy) in grafana and load Dashboards (grafana-create-source-proxy grafana-load-dashboards)
init: grafana-create-source-proxy grafana-load-dashboards

## Create datasource in proxy mode in Grafana
grafana-create-source-proxy:
	@echo "-- Create Datasource in Grafana 1/2"
	@curl 'http://admin:admin@localhost:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"influxdb","type":"influxdb","url":"http://influxdb:8086","access":"proxy","isDefault":false,"database":"aos"}'
	@echo "\n-- Create Datasource in Grafana 2/2"
	@curl 'http://admin:admin@localhost:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"prometheus","type":"prometheus","url":"http://prometheus:9090","access":"proxy","isDefault":true}'

## Create datasource in direct mode in Grafana (use that is grafana cannot access the data)
grafana-create-source-direct:
	@echo "-- Cleanup Datasources in Grafana"
	@curl 'http://admin:admin@localhost:3000/api/datasources/1' -X DELETE -H 'Content-Type: application/json' -H 'Accept: application/json'
	@curl 'http://admin:admin@localhost:3000/api/datasources/2' -X DELETE -H 'Content-Type: application/json' -H 'Accept: application/json'
	@echo "\n-- Create Datasource in Grafana 1/2"
	@curl 'http://admin:admin@localhost:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"influxdb","type":"influxdb","url":"http://$(LOCAL_IP):8086","access":"direct","isDefault":false,"database":"aos"}'
	@echo "\n-- Create Datasource in Grafana 2/2"
	@curl 'http://admin:admin@localhost:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"prometheus","type":"prometheus","url":"http://$(LOCAL_IP):9090","access":"direct","isDefault":true}'

## Load/Reload the Dashboards in Grafana
grafana-load-dashboards:
	@echo "-- Load Dashboard in Grafana 1/2"
	@curl 'http://admin:admin@localhost:3000/api/dashboards/db' -X POST -H "Content-Type: application/json" --data-binary @dashboards/apstra_aos_blueprint.json
	@echo "\n-- Load Dashboard in Grafana 2/2"
	@curl 'http://admin:admin@localhost:3000/api/dashboards/db' -X POST -H "Content-Type: application/json" --data-binary @dashboards/apstra_aos_device.json

## Stop all components, Update all images, Restart all components, Reload the Dashboards (stop update-docker start grafana-load-dashboards)
update: stop update-docker start grafana-load-dashboards

## Update Docker Images
update-docker:
	@echo "-- Download Latest Images from Docker Hub --"
	@docker-compose pull --ignore-pull-failures

## Delete Grafana information and delete current streaming session on AOS (clean-docker clean-aos)
clean: clean-docker # clean-aos

## Delete Grafana information
clean-docker:
	@echo "-- Delete all Data in Grafana (Grafana must be stopped) --"
	docker volume rm aosomstreaming_grafana_data_2
#
# ## Delete current streaming session on AOS
# clean-aos:
# 	@export $(shell cat variables.env | xargs)
# 	@echo "Delete all streaming session on the server (AOS server must be reacheable)"
# 	ansible-playbook -i tools/hosts.ini tools/pb.streaming_delete.yaml
