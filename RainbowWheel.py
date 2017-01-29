self.show = True
while True:
    if not self.show: break
    for j in range(256*5):
        if not self.show: break
        for i in range(led_object.led_count):
            if not self.show: break
            led_object.strip.setPixelColor(i, self.wheel(((i * 256 / led_object.led_count) + j) & 255))
        led_object.strip.show()
        time.sleep(20/1000.0)
