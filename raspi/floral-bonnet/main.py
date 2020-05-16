#!/usr/bin/python3 -u


# standard python modules
import datetime
import math
import signal
import sys
import textwrap
import time

# thirdparty modules
import adafruit_bme280
import adafruit_ssd1306
import adafruit_tsl2561
import board
import busio
import digitalio
import RPi.GPIO as GPIO
from PIL import Image, ImageDraw, ImageFont


def setup_i2csensors():
    i2c = busio.I2C(board.SCL, board.SDA)
    bme280 = adafruit_bme280.Adafruit_BME280_I2C(i2c, address=0x76)
    tsl2561 = adafruit_tsl2561.TSL2561(i2c)

    # TODO: Automatically scrape sea level pressure from the weather station at sydney airport
    # http://www.bom.gov.au/products/IDN60801/IDN60801.94767.shtml
    bme280.sea_level_pressure = 1030.2

    bme280._iir_filter = adafruit_bme280.IIR_FILTER_X16
    bme280._overscan_temperature = adafruit_bme280.OVERSCAN_X16
    bme280._overscan_humidity = adafruit_bme280.OVERSCAN_X16
    bme280._overscan_pressure = adafruit_bme280.OVERSCAN_X16

    tsl2561.enabled = True
    time.sleep(1)

    # set high gain mode
    tsl2561.gain = 1
    # set integration time
    tsl2561.integration_time = 1  # 101ms

    return bme280, tsl2561


def measure_dewpoint(bme280):
    #print("\nTemperature: %0.1f C" % bme280.temperature)
    #print("Humidity: %0.1f %%" % bme280.humidity)
    #print("Pressure: %0.1f hPa" % bme280.pressure)
    #print("Altitude = %0.2f meters" % bme280.altitude)

    # Magnus formula to calculate dew point
    b = 17.62
    c = 243.12
    gamma = (b * bme280.temperature / (c + bme280.temperature)) + \
        math.log(bme280.humidity / 100.0)
    dewpoint = (c * gamma) / (b - gamma)
    # print(dewpoint)
    return dewpoint


def setup_display():
    spi = busio.SPI(board.SCK, MOSI=board.MOSI)
    # Reset is on raspi GPIO24 / pin18
    reset_pin = digitalio.DigitalInOut(board.D24)
    # CS is on raspi GPIO8 / pin24
    cs_pin = digitalio.DigitalInOut(board.D8)
    # DC is on raspi GPIO23 / pin16
    dc_pin = digitalio.DigitalInOut(board.D23)

    oled = adafruit_ssd1306.SSD1306_SPI(
        128, 64, spi, dc_pin, reset_pin, cs_pin)

    # Clear display.
    oled.fill(0)
    oled.show()

    return oled


def draw_text(oled, textlines):
    # Create blank image for drawing.
    # Make sure to create image with mode '1' for 1-bit color.
    image = Image.new("1", (oled.width, oled.height))
    # Get drawing object to draw on image.
    draw = ImageDraw.Draw(image)
    """
    # This is to draw a border
    # Draw a white background
    draw.rectangle((0, 0, oled.width, oled.height), outline=255, fill=255)
    # Draw a smaller inner rectangle
    BORDER = 1
    draw.rectangle(
        (BORDER, BORDER, oled.width - BORDER - 1, oled.height - BORDER - 1),
        outline=0,
        fill=0,
    )
    """
    draw.rectangle((0, 0, oled.width, oled.height), outline=0, fill=0)

    # Load default font.
    font = ImageFont.load_default()

    # Draw Some Text
    # TODO: Clean this up
    # draw.text(
    #    (oled.width // 2 - font_width // 2, oled.height // 2 - font_height // 2),
    #    text,
    #    font=font,
    #    fill=255,
    # )
    y_text = 3
    for line in textlines:
        (font_width, font_height) = font.getsize(line)
        draw.text((oled.width // 2 - font_width // 2, y_text),
                  line, font=font, fill=255)
        y_text += font_height

    # Display image
    oled.image(image)
    oled.show()


def init_button(button_gpio):
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(button_gpio, GPIO.IN, pull_up_down=GPIO.PUD_UP)


def button_isPressed(button_gpio):
    # active low
    if GPIO.input(button_gpio) == False:
        return True
    else:
        return False


def init_ledcolor():
    RED_PIN = 22
    GREEN_PIN = 20
    BLUE_PIN = 21
    PWM_FREQ = 256

    GPIO.setmode(GPIO.BCM)
    GPIO.setup(RED_PIN, GPIO.OUT)
    GPIO.setup(GREEN_PIN, GPIO.OUT)
    GPIO.setup(BLUE_PIN, GPIO.OUT)

    rgbled = {}
    rgbled['red'] = GPIO.PWM(RED_PIN, PWM_FREQ)
    rgbled['green'] = GPIO.PWM(GREEN_PIN, PWM_FREQ)
    rgbled['blue'] = GPIO.PWM(BLUE_PIN, PWM_FREQ)

    rgbled['red'].start(0)
    rgbled['green'].start(0)
    rgbled['blue'].start(0)

    return rgbled


def set_ledcolor(rgbled, r, g, b):

    rgbled['red'].ChangeDutyCycle(r)
    rgbled['green'].ChangeDutyCycle(g)
    rgbled['blue'].ChangeDutyCycle(b)


def main_process():
    oled = setup_display()
    bme280, tsl2561 = setup_i2csensors()
    ledcolor = init_ledcolor()

    BUTTON_GPIO = 4
    init_button(BUTTON_GPIO)

    while True:
        textlines = []
        textlines.append("temp:%0.1fC humi:%0.1f%%" %
                         (bme280.temperature, bme280.humidity))
        #textlines.append("Airpressure:%0.1fhPa" % bme280.pressure)
        textlines.append("Alt:%0.2fm Dew:%0.1fC" %
                         (bme280.altitude, measure_dewpoint(bme280)))
        lux = tsl2561.lux
        if lux is None:
            lux = "N/A"
        textlines.append("Prs:%0.1fhPa Lux:%d" % (bme280.pressure, lux))
        textlines.append("Brd:%0.1f IR:%0.1f" % tsl2561.luminosity)
        timestr = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        textlines.append(timestr)

        if button_isPressed(BUTTON_GPIO):
            r = time.time() * 1000 % 60
            g = (r + 20) % 60
            b = (g + 20) % 60
            r /= 4
            g /= 4
            b /= 4
        else:
            r = 0
            g = 0
            b = 0
        set_ledcolor(ledcolor, r, g, b)

        draw_text(oled, textlines)
        print(textlines)
        print('{} {} {}'.format(r, g, b))
        # FIXME: not deterministic! use signal.settimer instead?
        time.sleep(0.5)


main_process()

# EOF
