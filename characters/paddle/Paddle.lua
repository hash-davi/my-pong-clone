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
			return Static(self)
		end,
		["dynamic"] = function()
			return Dynamic(self)
		end,
	})
	self.mode = "normal"
end

function Paddle:load(info)
	StageCharacters = info.stageCharacters
	self.stateMachine:transitionTo("static", {
		stageCharacters = StageCharacters,
	})
end

function Paddle:render()
	self.stateMachine:render()
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
	local ballSx = self.side == 1 and ball.position.x - (self.position.x + self.dimensions.width)
		or self.position.x - (ball.position.x + ball.dimensions.width)
	local ball_dt = self.side == 1 and (-ball.dx / ballSx) * dt or (ball.dx / ballSx) * dt

	local ballSy = ball.dy * ball_dt
	local finalPosition = {
		x = self.side == 1 and ball.position.x - ballSx or ball.position.x + ball.dimensions.width + ballSx,
		y = ball.dy > 0 and ball.position.y + ball.dimensions.height + ballSy or ball.position.y + ballSy,
	}

	if finalPosition.y > self.position.y + (self.dimensions.height * 3) / 4 then -- If the ball will fall below the paddle
		self:setSpeed(PLAYER_VELOCITY)
		self:moveY(self.dy * dt * slowingFactor)
	elseif finalPosition.y < self.position.y + self.dimensions.height / 4 then -- If the ball will fall above the paddle
		self:setSpeed(-PLAYER_VELOCITY)
		self:moveY(self.dy * dt * slowingFactor)
	else
		self:setSpeed(0)
		self.stateMachine:transitionTo("static", { stageCharacters = StageCharacters })
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
			self.stateMachine:transitionTo("static", { stageCharacters = StageCharacters })
		else
			self.position.y = self.position.y + distanceY
		end
	end
end

function Paddle:collidesAt(positionY)
	if positionY <= TOP_WALL or self.dimensions.height + positionY >= BOTTOM_WALL + 10 then
		return true
	end

	return false
end

function Paddle:setSpeed(speed)
	self.dy = speed
end

function Paddle:stop()
	self.dy = 0
end
