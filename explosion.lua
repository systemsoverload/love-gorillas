local Explosion = class('Explosion')

local explosionImageSmall = love.graphics.newImage("/images/explosion.png")
local explosionImageLarge = love.graphics.newImage("/images/explosion_large.png")
local explosionSoundSmall = love.audio.newSource("audio/small-explosion.ogg")
local explosionSoundLarge = love.audio.newSource("audio/large-explosion.ogg")

function Explosion:initialize(x,y,r)
	-- Create explosion object
	self.bb = Collider:addCircle(x, y, r)
	Collider:addToGroup( 'groupB', explosion )
	self.bb.entityType = 'explosion'
	self.x = x
	self.y = y
	self.radius = r

	if r > 10 then
		self.image = explosionImageLarge
		self.frameSize = 40
		love.audio.play(explosionSoundLarge)
	else
		self.image = explosionImageSmall
		self.frameSize = 20
		love.audio.play(explosionSoundSmall)
	end

	local explosionGrid = anim8.newGrid(self.frameSize, self.frameSize, self.image:getWidth(), self.image:getHeight())
	self.animation = anim8.newAnimation('once', explosionGrid('1-6,1'), 0.035)
end

function Explosion:draw()
	love.graphics.setColor(0,0,255,255)
	love.graphics.circle('fill', self.x, self.y, self.radius, 30)
	love.graphics.setColor(255,255,255,255)
	self.animation:draw( self.image, self.x - 10 , self.y - 10 )
end


return Explosion