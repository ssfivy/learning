
# Raspi floral bonnet playing around

Developed on the raspberry pi floral bonnet (distributed at LCA 2019)

I didn't attend the sessions and there doesn't seem to be much documentation on this hardware.
so I've been looking at DavidAntliff/pi-floral for how to get started.
Also a lot of adafruit tutorials, since the parts looks like a lot fo adafruit stuff.

Schematic is here: https://github.com/unreproducible/bonnet_floral


This is a lot more fun than I expected!


## Display

Tutorial: https://learn.adafruit.com/monochrome-oled-breakouts/python-usage-2
The floral bonnet uses SPI to connect to the display. 128 x 64 pixels.


DavidAntliff's code seems to use the older adafruit library described here: https://learn.adafruit.com/ssd1306-oled-displays-with-raspberry-pi-and-beaglebone-black/usage

## BME280 Temperature, Humidity, Barometric sensor

Adafruit's library works straightforward again, for the most part.
See guide here: https://learn.adafruit.com/adafruit-bme280-humidity-barometric-pressure-temperature-sensor-breakout/python-circuitpython-test
Note the device in floral bonnet is on I2c address 0x76, adafruit library defaults to 0x77 so need to set that.

The temperature values seem wrong out of the box.
It's about 4C higher compared to my (uncalibrated) extech ex330 thermocoulple.
Need to figure out why.
Perhaps the board design causes heat from other components to conduct to the sensor through the ground lines?
Have seen other people claiming self-heating problems as well.
The internet seems to be full of complaints about this sensor.

## TSL2561 Light sensor

Adafruit library just works: https://learn.adafruit.com/tsl2561/python-circuitpython

## Pushbutton & RGB LED

Pretty trivial, any guide should work e.g. : https://www.digikey.com/en/maker/projects/raspberry-pi-pushbutton-switch-for-beginners/62f7e57df92f4d69bf1e44d7f090651b
Button is active low.

## Running
Added systemd service file so it starts up automatically without needing any network/ssh or the like.
(the time will be gibberish without network tho)

## A better temperature sensor
Since the temp sensor in BME280 is blatantly false (sensed: 26C Weather: 16C) I want to try other sensors.

I have an ancient DS1820 but no pullup resistor :(
Once I got a pullup I will give it a try.
The default 1wire pin in raspi is used by the button, so we need to use another pin.
Some promising guides:
- https://learn.adafruit.com/adafruits-raspberry-pi-lesson-11-ds18b20-temperature-sensing/hardware
- https://raspberrypi.stackexchange.com/questions/4844/how-to-change-the-pin-used-for-the-1-wire-bus
- https://pinout.xyz/pinout/1_wire#
