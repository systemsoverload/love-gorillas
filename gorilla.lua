local Gorilla = class("Gorilla")

local victorySound = love.audio.newSource("audio/victory.ogg")

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
	-- draw player fields
	love.graphics.setColor(255,255,255,255)
	love.graphics.print(self.name, self.inputsX, self.inputsY)
	love.graphics.print(string.format("Angle: %s", self.angle), self.inputsX, self.inputsY + 20 )
	love.graphics.print(string.format("Power: %s", self.velocity), self.inputsX, self.inputsY + 40)

	-- draw gorilla image over the bb
	local gx, gy = self.gorilla:center()
	self.animation:draw(self.image, gx - 15, gy - 15)

end

-- Update loop
function Gorilla:update(dt)

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

return Gorilla