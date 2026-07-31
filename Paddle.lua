Paddle = Class({})

function Paddle:init(x, y, width, height, playable)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.playable = playable
	self.dy = 0

	self.state = "static"
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
