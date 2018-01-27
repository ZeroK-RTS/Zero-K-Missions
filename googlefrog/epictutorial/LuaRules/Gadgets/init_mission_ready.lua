include("LuaRules/Gadgets/init_auto_ready.lua")
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
  return {
    name      = "Mission Ready",
    desc      = "Ready screen for missons",
    author    = "Licho",
    date      = "15.4.2012",
    license   = "Nobody can do anything except me, Microsoft and Apple! Thieves hands off",
    layer     = 0,
    enabled   = true
  }
end