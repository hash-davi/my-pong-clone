Paddle = Class({})

require("characters.paddle.Static")
require("characters.paddle.Dynamic")

function Paddle:init(position, dimensions, playable, side)
	self.position = position
	self.dimensions = dimensions
	self.playable = playable
	self.dy = 0

	self.side = side

	self.cooldown = 0

	self.stateMachine = StateMachine({
		["static"] = function()
			return Static()
		end,
		["dynamic"] = function()
			return Dynamic()
		end,
	})
	self.mode = "normal"
end

function Paddle:load(info)
	StageCharacters = info.stageCharacters
	self.stateMachine:transitionTo(
		"static",
		{ stateMachine = self.stateMachine, parent = self, stageCharacters = StageCharacters }
	)
end

function Paddle:render()
	-- self.stateMachine:render()
	if self.mode == "stretched" then
		love.graphics.setColor(241 / 255, 81 / 255, 82 / 255)
	else
		love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	end
	love.graphics.rectangle("fill", self.position.x, self.position.y, self.dimensions.width, self.dimensions.height)
end

function Paddle:update(dt)
	self.stateMachine:update(dt)

	if self.mode ~= "normal" then
		self.cooldown = self.cooldown + dt

		if self.cooldown >= 10 then
			self:modify("normal")
		end
	end
end

function Paddle:track(ball, dt)
	local ball_sx = self.position.x - (ball.position.x + ball.dimensions.width)
	local ball_dt = (ball.dx / ball_sx) * dt

	local ball_sy = ball.dy * ball_dt
	local final_position = {
		x = ball.position.x + ball.dimensions.width + ball_sx,
		y = ball.position.y + ball.dimensions.height + ball_sy,
	}

	if final_position.y > self.position.y + self.dimensions.height then -- If the ball will fall below the paddle
		self:setSpeed(PLAYER_VELOCITY)
		self:moveY(self.dy * dt * slowingFactor)
	elseif final_position.y < self.position.y then -- If the ball will fall above the paddle
		self:setSpeed(-PLAYER_VELOCITY)
		self:moveY(self.dy * dt * slowingFactor)
	else
		self:stop()
	end
end

function Paddle:modify(type)
	self.mode = type

	if self.mode == "normal" then
		self.dimensions.width = PADDLE_WIDTH
		self.dimensions.height = PADDLE_HEIGHT
		self.cooldown = 0
	elseif self.mode == "stretched" then
		if self.dy == 0 then
			self:moveY(-(self.dimensions.height - PADDLE_HEIGHT / 2))
		end
		self.dimensions.height = PADDLE_HEIGHT * 1.5
	end
end

function Paddle:moveY(distanceY)
	if distanceY ~= 0 then
		if self:collidesAt(self.position.y + distanceY) then
			self:stop()
			self.stateMachine:transitionTo(
				"static",
				{ stateMachine = self.stateMachine, parent = self, stageCharacters = StageCharacters }
			)
		else
			self.position.y = self.position.y + distanceY
		end
	end
end

function Paddle:collidesAt(position)
	if position <= TOP_WALL or self.dimensions.height + position >= BOTTOM_WALL + 10 then
		return true
	end

	return false
end

function Paddle:setSpeed(speed)
	self.dy = speed
end

function Paddle:stop()
	self.dy = 0
	-- self.state = "static"
end
