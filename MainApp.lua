local Model = require("Model")
local Visual = require("Visual")

local HaveField = false
local Playing = true

--Main Loop
while Playing == true do
  if HaveField == false then
    Model.Init()
    Model.Dump()
    HaveField = true
  end
  local from, to, ExitApp = Visual.ReadInput()
  if ExitApp then
    Playing = false
    break
  end
  if from ~= nil and to ~= nil then
    Model.Move(from, to)
    Model.Tick()
  end
end
