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
local emptyTable = {}

local MIN_GAMEFRAME = 30*75	-- damage dealt before this time will be disregarded
local gameframe = 0
local invulnerableUnits = {}

local damageTriggers = {
  ["Dialogue 2"] = {damage = 45000},
  ["Dialogue 3"] = {damage = 100000},
}

local defenderSpecificDamageTriggers = {}

local helpUnits = {
  --[UnitDefNames.cloaksnipe.id] = "Help: Sharpshooter",
}
local helpUnitsDamage = {
  --[UnitDefNames.hoverriot.id] = {damage = 0, neededDamage = 2000, triggerName = "Fight Maces"},
  --[UnitDefNames.hoverskirm.id] = {damage = 0, neededDamage = 1250, triggerName = "Fight Scalpels"},
}

local triggerOnDeath = {
  Ada = "Ada Destroyed",
  Daneel = "Victory",
}

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

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GameFrame(n)
  gameframe = n
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if (unitTeam == attackerTeam) or (gameframe < MIN_GAMEFRAME) or paralyzer then
    return
  end
  
  for name,data in pairs(damageTriggers) do
    data.damage = data.damage - damage
    if data.damage <= 0 then
      GG.mission.ExecuteTriggerByName(name)
      damageTriggers[name] = nil
    end
  end
  
  if defenderSpecificDamageTriggers[unitTeam] then
    for name,data in pairs(defenderSpecificDamageTriggers[unitTeam]) do
      data.damage = data.damage - damage
      if data.damage <= 0 then
	GG.mission.ExecuteTriggerByName(name)
	defenderSpecificDamageTriggers[unitTeam][name] = nil
      end
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
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if invulnerableUnits[unitID] then
    return 0
  end
  
  for groupName, trigger in pairs(triggerOnDeath) do
    if (GG.mission.unitGroups[unitID] or emptyTable)[groupName] and not paralyzer then
      local health = Spring.GetUnitHealth(unitID)
      if health - damage < 0 then
	GG.mission.ExecuteTriggerByName(trigger)
	return health-1
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

function gadget:AllowUnitTransfer(unitID, unitDefID, oldTeam, newTeam, capture)
  local group = GG.mission.unitGroups[unitID] or emptyTable
  if group["Ada"] then
    return false
  end
  return true
end

function gadget:Initialize()
  GG.SetUnitInvulnerable = SetUnitInvulnerable
end

function gadget:Shutdown()
  GG.SetUnitInvulnerable = nil
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------