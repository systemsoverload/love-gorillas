HC = require "HardonCollider"

function love.load()
	Collider = HC(100, on_collide )
	gorilla2 = {}
	buildings = {}

	for i=0,9 do
		building = {};
		building.red = math.random( 255 )
		building.green = math.random( 255 )
		building.blue = math.random( 255 )
		building.width = 80;
		building.height = math.random(250)
		building.x = 80 * i
		building.y = 600 - building.height
		table.insert(buildings, building)
	end
	gorilla1Building = buildings[math.random(7)]
	gorilla2Building = buildings[math.random(7)]

	gorilla1 = Collider:addRectangle(gorilla1Building.x + 15, gorilla1Building.y - 30, 30, 30)
	gorilla1.image = love.graphics.newImage('/images/gorilla_stand.png')

	gorilla2.x = gorilla2Building.x + 15
	gorilla2.y = gorilla2Building.y - 30

	sunImage = love.graphics.newImage("/images/sun.png")
	gorillaImage = love.graphics.newImage("/images/gorilla_stand.png")
end

function love.update(dt)

end

function love.draw()
	--draw out skybox
	love.graphics.setColor(0,0,255)
	love.graphics.rectangle("fill",0,0,800,600)

	--Draw out random buildings
	for i,v in ipairs(buildings) do
		love.graphics.setColor(v.red,v.green,v.blue,255);
		love.graphics.rectangle("fill", v.x, v.y, v.width, v.height);
	end

	-- --Draw gorilla1
	-- love.graphics.setColor(255,255,255,255)
	-- love.graphics.draw(gorillaImage, gorilla1.x, gorilla1.y)
	gorilla1:draw('fill')
	--Draw gorilla1
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(gorillaImage, gorilla2.x, gorilla2.y)

	--Draw the sun!
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(sunImage, 400, 25)
end

function on_collide( dt, shape_a, shape_b )

end