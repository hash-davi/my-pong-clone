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
	local ball_sx = self.x - (ball.x + ball.width)
	local ball_dt = ball.dx / ball_sx

	local ball_sy = ball.dy * ball_dt
	local final_position = {
		x = ball.x + ball.width + ball_sx,
		y = ball.y + ball.height + ball_sy,
	}

	local paddle_sy = final_position.y - (self.y + self.height / 2)

	if paddle_sy > 0 then -- If the ball will fall below the paddle
		-- self.dy = math.min(paddle_sy / ball_dt, PLAYER_VELOCITY)
		self:moveY((-paddle_sy / ball_dt) * dt)
	elseif paddle_sy < 0 then -- If the ball will fall above the paddle
		-- self.dy = math.max((paddle_sy - ball.height) / ball_dt, -PLAYER_VELOCITY)
		self:moveY((paddle_sy / ball_dt) * dt)
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
		self.height = PADDLE_HEIGHT * 1.5
		if self.y - TOP_WALL >= (self.height - PADDLE_HEIGHT) / 2 then
			-- self.y = self.y - (self.height - PADDLE_HEIGHT) / 2
			self:moveY((self.height - PADDLE_HEIGHT / 2))
		end
	end
end

function Paddle:moveY(distanceY)
	self.state = "moving"

	self:setSpeed(PLAYER_VELOCITY * sign(distanceY))

	local move = math.floor(distanceY)

	if distanceY ~= 0 then
		local move_sign = sign(distanceY)
		while move ~= 0 do
			if self:collidesAt(self.y + move_sign) then
				self:stop()
				break
			else
				self.y = self.y + move_sign
				move = move - move_sign
			end
		end
	end
end

function Paddle:collidesAt(position)
	if position <= TOP_WALL or position + self.height >= BOTTOM_WALL + 10 then
		return true
	end

	return false
end

function Paddle:setSpeed(speed)
	self.dy = speed * slowingFactor
end

function Paddle:stop()
	self.dy = 0
	self.state = "static"
end
