"""
NeoPixel brightness proximity example. Increases the brightness of the NeoPixels as you move closer
to the proximity sensor.
"""
import time
import board
import neopixel
import random
import touchio
from adafruit_apds9960.apds9960 import APDS9960

timinglimit = 1000


apds = APDS9960(board.I2C())
pixels = neopixel.NeoPixel(board.NEOPIXEL, 2, brightness = 0.05)
touch1 = touchio.TouchIn(board.TOUCH1)
touch2 = touchio.TouchIn(board.TOUCH2)

apds.enable_proximity = True

pixels.fill(0x00FF00)


while True:
    if touch1.value:
        failed = False
        pixels.fill(0x0000FF)
        print("b")
        for i in range(timinglimit):
            if apds.proximity == 0:
                failed = True
                pixels.fill(0xFF0000)
                time.sleep(1)
                break
            print(apds.proximity)
        if failed:
            print("f")
        else:
            print("e")
        pixels.fill(0x00FF00)
