-- Modules importing and constants definitions -----------

Class = require("class")

local push = require("push")

require("Game")

require("Menu")

require("Stage")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

----------------------------------------------------------

-- Auxiliary functions -----------------------------------

function love.keypressed(key)
	game:keyPressed(key)
	-- if game.state == "start" then
	-- 	game.state = "stage"
	-- 	stage:load()
	-- end
	--
	-- if key == "escape" then
	-- 	love.event.quit()
	-- end
	--
	-- if key == "return" then
	-- 	if stage.state == "select" then
	-- 		stage.state = "serve"
	-- 	elseif stage.state == "serve" then
	-- 		stage.state = "rally"
	-- 	elseif stage.state == "result" then
	-- 		game.state = "start"
	-- 	end
	-- end
	--
	-- if stage.state == "select" then
	-- 	if key == "w" or key == "s" then
	-- 		stage:activate(stage.characters.leftPaddle)
	-- 	end
	--
	-- 	if key == "up" or key == "down" then
	-- 		stage:activate(stage.characters.rightPaddle)
	-- 	end
	-- elseif stage.state == "rally" then
	-- 	if key == "space" then
	-- 		stage:modify("slower")
	-- 	elseif key == "k" then
	-- 		leftPaddle:modify("stretched")
	-- 	end
	-- end
end

-- function showscore(player, x, y)
-- 	love.graphics.setFont(game_fonts["large"])
--
-- 	if player == 1 then
-- 		score = stage.score.left
-- 	elseif player == 2 then
-- 		score = stage.score.right
-- 	end
--
-- 	love.graphics.print(tostring(score), x, y)
-- end

----------------------------------------------------------

-- Main functions ----------------------------------------

-- Setup --------------------
function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	math.randomseed(os.time())

	game = Game()
	menu = Menu()

	-- game_fonts = {
	-- 	["large"] = love.graphics.newFont("font.ttf", 32),
	-- 	["medium"] = love.graphics.newFont("font.ttf", 24),
	-- 	["small"] = love.graphics.newFont("font.ttf", 16),
	-- }

	love.window.setTitle("Pong 'til the end of times")

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
		resizable = false,
		vsync = true,
		fullscreen = false,
	})

	push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })

	game:load()

	-- sounds = {
	-- 	["hit_sound"] = love.audio.newSource("sounds/sound.wav", "static"),
	-- 	["score_sound"] = love.audio.newSource("sounds/score.wav", "static"),
	-- }

	-- stage = Stage({
	-- 	leftPaddle = Paddle(10, TOP_WALL, PADDLE_WIDTH, PADDLE_HEIGHT, false),
	-- 	rightPaddle = Paddle(VIRTUAL_WIDTH - 20, BOTTOM_WALL - 20, PADDLE_WIDTH, PADDLE_HEIGHT, false),
	-- 	ball = Ball(201, VIRTUAL_HEIGHT / 2, 10, 10),
	-- })
end

-- Update -------------------
function love.update(dt)
	game:update(dt)
	-- if game.state == "stage" then
	-- 	stage:update(dt)
	-- end
end

-- Render -------------------
function love.draw()
	push.start()

	game:render()

	push.finish()
end

----------------------------------------------------------
