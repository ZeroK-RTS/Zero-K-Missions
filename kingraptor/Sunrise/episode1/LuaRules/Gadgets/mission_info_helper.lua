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
local units = {
  [UnitDefNames.jumpraid.id] = {damage = 0, neededDamage = 1200, triggerName = "Fight Pyros"},
  [UnitDefNames.jumpassault.id] = {damage = 0, neededDamage = 3000, triggerName = "Fight Jacks"},
}

function gadget:GameFrame(n)
  gameframe = n
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if not(units[attackerDefID] and unitTeam == 0) or gameframe < MIN_GAMEFRAME then
    return
  end
  units[attackerDefID].damage = units[attackerDefID].damage + damage
  if units[attackerDefID].damage > units[attackerDefID].neededDamage then
    GG.mission.ExecuteTriggerByName(units[attackerDefID].triggerName)
    units[attackerDefID] = nil
  end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------