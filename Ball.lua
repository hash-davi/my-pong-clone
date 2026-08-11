Ball = Class({})

function Ball:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height

	self.dx = BALL_DX
	self.dy = 0

	self.cooldown = 0

	self.mode = "normal"
end

function Ball:update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt

	if self.mode == "slower" then
		self.cooldown = self.cooldown + dt

		if self.cooldown >= 10 then
			self:modify("normal")
		end
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
	self.dy = math.random(-100, 100)
end

function Ball:modify(type)
	self.mode = type

	if self.mode == "normal" then
		self.dx = self.dx * 2
		self.dy = self.dy * 2
		self.cooldown = 0
	elseif self.mode == "slower" then
		lastDx = self.dx
		lastDy = self.dy
		self.dx = self.dx >= 0 and math.max(self.dx * 0.5, BALL_DX * 0.5) or math.max(self.dx * 0.5, -BALL_DX * 0.5)
		self.dy = self.dy * 0.5
	end
end
