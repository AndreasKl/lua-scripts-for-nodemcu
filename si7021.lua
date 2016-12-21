dev_addr = 0x40
RHumidityHoldCmd = 0xE5
TempHoldCmd = 0xE3

function setupI2C(id, sda, scl)
  i2c.setup(id, sda, scl, i2c.SLOW)
end

function writeI2C(id, dev_addr, set) 
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, set)
  i2c.stop(id)
end

function readI2C(id, dev_addr)          
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  raw_value = i2c.read(id, 2)
  i2c.stop(id)
  value = (bit.lshift(string.byte(raw_value, 1), 8) + string.byte(raw_value, 2))
  status = bit.band(value, 3)    --save status bits
  value = bit.band(value, 65532)  --clear status bits
  return value, status
end

function read_hum(id)
  writeI2C(id, dev_addr, RHumidityHoldCmd)
  readI2C(id, dev_addr)       
  humidity = -6.0 + 125.0 / 65536.0 * value
  -- FIXME: Remove debug output
  print("\nStatus : "..status)
  print("Humidity : "..string.format("%.2f", humidity).."%")
  return humidity
end

function read_temp(id)
   writeI2C(id, dev_addr, TempHoldCmd)
   readI2C(id, dev_addr)      
   temp = -46.85 + 175.72 / 65536.0 * value
   -- FIXME: Remove debug output
   print("Status : "..status)
   print("Temperature : "..string.format("%.2f",temp).."C")
   return temp
end