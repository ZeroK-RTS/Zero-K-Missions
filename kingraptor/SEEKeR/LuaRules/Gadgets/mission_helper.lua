--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Kodachi Rally Helper",
    desc      = "Helper gadget for Super Extreme Kodachi Rally (SEEKeR)",
    author    = "KingRaptor",
    date      = "2014.04.26",
    license   = "GNU GPL, v2 or later",
    layer     = -100,
    enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
-- synced
--------------------------------------------------------------------------------
local emptyTable = {}
local shiftTable = {"shift"}

local gameframe = 0
local powerupInterval = 30
local invulnerableUnits = {}
local kodachiDefID = UnitDefNames.logkoda.id
local nanoDefID = UnitDefNames.armnanotc.id
local testBuildDefID = UnitDefNames.cafus.id
local dirtbagDefID = UnitDefNames.corclog.id
local access = {public = true}

-- FIXME: should probably autodetect number of objectives instead of specifying here
local rounds = {
  {unitCount = 1, objCount = 3, powerupInterval = 45, score = 200, initTrigger = "Round 1", endTrigger = "Round 1 End"},
  {unitCount = 2, objCount = 5, powerupInterval = 45, score = 500, initTrigger = "Round 2", endTrigger = "Round 2 End"},
  {unitCount = 3, objCount = 8, powerupInterval = 40, score = 800, initTrigger = "Round 3", endTrigger = "Round 3 End", facStrength = 4.8},
  {unitCount = 4, objCount = 12, powerupInterval = 35, score = 1200, initTrigger = "Round 4", endTrigger = "Round 4 End", facStrength = 4.4},
  {unitCount = 5, objCount = 15, powerupInterval = 35, score = 1600, initTrigger = "Round 5", endTrigger = "Round 5 End", facStrength = 4.0},
  {unitCount = 6, objCount = 18, powerupInterval = 30, score = 2000, initTrigger = "Round 6", endTrigger = "Round 6 End", facStrength = 3.6},
  
  [-1] = {unitCount = 4, objCount = 2, powerupInterval = 40,  score = 1500, initTrigger = "Miniboss", endTrigger = "Miniboss End"},	-- facStrength = 2.5, noFac = true, noPowerups = true},
  [-2] = {unitCount = 6, objCount = 1, powerupInterval = 30,  score = 2000, initTrigger = "Boss", endTrigger = "Boss End", facStrength = 3.6},	-- facStrength = 2.5, noFac = true, noPowerups = true},
}

local killScores = {
  [UnitDefNames.cormex.id] = 50,
  [UnitDefNames.corcan.id] = 300,
  [UnitDefNames.corgol.id] = 1000,
}

local roundScores = {}

local objUnits = {}
local powerupUnits = {}
_G.objUnits = objUnits

local wantedUnitCount = 0
local unitCount = 0
local objCount = 0
local round = 0
local lastRound = 0
local roundRunning = false
local powerupTicker = 0

local spawnX, spawnZ = Game.mapSizeX/2, Game.mapSizeZ/2
local safezoneX1, safezoneZ1, safezoneX2, safezoneZ2 = 2500, 3500, 3500, 4500
local boundX1, boundZ1, boundX2, boundZ2 = 1280, 1800 + 640, Game.mapSizeX - 1280, 6400 - 640
local camX, camZ = 3032, 4192
local camY = Spring.GetGroundHeight(camX, camZ)

local function SetUnitInvulnerable(unitID, bool)
  if bool == true then
    invulnerableUnits[unitID] = true
    if Spring.GetUnitHealth(unitID) < 0 then
      Spring.SetUnitHealth(unitID, 1)
    end
  elseif bool == false then
    invulnerableUnits[unitID] = nil
  else
    Spring.Log(gadget:GetInfo().name, LOG.ERROR, "invalid parameters for SetUnitInvulnerable")
  end
end

