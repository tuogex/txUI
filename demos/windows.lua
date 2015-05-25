os.loadAPI("txUI")
txUI.UIManager.spaceColor = colors.lightBlue
local w, h = term.getSize()
local window = txUI.Window:new({w = w - 5; h = h - 5; draggable = true; hasShadow = true; bgColor = colors.white; tlColor = colors.blue; shadowColor = colors.gray;})
txUI.UIManager:addWindow(window)
txUI.UIManager:setVisibleWindow(window)
window:setTitleLabel(txUI.Label:new({text = "txUI Window"; bgColor = window.tlColor; textColor = colors.white; w = window.w; x = window.x; textAlign = "right";}))

window:addComponent(txUI.Button:new({x = 1; y = 1; w = 1; h = 1; action = (function(self) txUI.UIManager:exit(); end); textColor = colors.red; bgColor = window.tlColor; text = "X";}))
window:addComponent(txUI.Label:new({x = 1; y = 7; w = window.w; text = "txUI Windows!"; textColor = colors.lightGray;}))

txUI.UIManager:startUpdateCycle()
