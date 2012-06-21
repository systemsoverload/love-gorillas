HC = require "HardonCollider"
anim8 = require "anim8/anim8"

local text = {}

function love.load()

	Collider = HC(100, on_collide )
	buildings = {}

	--Generate random buildings
	for i=0,9 do
		local height =  100--math.random(250)
		local buildingX = i * 80
		local buildingY = 600 - height
		building = Collider:addRectangle( buildingX, buildingY, height, 80)
		building.red = math.random( 255 )
		building.green = math.random( 255 )
		building.blue = math.random( 255 )
		building.x = buildingX
		building.y = buildingY
		-- NOTE - Temp make all buildings same height for testing
		building.typeOf = 'building'
		table.insert(buildings, building)
	end

	--Grab random buildings from the table
	--Gorilla1 is constrained to the left half of the screen, and gorilla2 the right
	gorilla1Building = buildings[math.random(5)]
	gorilla2Building = buildings[math.random(5) + 5]

	gorilla1 = Collider:addRectangle(gorilla1Building.x + 15, gorilla1Building.y - 30, 30, 30)
	gorilla1.typeOf = 'gorilla'
	gorilla2 = Collider:addRectangle(gorilla2Building.x + 15, gorilla2Building.y - 30, 30, 30)
	gorilla2.typeOf = 'gorilla'

	sunImage = love.graphics.newImage("/images/sun.png")
	gorillaImage = love.graphics.newImage("/images/gorilla_stand.png")

	bananaImage = love.graphics.newImage("/images/banana.png")
	bananaGrid = anim8.newGrid(7, 7, bananaImage:getWidth(), bananaImage:getHeight())
	Bananimation = anim8.newAnimation('loop', bananaGrid('1-4,1'), 0.1)
end

function love.update(dt)
	if banana then
		banana:move(banana.velocity.x * dt, banana.velocity.y * dt)
	end

	while #text > 40 do
	    table.remove(text, 1)
	end

	Bananimation:update(dt)
	Collider:update(dt)
end

function love.draw()
	--draw out skybox
	love.graphics.setColor(0,0,255)
	love.graphics.rectangle("fill",0,0,800,600)

	--Draw random buildings
	for i,v in ipairs(buildings) do
		love.graphics.setColor(v.red,v.green,v.blue,255);
		v:draw('fill')
	end

	--Draw bananas
	if banana then
		local bx, by = banana:center()
		love.graphics.setColor(255,255,255,255)
		Bananimation:draw(bananaImage, bx, by)
	end

	--Draw the gorillas
	local g1x, g1y = gorilla1:center()
	local g2x, g2y = gorilla2:center()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(gorillaImage, g1x - 15 , g1y - 15 )
	love.graphics.draw(gorillaImage, g2x - 15 , g2y - 15 )

	--Draw the sun!
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(sunImage, 400, 25)

	for i = 1,#text do
		love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
		love.graphics.print(text[#text - (i-1)], 10, i * 15)
	end
end

function love.keyreleased(key)
	if key == " " then
		fireBanana(gorilla1)
	end
	if key == "escape" then
		love.event.push("quit")
	end
end

function fireBanana(thrownBy)
	local gx, gy = thrownBy:center()
	banana = Collider:addRectangle(gx, gy, 10, 10)
	banana.velocity = { x = 100, y = 0}
	banana.thrownBy = thrownBy
	banana.typeOf = 'banana'
end

function on_collide( dt, shape_a, shape_b, mtv_x, mtv_y )
	--Collision check for gorillas, make sure it's not a gorilla hitting itself on the throw
	if shape_a.typeOf == 'gorilla' and shape_b.thrownBy and shape_b.thrownBy ~= shape_a then
		text[#text+1] = string.format("Banana Colliding With GORILLA - (%s,%s)", mtv_x, mtv_y)
		shape_b.velocity = { x = 0, y = 0}
		banana = nil
		Bananimation:pause()
	end

	--Collision check for building
	if shape_a.typeOf == 'building' then
		text[#text+1] = string.format("Banana Colliding With BUILDING - (%s,%s)", mtv_x, mtv_y)
	end
end