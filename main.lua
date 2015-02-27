local settings = require "settings"

local options = {
	{
		txt = 'Mode',
		sel = 1,
		sub = {
			{
				txt = 'Infinite Play',
			},
			{
				txt = 'Timed Game',
				sel = 1,
				sub = {
					{ txt = '0:30', },
					{ txt = '1:00', },
					{ txt = '2:00', },
					{ txt = '5:00', },
				},
			},
		},
	},
	{
		txt = 'Volume',
		set = function(val)
			love.audio.setVolume(val)
		end,
		sel = 1,
		sub = {
			{
				txt = 'Music',
				val = 1.0,
				set = function(val)
					atmo:setVolume(val)
				end,
				sel = 10,
				sub = {
					{ val = 1.0, txt = '100%', },
					{ val = 0.9, txt = '90%', },
					{ val = 0.8, txt = '80%', },
					{ val = 0.7, txt = '70%', },
					{ val = 0.6, txt = '60%', },
					{ val = 0.5, txt = '50%', },
					{ val = 0.4, txt = '40%', },
					{ val = 0.3, txt = '30%', },
					{ val = 0.2, txt = '20%', },
					{ val = 0.1, txt = '10%', },
					{ val = 0.0, txt = 'Off', },
				},
			},
			{
				txt = 'Sound Effects',
				val = 1.0,
				set = function(val)
					tick:setVolume(val)
				end,
				sel = 8,
				sub = {
					{ val = 1.0, txt = '100%', },
					{ val = 0.9, txt = '90%', },
					{ val = 0.8, txt = '80%', },
					{ val = 0.7, txt = '70%', },
					{ val = 0.6, txt = '60%', },
					{ val = 0.5, txt = '50%', },
					{ val = 0.4, txt = '40%', },
					{ val = 0.3, txt = '30%', },
					{ val = 0.2, txt = '20%', },
					{ val = 0.1, txt = '10%', },
					{ val = 0.0, txt = 'Off', },
				},
			},
			{
				txt = 'Mute',
				val = 0.0,
			},
		},
	},
}

function love.load(arg)
	settings.load(options)
	settings.setSelectCallback(function() tick:play() end)

	tick = love.audio.newSource("tick.mp3", "static")
	tick:setVolume(0.3)

	atmo = love.audio.newSource("atmosphere.mp3", "stream")
	atmo:setVolume(0.1)
	atmo:setLooping(true)
	atmo:play()
end

function love.update(dt)
	settings.update(dt)
end

function love.mousepressed(x, y, button)
	settings.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	settings.mousereleased(x, y, button)
end

function love.keyreleased(key)
	settings.keyreleased(key)
end

function love.draw()
	settings.draw()
end
