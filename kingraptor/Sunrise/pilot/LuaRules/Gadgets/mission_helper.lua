--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Mission Info Helper",
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
end

function gadget:UnitDestroyed(unitID)
  invulnerableUnits[unitID] = nil
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if invulnerableUnits[unitID] then
    return 0
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