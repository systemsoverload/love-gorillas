HC = require "HardonCollider"
anim8 = require "anim8.anim8"
Gorilla = require "gorilla"
Banana = require "banana"

function love.load()

	Collider = HC(100, onCollide, onStopCollision )
	buildings, explosions, bananas, buildingImages = {}, {}, {}, {}
	explosionSound = love.audio.newSource("audio/small-explosion.ogg")
	victorySound = love.audio.newSource("audio/victory.ogg")

	gameOver = false

	--Load gorilla assets
	gorillaImage = love.graphics.newImage("/images/gorilla.png")
	GorillaGrid = anim8.newGrid( 28, 30, gorillaImage:getWidth(), gorillaImage:getHeight())
	Player1 = Gorilla:new('Player 1', anim8.newAnimation('loop', GorillaGrid('1-4,1'), .5), 5, 5, 'left' )
	Player2 = Gorilla:new('Player 2', anim8.newAnimation('loop', GorillaGrid('1-4,1'), .5), 720, 5, 'right' )

	currentPlayer = Player1

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
	generateLevel()

	-- Instantiate sun
	sun = Collider:addRectangle(400, 25, 41, 31)
	sun.entityType = 'sun'

	--Load image files
	sunImage = love.graphics.newImage("/images/sun.png")
	sunHitImage = love.graphics.newImage("/images/sunHit.png")

	explosionImage = love.graphics.newImage("/images/explosion.png")
end

function love.update(dt)

	-- Angle controls
	if love.keyboard.isDown("up") then
		-- Ceiling the angle input at 360
		if currentPlayer.angle + 25 * dt > 360 then
			currentPlayer.angle = 360
		else
			currentPlayer.angle = currentPlayer.angle + 25 * dt
		end
	end

	if love.keyboard.isDown("down") then
		-- Floor the angle input at 0
		if currentPlayer.angle - 25 * dt < 0 then
			currentPlayer.angle = 0
		else
			currentPlayer.angle = currentPlayer.angle - 25 * dt
		end
	end

	-- Power controls
	if love.keyboard.isDown("right") then
		currentPlayer.velocity = currentPlayer.velocity + 75 * dt
	end

	if love.keyboard.isDown("left") then
		-- Floor the velocity input at 0
		if currentPlayer.velocity - 75 * dt < 0 then
			currentPlayer.velocity = 0
		else
			currentPlayer.velocity = currentPlayer.velocity - 75 * dt
		end
	end

	for i,v in ipairs(explosions) do
		v.animation:update(dt)
	end

	-- Update animations
	Player1:update(dt)
	Player2:update(dt)

	for i,v in ipairs(bananas) do
		v:update(dt)
	end

	-- Update HC entities
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

	--Draw the gorillas
	local g1x, g1y = Player1.gorilla:center()
	local g2x, g2y = Player2.gorilla:center()
	love.graphics.setColor(255,255,255,255)
	Player1.animation:draw(gorillaImage, g1x - 15, g1y - 15)
	Player2.animation:draw(gorillaImage, g2x - 15, g2y - 15)

	--Draw explosions
	for i,v in ipairs(explosions) do
		love.graphics.setColor(0,0,255,255)
		love.graphics.circle('fill', v.x, v.y, v.radius, 30)
		love.graphics.setColor(255,255,255,255)
		v.animation:draw(explosionImage, v.x - 10 , v.y - 10)
	end

	--Draw bananas
	for i,banana in ipairs(bananas) do
		local bx, by = banana.bb:center()
		love.graphics.setColor(255,255,255,255)
		banana.animation:draw(banana.image, bx - 3.5, by - 3.5)
	end

	--Draw the sun
	love.graphics.setColor(255,255,255,255)
	if sun.wasHit == true then
		love.graphics.draw(sunHitImage, 400, 25)
	else
		love.graphics.draw(sunImage, 400, 25)
	end

	-- draw player fields
	love.graphics.setColor(255,255,255,255)
	love.graphics.print(currentPlayer.name, currentPlayer.inputsX, currentPlayer.inputsY)
	love.graphics.print(string.format("Angle: %s", currentPlayer.angle), currentPlayer.inputsX, currentPlayer.inputsY + 20 )
	love.graphics.print(string.format("Power: %s", currentPlayer.velocity), currentPlayer.inputsX, currentPlayer.inputsY + 40)

	-- Draw score field
	love.graphics.setColor(0,0,255,255)
	love.graphics.rectangle( 'fill', 350, 575, 97, 15 )
	love.graphics.setColor(255,255,255,255)
	love.graphics.print(string.format("%s > Score < %s", Player1.score, Player2.score ), 355, 576)

	if gameOver then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle('fill', 0, 0, 800, 600)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print('GAME OVER!', 320, 300)
		love.graphics.print(string.format("%s Score - %s", Player1.name, Player1.score), 320, 315)
		love.graphics.print(string.format("%s Score - %s", Player2.name, Player2.score), 320, 330)
		local winner
		if Player1.score > Player2.score then
			winner = Player1
		else
			winner = Player2
		end
		love.graphics.print(string.format("%s wins!", winner.name), 320, 345)
	end

