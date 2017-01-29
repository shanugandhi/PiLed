self.show = True
while True:
    if not self.show: break
    color = [255,0,0]
    for decColor in range(3):
        if not self.show: break
        incColor = 0 if decColor == 2 else decColor+1
        for i in range(255):
            if not self.show: break
            color[decColor] -= 1
            color[incColor] += 1
            for l in range(led_object.led_count):
                led_object.strip.setPixelColor(l, Color(color[0],color[1],color[2]))
            led_object.strip.show()
            time.sleep(100/1000.0)