local function CheckIdleUnits()
  local units = Spring.GetTeamUnits(1) or emptyTable
  local targets = Spring.GetTeamUnitsByDefs(0, kodachiDefID) or emptyTable
  if #targets == 0 or #units == 0 then
    return
  end
  local targetID = targets[math.random(#targets)]
  
  for i=1,#units do
    local unitID = units[i]
    local unitDefID = Spring.GetUnitDefID(unitID)
    if unitDefID ~= dirtbagDefID then
      local cmdQueue = Spring.GetCommandQueue(unitID, 1)
      if (not (cmdQueue and cmdQueue[1])) then
	Spring.GiveOrderToUnit(unitID, CMD.ATTACK, {targetID}, 0)
      end
    end
  end
end

local function ModifyScore(delta)
    local score = (GG.mission.scores[0] or 0) + delta
    GG.mission.scores[0] = score
    Spring.SetTeamRulesParam(0, "score", score, access) 
end

local function SetScore(score)
    GG.mission.scores[0] = score
    Spring.SetTeamRulesParam(0, "score", score, access)
end

local function SpawnPowerups(count, type, ignoreSafeZone)
  for i=1,count do
    local x, z
    local tries = 0
    local valid = false
    repeat
      x = math.random(boundX1, boundX2)
      z = math.random(boundZ1, boundZ2)
      y = Spring.GetGroundHeight(x, z)
      tries = tries + 1
      --valid = (not Spring.GetGroundBlocked(x, z))
      valid = Spring.TestBuildOrder(testBuildDefID, x, y, z, 1) > 0
      if not ignoreSafeZone then
	valid = valid and (x < safezoneX1 or x > safezoneX2) and (z < safezoneZ1 or z > safezoneZ2)
      end
    until (valid or tries > 15)
    local unitID = GG.SpawnPowerupUnit(x, z, type)
    Spring.SetUnitNeutral(unitID, true)
    powerupUnits[unitID] = true
  end
end

local function StartRound(n)
  local roundData
  n = n or round
  roundData = rounds[n]
  objCount = roundData.objCount
  powerupInterval = roundData.powerupInterval
  
  --objUnits = GG.mission.FindUnitsInGroup("ObjMex")
  --_G.objUnits = objUnits
  
  local kodas = Spring.GetTeamUnitsByDefs(0, kodachiDefID) or emptyTable
  for i=1,#kodas do
    local unitID = kodas[i]
    Spring.MoveCtrl.Disable(unitID)
    Spring.GiveOrderToUnit(unitID, CMD.WAIT, emptyTable, 0)
    Spring.GiveOrderToUnit(unitID, CMD.WAIT, emptyTable, 0)
  end  
  roundRunning = true
  CheckIdleUnits()
  
  if roundData and not roundData.noFac then
    local units = GG.mission.FindUnitsInGroup("Fac")
    for unitID in pairs(units) do
      Spring.SetUnitBuildSpeed(unitID, roundData.facStrength or 5)
    end
  end
  
  -- TODO: make them path around the map
  for unitID in pairs(powerupUnits) do
  
  end
end

local function EndRound(defeat)
  roundRunning = false
  local units = GG.mission.FindUnitsInGroup("Fac")
  for unitID in pairs(units) do
    Spring.SetUnitBuildSpeed(unitID, 0)
  end
  if not defeat then
    ModifyScore(rounds[round].score)
    local lastScore = GG.mission.scores[0]
    roundScores[round] = lastScore
    SendToUnsynced("RallyRoundComplete", round, lastScore)
    GG.mission.ExecuteTriggerByName("Send Score")
  end
end

local function SetRound(n)
  lastRound = round
  round = n
  Spring.SetGameRulesParam("round", n)
end

local function ResetUnits()
  local count = rounds[round].unitCount
  -- teleport units back to start box, replace losses, repair
  local kodas = Spring.GetTeamUnitsByDefs(0, kodachiDefID) or emptyTable
  for i=#kodas, count - 1 do
    local x = spawnX-- + (96 * (i%3))
    local z = spawnZ-- + (96 * math.floor(i/3))
    local y = Spring.GetGroundHeight(x, z)
    local newUnitID = Spring.CreateUnit(kodachiDefID, x, y, z, "n", 0)
    kodas[#kodas+1] = newUnitID
  end
  wantedUnitCount = math.floor(count/2 + 0.5)
  
  local num = #kodas
  local radius = (num == 0 and 0) or 64 + 32*num
  local angleIncrement = math.rad(360/num)
  
  for i=0,num - 1 do
    local unitID = kodas[i+1]
    local x = spawnX + math.sin(i*angleIncrement)*radius
    local z = spawnZ - math.cos(i*angleIncrement)*radius
    Spring.SetUnitPosition(unitID, x, z)	-- FIXME
    Spring.SetUnitHealth(unitID, 9999)
    Spring.MoveCtrl.Enable(unitID)
    Spring.GiveOrderToUnit(unitID, CMD.STOP, emptyTable, 0)
  end
  Spring.SetCameraTarget(camX, camY, camZ)
  --unitCount = count
end

local function RestartRound(r)
  r = r or round
  SetScore(roundScores[lastRound] or 0)
  ResetUnits()
  GG.mission.ExecuteTriggerByName(rounds[r].initTrigger)
end

local function RefreshObjDisplay()
    objUnits = GG.mission.FindUnitsInGroup("ObjMex")
  _G.objUnits = objUnits
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GameFrame(n)
  gameframe = n
  if n%30 == 0 and roundRunning then
    CheckIdleUnits()
    ModifyScore(-1)
    if (not rounds[round].noPowerups) then
      powerupTicker = powerupTicker + 1
      if powerupTicker >= powerupInterval then
	powerupTicker = 0
	SpawnPowerups(1, nil, true)
      end
    end
  end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  invulnerableUnits[unitID] = nil
  powerupUnits[unitID] = nil
  objUnits[unitID] = nil
  local groups = (GG.mission.unitGroups[unitID] or emptyTable)
  
  if groups["ObjMex"] then
    objCount = objCount - 1
    if roundRunning then
      ModifyScore(killScores[unitDefID] or 50)
      if objCount <= 0 then
	GG.mission.ExecuteTriggerByName(rounds[round].endTrigger)
      end
    end
  end
  
  if groups["Koda"] then
    unitCount = unitCount - 1
    if not ((groups["Intro1"] == true) or (groups["Intro2"] == true)) then
      ModifyScore(-100)
    end
    if unitCount <= 0 and roundRunning then
      GG.mission.ExecuteTriggerByName("Defeat")
    elseif unitCount < wantedUnitCount then
      SpawnPowerups(1,"kodachi",true)
    end
  end
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if invulnerableUnits[unitID] then
    return 0
  end
  return damage
end

--[[
function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions)
    if unitTeam == 0 and unitDefID == kodachiDefID and not roundRunning then
      local groups = (GG.mission.unitGroups[unitID] or emptyTable)
      return (groups["Koda"] == nil) or (groups["Intro1"] == true) or (groups["Intro2"] == true)
    end
    return true
end
]]

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
  Spring.SetUnitAlwaysVisible(unitID, true)
  if UnitDefs[unitDefID].isBuilder then
    Spring.SetUnitBuildSpeed(unitID, 5)
  end
  if unitDefID == kodachiDefID then
    GG.mission.AddUnitGroup(unitID, "Koda")
    unitCount = unitCount + 1
  elseif unitDefID == nanoDefID then
    local x, y, z = Spring.GetUnitPosition(unitID)
    Spring.GiveOrderToUnit(unitID, CMD.PATROL, {x + 40, y, z + 40}, 0)
  end
end

--[[ recursion >:|
function gadget:UnitIdle(unitID, unitDefID, unitTeam)
  if not roundRunning then
    return
  end
  if UnitDefs[unitDefID].canMove then
    local units = Spring.GetTeamUnits(0)
    local targetID = units[math.random(#units)]
    Spring.GiveOrderToUnit(unitID, CMD.ATTACK, {targetID}, 0)
  end
end
]]--

function gadget:Initialize()
  GG.SetUnitInvulnerable = SetUnitInvulnerable
  GG.CheckIdleUnits = CheckIdleUnits
  GG.StartRound = StartRound
  GG.EndRound = EndRound
  GG.RestartRound = RestartRound
  GG.ResetUnits = ResetUnits
  GG.SpawnPowerups = SpawnPowerups
  GG.SetRound = SetRound
  GG.ModifyScore = ModifyScore
  GG.RefreshObjDisplay = RefreshObjDisplay
end

function gadget:Shutdown()
  GG.SetUnitInvulnerable = nil
  GG.CheckIdleUnits = nil
  GG.StartRound = nil
  GG.EndRound = nil
  GG.RestartRound = nil
  GG.ResetUnits = nil
  GG.SpawnPowerups = nil
  GG.SetRound = nil
  GG.ModifyScore = nil
  GG.RefreshObjDisplay = nil
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- drawing code adapted from gui_spotter widget
-- Orig. by 'TradeMark' - mod. by 'metuslucidium'

local GL_LINE_LOOP           = GL.LINE_LOOP
local GL_TRIANGLE_FAN        = GL.TRIANGLE_FAN
local glBeginEnd             = gl.BeginEnd
local glColor                = gl.Color
local glCallList             = gl.CallList
local glCreateList           = gl.CreateList
local glDeleteList           = gl.DeleteList
local glDepthTest            = gl.DepthTest
local glDrawListAtUnit       = gl.DrawListAtUnit
local glPolygonOffset        = gl.PolygonOffset
local glScale                = gl.Scale
local glTranslate            = gl.Translate
local glVertex               = gl.Vertex
local glPushMatrix           = gl.PushMatrix
local glPopMatrix            = gl.PopMatrix

local spGetUnitViewPosition  = Spring.GetUnitViewPosition
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local myTeamID = Spring.GetLocalTeamID()
local realRadii = {}

local circleDivs = 65 -- how precise circle? octagon by default
local innersize = 0.7 -- circle scale compared to unit radius
local outersize = 1.4 -- outer fade size compared to circle scale (1 = no outer fade)
local radius = 120

local circlePoly

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Creating polygons, this is run once widget starts, create quads for each team colour:
local function UpdateDrawList()
	local r, g, b = 1, 0.2, 0.2
	local alpha = 0.5
	local fadealpha = 0.2
	if (r == b) and (r == g) then  -- increased alphas for greys/b/w
		alpha = 0.7
		fadealpha = 0.4
	end
	
	circlePoly = glCreateList(function()
		-- inner:
		glBeginEnd(GL.TRIANGLES, function()
			local radstep = (2.0 * math.pi) / circleDivs
			for i = 1, circleDivs do
				local a1 = (i * radstep)
				local a2 = ((i+1) * radstep)
				glColor(r, g, b, alpha)
				glVertex(0, 0, 0)
				glColor(r, g, b, fadealpha)
				glVertex(math.sin(a1), 0, math.cos(a1))
				glVertex(math.sin(a2), 0, math.cos(a2))
			end
		end)
		-- outer edge:
		glBeginEnd(GL.QUADS, function()
			local radstep = (2.0 * math.pi) / circleDivs
			for i = 1, circleDivs do
				local a1 = (i * radstep)
				local a2 = ((i+1) * radstep)
				glColor(r, g, b, fadealpha)
				glVertex(math.sin(a1), 0, math.cos(a1))
				glVertex(math.sin(a2), 0, math.cos(a2))
				glColor(r, g, b, 0.0)
				glVertex(math.sin(a2) * outersize, 0, math.cos(a2) * outersize)
				glVertex(math.sin(a1) * outersize, 0, math.cos(a1) * outersize)
			end
		end)
	end)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Drawing:
function gadget:DrawWorldPreUnit()
	glDepthTest(true)
	glPolygonOffset(-10000, -2)  -- draw on top of water/map - sideeffect: will shine through terrain/mountains
	local units = SYNCED.objUnits
	for unitID in spairs(units) do
		--glDrawListAtUnit(unitID, circlePoly, false, radius, 1.0, radius)
		local x,y,z = spGetUnitViewPosition(unitID)
		glPushMatrix()
		glTranslate(x,y,z)
		glScale(radius, 1, radius)
		glCallList(circlePoly)
		glPopMatrix()
	end
	glColor(1,1,1,1)
	glScale(1,1,1)
	glDepthTest(false)
end

function WrapToLuaUI(_, round, score)
  if (Script.LuaUI('RallyRoundComplete')) then
    Script.LuaUI.RallyRoundComplete(round, score)
  end
end

function gadget:Initialize()
  UpdateDrawList()
  gadgetHandler:AddSyncAction('RallyRoundComplete', WrapToLuaUI)
end

function gadget:Shutdown()
  gadgetHandler:RemoveSyncAction("RallyRoundComplete")
  glDeleteList(circlePoly)
end

end