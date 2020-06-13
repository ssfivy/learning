# Docker basics

Notes on basic docker commands so I dont have to check stackoverflow everytime

## Run a container

`docker run --name test -it ubuntu`
- Start a new container based on `ubuntu:latest` image and give it a name `test`
- `-t` allocate pseudo-tty so we get an interactive shell
- `-1` keep stdin open even if not attached
