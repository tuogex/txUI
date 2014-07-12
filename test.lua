os.loadAPI("txUI.lua")
local w, h = term.getSize()
local window = txUI.Window:new({w = w; h = h;})
local windowb = txUI.Window:new({w = w; h = h;})
windowb:setTitleLabel(txUI.Label:new({text = "txUI Window2"; bgColor = window.tlColor; textColor = colors.white; w = window.w; x = window.x; textAlign = "right";}))
txUI.UIManager:addWindow(window)
txUI.UIManager:setVisibleWindow(window)
txUI.UIManager:addWindow(windowb)
window:setTitleLabel(txUI.Label:new({text = "txUI Window"; bgColor = window.tlColor; textColor = colors.white; w = window.w; x = window.x; textAlign = "right";}))
window:addComponent(txUI.Label:new({x = 4; y = 10; bgColor = window.bgColor;}))
	
local textField = txUI.TextField:new({x = 33; y = 10;})
window:addComponent(textField)

window:addComponent(txUI.Label:new({x = 33; y = 12; bgColor = window.bgColor; textAlign = "right"; update = (function(self) self.text = textField.text end);}))
	
local list = txUI.List:new({x = 33; y = 14;})
window:addComponent(list)
list:addComponent(txUI.Button:new({}))
list:addComponent(txUI.Button:new({text = "2"; action = setWindow;}))
list:addComponent(txUI.Button:new({text = "3";}))
list:addComponent(txUI.Button:new({text = "4";}))
list:addComponent(txUI.Button:new({text = "5";}))
list:addComponent(txUI.Button:new({text = "exit"; action = (function(self) self.parent.parent:close(); windowb.visible = true; end);}))
	
local list2 = txUI.List:new({x = 33; y = 3;})
window:addComponent(list2)
list2:addComponent(txUI.Button:new())
list2:addComponent(txUI.Button:new({text = "2"; action = setWindow;}))
list2:addComponent(txUI.Button:new({text = "3";}))
list2:addComponent(txUI.Button:new({text = "4";}))
list2:addComponent(txUI.Button:new({text = "5";}))
list2:addComponent(txUI.Button:new({text = "exit"; action = (function(self) self.parent.parent:close(); windowb.visible = true; end);}))

window:addComponent(txUI.Checkbox:new({x = 4; y = 5;}))
window:addComponent(txUI.Button:new({x = 4; y = 15;}))
window:addComponent(txUI.Button:new({x = 1; y = 1; w = 1; h = 1; action = (function(self) self.parent:close(); windowb.visible = true; end); textColor = colors.red; bgColor = window.tlColor; text = "X";}))
windowb:addComponent(txUI.Button:new({x = 1; y = 1; w = 1; h = 1; action = (function(self) self.parent:close(); windowb.visible = true; end); textColor = colors.red; bgColor = window.tlColor; text = "X";}))
txUI.UIManager.appUpdate = function(self) 
	if (textField.text == "close") then
		self:exit()
	end
end
txUI.UIManager:startUpdateCycle()