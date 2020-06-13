# Docker : Buildroot
# Docker image with prerequisites installed to compile using Buildroot (or most C-based codebase).

FROM ubuntu:focal

#USER root
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && \
	apt-get install -y \
	bc \
	build-essential \
	cpio \
	curl \
	file \
	git \
	locales \
	libncurses5-dev \
	ninja-build \
	python3-pip \
	rsync \
	texinfo \
	time \
	unzip \
	wget \
	zip

# Install python dependencies (for reference)
RUN yes | pip3 install --upgrade pip setuptools
RUN yes | pip3 install \
	cryptography \
	requests

RUN echo "Docker build shell is $0, available env variables are: \n" && env

# might be needed by some stuff
RUN locale-gen en_US.UTF-8
#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US:en
#ENV LC_ALL en_US.UTF-8

CMD ["/bin/bash"]
