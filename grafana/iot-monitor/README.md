# Grafana iot-monitor

Example of gathering data using collectd, then using fluentbit to blast it over the internet to a fluentd server.

# TODOs

### Device configs
- [ ] Set up default reusable config for collectd
- [ ] Auto-configure collectd device identity if we have multiple devices
- [x] Gather data using collectd
- [ ] Set up default reusable config for fluentbit - collection side
- [x] Connect collectd to fluentbit
- [ ] Set up default reusable config for fluentbit - transmit side

### Internet configs
- [x] Set up receive config for fluentd
- [ ] Set up fluentd using docker-compose
- [x] Connect fluentbit to fluentd (plain TCP)
- [ ] Set up automated certificate generation for fluentbit+fluentd
- [ ] Connect fluentbit to fluentd (TCP + TLS)
- [ ] Connect fluentbit to fluentd (plain HTTP? Is this possible?)
- [ ] Connect fluentbit to fluentd (HTTPS? Is this possible?)

### Server configs
- [ ] Set up bastion host for configuring server
- [ ] Set up docker compose on app server
- Graphite?
- Grafana?
