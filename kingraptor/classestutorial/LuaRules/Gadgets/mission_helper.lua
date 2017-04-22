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

local BUTTON_PARAM = "tutorial_show_next_button"

local suppressDeathCheck = false
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local stages = {
	[1] = {name = "raider tutorial", trigger = "Start Riot Lesson"},
	[2] = {name = "riot tutorial", trigger = "Start Skirm Lesson"},
	[3] = {name = "skirm tutorial", trigger = "Start Skirm Lesson 2"},
	[4] = {name = "skirm tutorial 2", trigger = "Start Assault Lesson"},
	[5] = {name = "assault tutorial", trigger = "Start Arty Lesson"},
	[6] = {name = "arty tutorial", trigger = "Start AA Lesson"},
	[7] = {name = "aa tutorial", trigger = "End"},
	[8] = {name = "end", trigger = "Victory"},
	[9] = {name = "victory"},
}

local groupsToCheck = {
	[1] = {"RaiderDemo", "Spawn Raider Lesson"},
	[2] = {"RiotDemo", "Spawn Riot Lesson"},
	[3] = {"SkirmDemo", "Spawn Skirm Lesson"},
	[4] = {"SkirmDemo2", "Spawn Skirm Lesson 2"},
	[5] = {"AssaultDemo", "Spawn Assault Lesson"},
	[6] = {"ArtyDemo", "Spawn Arty Lesson"},
	[7] = {"AADemo", "Spawn AA Lesson"},
}

local features = {}
local delayedActions = {}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function RemoveFeatures()
	local features = Spring.GetAllFeatures()
	for i=1,#features do
		Spring.DestroyFeature(features[i])
	end
end

local function AddDelayedFunction(func, delay)
	local frame = Spring.GetGameFrame() + delay
	local tab = delayedActions[frame] or {}
	tab[#tab + 1] = func
	delayedActions[frame] = tab
end

local function AdvanceStage()
	local stage = Spring.GetGameRulesParam(STAGE_PARAM)		
	local stagedata = stages[stage]
	--Spring.Echo("Advancing", stage, stagedata)
	if stagedata and stagedata.trigger then
		GG.mission.ExecuteTriggerByName(stagedata.trigger)
		Spring.SetGameRulesParam(STAGE_PARAM, stage + 1)
	end
end

local function CheckGroup(destroyedUnitID, stage, advance)
	local groupName = groupsToCheck[stage][1]
	if not GG.mission.IsUnitInGroup(destroyedUnitID, groupName) then
		return
	end
	
	local units = GG.mission.FindUnitsInGroup(groupName)
	local friendlies = {}
	local enemies = {}
	for unitID in pairs(units) do
		local unitDefID = Spring.GetUnitDefID(unitID)
		if GG.mission.IsUnitInGroup(unitID, "NoNeedKill") or Spring.GetUnitIsDead(unitID)
			or UnitDefs[unitDefID].name == "fakeunit_los" then
			-- do nothing
		else
			local team = Spring.GetUnitTeam(unitID)
			if team == 0 then
				friendlies[#friendlies + 1] = unitID
			elseif team == 1 then
				enemies[#enemies + 1] = unitID
			end
		end
	end
	--Spring.Echo("Friendlies", #friendlies, "Enemies", #enemies)
	-- if one side is wiped out, restart/advance as needed
	local weDied = #friendlies == 0
	local theyDied = #enemies == 0
	if weDied or theyDied then
		
		local cleanup = function()
			suppressDeathCheck = true
			for unitID in pairs(units) do
				Spring.DestroyUnit(unitID, false, true)
			end
			suppressDeathCheck = false
			RemoveFeatures()
		end
		AddDelayedFunction(cleanup, 30)
		
		if theyDied and advance then
			AddDelayedFunction(AdvanceStage, 60)
		else
			AddDelayedFunction(function() GG.mission.ExecuteTriggerByName(groupsToCheck[stage][2]) end, 60)
		end
	end
end

local function CheckGroups(unitID)
	if suppressDeathCheck then
		return
	end
	local stage = Spring.GetGameRulesParam(STAGE_PARAM)		
	if stage < 8 then
		CheckGroup(unitID, stage, true)
	else
		for stageNum in ipairs(groupsToCheck) do
			CheckGroup(unitID, stageNum, false)
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GameFrame(n)
	if delayedActions[n] then
		for i=1,#delayedActions[n] do
			delayedActions[n][i]()
		end
		delayedActions[n] = nil
	end
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)

end

function gadget:UnitFromFactory(unitID, unitDefID, unitTeam, factID, factDefID, userOrders)

end

function gadget:AllowUnitCreation(unitDefID, builderID, builderTeam, x, y, z, facing)
	return CheckFactory(builderID)
end



function gadget:RecvLuaMsg(msg)
	if msg == "tutorial_next" then
		AdvanceStage()
	end
end

function gadget:Initialize()
	Spring.SetGameRulesParam(BUTTON_PARAM, 0)
	Spring.SetGameRulesParam(STAGE_PARAM, 0)
	GG.MissionHelper = {
		
	}
end

function gadget:GamePreload()
	RemoveFeatures()
end

function gadget:Shutdown()
	GG.MissionHelper = nil
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	CheckGroups(unitID)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------
local UPDATE_INTERVAL = 4	-- every 4 screenframes

local stageChecks = {}

local timer = 0
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--[[
function gadget:Update()
	timer = timer + 1
	if timer > UPDATE_INTERVAL then
		timer = 0
		
		local stage = Spring.GetGameRulesParam(STAGE_PARAM)
		if stageChecks[stage] and stageChecks[stage]() == true then	-- NEXT!
			Spring.SendLuaRulesMsg("uitutorial_next")
		end
	end
end
]]
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------