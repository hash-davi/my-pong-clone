Ball = Class({})

require("characters.ball.Ball_Static")

function Ball:init(position, dimensions)
	self.position = position
	self.dimensions = dimensions

	self.dx = BALL_DX
	self.dy = math.random(-100, 100)

	self.cooldown = 0

	self.stateMachine = StateMachine({
		["static"] = function()
			return Ball_Static()
		end,
		["dynamic"] = function()
			return Dynamic()
		end,
	})
	self.mode = "normal"
end

function Ball:load(info)
	StageCharacters = info.stageCharacters
	self.stateMachine:transitionTo(
		"static",
		{ stateMachine = self.stateMachine, parent = self, stageCharacters = StageCharacters }
	)
end

function Ball:update(dt)
	if self.mode ~= "normal" then
		self.cooldown = self.cooldown + dt

		if self.cooldown >= 10 then
			self:modify("normal")
		end
	end
end

function Ball:render()
	love.graphics.rectangle("fill", self.position.x, self.position.y, self.dimensions.width, self.dimensions.height)
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
	self.position.x = 201
	self.position.y = VIRTUAL_HEIGHT / 2
	self.dx = BALL_DX
	self.dy = math.random(-100, 100)
	-- self.state = "static"
end

function Ball:modify(type)
	self.mode = type

	if self.mode == "normal" then
		self.cooldown = 0
	end
end

function Ball:moveX(distanceX)
	-- self.state = "moving"

	if distanceX ~= 0 then
		self.position.x = self.position.x + distanceX
	end
end

function Ball:moveY(distanceY)
	-- self.state = "moving"

	if distanceY ~= 0 then
		self.position.y = self.position.y + distanceY
	end
end

function Ball:setDx(speed)
	self.dx = math.min(speed)
end

function Ball:setDy(speed)
	self.dy = math.min(speed, BALL_DX * 2)
end
