Ball = Class({})

require("src.characters.ball.BallStatic")
require("src.characters.ball.BallDynamic")

function Ball:init(position, dimensions)
	self.position = position
	self.dimensions = dimensions

	self.dx = BALL_DX
	self.dy = math.random(-BALL_DX, BALL_DX)

	self.served = false

	self.cooldown = 0

	self.stateMachine = StateMachine({
		["static"] = function()
			return BallStatic(self)
		end,
		["dynamic"] = function()
			return BallDynamic(self)
		end,
	})
	self.mode = "normal"
end

function Ball:load(info)
	StageCharacters = info.stageCharacters
	self.stateMachine:transitionTo("static", { stageCharacters = StageCharacters })
end

function Ball:update(dt)
	self.stateMachine:update(dt)

	if self.mode ~= "normal" then
		self.cooldown = self.cooldown + dt

		if self.cooldown >= 10 then
			self:modify("normal")
		end
	end
end

function Ball:render()
	self.stateMachine:render()
end

function Ball:collidesWith(paddle)
	if
		self.position.x > paddle.position.x + paddle.dimensions.width
		or self.position.x + self.dimensions.width < paddle.position.x
	then
		return false
	end

	if
		self.position.y > paddle.position.y + paddle.dimensions.height
		or self.position.y + self.dimensions.height < paddle.position.y
	then
		return false
	end

	return true
end

function Ball:reset()
	self.position = {
		x = VIRTUAL_WIDTH / 2 - self.dimensions.width / 2 - 10,
		y = VIRTUAL_HEIGHT / 2,
	}
	self.dx = BALL_DX
	self.dy = math.random(-BALL_DX, BALL_DX)
	self.served = false

	self.stateMachine:transitionTo("static", { stageCharacters = StageCharacters })
end

function Ball:modify(type)
	self.mode = type

	if self.mode == "normal" then
		self.cooldown = 0
	end
end

function Ball:moveX(distanceX)
	if distanceX ~= 0 then
		self.position.x = self.position.x + distanceX
	end
end

function Ball:moveY(distanceY)
	if distanceY ~= 0 then
		self.position.y = self.position.y + distanceY
	end
end

function Ball:setDx(speed)
	self.dx = speed > 0 and math.min(speed, BALL_DX * 4) or math.max(speed, -BALL_DX * 4)
end

function Ball:setDy(speed)
	self.dy = speed > 0 and math.min(speed, BALL_DX * 2) or math.max(speed, -BALL_DX * 2)
end

function Ball:serve()
	self.served = true
end
