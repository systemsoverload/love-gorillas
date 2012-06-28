HC = require "HardonCollider"
anim8 = require "anim8/anim8"

function love.load()

	Collider = HC(100, onCollide, onStopCollision )
	buildings, explosions, bananas, buildingImages = {}, {}, {}, {}
	gameOver = false
	player1 = { angle = 0, velocity = 0, score = 0, name = 'Player 1' , inputsX = 5, inputsY = 5 }
	player2 = { angle = 0, velocity = 0, score = 0, name = 'Player 2' , inputsX = 720, inputsY = 5 }

	currentPlayer = player1

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
		-- Move da banana!
		local bx,by = banana:center()
		if bx > 800 or bx < 0 then
			changeTurn()
			-- Destroy the banana and remove it from collider objects
			table.remove(bananas, 1)
			Collider:remove(banana)

		else
			banana:move(banana.velocity.x * dt, banana.velocity.y * dt)
			-- gravity!
			banana.velocity.y = banana.velocity.y + ( dt * 80 )
		end
	end

	-- Angle controls
	if love.keyboard.isDown("up") then
		if currentPlayer.angle + 25 * dt > 360 then
			currentPlayer.angle = 360
		else
			currentPlayer.angle = currentPlayer.angle + 25 * dt
		end
	end

	if love.keyboard.isDown("down") then
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
		if currentPlayer.velocity - 75 * dt < 0 then
			currentPlayer.velocity = 0
		else
			currentPlayer.velocity = currentPlayer.velocity - 75 * dt
		end
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
	local g1x, g1y = player1.gorilla:center()
	local g2x, g2y = player2.gorilla:center()
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

	-- draw player fields
	love.graphics.setColor(255,255,255,255)
	love.graphics.print(currentPlayer.name, currentPlayer.inputsX, currentPlayer.inputsY)
	love.graphics.print(string.format("Angle: %s", currentPlayer.angle), currentPlayer.inputsX, currentPlayer.inputsY + 20 )
	love.graphics.print(string.format("Power: %s", currentPlayer.velocity), currentPlayer.inputsX, currentPlayer.inputsY + 40)

	-- Draw score field
	love.graphics.setColor(0,0,255,255)
	love.graphics.rectangle( 'fill', 350, 575, 97, 15 )
	love.graphics.setColor(255,255,255,255)
	love.graphics.print(string.format("%s > Score < %s", player1.score, player2.score ), 355, 576)

	if gameOver then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle('fill', 0, 0, 800, 600)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print('GAME OVER!', 320, 300)
		love.graphics.print(string.format("%s Score - %s", player1.name, player1.score), 320, 315)
		love.graphics.print(string.format("%s Score - %s", player2.name, player2.score), 320, 330)
		local winner
		if player1.score > player2.score then
			winner = player1
		else
			winner = player2
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

-------------------------------------
-- Spawn a banana and start it moving along a given angle at a given speed
-- @method fireBanana
-------------------------------------
function fireBanana()
	local gx, gy = currentPlayer.gorilla:center()
	local banana = Collider:addRectangle(gx , gy , 7, 7)
	local angle

	if currentPlayer == player2 then
		angle = 180 - currentPlayer.angle
	else
		angle = currentPlayer.angle
	end

	--banana angle (in radians) and initial impuls velocity
	banana.angle = angle * (math.pi/180)
	banana.impulse = currentPlayer.velocity

	--calc velocity for x and y vectors
	banana.velocity = { }
	--double the impulse value so you dont have to enter such a large value
	banana.velocity.x = ( banana.impulse * 2 ) * math.cos(banana.angle)
	banana.velocity.y = ( banana.impulse * 2 ) * math.sin(banana.angle) * -1

	--setup other banana vars
	banana.thrownBy = currentPlayer.gorilla
	banana.typeOf = 'banana'
	banana.inExplosion = false

	if #bananas == 0 then
		table.insert(bananas, banana)
	end


end

-------------------------------------
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

-------------------------------------
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
		banana.inExplosion = true
		return
	-- Building collision handler
	elseif other.typeOf == 'building' and banana.inExplosion == false then
		-- Create explosion object
		local ex, ey = banana:center()
		local explosion = Collider:addCircle(ex, ey, 10)
		Collider:addToGroup( 'groupB', explosion )
		explosion.typeOf = 'explosion'

		-- Add explosion to the explosions table
		table.insert(explosions, explosion)

		-- Destroy the banana and remove it from collider objects
		table.remove(bananas, 1)
		Collider:remove(banana)

		-- Change turns
		changeTurn()

	-- Gorilla collision handler
	elseif other.typeOf == 'gorilla' then
		-- Make sure this isnt the banana colliding with the thrower
		if banana.thrownBy ~= other then

			-- Destroy the banana and remove it from collider objects
			table.remove(bananas, 1)
			Collider:remove(banana)

			-- Give a point to the thrower
			currentPlayer.score = currentPlayer.score + 1
			-- If the currentPlayer has scored 3, game over man
			if currentPlayer.score == 3 then
				gameOver = true
			end

			-- Clear any collision objects from the previous level
			cleanupObjects()
			-- Generate new level
			generateLevel()
			-- Change turns
			changeTurn()

		end
	elseif other.typeOf == 'sun' then
		-- Set the wasHit flag on the sun to change to the oh-face
		other.wasHit = true
	end
end

-------------------------------------
-- Flip the value of the global currentPlayer variable
-- @method changeTurn
-------------------------------------
function changeTurn()

	if currentPlayer == player1 then
		currentPlayer = player2
	elseif currentPlayer == player2 then
		currentPlayer = player1
	end
	-- Clear the oh-face off of the sun
	sun.wasHit = false
end

-------------------------------------
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

	-- Grab random buildings from the table
	-- Player1 is constrained to the left half of the screen, and Player2 the right
	gorilla1Building = buildings[math.random(5)]
	gorilla2Building = buildings[math.random(5) + 5]

	-- Instantiate gorillas
	player1.gorilla = Collider:addRectangle(gorilla1Building.x + 15, gorilla1Building.y - 30, 30, 30)
	player1.gorilla.typeOf = 'gorilla'

	player2.gorilla = Collider:addRectangle(gorilla2Building.x + 15, gorilla2Building.y - 30, 30, 30)
	player2.gorilla.typeOf = 'gorilla'

	Collider:addToGroup('groupB', player1.gorilla, player2.gorilla )
end

-------------------------------------
-- Method to clean up any left over collision objects when re-generating levels
-- @method cleanupObjects
-------------------------------------
function cleanupObjects()
	-- Reset both players angles and velocity
	player1.angle = 0
	player1.velocity = 0
	player2.angle = 0
	player1.velocity = 0

	-- Iterate buildings and explosions and remove them and their collision entities
	local collisionObjects = { buildings, explosions }
	for i in pairs(collisionObjects) do
		for k,v in ipairs(collisionObjects[i]) do
			Collider:remove(v)
			collisionObjects[i][k] = nil
		end
	end

	-- Remove collision entities for both gorillas and any stray bananas
	Collider:remove( player1.gorilla, player2.gorilla, banana )
end