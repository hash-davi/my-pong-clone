push = require("push")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PLAYER_VELOCITY = 200
BALL_X_VELOCITY = 100

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

	game_state = "menu"
	server = 1

	-- Player 1 Atributes --------
	player1_x = 10
	player1_y = 200
	player1_score = 0

	-- Player 2 Atributes --------
	player2_x = VIRTUAL_WIDTH - 20
	player2_y = 200
	player2_score = 0

	-- Ball Atributes ------------
	ball_x = 201
	ball_y = VIRTUAL_HEIGHT / 2
	ball_x_velocity = 100
	ball_y_velocity = 50
end

-- Update -------------------
function love.update(dt)
	-- Player 1 ------
	if love.keyboard.isDown("w") then
		player1_y = math.max(player1_y - 200 * dt, 15)
	end
	if love.keyboard.isDown("s") then
		player1_y = math.min(player1_y + 200 * dt, VIRTUAL_HEIGHT - 45)
	end

	-- Player 2 ------
	if love.keyboard.isDown("up") then
		player2_y = math.max(player2_y - 200 * dt, 15)
	end
	if love.keyboard.isDown("down") then
		player2_y = math.min(player2_y + 200 * dt, VIRTUAL_HEIGHT - 45)
	end

	if game_state == "menu" then
		player1_score = 0
		player2_score = 0
	elseif game_state == "game" then
		-- Movement ----------

		-- Ball ----------
		ball_x = ball_x + ball_x_velocity * dt
		ball_y = ball_y + ball_y_velocity * dt

		if ball_x >= player2_x - 10 and ball_y < player2_y + 30 and ball_y + 10 > player2_y then
			ball_x_velocity = -ball_x_velocity * 1.05
			ball_x = ball_x - 5
		end

		if ball_x <= player1_x + 10 and ball_y < player1_y + 30 and ball_y + 10 > player1_y then
			ball_x_velocity = -ball_x_velocity * 1.05
			ball_x = ball_x + 5
		end

		if ball_y >= VIRTUAL_HEIGHT - 25 or ball_y <= 15 then
			ball_y_velocity = -ball_y_velocity
		end

		-- Scoring -----------

		if ball_x < player1_x then
			player2_score = player2_score + 1

			server = 2
			game_state = "serve"
		elseif ball_x > player2_x then
			player1_score = player1_score + 1

			server = 1
			game_state = "serve"
		end

		if player1_score == 11 or player2_score == 11 then
			game_state = "result"
		end
	elseif game_state == "serve" then
		ball_x = 201
		ball_y = VIRTUAL_HEIGHT / 2

		if server == 1 then
			ball_x_velocity = math.abs(BALL_X_VELOCITY)
			ball_y_velocity = math.random(-50, 50)
		elseif server == 2 then
			ball_x_velocity = -math.abs(BALL_X_VELOCITY)
			ball_y_velocity = math.random(-50, 50)
		end
	elseif game_state == "result" then
		ball_x = 201
		ball_y = VIRTUAL_HEIGHT / 2
		ball_x_velocity = BALL_X_VELOCITY
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

		love.graphics.print(tostring(player1_score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		love.graphics.print(tostring(player2_score), VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	elseif game_state == "game" then
		love.graphics.print(tostring(player1_score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		love.graphics.print(tostring(player2_score), VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	elseif game_state == "result" then
		if server == 1 then
			love.graphics.printf("Player 1 won!", 0, 30, VIRTUAL_WIDTH, "center")
		elseif server == 2 then
			love.graphics.printf("Player 2 won!", 0, 30, VIRTUAL_WIDTH, "center")
		end

		love.graphics.print(tostring(player1_score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		love.graphics.print(tostring(player2_score), VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	end

	love.graphics.rectangle("fill", player1_x, player1_y, 10, 30)
	love.graphics.rectangle("fill", player2_x, player2_y, 10, 30)

	love.graphics.rectangle("fill", ball_x, ball_y, 10, 10)

	push.finish()
end

----------------------------------------------------------
