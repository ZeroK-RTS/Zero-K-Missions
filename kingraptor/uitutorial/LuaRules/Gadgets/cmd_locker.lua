if (not gadgetHandler:IsSyncedCode()) then
	return
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Automatically generated local definitions

local spCallCOBScript        = Spring.CallCOBScript
local spGetLocalTeamID       = Spring.GetLocalTeamID
local spGetTeamList          = Spring.GetTeamList
local spGetTeamUnits         = Spring.GetTeamUnits
local spSetUnitCOBValue      = Spring.SetUnitCOBValue
local spGetUnitDefID         = Spring.GetUnitDefID
local spGetUnitTeam		     = Spring.GetUnitTeam
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name = "Command Locker",
		desc = "",
		author = "KDR_11k (David Becker)",
		date = "2008-03-04",
		license = "Public Domain",
		layer = 999,
		enabled = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

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
	[CMD.MOVE_STATE] = true,
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
}


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
	return unlockUnitsMap
end

function gadget:AllowCommand_GetWantedUnitDefID()	
	return true
end

function gadget:AllowCommand(unitID, unitDefID, team, cmdID, cmdParams, cmdOpts, synced)
	if synced or (teamID ~= 0) then return true end
	if cmdID > 0 and not unlockedCMDs[-cmdID] then
		return false
	end
	return true
end

function gadget:Initialize()
	GG.CommandLocker = {
		UnlockCMD = UnlockCMD
	}
end

function gadget:Shutdown()
	GG.CommandLocker = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------