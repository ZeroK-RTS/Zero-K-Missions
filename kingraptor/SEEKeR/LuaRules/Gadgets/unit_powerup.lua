--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Powerups",
		desc = "YOU GOT THE TOUCH!",
		author = "KingRaptor",
		date = "April 2009",
		license = "Public domain",
		layer = 0,
		enabled = true
	}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local soundDir = "sounds/"
local imgDir = "LuaRules/Images/powerups/"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if(gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
--SYNCED
--------------------------------------------------------------------------------
local spGetUnitPosition		= Spring.GetUnitPosition
local spGetUnitsInCylinder	= Spring.GetUnitsInCylinder
local spGetUnitTeam		= Spring.GetUnitTeam
local spGetUnitAllyTeam		= Spring.GetUnitAllyTeam
local spGetUnitDefID		= Spring.GetUnitDefID
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local blockedDefs = {
	[ UnitDefNames['terraunit'].id ] = true,
	[ UnitDefNames['wolverine_mine'].id ] = true,
	[ UnitDefNames['pw_dropfac'].id ] = true,
	[ UnitDefNames['pw_dropdepot'].id ] = true,
	[ UnitDefNames['fakeunit_los'].id ] = true,
}
local DIRTBAG_DEF_ID = UnitDefNames.corclog.id
local teams = {
	[0] = 0,
}
local allyTeams = {
	[0] = 0,
}
local UPDATE_PERIOD = 10
local radius = 200

local powerupUnits = {}
local powerupTexts = {}

local damageBoost = {}
local speedBoost = {}
local invulnerable = {}

local powerupDefs = {
	kodachi = {
		chance = 1.25,
		round = 2,
		func = function(boxID)
			local x, y, z = Spring.GetUnitPosition(boxID)
			local newUnitID = Spring.CreateUnit("logkoda", x, y, z, "s", 0)
			Spring.PlaySoundFile(soundDir.."misc/teleport.wav", 4, x, y, z, 0, 0, 0, "sfx")
			Spring.SpawnCEG("teleport_in", x, y, z)
			
			-- apply existing boosts
			for unitID, expire in pairs(damageBoost) do
				damageBoost[newUnitID] = expire
				break
			end
			for unitID, expire in pairs(speedBoost) do
				speedBoost[newUnitID] = expire
				break
			end
			for unitID, expire in pairs(invulnerable) do
				invulnerable[newUnitID] = expire
				break
			end
		end,
		text = "Free Kodachi",
	},
	explode = {
		chance = 2,
		func = function(boxID)
			local x, y, z = Spring.GetUnitPosition(boxID)
			Spring.SpawnCEG("flashjuno", x, y, z)
			Spring.PlaySoundFile(soundDir.."explosion/mini_nuke.wav", 4, x, y, z, 0, 0, 0, "sfx")
			local units = Spring.GetUnitsInCylinder(x, z, 1000, 1)
			for i=1,#units do
				local unitID = units[i]
				local unitDefID = Spring.GetUnitDefID(unitID)
				local ud = UnitDefs[unitDefID]
				--Spring.Echo(ud.name, ud.speed > 0, ud.canAttack, (not ud.isFactory), not (unitDefID == DIRTBAG_DEF_ID))
				if ud.speed > 0 and ud.canAttack and (not ud.isFactory) and not (unitDefID == DIRTBAG_DEF_ID) and (GG.mission.unitGroups[unitID] or {}).ObjMex == nil then
					Spring.DestroyUnit(unitID)
				end
			end
		end,
		text = "Destroy Units",
	},
	facstun = {
		chance = 2,
		round = 2,
		func = function(boxID)
			local x, y, z = Spring.GetUnitPosition(boxID)
			Spring.SpawnCEG("electric_explosion", x, y, z)
			Spring.PlaySoundFile(soundDir.."weapon/more_lightning_fast.wav", 4, x, y, z, 0, 0, 0, "sfx")
			local units = GG.mission.FindUnitsInGroup("Fac")
			for unitID in pairs(units) do
				local para = select(3, Spring.GetUnitHealth(unitID))
				if para < 4000 then
					para = 4000
				end
				Spring.SetUnitHealth(unitID, {paralyze = para + 3000*32/30})	-- stun for 30 seconds
			end
		end,
		text = "Factory Lockout",
	},	
	repair = {
		chance = 2.5,
		func = function(boxID)
			local x, y, z = Spring.GetUnitPosition(boxID)
			Spring.SpawnCEG("nanobomb", x, y, z)
			Spring.PlaySoundFile(soundDir.."weapon/aoe_aura.wav", 4, x, y, z, 0, 0, 0, "sfx")
			local units = GG.mission.FindUnitsInGroup("Koda")
			for unitID in pairs(units) do
				Spring.SetUnitHealth(unitID, 9999)
			end
		end,
		text = "Team Repair",
	},
	--[[
	cloak = {
		chance = 1.5,
		func = function(boxID)
			Spring.SpawnCEG("teleport_out", x, y, z)
			--Spring.PlaySoundFile(soundDir.."weapon/aoe_aura.wav", 4, x, y, z, 0, 0, 0, "sfx")
			local units = GG.mission.FindUnitsInGroup("Koda")
			for unitID in pairs(units) do
				Spring.SetUnitCloak(unitID, true)
				
			end
		end,
		text = "Shadow Device",
	},
	]]
	speedboost = {
		chance = 1.5,
		round = 3,
		func = function(boxID)
			local x, y, z = Spring.GetUnitPosition(boxID)
			Spring.SpawnCEG("teleport_out", x, y, z)
			Spring.PlaySoundFile(soundDir.."weapon/missile/large_missile_fire.wav", 4, x, y, z, 0, 0, 0, "sfx")
			local units = GG.mission.FindUnitsInGroup("Koda")
			for unitID in pairs(units) do
				Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 2)
				GG.UpdateUnitAttributes(unitID)
				speedBoost[unitID] = Spring.GetGameFrame() + 30*10
			end
		end,
		text = "Speed Boost",
	},	
	doubledamage = {
		chance = 2,
		round = 3,
		func = function(boxID)
			local x, y, z = Spring.GetUnitPosition(boxID)
			Spring.SpawnCEG("galisplode", x, y, z)
			Spring.PlaySoundFile(soundDir.."weapon/blackhole_fire.wav", 4, x, y, z, 0, 0, 0, "sfx")
			local units = GG.mission.FindUnitsInGroup("Koda")
			for unitID in pairs(units) do
				damageBoost[unitID] = Spring.GetGameFrame() + 30*15
			end
		end,
		text = "Double Damage",
	},
	invulnerable = {
		chance = 1.5,
		round = 4,
		func = function(boxID)
			local x, y, z = Spring.GetUnitPosition(boxID)
			Spring.SpawnCEG("prettypop", x, y, z)
			Spring.SpawnCEG("particleraise", x, y, z)
			Spring.PlaySoundFile(soundDir.."weapon/laser/heavylaser_fire.wav", 4, x, y, z, 0, 0, 0, "sfx")
			local units = GG.mission.FindUnitsInGroup("Koda")
			for unitID in pairs(units) do
				invulnerable[unitID] = Spring.GetGameFrame() + 30*10
			end
		end,
		text = "Invulnerability",
	},
}
--local gameframe = Spring.GetGameFrame()

