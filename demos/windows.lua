os.loadAPI("txUI")
txUI.Controller.spaceColor = colors.lightBlue
txUI.Controller.multiWindow = true
local w, h = term.getSize()
local window = txUI.Window:new({w = w - 5; h = h - 5; draggable = true; hasShadow = true; bgColor = colors.white; tlColor = colors.lightGray; shadowColor = colors.gray;})
txUI.Controller:addWindow(window)
window:addComponent(txUI.Button:new({x = 1; y = 1; w = 1; h = 1; action = (function(self) txUI.Controller:closeWindow(self.parent); end); textColor = colors.white; bgColor = window.tlColor; text = "x";}))
txUI.Controller:addComponent(txUI.Label:new({x = 1; y = 9; w = w; text = "txUI Windows!"; textColor = colors.white; bgColor = colors.lightBlue;}))
txUI.Controller:addWindow(txUI.Controller:cloneComponent(window))
txUI.Controller:startUpdateCycle()
