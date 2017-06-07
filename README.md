# aosom-streaming

The Aosom Streaming project provide a packaged solution to collect and visualize
telemetry streaming information coming from an AOS Server.

The solution includes:
- A graphical Interface based on *Grafana* (port 3000)
- 2 Databases:
  - *Prometheus* for Counters and Alerts (port 9090)
  - *Influxdb* for Events (port 8086)
- 2 Collectors, one for each database based on *Telegraf*.

# Requirements

You need to have `docker` and `docker-compose` installed on your system to use this project.

> This project has been tested on AOS version 1.2

# Getting Started
### Configure

Update the following information in `variables.env` to match your environment.
```
AOS_SERVER=192.168.59.250
LOCAL_IP=192.168.59.1
```

> LOCAL_IP is the external IP where this project is running, this IP must be accessible from the AOS server

### Install the Apstra/telegraf container

If you are inside Apstra's network, make sure you have added the Apstra docker repo as an insecure registry:

```
# cat /etc/docker/daemon.json
{ "insecure-registries":["10.1.2.21:5000"] }
```

If you are outside, you need to manually install the docker container for telegraf

Download the file here:https://drive.google.com/open?id=0B-vHD1Q9n4AqLVFrbWFfOUt4N0k

Install the image
```
docker load -i docker-apstra-telegraf-v1.tar
```
# User Guide

### Start All Components

To start all components, you can execute the command:
```
make start
```

### Initialize Grafana (one time)

After the first boot, you need to initialize Grafana to:
- Configure Datasource
- Upload Dashboards

```
make init
```

### Stop All Components

```
make stop
```
> By default, Grafana configuration will be saved but all data in the database will be lost on stop


### Reset the project

At any time, you can reset the project but running the command `clean`.

```
make clean
```
> All components must be stopped before cleaning-up
> The next time you start the project you'll have to do a `init` again.

### other available options for MAKE
```
Available targets

help                           This help screen
start                          Start all components
stop                           Stop all components
init                           Create datasources (proxy) in grafana and load Dashboards (grafana-create-source-proxy grafana-load-dashboards)
grafana-create-source-proxy    Create datasource in proxy mode in Grafana
grafana-create-source-direct   Create datasource in direct mode in Grafana (use that is grafana cannot access the data)
grafana-load-dashboards        Load/Reload the Dashboards in Grafana
update                         Stop all components, Update all images, Restart all components, Reload the Dashboards (stop update-docker start grafana-load-dashboards)
update-docker                  Update Docker Images
clean                          Delete Grafana information and delete current streaming session on AOS (clean-docker clean-aos)
clean-docker                   Delete Grafana information
clean-aos                      Delete current streaming session on AOS
```

# Troubleshooting

 TODO
