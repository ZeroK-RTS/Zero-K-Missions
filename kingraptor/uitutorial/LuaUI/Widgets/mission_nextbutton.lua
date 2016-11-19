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

function widget:Initialize()
  Chili = WG.Chili
  window = Chili.Window:New {
    parent = Chili.Screen0,
    right = 0,
    bottom = 128,
    height = 64,
    width = 96,
    color = {0,0,0,0},
    caption = "",
    padding = {0,0,0,0},
    draggable = false,
    resizable = false,
    tweakResizable = false
  }
  button = Chili.Button:New {
    parent = window,
    width = "100%",
    height = "100%",
    caption = "Next",
    font = {size = 16},
    OnClick = { function(self, x, y, mouse)
        if mouse == 1 then
          Spring.SendLuaRulesMsg("uitutorial_next")
        end
      end
    },
  }
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------