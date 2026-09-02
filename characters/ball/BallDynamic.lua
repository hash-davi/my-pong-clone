BallDynamic = Class({ __includes = BaseState })

function BallDynamic:init(ball)
	self.ball = ball
end

function BallDynamic:load(info)
	self.stageCharacters = info.stageCharacters
end

function BallDynamic:update(dt)
	self.ball:setDx(self.ball.dx)
	self.ball:moveX(self.ball.dx * dt * slowingFactor)
	self.ball:setDy(self.ball.dy)
	self.ball:moveY(self.ball.dy * dt * slowingFactor)

	if self.ball.position.y + self.ball.dimensions.height >= BOTTOM_WALL + 10 or self.ball.position.y <= TOP_WALL then
		self.ball:setDy(-self.ball.dy)

		if self.ball.position.y + self.ball.dimensions.height >= BOTTOM_WALL + 10 then
			self.ball:moveY(-1)
		elseif self.ball.position.y <= TOP_WALL then
			self.ball:moveY(1)
		end

		love.audio.play(Game_sounds["hit_sound"])
	end
end

function BallDynamic:render()
	love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	love.graphics.rectangle(
		"fill",
		self.ball.position.x,
		self.ball.position.y,
		self.ball.dimensions.width,
		self.ball.dimensions.height
	)
end
