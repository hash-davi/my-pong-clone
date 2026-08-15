Paddle = Class({})

function sign(num)
	if num > 0 then
		return 1
	elseif num < 0 then
		return -1
	else
		return 0
	end
end

function Paddle:init(x, y, width, height, playable)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.playable = playable
	self.dy = 0

	self.cooldown = 0

	self.state = "static"
	self.mode = "normal"
end

function Paddle:render()
	if self.mode == "stretched" then
		love.graphics.setColor(241 / 255, 81 / 255, 82 / 255)
	end
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
end

function Paddle:update(dt)
	if self.state == "static" then
		self:stop()
	end

	if self.mode ~= "normal" then
		self.cooldown = self.cooldown + dt

		if self.cooldown >= 10 then
			self:modify("normal")
		end
	end
end

function Paddle:track(ball, dt)
	local ball_sx = self.x - (ball.x + ball.width)
	local ball_dt = (ball.dx / ball_sx) * dt

	local ball_sy = ball.dy * ball_dt
	local final_position = {
		x = ball.x + ball.width + ball_sx,
		y = ball.y + ball.height + ball_sy,
	}

	if final_position.y > self.y + self.height then -- If the ball will fall below the paddle
		-- self.dy = math.min(paddle_sy / ball_dt, PLAYER_VELOCITY)
		self:setSpeed(PLAYER_VELOCITY)
		self:moveY(self.dy * dt * slowingFactor)
	elseif final_position.y < self.y then -- If the ball will fall above the paddle
		-- self.dy = math.max((paddle_sy - ball.height) / ball_dt, -PLAYER_VELOCITY)
		self:setSpeed(-PLAYER_VELOCITY)
		self:moveY(self.dy * dt * slowingFactor)
	else
		self:stop()
	end
end

function Paddle:modify(type)
	self.mode = type

	if self.mode == "normal" then
		self.width = PADDLE_WIDTH
		self.height = PADDLE_HEIGHT
		self.cooldown = 0
	elseif self.mode == "stretched" then
		if self.dy == 0 then
			self:moveY(-(self.height - PADDLE_HEIGHT / 2))
		end
		self.height = PADDLE_HEIGHT * 1.5
	end
end

function Paddle:moveY(distanceY)
	self.state = "moving"

	if distanceY ~= 0 then
		if self:collidesAt(self.y + distanceY) then
			self:stop()
		else
			self.y = self.y + distanceY
		end
	end
end

function Paddle:collidesAt(position)
	if position <= TOP_WALL or self.height + position >= BOTTOM_WALL + 10 then
		return true
	end

	return false
end

function Paddle:setSpeed(speed)
	self.dy = speed
end

function Paddle:stop()
	self.dy = 0
	self.state = "static"
end
