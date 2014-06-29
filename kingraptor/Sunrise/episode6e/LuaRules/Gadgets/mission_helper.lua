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

local MIN_GAMEFRAME = 0	--30*75	-- damage dealt before this time will be disregarded
local gameframe = 0
local invulnerableUnits = {}

local damageTriggers = {}

local defenderSpecificDamageTriggers = {
  [1] = { ["Guard Dialogue"] = {damage = 8000} },
  [2] = { ["Hun Dialogue"] = {damage = 4000} },
  [3] = { ["Goth Dialogue"] = {damage = 4000} },
  [4] = { ["Lombard Dialogue"] = {damage = 4000} },
  [5] = { ["Suevi Dialogue"] = {damage = 4000} },
  [6] = { ["Bulgar Dialogue"] = {damage = 4000} },
}
local requireSpecificAttackerTeam = true
local attackerTeamsForDamageTriggers = {[0] = true, [7] = false}

local helpUnits = {}
local helpUnitsDamage = {}

local triggerOnDeath = {
  Ada = "Ada Destroyed",
  ScipioAstra = "SA Destroyed",
}

local enemyAirTrigger1 = "Unlock Crasher"
local enemyAirTrigger1Damage = 1000
local enemyAirTrigger1Active = true
local enemyAirTrigger2 = "Unlock Chainsaw"
local enemyAirTrigger2Damage = 4000
local enemyAirTrigger2Active = true
local heavyDefTrigger = "Unlock Impaler"
local heavyDefTriggerActive = true

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
  
  if (not requireSpecificAttackerTeam) or attackerTeamsForDamageTriggers[attackerTeam] then
    if defenderSpecificDamageTriggers[unitTeam] then
      for name,data in pairs(defenderSpecificDamageTriggers[unitTeam]) do
	data.damage = data.damage - damage
	if data.damage <= 0 then
	  GG.mission.ExecuteTriggerByName(name)
	  defenderSpecificDamageTriggers[unitTeam][name] = nil
	end
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
  
  if heavyDefTriggerActive and attackerID and (unitTeam == 0 or unitTeam == 7) then
    if (GG.mission.unitGroups[attackerID] or emptyTable)["HeavyDef"] then
      GG.mission.ExecuteTriggerByName(heavyDefTrigger)
      heavyDefTriggerActive = false
    end
  end
  
  local attackerDef = UnitDefs[attackerDefID]
  if attackerDef and attackerDef.canFly and (unitTeam == 0 or unitTeam == 7) then
    if enemyAirTrigger1Active then
      enemyAirTrigger1Damage = enemyAirTrigger1Damage - damage
      if enemyAirTrigger1Damage < 0 then
	enemyAirTrigger1Active = false
	GG.mission.ExecuteTriggerByName(enemyAirTrigger1)
      end
    end
    if enemyAirTrigger2Active then
      enemyAirTrigger2Damage = enemyAirTrigger2Damage - damage
      if enemyAirTrigger2Damage < 0 then
	enemyAirTrigger2Active = false
	GG.mission.ExecuteTriggerByName(enemyAirTrigger2)
      end
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

function gadget:AllowUnitTransfer(unitID, unitDefID, oldTeam, newTeam, capture)
  local group = GG.mission.unitGroups[unitID] or emptyTable
  if group["ScipioAstra"] then
    GG.mission.ExecuteTriggerByName("SA Destroyed")
    Spring.SetUnitHealth(unitID, {capture = 0})
    return false
  elseif group["HunComm"] or group["GothComm"] or group["LombardComm"] or group["SueviComm"] or group["BulgarComm"] then
    Spring.DestroyUnit(unitID)
    return false
  end
  return true
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