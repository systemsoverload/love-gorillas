-- TextInput 1.0 - for love2d 0.7.2
-- Copyright (c) 2011, Francesco Noferi
-- All rights reserved.

TextInput = class('TextInput')
function TextInput:initialize(x, y, size, w, callback)
	self.text = ""
	self.time = 0.0
	self.cursor = "_"
	self.cursor_pos = 0
	self.x = x
	self.y = y
	self.size = size
	self.w = w
	self.callback = callback or nil
	self.shift = false
end

function TextInput:reset()
	self.shift = false
	self.cursor_pos = 0
	self.time = 0.0
	self.text = ""
end

function TextInput:step(k)
	self.time = self.time + k
	if self.time > .5 then
		if self.cursor == "_" then
			self.cursor = ""
		else
			self.cursor = "_"
		end
		self.time = 0.0
	end
	self.shift = love.keyboard.isDown("lshift", "rshift", "capslock")
end

function TextInput:keypressed(key, unicode)
	if not unicode then
		unicode = 0
	end

	if key == "backspace" and self.cursor_pos > 0 then
		self.text = string.sub(self.text, 1, self.cursor_pos-1) .. string.sub(self.text, self.cursor_pos+1)
		self.cursor_pos = self.cursor_pos-1
	elseif key == "left" then
		self.cursor_pos = math.max(0, self.cursor_pos-1)
	elseif key == "right" then
		self.cursor_pos = math.min(self.text:len(), self.cursor_pos+1)
	elseif key == "delete" then
		self.text = string.sub(self.text, 1, self.cursor_pos) .. string.sub(self.text, self.cursor_pos+2)
	elseif key == "return" then
		-- Make callback function optional
		if self.callback then
			self.callback(self.text)
		end
	elseif self.text:len() < self.size then -- and unicode < 166 and unicode > 31 then
		local thekey = key
		if thekey == 'backspace' then
			return
		end
		if self.shift then
			thekey = key:upper()
		end
		self.text = string.sub(self.text, 1, self.cursor_pos) .. thekey .. string.sub(self.text, self.cursor_pos+1)
		self.cursor_pos = self.cursor_pos+1
	end
end

function TextInput:draw()
	-- Draw a blue box under the text field to cover the angle/velocity values
	love.graphics.setColor(0,0,255,255)
	love.graphics.rectangle('fill',self.x - 2, self.y, 25, 15)
	love.graphics.setColor(255,255,255,255)
	love.graphics.printf(self.text, self.x, self.y, self.w)
	love.graphics.printf(
		self.cursor,
		self.x+love.graphics.getFont():getWidth(string.sub(self.text, 1, self.cursor_pos))-love.graphics.getFont():getWidth(self.cursor)/2,
		self.y,
		self.w
	)
end
