Result = Class({ __includes = BaseState })

function Result:load(info)
	self.winner = info.winner
end

function Result:update(dt)
	if love.keyboard.wasPressed("return") then
		Game.stateMachine:transitionTo("start")
	end
end

function Result:render()
	love.graphics.setFont(Game_fonts["large"])
	if self.winner == 1 then
		love.graphics.printf("Player 1 won!", 0, 30, VIRTUAL_WIDTH, "center")
	elseif self.winner == 2 then
		love.graphics.printf("Player 2 won!", 0, 30, VIRTUAL_WIDTH, "center")
	end

	showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
	showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
end
