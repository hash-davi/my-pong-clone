BallStatic = Class({ __includes = BaseState })

function BallStatic:init(ball)
	self.ball = ball
end

function BallStatic:load(info)
	self.stageCharacters = info.stageCharacters
end

function BallStatic:update(dt)
	if self.ball.served then
		self.ball.stateMachine:transitionTo("dynamic", { stageCharacters = self.stageCharacters })
	end
end

function BallStatic:render()
	love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	love.graphics.rectangle(
		"fill",
		self.ball.position.x,
		self.ball.position.y,
		self.ball.dimensions.width,
		self.ball.dimensions.height
	)
end
