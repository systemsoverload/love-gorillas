require("middleclass.middleclass")

Gorilla = class("Gorilla")

function Gorilla:initialize(name,animation,inputsX,inputsY,orientation)
	self.score = 0
	self.name = name
	self.angle = 0
	self.velocity = 0
	self.isThrowing = 0
	self.inputsX = inputsX
	self.inputsY = inputsY
	self.animation = animation
	self.orientation = orientation
	self.victoryDance = nil
end

-- Set the collision bounding box
function Gorilla:setBB( x, y, height, width )
	self.gorilla = Collider:addRectangle(x,y,height,width)
	self.gorilla.entityType = 'gorilla'
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