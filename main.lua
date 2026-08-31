-- Modules importing and constants definitions -----------

Class = require("libs.class")

local push = require("libs.push")

require("Game")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

----------------------------------------------------------

-- Auxiliary functions -----------------------------------

function love.keypressed(key)
	love.keysPressed[key] = true

	Game:keypressed(key)
end

function love.keyboard.wasPressed(key)
	-- if love.keysPressed[key] then
	-- 	return true
	-- else
	-- 	return false
	-- end
	return love.keysPressed[key]
end

----------------------------------------------------------

-- Main functions ----------------------------------------

-- Setup --------------------
function love.load()
	-- Graphical settings ------------------------------
	love.graphics.setDefaultFilter("nearest", "nearest")

	math.randomseed(os.time())

	love.window.setTitle("Pong 'til the end of times")

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
		resizable = false,
		vsync = true,
		fullscreen = false,
	})

	push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })
	----------------------------------------------------

	-- Game instantiation ------------------------------
	Game = Game()

	-- Game loading ------------------------------------
	Game:load()

	love.keysPressed = {}
end

-- Update -------------------
function love.update(dt)
	Game:update(dt)
end

-- Render -------------------
function love.draw()
	push.start()

	Game:render()

	push.finish()
end

----------------------------------------------------------
