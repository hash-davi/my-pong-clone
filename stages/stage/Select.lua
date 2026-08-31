Select = Class({ __includes = BaseState })

function Select:update(dt)
	if love.keyboard.wasPressed("w") or love.keysPressed("s") then
		Stage:activate(Stage.characters.leftPaddle)
	end

	if love.keyboard.wasPressed("up") or love.keysPressed("down") then
		Stage:activate(Stage.characters.rightPaddle)
	end

	-- Left Paddle ------
	if Stage.characters.leftPaddle.playable then
		if love.keyboard.isDown("w") then
			Stage.characters.leftPaddle:setSpeed(-PLAYER_VELOCITY)
			Stage.characters.leftPaddle:moveY(Stage.characters.leftPaddle.dy * dt * slowingFactor)
		elseif love.keyboard.isDown("s") then
			Stage.characters.leftPaddle:setSpeed(PLAYER_VELOCITY)
			Stage.characters.leftPaddle:moveY(Stage.characters.leftPaddle.dy * dt * slowingFactor)
		else
			Stage.characters.leftPaddle:stop()
		end
	end

	-- Right Paddle ------
	if Stage.characters.rightPaddle.playable then
		if love.keyboard.isDown("up") then
			Stage.characters.rightPaddle:setSpeed(-PLAYER_VELOCITY)
			Stage.characters.rightPaddle:moveY(Stage.characters.rightPaddle.dy * dt * slowingFactor)
		elseif love.keyboard.isDown("down") then
			Stage.characters.rightPaddle:setSpeed(PLAYER_VELOCITY)
			Stage.characters.rightPaddle:moveY(Stage.characters.rightPaddle.dy * dt * slowingFactor)
		else
			Stage.characters.rightPaddle:stop()
		end
	end

	for i, paddle in pairs(Stage.paddles) do
		paddle.update(dt)
	end

	if love.keyboard.wasPressed("return") then
		Stage.stateMachine:transitionTo("serve", { server = 1 })
	end
end
