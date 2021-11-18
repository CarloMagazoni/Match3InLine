--[[
Module with player inputs definitions

Methods:
ReadInput() - read player commands and transform it into args for Model.Move

]]--

local Visual = {}
local Moves = {['u'] = 'Up', ['l'] = 'Left', ['r'] = 'Right', ['d'] = 'Down'}
local Code = {EXIT = 1, VALID = 2, INVALID = 3}


--[[
Validate input
]]--
local function Prepare(Input)
  Input = string.gsub(Input, "%s+", "")
  local Output = {}
  for i = 1, #Input do
    Output[i] = string.sub(Input, i, i)
  end
  return Output
end

--[[
Check input command status
]]--
local function ConverInputToStatus(Input)
  if #Input == 1 then
    if Input[1] == 'q' or Input[1] == 'Q' then
      return Code.EXIT
    end
  end
  if #Input == 4 then
    if Input[1] == 'm' and tonumber(Input[2]) >= 0 and tonumber(Input[2]) < 10 and tonumber(Input[3]) >= 0 and tonumber(Input[3]) < 10 and string.match('ulrd', Input[4]) then
      return Code.VALID
    end
  end
  return Code.INVALID
end

--[[
Convert direction symbol to Distination coordinates
]]--
local function ConvertToDistinationCoords(from,Direction)
  local ConvertedCords = {i = from[1], j = from[2]}
  local i = from[1]
  local j = from[2]
  if Direction == 'u' and from[1] > 1 then
    i = i - 1
  elseif Direction == 'l' and from[2] > 1 then
    j = j - 1
  elseif Direction == 'r' and from[2] < 10 then
    j = j + 1
  elseif Direction == 'd' and from[1] < 10 then
    i = i + 1
  else
    return nil
  end
  return {i, j}
end

--[[
Read player's input and return coordinates
]]--
function Visual.ReadInput()
  print("Type your command")
  local input = io.read()
  input = Prepare(input)
  local Status = ConverInputToStatus(input)
  if Status == Code.EXIT then
    return nil, nil, true
  elseif Status == Code.INVALID then
    return nil, nil, false
  end

  local Ip, Jp = tonumber(input[2]), tonumber(input[3])
  local from = {Jp, Ip}
  local to = ConvertToDistinationCoords(from, tostring(input[4]))
  if to == nil then
    return nil, nil, false
  end
  return from, to, false
end

return Visual
