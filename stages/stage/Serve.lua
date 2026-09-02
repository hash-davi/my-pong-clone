Serve = Class({ __includes = BaseState })

function Serve:init(stage)
	self.stage = stage
end

function Serve:load(info)
	self.server = info.server
	self.timers = info.timers

	self.score = info.score

	self.modifiers = info.modifiers
	self.characters = self.stage.characters
	self.paddles = self.stage.paddles

	self.characters.ball:reset()
end

function Serve:update(dt)
	for i, paddle in pairs(self.paddles) do
		paddle:update(dt)
	end

	if self.server == 1 then
		self.characters.ball.dx = BALL_DX
	elseif self.server == 2 then
		self.characters.ball.dx = -BALL_DX
	end

	if love.keyboard.wasPressed("return") then
		self.characters.ball:serve()
		self.stage.stateMachine:transitionTo("rally", {
			rallyTime = 0,
			score = self.score,
			modifiers = self.modifiers,
			timers = self.timers,
		})
	end
end

function Serve:render()
	love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
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
