Serve = Class({ __includes = BaseState })

function Serve:load(info)
	self.server = info.server
end

function Serve:update(dt)
	Stage.characters.ball:reset()

	if self.server == 1 then
		Stage.characters.ball.dx = BALL_DX
	elseif self.server == 2 then
		Stage.characters.ball.dx = -BALL_DX
	end

	if love.keyboard.wasPressed("return") then
		Stage.stateMachine:transitionTo("rally", { rallyTime = 0 })
	end
end

function Serve:render()
	if self.server == 1 then
		love.graphics.printf("Left's serve", 0, 30, VIRTUAL_WIDTH, "center")
	elseif self.server == 2 then
		love.graphics.printf("Right's serve", 0, 30, VIRTUAL_WIDTH, "center")
	end

	showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
	showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	Stage.characters.leftPaddle:render()
	Stage.characters.rightPaddle:render()

	Stage.characters.ball:render()

	if #Stage.modifiers ~= 0 then
		for i, mod in pairs(Stage.modifiers) do
			mod:render()
		end
	end
end
