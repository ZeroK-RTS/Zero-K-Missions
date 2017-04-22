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

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local stages = {
	[1] = {name = "metal intro", trigger = "Reclaim"},
	[2] = {name = "reclaim", trigger = "Repair"},
	[3] = {name = "repair", trigger = "Area Commands"},
	[4] = {name = "area commands", trigger = "Energy Intro"},
	[5] = {name = "energy intro", trigger = "Build Solar"},
	[6] = {name = "build solar"},
	[7] = {name = "build mex"},
	[8] = {name = "build factory"},
	[9] = {name = "build units 1"},
	[10] = {name = "build units 2", trigger = "Build Units 3"},
	[11] = {name = "build units 3", trigger = "Destroy Enemy Base"},
	[12] = {name = "destroy enemy base", trigger = "Victory"},
	[13] = {name = "victory"},
}

local featureEntries = {
	{id = "f1", featureName = "corgator_dead", x = 1600, z = 120, rot = 30},
	{id = "f2", featureName = "armpw_dead", x = 1400, z = 165, rot = 220},
	{id = "f3", featureName = "cornecro_dead", x = 1200, z = 120, rot = 105},
	{id = "f4", featureName = "corak_dead", x = 700, z = 220, rot = 72},
	{id = "f5", featureName = "corstorm_dead", x = 780, z = 260, rot = -48},
}

local features = {}
local featuresByFeatureID = {}
local factoryID = nil
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function AdvanceStage()
	local stage = Spring.GetGameRulesParam(STAGE_PARAM)		
	local stagedata = stages[stage]
	if stagedata and stagedata.trigger then
		GG.mission.ExecuteTriggerByName(stagedata.trigger)
	end
end

local function CheckReclaim()
	local stage = Spring.GetGameRulesParam(STAGE_PARAM)
	if stage == 2 then
		if not (features.f1 or features.f2 or features.f3) then
			AdvanceStage()
		end
	elseif stage == 4 then
		if not (features.f4 or features.f5) then
			local proceed = true
			local units = GG.mission.FindUnitsInGroup("Solars")
			for unitID in pairs(units) do
				local health, maxHealth = Spring.GetUnitHealth(unitID)
				if health < maxHealth then
					proceed = false
				end
			end
			if proceed then
				AdvanceStage()
			end
		end
	end
end

local function CheckRepair()
	local stage = Spring.GetGameRulesParam(STAGE_PARAM)
	if stage == 3 then
		local unitID = GG.mission.FindUnitInGroup("Storage")
		local health, maxHealth = Spring.GetUnitHealth(unitID)
		if health >= maxHealth then
			AdvanceStage()
		end
	end
end

local function CheckFactory(builderID)
	if builderID ~= factoryID then
		return true
	end
	local stage = Spring.GetGameRulesParam(STAGE_PARAM)
	if stage == 10 then
		-- check if fac is on repeat
		local state = Spring.GetUnitStates(builderID)
		if not state["repeat"] then
			return false
		end
	elseif stage == 11 then
		-- check if comm is assisting fac
		local commID = GG.mission.FindUnitInGroup("Comm")
		local cmd = (Spring.GetUnitCommands(commID, 1))[1]
		if cmd and cmd.id == CMD.GUARD and cmd.params[1] == factoryID then
			return true
		else
			return false
		end
	end
	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if (not factoryID) and unitDefID == UnitDefNames.factorycloak.id then
		factoryID = unitID
	end
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

function gadget:Shutdown()
	GG.MissionHelper = nil
end

function gadget:GameFrame(n)
	if n%5 == 0 then
		CheckRepair()
		CheckReclaim()
	end
end

function gadget:GamePreload()
	for i=1,#featureEntries do
		local entry = featureEntries[i]
		local y = Spring.GetGroundHeight(entry.x, entry.z)
		local featureID = Spring.CreateFeature(entry.featureName, entry.x, y, entry.z)
		Spring.SetFeatureRotation(featureID, 0, entry.rot, 0)
		features[entry.id] = featureID
		featuresByFeatureID[featureID] = entry.id
	end
end

function gadget:FeatureDestroyed(featureID)
	local id = featuresByFeatureID[featureID]
	if id then
		featuresByFeatureID[featureID] = nil
		features[id] = nil
		CheckReclaim()
	end
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
			Spring.SendLuaRulesMsg("tutorial_next")
		end
	end
end
]]
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------