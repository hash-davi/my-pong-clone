Modifier = Class({})

function Modifier:init(type)
	self.x = math.random(30, VIRTUAL_WIDTH - 32)
	self.y = math.random(TOP_WALL + 10, VIRTUAL_HEIGHT - 23)
	self.width = 15
	self.height = 15

	self.type = type
	self.range = "paddle"
end

function Modifier:render()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end
