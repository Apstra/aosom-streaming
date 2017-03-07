
start:
	docker-compose up -d

stop:
	docker-compose down

init: grafana-create-source grafana-load-dashboards

grafana-create-source:
	@echo "Create Datasource in Grafana 1/2"
	@curl 'http://admin:admin@localhost:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"influxdb","type":"influxdb","url":"http://influxdb:8086","access":"proxy","isDefault":false,"database":"aos"}'
	@echo "\nCreate Datasource in Grafana 2/2"
	@curl 'http://admin:admin@localhost:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"prometheus","type":"prometheus","url":"http://prometheus:9090","access":"proxy","isDefault":true}'

grafana-load-dashboards:
	@echo "Load Dashboard in Grafana 1/2"
	@curl 'http://admin:admin@localhost:3000/api/dashboards/db' -X POST -H "Content-Type: application/json" --data-binary @dashboards/apstra_aos_blueprint.json
	@echo "\nLoad Dashboard in Grafana 2/2"
	@curl 'http://admin:admin@localhost:3000/api/dashboards/db' -X POST -H "Content-Type: application/json" --data-binary @dashboards/apstra_aos_device.json

clean-server:
	@export $(shell cat variables.env | xargs)
	ansible-playbook -i tools/hosts.ini tools/pb.streaming_delete.yaml
