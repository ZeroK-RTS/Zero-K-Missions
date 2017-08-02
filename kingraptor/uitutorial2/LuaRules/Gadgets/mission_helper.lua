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
local MOVE_CIRCLE_RADIUS = 60
local MOVE_CIRCLE_RADIUS_SQ = MOVE_CIRCLE_RADIUS^2

local circles = {
	{1440, 0, 4110},
	{1560, 0, 4270},
	{1680, 0, 4110},
	{1800, 0, 4270},
}

for i=1,#circles do
	local circle = circles[i]
	local y = Spring.GetGroundHeight(circle[1], circle[3])
	if y < 5 then
		y = 5
	end
	circle[2] = y
end

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
	[1] = {name = "camera", trigger = "Solar Found"},
	[2] = {name = "selection 1"},
	[3] = {name = "selection 2"},
	[4] = {name = "selection 3", trigger = "Units Selected"},
	[5] = {name = "selection after", trigger = "Move Commander"},
	[6] = {name = "move"},
	[7] = {name = "line move", trigger = "Attack Target"},
	[8] = {name = "attack", trigger = "Attack Move"},
	[9] = {name = "attack move", trigger = "Victory"},
	[10] = {name = "done"},
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

local function Stage7Check()
	-- check if all the circles have units already there or heading to it
	local validCircles = {}
	local occupiedCircles = {}
	local units = Spring.GetTeamUnits(0)
	for i=1,#units do
		local unitID = units[i]
		local unitDefID = Spring.GetUnitDefID(unitID)
		local unitDef = UnitDefs[unitDefID]
		if unitDef.canMove then
			local ux, uy, uz = Spring.GetUnitPosition(unitID)
			for i=1,#circles do
				if not validCircles[i] then
					local circle = circles[i]
					-- check if unit is already occupying it
					local distSq = (ux - circle[1])^2 + (uz - circle[3])^2
					if distSq < MOVE_CIRCLE_RADIUS_SQ then
						validCircles[i] = true
						occupiedCircles[i] = true
					else
						-- check if unit is headed there
						local cmd = (Spring.GetUnitCommands(unitID, 1))[1]
						if cmd and (cmd.id == CMD.MOVE or cmd.id == CMD_RAW_MOVE) then
							distSq = (cmd.params[1] - circle[1])^2 + (cmd.params[3] - circle[3])^2
							if distSq < MOVE_CIRCLE_RADIUS_SQ then
								validCircles[i] = true
							end
						end
					end
				end
			end
		end
		if #validCircles == 4 then
			break
		end
	end
	if #occupiedCircles == 4 then
		AdvanceStage()
	elseif #validCircles < 4 then
		Spring.GiveOrderToUnitArray(units, CMD.STOP, {}, 0)
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if unitTeam ~= 0 then
		return
	end
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

function gadget:Shutdown()
end

function gadget:GameFrame(n)
	if Spring.GetGameRulesParam(STAGE_PARAM) == 7 then
		Stage7Check()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------
local UPDATE_INTERVAL = 4	-- every 4 screenframes
local circleDivs = 65

local stageChecks = {
	[1] = function()
		local visible = Spring.GetVisibleUnits(nil, nil, false)
		if #visible == 0 then
			return false
		end
		local unitID = visible[1]
		local x1, y1, z1 = Spring.GetCameraPosition()
		local x2, y2, z2 = Spring.GetUnitPosition(unitID)
		
		local distSq = (x2-x1)^2 + (z2-z1)^2
		if distSq <= (500000) and (y1 - y2) < 500 then
			return true
		end
		return false
	end,
	
	[4] = function()
		local selected = Spring.GetSelectedUnits()
		if #selected >= 4 then
			local hasCommander = false
			for i=1,#selected do
				local unitID = selected[i]
				local unitDefID = Spring.GetUnitDefID(unitID)
				local unitDef = UnitDefs[unitDefID]
				if unitDef.customParams.level then	-- is comm
					hasCommander = true
					break
				end
			end
			return hasCommander
		end
		return false
	end,
}

local timer = 0
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:Update()
	timer = timer + 1
	if timer > UPDATE_INTERVAL then
		timer = 0
		
		local stage = Spring.GetGameRulesParam(STAGE_PARAM)
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
	if not Spring.IsGUIHidden() and Spring.GetGameRulesParam(STAGE_PARAM) == 7 then
		--gl.DepthTest(true)
		for _,v in pairs(circles) do
			DrawPointCircle(v)
		end
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