+++
title = "PiPoEGUSCA - RaspberryPi Power over Ethernet Garden Ultrasonic Squirter Camera Alarm"
date = "2013-10-15"
showFullContent = false
+++

# PiPoEGUSCA - RaspberryPi Power over Ethernet Garden Ultrasonic Squirter Camera Alarm

## Raspberry Pi Powered Garden Deterrent
Over the summer, we have developed a small project to stop animals from going into a small raised flower bed.  The idea was to use a detector and water pistol to prevent them from spoiling the flower bed. The raised bed was built for a child to learn to garden in.

## Brief
The customer had just had his garden landscaped and wished to stop cats and foxes from leaving tokens of gratitude. It was decided to use a Raspberry Pi. Revision 1 of the project used a PIR detector and failed as the triggering mechanism was too sensitive. It was decided to use a commercial Ultrasonic scarer which has adjustable sensitivity (and sound frequency).

## List of Components:
- Raspberry Pi with 8GB SD Card and Raspbian.
- Raspberry Pi Camera board.
- LM2596 Voltage regulator board 4.5 to 40V input 1.2V to 37 out.: http://www.ebay.co.uk/itm/LM2596-Voltage-Regulator-board-4-5V-to-40V-in-1-2V-to-37V-out-UK-STOCK-/190814696793?pt=UK_BOI_Electrical_Components_Supplies_ET&var=490139054010&hash=item2c6d713559
- Ethernet Injector/Extractor: http://www.amazon.co.uk/Ethernet-Injector-Extractor-extractor-included/dp/B0044LFO70
- Second hand Dell PSU: 19.5V 3.34A
- PiFace.
- Ultrasonic Cat Deterrent for PIR detection: http://www.amazon.co.uk/PestBye-Battery-Operated-Cat-Repeller/dp/B004SGC75S/ref=sr_1_1?ie=UTF8&qid=1381745613&sr=8-1&keywords=ultrasonic+cat+deterrent
- Small NPN transistor amplifier circuit. (NPN transistor and protective resistor).
- Water Pistol - Hasbro 28495 Nerf Super Soaker Thunderstorm Water Gun - battery powered. We actually stripped the pistol down to just the 6V peristaltic motor and tubing, but there is no real reason to do this - the 5V supply can be simply wired into the inside of the trigger. http://modworks.blogspot.co.uk/2011/02/nerf-super-soaker-thunderstorm.html
- 50m Outdoor ethernet cable.
- RSPB Birdbox to house the components: http://shopping.rspb.org.uk/birds-wildlife/nestboxes/garden-bird-nestboxes/rspb-classic-nestbox.html

## Making an Garden Ultrasonic Squirter Camera Alarm
Crack open the Ultrasonic Cat Deterrent using spudgers.

{{<figure src="/media/blog/IMG_20130723_131852.jpg" title="Ultrasonic cat deterrent internals" >}}

Ultrasonic Cat Deterrent Cracked open. Blue LED is located on the middle right of the PCB as orientated.

De-solder the blue LED - it's easiest to do this with the Ultrasonic open and powered up from batteries and look for the blue light flashing.
Attach two wires to where the LED was to a small transistor amplifier circuit as per below.

{{<figure src="/media/blog/transistor_for_monitoring_ultrasonic_bb.png" title="Transistor for amplification" >}}


Amplifier circuit to modify LED on/off to be switch on/off

Optionally allow the Ultrasonic to be powered from the PiFace. The heatshrunk object between the two choc blocks is the transistor circuit board. Wires to/from the PiFace are on the Right hand side of the picture. Orange/White wires out are the conections to PiFace Input 0, Red and Green supply voltage to the Ultrasonic.

{{<figure src="/media/blog/IMG_20130923_134814.jpg" title="Chocolate block for powering from 5V supply" >}}

Install the PiFace software:
sudo apt-get install python-pifacecommon python-pifacedigitalio


Output of transistor amplifier circuit to PiFace input 0
Relay 0 of PiFace attached to Water Pistol.
Relay 1 of PiFace attached to 5V from the PiFace (in case customer wishes to disarm the Ultrasonic remotely).
5V from the Relay 1 and Ground from the PiFace to the Ultrasonic.


Piface powering Pi and Ultrasonic

{{<figure src="/media/blog/IMG_20130906_172921.jpg" title="PiFace powering the ultrasonic detector" >}}


