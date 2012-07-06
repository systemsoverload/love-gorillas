local Banana = class("Banana")
local bananaImage = love.graphics.newImage("/images/banana.png")
local bananaGrid = anim8.newGrid(7, 7, bananaImage:getWidth(), bananaImage:getHeight())
local throwSound = love.audio.newSource("audio/throw.ogg")

function Banana:initialize(x, y, width, height, thrownBy )
	self.bb = Collider:addRectangle(x,y,height,width)
	self.bb.thrownBy = thrownBy
	self.bb.entityType = 'banana'
	self.bb.inExplosion = false
	self.entityType = 'banana'
	self.animation = anim8.newAnimation('loop', bananaGrid('1-4,1'), 0.15)
	self.image = bananaImage
	self.soundPlayed = false
end

-- Calculate the x and y velocity of the banana based on an angle and impulse
function Banana:setTrajectory( angle, impulse )
	--calc velocity for x and y vectors
	self.velocity = { }
	--double the impulse value so you dont have to enter such a large value
	self.velocity.x = ( impulse * 2 ) * math.cos(angle)
	self.velocity.y = ( impulse * 2 ) * math.sin(angle) * -1
end

function Banana:draw()
	local bx, by = self.bb:center()
	love.graphics.setColor(255,255,255,255)
	self.animation:draw(self.image, bx - 3.5, by - 3.5)
end

function Banana:update(dt)
	if self.soundPlayed == false then
		love.audio.play(throwSound)
		self.soundPlayed = true
	end
	local bx,by = self.bb:center()
	if bx > 800 or bx < 0 or by > 600 then
		changeTurn()
		-- Destroy the banana and remove it from collider objects
		table.remove(bananas, 1)
		Collider:remove(self.bb)

	else
		-- Update banana position
		self.bb:move( (self.velocity.x * dt) * .5 , (self.velocity.y * dt) * .5 )
		-- gravity!
		self.velocity.y = self.velocity.y + ( dt * 40 )
	end

	self.animation:update(dt)
end

return Banana