end

function love.keyreleased(key)
	-- Fire a test banana on spacebar
	if key == " " then
		fireBanana()
	end

	-- Quit the game on escape
	if key == "escape" then
		love.event.push("quit")
	end
end

---
-- Spawn a banana and start it moving along a given angle at a given speed
-- @method fireBanana
-------------------------------------
function fireBanana()
	local gx, gy = currentPlayer.gorilla:center()
	local angle

	if currentPlayer == Player2 then
		angle = 180 - currentPlayer.angle
		gx = gx + 7
		gy = gy - 15
	else
		angle = currentPlayer.angle
		gx = gx - 15
		gy = gy - 15
	end

	local banana = Banana:new(gx, gy, 7, 7, currentPlayer.gorilla )

	-- pass banana angle (in radians) and initial impulse velocity
	banana:setTrajectory( angle * (math.pi/180), currentPlayer.velocity )

	if #bananas == 0 and Player1.victoryDance == nil and Player2.victoryDance == nil then
		currentPlayer.isThrowing = .25
		table.insert(bananas, banana)
	end


end

---
-- Method to be called when two HC objects stop colliding
-- @method onStopCollision
-- @param dt - delta
-- @param shape_a - The first of the two colliding shapes
-- @param shape_b - The second of the two colliding shapes
-- @param mtv_x - Minimum translation vector x coord
-- @param mtv_y - Minimum translation vector y coord
-------------------------------------
function onStopCollision(dt, shape_a, shape_b, mtv_x, mtv_y)
	local other
	local banana

	--Figure out which collision object is our banana, pass if neither
	if shape_a.entityType == 'banana' then
		banana = shape_a
		other = shape_b
	elseif shape_b.entityType == 'banana' then
		banana = shape_b
		other = shape_a
	else
		return
	end

	if other.entityType == 'explosion' then
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

