# DNS experimentation with Hurricane Electric

No automated "do everything" shell scripts are available since this is somebody else's infrastructure.

Hurricane Electric provides a free no-frills DNS service which supports dynamic DNS and is supported by various tools, so it is good for experiments. For serious business use you may or may not want someone else with an explicit support contract.

## TTL Values
When experimenting with changes, use very low TTL values e.g. 300 seconds,
and do this ideally 24 hour in advance of first experiments.
This helps with preventing stale data being cached by other dns servers on the internet.
When you have settled on a final configuration you can revert to a normal set of TTL values e.g. 86400 secs.

## Delegating nameservers

If you have a domain `example.com` registered by the company `registrar.com`,
you can go to the registrar and use their DNS server offering to store records.
For example, you can add an A record for `www.example.com` which will point to some IP address `a.b.c.d`.
This info is stored in the DNS hosting facility of the registrar e.g. `ns1.registrar.com`,
but is completely separate service from the domain name purchase itself.
So you can purchase a domain name from company A and only tell them that
you want to use some other set of nameservers, say `ns1.he.net`

However, you can also add an NS record for a subdomain `home.example.com` pointing to the other nameservers.
This means all queries for that subdomain will be handled by that nameserver, and you need to configure things there.

Note that through my experimentation, even if you delegate the NS record for a subdomain
the upper-level nameserver will still answer queries about the subdomain that it knows.
So if you set different A records for `home.example.com` in both `ns1.registrar.com` and `ns1.he.net`,
the A record for that subdomain will be answered by `ns1.registrar.com` and not `ns1.he.net`.
I am not sure if this is correct behavior or not - it is simply my observation.

## Dynamic DNS

Hurricane Electric allows dynamic DNS which is trivial to update using curl:

```
curl "https://dyn.dns.he.net/nic/update" -d "hostname=dyn.example.com" -d "password=password" -d "myip=192.168.0.1"
curl "https://dyn.dns.he.net/nic/update" -d "hostname=dyn.example.com" -d "password=password" -d "myip=2001:db8:beef:cafe::1"
```

No exhaustive docs, but there's enough examples here to get started: `https://dns.he.net/`
Note the password is not your web login password, but something that is set/generated for each subdomain through the web interface.

To start with this, you need to set up HE as a nameserver for a (sub)domain. Delegating a subdomain works fine.
Then add new A record and tick the box to allow dynamic DNS. Then click the DDNS generate key icon and generate a key used for DDNS update.

Note that you do not have to perform this call from the computer that needs the DNS pointed to either.
This opens up some possibilities e.g. using a third machine to perform the queries and update,
or performing updates triggered by CI/CD/other infra monitoring tools.

- [ ] TODO: Try automating this using shell / cron / systemd-timer or the like

## Tools

There are some clients that can update this for you.
I have checked out [lexicon](https://github.com/AnalogJ/lexicon) for now and it seems to work.
Note lexicon he provider works by querying the web api and parsing the resulting web pages,
so it may or may not be the most reliable way of updating things.
You also need to provide your actual login username and password which is less secure than a per-domain key.
