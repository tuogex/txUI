os.loadAPI("txUI.lua")
local w, h = term.getSize()
local loginWindow = txUI.Window:new({w = w; h = h;})
local contentWindow = txUI.Window:new({w = w; h = h;})

txUI.UIManager:addWindow(loginWindow)
loginWindow.onView = function(self)
	self:setTitleLabel(txUI.Label:new({text = "txUI Windows Demo"; bgColor = self.tlColor; textColor = colors.white; w = self.w; x = self.x; textAlign = "right";}))
	self:addComponent(txUI.Button:new({x = 1; y = 1; w = 1; h = 1; action = (function(self) txUI.UIManager:terminate() end); textColor = colors.red; bgColor = self.tlColor; text = "X";}))
	self:addComponent(txUI.Label:new({x = 1; y = 5; w = w; text = "Login to txUI"; bgColor = colors.lightGray;}))
	self:addComponent(txUI.Label:new({x = 4; y = 8; text = "Username"; textAlign = "left"; bgColor = colors.lightGray;}))
	self:addComponent(txUI.TextField:new({x = 33; y = 8; placeholder = "Username";}))
	self:addComponent(txUI.Label:new({x = 4; y = 10; text = "Password"; textAlign = "left"; bgColor = colors.lightGray;}))
	self:addComponent(txUI.TextField:new({x = 33; y = 10; placeholder = "Password"; textMask = "*";}))
	self:addComponent(txUI.Checkbox:new({x = 4; y = 12; text = "Remember me";}))
	self:addComponent(txUI.Button:new({x = 33; y = 14; text = "Login"; action = (function(self) txUI.UIManager:setVisibleWindow(contentWindow) end);}))
end
loginWindow.onHide = function(self)
	self.components = {}
	self.titleLabel = {}
end
txUI.UIManager:setVisibleWindow(loginWindow)

txUI.UIManager:addWindow(contentWindow)
contentWindow.onView = function(self)
	self:setTitleLabel(txUI.Label:new({text = "txUI Windows Demo"; bgColor = self.tlColor; textColor = colors.white; w = self.w; x = self.x; textAlign = "right";}))
	self:addComponent(txUI.Button:new({x = 1; y = 1; w = 8; h = 1; action = (function(self) txUI.UIManager:setVisibleWindow(loginWindow) end); textColor = colors.white; bgColor = self.tlColor; text = "< Logout";}))
	local list = txUI.List:new({x = 1; y = 2; w = w; h = h - 1;});
	self:addComponent(list)
	for i = 1,21,1 do
		list:addComponent(txUI.Label:new({text = i;}))
	end
end
contentWindow.onHide = function(self)
	self.components = {}
	self.titleLabel = {}
end

txUI.UIManager:startUpdateCycle()