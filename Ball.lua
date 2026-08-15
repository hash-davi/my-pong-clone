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
	self.dy = 0

	self.cooldown = 0

	self.state = "static"
	self.mode = "normal"
end

function Ball:update(dt)
	if self.mode ~= "normal" then
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
