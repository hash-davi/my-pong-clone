-- Modules importing and constants definitions -----------

Class = require("class")

local push = require("push")

require("Menu")

require("Paddle")

require("Ball")

require("Modifier")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

TOP_WALL = 15
BOTTOM_WALL = VIRTUAL_HEIGHT - 25

PADDLE_WIDTH = 10
PADDLE_HEIGHT = 30

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
			-- if player1.playable or player2.playable then
			game_state = "serve"
			-- end
		elseif game_state == "serve" then
			game_state = "game"
		elseif game_state == "result" then
			game_state = "menu"
		end
	end

	if game_state == "serve" then
		if key == "w" or key == "s" then
			player1.playable = true
		end

		if key == "up" or key == "down" then
			player2.playable = true
		end
	end

	-- if game_state == "game" then
	-- 	if key == "space" then
	-- 		player1.mode = "stretched"
	-- 		player1:reset()
	-- 	end
	-- end
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
	server = 1

	-- Player 1 Atributes --------
	player1 = Paddle(10, TOP_WALL, PADDLE_WIDTH, PADDLE_HEIGHT, false)
	player1_score = 0

	-- Player 2 Atributes --------
	player2 = Paddle(VIRTUAL_WIDTH - 20, BOTTOM_WALL - 20, PADDLE_WIDTH, PADDLE_HEIGHT, false)
	player2_score = 0

	-- Ball Atributes ------------
	ball = Ball(201, VIRTUAL_HEIGHT / 2, 10, 10)

	menu = Menu()

	modifierTimer = 0
	modifiers = {}

	modCoolDown = 0
end

-- Update -------------------
function love.update(dt)
	-- Left paddle ------
	if player1.playable then
		if love.keyboard.isDown("w") then
			player1.dy = -PLAYER_VELOCITY
		elseif love.keyboard.isDown("s") then
			player1.dy = PLAYER_VELOCITY
		else
			player1.dy = 0
			player1.state = "static"
		end
	end

	player1:update(dt)

	-- Right Paddle ------
	if player2.playable then
		if love.keyboard.isDown("up") then
			player2.dy = -PLAYER_VELOCITY
		elseif love.keyboard.isDown("down") then
			player2.dy = PLAYER_VELOCITY
		else
			player2.dy = 0
			player2.state = "static"
		end
	end

	player2:update(dt)

	if game_state == "menu" then
		player1_score = 0
		player2_score = 0
	elseif game_state == "game" then
		modifierTimer = modifierTimer + dt
		modCoolDown = modCoolDown + dt

		-- Unplayable paddle -
		if not player1.playable then
			if ball.dx < 0 and ball.x <= VIRTUAL_WIDTH / 2 then
				player1:track(ball)
			else
				player1.dy = 0
			end
		end

		if not player2.playable then
			if ball.dx > 0 and ball.x >= VIRTUAL_WIDTH / 2 then
				player2:track(ball)
			else
				player2.dy = 0
			end
		end

		-- Ball --------------
		if ball:collidesWith(player1) then
			ball.dx = math.min(-ball.dx * 1.05, BALL_DX * 2)
			ball.dy = ball.dy + player1.dy / 2
			ball.x = player1.x + ball.width + 1

			love.audio.play(sounds["hit_sound"])
		end
		if ball:collidesWith(player2) then
			ball.dx = math.min(-ball.dx * 1.05, BALL_DX * 2)
			ball.dy = ball.dy + player2.dy / 2
			ball.x = player2.x - ball.width - 1

			love.audio.play(sounds["hit_sound"])
		end

		for i, mod in pairs(modifiers) do
			if ball:collidesWith(mod) then
				player1.mode = "stretched"
				player1:reset()
				modCoolDown = 0

				table.remove(modifiers, i)
			end
		end

		if ball.y >= BOTTOM_WALL or ball.y <= TOP_WALL then
			ball.dy = -ball.dy
			love.audio.play(sounds["hit_sound"])
		end

		ball:update(dt)

		if modifierTimer >= 7 and #modifiers <= 3 then
			modifierTimer = 0
			table.insert(modifiers, Modifier("stretcher"))
		end

		if modCoolDown >= 10 then
			player1.mode = "normal"
			player1:reset()
		end

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
		love.graphics.printf("Press return to play", 0, VIRTUAL_HEIGHT - 80, VIRTUAL_WIDTH, "center")
		-- menu:render()
	elseif game_state == "serve" then
		if server == 1 then
			love.graphics.printf("Player 1's serve", 0, 30, VIRTUAL_WIDTH, "center")
		elseif server == 2 then
			love.graphics.printf("Player 2's serve", 0, 30, VIRTUAL_WIDTH, "center")
		end

		showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
		player1:render()
		player2:render()

		ball:render()

		if #modifiers ~= 0 then
			for i, mod in pairs(modifiers) do
				mod:render()
			end
		end
	elseif game_state == "game" then
		showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
		player1:render()
		player2:render()

		ball:render()

		if #modifiers ~= 0 then
			for i, mod in pairs(modifiers) do
				mod:render()
			end
		end
	elseif game_state == "result" then
		if server == 1 then
			love.graphics.printf("Player 1 won!", 0, 30, VIRTUAL_WIDTH, "center")
		elseif server == 2 then
			love.graphics.printf("Player 2 won!", 0, 30, VIRTUAL_WIDTH, "center")
		end

		showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	end

	push.finish()
end

----------------------------------------------------------
