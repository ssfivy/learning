# Issue a Let's encrypt certificate using DNS API

Use [acme.sh](https://github.com/acmesh-official/acme.sh)
to generate cert even for machines not exposed to internet.

This is possible since letsencrypt can validate a domain by checking its dns record,
proving that you do control the domain.

acme.sh is simpler to experiment with vs creating a full setup with certbot.

## Prerequisites

- `acme.sh` installed.
- A hostname
- A DNS service for that hostname (or at least a subdomain)
- DNS service must be supported by acme.sh

## Overall how-to
1. Decide on the subdomain you want
2. (may be unneeded) Set up the DNS service to have an A record for the subdomain
3. Set up your DNS service login credentials
4. use acme.sh in dns mode to register letsencrypt using DNS validation.
5. Get the certificate files and use it for whatever you need it for.

see the accompanying shell script for details.

## TODO
- Figure out: Do I need to maintain / backup anything?
- Experiment with alternate DNS provider (tested with Hurricane Electric, which doesnt use tokens, so it needs my actual account credentials which is rather iffy)

## Notes
- LetsEncrypt only issues Domain Validation certs, so you cannot fill data like Organisation Name and the like.
- Is there something I need to do with let's encrypt account management?
- Hurricane Electric API uses your actual login and password, and this is cached in `~/.acme.sh/account.conf` - so protect this file! (it's globally readable - really?)

## References
- The various ways to issue a cert: https://github.com/acmesh-official/acme.sh/wiki/How-to-issue-a-cert
- DNS API docs: https://github.com/acmesh-official/acme.sh/wiki/dnsapi
