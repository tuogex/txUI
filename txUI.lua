-- --
-- txUI - ComputerCraft User Interface Library
-- rel
-- tuogex
-- --

-- --
-- Controller @static
-- Holds the windows of the program and handles events
-- --
Controller = {}
Controller.prototype = {
	--vars
	components = {};
	windows = {};
	termSize = {};
	spaceColor = colors.white;
	style = {};
	useNative = true;
	multiWindow = false;
	oldTerm = {};
	--functions
	drawAll = function(self)
		local w, h = term.getSize()
		Utils:drawRect(1, 1, w, h, self.spaceColor)
		for key, val in pairs(self.components) do
			if (val.visible) then
				val:draw()
			end
		end
		local drawQueue = {}
		for key, val in pairs(self.windows) do
			if (val.visible) then
				table.insert(drawQueue, 1, val)
			end
		end
		for key, val in pairs(drawQueue) do
			val:draw()
		end
	end;
	appUpdate = function(self, eventTbl) end;
	startUpdateCycle = function(self)
		Controller.termSize = term.getSize()
		if (self.useNative) then
			Controller.oldTerm = term.current()
			term.redirect(term.native())
		end
		local handleEvent = function()
			local event
			repeat
				event = {os.pullEventRaw()}
			until(event[1] ~= "timer")
			if (event[1] == "terminate") then
				self:terminate()
			elseif (event[1] == "mouse_click" or event[1] == "monitor_touch") then
				for key, val in pairs(self.components) do
					if (val.visible and val:click(event[3], event[4], event[2])) then
						break
					end
				end
				for key, val in pairs(self.windows) do
					if (val.visible and Utils:inBounds(val.x, val.y, val.w, val.h, event[3], event[4]) and self.windows[1] ~= val) then
						table.remove(self.windows, key)
						table.insert(self.windows, 1, val)
					elseif (val.visible and Utils:inBounds(val.x, val.y, val.w, val.h, event[3], event[4]) and self.windows[1] == val) then
						break
					end
				end
				for key, val in pairs(self.windows) do
					if (val.visible and Utils:inBounds(val.x, val.y, val.w, val.h, event[3], event[4]) and val:click(event[3], event[4], event[2])) then
						break
					end
				end
			elseif (event[1] == "mouse_scroll") then
				for key, val in pairs(self.components) do
					if (val.visible and val:scroll(event[2])) then
						break
					end
				end
				for key, val in pairs(self.windows) do
					if (val.visible and val:scroll(event[2])) then
						break
					end
				end
			elseif (event[1] == "mouse_drag") then
				for key, val in pairs(self.components) do
					if (val.visible and val:drag(event[3], event[4], event[2])) then
						break
					end
				end
				for key, val in pairs(self.windows) do
					if (val.visible and val:drag(event[3], event[4], event[2])) then
						break
					end
				end
			elseif (event[1] == "char") then
				for key, val in pairs(self.components) do
					if (val.visible and val:char(event[2])) then
						break
					end
				end
				for key, val in pairs(self.windows) do
					if (val.visible and val:char(event[2])) then
						break
					end
				end
			elseif (event[1] == "key") then
				for key, val in pairs(self.components) do
					if (val.visible and val:key(event[2])) then
						break
					end
				end
				for key, val in pairs(self.windows) do
					if (val.visible and val:key(event[2])) then
						break
					end
				end
			else
				for key, val in pairs(self.components) do
					if (val.visible and val:event(event)) then
						break
					end
				end
				for key, val in pairs(self.windows) do
					if (val.visible and val:event(event)) then
						break
					end
				end
			end
			return event
		end
		while (true) do
			if (#self.windows == 0 and #self.components == 0) then
				self:exit()
			end
			self:drawAll()
			for key, val in pairs(self.components) do
				if (val.visible) then
					val:update()
				end
			end
			for key, val in pairs(self.windows) do
				if (val.visible) then
					val:update()
				end
			end
			local eventTbl = handleEvent()
			self:appUpdate(eventTbl);
			--remove components marked for removal
			local removed = {}
			for key, val in pairs(self.components) do
				if (val.removed) then
					table.insert(removed, key)
				else
					val:update()
				end
			end
			for key, val in pairs(removed) do
				self.components[val] = nil
			end
			--close windows marked for close
			local closed = {}
			for key, val in pairs(self.windows) do
				if (val.closed) then
					table.insert(closed, key)
				end
			end
			for key, val in pairs(closed) do
				self.windows[val] = nil
			end
		end
	end;
	setVisibleWindow = function(self, windowTbl)
		for key, val in pairs(self.windows) do
			local wasVisible = val.visible
			val.visible = (tostring(val) == tostring(windowTbl) or self.multiWindow)
			if (not wasVisible and val.visible) then
				val:onView()
			end
			if (wasVisible and not val.visible) then
				val:onHide()
			end
		end
	end;
	addWindow = function(self, windowTbl)
		windowTbl.closed = false
		windowTbl.visible = self.multiWindow
		table.insert(self.windows, windowTbl)
		if (#self.windows == 1) then
			self:setVisibleWindow(windowTbl)
		end
	end;
	closeWindow = function(self, windowTbl)
		for key, val in pairs(self.windows) do
			if (val == windowTbl) then
				val.closed = true
			end
		end
	end;
	addComponent = function(self, componentTbl)
		componentTbl.parent = self
		componentTbl.parent.x = 1
		componentTbl.parent.y = 1
		componentTbl.parent.w = self.termSize[1]
		componentTbl.parent.h = self.termSize[2]
		componentTbl.removed = false
		table.insert(self.components, componentTbl)
	end;
	removeComponent = function(self, componentTbl)
		for key, val in pairs(self.components) do
			if (val == componentTbl) then
				val.removed = true
			end
		end
	end;
	terminate = function(self)
		self:exit()
	end;
	exit = function(self)
		if (self.useNative) then
			term.redirect(self.oldTerm)
		end
		term.setBackgroundColor(colors.black)
		term.clear()
		term.setCursorPos(1, 1)
		error()
	end;
	cloneComponent = function(self, obj, copied)
		if type(obj) ~= 'table' then
			return obj
		end
		if copied and copied[obj] then
			return copied[obj]
		end
		local c = copied or {}
		local res = setmetatable({}, getmetatable(obj))
		c[obj] = res
		for k, v in pairs(obj) do
			res[self:cloneComponent(k, c)] = self:cloneComponent(v, c)
		end
		return res
	end;
	inheritComponent = function(self, obj, newTbl)
		local oldComponent = self:cloneComponent(obj)
		for k, v in pairs(newTbl) do
			oldComponent[k] = v
		end 
		return oldComponent
	end;
	setDefaultStyle = function(self, styleTbl)
		self.style = styleTbl
	end;
}
Controller.mt = {
	__index = function (table, key)
		return Controller.prototype[key]
	end;
}
setmetatable(Controller, Controller.mt)

-- --
-- Utils @static
-- Utilities to aid in UI design
-- --
Utils = {}
Utils.prototype = {
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
	limitText = function(self, text, limit, tail)
		if (string.len(text) > limit) then
			return string.sub(text, 0, limit - string.len(tail)) .. tail
		else
			return text
		end
	end;
	wrapText = function(self, text, limit)
		local index = 0
		return text:gsub("(%C?)", function (w)
			index = index + 1
			return w .. (index % limit == 0 and "\n" or "")
		end)
	end;
	splitText = function(self, str, pat)
		local t = {}
		local fpat = "(.-)" .. pat
		local last_end = 1
		local s, e, cap = str:find(fpat, 1)
		while s do
			if (s ~= 1 or cap ~= "") then
				table.insert(t,cap)
			end
			last_end = e + 1
			s, e, cap = str:find(fpat, last_end)
		end
		if (last_end <= #str) then
			cap = str:sub(last_end)
			table.insert(t, cap)
		end
		return t
	end;
	inBounds = function(self, boundX, boundY, boundW, boundH, checkX, checkY)
		local xInBound = (checkX >= boundX) and (checkX <= boundX + boundW - 1)
		local yInBound = (checkY >= boundY) and (checkY <= boundY + boundH - 1)
		return xInBound and yInBound
	end;
}
Utils.mt = {
	__index = function(table, key)
		return Utils.prototype[key]
	end;
}
setmetatable(Utils, Utils.mt)

-- --
-- Style
-- Contains default styles for components and windows
-- --
Style = {}
Style.prototype = {
	Window = {};
	Component = {};
	Panel = {};
	Button = {};
	Label = {};
	TextField = {};
	List = {};
	CheckBox = {};
	ProgressBar = {};
}
Style.mt = {
	__index = function (table, key)
		return Style.prototype[key]
	end;
}
function Style:new(styleTbl)
	setmetatable(styleTbl, Style.mt)
	return styleTbl
end

-- --
-- Window
-- Pretty self explainatory
-- --
Window = {}
Window.prototype = {
	-- vars
	bgColor = colors.lightGray;
	tlColor = colors.gray;
	activeTlColor = colors.blue;
	components = {};
	titleLabel = {};
	z = 0;
	x = 1;
	y = 1;
	h = 1;
	w = 1;
	draggable = false;
	lastClick = {};
	hasShadow = false;
	shadowColor = colors.black;
	visible = false;
	closed = false;
	--functions
	draw = function(self)
		--draw shadow
		if (self.hasShadow) then
			Utils:drawRect(self.x + 1, self.y + 1, self.w, self.h, self.shadowColor)
		end
		--drawPane
		Utils:drawRect(self.x, self.y, self.w, self.h, self.bgColor)
		--drawTitle
		term.setBackgroundColor(self:isActive() and self.activeTlColor or self.tlColor)
		term.setCursorPos(self.x, self.y)
		for pX = self.x, self.w + self.x - 1, 1 do
			term.write(" ")
		end
		if (#self.titleLabel ~= 0) then
			self.titleLabel:draw()
		end
		--draw components
		self:drawComponents()
	end;
	drawComponents = function(self)
		for key, val in pairs(self.components) do
			if (val.visible) then
				val:draw()
			end
		end
	end;
	setTitleLabel = function(self, newLabel)
		newLabel.parent = self
		setmetatable(newLabel, Label.tlmt)
		self.titleLabel = newLabel
	end;
	addComponent = function(self, componentTbl)
		componentTbl.parent = self
		componentTbl.removed = false
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
		Controller:closeWindow(self)
	end;
	click = function(self, x, y)
		if (self.draggable and ((x >= self.x) and (x <= (self.x + self.w - 1)) and (y >= self.y) and (y <= self.y))) then
			self.lastClick.x = x
			self.lastClick.y = y
		else
			self.lastClick.x = nil
			self.lastClick.y = nil
		end
		for key, val in pairs(self.components) do
			val:click(x, y)
		end
		return (self.draggable and ((x >= self.x) and (x <= (self.x + self.w - 1)) and (y >= self.y) and (y <= self.y)))
	end;
	key = function(self, keyCode)
		for key, val in pairs(self.components) do
			val:key(keyCode)
		end
	end;
	char = function(self, char)
		for key, val in pairs(self.components) do
			val:char(char)
		end
	end;
	scroll = function(self, direction)
		for key, val in pairs(self.components) do
			val:scroll(direction)
		end
	end;
	drag = function(self, x, y)
		if (self.draggable and self.lastClick.x ~= nil) then
			self.x = self.x + x - self.lastClick.x
			self.y = self.y + y - self.lastClick.y
			self.lastClick.x = x
			self.lastClick.y = y
		end
		for key, val in pairs(self.components) do
			val:drag(x, y)
		end
	end;
	event = function(self, eventTbl)
		for key, val in pairs(self.components) do
			val:event(eventTbl)
		end
	end;
	onView = function(self)
	end;
	onHide = function(self)
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
			self.components[val] = nil
		end
	end;
	isActive = function(self)
		return Controller.windows[1] == self
	end;
}
Window.mt = {
	__index = function (table, key)
		if (Controller.style.Window[key] ~= nil) then
			return Controller.style.Window[key]
		else
			return Window.prototype[key]
		end
	end;
}
function Window:new(windowTbl)
	setmetatable(windowTbl, Window.mt)
	windowTbl.components = {}
	return windowTbl
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
	visible = true;
	--functions
	draw = function(self) end;
	click = function(self, x, y, button) return false end;
	key = function(self, keyCode) return false end;
	char = function(self, char) return false end;
	scroll = function(self, direction) return false end;
	drag = function(self, x, y, button) return false end;
	event = function(self, eventTbl) return false end;
	update = function(self) return false end;
	termX = function(self) return self.x + self.parent.x - 1 end;
	termY = function(self) return self.y + self.parent.y - 1 end;
	setPos = function(self, x, y)
		self.x = x;
		self.y = y;
	end;
	setSize = function(self, w, h)
		self.w = w;
		self.h = h;
	end;
}

-- --
-- Panel
-- Pretty self explainatory
-- --
Panel = {}
Panel.prototype = {
	-- vars
	bgColor = colors.lightGray;
	components = {};
	z = 0;
	x = 1;
	y = 1;
	h = 1;
	w = 1;
	--functions
	draw = function(self)
		--drawPane
		Utils:drawRect(self.x, self.y, self.w, self.h, self.bgColor)
		--draw components
		self:drawComponents()
	end;
	drawComponents = function(self)
		for key, val in pairs(self.components) do
			val:draw()
		end
	end;
	addComponent = function(self, componentTbl)
		componentTbl.parent = self
		componentTbl.removed = false
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
		Controller:closeWindow(self)
	end;
	click = function(self, x, y)
		for key, val in pairs(self.components) do
			val:click(x, y)
		end
	end;
	key = function(self, keyCode)
		for key, val in pairs(self.components) do
			val:key(keyCode)
		end
	end;
	char = function(self, char)
		for key, val in pairs(self.components) do
			val:char(char)
		end
	end;
	scroll = function(self, direction)
		for key, val in pairs(self.components) do
			val:scroll(direction)
		end
	end;
	drag = function(self, x, y)
		for key, val in pairs(self.components) do
			val:drag(x, y)
		end
	end;
	event = function(self, eventTbl)
		for key, val in pairs(self.components) do
			val:event(eventTbl)
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
			self.components[val] = nil
		end
	end;
}
Panel.mt = {
	__index = function (table, key)
		if (Controller.style.Panel[key] ~= nil) then
			return Controller.style.Panel[key]
		elseif (Panel.prototype[key] ~= nil) then
			return Panel.prototype[key]
		else
			return Component.prototype[key]
		end
	end;
}
function Panel:new(panelTbl)
	setmetatable(panelTbl, Panel.mt)
	panelTbl.components = {}
	return panelTbl
end

-- --
-- Button extends Component
-- A component that you can click
-- --
Button = {}
Button.prototype = {
	--vars
	h = 3;
	w = 16;
	bgColor = colors.lightBlue;
	textColor = colors.white;
	activeColor = colors.blue;
	activeTextColor = colors.white;
	active = false;
	text = "txUI Button";
	textAlign = "center";
	vertCenter = true;
	--functions
	action = function(self) end;
	draw = function(self)
		Utils:drawRect(self:termX(), self:termY(), self.w, self.h, (function(self) if (self.active) then return self.activeColor else return self.bgColor end end)(self))
		term.setTextColor((function(self) if (self.active) then return self.activeTextColor else return self.textColor end end)(self))
		local lines = #Utils:splitText(self.text, "\n")
		for k, v in ipairs(Utils:splitText(self.text, "\n")) do
			term.setCursorPos(Utils:alignText(self.textAlign, string.len(v), self:termX(), self.w), self:termY() + k - 1 + (self.vertCenter and ((self.h - lines) / 2) or 0))
			term.write(v)
		end
	end;
	click = function (self, x, y)
		if ((x >= self:termX()) and (x <= (self:termX() + self.w - 1)) and (y >= self:termY()) and (y <= (self:termY() + self.h - 1))) then
			self.active = true
			self:action()
		else
			self.active = false
		end
	end;
	update = function(self) return false end;
}
Button.mt = {
	__index = function (table, key)
		if (Controller.style.Button[key] ~= nil) then
			return Controller.style.Button[key]
		elseif (Button.prototype[key] ~= nil) then
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
	vertCenter = true;
	--functions
	draw = function(self)
		Utils:drawRect(self:termX(), self:termY(), self.w, self.h, self.bgColor)
		term.setBackgroundColor(self.bgColor)
		term.setTextColor(self.textColor)
		local lines = #Utils:splitText(self.text, "\n")
		for k, v in ipairs(Utils:splitText(self.text, "\n")) do
			term.setCursorPos(Utils:alignText(self.textAlign, string.len(v), self:termX(), self.w), self:termY() + k - 1 + (self.vertCenter and ((self.h - lines) / 2) or 0))
			term.write(v)
		end
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
Label.tlmt = {
	__index = function (table, key)
		if (key == "w") then
			return table.parent.w
		elseif (key == "bgColor") then
			return table.parent.tlColor
		elseif (Label.prototype[key] ~= nil) then
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
	textMask = "";
	active = false;
	cursorPos = 0;
	displayOffset = 0;
	--functions
	draw = function(self)
		Utils:drawRect(self:termX(), self:termY(), self.w, self.h, self.bgColor)
		term.setBackgroundColor(self.bgColor)
		if (self.active or string.len(self.text) ~= 0) then
			local toWrite = string.sub(self.text, self.displayOffset + 1, self.displayOffset + self.w)
			if (string.len(self.textMask) ~= 0) then
				toWrite = string.gsub(toWrite, "%C", self.textMask)
			end
			term.setCursorPos(Utils:alignText(self.textAlign, string.len(toWrite), self:termX(), self.w), self:termY() + (self.h / 2))
			term.setTextColor(self.textColor)
			term.write(toWrite)
		else
			local toWrite = string.sub(self.placeholder, self.displayOffset + 1)
			term.setCursorPos(Utils:alignText(self.textAlign, string.len(toWrite), self:termX(), self.w), self:termY() + (self.h / 2))
			term.setTextColor(self.placeholderColor)
			term.write(toWrite)
		end
		term.setCursorBlink(self.active)
		if (self.active) then
			term.setCursorPos(self:termX() + self.cursorPos - self.displayOffset, self:termY() + (self.h / 2))
		end
	end;
	click = function (self, x, y)
		if ((x >= self:termX()) and (x <= (self:termX() + self.w - 1)) and (y >= self:termY()) and (y <= (self:termY() + self.h - 1))) then
			self.active = true
		else
			self.active = false
		end
	end;
	action = function(self)
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
		elseif (keyCode == keys.enter) then
			self:action()
		end
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

-- --
-- List extends Component
-- A component that lets you hold lists of other components
-- --
List = {}
List.prototype = {
	--vars
	h = 5;
	w = 16;
	bgColor = colors.white;
	bgColorStripe = colors.lightGray;
	textColor = colors.black;
	textColorStripe = colors.black;
	activeColor = colors.gray;
	activeTextColor = colors.white;
	textAlign = "left";
	scrollBarColor = colors.gray;
	scrollBarTextColor = colors.white;
	scrollBar = true;
	wrapText = false;
	displayOffset = 0;
	components = {};
	active = false;
	--functions
	draw = function(self)
		Utils:drawRect(self:termX(), self:termY(), self.w, self.h, self.bgColor)
		term.setBackgroundColor(self.bgColor)
		-- draw the components
		local index = 1
		for key, val in pairs(self.components) do
			val.w = self.w - (self.scrollBar and 1 or 0)
			val.y = self.displayOffset + index
			index = index + val.h
			if ((val.y > 0) and (val.y <= self.h)) then
				val:draw()
			end
			self.components[key] = val
		end
		-- draw the scroll bar
		if (self.scrollBar) then
			Utils:drawRect(self:termX() + self.w - 1, self:termY(), 1, self.h, self.scrollBarColor)
			term.setBackgroundColor(self.scrollBarColor)
			term.setTextColor(self.scrollBarTextColor)
			term.setCursorPos(self:termX() + self.w - 1, self:termY())
			term.write("^")
			term.setCursorPos(self:termX() + self.w - 1, self:termY() + self.h - 1)
			term.write("v")
		end
	end;
	click = function (self, x, y)
		for key, val in pairs(self.components) do
			if ((val.y > 0) and (val.y <= self.h)) then
				val:click(x, y)
			end
		end
		if ((x >= self:termX()) and (x <= (self:termX() + self.w - 1)) and (y >= self:termY()) and (y <= (self:termY() + self.h - 1))) then
			self.active = true
		else
			self.active = false
		end
		if (self.scrollBar) then
			if ((x == self:termX() + self.w - 1) and (y == self:termY())) then
				if (self.displayOffset < 0) then
					self.displayOffset = self.displayOffset + 1
				end
			end
			if ((x == self:termX() + self.w - 1) and (y == self:termY() + self.h - 1)) then
				if (self.displayOffset > -#self.components + 1) then
					self.displayOffset = self.displayOffset - 1
				end
			end
		end
	end;
	scroll = function (self, direction)
		if (self.active) then
			if (direction == -1) then
				if (self.displayOffset < 0) then
					self.displayOffset = self.displayOffset + 1
				end
			end
			if (direction == 1) then
				if (self.displayOffset > -#self.components + 1) then
					self.displayOffset = self.displayOffset - 1
				end
			end
		end
	end;
	addComponent = function(self, componentTbl)
		componentTbl.h = 1
		componentTbl.w = self.w - (self.scrollBar and 1 or 0)
		if (not self.wrapText) then
			componentTbl.text = Utils:limitText(componentTbl.text, componentTbl.w, "...")
		else
			if (string.len(componentTbl.text) > componentTbl.w) then
				componentTbl.h = math.ceil(string.len(componentTbl.text) / componentTbl.w)
				componentTbl.text = Utils:wrapText(componentTbl.text, componentTbl.w)
			end
		end
		componentTbl.bgColor = (#self.components % 2 == 0 and self.bgColor or self.bgColorStripe)
		componentTbl.textColor = (#self.components % 2 == 0 and self.textColor or self.textColorStripe)
		componentTbl.textAlign = self.textAlign
		componentTbl.activeColor = self.activeColor
		componentTbl.activeTextColor = self.activeTextColor
		componentTbl.parent = self
		componentTbl.removed = false
		table.insert(self.components, componentTbl)
	end;
	update = function(self) return false end;
}
List.mt = {
	__index = function (table, key)
		if (List.prototype[key] ~= nil) then
			return List.prototype[key]
		else
			return Component.prototype[key]
		end
	end;
}
function List:new(listTbl)
	if (listTbl == nil) then
		listTbl = self
	end
	setmetatable(listTbl, List.mt)
	listTbl.components = {}
	return listTbl
end

-- --
-- Checkbox extends Component
-- A component that lets users make a boolean choice
-- --
Checkbox = {}
Checkbox.prototype = {
	--vars
	h = 1;
	w = 16;
	bgColor = colors.lightGray;
	boxColor = colors.white;
	textColor = colors.black;
	checkedChar = "X";
	checked = false;
	text = "txUI Checkbox";
	textPosition = "right";
	--functions
	draw = function(self)
		Utils:drawRect(self:termX(), self:termY(), self.w, self.h, self.bgColor)
		-- draw box and set label position
		term.setBackgroundColor(self.boxColor)
		term.setTextColor(self.textColor)
		if (self.textPosition == "right") then
			Utils:drawRect(self:termX(), self:termY(), 1, 1, self.boxColor)
			term.setCursorPos(self:termX(), self:termY())
			term.write(self.checked and self.checkedChar or " ")
			term.setCursorPos(self:termX() + 2, self:termY())
		elseif (self.textPosition == "left") then
			Utils:drawRect(self:termX() + self.w - 1, self:termY(), 1, 1, self.boxColor)
			term.setCursorPos(self:termX() + self.w - 1, self:termY())
			term.write(self.checked and self.checkedChar or " ")
			term.setCursorPos(self:termX() + self.w - string.len(self.text) - 2, self:termY())
		end
		-- draw label
		term.setBackgroundColor(self.bgColor)
		term.write(self.text)
	end;
	click = function (self, x, y)
		if ((x >= self:termX()) and (x <= (self:termX() + self.w - 1)) and (y >= self:termY()) and (y <= (self:termY() + self.h - 1))) then
			self.checked = not self.checked
		end
	end;
	update = function(self) return false end;
}
Checkbox.mt = {
	__index = function (table, key)
		if (Checkbox.prototype[key] ~= nil) then
			return Checkbox.prototype[key]
		else
			return Component.prototype[key]
		end
	end;
}
function Checkbox:new(checkboxTbl)
	if (checkboxTbl == nil) then
		checkboxTbl = self
	end
	setmetatable(checkboxTbl, Checkbox.mt)
	return checkboxTbl
end

-- --
-- ProgressBar extends Component
-- A component that shows progress
-- --
ProgressBar = {}
ProgressBar.prototype = {
	--vars
	h = 1;
	w = 16;
	val = 0;
	bgColor = colors.white;
	barColor = colors.lime;
	textColor = colors.black;
	barTextColor = colors.white;
	textAlign = "center";
	textMask = "{val}%";
	showText = true;
	vertCenter = true;
	--functions
	draw = function(self)
		if (self.val > 100) then
			self.val = 100
		end
		local barWidth = self.w * (self.val / 100)
		Utils:drawRect(self:termX(), self:termY(), self.w, self.h, self.bgColor)
		Utils:drawRect(self:termX(), self:termY(), barWidth, self.h, self.barColor)
		if (self.showText) then
			local text = string.gsub(self.textMask, "{val}", tostring(self.val))
			term.setBackgroundColor(self.bgColor)
			term.setTextColor(self.textColor)
			local lines = #Utils:splitText(text, "\n")
			for k, v in ipairs(Utils:splitText(text, "\n")) do
				term.setCursorPos(Utils:alignText(self.textAlign, string.len(v), self:termX(), self.w), self:termY() + k - 1 + (self.vertCenter and ((self.h - lines) / 2) or 0))
				local x, y = term.getCursorPos()
				if (x - self:termX() < barWidth) then
					term.setBackgroundColor(self.barColor)
					term.setTextColor(self.barTextColor)
					term.write(v)
					if (x - self:termX() + string.len(v) > barWidth) then
						term.setBackgroundColor(self.bgColor)
						term.setTextColor(self.textColor)
						local overflow = x - self:termX() + string.len(v) - barWidth
						local ax, ay = term.getCursorPos()
						term.setCursorPos(ax - overflow, ay)
						term.write(string.sub(v, math.abs(string.len(v) - overflow) + 1))
					end
				else
					term.write(v)
				end
			end
		end
	end;
	update = function(self) return false end;
}
ProgressBar.mt = {
	__index = function (table, key)
		if (ProgressBar.prototype[key] ~= nil) then
			return ProgressBar.prototype[key]
		else
			return Component.prototype[key]
		end
	end;
}
function ProgressBar:new(progressBarTbl)
	if (progressBarTbl == nil) then
		progressBarTbl = self
	end
	setmetatable(progressBarTbl, ProgressBar.mt)
	return progressBarTbl
end

Controller:setDefaultStyle(Style:new({}))
