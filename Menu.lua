Menu = Class({})

function Menu:init()
	self.page = "mode_selection"
end

function Menu:render()
	love.graphics.printf("My Pong", 0, 30, VIRTUAL_WIDTH, "center")
	if self.page == "mode_selection" then
		modeSelection()
	end
end

function modeSelection()
	love.graphics.printf("Singleplayer", 0, 120, VIRTUAL_WIDTH, "center")
	love.graphics.printf("Multiplayer", 0, 160, VIRTUAL_WIDTH, "center")
end
