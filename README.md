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

Make a copy of the file `variables.default` named `variables.env` and update the following information in `variables.env` to match your environment.
```
AOS_SERVER=192.168.59.250
LOCAL_IP=192.168.59.1
```

> LOCAL_IP is the external IP where this project is running, this IP must be accessible from the AOS server

> **!! The behavior of the project has changed since June 2017, previously it was not required to copy the variable file.**

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

### Check if all containers are running properly

If there is an issue it's possible that a container might stop immediately after boot up. First things to check if to make sure all containers are running.  

By default, 5 containers are created, you can check if they are running with `docker ps`.
The names of the containers are usually:
- aosomstreaming_telegraf-influx_1
- Creating aosomstreaming_influxdb_1
- Creating aosomstreaming_telegraf-prom_1
- Creating aosomstreaming_prometheus_1
- Creating aosomstreaming_grafana_1

### Check the logs of a container

If a container is not running you'll need to access its logs to get more information about the issue
Docker provide a command to directly access the log of a specific container.
```
docker logs <container name or id>
```

If the container is running you can keep the logs flowing with the option `-f`
```
docker logs -f <container name or id>
```

### Check if Telegraf is receiving information from AOS

The container named `aosomstreaming_telegraf-prom_1` is usually a good place to start to make sure
that data is flowing properly.

Here is a normal logs output for initialization phase of the container `telegraf-prom`

At bootup this container will:
1 Open a session to AOS
2 Collect information about the existing blueprint and devices
3 Configure AOS to Stream Data to telegraf
4 Collect incoming Data
```
➜  aosom-streaming git:(perfmon-generic) ✗ docker logs -f aosomstreaming_telegraf-prom_1
2017/06/05 23:32:57 I! Using config file: /etc/telegraf/telegraf.conf
2017-06-05T23:32:57Z D! Attempting connection to output: prometheus_client
2017-06-05T23:32:57Z D! Successfully connected to output: prometheus_client
2017-06-05T23:32:57Z I! Starting Telegraf (version 95ebebc)
2017-06-05T23:32:57Z I! Loaded outputs: prometheus_client
2017-06-05T23:32:57Z I! Loaded inputs: inputs.aos
2017-06-05T23:32:57Z I! Tags enabled: host=57bb6f18d635
2017-06-05T23:32:57Z I! Agent Config: Interval:10s, Quiet:false, Hostname:"57bb6f18d635", Flush Interval:5s
2017-06-05T23:32:57Z D! Starting input:aos, will connect to AOS server 172.20.80.3:443
2017-06-05T23:32:57Z I! Session to AOS server Opened on https://172.20.80.3:443
2017-06-05T23:32:58Z I! Id: 525400F23A98 - normal 9e141fa8-752d-41c4-beea-d44706275658 | leaf
2017-06-05T23:32:58Z I! Id: 525400BDA0F8 - normal 9e141fa8-752d-41c4-beea-d44706275658 | spine
2017-06-05T23:32:58Z I! Id: 525400EBBD32 - normal 9e141fa8-752d-41c4-beea-d44706275658 | leaf
2017-06-05T23:32:58Z I! Id: 525400B64A34 - normal 9e141fa8-752d-41c4-beea-d44706275658 | spine
2017-06-05T23:32:58Z I! Id: 5254007F858F - normal
2017-06-05T23:32:58Z I! Id: 5254005FEA8D - normal 9e141fa8-752d-41c4-beea-d44706275658 | leaf
2017-06-05T23:32:58Z I! Id: 525400DCC172 - normal 9e141fa8-752d-41c4-beea-d44706275658 | spine
2017-06-05T23:32:58Z I! Id: 525400A351EC - normal
2017-06-05T23:32:58Z I! Id: 525400B79224 - normal
2017-06-05T23:32:58Z I! Id: 5254007C04A5 - normal
2017-06-05T23:32:58Z I! Id: 525400B8CF02 - normal
2017-06-05T23:32:58Z I! Id: 525400BD28D3 - normal 9e141fa8-752d-41c4-beea-d44706275658 | spine
2017-06-05T23:32:58Z I! Id: 52540046A0D1 - normal 9e141fa8-752d-41c4-beea-d44706275658 | leaf
2017-06-05T23:32:58Z I! Listening on port 6666
2017-06-05T23:32:58Z I! Streaming of perfmon configured to 10.0.7.157:6666
2017-06-05T23:32:58Z I! Streaming of alerts configured to 10.0.7.157:6666
2017-06-05T23:32:58Z D! New TCP Session Opened ..
2017-06-05T23:32:58Z D! New TCP Session Opened ..
2017-06-05T23:33:02Z D! New TCP Session Opened ..
2017-06-05T23:33:03Z D! New TCP Session Opened ..
2017-06-05T23:33:05Z D! Output [prometheus_client] buffer fullness: 80 / 10000 metrics.
2017-06-05T23:33:05Z D! Output [prometheus_client] wrote batch of 80 metrics in 28.27834ms
2017-06-05T23:33:10Z D! Output [prometheus_client] buffer fullness: 160 / 10000 metrics.
2017-06-05T23:33:10Z D! Output [prometheus_client] wrote batch of 160 metrics in 50.753204ms
2017-06-05T23:33:15Z D! Output [prometheus_client] buffer fullness: 227 / 10000 metrics.
2017-06-05T23:33:15Z D! Output [prometheus_client] wrote batch of 227 metrics in 58.837438ms
2017-06-05T23:33:20Z D! Output [prometheus_client] buffer fullness: 80 / 10000 metrics.
2017-06-05T23:33:20Z D! Output [prometheus_client] wrote batch of 80 metrics in 23.348851ms
2017-06-05T23:33:25Z D! Output [prometheus_client] buffer fullness: 144 / 10000 metrics.
2017-06-05T23:33:25Z D! Output [prometheus_client] wrote batch of 144 metrics in 20.794011ms
2017-06-05T23:33:28Z D! Finished to Refresh Data, will sleep for 30 sec
```
