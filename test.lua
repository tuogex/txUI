os.loadAPI("txUI.lua")
local w, h = term.getSize()
local window = txUI.Window:new({w = w; h = h;})
local winIndex = txUI.UIManager:addWindow(window)
window:setTitleLabel(txUI.Label:new({text = "txUI Window"; bgColor = window.tlColor; textColor = colors.white; w = window.w; x = window.x; textAlign = "right";}))
window:addComponent(txUI.Label:new({x = 4; y = 10; bgColor = window.bgColor;}))
local textField = txUI.TextField:new({x = 33; y = 10;})
window:addComponent(textField)
window:addComponent(txUI.Label:new({x = 33; y = 12; bgColor = window.bgColor; textAlign = "right"; update = (function(self) self.text = textField.text end);}))
window:addComponent(txUI.Button:new({x = 33; y = 15; text = "Toggle Visible"; action = (function(self) self.parent.visible = false end);}))
window:addComponent(txUI.Button:new({x = 4; y = 15;}))
window:addComponent(txUI.Button:new({x = 1; y = 1; w = 1; h = 1; action = (function(self) self.parent:close() end); textColor = colors.red; color = window.tlColor; text = "X";}))
txUI.UIManager.appUpdate = function(self) 
	if (textField.text == "close") then
		self:exit()
	end
end
txUI.UIManager:startUpdateCycle()