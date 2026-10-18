local component=require("component")

local OUTPUT="/home/resource_filter_debug.txt"

local function getController()
  if component.isAvailable("me_controller") then return component.me_controller,"me_controller" end
  if component.isAvailable("me_interface") then return component.me_interface,"me_interface" end
  return nil,nil
end

local f,err=io.open(OUTPUT,"w")
if not f then
  print("ERROR: "..tostring(err))
  return
end

local function line(s) f:write(tostring(s or ""),"\n") end

local controller,kind=getController()
line("=== FILTER TEST ===")
line("controller = "..tostring(kind))
line("")

if not controller then
  line("ERROR: ME controller/interface not found")
  f:close()
  print("Result: "..OUTPUT)
  return
end

local tests={
  {title="QUARTZ",filter={name="minecraft:quartz"}},
  {title="LAPIS",filter={name="minecraft:dye"}}
}

for _,t in ipairs(tests) do
  line("=== "..t.title.." ===")
  line("filter.name = "..t.filter.name)

  local ok,items,callErr=pcall(function()
    return controller.getItemsInNetwork(t.filter)
  end)

  line("pcall = "..tostring(ok))
  line("return type = "..type(items))
  if callErr~=nil then line("api error = "..tostring(callErr)) end

  if ok and type(items)=="table" then
    line("items = "..tostring(#items))
    local total=0
    for i,item in ipairs(items) do
      local name=tostring(item.name or "")
      local label=tostring(item.label or "")
      local size=tonumber(item.size) or 0
      total=total+size
      line("ITEM "..i)
      line("name  = "..name)
      line("label = "..label)
      line("size  = "..size)
      line("-----------------------------")
    end
    line("raw total = "..tostring(total))
  end
  line("")
end

line("=== END ===")
f:close()
print("Готово")
print("Результат: "..OUTPUT)
print("Открыть: edit "..OUTPUT)
