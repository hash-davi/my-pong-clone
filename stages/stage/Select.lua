Select = Class({ __includes = BaseState })

function Select:init(stage)
	self.stage = stage
end

function Select:load(info)
	self.timers = info.timers
	self.mode = info.mode

	self.score = info.score

	self.characters = info.characters
	self.paddles = info.paddles
end

function Select:update(dt)
	if love.keyboard.wasPressed("w") or love.keyboard.wasPressed("s") then
		self.stage:activate(self.characters.leftPaddle)
	end

	if love.keyboard.wasPressed("up") or love.keyboard.wasPressed("down") then
		self.stage:activate(self.characters.rightPaddle)
	end

	for i, paddle in pairs(self.paddles) do
		paddle:update(dt)
	end

	if love.keyboard.wasPressed("return") then
		self.stage.stateMachine:transitionTo("serve", {
			server = 1,
			mode = self.mode,
			timers = self.timers,
			score = self.score,
			modifiers = {},
			characters = self.characters,
			paddles = self.paddles,
		})
	end
end

function Select:render()
	for i, character in pairs(self.characters) do
		character:render()
	end
end
