---
title: "Wireless Things, LLAP and house of the future"
date: 2016-07-09T22:58:50Z
draft: false
---

# Wireless things temperature sensors, LLAP and the house of the future.

## ESP8266 Woes

I have spent a large amount of time trying to get the ESP8266s to sleep. I have this problem:
http://www.esp8266.com/viewtopic.php?f=32&t=6763

I've tried to ground the pins as discussed in that thread. Given that the batteries last two to three weeks, the debugging is frustratingly long. I wanted to look at other alternatives.

## The Alternative

I looked again at Ciseco's / Wireless Things range again. They are powered by a CR2032, and cost £10 - slightly more expensive than an ESP8266, but are boxed, reliable and portable:

https://www.wirelessthings.net/wireless-temperature-sensor
This is attached to a Pi and is used to convert the 868MHz LLAP output to HTTP requests.
https://www.wirelessthings.net/slice-of-radio-wireless-rf-transciever-for-the-raspberry-pi

Django then places these into redis entries for use by the thermostat. These work really well, are very easy to setup and very simple to integrate.

https://github.com/tommybobbins/PiThermostat

Here are the output voltages for just over two weeks:

{{<figure src="/media/blog/voltages_2weeks.png" title="Voltages over two weeks" >}}

Here are the temperatures over this time. There are 6 Wireless things sensors: Attic, Barabbas, Damocles, Icarus (inside) and Eden, Heimdall (outside). Forno is a TMP102 sensor attached to a Raspberry Pi inside a metal cased CCTV camera and so gets artificially hot.

{{<figure src="/media/blog/thermostat_2weeks.png" title="Temperature sensor output" >}}
