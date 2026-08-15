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
	elseif stage.state == "rally" then
		if key == "space" then
			stage:modify("slower")
		elseif key == "k" then
			leftPaddle:modify("stretched")
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
	if game_state == "stage" then
		stage:update(dt)
	end
end

-- Render -------------------
function love.draw()
	push.start()

	-- Graphics ---------
	if stage.mode == "slower" then
		love.graphics.clear(30 / 255, 85 / 255, 92 / 255, 1)
		love.graphics.setColor(93 / 255, 211 / 255, 158 / 255)
	else
		love.graphics.clear(58 / 255, 46 / 255, 57 / 255, 1)
		love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	end

	love.graphics.setFont(score_font)

	if game_state == "menu" then
		love.graphics.printf("Welcome to Pong", 0, 60, VIRTUAL_WIDTH, "center")
		love.graphics.printf("Press return to play", 0, VIRTUAL_HEIGHT - 80, VIRTUAL_WIDTH, "center")
		-- menu:render()
	elseif stage.state == "serve" then
		if stage.server == 1 then
			love.graphics.printf("Left's serve", 0, 30, VIRTUAL_WIDTH, "center")
		elseif stage.server == 2 then
			love.graphics.printf("Right's serve", 0, 30, VIRTUAL_WIDTH, "center")
		end

		showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
		stage.characters.leftPaddle:render()
		stage.characters.rightPaddle:render()

		stage.characters.ball:render()

		stage:render()

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

		stage:render()

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
