--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Block Load Onto",
    desc      = "No rides allowed!",
    author    = "KingRaptor",
    date      = "2015.09.09",
    license   = "Public Domain",
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
function gadget:AllowCommand_GetWantedCommand()	
	return {[CMD.LOAD_ONTO] = true}
end
	
function gadget:AllowCommand_GetWantedUnitDefID()	
	return true
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	--GG.UnitEcho(unitID, cmdID)
	if cmdID == CMD.LOAD_ONTO then
		return false
	end
	return true
end

--------------------------------------------------------------------------------