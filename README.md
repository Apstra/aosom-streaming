# aosom-streaming

The Aosom Streaming project provide a packaged solution to collect and visualize
telemetry streaming information coming from an AOS Server.

The solution includes:
- A graphical Interface (port 3000) - Gafana
- 2 Databases:
 - (port 9090) - Prometheus for Alerts and counters
 - (port 8086) - INfluxdb for events
- 2 Collectors, one for each database based on Telegraf.

# Requirement

You need to have `docker` and `docker-compose` installed on your system to use this project.

> This project has been tested on AOS version 1.1.1

# Getting Started

### Configure

Update the following information in `variables.env` to match your environment.
```
AOS_SERVER=172.20.187.3
LOCAL_IP=10.0.7.157
```

> LOCAL_IP is the external IP where this project is running, this IP must be accessible from the AOS server

### (optional) Install the Apstra/telegraf container

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

# Start All Components

To start all components, you can execute the command:
```
make start
```

# Initialize Grafana (one time)

After the first boot, you need to initialize Grafana to:
- Configure Datasource
- Upload Dashboards

```
make init
```

# Stop All Components

```
make stop
```
