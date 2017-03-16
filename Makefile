
VAR_FILE=variables.env
include $(VAR_FILE)

start:
	docker-compose up -d

stop:
	docker-compose down

init: grafana-create-source-proxy grafana-load-dashboards

grafana-create-source-proxy:
	@echo "Create Datasource in Grafana 1/2"
	@curl 'http://admin:admin@localhost:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"influxdb","type":"influxdb","url":"http://influxdb:8086","access":"proxy","isDefault":false,"database":"aos"}'
	@echo "\nCreate Datasource in Grafana 2/2"
	@curl 'http://admin:admin@localhost:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"prometheus","type":"prometheus","url":"http://prometheus:9090","access":"proxy","isDefault":true}'

grafana-create-source-direct:
	@echo "Cleanup Datasources in Grafana"
	@curl 'http://admin:admin@localhost:3000/api/datasources/1' -X DELETE -H 'Content-Type: application/json' -H 'Accept: application/json'
	@curl 'http://admin:admin@localhost:3000/api/datasources/2' -X DELETE -H 'Content-Type: application/json' -H 'Accept: application/json'
	@echo "\nCreate Datasource in Grafana 1/2"
	@curl 'http://admin:admin@localhost:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"influxdb","type":"influxdb","url":"http://$(LOCAL_IP):8086","access":"direct","isDefault":false,"database":"aos"}'
	@echo "\nCreate Datasource in Grafana 2/2"
	@curl 'http://admin:admin@localhost:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"prometheus","type":"prometheus","url":"http://$(LOCAL_IP):9090","access":"direct","isDefault":true}'

grafana-load-dashboards:
	@echo "Load Dashboard in Grafana 1/2"
	@curl 'http://admin:admin@localhost:3000/api/dashboards/db' -X POST -H "Content-Type: application/json" --data-binary @dashboards/apstra_aos_blueprint.json
	@echo "\nLoad Dashboard in Grafana 2/2"
	@curl 'http://admin:admin@localhost:3000/api/dashboards/db' -X POST -H "Content-Type: application/json" --data-binary @dashboards/apstra_aos_device.json

update:
	@echo "Download Latest Images from Docker Hub"
	@docker-compose pull --ignore-pull-failures

clean: clean-docker clean-aos

clean-docker:
	@echo "Delete all Data in Grafana (Grafana must be stopped)"
	docker volume rm aosomstreaming_grafana_data_2

clean-aos:
	@export $(shell cat variables.env | xargs)
	@echo "Delete all streaming session on the server (AOS server must be reacheable)"
	ansible-playbook -i tools/hosts.ini tools/pb.streaming_delete.yaml
