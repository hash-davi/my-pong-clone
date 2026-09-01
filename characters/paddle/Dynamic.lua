Dynamic = Class({ __includes = BaseState })

function Dynamic:init(paddle)
	self.paddle = paddle
end

function Dynamic:load(info)
	self.stageCharacters = info.stageCharacters
end

function Dynamic:update(dt)
	if self.paddle.side == 1 then
		self:leftControl(dt)
	elseif self.paddle.side == 2 then
		self:rightControl(dt)
	end
end

function Dynamic:leftControl(dt)
	if self.paddle.playable then
		if love.keyboard.isDown("w") then
			self.paddle:setSpeed(-PLAYER_VELOCITY)
			self.paddle:moveY(self.paddle.dy * dt * slowingFactor)
		elseif love.keyboard.isDown("s") then
			self.paddle:setSpeed(PLAYER_VELOCITY)
			self.paddle:moveY(self.paddle.dy * dt * slowingFactor)
		else
			self.paddle:setSpeed(0)
			self.paddle.stateMachine:transitionTo("static", {
				stageCharacters = self.stageCharacters,
			})
		end
	else
		if self.stageCharacters.ball.dx < 0 and self.stageCharacters.ball.position.x <= VIRTUAL_WIDTH / 2 then
			self.paddle:track(self.stageCharacters.ball, dt)
		else
			self.paddle:setSpeed(0)
			self.paddle.stateMachine:transitionTo("static", {
				stageCharacters = self.stageCharacters,
			})
		end
	end
end

function Dynamic:rightControl(dt)
	if self.paddle.playable then
		if love.keyboard.isDown("up") then
			self.paddle:setSpeed(-PLAYER_VELOCITY)
			self.paddle:moveY(self.paddle.dy * dt * slowingFactor)
		elseif love.keyboard.isDown("down") then
			self.paddle:setSpeed(PLAYER_VELOCITY)
			self.paddle:moveY(self.paddle.dy * dt * slowingFactor)
		else
			self.paddle:setSpeed(0)
			self.paddle.stateMachine:transitionTo("static", {
				stageCharacters = self.stageCharacters,
			})
		end
	else
		if self.stageCharacters.ball.dx > 0 and self.stageCharacters.ball.position.x >= VIRTUAL_WIDTH / 2 then
			self.paddle:track(self.stageCharacters.ball, dt)
		else
			self.paddle:setSpeed(0)
			self.paddle.stateMachine:transitionTo("static", {
				stageCharacters = self.stageCharacters,
			})
		end
	end
end

function Dynamic:render()
	if self.paddle.mode == "stretched" then
		love.graphics.setColor(241 / 255, 81 / 255, 82 / 255)
	else
		love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	end
	love.graphics.rectangle(
		"fill",
		self.paddle.position.x,
		self.paddle.position.y,
		self.paddle.dimensions.width,
		self.paddle.dimensions.height
	)
end
