local component = require("component")

local OUTPUT = "/home/resource_debug.txt"

local function writeLine(f, text)
  f:write(tostring(text or ""), "\n")
end

local function getController()
  if component.isAvailable("me_controller") then
    return component.me_controller, "me_controller"
  end
  if component.isAvailable("me_interface") then
    return component.me_interface, "me_interface"
  end
  return nil, nil
end

local out, err = io.open(OUTPUT, "w")
if not out then
  print("ERROR: cannot create " .. OUTPUT .. ": " .. tostring(err))
  return
end

writeLine(out, "=== QUARTZ / LAPIS DEBUG ===")

local controller, controllerType = getController()
if not controller then
  writeLine(out, "ERROR: ME controller/interface not found")
  out:close()
  print("Готово: ошибка записана в " .. OUTPUT)
  return
end

writeLine(out, "controller = " .. controllerType)

local ok, items = pcall(function()
  return controller.getItemsInNetwork()
end)

if not ok or type(items) ~= "table" then
  writeLine(out, "ERROR: getItemsInNetwork() failed")
  out:close()
  print("Готово: ошибка записана в " .. OUTPUT)
  return
end

writeLine(out, "ME items = " .. tostring(#items))
writeLine(out, "")

local found = 0

for index, item in ipairs(items) do
  local name = tostring(item.name or "")
  local label = tostring(item.label or "")
  local size = tonumber(item.size) or 0

  local n = string.lower(name)
  local l = string.lower(label)

  if n:find("quartz", 1, true)
    or l:find("quartz", 1, true)
    or n:find("lapis", 1, true)
    or l:find("lapis", 1, true) then

    found = found + 1
    writeLine(out, "ITEM " .. tostring(index))
    writeLine(out, "name  = " .. name)
    writeLine(out, "label = " .. label)
    writeLine(out, "size  = " .. tostring(size))
    writeLine(out, "-----------------------------")
  end
end

writeLine(out, "")
writeLine(out, "Found matching entries = " .. tostring(found))

if found == 0 then
  writeLine(out, "")
  writeLine(out, "No quartz/lapis text match found.")
  writeLine(out, "All ME items are listed below:")
  writeLine(out, "")

  for index, item in ipairs(items) do
    writeLine(out,
      tostring(index)
      .. ": name=" .. tostring(item.name or "")
      .. " | label=" .. tostring(item.label or "")
      .. " | size=" .. tostring(item.size or 0)
    )
  end
end

writeLine(out, "")
writeLine(out, "=== END ===")
out:close()

print("Готово.")
print("Результат сохранен в:")
print(OUTPUT)
print("Открыть: edit " .. OUTPUT)
