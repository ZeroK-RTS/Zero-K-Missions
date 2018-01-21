--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Command Locker",
		desc = "Blocks non-permitted commands",
		author = "KDR_11k (David Becker), KingRaptor (L.J. Lim)",
		date = "2008-03-04",
		license = "Public Domain",
		layer = 999,
		enabled = true,
	}
end

local SAVE_FILE = "Gadgets/cmd_locker.lua"
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if (gadgetHandler:IsSyncedCode()) then
	
--------------------------------------------------------------------------------
-- synced
--------------------------------------------------------------------------------
VFS.Include("LuaRules/Configs/customcmds.h.lua")

local ALLOW_SYNCED = false

local unlockedCMDs = {
	[CMD.STOP] = true,
	--[CMD.WAIT] = true,
	[CMD.TIMEWAIT] = true,
	[CMD.DEATHWAIT] = true,
	[CMD.SQUADWAIT] = true,
	[CMD.GATHERWAIT] = true,
	[CMD.AISELECT] = true,
	[CMD.GROUPSELECT] = true,
	[CMD.GROUPADD] = true,
	[CMD.GROUPCLEAR] = true,
	[CMD.SELFD] = true,
	[CMD.LOAD_UNITS] = true,
	[CMD.LOAD_ONTO] = true,
	[CMD.UNLOAD_UNITS] = true,
	[CMD.UNLOAD_UNIT] = true,
	[CMD.ONOFF] = true,
	[CMD.CLOAK] = true,
	[CMD.IDLEMODE] = true,
	[CMD.SET_WANTED_MAX_SPEED] = true,
	[CMD.SETBASE] = true,
	
	[CMD.INTERNAL] = true,
	[CMD.INSERT] = true,
	[CMD.REMOVE] = true,
	
	[CMD_ORBIT] = true,
	[CMD_ORBIT_DRAW] = true,
	[CMD_RAW_MOVE] = true,
}

_G.unlockedCMDs = unlockedCMDs
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function SetCMDEnabled(unitID, cmdID, enabled)
	local cmdDescID = Spring.FindUnitCmdDesc(unitID, cmdID)
	if (cmdDescID) then
		local cmdArray = {disabled = not enabled}
		Spring.EditUnitCmdDesc(unitID, cmdDescID, cmdArray)
	end
end

local function UnlockCMD(cmdID)
	unlockedCMDs[cmdID] = true
	local units = Spring.GetTeamUnits(0)
	for i=1,#units do
		SetCMDEnabled(units[i], cmdID, true)	
	end
end

local function LockCMD(cmdID)
	unlockedCMDs[cmdID] = nil
	local units = Spring.GetTeamUnits(0)
	for i=1,#units do
		SetCMDEnabled(units[i], cmdID, false)	
	end
end

-- right now we don't check if something else disabled/enabled the command before modifying it
-- this isn't a problem right now, but we may want it to be more robust
local function SetCMDs(unitID)
	local cmds = Spring.GetUnitCmdDescs(unitID)
	for i=1,#cmds do
		local cmdData = cmds[i]
		local cmdID = cmdData.id
		if cmdID > 0 then
			SetCMDEnabled(unitID, cmdID, unlockedCMDs[cmdID] and true or false)
		end
	end
end

local function ResetUnits(cmdID)
	local units = Spring.GetTeamUnits(0)
	for i=1,#units do
		SetCMDs(units[i])
	end
end

local function ProcessAllUnits()
	local units = Spring.GetAllUnits()
	for i=1,#units do
		local unitTeam = Spring.GetUnitTeam(units[i])
		gadget:UnitCreated(units[i], nil, unitTeam)
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:UnitCreated(unitID, unitDefID, team)
	if team == 0 then SetCMDs(unitID) end
end

function gadget:AllowUnitTransfer(unitID, unitDefID, oldTeam, newTeam, capture)
	gadget:UnitCreated(unitID, unitDefID, newTeam)
	return true
end

-- blocks command - prevent widget hax
function gadget:AllowCommand_GetWantedCommand()	
	return true
end

function gadget:AllowCommand_GetWantedUnitDefID()	
	return true
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOpts, cmdTag, synced)
	if (teamID ~= 0) then return true end
	if synced and ALLOW_SYNCED then return true end	-- note: right-click default command with 1 unit selected is issued as both synced and unsynced
	
	if cmdID == CMD.INSERT then
		cmdID = cmdParams[2]
	end
	
	if cmdID > 0 and not unlockedCMDs[cmdID] then
		if #cmdParams >= 3 then
			SendToUnsynced("mission_CommandBlocked", cmdID, cmdParams[1], cmdParams[2], cmdParams[3], cmdParams[4])
		else
			if #cmdParams == 1 then unitID = cmdParams[1] end
			local x, y, z = Spring.GetUnitPosition(unitID)
			if x and y and z then
				SendToUnsynced("mission_CommandBlocked", cmdID, x, y, z)
			end
		end
		return false
	end
	return true
end

