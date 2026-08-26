Stage = Class({})

require("Paddle")

require("Ball")

require("Modifier")

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

TOP_WALL = 15
BOTTOM_WALL = VIRTUAL_HEIGHT - 25

LEFT_ZONE = 10
RIGHT_ZONE = VIRTUAL_WIDTH - 20

PADDLE_WIDTH = 10
PADDLE_HEIGHT = 30

PLAYER_VELOCITY = 200
BALL_DX = 100

slowingFactor = 1

local modTypes = {
	"stretcher",
	"slow_motion",
	"8_ball_pong",
}

local modRanges = {
	["slow_motion"] = "stage",
	["stretcher"] = "paddle",
	["8_ball_pong"] = "stage",
}

local modTypesConverter = {
	["stretcher"] = "stretched",
	["slow_motion"] = "slower",
	["8_ball_pong"] = "pooled",
}

local possibleStates = {
	"select",
	"serve",
	"rally",
	"paused",
	"countdown",
	"result",
}

local messages = {
	"Great rally!",
	"Nice shot!",
}

function Stage:init(characters)
	self.characters = characters
	self.paddles = {}
	self.modifiers = {}

	self.server = 1
	self.score = {
		left = 0,
		right = 0,
	}

	-- self.state = "serve"

	self.stateMachine = StateMachine({
		["select"] = function()
			return Select()
		end,
		["serve"] = function()
			return Serve()
		end,
		["rally"] = function()
			return Rally()
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
	self.cooldown = 0
end

function Stage:load()
	leftPaddle = self.characters.leftPaddle
	rightPaddle = self.characters.rightPaddle
	ball = self.characters.ball

	self.paddles = {
		leftPaddle,
		rightPaddle,
	}

	modTimer = 0
	rallyTime = 0

	-- self.state = "select"

	self.stateMachine:transitionTo("select")
end

function Stage:update(dt)
	if self.mode ~= "normal" then
		self.cooldown = self.cooldown + dt

		if self.cooldown >= 10 then
			self:modify("normal")
		end
	end

	self.stateMachine:update(dt)

	if self.state ~= "paused" then
		-- Left paddle ------
		if leftPaddle.playable then
			if love.keyboard.isDown("w") then
				leftPaddle:setSpeed(-PLAYER_VELOCITY)
				leftPaddle:moveY(leftPaddle.dy * dt * slowingFactor)
			elseif love.keyboard.isDown("s") then
				leftPaddle:setSpeed(PLAYER_VELOCITY)
				leftPaddle:moveY(leftPaddle.dy * dt * slowingFactor)
			else
				leftPaddle:stop()
			end
		end

		leftPaddle:update(dt)

		-- Right Paddle ------
		if rightPaddle.playable then
			if love.keyboard.isDown("up") then
				rightPaddle:setSpeed(-PLAYER_VELOCITY)
				rightPaddle:moveY(rightPaddle.dy * dt * slowingFactor)
			elseif love.keyboard.isDown("down") then
				rightPaddle:setSpeed(PLAYER_VELOCITY)
				rightPaddle:moveY(rightPaddle.dy * dt * slowingFactor)
			else
				rightPaddle:stop()
			end
		end

		rightPaddle:update(dt)
	end

	if self.state == "serve" then
		rallyTime = 0

		ball:reset()

		if self.server == 1 then
			ball.dx = BALL_DX
		elseif self.server == 2 then
			ball.dx = -BALL_DX
		end
	elseif self.state == "rally" then
		modTimer = modTimer + dt
		rallyTime = rallyTime + dt

		-- Unplayable paddles -
		if not leftPaddle.playable then
			if ball.dx < 0 and ball.x <= VIRTUAL_WIDTH / 2 then
				leftPaddle:track(ball, dt)
			else
				leftPaddle:stop()
			end
		end

		if not rightPaddle.playable then
			if ball.dx > 0 and ball.x >= VIRTUAL_WIDTH / 2 then
				rightPaddle:track(ball, dt)
			else
				rightPaddle:stop()
			end
		end

		ball:setDx(ball.dx)
		ball:moveX(ball.dx * dt * slowingFactor)
		ball:setDy(ball.dy)
		ball:moveY(ball.dy * dt * slowingFactor)

		-- Ball --------------
		if ball:collidesWith(leftPaddle) then
			ball:setDx(-ball.dx * 1.05)
			ball:setDy(ball.dy + leftPaddle.dy / 2)
			ball:moveX(leftPaddle.x + leftPaddle.width + 1 - ball.x)
			scorer = 1

			love.audio.play(sounds["hit_sound"])
		end
		if ball:collidesWith(rightPaddle) then
			ball:setDx(-ball.dx * 1.05)
			ball:setDy(ball.dy + rightPaddle.dy / 2)
			ball:moveX(rightPaddle.x - ball.width - 1 - ball.x)
			scorer = 2

			love.audio.play(sounds["hit_sound"])
		end

		for i, mod in pairs(self.modifiers) do
			if ball:collidesWith(mod) then
				if modRanges[mod.type] == "paddle" then
					if scorer == 1 then
						leftPaddle:modify(modTypesConverter[mod.type], dt)
					elseif scorer == 2 then
						rightPaddle:modify(modTypesConverter[mod.type], dt)
					end
				elseif modRanges[mod.type] == "stage" then
					self:modify(modTypesConverter[mod.type])
				end

				table.remove(self.modifiers, i)
			end
		end

		if ball.y + ball.height >= BOTTOM_WALL + 10 or ball.y <= TOP_WALL then
			ball:setDy(-ball.dy)

			if ball.y + ball.height >= BOTTOM_WALL + 10 then
				ball:moveY(-1)
			elseif ball.y <= TOP_WALL then
				ball:moveY(1)
			end

			love.audio.play(sounds["hit_sound"])
		end

		ball:update(dt)

		if modTimer >= 10 and #self.modifiers <= 2 then
			modTimer = 0
			table.insert(self.modifiers, Modifier(modTypes[math.random(#modTypes)]))
		end

		-- Scoring -----------
		if ball.x < leftPaddle.x then
			self.score.right = self.score.right + 1

			love.audio.play(sounds["score_sound"])

			self.server = 2
			self.state = "serve"
		elseif ball.x > rightPaddle.x then
			self.score.left = self.score.left + 1

			love.audio.play(sounds["score_sound"])

			self.server = 1
			self.state = "serve"
		end

		if self.score.left == 11 or self.score.right == 11 then
			self.state = "result"
		end
	elseif self.state == "result" then
		self:reset()
	end
end

function Stage:activate(paddle)
	paddle.playable = true
	table.insert(self.paddles, paddle)
end

function Stage:modify(type)
	self.mode = type

	if self.mode == "normal" then
		self.cooldown = 0
		slowingFactor = 1
		love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	elseif self.mode == "slower" then
		slowingFactor = 0.2
		love.graphics.setColor(93 / 255, 211 / 255, 158 / 255)
		-- elseif self.mode == "pooled" then
		-- 	self:togglePause()
	end
end

function Stage:render()
	if self.mode == "slower" then
		love.graphics.setColor(93 / 255, 211 / 255, 158 / 255)
	end
	love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - 10, TOP_WALL, 1, BOTTOM_WALL - 5)

	love.graphics.rectangle(
		"line",
		leftPaddle.x - 2,
		TOP_WALL,
		(rightPaddle.x + rightPaddle.width) - leftPaddle.x + 4,
		BOTTOM_WALL - 5
	)

	showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
	showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	self.characters.leftPaddle:render()
	self.characters.rightPaddle:render()

	self.characters.ball:render()

	love.graphics.printf(self.state, 0, 30, VIRTUAL_WIDTH, "center") -- DEBUG

	if #self.modifiers ~= 0 then
		for i, mod in pairs(self.modifiers) do
			mod:render()
		end
	end

	self.stateMachine:render()

	-- if self.state == "serve" then
	-- 	if self.server == 1 then
	-- 		love.graphics.printf("Left's serve", 0, 30, VIRTUAL_WIDTH, "center")
	-- 	elseif self.server == 2 then
	-- 		love.graphics.printf("Right's serve", 0, 30, VIRTUAL_WIDTH, "center")
	-- 	end
	--
	-- 	showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
	-- 	showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	-- 	self.characters.leftPaddle:render()
	-- 	self.characters.rightPaddle:render()
	--
	-- 	self.characters.ball:render()
	--
	-- 	self:render()
	--
	-- 	if #self.modifiers ~= 0 then
	-- 		for i, mod in pairs(self.modifiers) do
	-- 			mod:render()
	-- 		end
	-- 	end
	-- elseif self.state == "result" then
	-- 	if self.server == 1 then
	-- 		love.graphics.printf("Player 1 won!", 0, 30, VIRTUAL_WIDTH, "center")
	-- 	elseif self.server == 2 then
	-- 		love.graphics.printf("Player 2 won!", 0, 30, VIRTUAL_WIDTH, "center")
	-- 	end
	--
	-- 	showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
	-- 	showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	-- end
end

function Stage:togglePause()
	if self.state ~= "paused" then
		self.state = "paused"
		self:modify("pooled")
		ball:modify("pooled")
	else
		self.state = "rally"
		self:modify("normal")
		ball:modify("normal")
	end
end

function Stage:reset()
	ball:reset()

	self.modifiers = {}
end

function Stage:exit() end
