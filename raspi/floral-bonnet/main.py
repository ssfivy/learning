#!/usr/bin/env python3

# standard python modules
import sys

# thirdparty modules
import adafruit_ssd1306
import board
import busio
import digitalio
from PIL import Image, ImageDraw, ImageFont


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

    # Create blank image for drawing.
    # Make sure to create image with mode '1' for 1-bit color.
    image = Image.new("1", (oled.width, oled.height))

    # Get drawing object to draw on image.
    draw = ImageDraw.Draw(image)

    # Draw a white background
    draw.rectangle((0, 0, oled.width, oled.height), outline=255, fill=255)

    # Draw a smaller inner rectangle
    BORDER = 1
    draw.rectangle(
        (BORDER, BORDER, oled.width - BORDER - 1, oled.height - BORDER - 1),
        outline=0,
        fill=0,
    )

    # Load default font.
    font = ImageFont.load_default()

    # Draw Some Text
    text = "G'day mate"
    (font_width, font_height) = font.getsize(text)
    draw.text(
        (oled.width // 2 - font_width // 2, oled.height // 2 - font_height // 2),
        text,
        font=font,
        fill=255,
    )

    # Display image
    oled.image(image)
    oled.show()


setup_display()
