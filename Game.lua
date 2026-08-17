Game = Class({})

-- Modules required ------------------------
require("Stage")

require("Menu")
--------------------------------------------

local possibleStates = {
	"start",
	"menu",
	"stage",
}

function showscore(player, x, y)
	love.graphics.setFont(game_fonts["large"])

	if player == 1 then
		score = stage.score.left
	elseif player == 2 then
		score = stage.score.right
	end

	love.graphics.print(tostring(score), x, y)
end

function Game:init()
	self.state = "start"
end

function Game:load()
	menu = Menu()

	game_fonts = {
		["large"] = love.graphics.newFont("font.ttf", 32),
		["medium"] = love.graphics.newFont("font.ttf", 24),
		["small"] = love.graphics.newFont("font.ttf", 16),
	}

	sounds = {
		["hit_sound"] = love.audio.newSource("sounds/sound.wav", "static"),
		["score_sound"] = love.audio.newSource("sounds/score.wav", "static"),
	}

	stage = Stage({
		leftPaddle = Paddle(10, TOP_WALL, PADDLE_WIDTH, PADDLE_HEIGHT, false),
		rightPaddle = Paddle(VIRTUAL_WIDTH - 20, BOTTOM_WALL - 20, PADDLE_WIDTH, PADDLE_HEIGHT, false),
		ball = Ball(201, VIRTUAL_HEIGHT / 2, 10, 10),
	})
end

function Game:update(dt)
	if self.state == "stage" then
		stage:update(dt)
	end
end

function Game:render()
	-- Graphics ---------
	if stage.mode == "slower" then
		love.graphics.clear(30 / 255, 85 / 255, 92 / 255, 1)
		love.graphics.setColor(93 / 255, 211 / 255, 158 / 255)
	else
		love.graphics.clear(58 / 255, 46 / 255, 57 / 255, 1)
		love.graphics.setColor(244 / 255, 216 / 255, 205 / 255)
	end

	if self.state == "start" then
		love.graphics.setFont(game_fonts["large"])
		love.graphics.printf("Pong 'til the end of times", VIRTUAL_WIDTH / 4, 50, VIRTUAL_WIDTH / 2, "center")

		love.graphics.setFont(game_fonts["small"])
		love.graphics.printf("Press any key to play", 0, VIRTUAL_HEIGHT - 60, VIRTUAL_WIDTH, "center")
		-- menu:render()
	elseif self.state == "stage" then
		showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
		showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
		stage.characters.leftPaddle:render()
		stage.characters.rightPaddle:render()

		stage.characters.ball:render()

		stage:render()

		if #stage.modifiers ~= 0 then
			for i, mod in pairs(stage.modifiers) do
				mod:render()
			end
		end

		if stage.state == "serve" then
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

			stage:render()

			if #stage.modifiers ~= 0 then
				for i, mod in pairs(stage.modifiers) do
					mod:render()
				end
			end
		elseif stage.state == "result" then
			if stage.server == 1 then
				love.graphics.printf("Player 1 won!", 0, 30, VIRTUAL_WIDTH, "center")
			elseif stage.server == 2 then
				love.graphics.printf("Player 2 won!", 0, 30, VIRTUAL_WIDTH, "center")
			end

			showscore(1, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 50)
			showscore(2, VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 - 50)
		end
	end
end

function Game:keypressed(key)
	if self.state == "start" then
		self.state = "stage"
		stage:load()
	end

	if key == "escape" then
		love.event.quit()
	end

	if key == "return" then
		if stage.state == "select" then
			stage.state = "serve"
		elseif stage.state == "serve" then
			stage.state = "rally"
		elseif stage.state == "result" then
			self.state = "start"
		end
	end

	if stage.state == "select" then
		if key == "w" or key == "s" then
			stage:activate(stage.characters.leftPaddle)
		end

		if key == "up" or key == "down" then
			stage:activate(stage.characters.rightPaddle)
		end
	elseif stage.state == "rally" then
		if key == "space" then
			stage:modify("slower")
		elseif key == "k" then
			stage.characters.leftPaddle:modify("stretched")
		end
	end
end
