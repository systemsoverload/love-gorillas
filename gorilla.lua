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
	self.gorillaAnimation = animation
	self.orientation = orientation
	self.victoryDance = nil
end

function Gorilla:update(dt)

	if  self.isThrowing > 0 then
		-- Throw from the correct arm depending on which side of the screen gorilla is on
		if self.orientation == "left" then
			self.gorillaAnimation:gotoFrame(2)
		else
			self.gorillaAnimation:gotoFrame(4)
		end
		self.isThrowing = self.isThrowing - dt
	elseif self.victoryDance == nil then
		self.gorillaAnimation:gotoFrame(1)
	end

	if self.victoryDance then
		if self.victoryDance > 0 then
			self.gorillaAnimation:resume()
			self.victoryDance = self.victoryDance - dt
		else
			self.victoryDance = nil
			self.gorillaAnimation:gotoFrame(1)
			-- Clear any collision objects from the previous level
			cleanupObjects()
			-- Generate new level
			generateLevel()
			-- Change turns
			changeTurn()
		end
	else
		Player1.gorillaAnimation:pause()
		Player2.gorillaAnimation:pause()
	end

	self.gorillaAnimation:update(dt)
end

return Gorilla