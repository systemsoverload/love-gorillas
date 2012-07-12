HC = require "HardonCollider"
anim8 = require "anim8.anim8"

function love.load()
	require("middleclass.middleclass")
	Banana = require "banana"
	Gorilla = require "gorilla"
	Explosion = require "explosion"

	Collider = HC(100, onCollide, onStopCollision )
	buildings, explosions, bananas, buildingImages = {}, {}, {}, {}

	gameOver = false

	--Load gorilla assets
	Player1 = Gorilla:new('Player 1', 5, 5, 'left' )
	Player2 = Gorilla:new('Player 2', 725, 5, 'right' )

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
end

function love.update(dt)

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
	Player1:draw()
	Player2:draw()

	--Draw explosions
	for i,explosion in ipairs(explosions) do
		explosion:draw()
	end

	--Draw bananas
	for i,banana in ipairs(bananas) do
		banana:draw()
	end

	--Draw the sun
	love.graphics.setColor(255,255,255,255)
	if sun.wasHit == true then
		love.graphics.draw(sunHitImage, 400, 25)
	else
		love.graphics.draw(sunImage, 400, 25)
	end

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

function love.keypressed(key,unicode)
	--Only send numbers or enter key
	if (unicode >= 48 and unicode <= 57)
						or key == 'return'
						or key == 'backspace'
						or key == 'left'
						or key == 'right' then
		currentPlayer:keypressed(key, unicode)
	elseif key == "escape" then
		love.event.push("quit")
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
			if v.bb:contains(banana:center()) then
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

			--Play the victory song
			currentPlayer:celebrate()

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
	currentPlayer.isThrowing = 0
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
			-- If the object is a class, remove its bounding box property instead
			if v.bb then
				Collider:remove(v.bb)
			else
				Collider:remove(v)
			end
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
	local explosion = Explosion:new( x, y, r )
	table.insert(explosions, explosion)
end