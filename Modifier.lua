Modifier = Class({})

function Modifier:init(type)
	self.x = math.random(30, 400)
	self.y = math.random(TOP_WALL + 10, 220)
	self.width = 15
	self.height = 15

	self.type = type
end

function Modifier:render()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end
