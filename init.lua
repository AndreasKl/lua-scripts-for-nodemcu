-- Wlan configuration
cfg = require "config"

wlanNotAvailableCounter = 0

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
  print("\nSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\tChannel: "..T.channel)
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
  print("\nSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\treason: "..T.reason)
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
  print("\nSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..T.netmask.."\n\tGateway IP: "..T.gateway)
end)

-- Connect to wlan, when no IP is set.
if wifi.sta.getip() == nil then
  wifi.setmode(wifi.STATION)
  wifi.sta.config(cfg.station_cfg)
  wifi.sta.connect()
end

if mqttClient ~= nil then
  mqttClient:close()
  mqttClient = nil
end

mqttClient = mqtt.Client("esp8266", 120, cfg.mqtt_cfg.user, cfg.mqtt_cfg.pwd)
mqttClient:on("offline", function(client) print("MQTT went offline.") end)

function die()
  -- Turn status LED red WLAN is broken...
  gpio.mode(0, gpio.OUTPUT) 
  gpio.write(0, gpio.LOW)
  wifi.setmode(wifi.NULLMODE, false)
end

function connect()
  if wlanNotAvailableCounter > 10 then
    print("WLAN broken. OMG!")
    die()
    return
  end
  if wifi.sta.getip() == nil then
    print("Waiting for IP address.")
    wlanNotAvailableCounter = wlanNotAvailableCounter + 1
    tmr.alarm(1, 20000, tmr.ALARM_SINGLE, connect)
    return
  end
  -- sntp.sync()
  connectMqtt()
  wlanNotAvailableCounter = 0
end

function connectMqtt()
  mqttClient:connect(cfg.mqtt_cfg.server, cfg.mqtt_cfg.port, 1, 
    function(client)
      print "Connected"
      publishAndSchedule()
    end, 
    function(client, reason)
      print("Failed because of: "..reason) 
    end)
end

function publishAndSchedule()
  if publishSensorData() then
    tmr.alarm(0, 120000, tmr.ALARM_SINGLE, publishAndSchedule)
    print("HEAP: "..node.heap())
    return
  end

  -- schedule a mqtt reconnect in a few seconds
  print "Lost MQTT connection schedule a reconnect."
  tmr.alarm(1, 30000, tmr.ALARM_SINGLE, connect)
end

function publishSensorData()
  local temp, humidity = readSensor()
  -- sec, usec = rtctime.get()
  -- return mqttClient:publish(cfg.mqtt_cfg.topic,"D:"..sec.."T:"..temp.."|H:"..humidity, 0, 1)
  return mqttClient:publish(cfg.mqtt_cfg.topic, "T:"..temp.."|H:"..humidity, 0, 1)
end

function readSensor()
  local si7021 = require "si7021"
  local sda = 5
  local scl = 6

  -- FIXME: temporal coupling
  si7021.setupI2C(sda, scl)
  local humidity = si7021.read_humidity()
  local temp = si7021.read_temp()

  print("Temperature : "..string.format("%.2f", temp).."C")
  print("Humidity : "..string.format("%.2f", humidity).."%")
 
  si7021 = nil
  package.loaded.si7021 = nil
  return string.format("%.2f", temp), string.format("%.2f", humidity)
end

connect()