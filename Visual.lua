--[[
Module with player inputs definitions

Methods:
ReadInput() - read player commands and transform it into args for Model.Move

]]--

local Visual = {}
local Moves = {['u'] = 'Up', ['l'] = 'Left', ['r'] = 'Right', ['d'] = 'Down'}

--VISUALIZATION

local function ConvertToCords(from,Direction)
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
  return {i,j}
end

local function DefineCommandFromInput(Input)
  local Code = nil
  if #Input == 1 then
    if Input[1] == 'q' or Input[1] == 'Q' then
      Code =  0
      return Code
    end
  end
  if #Input == 4 then
    if Input[1] == 'm' and tonumber(Input[2]) > 0 and tonumber(Input[2]) < 10 and tonumber(Input[3]) > 0 and tonumber(Input[3]) < 10 and string.match('ulrd',Input[4]) then
      Code = 1
    end
  else
    Code = 404
  end
  return Code
end

local function Prepare(Input)
  local Output = {}
  for match in (Input..' '):gmatch("(.-)"..' ') do
    table.insert(Output, match)
  end
  return Output
end

function Visual.ReadInput()
  print("Type your command")
  local input = io.read()
  input = Prepare(input)
  if DefineCommandFromInput(input) == 0 then
    return nil,nil,true
  elseif DefineCommandFromInput(input) == 404 then
    return nil,nil, false
  else
    local Ip,Jp = tonumber(input[2]), tonumber(input[3])
    local from = {Jp,Ip}
    local to = ConvertToCords(from, tostring(input[4]))
    if to == nil then
      return nil, nil, false
    end
    return from, to, false
  end
end

return Visual
