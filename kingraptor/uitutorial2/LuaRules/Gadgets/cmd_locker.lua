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
--------------------------------------------------------------------------------
-- synced
VFS.Include("LuaRules/Configs/customcmds.h.lua")

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
	if cmdID > 0 and not unlockedCMDs[cmdID] then
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
--------------------------------------------------------------------------------
-- unsynced

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

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

end