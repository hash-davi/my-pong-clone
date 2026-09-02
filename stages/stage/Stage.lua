Stage = Class({ __includes = BaseState })

require("stages.stage.Select")
require("stages.stage.Serve")
require("stages.stage.Rally")
require("stages.stage.Result")

require("characters.paddle.Paddle")
require("characters.ball.Ball")

require("Modifier")

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

TOP_WALL = 15
BOTTOM_WALL = VIRTUAL_HEIGHT - 25

LEFT_ZONE = 10
RIGHT_ZONE = VIRTUAL_WIDTH - 10

PADDLE_WIDTH = 10
PADDLE_HEIGHT = 30

PLAYER_VELOCITY = 200
BALL_DX = 100

slowingFactor = 1

-- local messages = {
-- 	"Great rally!",
-- 	"Nice shot!",
-- }

function Stage:init(characters)
	self.characters = characters
	self.paddles = {}
	self.modifiers = {}

	self.score = {
		left = 0,
		right = 0,
	}

	self.stateMachine = StateMachine({
		["select"] = function()
			return Select(self)
		end,
		["serve"] = function()
			return Serve(self)
		end,
		["rally"] = function()
			return Rally(self)
		end,
		["paused"] = function()
			return Paused()
		end,
		["countdown"] = function()
			return Countdown()
		end,
		["result"] = function()
			return Result()
		end,
	})

	self.mode = "normal"

	self.timers = { mod = 0, cooldown = 0 }
end

function Stage:load()
	self.paddles = {
		self.characters.leftPaddle,
		self.characters.rightPaddle,
	}

	for i, character in pairs(self.characters) do
		character:load({ stageCharacters = self.characters })
	end

	self.stateMachine:transitionTo("select", {
		mode = self.mode,
		score = self.score,
		timers = self.timers,
		characters = self.characters,
		paddles = self.paddles,
	})
end

function Stage:update(dt)
	self.stateMachine:update(dt)
end

function Stage:activate(paddle)
	paddle.playable = true
end

function Stage:modify(type)
	self.mode = type

	if self.mode == "normal" then
		self.timers.cooldown = 0
		slowingFactor = 1
		love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	elseif self.mode == "slower" then
		slowingFactor = 0.5
		love.graphics.setColor(93 / 255, 211 / 255, 158 / 255)
	end
end

function Stage:render()
	if self.mode == "slower" then
		love.graphics.clear(30 / 255, 85 / 255, 92 / 255, 1)
		love.graphics.setColor(93 / 255, 211 / 255, 158 / 255)
	else
		love.graphics.clear(58 / 255, 46 / 255, 57 / 255, 1)
		love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	end

	-- Court ------
	love.graphics.rectangle("line", LEFT_ZONE - 2, TOP_WALL, RIGHT_ZONE - LEFT_ZONE + 4, BOTTOM_WALL - 5) -- Perimeter
	love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - 10, TOP_WALL, 1, BOTTOM_WALL - 5) -- Net line

	-- DEBUG ------
	love.graphics.setFont(Game_fonts["small"])
	love.graphics.printf(self.characters.leftPaddle.dy, 0, 30, VIRTUAL_WIDTH / 2, "center")
	love.graphics.printf(self.characters.rightPaddle.dy, VIRTUAL_WIDTH / 2, 30, VIRTUAL_WIDTH / 2, "center")
	love.graphics.printf(self.characters.ball.dy, -10, 60, VIRTUAL_WIDTH, "center")

	self.stateMachine:render()
end

function Stage:reset()
	self.characters.ball:reset()

	self.modifiers = {}
end
