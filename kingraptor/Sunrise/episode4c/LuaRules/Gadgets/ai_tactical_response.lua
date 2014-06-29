--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Tactical Response",
    desc      = "Units respond to being shot from a distance",
    author    = "KingRaptor",
    date      = "2012.11.10",
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
--local RESPONSE_MAX_RANGE_TO_ATTACKER = 900
local RESPONSE_SUMMON_DISTANCE = 500
local MAX_RESPONSE_FREQUENCY = 150	-- 5 seconds
local enabledTeams = {}
local lastResponse = -10000
local allowNonCombat = true
local gameframe = 0

local function EnableForTeam(team)
  enabledTeams[team] = true
end

local function DisableForTeam(team)
  enabledTeams[team] = nil
end

function gadget:Initialize()
  GG.TacticalResponse = {}
  GG.TacticalResponse.EnableForTeam = EnableForTeam
  GG.TacticalResponse.DisableForTeam = DisableForTeam
end

function gadget:Shutdown()
  GG.TacticalResponse = nil
end

function gadget:GameFrame(n)
  gameframe = n
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if (not enabledTeams[unitTeam]) or (not attackerID) or (gameframe < lastResponse + MAX_RESPONSE_FREQUENCY)  then
    return
  end
  local ax, ay, az = Spring.GetUnitPosition(attackerID)
  local ux, uy, uz = Spring.GetUnitPosition(unitID)
  local inRange = Spring.GetUnitsInCylinder(ux, uz, RESPONSE_SUMMON_DISTANCE, unitTeam)
  local responders = {}
  if inRange then
    if allowNonCombat then
      responders = inRange
    else
      for i=1,#inRange do
	local unitID = inRange[i]
	local unitDef = UnitDefs[Spring.GetUnitDefID(unitID)]
	if unitDef.canAttack then
	  responders[#responders+1] = unitID
	end
      end
    end
    Spring.GiveOrderToUnitArray(responders, CMD.FIGHT, {ax, ay, az}, {})
    lastResponse = gameframe
  end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------