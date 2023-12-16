---
title: "Raspberry Pi video switcher"
date: 2021-03-18T22:59:22Z
draft: false
---
# Switching a looped video to another video when a GPIO pin is pushed

Assuming we have two videos, vid1 and vid2. We want to loop file1 and then when the GPIO button is pushed, we play vid2 to completion, then switch back to vid1. Here is some code to do that.

```
#!/usr/bin/python3
from gpiozero import LED, Button
from time import sleep
from datetime import datetime
from subprocess import Popen
from signal import pause
from os import system

import os
button1 = Button(10)
vid1="home.mp4"
vid2="ssh.mp4"
os.system('killall omxplayer.bin')

def play_vid1():
    print ("Play looping default video")
    os.system('killall omxplayer.bin')
    omxc = Popen(['omxplayer', '-b', vid1, '--loop'])

def play_vid2():
    print ("Play standalone video")
    os.system('killall omxplayer.bin')
    omxc = Popen(['omxplayer', '-b', vid2])
    omxc.wait()
    # Belt and braces, kill this with fire
    os.system('killall omxplayer.bin')
    print ("Finished standalone video")

while True:
    play_vid1()
    button1.wait_for_press() 
    play_vid2()
```
