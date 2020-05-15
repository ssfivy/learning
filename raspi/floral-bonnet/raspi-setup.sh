#/bin/bash

# Record of my CLI operations. Script may or may not work if run as-is

# manual part
# using raspi-config:
# set up wifi / network connectivity
# enable ssh
# enable SPI and I2c

# Automated part of raspi setup from here onwards
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y \
    rng-tools haveged \
    python3-pil
    # pip3 install can fail if not enough entropy so we need rng-tools and haveged
    # python3-pil will install pillow library, which has some other system dependencies so we should not install it from pip

# my goodness pip3 on raspi zero w is uber slow
sudo pip3 install --upgrade setuptools pip
sudo pip3 install RPI.GPIO adafruit-blinka adafruit-circuitpython-ssd1306


#EOF
