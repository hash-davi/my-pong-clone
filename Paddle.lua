Paddle = Class({})

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
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Paddle:update(dt)
	self.state = self.dy == 0 and "static" or "moving"

	if self.state == "moving" then
		if self.dy < 0 then
			self.y = math.max(self.y + self.dy * dt, TOP_WALL)
		else
			self.y = math.min(self.y + self.dy * dt, BOTTOM_WALL - self.height + 10)
		end
	elseif self.state == "static" then
		self.dy = 0
	end

	if self.y == BOTTOM_WALL - self.height + 10 or self.y == TOP_WALL then
		self.dy = 0
	end

	if self.mode ~= "normal" then
		self.cooldown = self.cooldown + dt

		if self.cooldown >= 10 then
			self.mode = "normal"
			self:modify()
			self.cooldown = 0
		end
	end
end

function Paddle:track(ball)
	local ball_sx = self.x - (ball.x + ball.width)
	local ball_dt = ball.dx / ball_sx

	local ball_sy = ball.dy * ball_dt
	local final_position = {
		x = ball.x + ball.width + ball_sx,
		y = ball.y + ball.height + ball_sy,
	}

	local paddle_sy = final_position.y - (self.y + self.height / 2)

	if paddle_sy > 0 then -- If the ball will fall below the paddle
		self.dy = math.min(paddle_sy / ball_dt, PLAYER_VELOCITY)
	elseif paddle_sy < 0 then -- If the ball will fall above the paddle
		self.dy = math.max((paddle_sy - ball.height) / ball_dt, -PLAYER_VELOCITY)
	else
		self.dy = 0
	end
end

function Paddle:modify(type)
	self.mode = type

	if self.mode == "normal" then
		self.width = PADDLE_WIDTH
		self.height = PADDLE_HEIGHT
	elseif self.mode == "stretched" then
		self.height = PADDLE_HEIGHT * 1.5
		if self.y - TOP_WALL >= (self.height - PADDLE_HEIGHT) / 2 then
			self.y = self.y - (self.height - PADDLE_HEIGHT) / 2
		end
	end
end

function Paddle:moveUp()
	self.dy = self.mode == "slower" and -PLAYER_VELOCITY * 0.5 or -PLAYER_VELOCITY
end

function Paddle:moveDown()
	self.dy = self.mode == "slower" and PLAYER_VELOCITY * 0.5 or PLAYER_VELOCITY
end
