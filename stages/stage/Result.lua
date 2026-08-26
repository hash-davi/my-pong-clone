Result = Class({ __includes = BaseState })

function Result:render()
	if stage.server == 1 then
		love.graphics.printf("Player 1 won!", 0, 30, VIRTUAL_WIDTH, "center")
	elseif stage.server == 2 then
		love.graphics.printf("Player 2 won!", 0, 30, VIRTUAL_WIDTH, "center")
	end

	showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
	showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
end