---
-- Method to be called when two HC objects start colliding
-- @method onCollide
-- @param dt - delta
-- @param shape_a - The first of the two colliding shapes
-- @param shape_b - The second of the two colliding shapes
-- @param mtv_x - Minimum translation vector x coord
-- @param mtv_y - Minimum translation vector y coord
-------------------------------------
function onCollide( dt, shape_a, shape_b, mtv_x, mtv_y )
	local other
	local banana

	--Figure out which collision object is our banana, pass if neither
	if shape_a.entityType == 'banana' then
		banana = shape_a
		other = shape_b
	elseif shape_b.entityType == 'banana' then
		banana = shape_b
		other = shape_a
	else
		return
	end

	--Explosion collision handler
	if other.entityType == 'explosion' then
		banana.inExplosion = true
		return
	-- Building collision handler
	elseif other.entityType == 'building' and banana.inExplosion == false then
		-- Create location on this spot
		local ex, ey = banana:center()
		addExplosion( ex, ey, 10)

		-- Destroy the banana and remove it from collider objects
		table.remove(bananas, 1)
		Collider:remove(banana)

		-- Change turns
		changeTurn()

	-- Gorilla collision handler
	elseif other.entityType == 'gorilla' then
		-- Make sure this isnt the banana colliding with the thrower
		if banana.thrownBy ~= other then

			-- Create location on the gorilla that was hit
			local ex, ey = other:center()
			addExplosion( ex, ey, 40)

			-- Destroy the banana and remove it from collider objects
			table.remove(bananas, 1)
			Collider:remove(banana)

			-- Give a point to the thrower
			currentPlayer.score = currentPlayer.score + 1

			--Set victory dance flag
			currentPlayer.victoryDance = 7

			--Play the victory song
			love.audio.play(victorySound)
			-- If the currentPlayer has scored 3, game over man
			if currentPlayer.score == 3 then
				gameOver = true
			end

		end
	elseif other.entityType == 'sun' then
		-- Set the wasHit flag on the sun to change to the oh-face
		other.wasHit = true
	end
end

---
-- Flip the value of the global currentPlayer variable
-- @method changeTurn
-------------------------------------
function changeTurn()

	if currentPlayer == Player1 then
		currentPlayer = Player2
	elseif currentPlayer == Player2 then
		currentPlayer = Player1
	end
	-- Clear the oh-face off of the sun
	sun.wasHit = false
end

---
-- Generate random buildings and place gorillas randomly on top of them
-- @method generateLevel
-------------------------------------
function generateLevel()
	-- Generate random buildings
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
		building.entityType = 'building'
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

	-- Grab random buildings from the table
	-- Player1 is constrained to the left half of the screen, and Player2 the right
	gorilla1Building = buildings[math.random(5)]
	gorilla2Building = buildings[math.random(5) + 5]

	-- Instantiate gorilla bounding boxes
	Player1:setBB(gorilla1Building.x + 15, gorilla1Building.y - 30, 30, 30)
	Player2:setBB(gorilla2Building.x + 15, gorilla2Building.y - 30, 30, 30)

	Collider:addToGroup('groupB', Player1.gorilla, Player2.gorilla )
end

---
-- Method to clean up any left over collision objects when re-generating levels
-- @method cleanupObjects
-------------------------------------
function cleanupObjects()
	-- Reset both players angles and velocity
	Player1.angle = 0
	Player1.velocity = 0
	Player2.angle = 0
	Player2.velocity = 0

	-- Iterate buildings and explosions and remove them and their collision entities
	local collisionObjects = { buildings, explosions }
	for i in pairs(collisionObjects) do
		for k,v in ipairs(collisionObjects[i]) do
			Collider:remove(v)
			collisionObjects[i][k] = nil
		end
	end

	-- Remove collision entities for both gorillas and any stray bananas
	Collider:remove( Player1.gorilla, Player2.gorilla, banana )
end

---
-- Add new explosion object to the scene
-- @method addExplosion
-- @param x - X coordinate to render collision entity and sprite
-- @param y - Y coordinate to render collision entity and sprite
-- @param r - radius of hit box and the "damage" circle to be rendered
-------------------------------------
function addExplosion( x, y, r )
	-- Create explosion object
	local explosion = Collider:addCircle(x, y, r)
	Collider:addToGroup( 'groupB', explosion )
	explosion.entityType = 'explosion'
	explosion.x = x
	explosion.y = y
	explosion.radius = r
	local explosionGrid = anim8.newGrid(20, 20, explosionImage:getWidth(), explosionImage:getHeight())
	explosion.animation = anim8.newAnimation('once', explosionGrid('1-6,1'), 0.035)
	-- Add explosion to the explosions table
	table.insert(explosions, explosion)
	love.audio.play(explosionSound)
end