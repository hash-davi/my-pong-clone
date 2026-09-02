StateMachine = Class({})

function StateMachine:init(states)
	self.empty = {
		load = function() end,
		update = function() end,
		render = function() end,
		exit = function() end,
	}

	self.states = states or {}

	self.currentState = self.empty
end

function StateMachine:transitionTo(targetState, info)
	assert(self.states[targetState])

	self.currentState:exit()
	self.currentState = self.states[targetState]()
	self.currentState:load(info)
end

function StateMachine:update(dt)
	self.currentState:update(dt)
end

function StateMachine:render()
	self.currentState:render()
end
