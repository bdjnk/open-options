local flux = require "lib.flux"
local lume = require "lib.lume"
local look = require "lib.inspect"

conf = {}

local keys = {
	up    = "up",
	down  = "down",
	right = "right",
	left  = "left",
	exit  = "escape"
}

local f = {}
local path = { 1 }
local settings
local maxdepth
local drag = {
	y = 0, dy = 0,
	x = 0, dx = 0,
	state = false,
}
local mFont, dFont

function conf.setup(menu)
	settings = menu

	function recurse(sub)
		deepest = 0
		for k,v in ipairs(sub) do
			if v.sub then
				depth = recurse(v.sub)
				if depth > deepest then deepest = depth end
			end
		end
		return deepest + 1
	end
	maxdepth = recurse(menu)
	--print(maxdepth)

	mFont = love.graphics.newFont(18)
	dFont = love.graphics.newFont(14)
end

function conf.setkeys(down, left, up, right, exit)
end

function conf.update(dt)
	if love.mouse.isDown("l") then
		local fH = mFont:getHeight()*mFont:getLineHeight()
		local mx,my = love.mouse.getPosition()
		drag.dx = drag.dx + mx - drag.x
		drag.dy = drag.dy + my - drag.y
		drag.x = mx
		drag.y = my
		if drag.dy > fH then
			drag.dy = 0
			drag.state = true
			--drag.dy = drag.dy - 20
			f.goUp()
		elseif drag.dy < -fH then
			drag.dy = 0
			drag.state = true
			--drag.dy = drag.dy + 20
			f.goDown()
		end
	end
end

function conf.mousepressed(x, y, button)
	local vWd = viewW/maxdepth
	while x < vWd*(#path-1) do
		f.goLeft()
	end
	while x > vWd*(#path) do
		f.goRight()
	end
	if button == "l" then
		drag.x = x
		drag.y = y
	elseif button == "wd" then
		f.goDown()
	elseif button == "wu" then
		f.goUp()
	end
end

function conf.mousereleased(x, y, button)
	local vWd = viewW/maxdepth
	local fH = mFont:getHeight()*mFont:getLineHeight()
	
	if button == "l" then
		drag.x, drag.dx = 0, 0
		drag.y, drag.dy = 0, 0
		if drag.state == true then
			drag.state = false
			return
		end

		--print("=========================")
		-- columns of options (moves vertically)
		function recurse(sub, level, sel)
			if not sub then return end
			local selected = path[level] and path[level] or sel
			for index,option in ipairs(sub) do
				-- clickable area
				local ox,oy,ow,oh = vWd*(level-1), viewH/2-fH/2-(selected-index)*(fH+10), vWd, fH+space*2
				if x > ox and x < ox+ow and y > oy and y < oy+oh then
					-- we've clicked an option
					path[level] = index
					path = lume.slice(path, 1, level)
					--print("index:"..index..", level:"..level..", path:"..look(path).."\nsub:"..look(sub))

					sub = settings
					local set
					for level = 1, #path-1 do
						set = sub[path[level]].set
						sub = sub[path[level]].sub
					end
					if set then set(option.val) end
					return -- all done here

				end
			end
			if path[level] and selected ~= 0 then
				recurse(sub[selected].sub, level+1, sub[selected].sel)
			end
		end
		recurse(settings, 1, 1)
	end
end

function conf.keyreleased(key)
	if key == keys.exit then
		--print("return false")
		return false
	end
	if key == keys.right then -- delve into the menu
		f.goRight()
	elseif key == keys.left then -- back out of the menu
		f.goLeft()
	elseif key == keys.down then
		f.goDown()
	elseif key == keys.up then
		f.goUp()
	end
	return true
end

function f.goRight()
	if #path > 0 then
		local sub = settings
		local sel
		for level,index in ipairs(path) do
			sel = sub[index].sel
			sub = sub[index].sub
		end
		path[#path+1] = sel
	end
end
function f.goLeft()
	local sub = settings
	for level,index in ipairs(path) do
		if sub[index] and sub[index].sel and path[level+1] then
			sub[index].sel = path[level+1]
			sub = sub[index].sub
		end
	end
	if #path > 1 then
		path[#path] = nil
	end
end

function f.goDown()
	local sub = settings
	local set
	for level = 1, #path-1 do
		set = sub[path[level]].set
		sub = sub[path[level]].sub
	end
	if path[#path] == #sub then -- loop
		path[#path] = 1
	else
		path[#path] = path[#path] + 1
	end
	if set then -- apply setting
		set(sub[path[#path]].val)
	end
end

function f.goUp()
	local sub = settings
	local set
	for level = 1, #path-1 do
		set = sub[path[level]].set
		sub = sub[path[level]].sub
	end
	if path[#path] == 1 then -- loop
		path[#path] = #sub
	else
		path[#path] = path[#path] - 1
	end
	if set then -- apply setting
		set(sub[path[#path]].val)
	end
end

function conf.draw()
	local vWd = viewW/maxdepth

	local fH = mFont:getHeight()*mFont:getLineHeight()
	love.graphics.setFont(mFont)
	
	-- fullscreen background (never moves)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, 0, viewW, viewH)
	love.graphics.setColor(0, 0, 255)
	love.graphics.rectangle("fill", 0+space, 0+space, viewW-space*2, viewH-space*2)
	
	-- center-line background (never moves)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, viewH/2-fH/2-space, viewW, fH+space*2)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", 0+space, viewH/2-fH/2, viewW-space*2, fH)
	
	-- selected item background (moves horizontally)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", vWd*(#path-1), viewH/2-fH/2-space, vWd, fH+space*2)
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", vWd*(#path-1)+space, viewH/2-fH/2, vWd-space*2, fH)
	
	-- columns of options (moves vertically)
	function recurse(sub, level, sel)
		if not sub then return end
		local selected = path[level] and path[level] or sel
		for index,option in ipairs(sub) do
			love.graphics.setColor(255, 255, 255)
			love.graphics.print(option.txt,
				vWd*(level-1) + ((vWd-mFont:getWidth(option.txt))/2),
				viewH/2-fH/2-(selected-index)*(fH+10))
		end	
		if path[level] and selected ~= 0 then
			recurse(sub[selected].sub, level+1, sub[selected].sel)
		end
	end
	recurse(settings, 1, 1)
	
	--love.graphics.setFont(dFont)
	--love.graphics.printf(look(drag), 10, 10, 800)
	--love.graphics.printf(look(settings), 10, 10, 800)
	--love.graphics.printf(look(path), 310, 10, 800)
	--return
end

return conf
