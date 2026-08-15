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

	self.paddle_sy = 0

	self.cooldown = 0

	self.state = "static"
	self.mode = "normal"
end

function Paddle:render()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
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
	ball_sx = self.x - (ball.x + ball.width)
	ball_dt = ball.dx / ball_sx

	ball_sy = ball.dy * ball_dt
	final_position = {
		x = ball.x + ball.width + ball_sx,
		y = ball.y + ball.height + ball_sy,
	}

	self.paddle_sy = final_position.y - (self.y + self.height / 2)

	if self.paddle_sy > self.height / 2 then -- If the ball will fall below the paddle
		-- self.dy = math.min(paddle_sy / ball_dt, PLAYER_VELOCITY)
		self:setSpeed(PLAYER_VELOCITY)
		self:moveY(self.dy * dt * slowingFactor)
	elseif self.paddle_sy < -self.height / 2 then -- If the ball will fall above the paddle
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
