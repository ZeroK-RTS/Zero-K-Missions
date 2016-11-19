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
if (not gadgetHandler:IsSyncedCode()) then
	return
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local STAGE_PARAM = "uitutorial_stage"
local BUTTON_PARAM = "uitutorial_show_next_button"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local stages = {
	[1] = {name = "camera", nexttrigger = "Find Radar"},
	[2] = {name = "find radar", nexttrigger = "Select Unit"},
	[3] = {name = "select unit", nexttrigger = "Go to Location"},
	[4] = {name = "move", nexttrigger = "Spawn Target"},
	[5] = {name = "attack", nexttrigger = "Spawn Fight Demo"},
	[6] = {name = "fightdemo", nexttrigger = "Spawn More Targets"},
	[7] = {name = "fight", nexttrigger = "Line Move"},
	[8] = {name = "line move", nexttrigger = "Build Solar"},
	[9] = {name = "build solar", nexttrigger = "Build Mex"},
	[10] = {name = "build mex", nexttrigger = "Build Factory"},
	[11] = {name = "build factory", nexttrigger = "Build Units"},
	[12] = {name = "build units", nexttrigger = "Repair Unit"},
	[13] = {name = "repair", nexttrigger = "Fog of War"},
	[14] = {name = "fog of war", nexttriger = nil}
}

local checkReaper = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if unitTeam ~= 0 then
		return
	end
end

function gadget:RecvLuaMsg(msg)
	if msg == "uitutorial_next" then
		local stage = Spring.GetGameRulesParam(STAGE_PARAM) + 1
		Spring.SetGameRulesParam(STAGE_PARAM, stage)
		
		local stagedata = stages[stage]
		--Spring.Echo("Stage " .. stage, (stagedata or {}).nexttrigger)
		if stagedata and stagedata.nexttrigger then
			GG.mission.ExecuteTriggerByName(stagedata.nexttrigger)
		end
	end
end

function gadget:Initialize()
	Spring.SetGameRulesParam(BUTTON_PARAM, 0)
	Spring.SetGameRulesParam(STAGE_PARAM, 0)
	GG.MissionHelper = {
		SetCheckReaper = function(bool)
			checkReaper = bool
		end
	}
end

function gadget:Shutdown()
	GG.MissionHelper = nil
end

function gadget:GameFrame(n)
	if checkReaper and n%15 == 0 then
		local reaper = GG.mission.FindUnitInGroup("Reaper")
		local hp, maxHP = Spring.GetUnitHealth(reaper)
		if hp and hp >= maxHP then
			checkReaper = false
			GG.mission.ExecuteTriggerByName("Unit Repaired")
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------