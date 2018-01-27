--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Mission Helper",
    desc      = "bla",
    author    = "KingRaptor",
    date      = "2014.04.26",
    license   = "GNU GPL, v2 or later",
    layer     = -100,
    enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- shared constants

local STAGE_PARAM = "tutorial_stage"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
include("LuaRules/Configs/customcmds.h.lua")

local BUTTON_PARAM = "tutorial_show_next_button"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local stages = {
	[1] = {name = "camera", trigger = "Units Found"},
	[2] = {name = "killwave1", trigger = "First Wave Killed"},
	[3] = {name = "lineMove", trigger = "Line Move"},
	[4] = {name = "killwave3", trigger = "Third Wave Killed"},
	--[2] = {name = "select comm"},
	--[3] = {name = "move comm"},
	--[4] = {name = "select multiple", trigger = "Line Move"},
	--[5] = {name = "line move", trigger = "Attack Target"},
	--[6] = {name = "attack"},
	--[7] = {name = "build mex"},
	--[8] = {name = "build solar"},
	--[9] = {name = "build factory"},
	--[10] = {name = "assist fac", trigger = "Build Glaives"},
	--[11] = {name = "build glaives"},
	--[12] = {name = "attack move", trigger = "Victory"},
	--[13] = {name = "end"},
}

local stageKillGroups = {
	[2] = "firstwave",
	[4] = "thirdwave",
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function AdvanceStage()
	local stage = Spring.GetGameRulesParam(STAGE_PARAM)		
	local stagedata = stages[stage]
	if stagedata and stagedata.trigger then
		GG.mission.ExecuteTriggerByName(stagedata.trigger)
	end
end

local function ProcessForbiddenCommand(unitID, cmdID, cmdParams)
	if #cmdParams >= 3 then
		SendToUnsynced("mission_CommandBlocked", cmdID, cmdParams[1], cmdParams[2], cmdParams[3], cmdParams[4])
	else
		if #cmdParams == 1 then unitID = cmdParams[1] end
		local x, y, z = Spring.GetUnitPosition(unitID)
		if x and y and z then
			SendToUnsynced("mission_CommandBlocked", cmdID, x, y, z)
		end
	end
end


local function IsCommandAllowed(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOpts, cmdTag, synced)
	return Spring.GetGameRulesParam(STAGE_PARAM) ~= 1
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:AllowCommand_GetWantedCommand()	
	return true
end

function gadget:AllowCommand_GetWantedUnitDefID()	
	return true
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOpts, cmdTag, synced)
	if teamID ~= 0 then
		return true
	end
	local allowed = IsCommandAllowed(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOpts, cmdTag, synced)
	if not allowed then
		ProcessForbiddenCommand(unitID, cmdID, cmdParams)
		return false
	end
	
	return true
end

function gadget:RecvLuaMsg(msg)
	if msg == "tutorial_next" then
		AdvanceStage()
	end
end

function gadget:Initialize()
	Spring.SetGameRulesParam(BUTTON_PARAM, 0)
	Spring.SetGameRulesParam(STAGE_PARAM, 0)
end

local function CheckAdvanceStage(stage)
	if stageKillGroups[stage] then
		local units = GG.mission.FindUnitsInGroup(stageKillGroups[stage])
		for unitID in pairs(units) do
			return
		end
		AdvanceStage()
	end
end

local vitalUnits = {
	[UnitDefNames["cloakraid"].id] = true,
	[UnitDefNames["cloakassault"].id] = true,
}

local function CheckUnitLossLoss(stage)
	if stage == 5 then
		return
	end
	local units = Spring.GetTeamUnits(0)
	if not units then
		return
	end
	for i = 1, #units do
		if vitalUnits[Spring.GetUnitDefID(units[i])] then
			return
		end
	end
	GG.mission.ExecuteTriggerByName("Mission Defeat")
end

function gadget:GameFrame(n)
	if n%5 == 4 then
		local stage = Spring.GetGameRulesParam(STAGE_PARAM)
		CheckAdvanceStage(stage)
		CheckUnitLossLoss(stage)
	end
end
	
function gadget:Shutdown()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------
local UPDATE_INTERVAL = 4	-- every 4 screenframes
local circleDivs = 65
local ZOOM_DIST_SQ = 1600 * 1600

local circles = {
	{3670, 0, 3440},
	{3725, 0, 3540},
	{3800, 0, 3600},
	{3900, 0, 3650},
	{4000, 0, 3690},
	{4020, 0, 3740},
}

for i = 1,#circles do
	local circle = circles[i]
	local y = Spring.GetGroundHeight(circle[1], circle[3])
	if y < 5 then
		y = 5
	end
	circle[2] = y