Wiring inside the birdbox.
{{<figure src="/media/blog/PiPoEGUSCA.png" title="Pi Powered Ultrasonic detector" >}}


Water pistol motor inside birdbox. Milk bottle reservoir. Reservoir Overflow pipe is mounted into the handle of the milk bottle. Note this is an earlier revision when the PIR was used to peep through the Birdbox hole.

{{<figure src="/media/blog/IMG_20130826_103458.jpg" title="Motor mounted inside birdbox" >}}

Attach the camera board to the Raspberry Pi carefully threading it through the PiFace.


Version 2: PIR sensor has been replaced by a Pi Camera board mounted to inside of the birdbox. Voltage regulator circuit board is in the bottom left of this photograph.

{{<figure src="/media/blog/IMG_20130826_103458.jpg" title="Camera mounted inside birdbox" >}}

Neat wiring! PiFace, Milk Bottle water pistol reservoir behind , PiFace relays to control and read from the Ultrasonic and fire the Water pistol. Camera board is in the top left of this photograph, voltage regulator underneath.

{{<figure src="/media/blog/IMG_20131015_102101.jpg" title="Birdbox in-situ" >}}

Birdbox, Raspberry Pi camera, red cork bung for refilling reservoir. 3 attached cables - one is the reservoir overflow, one to the Ultrasonic and finally the PoE cable.

{{<figure src="/media/blog/IMG_20131015_102112.jpg" title="Messy birdbox wiring" >}}

PiPoEGUSCA and Ultrasonic in situ.

{{<figure src="/media/blog/IMG_20130826_103458.jpg" title="Messy birdbox wiring" >}}


Waterproof container

{{<figure src="/media/blog/IMG_20131015_102133.jpg" title="Waterproof container" >}}


GitHub code:
https://github.com/tommybobbins/pipoegusca

Deploy the init script into /etc/init.d/ and deploy the python script into /usr/local/bin

```
pi@raspberrypi:$ cd pipoegusca
pi@raspberrypi:$ sudo cp read-ultrasonic.py /usr/local/bin
pi@raspberrypi:$ sudo cp read-ultra.sh /etc/init.d/
```

Set the permissions:
```
pi@raspberrypi:$ sudo chmod a+x /usr/local/bin/read-ultrasonic.py
pi@raspberrypi:$ sudo chmod a+x /etc/init.d/read-ultra.sh
pi@raspberrypi:$ sudo insserv read-ultra.sh
```

Make h264 video storage location:
```
pi@raspberrypi:$ sudo mkdir /usr/local/catcam
pi@raspberrypi:$ sudo chown pi /usr/local/catcam
```
Make all files written into /usr/local/catcam be owned by group pi:
```
pi@raspberrypi:$ sudo chmod g+s /usr/local/catcam
```
Start it up:
```
pi@raspberrypi:$ sudo /etc/init.d/read-ultra.sh start
```
{{< youtube 6W1Y1HhCfmg >}}

Warning, this Python script will turn your PiFace into a Larson scanner. You have been warned.




## Future work
Replace the Ultrasonic module with either opencv running on the Raspberry Pi reading from the camera or running motion (# apt-get install motion)
Install Pi-Noir camera http://designspark.com/eng/blog/nocturnal-wildlife-watching-with-pi-noir. We currently switch the garden lighting on when movement is detected, but it would be better to be able to collect more IR light. This has been done:

{{<figure src="/media/blog/catimage.jpg" title="PiNoir camera" >}}
Make the water reservoir external for ease of filling. Done.
Replace the Water Pistol pump with the Adafruit 12V Peristaltic pump: http://www.adafruit.com/blog/2012/12/19/new-product-peristaltic-liquid-pump-with-silicone-tubing/
Add a IR light from Phenoptix. Done.

{{<figure src="/media/blog/IMG_20131108_143854.jpg" title="IR Torch in birdbox hole" >}}

IR Torch mounted in birdbox hole, PiNoir mounted below IR Torch, Water pistol poking out rudely.

Birdbox with relocated water pistol hole, camera mounted below IR torch. Ultrasonic is to the bottom right of this picture.

{{<figure src="/media/blog/IMG_20131108_143854.jpg" title="IR torch, ultrasonic and camera in place" >}}

{{< youtube S1kHwYkbAyA >}}

Camera starts before Water pistol, then IR torch switches on at the same time as the water pistol. Camera then switches off after IR torch and water pistol switch off. The IR filter is bouncing back IR bleed. To be fixed.
