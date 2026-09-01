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
	self.mode = info.mode
	self.timers = info.timers
	self.scorer = info.server

	self.score = info.score

	self.modifiers = info.modifiers
	self.characters = info.characters
	self.paddles = info.paddles
end

function Rally:update(dt)
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

	self.characters.ball:setDx(self.characters.ball.dx)
	self.characters.ball:moveX(self.characters.ball.dx * dt * slowingFactor)
	self.characters.ball:setDy(self.characters.ball.dy)
	self.characters.ball:moveY(self.characters.ball.dy * dt * slowingFactor)

	-- self.characters.ball --------------
	if self.characters.ball:collidesWith(self.characters.leftPaddle) then
		self.characters.ball:setDx(-self.characters.ball.dx * 1.05)
		self.characters.ball:setDy(self.characters.ball.dy + self.characters.leftPaddle.dy / 2)
		self.characters.ball:moveX(
			self.characters.leftPaddle.position.x
				+ self.characters.leftPaddle.dimensions.width
				+ 1
				- self.characters.ball.position.x
		)
		self.scorer = 1

		love.audio.play(Game_sounds["hit_sound"])
	end
	if self.characters.ball:collidesWith(self.characters.rightPaddle) then
		self.characters.ball:setDx(-self.characters.ball.dx * 1.05)
		self.characters.ball:setDy(self.characters.ball.dy + self.characters.rightPaddle.dy / 2)
		self.characters.ball:moveX(
			self.characters.rightPaddle.position.x
				- self.characters.ball.dimensions.width
				- 1
				- self.characters.ball.position.x
		)
		self.scorer = 2

		love.audio.play(Game_sounds["hit_sound"])
	end

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

	if
		self.characters.ball.position.y + self.characters.ball.dimensions.height >= BOTTOM_WALL + 10
		or self.characters.ball.position.y <= TOP_WALL
	then
		self.characters.ball:setDy(-self.characters.ball.dy)

		if self.characters.ball.position.y + self.characters.ball.dimensions.height >= BOTTOM_WALL + 10 then
			self.characters.ball:moveY(-1)
		elseif self.characters.ball.position.y <= TOP_WALL then
			self.characters.ball:moveY(1)
		end

		love.audio.play(Game_sounds["hit_sound"])
	end

	self.characters.ball:update(dt)

	if self.timers.mod >= 10 and #self.modifiers <= 2 then
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
			mode = self.mode,
			score = self.score,
			modifiers = self.modifiers,
			characters = self.characters,
			paddles = self.paddles,
		})
	elseif self.characters.ball.position.x > RIGHT_ZONE - self.characters.rightPaddle.dimensions.width then
		self.scorer = 1
		self.score.left = self.score.left + 1

		love.audio.play(Game_sounds["score_sound"])

		self.stage.stateMachine:transitionTo("serve", {
			server = self.scorer,
			timers = self.timers,
			mode = self.mode,
			score = self.score,
			modifiers = self.modifiers,
			characters = self.characters,
			paddles = self.paddles,
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
