Serve = Class({ __includes = BaseState })

function Serve:load(info)
	self.parentStateMachine = info.stateMachine

	self.server = info.server
	self.timers = info.timers
	self.mode = info.mode

	self.score = info.score

	self.modifiers = info.modifiers
	self.characters = info.characters
	self.paddles = info.paddles
end

function Serve:update(dt)
	self.characters.ball:reset()

	-- Left paddle ------
	if self.characters.leftPaddle.playable then
		if love.keyboard.isDown("w") then
			self.characters.leftPaddle:setSpeed(-PLAYER_VELOCITY)
			self.characters.leftPaddle:moveY(self.characters.leftPaddle.dy * dt * slowingFactor)
		elseif love.keyboard.isDown("s") then
			self.characters.leftPaddle:setSpeed(PLAYER_VELOCITY)
			self.characters.leftPaddle:moveY(self.characters.leftPaddle.dy * dt * slowingFactor)
		else
			self.characters.leftPaddle:stop()
		end
	end

	-- Right Paddle ------
	if self.characters.rightPaddle.playable then
		if love.keyboard.isDown("up") then
			self.characters.rightPaddle:setSpeed(-PLAYER_VELOCITY)
			self.characters.rightPaddle:moveY(self.characters.rightPaddle.dy * dt * slowingFactor)
		elseif love.keyboard.isDown("down") then
			self.characters.rightPaddle:setSpeed(PLAYER_VELOCITY)
			self.characters.rightPaddle:moveY(self.characters.rightPaddle.dy * dt * slowingFactor)
		else
			self.characters.rightPaddle:stop()
		end
	end

	for i, paddle in pairs(self.paddles) do
		paddle:update(dt)
	end

	if self.server == 1 then
		self.characters.ball.dx = BALL_DX
	elseif self.server == 2 then
		self.characters.ball.dx = -BALL_DX
	end

	if love.keyboard.wasPressed("return") then
		self.parentStateMachine:transitionTo("rally", {
			stateMachine = self.parentStateMachine,
			rallyTime = 0,
			mode = self.mode,
			score = self.score,
			modifiers = self.modifiers,
			characters = self.characters,
			paddles = self.paddles,
			timers = self.timers,
		})
	end
end

function Serve:render()
	if self.server == 1 then
		love.graphics.printf("Left's serve", 0, 30, VIRTUAL_WIDTH, "center")
	elseif self.server == 2 then
		love.graphics.printf("Right's serve", 0, 30, VIRTUAL_WIDTH, "center")
	end

	showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
	showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)

	for i, character in pairs(self.characters) do
		character:render()
	end

	if #self.modifiers ~= 0 then
		for i, mod in pairs(self.modifiers) do
			mod:render()
		end
	end
end
