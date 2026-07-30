Paddle = Class({})

function Paddle:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
end

function Paddle:render()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Paddle:update(dt)
	if love.keyboard.isDown("w") then
		self.y = math.max(self.y - 200 * dt, 15)
	end
	if love.keyboard.isDown("s") then
		self.y = math.min(self.y + 200 * dt, VIRTUAL_HEIGHT - 45)
	end
end
