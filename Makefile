
VAR_FILE=variables.env
include $(VAR_FILE)
GRAFANA_LOGIN=admin
GRAFANA_PASSWORD=aos-aos

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
	@./docker_compose.sh up -d

## Stop all components
stop:
	@echo "-- Stop all components --"
	@./docker_compose.sh down

## Start all components using ECR images to prevent docker pull quota limits
start-ecr:
	@echo "-- Start all components --"
	@./docker_compose.sh -f ecr.docker-compose.yml up -d
	@./api_request.py --url /api/health || echo Grafana failed to start

stop-ecr:
	@echo "-- Start all components --"
	@./docker_compose.sh -f ecr.docker-compose.yml down

## Create datasources (proxy) in grafana and load Dashboards (grafana-create-source-proxy grafana-load-dashboards)
init: grafana-create-source-proxy grafana-load-dashboards

## Create datasource in proxy mode in Grafana
grafana-create-source-proxy:
	@echo "-- Create Datasource in Grafana 1/2"
	@./api_request.py --method POST --url /api/datasources --template influxdb
	@echo "\n-- Create Datasource in Grafana 2/2"
	@./api_request.py --method POST --url /api/datasources --template prometheus

## Create datasource in direct mode in Grafana (use that is grafana cannot access the data)
grafana-create-source-direct:
	@echo "-- Cleanup Datasources in Grafana"
	@./api_request.py --method DELETE --url /api/datasources/1
	@./api_request.py --method DELETE --url /api/datasources/2
	@echo "\n-- Create Datasource in Grafana 1/2"
	@./api_request.py --method POST --url /api/datasources --template influxdb_direct
	@echo "\n-- Create Datasource in Grafana 2/2"
	@./api_request.py --method POST --url /api/datasources --template prometheus_direct

## Load/Reload the Dashboards in Grafana
grafana-load-dashboards:
	@echo "-- Load Dashboard in Grafana 1/2"
	@./api_request.py --url /api/dashboards/db --method POST --template apstra_aos_blueprint
	@echo "\n-- Load Dashboard in Grafana 2/2"
	@./api_request.py --url /api/dashboards/db --method POST --template apstra_aos_device

## Stop all components, Update all images, Restart all components, Reload the Dashboards (stop update-docker start grafana-load-dashboards)
update: stop update-docker start grafana-load-dashboards

## Update Docker Images
update-docker:
	@echo "-- Download Latest Images from Docker Hub --"
	@./docker_compose.sh pull --ignore-pull-failures

## Delete Grafana information and delete current streaming session on AOS (clean-docker clean-aos)
clean: clean-docker # clean-aos

## Delete Grafana information
clean-docker:
	@echo "-- Delete all Data in Grafana (Grafana must be stopped) --"
	docker volume rm -f aosomstreaming_grafana_data_2
#
# ## Delete current streaming session on AOS
# clean-aos:
# 	@export $(shell cat variables.env | xargs)
# 	@echo "Delete all streaming session on the server (AOS server must be reacheable)"
# 	ansible-playbook -i tools/hosts.ini tools/pb.streaming_delete.yaml
