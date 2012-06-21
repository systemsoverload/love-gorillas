HC = require "HardonCollider"

local text = {}

function love.load()

	Collider = HC(100, on_collide )
	buildings = {}

	--Generate random buildings
	for i=0,9 do
		building = {}
		building.red = math.random( 255 )
		building.green = math.random( 255 )
		building.blue = math.random( 255 )
		building.width = 80
		-- NOTE - Temp make all buildings same height for testing
		building.height = 100--math.random(250)
		building.x = 80 * i
		building.y = 600 - building.height
		table.insert(buildings, building)
	end

	--Grab random buildings from the table
	--Gorilla1 is constrained to the left half of the screen, and gorilla2 the right
	gorilla1Building = buildings[math.random(5)]
	gorilla2Building = buildings[math.random(5) + 5]

	gorilla1 = Collider:addRectangle(gorilla1Building.x + 15, gorilla1Building.y - 30, 30, 30)
	gorilla2 = Collider:addRectangle(gorilla2Building.x + 15, gorilla2Building.y - 30, 30, 30)

	sunImage = love.graphics.newImage("/images/sun.png")
	gorillaImage = love.graphics.newImage("/images/gorilla_stand.png")

end

function love.update(dt)
	if banana then
		banana:move(banana.velocity.x * dt, banana.velocity.y * dt)
	end

	Collider:update(dt)
end

function love.draw()
	--draw out skybox
	love.graphics.setColor(0,0,255)
	love.graphics.rectangle("fill",0,0,800,600)

	--Draw random buildings
	for i,v in ipairs(buildings) do
		love.graphics.setColor(v.red,v.green,v.blue,255);
		love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
	end

	--Draw bananas
	if banana then
		banana:draw('fill')
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
		love.event.push("quit")   -- actually causes the app to quit
	end
end

function fireBanana(thrownBy)
	local gx, gy = thrownBy:center()
	banana = Collider:addRectangle(gx, gy, 10, 10)
	banana.velocity = { x = 100, y = 0}
	banana.thrownBy = thrownBy
end

function on_collide( dt, shape_a, shape_b, mtv_x, mtv_y )
	if shape_b.thrownBy and shape_b.thrownBy ~= shape_a then
		text[#text+1] = string.format("Colliding - (%s,%s)", mtv_x, mtv_y)
	end
end