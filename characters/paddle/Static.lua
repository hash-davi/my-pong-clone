Static = Class({ __includes = BaseState })

function Static:init(paddle)
	self.paddle = paddle
end

function Static:load(info)
	self.stageCharacters = info.stageCharacters
end

function Static:update(dt)
	if self.paddle.side == 1 then
		self:leftControl()
	else
		self:rightControl()
	end
end

function Static:leftControl()
	if self.paddle.playable then
		if love.keyboard.isDown("w") or love.keyboard.isDown("s") then
			self.paddle.stateMachine:transitionTo("dynamic", {
				stageCharacters = self.stageCharacters,
			})
		end
	elseif self.stageCharacters.ball.dx < 0 and self.stageCharacters.ball.position.x <= VIRTUAL_WIDTH / 2 then
		self.paddle.stateMachine:transitionTo("dynamic", {
			stageCharacters = self.stageCharacters,
		})
	end
end

function Static:rightControl()
	if self.paddle.playable then
		if love.keyboard.isDown("up") or love.keyboard.isDown("down") then
			self.paddle.stateMachine:transitionTo("dynamic", {
				stageCharacters = self.stageCharacters,
			})
		end
	elseif self.stageCharacters.ball.dx > 0 and self.stageCharacters.ball.position.x >= VIRTUAL_WIDTH / 2 then
		self.paddle.stateMachine:transitionTo("dynamic", {
			stageCharacters = self.stageCharacters,
		})
	end
end

function Static:render()
	if self.paddle.mode == "stretched" then
		love.graphics.setColor(241 / 255, 81 / 255, 82 / 255)
	else
		love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	end
	love.graphics.rectangle(
		"fill",
		self.paddle.position.x,
		self.paddle.position.y,
		self.paddle.dimensions.width,
		self.paddle.dimensions.height
	)
end
