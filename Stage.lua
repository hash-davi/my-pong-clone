Stage = Class({})

function Stage:init(characters)
	self.characters = characters
	self.state = "serve"
end

function Stage:load()
	leftPaddle = self.characters.leftPaddle
	rightPaddle = self.characters.rightPaddle
	ball = self.characters.ball
end

function Stage:update(dt)
	modTimer = modTimer + dt

	-- Unplayable paddles -
	if not leftPaddle.playable then
		if ball.dx < 0 and ball.x <= VIRTUAL_WIDTH / 2 then
			leftPaddle:track(ball)
		else
			leftPaddle.dy = 0
		end
	end

	if not rightPaddle.playable then
		if ball.dx > 0 and ball.x >= VIRTUAL_WIDTH / 2 then
			rightPaddle:track(ball)
		else
			rightPaddle.dy = 0
		end
	end

	-- Ball --------------
	if ball:collidesWith(leftPaddle) then
		ball.dx = math.min(-ball.dx * 1.05, BALL_DX * 2)
		ball.dy = ball.dy + leftPaddle.dy / 2
		ball.x = leftPaddle.x + ball.width + 1
		lastTouch = 1

		love.audio.play(sounds["hit_sound"])
	end
	if ball:collidesWith(rightPaddle) then
		ball.dx = math.min(-ball.dx * 1.05, BALL_DX * 2)
		ball.dy = ball.dy + rightPaddle.dy / 2
		ball.x = rightPaddle.x - ball.width - 1
		lastTouch = 2

		love.audio.play(sounds["hit_sound"])
	end

	for i, mod in pairs(modifiers) do
		if ball:collidesWith(mod) then
			if mod.type == "slow_motion" then
				for i, movable in pairs(movables) do
					movable.dx = movable.dx ~= nil and movable.dx * 0.5 or nil
					movable.dy = movable.dy * 0.5
				end
			end
			if lastTouch == 1 then
				leftPaddle:modify(modTypesConverter[mod.type])
			elseif lastTouch == 2 then
				rightPaddle:modify(modTypesConverter[mod.type])
			end

			table.remove(modifiers, i)
		end
	end

	if ball.y + ball.height >= BOTTOM_WALL + 10 or ball.y <= TOP_WALL then
		ball.dy = -ball.dy
		love.audio.play(sounds["hit_sound"])
	end

	ball:update(dt)

	if modTimer >= 10 and #modifiers <= 2 then
		modTimer = 0
		table.insert(modifiers, Modifier(modTypes[math.random(#modTypes)]))
	end

	-- Scoring -----------
	if ball.x < leftPaddle.x then
		player2_score = player2_score + 1

		love.audio.play(sounds["score_sound"])

		server = 2
		game_state = "serve"
	elseif ball.x > rightPaddle.x then
		player1_score = player1_score + 1

		love.audio.play(sounds["score_sound"])

		server = 1
		game_state = "serve"
	end

	if player1_score == 11 or player2_score == 11 then
		game_state = "result"
	end
end
