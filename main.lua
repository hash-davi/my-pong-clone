-- Modules importing and constants definitions -----------

Class = require("class")

local push = require("push")

require("Game")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

----------------------------------------------------------

-- Auxiliary functions -----------------------------------

function love.keypressed(key)
	game:keypressed(key)
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
	game = Game()

	-- Game loading ------------------------------------
	game:load()
end

-- Update -------------------
function love.update(dt)
	game:update(dt)
end

-- Render -------------------
function love.draw()
	push.start()

	game:render()

	push.finish()
end

----------------------------------------------------------
