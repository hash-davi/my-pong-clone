Modifier = Class({})

function Modifier:init(type)
	self.position = { x = math.random(30, VIRTUAL_WIDTH - 32), y = math.random(TOP_WALL + 10, VIRTUAL_HEIGHT - 23) }
	self.dimensions = {
		width = 15,
		height = 15,
	}

	self.type = type
	self.range = "paddle"
end

function Modifier:render()
	if self.type == "slow_motion" then
		love.graphics.setColor(93 / 255, 211 / 255, 158 / 255)
		love.graphics.rectangle("fill", self.position.x, self.position.y, self.dimensions.width, self.dimensions.height)
		love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	elseif self.type == "stretcher" then
		love.graphics.setColor(241 / 255, 81 / 255, 82 / 255)
		love.graphics.rectangle("fill", self.position.x, self.position.y, self.dimensions.width, self.dimensions.height)
		love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	end
end
