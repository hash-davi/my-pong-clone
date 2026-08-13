Stage = Class({})

require("Paddle")

require("Ball")

require("Modifier")

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

TOP_WALL = 15
BOTTOM_WALL = VIRTUAL_HEIGHT - 25

PADDLE_WIDTH = 10
PADDLE_HEIGHT = 30

PLAYER_VELOCITY = 200
BALL_DX = 100

local modTypes = {
	"stretcher",
	"slow_motion",
}

local modRanges = {
	["slow_motion"] = "stage",
	["stretcher"] = "paddle",
}

local modTypesConverter = {
	["stretcher"] = "stretched",
	["slow_motion"] = "slower",
}

local possibleStates = {
	"select",
	"serve",
	"rally",
	"paused",
	"countdown",
	"result",
}

function Stage:init(characters)
	self.characters = characters
	self.actives = {}
	self.modifiers = {}

	self.server = 1

	self.state = "serve"
	self.mode = "normal"
	self.cooldown = 0
end

function Stage:load()
	leftPaddle = self.characters.leftPaddle
	rightPaddle = self.characters.rightPaddle
	ball = self.characters.ball

	player1_score = 0
	player2_score = 0

	modTimer = 0

	self.state = "select"
end

function Stage:update(dt)
	modTimer = modTimer + dt

	if self.mode ~= "normal" then
		self.cooldown = self.cooldown + dt

		if self.cooldown >= 10 then
			self:modify("normal")
		end
	end

	-- Left paddle ------
	if leftPaddle.playable then
		if love.keyboard.isDown("w") then
			leftPaddle:moveY(-PLAYER_VELOCITY, dt)
		elseif love.keyboard.isDown("s") then
			leftPaddle:moveY(PLAYER_VELOCITY, dt)
		else
			leftPaddle:stop()
		end
	end

	leftPaddle:update(dt)

	-- Right Paddle ------
	if rightPaddle.playable then
		if love.keyboard.isDown("up") then
			rightPaddle:moveY(-100, dt)
		elseif love.keyboard.isDown("down") then
			rightPaddle:moveY(100, dt)
		else
			rightPaddle:stop()
		end
	end

	rightPaddle:update(dt)

	if self.state == "serve" then
		ball:reset()

		if self.server == 1 then
			ball.dx = BALL_DX
		elseif self.server == 2 then
			ball.dx = -BALL_DX
		end
	elseif self.state == "rally" then
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

		-- Ball --------------
		if ball:collidesWith(leftPaddle) then
			ball.dx = math.min(-ball.dx * 1.05, BALL_DX * 2)
			ball.dy = ball.dy + leftPaddle.dy / 2
			ball.x = leftPaddle.x + leftPaddle.width + 1
			scorer = 1

			love.audio.play(sounds["hit_sound"])
		end
		if ball:collidesWith(rightPaddle) then
			ball.dx = math.min(-ball.dx * 1.05, BALL_DX * 2)
			ball.dy = ball.dy + rightPaddle.dy / 2
			ball.x = rightPaddle.x - ball.width - 1
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
			ball.dy = -ball.dy
			love.audio.play(sounds["hit_sound"])
		end

		ball:update(dt)

		if modTimer >= 10 and #self.modifiers <= 2 then
			modTimer = 0
			table.insert(self.modifiers, Modifier(modTypes[math.random(#modTypes)]))
		end

		-- Scoring -----------
		if ball.x < leftPaddle.x then
			player2_score = player2_score + 1

			love.audio.play(sounds["score_sound"])

			self.server = 2
			self.state = "serve"
		elseif ball.x > rightPaddle.x then
			player1_score = player1_score + 1

			love.audio.play(sounds["score_sound"])

			self.server = 1
			self.state = "serve"
		end

		if player1_score == 1 or player2_score == 11 then
			self.state = "result"
		end
	elseif self.state == "result" then
		self:reset()
	end
end

function Stage:activate(paddle)
	paddle.playable = true

	table.insert(self.actives, paddle)
end

function Stage:modify(type)
	self.mode = type

	if self.mode == "normal" then
		self.cooldown = 0
	end
	if self.mode == "slower" then
		for i, character in pairs(self.characters) do
			character.dy = character.dy * 0.5
		end
	end
end

function Stage:reset()
	ball:reset()

	self.modifiers = {}
end
