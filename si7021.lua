local moduleName = ...
local M = {}
_G[moduleName] = M

local id = 0
local device_address = 0x40
local relative_humidity_hold_cmd = 0xE5
local temp_hold_cmd = 0xE3

function M.setupI2C(sda, scl)
  i2c.setup(id, sda, scl, i2c.SLOW)
end

local function writeI2C(set)
  i2c.start(id)
  i2c.address(id, device_address, i2c.TRANSMITTER)
  i2c.write(id, set)
  i2c.stop(id)
end

local function readI2C()
  i2c.start(id)
  i2c.address(id, device_address, i2c.RECEIVER)
  raw_value = i2c.read(id, 2)
  i2c.stop(id)
  local value = (bit.lshift(string.byte(raw_value, 1), 8) + string.byte(raw_value, 2))
  local status = bit.band(value, 3)
  value = bit.band(value, 65532)
  return value, status
end

function M.read_humidity()
  writeI2C(relative_humidity_hold_cmd)
  local value, status = readI2C()
  local humidity = -6.0 + 125.0 / 65536.0 * value
  return humidity
end

function M.read_temp()
   writeI2C(temp_hold_cmd)
   local value, status = readI2C()
   local temp = -46.85 + 175.72 / 65536.0 * value
   return temp
end

return M
