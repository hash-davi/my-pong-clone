Ball = Class({})

function Ball:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height

	self.dx = BALL_DX
	self.dy = math.random(2) == 1 and -100 or 100
end

function Ball:update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt

	if self.y >= BOTTOM_WALL or self.y <= TOP_WALL then
		self.dy = -self.dy
	end
end

function Ball:render()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Ball:collidesWith(paddle)
	if self.x > paddle.x + paddle.width or self.x + self.width < paddle.x then
		return false
	end

	if self.y > paddle.y + paddle.height or self.y + self.height < paddle.y then
		return false
	end

	return true
end

function Ball:reset()
	self.x = 201
	self.y = VIRTUAL_HEIGHT / 2
	self.dx = BALL_DX
	self.dy = math.random(-50, 50)
end
