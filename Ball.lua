Ball = Class({})

function sign(num)
	if num > 0 then
		return 1
	elseif num < 0 then
		return -1
	else
		return 0
	end
end

function Ball:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height

	self.dx = BALL_DX
	self.dy = math.random(-100, 100)

	self.cooldown = 0

	self.line = {}

	self.state = "static"
	self.mode = "normal"
end

function Ball:update(dt)
	local sy = 0
	if self.dy > 0 then
		sy = BOTTOM_WALL + 10 - (self.y + self.height)
	else
		sy = TOP_WALL - self.y
	end
	local deltaTime = math.abs(sy / self.dy)
	local sx = self.dx * deltaTime

	self.line = {
		x = self.x + self.width / 2,
		y = self.y + self.height / 2,
		angle = math.pi / 2,
		end_point = {
			x = sx > 0 and self.x + self.width + sx or self.x + sx,
			y = sy > 0 and self.y + self.height + sy or self.y + sx,
		},
	}

	if self.mode ~= "normal" then
		self.cooldown = self.cooldown + dt

		if self.cooldown >= 10 then
			self:modify("normal")
		end
	end
end

function Ball:render()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	if self.state == "moving" then
		love.graphics.line(self.line.x, self.line.y, self.line.end_point.x, self.line.end_point.y)
	end
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
	self.state = "static"
end

function Ball:modify(type)
	self.mode = type

	if self.mode == "normal" then
		self.cooldown = 0
	end
end

function Ball:moveX(distanceX)
	self.state = "moving"

	if distanceX ~= 0 then
		self.x = self.x + distanceX
	end
end

function Ball:moveY(distanceY)
	self.state = "moving"

	if distanceY ~= 0 then
		self.y = self.y + distanceY
	end
end

function Ball:setDx(speed)
	self.dx = math.min(speed)
end

function Ball:setDy(speed)
	self.dy = math.min(speed, BALL_DX * 2)
end
