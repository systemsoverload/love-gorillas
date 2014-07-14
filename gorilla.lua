local Gorilla = class("Gorilla")

local victorySound = love.audio.newSource("audio/victory.ogg")
require "TextInput"

function Gorilla:initialize( name, inputsX, inputsY, orientation )
	self.score = 0
	self.name = name
	self.angle = 0
	self.velocity = 0
	self.isThrowing = 0
	self.inputsX = inputsX
	self.inputsY = inputsY
	self.orientation = orientation
	self.victoryDance = nil
	self.image = love.graphics.newImage("/images/gorilla.png")
	self.grid = anim8.newGrid( 28, 30, self.image:getWidth(), self.image:getHeight())
	self.animation =  anim8.newAnimation('loop', self.grid('1-4,1'), .5)
	self.inputState = "angle"

	if self.orientation == 'left' then
		self.playerInput = TextInput(inputsX + 44, inputsY + 20, 3, 5 )
	elseif self.orientation == 'right' then
		self.playerInput = TextInput(inputsX + 44, inputsY + 20, 3, 5 )
	end
end

-- Set the collision bounding box
function Gorilla:setBB( x, y, height, width )
	self.gorilla = Collider:addRectangle(x,y,height,width)
	self.gorilla.entityType = 'gorilla'
end

function Gorilla:celebrate()
	-- Give me a point
	self.score = currentPlayer.score + 1

	--Set victory dance flag
	self.victoryDance = 6

	--Play victory sound
	love.audio.play(victorySound)
end

function Gorilla:draw()
	if self == currentPlayer then
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf( self.name, self.inputsX, self.inputsY, 100, 'left' )
		-- Render angle and velocity text based on the inputState
		if self.inputState == 'angle' or self.inputState == 'velocity' then
			love.graphics.printf( string.format("Angle: %s", self.angle), self.inputsX, self.inputsY + 20, 90, 'left' )
			if self.inputState == 'velocity' or self.isThrowing ~= 0 then
				love.graphics.printf( string.format("Power: %s", self.velocity), self.inputsX, self.inputsY + 40, 90, 'left')
			end
		end

		if self.isThrowing == 0 then
			self.playerInput:draw()
		end
	end

	-- draw gorilla image over the bb
	local gx, gy = self.gorilla:center()
	self.animation:draw(self.image, gx - 15, gy - 15)

end

function Gorilla:keypressed(key)
	if self.isThrowing == 0 and self.inputState == "angle" and key == "return" then
		self.inputState = "velocity"
		self.angle = tonumber(self.playerInput.text) or 0
		self.playerInput:keypressed(key, nil)
		self.playerInput.text = ''
		self.playerInput.y = self.inputsY + 40
	elseif self.isThrowing and self.inputState == "velocity" and key == "return" then
		self.inputState = "angle"
		self.velocity = tonumber(self.playerInput.text) or 0
		self.playerInput.text = ''
		self.playerInput.y = self.inputsY + 20
		self:fireBanana()
	else
		self.playerInput:keypressed(key, nil)
	end
end

-- Update loop
function Gorilla:update(dt)
	if self == currentPlayer then
		-- self.playerInput:step(dt)
	end
	if  self.isThrowing > 0 then
		-- Throw from the correct arm depending on which side of the screen gorilla is on
		if self.orientation == "left" then
			self.animation:gotoFrame(2)
		else
			self.animation:gotoFrame(4)
		end
		self.isThrowing = self.isThrowing - dt
	elseif self.victoryDance == nil then
		self.animation:gotoFrame(1)
	end

	if self.victoryDance then
		if self.victoryDance > 0 then
			self.animation:resume()
			self.victoryDance = self.victoryDance - dt
		else
			self.victoryDance = nil
			self.animation:gotoFrame(1)
			-- Clear any collision objects from the previous level
			cleanupObjects()
			-- Generate new level
			generateLevel()
			-- Change turns
			changeTurn()
		end
	else
		self.animation:pause()
	end

	self.animation:update(dt)
end

---
-- Spawn a banana and start it moving along a given angle at a given speed
-- @method fireBanana
-------------------------------------
function Gorilla:fireBanana()
	local gx, gy = self.gorilla:center()
	local angle

	-- Reflect angle for player on the right
	if self.orientation == "right" then
		angle = 180 - self.angle
		gx = gx + 7
		gy = gy - 15
	else
		angle = self.angle
		gx = gx - 15
		gy = gy - 15
	end

	local banana = Banana:new(gx, gy, 7, 7, self.gorilla )

	-- pass banana angle (in radians) and initial impulse velocity
	banana:setTrajectory( angle * (math.pi/180), self.velocity * 1.25 )

	if #bananas == 0 and Player1.victoryDance == nil and Player2.victoryDance == nil then
		self.isThrowing = .25
		table.insert(bananas, banana)
	end


end

return Gorilla
