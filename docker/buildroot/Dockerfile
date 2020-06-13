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
ENV PYTHONIOENCODING utf-8
RUN yes | pip3 install --upgrade pip setuptools
RUN yes | pip3 install \
	cryptography \
	requests

# might be needed by some stuff
RUN locale-gen en_US.UTF-8
#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US:en
#ENV LC_ALL en_US.UTF-8

# Buildroot does not want to be built from root
RUN adduser --disabled-password --gecos "" builder
ENV HOME /home/builder
WORKDIR /home/builder
USER builder

RUN echo "I am $(whoami), Docker build shell is $0, available env variables are: \n" && env

CMD ["/bin/bash"]
