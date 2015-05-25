os.loadAPI("txUI")
txUI.Controller.spaceColor = colors.lightBlue
local w, h = term.getSize()
local window = txUI.Window:new({w = w - 5; h = h - 5; draggable = true; hasShadow = true; bgColor = colors.white; tlColor = colors.blue; shadowColor = colors.gray;})
txUI.Controller:addWindow(window)
txUI.Controller:setVisibleWindow(window)
window:setTitleLabel(txUI.Label:new({text = "txUI Window"; bgColor = window.tlColor; textColor = colors.white; w = window.w; x = window.x; textAlign = "right";}))

window:addComponent(txUI.Button:new({x = 1; y = 1; w = 1; h = 1; action = (function(self) txUI.Controller:exit(); end); textColor = colors.red; bgColor = window.tlColor; text = "X";}))
txUI.Controller:addComponent(txUI.Label:new({x = 1; y = 9; w = w; text = "txUI Windows!"; textColor = colors.white; bgColor = colors.lightBlue;}))

txUI.Controller:startUpdateCycle()
