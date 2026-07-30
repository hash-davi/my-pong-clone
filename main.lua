-- Modules importing and constants definitions -----------

Class = require("class")

push = require("push")

require("Paddle")

require("Ball")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

TOP_WALL = 15
BOTTOM_WALL = VIRTUAL_HEIGHT - 25

PLAYER_VELOCITY = 200
BALL_DX = 100

----------------------------------------------------------

-- Auxiliary functions -----------------------------------

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	if key == "return" then
		if game_state == "menu" then
			game_state = "serve"
		elseif game_state == "serve" then
			game_state = "game"
		elseif game_state == "result" then
			game_state = "menu"
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

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
		resizable = false,
		vsync = true,
		fullscreen = false,
	})

	push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })

	sounds = {
		["hit_sound"] = love.audio.newSource("assets/sound.wav", "static"),
		["score_sound"] = love.audio.newSource("assets/score.wav", "static"),
	}

	game_state = "menu"
	server = 1

	-- Player 1 Atributes --------
	player1 = Paddle(10, TOP_WALL, 10, 30, 1)
	player1_score = 0

	-- Player 2 Atributes --------
	player2 = Paddle(VIRTUAL_WIDTH - 20, BOTTOM_WALL - 20, 10, 30, 2)
	player2_score = 0

	-- Ball Atributes ------------
	ball = Ball(201, VIRTUAL_HEIGHT / 2, 10, 10)
end

-- Update -------------------
function love.update(dt)
	-- Player 1 ------
	if love.keyboard.isDown("w") then
		player1.dy = -PLAYER_VELOCITY
	elseif love.keyboard.isDown("s") then
		player1.dy = PLAYER_VELOCITY
	else
		player1.dy = 0
	end

	player1:update(dt)

	-- Player 2 ------
	if love.keyboard.isDown("up") then
		player2.dy = -PLAYER_VELOCITY
	elseif love.keyboard.isDown("down") then
		player2.dy = PLAYER_VELOCITY
	else
		player2.dy = 0
	end

	player2:update(dt)

	if game_state == "menu" then
		player1_score = 0
		player2_score = 0
	elseif game_state == "game" then
		-- Ball --------------
		if ball:collidesWith(player1) then
			ball.dx = -ball.dx * 1.05
			ball.x = player1.x + ball.width + 1

			love.audio.play(sounds["hit_sound"])
		end
		if ball:collidesWith(player2) then
			ball.dx = -ball.dx * 1.05
			ball.x = player2.x - ball.width - 1

			love.audio.play(sounds["hit_sound"])
		end

		if ball.y >= BOTTOM_WALL or ball.y <= TOP_WALL then
			ball.dy = -ball.dy
			love.audio.play(sounds["hit_sound"])
		end

		ball:update(dt)

		-- Scoring -----------
		if ball.x < player1.x then
			player2_score = player2_score + 1

			love.audio.play(sounds["score_sound"])

			server = 2
			game_state = "serve"
		elseif ball.x > player2.x then
			player1_score = player1_score + 1

			love.audio.play(sounds["score_sound"])

			server = 1
			game_state = "serve"
		end

		if player1_score == 11 or player2_score == 11 then
			game_state = "result"
		end
	elseif game_state == "serve" then
		ball:reset()

		if server == 1 then
			ball.dx = BALL_DX
		elseif server == 2 then
			ball.dx = -BALL_DX
		end
	elseif game_state == "result" then
		ball:reset()
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
	elseif game_state == "serve" then
		if server == 1 then
			love.graphics.printf("Player 1's serve", 0, 30, VIRTUAL_WIDTH, "center")
		elseif server == 2 then
			love.graphics.printf("Player 2's serve", 0, 30, VIRTUAL_WIDTH, "center")
		end

		showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	elseif game_state == "game" then
		showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	elseif game_state == "result" then
		if server == 1 then
			love.graphics.printf("Player 1 won!", 0, 30, VIRTUAL_WIDTH, "center")
		elseif server == 2 then
			love.graphics.printf("Player 2 won!", 0, 30, VIRTUAL_WIDTH, "center")
		end

		showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	end

	player1:render()
	player2:render()

	ball:render()

	push.finish()
end

----------------------------------------------------------
