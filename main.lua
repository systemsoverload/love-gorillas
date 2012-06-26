HC = require "HardonCollider"
anim8 = require "anim8/anim8"

local debugText = {}

function love.load()

	Collider = HC(100, on_collide, on_stopCollision )
	buildings, explosions, bananas, buildingImages = {}, {}, {}, {}

	player1 = { angle = 0, velocity = 0 }
	player2 = { angle = 0, velocity = 0 }

	--Setup building images and prep for randomization
	local buildingRedImage = love.graphics.newImage("/images/building_red.png")
	buildingRedImage:setWrap('repeat', 'repeat')
	table.insert(buildingImages, buildingRedImage)

	local buildingGrayImage = love.graphics.newImage("/images/building_gray.png")
	buildingGrayImage:setWrap('repeat', 'repeat')
	table.insert(buildingImages, buildingGrayImage)

	local buildingBlueImage = love.graphics.newImage("/images/building_blue.png")
	buildingBlueImage:setWrap('repeat', 'repeat')
	table.insert(buildingImages, buildingBlueImage)

	--Generate random buildings
	for i=0,9 do
		local height =  math.random(40, 250)
		local buildingX = i * 80 - 1
		local buildingY = 600 - height
		local buildingImage = buildingImages[math.random( 3 )]
		building = Collider:addRectangle( buildingX, buildingY, 78, height)
		building.height = height
		Collider:addToGroup('groupB',building)
		building.x = buildingX
		building.y = buildingY
		building.typeOf = 'building'
		building.image = buildingImage
		building.quad = love.graphics.newQuad(
			0 --Starting x
			, 0 --Starting y
			, 79 --Quad width
			, height --Quad Height
			, buildingImage:getWidth() --Image width
			, buildingImage:getHeight() --Image height
		)
		table.insert(buildings, building)
	end

	--Grab random buildings from the table
	--Gorilla1 is constrained to the left half of the screen, and gorilla2 the right
	gorilla1Building = buildings[math.random(5)]
	gorilla2Building = buildings[math.random(5) + 5]

	-- Instantiate gorillas
	gorilla1 = Collider:addRectangle(gorilla1Building.x + 15, gorilla1Building.y - 30, 30, 30)
	gorilla1.typeOf = 'gorilla'

	gorilla2 = Collider:addRectangle(gorilla2Building.x + 15, gorilla2Building.y - 30, 30, 30)
	gorilla2.typeOf = 'gorilla'

	Collider:addToGroup('groupB', gorilla1, gorilla2 )

	-- Instantiate sun
	sun = Collider:addRectangle(400, 25, 41, 31)
	sun.typeOf = 'sun'

	--Load image files
	sunImage = love.graphics.newImage("/images/sun.png")
	sunHitImage = love.graphics.newImage("/images/sunHit.png")
	gorillaImage = love.graphics.newImage("/images/gorilla_stand.png")
	bananaImage = love.graphics.newImage("/images/banana.png")

	--Setup banana animations
	bananaGrid = anim8.newGrid(7, 7, bananaImage:getWidth(), bananaImage:getHeight())
	Bananimation = anim8.newAnimation('loop', bananaGrid('1-4,1'), 0.1)
end

function love.update(dt)
	-- If a banana has been thrown, attempt to move it
	for i,banana in ipairs(bananas) do

		banana:move(banana.velocity.x*dt, banana.velocity.y*dt)

		--gravity!
		banana.velocity.y = banana.velocity.y + ( dt * 80 )
	end

	-- Remove excess debug messages
	while #debugText > 40 do
		table.remove(debugText, 1)
	end

	-- Angle controls
	if love.keyboard.isDown("up") then
		player1.angle = player1.angle + 25 * dt
	end

	if love.keyboard.isDown("down") then
		player1.angle = player1.angle - 25 * dt
	end

	-- Power controls
	if love.keyboard.isDown("right") then
		player1.velocity = player1.velocity + 75 * dt
	end

	if love.keyboard.isDown("left") then
		player1.velocity = player1.velocity - 75 * dt
	end

	Bananimation:update(dt)
	Collider:update(dt)
end

