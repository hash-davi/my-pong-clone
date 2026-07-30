Paddle = Class({})

function Paddle:init(x, y, width, height, player)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.player = player
	self.dy = 0
end

function Paddle:render()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Paddle:update(dt)
	if self.dy < 0 then
		self.y = math.max(self.y + self.dy * dt, TOP_WALL)
	else
		self.y = math.min(self.y + self.dy * dt, BOTTOM_WALL - self.height + 10)
	end
end
