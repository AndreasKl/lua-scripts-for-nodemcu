# ESP8266 AI-Thinker Playground

## Firmware

Command to flash the firmware to my 32Mbit flash on OSX. Stock firmware was a NOOP.

> ./esptool.py --port /dev/tty.SLAB_USBtoUART write_flash -fm dio 0x00000 /Users/buttercup/Downloads/nodemcu-master-13-modules-2016-12-19-23-25-09-float.bin

### Current firmware config

> NodeMCU custom build by frightanic.com
> 	branch: master
> 	commit: 81ec3665cb5fe68eb8596612485cc206b65659c9
> 	SSL: true
> 	modules: bit,file,gpio,i2c,mqtt,net,node,rtcfifo,rtcmem,rtctime,sntp,tmr,uart,wifi,tls
>  build 	built on: 2017-01-06 21:33
>  powered by Lua 5.1.4 on SDK 1.5.4.1(39cb9a32)


## Python Notes
Need 2.7.x for esptool.py and pyserial `sudo pip install pyserial` module for com.

## Si7021-A20

The sensor is connected using the following wiring:
> VIN -> 3V3
> GND -> GND
> SCL -> D6
> SCA -> D5

## Uploading source code
Install https://github.com/kmpm/nodemcu-uploader via `pip install nodemcu-uploader`
upload source using `nodemcu-uploader  --port /dev/tty.SLAB_USBtoUART upload si7021.lua`.

## Monitoring output on MacOS
`screen /dev/tty.SLAB_USBtoUART 115200` the boot process runs with 9.6kbps and changes to 115.2kbps when firmware gets control. To kill the screen press ctrl + a and then a k.

## WLAN
Copy config.lua.default to config.lua and amend your config. Upload the config to your flash.
