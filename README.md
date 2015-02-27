# Ring Settings

A simple settings menu for LÖVE (love2d). Tested on Linux and Android.

This is a WIP. It works, but it certainly isn't done.

## Usage

### LÖVE Callback Functions

Most of Ring Settings functions definitions are identical to the basic LÖVE callback functions. These are used like this:

```lua
local settings = require "settings"

function love.load(arg)
	settings.load(options)
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
```

### The Options Table

The `options` argument to `settings.load` is a array of options, each potentially with a `sub` array of options, and so on.

The [main.lua](main.lua) file provides a straightforward example.

### Additional Functions

Aside from the functions mirroring the LÖVE callback functions, Ring Settings also has these.

#### setSelectCallback

In order to perform some action whenever a menu item is selected, we can pass a function into `setSelectCallback`. For example:

```lua
settings.setSelectCallback(
	function()
		tick:play()
	end
)
```

This would play the tick sound whenever an item is selected.

## Credit

Music in the demonstration is courtesy [Matt Hanson](http://www.calpomatt.com)
