# tcp-http-tunnel

Experimenting with tunneling data through haproxy

## Why?
- You have PCs/servers/embedded devices in home/some other location.
- You want to monitor these using production-grade monitoring tools like Grafana.
- You need to blast metrics from those machines to your monitoring server through The Internet.
- You don't want to expose metrics/logs when the data transits through The Internet.
- You just want to deal with security settings once rather than configure every dang monitoring daemon separately.
- You want to put the connection through a HTTPS proxy for whatever reason and realised tools that commonly listen to `collectd` and `fluentbit` uses TCP+TLS which a HTTP proxy dont like.
    - This may or may not be possible.
- Also I wanna give haproxy a try.

## Overview
```
+-----------------------------------------------------------------------------------+
|                                                                                   |
|   Experimental VM                                                                 |
|                                   docker compose                                  |
|            +----------------------------------------------------------+           |
|                                                                                   |
|            +------------------------+        +------------------------+           |
|            | docker: haproxy client |        | docker: haproxy server |           |
|            |                        |        |                        |           |
|            |                        | https  |                        |           |
|            |                        |        |                        |           |
|  netcat+-->+                        +------->+                        +-->netcat  |
|            +------+-----------------+        +---------------+--------+           |
|                   ^                                          ^                    |
|                   |                                          |                    |
|            +------+----+     +---------------------+   +-----+------+             |
|            |           |     |                     |   |            |             |
|            |keys+certs +<----+  cert setup script  +-->+  keys+certs|             |
|            +-----------+     |                     |   +------------+             |
|                              +---------------------+                              |
|                                                                                   |
+-----------------------------------------------------------------------------------+
```

## References

- https://github.com/graphite-project/carbon/issues/91
- https://bearstech.com/societe/blog/authenticate-everything-with-ssl/
- https://calomel.org/haproxy_tunnel_ssh_through_https.html
