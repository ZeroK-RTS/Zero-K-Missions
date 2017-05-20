--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Mission Victory Handler",
    desc      = "Unit tracking for victory",
    author    = "KingRaptor",
    date      = "2012.12.16",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true
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
local spGetTeamInfo = Spring.GetTeamInfo

local defeatTriggersByTeam = {
  [0] = "Defeat",
  [1] = "Victory",
}
local defeatTriggersByAllyTeam = {}

local teamsToAllyTeams = {}

local countNonCombatStatics = false
local countNonBuilders = false
local countNormalCons = false
local countFactories = true
local gaiaTeamID = Spring.GetGaiaTeamID()
local gaiaAllyTeamID = select(6, spGetTeamInfo(gaiaTeamID))

local nilUnitDef = {id=-1}
local function GetUnitDefIdByName(defName)
  return (UnitDefNames[defName] or nilUnitDef).id
end

local doesNotCountList = {
  [GetUnitDefIdByName("spiderscout")] = true,
  [GetUnitDefIdByName("shieldbomb")] = true,
  [GetUnitDefIdByName("cloakbomb")] = true,
  [GetUnitDefIdByName("cloakheavyraid")] = true,
  [GetUnitDefIdByName("terraunit")] = true,
}

-- auto detection of doesnotcount units
for name, ud in pairs(UnitDefs) do
  if (ud.customParams.dontcount) then
    doesNotCountList[ud.id] = true
  elseif (ud.isFeature) then
    doesNotCountList[ud.id] = true
  elseif not (ud.isBuilder or countNonBuilders) then
    doesNotCountList[ud.id] = true
  elseif (not countNonCombatStatics) and (not ud.canAttack) and (not ud.speed) and (not ud.isFactory) then
    doesNotCountList[ud.id] = true
  elseif (not countFactories) and ud.isFactory then
    doesNotCountList[ud.id] = true
  elseif (not countNormalCons) and ud.isBuilder and not (ud.isFactory or ud.customParams.commtype) then
    doesNotCountList[ud.id] = true
  end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local teamUnitCounts = {}
local allyTeamUnitCounts = {}

local function CheckAllUnits()
  aliveCount = {}
  local teams = spGetTeamList()
  for i=1,#teams do
    local teamID = teams[i]
    if teamID ~= gaiaTeam then
      aliveCount[teamID] = 0
    end
  end
  local units = spGetAllUnits()
  for i=1,#units do
    local unitID = units[i]
    local teamID = spGetUnitTeam(unitID)
    local unitDefID = spGetUnitDefID(unitID)
    gadget:UnitCreated(unitID, unitDefID, teamID)
  end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitCreated(unitID, unitDefID, teamID)
  if (team ~= gaiaTeamID) and (not doesNotCountList[unitDefID]) then
    teamUnitCounts[teamID] = teamUnitCounts[teamID] + 1
    local allyTeamID = teamsToAllyTeams[teamID]
    allyTeamUnitCounts[allyTeamID] = allyTeamUnitCounts[allyTeamID] + 1
  end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
  if (team ~= gaiaTeamID) and (not doesNotCountList[unitDefID]) then
    teamUnitCounts[teamID] = teamUnitCounts[teamID] - 1
    if teamUnitCounts[teamID] == 0 then
      GG.mission.ExecuteTriggerByName(defeatTriggersByTeam[teamID])
    end
    local allyTeamID = teamsToAllyTeams[teamID]
    allyTeamUnitCounts[allyTeamID] = allyTeamUnitCounts[allyTeamID] - 1
    if allyTeamUnitCounts[allyTeamID] == 0 then
      GG.mission.ExecuteTriggerByName(defeatTriggersByAllyTeam[allyTeamID])
    end
  end
end

-- note the order of UnitGiven and UnitTaken in the event queue
-- -> first we add the unit and _then_ remove it from the ally unit counter!
function gadget:UnitGiven(u, ud, newTeam, oldTeam)
  gadget:UnitCreated(u, ud, newTeam)
end

function gadget:UnitTaken(u, ud, oldTeam, newTeam)
  gadget:UnitDestroyed(u, ud, oldTeam)	
end

function gadget:Initialize()
  local teams = Spring.GetTeamList()
  for i=1,#teams do
    local teamID = teams[i]
    teamUnitCounts[teamID] = 0
    local allyTeamID = select(6, spGetTeamInfo(teamID))
    teamsToAllyTeams[teamID] = allyTeamID
    allyTeamUnitCounts[allyTeamID] = 0
  end
end