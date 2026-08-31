Select = Class({ __includes = BaseState })

function Select:load(info)
	self.parentStateMachine = info.stateMachine

	self.timers = info.timers
	self.mode = info.mode

	self.score = info.score

	self.characters = info.characters
	self.paddles = info.paddles
end

function Select:update(dt)
	if love.keyboard.wasPressed("w") or love.keyboard.wasPressed("s") then
		Stage:activate(self.characters.leftPaddle)
	end

	if love.keyboard.wasPressed("up") or love.keyboard.wasPressed("down") then
		Stage:activate(self.characters.rightPaddle)
	end

	-- Left Paddle ------
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

	if love.keyboard.wasPressed("return") then
		self.parentStateMachine:transitionTo("serve", {
			stateMachine = self.parentStateMachine,
			server = 1,
			mode = self.mode,
			timers = self.timers,
			score = self.score,
			modifiers = {},
			characters = self.characters,
			paddles = self.paddles,
		})
	end
end

function Select:render()
	for i, character in pairs(self.characters) do
		character:render()
	end
end
