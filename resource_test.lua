local component = require("component")

local function getController()
  if component.isAvailable("me_controller") then
    return component.me_controller
  end
  if component.isAvailable("me_interface") then
    return component.me_interface
  end
  return nil
end

local c = getController()
if not c then
  print("ERROR: ME controller/interface not found")
  return
end

local ok, items = pcall(function()
  return c.getItemsInNetwork()
end)

if not ok or type(items) ~= "table" then
  print("ERROR: getItemsInNetwork() failed")
  return
end

print("=== QUARTZ / LAPIS DEBUG ===")
print("ME items: " .. tostring(#items))
print("")

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
    print("ITEM " .. tostring(index))
    print("name  = " .. name)
    print("label = " .. label)
    print("size  = " .. tostring(size))
    print("-----------------------------")
  end
end

if found == 0 then
  print("No items containing 'quartz' or 'lapis' were found.")
  print("")
  print("Printing all ME items for identification:")
  print("")

  for index, item in ipairs(items) do
    print(
      tostring(index)
      .. ": name=" .. tostring(item.name or "")
      .. " | label=" .. tostring(item.label or "")
      .. " | size=" .. tostring(item.size or 0)
    )
  end
end

print("")
print("Found matching entries: " .. tostring(found))
print("=== END ===")
