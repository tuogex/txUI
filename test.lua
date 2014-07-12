os.loadAPI("txUI.lua")
local w, h = term.getSize()
local window = txUI.Window:new({w = w; h = h;})
local winIndex = txUI.UIManager:addWindow(window)
window:setTitleLabel(txUI.Label:new({text = "txUI Window"; bgColor = window.tlColor; textColor = colors.white; w = window.w; x = window.x; textAlign = "right";}))
window:addComponent(txUI.Label:new({x = 4; y = 10; bgColor = window.bgColor;}))
	
local textField = txUI.TextField:new({x = 33; y = 10;})
window:addComponent(textField)

window:addComponent(txUI.Label:new({x = 33; y = 12; bgColor = window.bgColor; textAlign = "right"; update = (function(self) self.text = textField.text end);}))
	
local list = txUI.List:new({x = 33; y = 14;})
window:addComponent(list)
list:addComponent(txUI.Button:new())
list:addComponent(txUI.Button:new({text = "2";}))
list:addComponent(txUI.Button:new({text = "3";}))
list:addComponent(txUI.Button:new({text = "4";}))
list:addComponent(txUI.Button:new({text = "5";}))
list:addComponent(txUI.Button:new({text = "exit"; action = (function(self) self.parent.parent:close() end);}))

window:addComponent(txUI.Checkbox:new({x = 4; y = 5;}))
window:addComponent(txUI.Button:new({x = 4; y = 15;}))
window:addComponent(txUI.Button:new({x = 1; y = 1; w = 1; h = 1; action = (function(self) self.parent:close() end); textColor = colors.red; bgColor = window.tlColor; text = "X";}))
txUI.UIManager.appUpdate = function(self) 
	if (textField.text == "close") then
		self:exit()
	end
end
txUI.UIManager:startUpdateCycle()