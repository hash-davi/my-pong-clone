Serve = Class({ __includes = BaseState })

function Serve:init(stage)
	self.stage = stage
end

function Serve:load(info)
	self.server = info.server
	self.timers = info.timers
	self.mode = info.mode

	self.score = info.score

	self.modifiers = info.modifiers
	self.characters = info.characters
	self.paddles = info.paddles
end

function Serve:update(dt)
	self.characters.ball:reset()

	for i, paddle in pairs(self.paddles) do
		paddle:update(dt)
	end

	if self.server == 1 then
		self.characters.ball.dx = BALL_DX
	elseif self.server == 2 then
		self.characters.ball.dx = -BALL_DX
	end

	if love.keyboard.wasPressed("return") then
		self.stage.stateMachine:transitionTo("rally", {
			rallyTime = 0,
			mode = self.mode,
			score = self.score,
			modifiers = self.modifiers,
			characters = self.characters,
			paddles = self.paddles,
			timers = self.timers,
		})
	end
end

function Serve:render()
	love.graphics.setFont(Game_fonts["large"])
	if self.server == 1 then
		love.graphics.printf("Left's serve", 0, 30, VIRTUAL_WIDTH, "center")
	elseif self.server == 2 then
		love.graphics.printf("Right's serve", 0, 30, VIRTUAL_WIDTH, "center")
	end

	showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
	showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)

	for i, character in pairs(self.characters) do
		character:render()
	end

	if #self.modifiers ~= 0 then
		for i, mod in pairs(self.modifiers) do
			mod:render()
		end
	end
end
