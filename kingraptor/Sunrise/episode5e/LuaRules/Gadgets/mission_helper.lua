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
  ["Dialogue 1"] = {damage = 12000},
  ["Dialogue 2"] = {damage = 50000},
  ["Dialogue 3"] = {damage = 120000},
}

local defenderSpecificDamageTriggers = {}

local enemyPlaneTrigger = "Trident Available"
local enemyPlaneTriggerDamage = 8000
local enemyPlaneTriggerActive = true
local flakTrigger = "Hit By Flak"
local flakTriggerActive = true
local flakUnits = {[UnitDefNames.corflak.id] = true, [UnitDefNames.corsent.id] = true}
local riotTrigger = "Hit By Riots"
local riotTriggerActive = true
local riotUnits = {[UnitDefNames.arm_venom.id] = true, [UnitDefNames.tawf114.id] = true, [UnitDefNames.armdeva.id] = true}

local helpUnits = {
  --[UnitDefNames.armsnipe.id] = "Help: Sharpshooter",
}
local helpUnitsDamage = {
  --[UnitDefNames.hoverriot.id] = {damage = 0, neededDamage = 2000, triggerName = "Fight Maces"},
  --[UnitDefNames.nsaclash.id] = {damage = 0, neededDamage = 1250, triggerName = "Fight Scalpels"},
}

local triggerOnDeath = {
  Ada = "Ada Destroyed",
  ScipioAstra = "SA Destroyed",
  Athenion = "Athenion Destroyed"
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
  
  local attackerDef = UnitDefs[attackerDefID]
  if attackerDef and attackerDef.canFly and (unitTeam == 0 or unitTeam == 1) and enemyPlaneTriggerActive then
    enemyPlaneTriggerDamage = enemyPlaneTriggerDamage - damage
    if enemyPlaneTriggerDamage < 0 then
      enemyPlaneTriggerActive = false
      GG.mission.ExecuteTriggerByName(enemyPlaneTrigger)
    end
  end
  
  local unitDef = UnitDefs[unitDefID]
  if unitDef.canFly and (unitTeam == 0) then
    if flakTriggerActive and attackerDefID and flakUnits[attackerDefID] then
      flakTriggerActive = false
      GG.mission.ExecuteTriggerByName(flakTrigger)
    elseif riotTriggerActive and attackerDefID and riotUnits[attackerDefID] then
      riotTriggerActive = false
      GG.mission.ExecuteTriggerByName(riotTrigger)
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

function gadget:Initialize()
  GG.SetUnitInvulnerable = SetUnitInvulnerable
end

function gadget:Shutdown()
  GG.SetUnitInvulnerable = nil
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------