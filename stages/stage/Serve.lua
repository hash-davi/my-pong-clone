Serve = Class({ __includes = BaseState })

function Serve:render()
	if stage.server == 1 then
		love.graphics.printf("Left's serve", 0, 30, VIRTUAL_WIDTH, "center")
	elseif stage.server == 2 then
		love.graphics.printf("Right's serve", 0, 30, VIRTUAL_WIDTH, "center")
	end

	showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
	showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
	stage.characters.leftPaddle:render()
	stage.characters.rightPaddle:render()

	stage.characters.ball:render()

	if #stage.modifiers ~= 0 then
		for i, mod in pairs(stage.modifiers) do
			mod:render()
		end
	end
end
