Paddle = Class({})

function Paddle:init(x, y, width, height, player)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.player = player
	self.dy = PLAYER_VELOCITY
end

function Paddle:render()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Paddle:update(dt)
	if self.player == 1 then
		if love.keyboard.isDown("w") then
			self.y = math.max(self.y - self.dy * dt, TOP_WALL)
		end
		if love.keyboard.isDown("s") then
			self.y = math.min(self.y + self.dy * dt, BOTTOM_WALL)
		end
	elseif self.player == 2 then
		if love.keyboard.isDown("up") then
			self.y = math.max(self.y - self.dy * dt, TOP_WALL)
		end
		if love.keyboard.isDown("down") then
			self.y = math.min(self.y + self.dy * dt, BOTTOM_WALL)
		end
	end
end
