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
local teams = {
  [0] = true, [2] = true
}
local triggers = {
  ["Dialogue 1"] = {damage = 3000},
}
local helpUnits = {
  [UnitDefNames.corgator.id] = "Help: Scorcher",
  [UnitDefNames.corraid.id] = "Help: Ravager",
  [UnitDefNames.cormist.id] = "Help: Slasher",
  [UnitDefNames.corgarp.id] = "Help: Wolverine",
}
local helpUnits_command = {
  [UnitDefNames.armfus.id] = "Help: Fusion",
}

local empireDefeated = false
local valhallansDefeated = false
local checkEmpireCond = false

local function EmpireDefeated()
  --Spring.Echo("Imperials pwnt!")
  GG.mission.ExecuteTriggerByName("Cleared Imperial Base")
  empireDefeated = true
  if valhallansDefeated then
    GG.mission.ExecuteTriggerByName("Victory")
  end
end

local function ValhallansDefeated()
  --Spring.Echo("Vikings pwnt!")
  valhallansDefeated = true
  if empireDefeated then
    GG.mission.ExecuteTriggerByName("Victory")
  end
end

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
  if checkEmpireCond and n%45 == 0 then
    checkEmpireCond = false
    local units = Spring.GetUnitsInCylinder(6600, 1720, 1000, 1)
    if units and #units > 0 then
      return
    end
    units = Spring.GetUnitsInCylinder(6600, 1720, 1000, 3) or {}
    for i=1,#units do
      local unitID = units[i]
      local unitDef = UnitDefs[Spring.GetUnitDefID(unitID)]
      if unitDef.canAttack then
	return
      end
    end
    EmpireDefeated()
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
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  invulnerableUnits[unitID] = nil
  if (unitTeam == 1 or unitTeam == 3) and not empireDefeated then
    checkEmpireCond = true
  end
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if invulnerableUnits[unitID] then
    return 0
  end
  if (GG.mission.unitGroups[unitID] or {})["ValComm"] and not paralyzer then
    local health = Spring.GetUnitHealth(unitID)
    if health - damage < 0 then
      GG.mission.ExecuteTriggerByName("Val Comm Destroyed")
      ValhallansDefeated()
      return health-1
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

function gadget:AllowCommand(unitID, unitDefID, teamID,cmdID, cmdParams, cmdOptions)
  if teamID == 0 and helpUnits_command[-cmdID] then
    GG.mission.ExecuteTriggerByName(helpUnits_command[-cmdID])
    helpUnits_command[-cmdID] = nil
  end
  return true
end

function gadget:Shutdown()
  GG.SetUnitInvulnerable = nil
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------