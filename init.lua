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
  -- Upload measures when connected
end)

-- Connect to wlan
if wifi.sta.status() ~= 5 then
  wifi.setmode(wifi.STATION)
  wifi.sta.config(station_cfg)
  wifi.sta.connect()
  tmr.delay(10000000)
  print(wifi.sta.status())
  print(wifi.sta.getip())
end

local si7021 = require "si7021"
local sda = 5
local scl = 6

-- Use hum/temp sensor
-- FIXME: temporal coupling
si7021.setupI2C(sda, scl)
local humidity = si7021.read_humidity()
local temp = si7021.read_temp()
print("Temperature : "..string.format("%.2f",temp).."C")
print("Humidity : "..string.format("%.2f", humidity).."%")
 
si7021 = nil
package.loaded.si7021 = nil

-- Push data to mqtt endpoint
if mqttClient == nil then
  mqttClient = mqtt.Client("esp8266", 120, mqtt_cfg.user, mqtt_cfg.pwd)
end

mqttClient:connect(mqtt_cfg.server, mqtt_cfg.port, 1, 
  function(client) 
    mqttClient:publish("/sensor/tumble_dryer","T : "..string.format("%.2f",temp),0,0, function(client) print("sent") end)
  end, 
  function(client, reason) 
    print("failed reason: "..reason) 
  end)