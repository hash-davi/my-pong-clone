Rally = Class({ __includes = BaseState })

function Rally:load(info)
	self.time = info.rallyTime
	self.scorer = info.server
end

function Rally:update(dt)
	Stage.timers.mod = Stage.timers.mod + dt
	self.time = self.time + dt

	-- Left paddle ------
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
		paddle:update(dt)
	end

	-- Unplayable paddles -
	if not Stage.characters.leftPaddle.playable then
		if Stage.characters.ball.dx < 0 and Stage.characters.ball.x <= VIRTUAL_WIDTH / 2 then
			Stage.characters.leftPaddle:track(Stage.characters.ball, dt)
		else
			Stage.characters.leftPaddle:stop()
		end
	end

	if not Stage.characters.rightPaddle.playable then
		if Stage.characters.ball.dx > 0 and Stage.characters.ball.x >= VIRTUAL_WIDTH / 2 then
			Stage.characters.rightPaddle:track(Stage.characters.ball, dt)
		else
			Stage.characters.rightPaddle:stop()
		end
	end

	Stage.characters.ball:setDx(Stage.characters.ball.dx)
	Stage.characters.ball:moveX(Stage.characters.ball.dx * dt * slowingFactor)
	Stage.characters.ball:setDy(Stage.characters.ball.dy)
	Stage.characters.ball:moveY(Stage.characters.ball.dy * dt * slowingFactor)

	-- Stage.characters.ball --------------
	if Stage.characters.ball:collidesWith(Stage.characters.leftPaddle) then
		Stage.characters.ball:setDx(-Stage.characters.ball.dx * 1.05)
		Stage.characters.ball:setDy(Stage.characters.ball.dy + Stage.characters.leftPaddle.dy / 2)
		Stage.characters.ball:moveX(
			Stage.characters.leftPaddle.x + Stage.characters.leftPaddle.width + 1 - Stage.characters.ball.x
		)
		self.scorer = 1

		love.audio.play(sounds["hit_sound"])
	end
	if Stage.characters.ball:collidesWith(Stage.characters.rightPaddle) then
		Stage.characters.ball:setDx(-Stage.characters.ball.dx * 1.05)
		Stage.characters.ball:setDy(Stage.characters.ball.dy + Stage.characters.rightPaddle.dy / 2)
		Stage.characters.ball:moveX(
			Stage.characters.rightPaddle.x - Stage.characters.ball.width - 1 - Stage.characters.ball.x
		)
		self.scorer = 2

		love.audio.play(sounds["hit_sound"])
	end

	for i, mod in pairs(Stage.modifiers) do
		if Stage.characters.ball:collidesWith(mod) then
			if modRanges[mod.type] == "paddle" then
				if self.scorer == 1 then
					Stage.characters.leftPaddle:modify(modTypesConverter[mod.type], dt)
				elseif self.scorer == 2 then
					Stage.characters.rightPaddle:modify(modTypesConverter[mod.type], dt)
				end
			elseif modRanges[mod.type] == "stage" then
				Stage:modify(modTypesConverter[mod.type])
			end

			table.remove(Stage.modifiers, i)
		end
	end

	if
		Stage.characters.ball.y + Stage.characters.ball.height >= BOTTOM_WALL + 10
		or Stage.characters.ball.y <= TOP_WALL
	then
		Stage.characters.ball:setDy(-Stage.characters.ball.dy)

		if Stage.characters.ball.y + Stage.characters.ball.height >= BOTTOM_WALL + 10 then
			Stage.characters.ball:moveY(-1)
		elseif Stage.characters.ball.y <= TOP_WALL then
			Stage.characters.ball:moveY(1)
		end

		love.audio.play(sounds["hit_sound"])
	end

	Stage.characters.ball:update(dt)

	if modTimer >= 10 and #Stage.modifiers <= 2 then
		Stage.timers.mod = 0
		table.insert(Stage.modifiers, Modifier(modTypes[math.random(#modTypes)]))
	end

	-- Scoring -----------
	if Stage.characters.ball.x < Stage.characters.leftPaddle.x then
		Stage.score.right = Stage.score.right + 1

		love.audio.play(sounds["score_sound"])

		Stage.stateMachine:transitionTo("serve", { server = self.scorer })
	elseif Stage.characters.ball.x > Stage.characters.rightPaddle.x then
		Stage.score.left = Stage.score.left + 1

		love.audio.play(sounds["score_sound"])

		Stage.stateMachine:transitionTo("serve", { server = self.scorer })
	end

	if Stage.score.left == 11 or Stage.score.right == 11 then
		Stage.stateMachine:transitionTo("result", { winner = self.scorer })
	end
end

function Rally:render()
	if #Stage.modifiers ~= 0 then
		for i, mod in pairs(Stage.modifiers) do
			mod:render()
		end
	end

	for i, characters in pairs(Stage.characters) do
		characters:render()
	end

	showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
	showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
end
