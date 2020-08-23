# Grafana iot-monitor

Two separate monitoring chain:

Plaintext chain:
```
logs -> fluentbit ----internet----> (fluentd?) -> elasticsearch -> kibana

metrics -> collectd ----internet----> graphite -> grafana

```

Secured chain:
```
logs -> fluentbit ----+                         +--> (fluentd?) -> elasticsearch -> kibana --+
                      |                         |                                            |
                      v                         |                                            v
                    haproxy ---internet----> haproxy                                       caddy -> Internet-exposed dashboard
                      ^                         |                                            ^
                      |                         |                                            |
metrics -> collectd --+                         +--> graphite -> grafana --------------------+
```


## TODOs

### Device - Metrics
- [ ] Set up default reusable config for collectd
- [x] Auto-configure collectd device identity if we have multiple devices
- [x] Gather data using collectd

### Device - Logs
- [ ] Set up default reusable config for fluentbit - collection side
- [ ] Set up default reusable config for fluentbit - transmit side

### Internet transmission
see learning/haproxy/tcptunnel project for the experiments
- [ ] Set up default haproxy config - device side
- [ ] Set up default haproxy config - server side
- [ ] Integrate haproxy - device side
- [ ] Integrate haproxy - server side

### Server - Metrics
- [ ] Set up bastion host for configuring server
- [x] Set up docker compose on app server
- [x] Set up graphite using docker-compose
- [x] Set up grafana using docker-compose
- [ ] store / archive graphite data
- [ ] store / archive grafana configs / UI
- [ ] auto-generate grafana dashboard when new device shows up

### Server - logs
- [x] Set up receive config for fluentd
- [x] Set up fluentd using docker-compose
- [x] Connect fluentbit to fluentd (plain TCP)
- elasticsearch?
- kibana?


# Software choice rationale
Everything comes from the data source requirement:
- collectd and fluentbit are tiny, suitable for embedded devices.
- collectd seems better for metric, fluentbit seems better at doing logs.

- fluentd - elasticsearch - kibana seems like a common stack.
- collectd - graphite - grafana seems like another common stack.

- haproxy is there to encrypt data connection in a common way (vs configuring  collectd and fluentbit crypto)
- haproxy is _hopefully_ can tunnel the plain TCP connection through HTTPS so it can go through proxy servers.
