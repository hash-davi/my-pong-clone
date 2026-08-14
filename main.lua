-- Modules importing and constants definitions -----------

Class = require("class")

local push = require("push")

require("Menu")

require("Stage")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

----------------------------------------------------------

-- Auxiliary functions -----------------------------------

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	if key == "return" then
		if game_state == "menu" then
			game_state = "stage"
			stage:load()
		elseif stage.state == "select" then
			stage.state = "serve"
		elseif stage.state == "serve" then
			stage.state = "rally"
		elseif stage.state == "result" then
			game_state = "menu"
		end
	end

	if stage.state == "select" then
		if key == "w" or key == "s" then
			stage:activate(stage.characters.leftPaddle)
		end

		if key == "up" or key == "down" then
			stage:activate(stage.characters.rightPaddle)
		end
	end
end

function showscore(player, x, y)
	if player == 1 then
		score = player1_score
	elseif player == 2 then
		score = player2_score
	end

	love.graphics.print(tostring(score), x, y)
end

----------------------------------------------------------

-- Main functions ----------------------------------------

-- Setup --------------------
function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	math.randomseed(os.time())

	score_font = love.graphics.newFont("font.ttf", 32)

	love.window.setTitle("My Pong")

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
		resizable = false,
		vsync = true,
		fullscreen = false,
	})

	push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })

	sounds = {
		["hit_sound"] = love.audio.newSource("sounds/sound.wav", "static"),
		["score_sound"] = love.audio.newSource("sounds/score.wav", "static"),
	}

	game_state = "menu"

	stage = Stage({
		leftPaddle = Paddle(10, TOP_WALL, PADDLE_WIDTH, PADDLE_HEIGHT, false),
		rightPaddle = Paddle(VIRTUAL_WIDTH - 20, BOTTOM_WALL - 20, PADDLE_WIDTH, PADDLE_HEIGHT, false),
		ball = Ball(201, VIRTUAL_HEIGHT / 2, 10, 10),
	})

	menu = Menu()
end

