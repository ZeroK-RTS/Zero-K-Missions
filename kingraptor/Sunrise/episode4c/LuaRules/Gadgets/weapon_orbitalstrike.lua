--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Orbital Strike",
    desc      = "Don't look up.",
    author    = "KingRaptor",
    date      = "2013.06.21",
    license   = "Public Domain",
    layer     = 0,
    enabled   = false --not (Game.version:find('91.0') and (Game.version:find('91.0.1') == nil))
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
local ORIGIN_HEIGHT = 1500
local FALL_SPEED = -5

local scheduledStrikes = {}	-- [gameframe] = {weapon = weapon, x = x, z = z, spread = spread, team = team}

local function UseOrbitalStrike(weapon, team, x, z, spread, numShots, delayBetweenShots)
  --Spring.Echo("Orbital strike initiated")
  local weapon = WeaponDefNames[weapon] and WeaponDefNames[weapon].id
  if not weapon then
    Spring.Log(gadget:GetInfo().name, "error", "Invalid weapon arg for orbital strike")
    return
  end
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
  if n % (30*5) == 0 then
    UseOrbitalStrike("kinetic_impactor", 0, Game.mapSizeX/2, Game.mapSizeZ/2, 100, 15, 3)
  end

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
      local gheight = Spring.GetGroundHeight(x, z)

      
      local params = {
	pos = {x, ORIGIN_HEIGHT + gheight, z},
	["end"] = {x, 0, z},
	team = data.team,
	speed = {0, FALL_SPEED, 0},
	maxRange = ORIGIN_HEIGHT*2,
	spread = {0,0,0},
	error = {0,0,0},
	ttl = 60,
	gravity = Game.gravity,
	startAlpha = 1,
	endAlpha = 1,
	--model = string,
	--cegTag = string,
      }
      Spring.SpawnProjectile(data.weapon, params)
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