function gadget:Initialize()
	GG.CommandLocker = {
		LockCMD = LockCMD,
		UnlockCMD = UnlockCMD
	}
	ProcessAllUnits()
end

function gadget:Load(zip)
	if not GG.SaveLoad then
		Spring.Log(gadget:GetInfo().name, LOG.ERROR, "Start Unit Setup failed to access save/load API")
		return
	end
	local data = GG.SaveLoad.ReadFile(zip, gadget:GetInfo().name, SAVE_FILE)
	if data then
		unlockedCMDs = data.unlockedCMDs
	end
end

function gadget:Shutdown()
	GG.CommandLocker = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
-- unsynced
--------------------------------------------------------------------------------

local BLOCKED_ICON_SIZE = 16
local INIT_Y_OFFSET = 24

local phases = {
	{time = 0, offset = INIT_Y_OFFSET, alpha = 0.2},
	{time = 0.5, offset = 0, alpha = 0.8},
	{time = 1, offset = 24, alpha = 0}
}
local highestTime = phases[#phases].time

local blockedCommands = {}
local toRemove = {}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function CommandBlocked(_, cmdID, x, y, z, radius)
	blockedCommands[#blockedCommands + 1] = {
		id = cmdID,
		x = x,
		y = y + INIT_Y_OFFSET,
		z = z,
		radius = radius,
		offset = 0,
		time = 0,
		phase = 1,
		alpha = 0.2,
	}
end

local function UpdateBlockedCommands(deltaT)
	for i=1,#blockedCommands do
		local command = blockedCommands[i]
		command.time = command.time + deltaT
		local time = command.time
		if time >= highestTime then
			toRemove[#toRemove+1] = i
		else
			local previousPhase = math.floor(command.phase)
			local nextPhase = previousPhase + 1
			if time > phases[nextPhase].time then
				previousPhase = nextPhase
				nextPhase = nextPhase + 1
			end
			local nextPhaseDef = phases[nextPhase]
			local previousPhaseDef = phases[previousPhase]
			local nextTime = nextPhaseDef.time
			local previousTime = previousPhaseDef.time
			local timeDiff = nextTime - previousTime
			command.phase = previousPhase + (time - previousTime)/timeDiff
			local phaseProgress = command.phase%1
			
			local alphaDiff = nextPhaseDef.alpha - previousPhaseDef.alpha
			command.alpha = previousPhaseDef.alpha + alphaDiff*phaseProgress
			local offsetDiff = nextPhaseDef.offset - previousPhaseDef.offset
			command.offset = previousPhaseDef.offset + offsetDiff*phaseProgress
			
			--if command.targetID then
			--	if command.isFeature then
			--		local x, y, z = GetFeatureTopPos(command.targetID) 
			--		command.pos = x and {x, y, z} or command.pos
			--	else
			--		local x, y, z = GetUnitTopPos(command.targetID) 
			--		command.pos = x and {x, y, z} or command.pos
			--	end
			--end
		end
	end
	if #toRemove > 0 then	-- so we don't recreate the table unless we have to
		for i=1, #toRemove do
			table.remove(blockedCommands, toRemove[i])
		end
		toRemove = {}
	end
end

local function DrawBlockedCommands()
	gl.DepthTest(true)
	gl.Texture("LuaUI/Images/dynamic_comm_menu/cross.png")
	for i=1,#blockedCommands do
		local command = blockedCommands[i]
		if command.time < highestTime and command.alpha > 0 then
			local x, y, z = command.x, command.y, command.z
			y = y + command.offset
			gl.PushMatrix()
			--if command.radius then
			--	gl.DrawGroundCircle(x, y, z, command.radius, 32)
			--end
			gl.Color(1,1,1,command.alpha)
			x, y, z = Spring.WorldToScreenCoords(x, y, z)
			gl.Translate(x, y, z)
			--gl.Billboard()	-- not needed in DrawScreen
			--gl.Rotate(180, 0, 0, 1)
			gl.TexRect(-BLOCKED_ICON_SIZE, -BLOCKED_ICON_SIZE, BLOCKED_ICON_SIZE, BLOCKED_ICON_SIZE)
			gl.PopMatrix()
		end
	end

	gl.Color(1,1,1,1)
	gl.Texture(false)
	gl.DepthTest(false)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local timer = Spring.GetTimer()
function gadget:Update()
	local currTimer = Spring.GetTimer()
	local dt = Spring.DiffTimers(currTimer, timer)
	timer = currTimer
	UpdateBlockedCommands(dt)
end

function gadget:Save(zip)
	if not GG.SaveLoad then
		Spring.Log(gadget:GetInfo().name, LOG.ERROR, "Start Unit Setup failed to access save/load API")
		return
	end
	local toSave = {
		unlockedCMDs = SYNCED.unlockedCMDs
	}
	GG.SaveLoad.WriteSaveData(zip, SAVE_FILE, toSave)
end

function gadget:DrawScreen()
	DrawBlockedCommands()
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("mission_CommandBlocked", CommandBlocked)
end

function gadget:Shutdown()
	gadgetHandler.RemoveSyncAction("mission_CommandBlocked")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

end