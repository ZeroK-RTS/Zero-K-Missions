--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Mission Helper",
    desc      = "Helper gadget for mission stuff",
    author    = "KingRaptor",
    date      = "2012.12.16",
    license   = "Public Domain",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (not gadgetHandler:IsSyncedCode()) then
  return
end
--------------------------------------------------------------------------------
-- synced
--------------------------------------------------------------------------------
local MIN_GAMEFRAME = 30*60*2	-- damage dealt before this time will be disregarded
local gameframe = 0
local invulnerableUnits = {}
local teams = {
  [0] = true, [1] = true, [3] = true
}
local triggers = {
  ["Dialogue 1"] = {damage = 9000},
}

local helpUnits = {
  --[UnitDefNames.armsnipe.id] = "Help: Sharpshooter",
}
local helpUnitsDamage = {
  [UnitDefNames.hoverriot.id] = {damage = 0, neededDamage = 2000, triggerName = "Fight Maces"},
  [UnitDefNames.nsaclash.id] = {damage = 0, neededDamage = 1250, triggerName = "Fight Scalpels"},
}

local triggerOnDeath = {
  Ada = "Ada Destroyed",
  Odin = "Odin Destroyed",
}

local wave2Active = false
local finaleActive = false

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

function gadget:GameFrame(n)
  gameframe = n

  if n%30 == 0 then
    if GG.KotH.GetTimeRemaining(0) <= 60*2 and not finaleActive then
      GG.mission.ExecuteTriggerByName("Final Showdown")
    elseif GG.KotH.GetTimeRemaining(0) <= 60*5 and not wave2Active then
      GG.mission.ExecuteTriggerByName("Waves 2 Init")
    end
  end
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if not(teams[unitTeam] and teams[attackerTeam] and unitTeam ~= attackerTeam) or gameframe < MIN_GAMEFRAME then
    return
  end
  
  for name,data in pairs(triggers) do
    data.damage = data.damage - damage
    if data.damage <= 0 then
      GG.mission.ExecuteTriggerByName(name)
      triggers[name] = nil
    end
  end
  
  if unitTeam == 0 and helpUnitsDamage[attackerDefID] then
    helpUnitsDamage[attackerDefID].damage = helpUnitsDamage[attackerDefID].damage + damage
    if helpUnitsDamage[attackerDefID].damage > helpUnitsDamage[attackerDefID].neededDamage then
      GG.mission.ExecuteTriggerByName(helpUnitsDamage[attackerDefID].triggerName)
      helpUnitsDamage[attackerDefID] = nil
    end
  end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  invulnerableUnits[unitID] = nil
  --[[
  if (unitTeam == 1 or unitTeam == 3) and not valhalllansDefeated then
    checkValhallansCond = true
  end
  ]]--
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if invulnerableUnits[unitID] then
    return 0, 0
  end
  
  if GG.mission.unitGroups[unitID] then
    for groupName, trigger in pairs(triggerOnDeath) do
      if GG.mission.unitGroups[unitID][groupName] and not paralyzer then
	local health = Spring.GetUnitHealth(unitID)
	if health - damage <= 0 then
	  GG.mission.ExecuteTriggerByName(trigger)
	  return 0
	end
      end
    end
  end

  return damage
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
  if gameframe < 1 then return end
  if helpUnits[unitDefID] and unitTeam == 0 then
    GG.mission.ExecuteTriggerByName(helpUnits[unitDefID])
    helpUnits[unitDefID] = nil
  end
end

function gadget:Initialize()
  GG.SetUnitInvulnerable = SetUnitInvulnerable
end

--[[
function gadget:AllowCommand(unitID, unitDefID, teamID,cmdID, cmdParams, cmdOptions)
  if teamID == 0 and helpUnitsCommand[-cmdID] then
    GG.mission.ExecuteTriggerByName(helpUnitsCommand[-cmdID])
    helpUnitsCommand[-cmdID] = nil
  end
  return true
end
]]--

function gadget:Shutdown()
  GG.SetUnitInvulnerable = nil
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------