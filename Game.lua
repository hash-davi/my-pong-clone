Game = Class({})

-- Modules required ------------------------
require("StateMachine")
require("BaseState")
require("StartScreen")

require("stages.stage.Stage")

require("Menu")
--------------------------------------------

function showscore(player, x, y)
	local score

	if player == 1 then
		score = Game.stateMachine.currentState.score.left
	elseif player == 2 then
		score = Game.stateMachine.currentState.score.right
	end

	love.graphics.setFont(game_fonts["large"])
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
				ball = Ball({ x = 201, y = VIRTUAL_HEIGHT / 2 }, { width = 10, height = 10 }),
			})
		end,
	})
end

function Game:load()
	self.stateMachine:transitionTo("start")

	game_fonts = {
		["large"] = love.graphics.newFont("font.ttf", 32),
		["medium"] = love.graphics.newFont("font.ttf", 24),
		["small"] = love.graphics.newFont("font.ttf", 16),
	}

	sounds = {
		["hit_sound"] = love.audio.newSource("sounds/sound.wav", "static"),
		["score_sound"] = love.audio.newSource("sounds/score.wav", "static"),
	}
end

function Game:update(dt)
	-- if self.state == "stage" then
	-- 	stage:update(dt)
	-- end
	self.stateMachine:update(dt)
end

function Game:render()
	-- Graphics ---------
	-- if stage.mode == "slower" then
	-- 	love.graphics.clear(30 / 255, 85 / 255, 92 / 255, 1)
	-- 	love.graphics.setColor(93 / 255, 211 / 255, 158 / 255)
	-- else
	-- 	love.graphics.clear(58 / 255, 46 / 255, 57 / 255, 1)
	-- 	love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	-- end

	self.stateMachine:render()
end

function Game:keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