end

local stageChecks = {
	[1] = function()
		local visible = Spring.GetVisibleUnits(0, nil, false)
		if #visible == 0 then
			return false
		end
		for i = 1, #visible do
			local unitID = visible[i]
			local unitDefID = Spring.GetUnitDefID(unitID)
			if UnitDefs[unitDefID].name == "cloakraid" then
				local x1, y1, z1 = Spring.GetCameraPosition()
				local x2, y2, z2 = Spring.GetUnitPosition(unitID)
				
				local distSq = (x2-x1)^2 + (z2-z1)^2
				if distSq <= ZOOM_DIST_SQ and (y1 - y2) < 700 then
					return true
				end
			end
		end
		return false
	end,
	
	--[4] = function()
	--	local selected = Spring.GetSelectedUnits()
	--	if #selected >= 4 then
	--		local hasCommander = false
	--		for i=1,#selected do
	--			local unitID = selected[i]
	--			local unitDefID = Spring.GetUnitDefID(unitID)
	--			local unitDef = UnitDefs[unitDefID]
	--			if unitDef.customParams.level then	-- is comm
	--				hasCommander = true
	--				break
	--			end
	--		end
	--		return hasCommander
	--	end
	--	return false
	--end,
}


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local screenTimer = 0
local stage = 1
function gadget:Update()
	screenTimer = screenTimer + 1
	if screenTimer > UPDATE_INTERVAL then
		screenTimer = 0
		stage = Spring.GetGameRulesParam(STAGE_PARAM)
		if stageChecks[stage] and stageChecks[stage]() == true then	-- NEXT!
			Spring.SendLuaRulesMsg("tutorial_next")
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- drawing functions

-- from customFormations2
local function tVerts(verts)
	for i = 1, #verts do
		local v = verts[i]
        if v[1] and v[2] and v[3] then
            gl.Vertex(v[1], v[2], v[3])
        end
	end
end

local function DrawFormationLines()
	gl.LineStipple(1, 4095)
	gl.LineWidth(4)
	
	gl.Color(0.5, 1.0, 0.5, 0.8)
	gl.BeginEnd(GL.LINE_STRIP, tVerts, circles)
	gl.Color(1,1,1,1)
	
	gl.LineWidth(1.0)
	gl.LineStipple(false)
end

local function DrawCircleInside(circleDivs, r, g, b, alpha, radius)
	local radstep = (2.0 * math.pi) / circleDivs
	for i = 1, circleDivs do
		local a1 = (i * radstep)
		local a2 = ((i+1) * radstep)
		gl.Color(r, g, b, 0)
		gl.Vertex(0, 0, 0)
		gl.Color(r, g, b, alpha)
		gl.Vertex(math.sin(a1)*radius, 0, math.cos(a1)*radius)
		gl.Vertex(math.sin(a2)*radius, 0, math.cos(a2)*radius)
	end
end

--[[
local function DrawCircleRim(circleDivs, numSlices, r, g, b, alpha, fadealpha, radius)
	local radstep = (2.0 * math.pi) / circleDivs
	for i = 1, numSlices do
		local a1 = (i * radstep)
		local a2 = ((i+1) * radstep)
		gl.Color(r, g, b, fadealpha)
		gl.Vertex(math.sin(a1)* radius * innersize, 0, math.cos(a1)*radius * innersize)
		gl.Vertex(math.sin(a2)* radius * innersize, 0, math.cos(a2)*radius * innersize)
		gl.Color(r, g, b, alpha)
		gl.Vertex(math.sin(a2) * radius * outersize, 0, math.cos(a2) * radius * outersize)
		gl.Vertex(math.sin(a1) * radius * outersize, 0, math.cos(a1) * radius * outersize)
	end
end
]]

local function DrawPointCircle(point)
	local r1, g1, b1 = 0.2, 0.4, 0.5
	
	gl.PushMatrix()
	gl.Translate(point[1], point[2] + 10, point[3])
	gl.BeginEnd(GL.TRIANGLES, DrawCircleInside, circleDivs, r1, g1, b1, 0.8, MOVE_CIRCLE_RADIUS)
	gl.PopMatrix()
end

function gadget:DrawWorldPreUnit()
	if not Spring.IsGUIHidden() and Spring.GetGameRulesParam(STAGE_PARAM) == 3 then
		--gl.DepthTest(true)
		--for _,v in pairs(circles) do
		--	DrawPointCircle(v)
		--end
		DrawFormationLines()
		gl.Color(1,1,1,1)
		--gl.DepthTest(false)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------