function love.draw()
	--Draw sky bg
	love.graphics.setColor(0,0,255)
	love.graphics.rectangle("fill",0,0,800,600)

	--Draw buildings
	for i,v in ipairs(buildings) do
		love.graphics.setColor(255,255,255,255)
		-- love.graphics.drawq(img, bottom_left, 50, 200)
		love.graphics.drawq(v.image, v.quad, v.x, v.y)
		-- love.graphics.draw(buildingRedImage, v.x, v.y)
	end

	--Draw explosions
	for i,v in ipairs(explosions) do
		love.graphics.setColor(0,0,255)
		v:draw("fill")
	end

	--Draw the gorillas
	local g1x, g1y = gorilla1:center()
	local g2x, g2y = gorilla2:center()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(gorillaImage, g1x - 15 , g1y - 15 )
	love.graphics.draw(gorillaImage, g2x - 15 , g2y - 15 )

	--Draw bananas
	for i,banana in ipairs(bananas) do
		local bx, by = banana:center()
		love.graphics.setColor(255,255,255,255)
		Bananimation:draw(bananaImage, bx - 3.5, by - 3.5)
	end

	--Draw the sun
	love.graphics.setColor(255,255,255,255)
	if sun.wasHit == true then
		love.graphics.draw(sunHitImage, 400, 25)
	else
		love.graphics.draw(sunImage, 400, 25)
	end

	-- FIXME - Debug logging
	for i = 1,#debugText do
		love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
		love.graphics.print(debugText[#debugText - (i-1)], 10, i * 15 + 50)
	end

	-- draw player fields
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("Player 1", 0, 0)
	love.graphics.print(string.format("Angle: %s", player1.angle), 0, 20)
	love.graphics.print(string.format("Power: %s", player1.velocity), 0, 40)
end

function love.keyreleased(key)
	-- Fire a test banana on spacebar
	if key == " " then
		fireBanana(gorilla1)
	end

	-- Quit the game on escape
	if key == "escape" then
		love.event.push("quit")
	end
end

function fireBanana(thrownBy)
	local gx, gy = gorilla1:center()
	local banana = Collider:addRectangle(gx , gy , 7, 7)

	--banana angle (in radians) and initial impuls velocity
	banana.angle = player1.angle*(math.pi/180)
	banana.impulse = player1.velocity

	--calc velocity for x and y vectors
	banana.velocity = { }
	banana.velocity.x = banana.impulse * math.cos(banana.angle)
	banana.velocity.y = banana.impulse * math.sin(banana.angle) * -1

	--setup other banana vars
	banana.thrownBy = thrownBy
	banana.typeOf = 'banana'
	banana.inExplosion = false

	if #bananas > 0 then
		table.remove(bananas, 1)
	end

	table.insert(bananas, banana)
end

function on_stopCollision(dt, shape_a, shape_b, mtv_x, mtv_y)
	local other
	local banana

	--Figure out which collision object is our banana, pass if neither
	if shape_a.typeOf == 'banana' then
		banana = shape_a
		other = shape_b
	elseif shape_b.typeOf == 'banana' then
		banana = shape_b
		other = shape_a
	else
		return
	end

	if other.typeOf == 'explosion' then
		local intersectsExplosion = false
		for i,v in ipairs(explosions) do
			if v:contains(banana:center()) then
				intersectsExplosion = true
			end
		end
		if intersectsExplosion == false then
			banana.inExplosion = false
		end
	end
end

function on_collide( dt, shape_a, shape_b, mtv_x, mtv_y )
	local other
	local banana

	--Figure out which collision object is our banana, pass if neither
	if shape_a.typeOf == 'banana' then
		banana = shape_a
		other = shape_b
	elseif shape_b.typeOf == 'banana' then
		banana = shape_b
		other = shape_a
	else
		return
	end

	--Explosion collision handler
	if other.typeOf == 'explosion' then
		-- debugText[#debugText+1] = 'Banana colliding with EXPLOSION'
		banana.inExplosion = true
		return
	--Building collision handler
	elseif other.typeOf == 'building' and banana.inExplosion == false then

		--Destroy the banana and remove it from collider objects
		table.remove(bananas, 1)
		Collider:remove(banana)

		--Create explosion object
		local ex, ey = banana:center()
		local explosion = Collider:addCircle(ex, ey, 10)
		Collider:addToGroup( 'groupB', explosion )
		explosion.typeOf = 'explosion'

		--Add explosion to the explosions table
		table.insert(explosions, explosion)

	--Gorilla collision handler
	elseif other.typeOf == 'gorilla' then
		if banana.thrownBy ~= other then
			-- debugText[#debugText+1] = string.format("Banana Colliding With GORILLA - (%s,%s)", mtv_x, mtv_y)
			banana.velocity = { x = 0, y = 0}
			table.remove(bananas, 1)
		end
	elseif other.typeOf == 'sun' then
		other.wasHit = true
	end

end