_G.powerupUnits = powerupUnits
_G.powerupTexts = powerupTexts
_G.damageBoost = damageBoost
_G.invulnerable = invulnerable
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetSetCount(set)
  local count = 0
  for _ in pairs(set) do
    count = count + 1
  end
  return count
end

local function CheckPowerupUnit(unitID)
	local powerupType = powerupUnits[unitID]
	if not powerupType then
		return
	end
	
	local _, _, _, ux, uy, uz = spGetUnitPosition(unitID, true)
	local trigger = false
	local units = spGetUnitsInCylinder(ux, uz, radius)
	for i=1,#units do
		local unitID = units[i]
		local team = spGetUnitTeam(unitID)
		local allyTeam = spGetUnitAllyTeam(unitID)
		local unitDefID = spGetUnitDefID(unitID)
		if teams[team] and not blockedDefs[unitDefID] then
			trigger = true
			break
		end
	end
	
	if trigger then
		powerupDefs[powerupType].func(unitID)
		powerupTexts[#powerupTexts + 1] = {x = ux, y = uy, z = uz, ttl = 60, length = 60, text = powerupDefs[powerupType].text}
		Spring.DestroyUnit(unitID, false, true)
	end
end

local function ProcessPowerups()
	for unitID in pairs(powerupUnits) do
		CheckPowerupUnit(unitID)
	end
end

local function PickPowerupType()
	local chance, totalChance = 0, 0
	local allowedDefs = {}
	local round = (Spring.GetGameRulesParam("round") or -999)
	if round == -1 then
		round = 3
	elseif round == -2 then
		round = 7
	end
	for name, data in pairs(powerupDefs) do
		if (round) >= (data.round or 0) then
			totalChance = totalChance + data.chance
			allowedDefs[name] = data
		end
	end
	local rand = math.random() * totalChance
	
	local type
	for name, data in pairs(allowedDefs) do
		chance = chance + data.chance
		type = name
		if chance >= rand then
			break
		end
	end
	return type or "repair"
end

local function SpawnPowerupUnit(x, z, type)
	local y = Spring.GetGroundHeight(x, z)
	local unitID = Spring.CreateUnit("corclog", x, y, z, math.random(0,3), 1)
	Spring.PlaySoundFile(soundDir.."misc/teleport.wav", 4, x, y, z, 0, 0, 0, "sfx")
	Spring.SpawnCEG("teleport_in", x, y, z)
	powerupUnits[unitID] = type or PickPowerupType()
	Spring.GiveOrderToUnit(unitID, CMD.FIRE_STATE, {0}, 0)
	return unitID
end

local function ProcessBoosts(frame)
	for unitID, expire in pairs(damageBoost) do
		if frame >= expire then
			damageBoost[unitID] = nil
		end
	end
	for unitID, expire in pairs(speedBoost) do
		if frame >= expire then
			Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
			GG.UpdateUnitAttributes(unitID)
			speedBoost[unitID] = nil
		else
			local _,_,_,x,y,z = Spring.GetUnitPosition(unitID, true)
			Spring.SpawnCEG("flamer", x, y, z, 0, 0, 0, 8, 0)
		end
	end
	for unitID, expire in pairs(invulnerable) do
		if frame >= expire then
			invulnerable[unitID] = nil
		end
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:Initialize()
	GG.SpawnPowerupUnit = SpawnPowerupUnit
	for i=1,4 do
		--SpawnPowerupUnit(600, 600 + i*250)
	end
end

function gadget:Shutdown()
	GG.SpawnPowerupUnit = nil
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	powerupUnits[unitID] = nil
	damageBoost[unitID] = nil
	speedBoost[unitID] = nil
	invulnerable[unitID] = nil
end

function gadget:GameFrame(f)
	if(f % UPDATE_PERIOD == 0) then
		ProcessPowerups()
		ProcessBoosts(f)
	end
	for index, textEntry in pairs(powerupTexts) do	-- getting lazy and using pairs to save trouble with table removal
		textEntry.ttl = textEntry.ttl - 1
		if textEntry.ttl <= 0 then
			table.remove(powerupTexts, index)
		end
	end
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
	if invulnerable[unitID] then
		return 0
	end
	if attackerID and damageBoost[attackerID] then
		damage = damage*2
	end
	return damage
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
--UNSYNCED
--------------------------------------------------------------------------------
local GL_BACK                = GL.BACK
local GL_LEQUAL              = GL.LEQUAL
local GL_ONE                 = GL.ONE
local GL_ONE_MINUS_SRC_ALPHA = GL.ONE_MINUS_SRC_ALPHA
local GL_SRC_ALPHA           = GL.SRC_ALPHA

local spGetUnitPosition = Spring.GetUnitPosition
local spIsUnitVisible = Spring.IsUnitVisible
local glBeginEnd = gl.BeginEnd
local glBillboard = gl.Billboard
local glPushMatrix = gl.PushMatrix
local glPopMatrix = gl.PopMatrix
local glDrawFuncAtUnit = gl.DrawFuncAtUnit
local glTranslate = gl.Translate
local glDepthTest = gl.DepthTest
local glTexture = gl.Texture
local glTexRect = gl.TexRect
local glText = gl.Text
local glUnit = gl.Unit
local glColor = gl.Color
local glBlending = gl.Blending
local glPolygonOffset = gl.PolygonOffset
local glCulling = gl.Culling

local powerupDefs = {
	kodachi = {
		icon = imgDir.."gift2.png",
	},
	explode = {
		icon = imgDir.."nuke.png",
	},
	facstun = {
		icon = imgDir.."capture.png",
	},	
	repair = {
		icon = imgDir.."repair.png",
	},
	--[[
	cloak = {
		icon = imgDir.."cloak.png",
	},
	]]
	speedboost = {
		icon = imgDir.."speedboost.png",
	},	
	doubledamage = {
		icon = imgDir.."doubledamage.png",
	},
	invulnerable = {
		icon = imgDir.."invulnerable.png",
	},
}

local phase = 0
local cloggerHeight = 80

local function MakeRealTable(proxy)
	if not proxy then return end
	local proxyLocal = proxy
	local ret = {}
	for i,v in spairs(proxyLocal) do
		if type(v) == "table" then
			ret[i] = MakeRealTable(v)
		else
			ret[i] = v
		end
	end
	return ret
end

function color2incolor(r,g,b,a)
	local inColor = '\255\255\255\255'
	if r then
		inColor = string.char(255, r*255, g*255, b*255)
	end
	return inColor
end

local function DrawPowerupIcon(texture, offset)
	glTexture(texture)
	glTranslate(0, cloggerHeight + offset,0)
	glBillboard()
	glTexRect(-16, -16, 16, 16)
end

-- FIXME: doesn't fade properly
local function DrawPowerupText(textInfo)
	glPushMatrix()
	local time = textInfo.ttl/textInfo.length
	local offset = (1 - time) * 40
	--local colorChar = color2incolor(1, 1, 1, 0.2+0.8*time)
	local x, y, z = Spring.WorldToScreenCoords(textInfo.x, textInfo.y, textInfo.z)
	glTranslate(x, y + offset, z)
	--glBillboard()
	glText(textInfo.text,0,0,16,"co")
	glPopMatrix()
end

function gadget:DrawWorld()
	phase = phase + 0.01
	if not Spring.IsGUIHidden() then
		local units = SYNCED.powerupUnits
		local offset = math.sin(phase) * 10
		--glDepthTest(true)
		for unitID, powerupType in spairs(units) do
			if spIsUnitVisible(unitID, 32, true) then
				local texture = powerupDefs[powerupType].icon
				glDrawFuncAtUnit(unitID, false, DrawPowerupIcon, texture, offset)
			end
		end
		glTexture(false)
		
		glBlending(GL_ONE, GL_ONE)
		glDepthTest(GL_LEQUAL)
		glPolygonOffset(-10, -10)
		glCulling(GL_BACK)
		local invulnerable = SYNCED.invulnerable
		for u in spairs(invulnerable) do
			local _,_,_,x,y,z = spGetUnitPosition(u, true)
			glColor(0,0.25,1,1)
			if spIsUnitVisible(u, 32, true) then
				glUnit(u, true)
			end
		end
		local damageBoost = SYNCED.damageBoost
		for u in spairs(damageBoost) do
			local _,_,_,x,y,z = spGetUnitPosition(u, true)
			glColor(1,0.1,0.1,1)
			if spIsUnitVisible(u, 32, true) then
				glUnit(u, true)
			end
		end
		glBlending(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
		glPolygonOffset(false)
		glCulling(false)
		glDepthTest(false)
		glColor(1,1,1,1)
		--glDepthTest(false)
	end
end

function gadget:DrawScreen()
	if not Spring.IsGUIHidden() then
		local texts = SYNCED.powerupTexts
		for _,textInfo in spairs(texts) do
			DrawPowerupText(textInfo)
		end
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end