-- Update -------------------
function love.update(dt)
	-- -- Left paddle ------
	-- if leftPaddle.playable then
	-- 	if love.keyboard.isDown("w") then
	-- 		leftPaddle:moveUp()
	-- 	elseif love.keyboard.isDown("s") then
	-- 		leftPaddle:moveDown()
	-- 	else
	-- 		leftPaddle.dy = 0
	-- 		leftPaddle.state = "static"
	-- 	end
	-- end
	--
	-- leftPaddle:update(dt)
	--
	-- -- Right Paddle ------
	-- if rightPaddle.playable then
	-- 	if love.keyboard.isDown("up") then
	-- 		rightPaddle:moveUp()
	-- 	elseif love.keyboard.isDown("down") then
	-- 		rightPaddle:moveDown()
	-- 	else
	-- 		rightPaddle.dy = 0
	-- 		rightPaddle.state = "static"
	-- 	end
	-- end
	--
	-- rightPaddle:update(dt)
	--
	if game_state == "stage" then
		stage:update(dt)
		-- modTimer = modTimer + dt
		--
		-- -- Unplayable paddle -
		-- if not leftPaddle.playable then
		-- 	if ball.dx < 0 and ball.x <= VIRTUAL_WIDTH / 2 then
		-- 		leftPaddle:track(ball)
		-- 	else
		-- 		leftPaddle.dy = 0
		-- 	end
		-- end
		--
		-- if not rightPaddle.playable then
		-- 	if ball.dx > 0 and ball.x >= VIRTUAL_WIDTH / 2 then
		-- 		rightPaddle:track(ball)
		-- 	else
		-- 		rightPaddle.dy = 0
		-- 	end
		-- end
		--
		-- -- Ball --------------
		-- if ball:collidesWith(leftPaddle) then
		-- 	ball.dx = math.min(-ball.dx * 1.05, BALL_DX * 2)
		-- 	ball.dy = ball.dy + leftPaddle.dy / 2
		-- 	ball.x = leftPaddle.x + ball.width + 1
		-- 	lastTouch = 1
		--
		-- 	love.audio.play(sounds["hit_sound"])
		-- end
		-- if ball:collidesWith(rightPaddle) then
		-- 	ball.dx = math.min(-ball.dx * 1.05, BALL_DX * 2)
		-- 	ball.dy = ball.dy + rightPaddle.dy / 2
		-- 	ball.x = rightPaddle.x - ball.width - 1
		-- 	lastTouch = 2
		--
		-- 	love.audio.play(sounds["hit_sound"])
		-- end
		--
		-- for i, mod in pairs(modifiers) do
		-- 	if ball:collidesWith(mod) then
		-- 		if mod.type == "slow_motion" then
		-- 			for i, movable in pairs(movables) do
		-- 				movable.dx = movable.dx ~= nil and movable.dx * 0.5 or nil
		-- 				movable.dy = movable.dy * 0.5
		-- 			end
		-- 		end
		-- 		if lastTouch == 1 then
		-- 			leftPaddle:modify(modTypesConverter[mod.type])
		-- 		elseif lastTouch == 2 then
		-- 			rightPaddle:modify(modTypesConverter[mod.type])
		-- 		end
		--
		-- 		table.remove(modifiers, i)
		-- 	end
		-- end
		--
		-- if ball.y + ball.height >= BOTTOM_WALL + 10 or ball.y <= TOP_WALL then
		-- 	ball.dy = -ball.dy
		-- 	love.audio.play(sounds["hit_sound"])
		-- end
		--
		-- ball:update(dt)
		--
		-- if modTimer >= 10 and #modifiers <= 2 then
		-- 	modTimer = 0
		-- 	table.insert(modifiers, Modifier(modTypes[math.random(#modTypes)]))
		-- end
		--
		-- -- Scoring -----------
		-- if ball.x < leftPaddle.x then
		-- 	player2_score = player2_score + 1
		--
		-- 	love.audio.play(sounds["score_sound"])
		--
		-- 	server = 2
		-- 	game_state = "serve"
		-- elseif ball.x > rightPaddle.x then
		-- 	player1_score = player1_score + 1
		--
		-- 	love.audio.play(sounds["score_sound"])
		--
		-- 	server = 1
		-- 	game_state = "serve"
		-- end
		--
		-- if player1_score == 11 or player2_score == 11 then
		-- 	game_state = "result"
		-- end
		-- elseif game_state == "serve" then
		-- 	ball:reset()
		--
		-- 	if server == 1 then
		-- 		ball.dx = BALL_DX
		-- 	elseif server == 2 then
		-- 		ball.dx = -BALL_DX
		-- 	end
		-- elseif game_state == "result" then
		-- 	ball:reset()
	end
end

-- Render -------------------
function love.draw()
	push.start()

	-- Graphics ---------
	love.graphics.clear(60 / 255, 50 / 255, 70 / 255, 1)

	love.graphics.setFont(score_font)

	if game_state == "menu" then
		love.graphics.printf("Welcome to Pong", 0, 60, VIRTUAL_WIDTH, "center")
		love.graphics.printf("Press return to play", 0, VIRTUAL_HEIGHT - 80, VIRTUAL_WIDTH, "center")
		-- menu:render()
	elseif stage.state == "serve" then
		if stage.server == 1 then
			love.graphics.printf("Player 1's serve", 0, 30, VIRTUAL_WIDTH, "center")
		elseif stage.server == 2 then
			love.graphics.printf("Player 2's serve", 0, 30, VIRTUAL_WIDTH, "center")
		end

		showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
		stage.characters.leftPaddle:render()
		stage.characters.rightPaddle:render()

		stage.characters.ball:render()

		if #stage.modifiers ~= 0 then
			for i, mod in pairs(stage.modifiers) do
				mod:render()
			end
		end
	elseif game_state == "stage" then
		showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
		stage.characters.leftPaddle:render()
		stage.characters.rightPaddle:render()

		stage.characters.ball:render()

		love.graphics.printf(stage.state, 0, 30, VIRTUAL_WIDTH, "center")
		love.graphics.printf(ball.dx, 0, 120, VIRTUAL_WIDTH, "center")
		love.graphics.printf(ball.dy, 0, 160, VIRTUAL_WIDTH, "center")

		if #stage.modifiers ~= 0 then
			for i, mod in pairs(stage.modifiers) do
				mod:render()
			end
		end
	elseif stage.state == "result" then
		if stage.server == 1 then
			love.graphics.printf("Player 1 won!", 0, 30, VIRTUAL_WIDTH, "center")
		elseif stage.server == 2 then
			love.graphics.printf("Player 2 won!", 0, 30, VIRTUAL_WIDTH, "center")
		end

		showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	end

	push.finish()
end

----------------------------------------------------------
