--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Orbital Strike 91.0",
    desc      = "Don't look up.",
    author    = "KingRaptor",
    date      = "2013.06.21",
    license   = "Public Domain",
    layer     = 0,
    enabled   = true --Game.version:find('91.0') and (Game.version:find('91.0.1') == nil)
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
local ORIGIN_HEIGHT = 5000

local scheduledStrikes = {}	-- [gameframe] = {weapon = weapon, x = x, z = z, spread = spread, team = team}

local function UseOrbitalStrike(weapon, team, x, z, spread, numShots, delayBetweenShots)
  local weapon = WeaponDefNames[weapon] and WeaponDefNames[weapon].id
  --[[
  if not weapon then
    Spring.Echo(gadget:GetInfo().name, "error", "Invalid weapon arg for orbital strike")
    return
  end
  ]]
  local frame = Spring.GetGameFrame() + 1
  for i=1,numShots do
    local time = frame + delayBetweenShots*(i-1)
    scheduledStrikes[time] = scheduledStrikes[time] or {}
    scheduledStrikes[time][#scheduledStrikes[time] + 1] = {
      weapon = weapon,
      x = x,
      z = z,
      spread = spread,
      team = team
    }
  end
end

function gadget:GameFrame(n)
  --if n%150 == 0 then
  --  GG.UseOrbitalStrike("kinetic_impactor", 2, 4100, 4100, 350, 9, 10)
  --end

  if scheduledStrikes[n] then
    local strikes = scheduledStrikes[n]
    for i=1,#strikes do
      local data = strikes[i]
      local x, z = data.x, data.z
      local angle = math.random(0, 360)
      angle = math.rad(angle)
      local dist = math.random(0, data.spread)
      x = x + math.sin(angle)*dist
      z = z + math.cos(angle)*dist
      
      Spring.CreateUnit("fakeunit_orbitalstrike", x, ORIGIN_HEIGHT, z, 0, data.team)
    end
    scheduledStrikes[n] = nil
  end
end

function gadget:Initialize()
  GG.UseOrbitalStrike = UseOrbitalStrike
end

function gadget:Shutdown()
  GG.UseOrbitalStrike = nil
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------