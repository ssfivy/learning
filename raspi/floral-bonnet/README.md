
# Raspi floral bonnet playing around

Developed on the raspberry pi floral bonnet (distributed at LCA 2019)

I didn't attend the sessions and there doesn't seem to be much documentation on this hardware.
so I've been looking at DavidAntliff/pi-floral for how to get started.
Also a lot of adafruit tutorials, since the parts looks like a lot fo adafruit stuff.

Schematic is here: https://github.com/unreproducible/bonnet_floral

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


## TSL2561 Light sensor

TODO

## Pushbutton & RGB LED

TODO
