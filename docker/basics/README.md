# Docker basics

Notes on basic docker commands so I dont have to check stackoverflow everytime

## Images

### Build an image

`docker build --tag imagename:1.0 .`
- Builds an image
- Tags that image with a repository name and tag
- Use dockerfile in the current directory

### List all images in system

`docker image ls --all`

## Containers

### List all container in system

`docker container ls --all`

### Run a container

`docker run --name test -it ubuntu`
- Start a new container based on `ubuntu:latest` image and give it a name `test`
- `-t` allocate pseudo-tty so we get an interactive shell
- `-1` keep stdin open even if not attached

### Remove all stopped container

`docker container prune -f`
- Warning: will not ask for confirmation!
