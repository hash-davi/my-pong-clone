-- Modules importing and constants definitions -----------

require("src.Dependencies")
require("src.Constants")

----------------------------------------------------------

-- Auxiliary functions -----------------------------------

function love.keypressed(key)
	love.keyboard.keysPressed[key] = true

	Game:keypressed(key)
end

function love.keyboard.wasPressed(key)
	return love.keyboard.keysPressed[key]
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

	Push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })
	----------------------------------------------------

	-- Game instantiation ------------------------------
	Game = Game()

	-- Game loading ------------------------------------
	Game:load()

	love.keyboard.keysPressed = {}
end

-- Update -------------------
function love.update(dt)
	Game:update(dt)

	love.keyboard.keysPressed = {}
end

-- Render -------------------
function love.draw()
	Push.start()

	Game:render()

	Push.finish()
end

----------------------------------------------------------
