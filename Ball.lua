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
	-- -- self.x = self.x + self.dx * dt
	-- self:moveX(self.dx * dt)
	-- -- self.y = self.y + self.dy * dt
	-- self:moveY(self.dy * dt)

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

	self:setDx(BALL_DX * sign(distanceX))

	local move = math.floor(distanceX)

	if distanceX ~= 0 then
		local move_sign = sign(distanceX)
		while move ~= 0 do
			self.x = self.x + move_sign
			move = move - move_sign
		end
	end
end

function Ball:moveY(distanceY)
	self.state = "moving"

	local move = math.floor(distanceY)

	if distanceY ~= 0 then
		local move_sign = sign(distanceY)
		while move ~= 0 do
			if self:collidesAt(self.y + move_sign) then
				self:setDy(-self.dy)
				break
			else
				self.y = self.y + move_sign
				move = move - move_sign
			end
		end
	end
end

function Ball:collidesAt(position)
	if position <= TOP_WALL or position + self.height >= BOTTOM_WALL + 10 then
		return true
	end

	return false
end

function Ball:setDx(speed)
	self.dx = speed * slowingFactor
end

function Ball:setDy(speed)
	self.dy = speed * slowingFactor
end
