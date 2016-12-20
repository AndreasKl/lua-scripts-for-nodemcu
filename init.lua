-- Wlan configuration
require "config"

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
  print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\tChannel: "..T.channel)
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
  print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\treason: "..T.reason)
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
  print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..T.netmask.."\n\tGateway IP: "..T.gateway)
end)

-- Connect to wlan
result = wifi.sta.config(station_cfg)

id  = 0x0
sda = 5
scl = 6
dev_addr = 0x40
RHumidityHoldCmd = 0xE5
TempHoldCmd = 0xE3

i2c.setup(id, sda, scl, i2c.SLOW)

function writeI2C(id, dev_addr, set) 
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, set)
  i2c.stop(id)
end

function readI2C(id, dev_addr)          
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  data = i2c.read(id, 2)
  i2c.stop(id)
  rval = (bit.lshift(string.byte(data, 1), 8) + string.byte(data, 2))
  status = bit.band(rval, 3)    --save status bits
  rval = bit.band(rval, 65532)  --clear status bits
  return rval, status
end

function read_hum(id, dev_addr)
  writeI2C(id, dev_addr, RHumidityHoldCmd)
  readI2C(id, dev_addr)       
  hum = -6.0+125.0/65536.0*rval
  print("\nStatus : "..status)
  print("Humidity : "..string.format("%.2f",hum).."%")
end

function read_temp(id, dev_addr)
   writeI2C(id, dev_addr, TempHoldCmd)
   readI2C(id, dev_addr)      
   temp = -46.85+175.72/65536.0*rval
   print("Status : "..status)
   print("Temperature : "..string.format("%.2f",temp).."C")
end

read_hum(id, dev_addr)
read_temp(id, dev_addr)
