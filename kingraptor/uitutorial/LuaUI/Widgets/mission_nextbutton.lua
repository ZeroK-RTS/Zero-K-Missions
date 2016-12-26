--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "Next Button",
    desc      = "Click to continue",
    author    = "quantum",
    date      = "October 2010",
    license   = "GNU GPL, v2 or later",
    layer     = 1, 
    enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local Chili
local window
local button

local locked = false
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:Update(dt)
  if not button then
    return
  end
  if Spring.GetGameRulesParam("uitutorial_show_next_button") == 1 then
    if not button.visible then
      button:Show()
    end
  else
    if button.visible then
      button:Hide()
    end
  end
end

function widget:GameFrame(f)
  locked = false
end

function widget:Initialize()
  local vsx, vsy = Spring.GetWindowGeometry()
  Chili = WG.Chili
  window = Chili.Window:New {
    name = "uitutorial_nextButtonWindow",
    parent = Chili.Screen0,
    right = 0,
    y = 50 + vsy * 0.20 + 64 + (240 + 24),	-- put it under proconsole, objectives button and persistent message window
    height = 48,
    width = 80,
    color = {0,0,0,0},
    caption = "",
    padding = {0,0,0,0},
    dockable = true,
    dockableSavePositionOnly = true,
    draggable = false,
    resizable = false,
    tweakDraggable = true,
    tweakResizable = true
  }
  button = Chili.Button:New {
    parent = window,
    width = "100%",
    height = "100%",
    caption = "Next",
    font = {size = 16},
    OnClick = { function(self, x, y, mouse)
        if mouse == 1 and not locked then
          Spring.SendLuaRulesMsg("uitutorial_next")
          locked = true -- only allow one click per gameframe, so it doesn't super increment when paused
        end
      end
    },
  }
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------