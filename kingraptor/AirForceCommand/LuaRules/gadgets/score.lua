--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Score",
    desc      = "Mission score for Air Force Command",
    author    = "KingRaptor",
    date      = "2012.5.28",
    license   = "Public Domain",
    layer     = math.huge,
    enabled   = true --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if (not gadgetHandler:IsSyncedCode()) then
  return false  --  silent removal
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local spGetUnitHealth = Spring.GetUnitHealth
local spGetUnitLastAttacker = Spring.GetUnitLastAttacker
local spGetUnitTeam = Spring.GetUnitTeam

local aiTeams = {}

local maxHealth = {}
local cost = {}
for i=1,#UnitDefs do
  maxHealth[i] = UnitDefs[i].health
  cost[i] = UnitDefs[i].metalCost
end

local losAccess = {public = true}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, 
                            weaponID, attackerID, attackerDefID, attackerTeam)
  if (not attackerTeam) or aiTeams[attackerTeam] or Spring.AreTeamsAllied(unitTeam, attackerTeam) then
    return
  end
    
  if paralyzer then
    damage = damage * 0.25
  end
  
  local scoreDelta = damage/maxHealth[unitDefID] * cost[unitDefID]
  
  if GG.mission then
    local score = (GG.mission.scores[attackerTeam] or 0) + scoreDelta
    GG.mission.scores[attackerTeam] = score
    Spring.SetTeamRulesParam(attackerTeam, "score", score, losAccess)
  end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  local lastAttacker = spGetUnitLastAttacker(unitID)
  if not lastAttacker then
    return
  end
  
  local attackerTeam = spGetUnitTeam(lastAttacker)
  if aiTeams[attackerTeam] or Spring.AreTeamsAllied(unitTeam, attackerTeam) then
    return
  end
  
  local scoreDelta = cost[unitDefID] * 0.5
  
  if GG.mission then
    local score = (GG.mission.scores[attackerTeam] or 0) + scoreDelta
    GG.mission.scores[attackerTeam] = score
    Spring.SetTeamRulesParam(attackerTeam, "score", score, LOS_ACCESS)    
  end
end

--[[
function gadget:UnitFromFactory(unitID, unitDefID, teamID, builderID, builderDefID)
  local scoreDelta = cost[unitDefID] * -0.2
  
  if GG.mission then
    local score = (GG.mission.scores[teamID] or 0) + scoreDelta
    GG.mission.scores[attackerTeam] = score
    Spring.SetTeamRulesParam(teamID, "score", score)    
  end
end
]]--

function gadget:GameStart()
  local teams = Spring.GetTeamList()
  for i=1,#teams do
    if select(4, Spring.GetTeamInfo(teams[i])) then
      aiTeams[teams[i]] = true
    end
  end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
