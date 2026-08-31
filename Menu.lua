Menu = Class({ __include = BaseState })

function Menu:render()
	love.graphics.printf("My Pong", 0, 30, VIRTUAL_WIDTH, "center")
	if self.page == "mode_selection" then
		modeSelection()
	end
end
