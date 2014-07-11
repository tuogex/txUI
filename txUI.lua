-- --
-- txUI - ComputerCraft User Interface Library
-- dev
-- tuogex
-- --

-- --
-- UIManager @static
-- Holds the windows of the program and handles events
-- --
UIManager = {}
UIManager.prototype = {
	--vars
	windows = {};
	--functions
	drawAll = function(self)
		for key, val in pairs(self.windows) do
			if (val.visible) then
				val:draw()
			end
		end
	end;
	appUpdate = function(self) end;
	startUpdateCycle = function(self)
		local handleEvent = function()
			local event = {os.pullEventRaw()}
			if (event[1] == "terminate") then
				self:terminate()
			elseif (event[1] == "mouse_click" or event[1] == "monitor_touch") then
				for key, val in pairs(self.windows) do
					if (val.visible and val:click(event[3], event[4], event[2])) then
						break
					end
				end
			elseif (event[1] == "mouse_scroll") then
				for key, val in pairs(self.windows) do
					if (val.visible and val:scroll(event[2])) then
						break
					end
				end
			elseif (event[1] == "mouse_drag") then
				for key, val in pairs(self.windows) do
					if (val.visible and val:drag(event[3], event[4], event[2])) then
						break
					end
				end
			elseif (event[1] == "char") then
				for key, val in pairs(self.windows) do
					if (val.visible and val:char(event[2])) then
						break
					end
				end
			elseif (event[1] == "key") then
				for key, val in pairs(self.windows) do
					if (val.visible and val:key(event[2])) then
						break
					end
				end
			end
		end
		while (true) do
			if (#self.windows == 0) then
				self:exit()
			end
			self:drawAll()
			for key, val in pairs(self.windows) do
				if (val.visible) then
					val:update()
				end
			end
			handleEvent()
			self:appUpdate();
			--close windows marked for close
			local closed = {}
			for key, val in pairs(self.windows) do
				if (val.closed) then
					table.insert(closed, key)
				end
			end
			for key, val in pairs(closed) do
				table.remove(self.windows, val)
			end
		end
	end;
	addWindow = function(self, windowTbl)
		table.insert(self.windows, windowTbl)
	end;
	closeWindow = function(self, windowTbl)
		for key, val in pairs(self.windows) do
			if (val == windowTbl) then
				val.closed = true
			end
		end
	end;
	terminate = function(self)
		self:exit()
	end;
	exit = function(self)
		term.setBackgroundColor(colors.black)
		term.clear()
		term.setCursorPos(1, 1)
		error()
	end;
}
UIManager.mt = {
	__index = function (table, key)
		return UIManager.prototype[key]
	end;
}
setmetatable(UIManager, UIManager.mt)

-- --
-- DrawUtils @static
-- Utilities to aid in drawing
-- --
DrawUtils = {}
DrawUtils.prototype = {
	drawRect = function(self, x, y, w, h, color)
		term.setBackgroundColor(color)
		for pY = y, h - 1 + y, 1 do
			term.setCursorPos(x, pY)
			for pX = x, w - 1 + x, 1 do
				term.write(" ")
			end
		end
	end;
	alignText = function(self, alignment, textLength, x, w)
		if (alignment == "left") then
			return x
		elseif (alignment == "center") then
			return x + ((w - textLength) / 2)
		elseif (alignment == "right") then
			return x + (w - textLength)
		end
	end;
}
DrawUtils.mt = {
	__index = function(table, key)
		return DrawUtils.prototype[key]
	end;
}
setmetatable(DrawUtils, DrawUtils.mt)

-- --
-- Window
-- Pretty self explainatory
-- --
Window = {}
Window.prototype = {
	-- vars
	bgColor = colors.lightGray;
	tlColor = colors.gray;
	components = {};
	titleLabel = {};
	z = 0;
	x = 1;
	y = 1;
	h = 1;
	w = 1;
	visible = true;
	closed = false;
	--functions
	draw = function(self) 
		--drawPane
		DrawUtils:drawRect(self.x, self.y, self.w, self.h, self.bgColor)
		--drawTitle
		term.setBackgroundColor(self.tlColor)
		term.setCursorPos(self.x, self.y)
		for pX = self.x, self.w + self.x, 1 do
			term.write(" ")
		end
		if (self.titleLabel ~= nil) then
			self.titleLabel:draw()
		end
		--draw components
		self:drawComponents()
	end;
	drawComponents = function(self)
		for key, val in pairs(self.components) do
			val:draw()
		end
	end;
	setTitleLabel = function(self, newLabel)
		newLabel.parent = self
		self.titleLabel = newLabel
	end;
	addComponent = function(self, componentTbl)
		componentTbl.parent = self
		table.insert(self.components, componentTbl)
	end;
	removeComponent = function(self, componentTbl)
		for key, val in pairs(self.components) do
			if (val == componentTbl) then
				val.removed = true
			end
		end
	end;
	close = function(self)
		UIManager:closeWindow(self)
	end;
	click = function(self, x, y)
		for key, val in pairs(self.components) do
			if (val:click(x, y)) then
				break
			end
		end
	end;
	key = function(self, keyCode)
		for key, val in pairs(self.components) do
			if (val:key(keyCode)) then
				break
			end
		end
	end;
	char = function(self, char)
		for key, val in pairs(self.components) do
			if (val:char(char)) then
				break
			end
		end
	end;
	scroll = function(self, direction)
		for key, val in pairs(self.components) do
			if (val:scroll(direction)) then
				break
			end
		end
	end;
	drag = function(self, x, y)
		for key, val in pairs(self.components) do
			if (val:drag(x, y)) then
				break
			end
		end
	end;
	update = function(self)
		local removed = {}
		for key, val in pairs(self.components) do
			if (val.removed) then
				table.insert(removed, key)
			else
				val:update()
			end
		end
		for key, val in pairs(removed) do
			table.remove(self.components, val)
		end
	end;
}
Window.mt = {
	__index = function (table, key) 
		return Window.prototype[key]
	end;
}
function Window:new(windowTbl)
	setmetatable(windowTbl, Window.mt)
	return windowTbl;
end

-- --
-- Component @abstract
-- Abstract class used to represent components in a window
-- --
Component = {}
Component.prototype = {
	--vars
	x = 1;
	y = 1;
	h = 1;
	w = 1;
	z = 0;
	parent = {};
	removed = false;
	--functions
	draw = function(self) end;
	click = function(self, x, y, button) return false end;
	key = function(self, keyCode) return false end;
	char = function(self, char) return false end;
	scroll = function(self, direction) return false end;
	drag = function(self, x, y, button) return false end;
	update = function(self) return false end;
}

-- --
-- Button extends Component
-- A component that you can click
-- --
Button = {}
Button.prototype = {
	--vars
	h = 3;
	w = 16;
	color = colors.lightBlue;
	textColor = colors.white;
	activeColor = colors.blue;
	activeTextColor = colors.white;
	active = false;
	text = "txUI Button";
	textAlign = "center";
	--functions
	action = function(self) end;
	draw = function(self)
		DrawUtils:drawRect(self.x + self.parent.x - 1, self.y + self.parent.y - 1, self.w, self.h, (function(self) if (self.active) then return self.activeColor else return self.color end end)(self))
		term.setCursorPos(DrawUtils:alignText(self.textAlign, string.len(self.text), self.x + self.parent.x - 1, self.w), self.y + (self.h / 2))
		term.setTextColor((function(self) if (self.active) then return self.activeTextColor else return self.textColor end end)(self))
		term.write(self.text)
	end;
	click = function (self, x, y) 
		if ((x >= self.x) and (x <= (self.x + self.w - 1)) and (y >= self.y) and (y <= (self.y + self.h - 1))) then
			self.active = true
			self:action()
			return true
		else
			self.active = false
			return false
		end
	end;
	update = function(self) return false end;
}
Button.mt = {
	__index = function (table, key) 
		if (Button.prototype[key] ~= nil) then
			return Button.prototype[key]
		else
			return Component.prototype[key]
		end
	end;
}
function Button:new(buttonTbl)
	if (buttonTbl == nil) then
		buttonTbl = self
	end
	setmetatable(buttonTbl, Button.mt)
	return buttonTbl
end

-- --
-- Label extends Component
-- A component that displays text
-- --
Label = {}
Label.prototype = {
	--vars
	h = 1;
	w = 16;
	bgColor = colors.white;
	textColor = colors.black;
	text = "txUI Label";
	textAlign = "center";
	--functions
	draw = function(self)
		DrawUtils:drawRect(self.x + self.parent.x - 1, self.y + self.parent.y - 1, self.w, self.h, self.bgColor)
		term.setCursorPos(DrawUtils:alignText(self.textAlign, string.len(self.text), self.x + self.parent.x - 1, self.w), self.y + (self.h / 2))
		term.setBackgroundColor(self.bgColor)
		term.setTextColor(self.textColor)
		term.write(self.text)
	end;
	update = function(self) return false end;
}
Label.mt = {
	__index = function (table, key)
		if (Label.prototype[key] ~= nil) then
			return Label.prototype[key]
		else
			return Component.prototype[key]
		end
	end;
}
function Label:new(labelTbl)
	if (labelTbl == nil) then
		labelTbl = self
	end
	setmetatable(labelTbl, Label.mt)
	return labelTbl
end

-- --
-- TextField extends Component
-- A component that allows for text input
-- --
TextField = {}
TextField.prototype = {
	--vars
	h = 1;
	w = 16;
	bgColor = colors.white;
	textColor = colors.black;
	placeholderColor = colors.lightGray;
	placeholder = "txUI TextField";
	text = "";
	textAlign = "left";
	active = false;
	cursorPos = 0;
	displayOffset = 0;
	--functions
	draw = function(self)
		DrawUtils:drawRect(self.x + self.parent.x - 1, self.y + self.parent.y - 1, self.w, self.h, self.bgColor)
		term.setBackgroundColor(self.bgColor)
		if (self.active or string.len(self.text) ~= 0) then
			local toWrite = string.sub(self.text, self.displayOffset + 1, self.displayOffset + self.w)
			term.setCursorPos(DrawUtils:alignText(self.textAlign, string.len(toWrite), self.x + self.parent.x - 1, self.w), self.y + (self.h / 2))
			term.setTextColor(self.textColor)
			term.write(toWrite)
		else
			local toWrite = string.sub(self.placeholder, self.displayOffset + 1)
			term.setCursorPos(DrawUtils:alignText(self.textAlign, string.len(toWrite), self.x + self.parent.x - 1, self.w), self.y + (self.h / 2))
			term.setTextColor(self.placeholderColor)
			term.write(toWrite)
		end
		term.setCursorBlink(self.active)
		if (self.active) then
			term.setCursorPos(self.x + self.parent.x - 1 + self.cursorPos - self.displayOffset, self.y + (self.h / 2))
		end
	end;
	click = function (self, x, y) 
		if ((x >= self.x) and (x <= (self.x + self.w - 1)) and (y >= self.y) and (y <= (self.y + self.h - 1))) then
			self.active = true
			self:action()
			return true
		else
			self.active = false
			return false
		end
	end;
	action = function(self)
		self:draw()
	end;
	key = function(self, keyCode)
		if (self.active == false) then
			return
		end
		if (keyCode == keys.backspace) then
			if (self.cursorPos > 0) then
				self.text = string.sub(self.text, 1, self.cursorPos - 1) .. string.sub(self.text, self.cursorPos + 1)
				self.cursorPos = self.cursorPos - 1
				if (self.cursorPos - self.displayOffset < 0) then
					self.displayOffset = self.displayOffset - 1
				end
				self:draw()
			end
		elseif (keyCode == keys.left) then
			if (self.cursorPos > 0) then
				self.cursorPos = self.cursorPos - 1
				if (self.cursorPos - self.displayOffset < 0) then
					self.displayOffset = self.displayOffset - 1
				end
				self:draw()
			end
		elseif (keyCode == keys.right) then
			if (self.cursorPos < string.len(self.text)) then
				self.cursorPos = self.cursorPos + 1
				if (self.cursorPos - self.displayOffset > self.w - 1) then
					self.displayOffset = self.displayOffset + 1
				end
				self:draw()
			end
		end
		return true
	end;
	char = function(self, char)
		if (self.active == false) then
			return
		end
		self.text = string.sub(self.text, 1, self.cursorPos) .. char .. string.sub(self.text, self.cursorPos + 1)
		if (self.cursorPos - self.displayOffset > self.w - 2) then
			self.displayOffset = self.displayOffset + 1
		end
		self.cursorPos = self.cursorPos + 1
		return true
	end;
	update = function(self)
		if (self.active) then
			self:draw()
		end
	end;
}
TextField.mt = {
	__index = function (table, key)
		if (TextField.prototype[key] ~= nil) then
			return TextField.prototype[key]
		else
			return Component.prototype[key]
		end
	end;
}
function TextField:new(textFieldTbl)
	if (textFieldTbl == nil) then
		textFieldTbl = self
	end
	setmetatable(textFieldTbl, TextField.mt)
	return textFieldTbl
end