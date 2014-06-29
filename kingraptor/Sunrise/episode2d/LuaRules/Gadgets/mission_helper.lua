--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Mission Info Helper",
    desc      = "Helper gadget for informative tips in mission",
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

local attackers = {
  [UnitDefNames.chickena.id] = {damage = 0, neededDamage = 4000, triggerName = "Help: Cockatrice"},
}
local triggerOnDeath = {
  Ada = "Ada Destroyed",
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

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if not(attackers[attackerDefID] and unitTeam == 0) or gameframe < MIN_GAMEFRAME then
    return
  end
  attackers[attackerDefID].damage = attackers[attackerDefID].damage + damage
  if attackers[attackerDefID].damage > attackers[attackerDefID].neededDamage then
    GG.mission.ExecuteTriggerByName(attackers[attackerDefID].triggerName)
    attackers[attackerDefID] = nil
  end
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


function gadget:Initialize()
  GG.SetUnitInvulnerable = SetUnitInvulnerable
end

function gadget:Shutdown()
  GG.SetUnitInvulnerable = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------