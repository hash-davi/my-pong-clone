Game = Class({})

-- Modules required ------------------------
require("src.StateMachine")
require("src.BaseState")

require("src.screens.StartScreen")
require("src.screens.Menu")
require("src.stages.stage.Stage")
--------------------------------------------

function showscore(player, x, y)
	local score

	if player == 1 then
		score = Game.stateMachine.currentState.score.left
	elseif player == 2 then
		score = Game.stateMachine.currentState.score.right
	end

	love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	love.graphics.setFont(Game_fonts["large"])
	love.graphics.print(tostring(score), x, y)
end

function Game:init()
	self.stateMachine = StateMachine({
		["start"] = function()
			return StartScreen()
		end,
		["menu"] = function()
			return Menu()
		end,
		["stage"] = function()
			return Stage({
				leftPaddle = Paddle(
					{ x = LEFT_ZONE, y = TOP_WALL },
					{ width = PADDLE_WIDTH, height = PADDLE_HEIGHT },
					false,
					1
				),
				rightPaddle = Paddle(
					{ x = RIGHT_ZONE - PADDLE_WIDTH, y = BOTTOM_WALL - 20 },
					{ width = PADDLE_WIDTH, height = PADDLE_HEIGHT },
					false,
					2
				),
				ball = Ball({ x = VIRTUAL_WIDTH / 2 - 15, y = VIRTUAL_HEIGHT / 2 }, { width = 10, height = 10 }),
			})
		end,
	})
end

function Game:load()
	self.stateMachine:transitionTo("start")

	Game_fonts = {
		["large"] = love.graphics.newFont("fonts/font.ttf", 32),
		["medium"] = love.graphics.newFont("fonts/font.ttf", 24),
		["small"] = love.graphics.newFont("fonts/font.ttf", 16),
	}

	Game_sounds = {
		["hit_sound"] = love.audio.newSource("sounds/sound.wav", "static"),
		["score_sound"] = love.audio.newSource("sounds/score.wav", "static"),
	}
end

function Game:update(dt)
	self.stateMachine:update(dt)
end

function Game:render()
	self.stateMachine:render()
end

function Game:keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
