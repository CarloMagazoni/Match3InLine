--[[
Module with main gameplay logic

Methods:
Init() - Create game field
Tick() - Do something on the game field
Move(from,to) - Perform a player's move
Mix() - Shaffle Matrix with existed gems
Dump() - Render Matrix in console

]]--

local Model = {}
local GemsArray = {'A', 'B', 'C', 'D', 'E', 'F'}
local GameMatrix, Maska = nil

--[[
Just Table copy
]]--
local function TableCopy(t)
  local u = {}
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

--[[
ReRandomGem to prevent ready combo on the start of the game
]]--
local function ReRandomList(index)
  local list = TableCopy(GemsArray)
  local Gem = nil
  table.remove(list, index)
  Gem = list[math.random(#list)]
  return Gem
end

--[[
Create Mask matrix
]]--
local function CreateMaskMatrix(Matrix)
  local MaskMatrix = {}
  for i = 0, #Matrix do
    MaskMatrix[i] = {}
    for j = 0, #Matrix[i] do
      MaskMatrix[i][j] = "-"
    end
  end
  return MaskMatrix
end

--[[
Mark Elements to further delete
]]--
local function MarkAsMatched(M, i, j)
  M[i][j] = "x"
end

--[[
Check for 4 and more in the called match (HORIZONTAL)
]]--
local function CheckChainX(Matrix, MaskMatrix, i, j)
  if j ~= 0 then
    if Matrix[i][j] == Matrix[i][j-1] then
      MarkAsMatched(MaskMatrix, i, j-1)
    end
  end
  if j ~= #Matrix[1] then
    if Matrix[i][j] == Matrix[i][j+1] then
      MarkAsMatched(MaskMatrix, i, j+1)
    end
  end
end

--[[
Check for 4 and more in the called match (Vertical)
]]--
local function CheckChainY(Matrix, MaskMatrix, i, j)
  if i ~= 0 then
    if Matrix[i][j] == Matrix[i-1][j] then
      MarkAsMatched(MaskMatrix, i-1, j)
    end
  end
  if i ~= #Matrix then
    if Matrix[i][j] == Matrix[i+1][j] then
      MarkAsMatched(MaskMatrix, i+1, j)
    end
  end
end

--[[
Check for horizontal match in the middle point
]]--
local function MarkHorizontalMatch(Matrix, MaskMatrix, i, j)
  if j > #Matrix[i] or j < 0 then return end
  if Matrix[i][j] == Matrix[i][j-1] and Matrix[i][j] == Matrix[i][j+1] then
    MarkAsMatched(MaskMatrix, i, j)
    CheckChainX(Matrix,MaskMatrix, i, j)
    CheckChainX(Matrix,MaskMatrix, i, j-1)
    CheckChainX(Matrix,MaskMatrix, i, j+1)
  end
end

--[[
Check for vertical mathc in the middle point
]]--
local function MarkVerticalMatch(Matrix, MaskMatrix, i, j)
  if i > #Matrix or i < 0 then return end
  if Matrix[i][j] == Matrix[i-1][j] and Matrix[i][j] == Matrix[i+1][j] then
    MarkAsMatched(MaskMatrix, i, j)
    CheckChainY(Matrix,MaskMatrix, i, j)
    CheckChainY(Matrix,MaskMatrix, i-1, j)
    CheckChainY(Matrix,MaskMatrix, i+1, j)
  end
end

--[[
Function for tick() to do a match with possible modification to various gems combination like sqare, L Shape etc.
]]--
local function MarkMatches(Matrix, MaskMatrix)
  for i = 0, #Matrix do
    for j = 0, #Matrix[i] do
      if (i ~= 0 or i ~= #Matrix) and (j ~= 0 or j ~= #Matrix[i]) then --if not corners
        if i == 0 or i == #Matrix then --Only horizontal
          MarkHorizontalMatch(Matrix, MaskMatrix, i, j)
        elseif j == 0 or j == #Matrix[i] then --Only vertical
          MarkVerticalMatch(Matrix, MaskMatrix, i, j)
        else
          MarkHorizontalMatch(Matrix, MaskMatrix, i, j)
          MarkVerticalMatch(Matrix, MaskMatrix, i, j) -- + Shape
        end
      end
    end
  end
end

--[[
Scan matrix for current match. A lot of if-then to define various scenarios on the bounds of the Main GameMatrix
]]--
local function HasMatchAtPoint(Matrix, i, j)
  local element = Matrix[i][j]
  if i == 0 and j == 0 then --If UpLeft
    if element == Matrix[i][j+1] and element == Matrix[i][j+2] or element == Matrix[i+1][j] and element == Matrix[i+2][j] then
      return true else return false end
  elseif i == #Matrix and j == 0 then --If LowLeft
    if element == Matrix[i][j+1] and element == Matrix[i][j+2] or element == Matrix[i-1][j] and element == Matrix[i-2][j] then
      return true else return false end
  elseif i == 0 and j == #Matrix[i] then --If UpRight
    if element == Matrix[i][j-1] and element == Matrix[i][j-2] or element == Matrix[i+1][j] and element == Matrix[i+2][j] then
      return true else return false end
  elseif i == #Matrix and j == #Matrix[i] then --If LowRight
    if element == Matrix[i][j-1] and element == Matrix[i][j-2] or element == Matrix[i-1][j] and element == Matrix[i-2][j] then
      return true else return false end
  elseif i == 0 and j < 9 and j > 0 then --If UpBound
    if element == Matrix[i][j-1] and element == Matrix[i][j+1] or element == Matrix[i+1][j] and element == Matrix[i+2][j] then
      return true else return false end
  elseif i == #Matrix and j < 9 and j > 0 then --If LowBound
    if element == Matrix[i][j-1] and element == Matrix[i][j+1] or element == Matrix[i-1][j] and element == Matrix[i-2][j] then
      return true else return false end
    elseif j == 0 and i < 9 and i > 0 then --If LeftBound
      if element == Matrix[i][j+1] and element == Matrix[i][j+2] or element == Matrix[i-1][j] and element == Matrix[i+1][j] then
        return true else return false end
    elseif j == #Matrix and i < 9 and i > 0 then --If RightBound
      if element == Matrix[i][j-1] and element == Matrix[i][j-2] or element == Matrix[i-1][j] and element == Matrix[i+1][j] then
        return true else return false end
  else
    if element == Matrix[i][j-1] and element == Matrix[i][j+1] or element == Matrix[i-1][j] and element == Matrix[i+1][j] then
      return true else return false end
  end
end

--[[
Scan Matrix if last move made a match somewhere
]]--
local function HasNewSolutions(Matrix)
  local NewSolution = false
  for i = 0, #Matrix do
    for j = 0, #Matrix[i] do
      if HasMatchAtPoint(Matrix, i, j) then
        NewSolution = true
      end
    end
  end
  if NewSolution then return true else return false end
end

--[[
Revert mask matrix to init state
]]--
local function RefreshMaskMatrix(Mask)
  for i = 0, #Mask do
    for j = 0, #Mask[i] do
      Mask[i][j] = "-"
    end
  end
end

--[[
Generate new gems for empty holes
]]--
local function FillHoles(Matrix)
  for i = 0, #Matrix do
    for j = 0, #Matrix[i] do
      if Matrix[i][j] == "-" then
        Matrix[i][j] = GemsArray[math.random(#GemsArray)]
      end
    end
  end
end

--[[
Drop elements above empty spaces
]]--
local function DropElements(Matrix, MaskMatrix)
  for j = 0, #Matrix[1] do
    local NumberofHoles, LowestHole = 0
    for i = #Matrix, 0, -1 do
      if Matrix[i][j] == "-" then
        NumberofHoles = NumberofHoles + 1
        if NumberofHoles == 1 then
          LowestHole = i
        end
      end
      if Matrix[i][j] ~= "-" and NumberofHoles > 0 then
        Matrix[LowestHole][j] = Matrix[i][j]
        LowestHole = LowestHole-1
        Matrix[i][j] = "-"
      end
    end
  end
end

--[[
Delete marked elements from main matrix and call Drop
]]--
local function DeleteMatchedElements(Matrix, MaskMatrix)
  for i = 0, #Matrix do
    for j = 0, #Matrix[i] do
      if MaskMatrix[i][j] == "x" then Matrix[i][j] = "-" end
    end
  end
end

--[[
Check if there is no any possible single move to make a match
]]--
local function HasDeadEnd(Matrix)
  for i = 0, #Matrix do
    for j = 0, #Matrix[i] do
      element = Matrix[i][j]
      if element == Matrix[i+1][j] then
        if i < 8 and element == Matrix[i + 3][j] then return false end
        if j < 10 and i < 9 and element == Matrix[i + 2][j + 1] then return false end
        if j > 1 and i < 9 and element == Matrix[i + 2][j - 1] then return false end

        if i > 2 and element == Matrix[i - 2][j] then return false end
        if j < 10 and i > 1 and element == Matrix[i - 1][j + 1] then return false end
        if j > 1 and i > 1 and element == Matrix[i - 1][j - 1] then return false end
      end
      if element == Matrix[i][j+1] then
        if j < 8 and element == Matrix[i][j + 3] then return false end
        if i < 10 and j < 9 and element == Matrix[i + 1][j + 2] then return false end
        if i > 1 and j < 9 and element == Matrix[i - 1][j + 2] then return false end

        if j > 2 and element == Matrix[i][j - 2] then return false end
        if i < 10 and j > 1 and element == Matrix[i + 1][j - 1] then return false end
        if i > 1 and j > 1 and element == Matrix[i - 1][j - 1] then return false end
      end
    end
  end
  return true
end

--[[
Creation of GameMatrix + mask table | INIT() METHOD
]]--
function Model.Init()
  GameMatrix = {}
  for i = 0,9 do
    GameMatrix[i] = {}
    for j = 0,9 do
      local AmountOfGems = #GemsArray
      local index = math.random(#GemsArray)
      local GeneratedGem = GemsArray[index]
      if i > 2 then
        if (GameMatrix[i-1][j] == GeneratedGem and GameMatrix[i-2][j] == GeneratedGem) then
          GeneratedGem = ReRandomList(index)
        end
      end
      if j > 2 then
        if (GameMatrix[i][j-1] == GeneratedGem and GameMatrix[i][j-2] == GeneratedGem) then
          GeneratedGem = ReRandomList(index)
        end
      end
      GameMatrix[i][j]=GeneratedGem
    end
  end
  Maska = CreateMaskMatrix(GameMatrix)
end

--[[
Tick or do something | TICK() METHOD
]]--
function Model.Tick()
  if HasNewSolutions(GameMatrix) then
    MarkMatches(GameMatrix, Maska)
    DeleteMatchedElements(GameMatrix, Maska)
    DropElements(GameMatrix, Maska)
    FillHoles(GameMatrix)
    RefreshMaskMatrix(Maska)
    Model.Dump()
    Model.Tick()
    if HasDeadEnd(GameMatrix) then
      return Model.Mix()
    end
  end
end

--[[
Move Gem from xy to newx and newy | MOVE() METHOD
]]--
function Model.Move(from, to)
  local Buffer = GameMatrix[from[1]][from[2]]
  GameMatrix[from[1]][from[2]] = GameMatrix[to[1]][to[2]]
  GameMatrix[to[1]][to[2]] = Buffer
  if not HasNewSolutions(GameMatrix) then
    Buffer = GameMatrix[to[1]][to[2]]
    GameMatrix[to[1]][to[2]] = GameMatrix[from[1]][from[2]]
    GameMatrix[from[1]][from[2]] = Buffer
  end
end

--[[
Mix Matrix with existing elements to make possible moves for player | MIX() METHOD
]]--
function Model.Mix()
  local ShakedMatrix = GameMatrix
  for i = 0, #GameMatrix do
    for j = 0, #GameMatrix[i] do
      local Buffer = GameMatrix[i][j]
      local NewI = math.random(0, #GameMatrix)
      local NewJ = math.random(0, #GameMatrix[i])
      GameMatrix[i][j] = GameMatrix[NewI][NewJ]
      GameMatrix[NewI][NewJ] = Buffer
    end
  end
  if not HasNewSolutions(GameMatrix) and not HasDeadEnd() then return Model.Mix() end
  Model.Dump()
end

--[[
Render Main Game Matrix | DUMP() METHOD
]]--
function Model.Dump()
  os.execute("cls")
  local string = "  "
  for j = 0, #GameMatrix[1] do
    string = string.." "..j
  end
  print(string)
  for i = 0, #GameMatrix do
      string = i.."|"
    for j = 0, #GameMatrix[1] do
      string = string.." "..GameMatrix[i][j]
    end
    print(string)
  end
end

return Model
