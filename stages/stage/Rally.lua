Rally = Class({ __includes = BaseState })

local modTypes = {
	"stretcher",
	"slow_motion",
	-- "8_ball_pong",
}

local modRanges = {
	["slow_motion"] = "stage",
	["stretcher"] = "paddle",
	-- ["8_ball_pong"] = "stage",
}

local modTypesConverter = {
	["stretcher"] = "stretched",
	["slow_motion"] = "slower",
	-- ["8_ball_pong"] = "pooled",
}

function Rally:init(stage)
	self.stage = stage
end

function Rally:load(info)
	self.time = info.rallyTime
	self.timers = info.timers
	self.scorer = info.server

	self.score = info.score

	self.modifiers = info.modifiers
	self.characters = self.stage.characters
	self.paddles = self.stage.paddles
end

function Rally:update(dt)
	-- DEBUG ------
	if love.keyboard.wasPressed("p") then
		self.stage:modify("slower")
	end

	if self.stage.mode ~= "normal" then
		self.timers.cooldown = self.timers.cooldown + dt

		if self.timers.cooldown >= 10 then
			self.stage:modify("normal")
		end
	end

	self.timers.mod = self.timers.mod + dt
	self.time = self.time + dt

	for i, paddle in pairs(self.paddles) do
		paddle:update(dt)
	end

	self.characters.ball:update(dt)

	-- Paddle vs Ball collision handling --------------
	for i, paddle in pairs(self.paddles) do
		if self.characters.ball:collidesWith(paddle) then
			self.characters.ball:setDx(-self.characters.ball.dx * 1.05)
			self.characters.ball:setDy(self.characters.ball.dy + paddle.dy / 2)

			if paddle.side == 1 then
				self.characters.ball:moveX(
					paddle.position.x + paddle.dimensions.width + 1 - self.characters.ball.position.x
				)
			else
				self.characters.ball:moveX(
					paddle.position.x - self.characters.ball.dimensions.width - 1 - self.characters.ball.position.x
				)
			end

			self.scorer = paddle.side
			love.audio.play(Game_sounds["hit_sound"])
		end
	end

	-- Ball vs Modifier collision handling ------------
	for i, mod in pairs(self.modifiers) do
		if self.characters.ball:collidesWith(mod) then
			if modRanges[mod.type] == "paddle" then
				if self.scorer == 1 then
					self.characters.leftPaddle:modify(modTypesConverter[mod.type], dt)
				elseif self.scorer == 2 then
					self.characters.rightPaddle:modify(modTypesConverter[mod.type], dt)
				end
			elseif modRanges[mod.type] == "stage" then
				self.stage:modify(modTypesConverter[mod.type])
			end

			table.remove(self.modifiers, i)
		end
	end

	if self.timers.mod >= 10 and #self.modifiers < 3 then
		self.timers.mod = 0
		table.insert(self.modifiers, Modifier(modTypes[math.random(#modTypes)]))
	end

	-- Scoring -----------
	if self.characters.ball.position.x < LEFT_ZONE then
		self.scorer = 2
		self.score.right = self.score.right + 1

		love.audio.play(Game_sounds["score_sound"])

		self.stage.stateMachine:transitionTo("serve", {
			server = self.scorer,
			timers = self.timers,
			score = self.score,
			modifiers = self.modifiers,
		})
	elseif self.characters.ball.position.x > RIGHT_ZONE - self.characters.rightPaddle.dimensions.width then
		self.scorer = 1
		self.score.left = self.score.left + 1

		love.audio.play(Game_sounds["score_sound"])

		self.stage.stateMachine:transitionTo("serve", {
			server = self.scorer,
			timers = self.timers,
			score = self.score,
			modifiers = self.modifiers,
		})
	end

	if self.score.left == 11 or self.score.right == 11 then
		self.stage.stateMachine:transitionTo("result", { winner = self.scorer })
	end
end

function Rally:render()
	if #self.modifiers ~= 0 then
		for i, mod in pairs(self.modifiers) do
			mod:render()
		end
	end

	for i, character in pairs(self.characters) do
		character:render()
	end

	showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
	showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
end

function Rally:modify(type)
	self.mode = type

	if self.mode == "normal" then
		self.timers.cooldown = 0
		slowingFactor = 1
		love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	elseif self.mode == "slower" then
		slowingFactor = 0.2
		love.graphics.setColor(93 / 255, 211 / 255, 158 / 255)
	end
end
