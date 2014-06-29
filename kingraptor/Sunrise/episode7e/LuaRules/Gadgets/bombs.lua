--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Bombs (adapted from KotH)",
		desc = "*BOOOOOM* Terrorists win!",
		author = "Alchemist, Licho, KingRaptor",
		date = "April 2009",
		license = "Public domain",
		layer = 1,
		enabled = true
	}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if(gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
--SYNCED
--------------------------------------------------------------------------------
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

local points = {
	{pos = {568, 915, 2831}, radius = 250, controlStrength = 0},
	{pos = {1224, 915, 3672}, radius = 250, controlStrength = 0},
	{pos = {536, 878, 5432}, radius = 300, controlStrength = 0},
}

local teams = {
	[0] = 0,
	[3] = 0,
}
local allyTeams = {
	[0] = 0,
}

local captures = 0
local triggers = {"Bomb Defused 1", "Bomb Defused 2", "Bomb Defused 3"}

local UPDATE_PERIOD = 15

local captureSpeed = 0.05*(UPDATE_PERIOD/30)	-- 20 seconds to fully cap
local decaptureSpeed = 0	--0.1*(UPDATE_PERIOD/30)	-- 10 seconds to fully uncap

local grace = 0
local graceLength = 0

_G.points = points
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetSetCount(set)
  local count = 0
  for _ in pairs(set) do
    count = count + 1
  end
  return count
end

local function ProcessPoint(index)
	local point = points[index]
	local soleAllyTeam	-- may not actually be the sole ally team
	local contested = false
	local present = {}
	
	local units = spGetUnitsInCylinder(point.pos[1], point.pos[3], point.radius)
	for i=1,#units do
		local unitID = units[i]
		local team = spGetUnitTeam(unitID)
		local allyTeam = spGetUnitAllyTeam(unitID)
		local unitDefID = spGetUnitDefID(unitID)
		if teams[team] and not blockedDefs[unitDefID] then
			present[allyTeam] = true
			soleAllyTeam = allyTeam
		end
	end
	
	-- possible situations:
	-- neutral, uncontested,
	-- neutral, contested,
	-- neutral, being captured
	-- captured, uncontested
	-- captured, contested
	-- captured, being decaptured
	
	local numAllyTeams = GetSetCount(present)
	local controlStrength = point.controlStrength
	local capturingAllyTeam = point.capturingAllyTeam
	
	if not point.controllingAllyTeam then	-- neutral
		if numAllyTeams == 0 and capturingAllyTeam then	-- unoccupied
			-- bleed current progress
			--[[
			controlStrength = controlStrength - captureSpeed
			if controlStrength <= 0 then
				capturingAllyTeam = nil
				controlStrength = 0
			end
			]]
		elseif numAllyTeams == 1 then	-- occupied by one team
			if soleAllyTeam ~= capturingAllyTeam then	-- decapture
				controlStrength = controlStrength - decaptureSpeed
				if controlStrength <= 0 then
					capturingAllyTeam = soleAllyTeam
					controlStrength = 0
				end
			else	-- capture
				controlStrength = controlStrength + captureSpeed
				if controlStrength >= 1 then
					point.controllingAllyTeam = soleAllyTeam
					controlStrength = 1
					capturingAllyTeam = nil
				end
			end
		else	-- contested
			-- do nothing?
		end
	else	-- controlled by one allyTeam
		if numAllyTeams == 0 then	-- unoccupied
			-- recover to full if necessary
			controlStrength = controlStrength + captureSpeed
			if controlStrength >= 1 then
				controlStrength = 1
				capturingAllyTeam = nil
			end
		elseif numAllyTeams == 1 then	-- occupied by one team
			if soleAllyTeam ~= controllingAllyTeam then	-- decapture
				controlStrength = controlStrength - decaptureSpeed
				if controlStrength <= 0 then
					point.controllingAllyTeam = nil
					capturingAllyTeam = soleAllyTeam
					controlStrength = 0
				end
			else	-- recover to full if necessary (at increased speed)
				controlStrength = controlStrength + decaptureSpeed
				if controlStrength >= 1 then
					controlStrength = 1
					capturingAllyTeam = nil
				end
			end
		else	-- contested
			-- do nothing?
		end
	end
	point.controlStrength = controlStrength
	point.capturingAllyTeam = capturingAllyTeam
	
	if point.controllingAllyTeam then
		return true	-- defuse the bomb
	end
end

local function ProcessPoints()
	local toRemove = {}
	for i=1,#points do
		local defused = ProcessPoint(i)
		if defused then
			toRemove[#toRemove+1] = i
		end
	end
	for i=1,#toRemove do
		local index = toRemove[i]
		local point = points[index]
		local units = spGetUnitsInCylinder(point.pos[1], point.pos[3], point.radius)
		for i=1,#units do
			local unitID = units[i]
			GG.mission.RemoveUnitGroup(unitID, "Bomb")
		end
		
		table.remove(points,index)
		captures = captures + 1
		GG.mission.ExecuteTriggerByName(triggers[captures])
	end
	if #points == 0 then
		gadgetHandler:RemoveGadget()
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:Initialize()
	--[[
	local goalTime = (Spring.GetModOptions().hilltime or 0) * 60
	
	graceLength = Spring.GetModOptions().gracetime
	if graceLength then
		grace = graceLength * 60
	else
		grace = 0
	end
	for allyTeamID in pairs(allyTeams) do
		allyTeams[allyTeamID] = goalTime
	end
	]]
end

function gadget:GameFrame(f)
	--[[
	if(f%30 == 0 and f < grace * 30 + graceLength*30*60) then
		grace = grace - 1
		_G.grace = grace
	end
	if(f == grace*30 + graceLength*30*60) then
		_G.grace = grace
		--Spring.Echo("Grace period is over. GET THE HILL!")
	end
	]]
	if(f % UPDATE_PERIOD == 0) then
		ProcessPoints()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
--UNSYNCED
--------------------------------------------------------------------------------
local glBeginEnd = gl.BeginEnd
local glPushMatrix = gl.PushMatrix
local glPopMatrix = gl.PopMatrix
local glColor = gl.Color
local glTranslate = gl.Translate
local glVertex = gl.Vertex
local glText = gl.Text
local glDepthTest = gl.DepthTest

local allyTeams = { [0] = {0,1,0.5}, [1] = {1,0,0} }
local circleDivs = 65	-- circle resolution
local innersize = 0.8
local outersize = 1 -- outer radius size compared to hill radius

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


local function DrawCircleInside(circleDivs, r, g, b, alpha, radius)
	local radstep = (2.0 * math.pi) / circleDivs
	for i = 1, circleDivs do
		local a1 = (i * radstep)
		local a2 = ((i+1) * radstep)
		glColor(r, g, b, 0)
		glVertex(0, 0, 0)
		glColor(r, g, b, alpha)
		glVertex(math.sin(a1)*radius, 0, math.cos(a1)*radius)
		glVertex(math.sin(a2)*radius, 0, math.cos(a2)*radius)
	end
end

local function DrawCircleRim(circleDivs, numSlices, r, g, b, alpha, fadealpha, radius)
	local radstep = (2.0 * math.pi) / circleDivs
	for i = 1, numSlices do
		local a1 = (i * radstep)
		local a2 = ((i+1) * radstep)
		glColor(r, g, b, fadealpha)
		glVertex(math.sin(a1)* radius * innersize, 0, math.cos(a1)*radius * innersize)
		glVertex(math.sin(a2)* radius * innersize, 0, math.cos(a2)*radius * innersize)
		glColor(r, g, b, alpha)
		glVertex(math.sin(a2) * radius * outersize, 0, math.cos(a2) * radius * outersize)
		glVertex(math.sin(a1) * radius * outersize, 0, math.cos(a1) * radius * outersize)
	end
end

local function DrawPointCircle(point)
	local owner = point.owningAllyTeam
	local capper = point.capturingAllyTeam
	local innerColor = {1,1,1}
	if owner then
		innerColor = allyTeams[owner]
	end
	local r1, g1, b1 = unpack(innerColor)
	local outerColor = innerColor
	if capper and (not owner) then
		outerColor = allyTeams[capper]
	end
	local r2, g2, b2 = unpack(outerColor)
	
	local alpha = 0.5
	local fadealpha = 0.3
	if (r == b) and (r == g) then  -- increased alphas for greys/b/w
		alpha = 0.7
		fadealpha = 0.5
	end
	local radius = point.radius
	local numSlices = math.floor(point.controlStrength*circleDivs)
	
	glPushMatrix()
	glTranslate(point.pos[1], point.pos[2] + 10, point.pos[3])
	glBeginEnd(GL.TRIANGLES, DrawCircleInside, circleDivs, r1, g1, b1, fadealpha, radius)
	glBeginEnd(GL.QUADS, DrawCircleRim, circleDivs, numSlices, r2, g2, b2, alpha, fadealpha, radius)
	glPopMatrix()
end

function gadget:DrawWorldPreUnit()
	if not Spring.IsGUIHidden() then
		local points = SYNCED.points
		--glDepthTest(true)
		for _,v in spairs(points) do
			DrawPointCircle(v)
		end
		glColor(1,1,1,1)
		--glDepthTest(false)
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end