# ESP8266 AI-Thinker Playground

## Firmware

Command to flash the firmware to my 32Mbit flash on OSX. Stock firmware was a NOOP.

> ./esptool.py --port /dev/tty.SLAB_USBtoUART write_flash -fm dio 0x00000 /Users/buttercup/Downloads/nodemcu-master-13-modules-2016-12-19-23-25-09-float.bin

### Current firmware config

> NodeMCU custom build by frightanic.com
>	branch: master
>	commit: 81ec3665cb5fe68eb8596612485cc206b65659c9
>	SSL: true
>	modules: bit,cjson,encoder,file,gpio,http,i2c,mqtt,net,node,tmr,uart,wifi
> build 	built on: 2016-12-19 23:24
> powered by Lua 5.1.4 on SDK 1.5.4.1(39cb9a32)

+sntp, +rtctime, +rtcfifo, +rtcmem. -http

## Python Notes
Need 2.7.x for esptool.py and pyserial `sudo pip install pyserial` module for com. 

## Si7021-A20

The sensor is connected using the following wiring:
> VIN -> 3V3
> GND -> GND
> SCL -> D6
> SCA -> D5

## WLAN
Copy config.lua.default to config.lua and amend your config. Upload the config to your flash. 
