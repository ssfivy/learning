#!/bin/bash

# Experiment: Build firmware for nrf52840 that can act as a bluetooth hci dongle from linux
# Not 100% reproducible

NORDIC_DEVICE=/dev/ttyACM1

cd ~/zephyrproject/
source zephyr/zephyr-env.sh

# Blinky
#west build -b nrf52840_pca10059 zephyr/samples/basic/blinky --pristine

# BLE Beacon
#west build -b nrf52840_pca10059 zephyr/samples/bluetooth/beacon --pristine

# USB HCI
#west build -b nrf52840_pca10059 zephyr/samples/bluetooth/hci_usb --pristine

# UART HCI
west build -b nrf52840_pca10059 zephyr/samples/bluetooth/hci_uart --pristine


# Package with nrfutil
nrfutil pkg generate --hw-version 52 --sd-req=0x00 \
        --application build/zephyr/zephyr.hex \
        --application-version 1 build/blinky.zip

nrfutil dfu usb-serial -pkg build/blinky.zip -p ${NORDIC_DEVICE}

#rm -rf build
