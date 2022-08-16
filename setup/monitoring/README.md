# Monitoring Setup 

Current setup looks like:

Agents -> Riemann -> go-carbon -> Grafana

As agent we are use rieman-tools and [liberty-monitoring](https://github.com/nezavisimost/liberty-monitoring)

We have public available [dashboard](https://m.fuckrkn1.org/d/fX0pLFiVz/fuckrkn1-dashboard?orgId=1)


## Service Map 

### Agents

Currently we have 2 agents which sends metrics: riemann-health and liberty-monitoring


## rieman-health

Riemann-health are part of [riemann-tools](https://github.com/riemann/riemann-tools/blob/main/bin/riemann-health)

Sends: cpu, load, memory, disk metrics

Installing with gem - ruby required.

Currently tunning in tmux, ideally shoud work via systemd unit.

Btw, it's temp solution and would be replaced with own implementation of metrics agent. 

## liberty-monitoring

[Inhouse](https://github.com/nezavisimost/liberty-monitoring) solution written in Clojure. Build locally and supposed to be metrics sender, but currently also grabbing metrics as work-around. 

Currently tunning in tmux, ideally shoud work via systemd unit.

Ideally need to configure CI/CD pipeline and packaging.

Connected devices metrics currently is a script are running in crontab (ugly ugly solution but works >_>)

```
# Check amount of connections
* * * * * /root/monitoring/connects.sh

# cat /root/monitoring/connects.sh
#!/bin/bash

/usr/bin/echo "{:time $(date '+%s') :metric $(/usr/local/sbin/ipsec show | /usr/bin/wc -l)}" > /root/monitoring/connects &2>1

```


## Riemann https://riemann.io 

You can look at riemann as a service which rules metrics. 
Currently just sends all metrics to go-carbon storage. But in future the configuration would be more more complicated. 

The configuration is pure Clojure language which means we have infinitely flexible rules/aggregation for different metrics. 

Unfortunatelly last release is very old, so I've built it from source code, would be nice to automate and package it. 

- Runs with systemd unit file
- Home dir - /home/monitoring 
- User - monitoring
- Config file - [/home/monitoring/riemann.config](./riemann/riemann.config)



### go-carbon https://github.com/go-graphite/go-carbon

The service are for collecting metrics. It's just a fork of graphite originally written in Python (which means fucking slow)

- Config dir - /etc/carbon
- User - monitoring
- Runs with systemd unit
- built manually 

3 config files: 
- [carbon.conf](./carbon/carbon.conf)  
- [storage-aggregation.conf](./carbon/storage-aggregation.conf)  
- [storage-schemas.conf](./carbon/storage-schemas.conf)


## carbonapi https://github.com/go-graphite/carbonapi

I have not a fucking clue why the carbon web-server itself is not good enough, but for getting metrics in Grafana we need the API server which provides HTTP API for getting metrics from carbon backends (which works as HTTP API as well) (insane)

- Config dir - /etc/carbon
- User - monitoring
- Runs with systemd unit
- installed from deb package downloaded manually ._. 

4 config files:
- [carbonapi.yaml](./carbonapi/carbonapi.yaml)
- [graphTemplates.yaml](./carbonapi/graphTemplates.yaml)
- [graphiteWeb.yaml](./carbonapi/graphiteWeb.yaml)
- [timeShift.yaml](./carbonapi/timeShift.yaml)


## Grafana 

Grafana is a great tool to aggregate and draw any metrics from different datasources. We have virtual host in nginx as reverse-proxy and ssl-termination. 

- Installed as deb package downloaded manually.
- Runs with systemd unit

Currently we have small amount of graphs and I want to get more rich dashboard.









