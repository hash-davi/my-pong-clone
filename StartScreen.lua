StartScreen = Class({ __includes = BaseState })

function StartScreen:update()
	if love.keyboard.wasPressed("space") then
		Game.stateMachine:transitionTo("menu")
	end
end

function StartScreen:render()
	love.graphics.setFont(game_fonts["large"])
	love.graphics.printf("Pong 'til the end of times", VIRTUAL_WIDTH / 4, 50, VIRTUAL_WIDTH / 2, "center")

	love.graphics.setFont(game_fonts["small"])
	love.graphics.printf("Press any key to play", 0, VIRTUAL_HEIGHT - 60, VIRTUAL_WIDTH, "center")
end
