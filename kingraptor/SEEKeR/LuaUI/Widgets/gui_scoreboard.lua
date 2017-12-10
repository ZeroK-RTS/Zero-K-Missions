function widget:GetInfo()
  return {
    name      = "Scoreboard",
    desc      = "bla",
    author    = "KingRaptor (L.J. Lim)",
    date      = "2014.05.03",
    license   = "Public Domain",
    layer     = 0,
    enabled   = true,
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local Chili
local Label

local scoreLabels = {}

local function DisplayStats()
  Chili = WG.Chili
  Label = Chili.Label
  
  local vsx,vsy = Spring.GetWindowGeometry()
  
  local window = Chili.Window:New{
    parent = Chili.Screen0,
    name   = 'gamestats_window';
    classname = 'main_window_small_tall';
    width  = 200;
    height = 240;
    right  = 0;
    y = vsy/2 - 110;
    draggable = true,
    resizable = false,
    tweakResizable = false,
    padding = {0, 0, 0, 0},
    itemMargin  = {0, 0, 0, 0},
  }
  --local subpanel = Chili.Panel:New{
  --  parent = panel,
  --  y = "10%",
  --  width = "100%",
  --  height = "90%",
  --}
  
  local topbar = Chili.StackPanel:New{
    parent = window,
    orientation = "horizontal",
    x = 0,
    y = 8,
    width = '100%',
    height = "10%",
    padding = {0, 0, 0, 0},
    itemMargin  = {0, 0, 0, 0},
  }
  
  local title = Label:New{
    parent = topbar, caption = "Score", align="right", fontSize = 16, fontShadow = true,
  }
  scoreLabels["current"] = Label:New{
    parent = topbar, caption = "0", align="center", fontSize = 14, fontShadow = true
  }
  
  local grid = Chili.Grid:New{
    parent = window,
    rows = 8,
    columns = 2,
    y = "10%",
    width = '100%',
    bottom = 4,
  }
  
  for i=1,8 do
    local round = i
    local caption = "Round " .. round
    if i == 4 then
      round = -1
      caption = "Miniboss"
    elseif i == 8 then
      round = -2
      caption = "Boss"
    elseif i > 3 then
      round = round - 1
      caption = "Round " .. round
    end
    Label:New{ parent = grid, caption = caption, y = 0, align="center", fontSize = 13, fontShadow = true }
    scoreLabels[round] = Label:New{ parent = grid, caption = "", y = 0, align="center", fontSize = 13, fontShadow = true }    
  end
end

function RallyRoundComplete(round, score)
  scoreLabels[round]:SetCaption(score)
end

function RallyUpdateScore(score)
  scoreLabels["current"]:SetCaption(score)
end

function widget:Initialize()
  widgetHandler:RegisterGlobal("RallyRoundComplete", RallyRoundComplete)
  widgetHandler:RegisterGlobal("RallyUpdateScore", RallyUpdateScore)
  DisplayStats()
end

function widget:Shutdown()
  widgetHandler:DeregisterGlobal("RallyRoundComplete")
  widgetHandler:DeregisterGlobal("RallyUpdateScore")
end