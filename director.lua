
director = {}
director.__index = director

--[[	director
	init functions:
		variable = director.start(font, rootdir, target, x, y, w, h)
	closing functions:
		data = variable:update() returns the path the user selects in director.
		director.close() closes the most recent director instance, which should be the only one.
	example *full* implementation:
		variable = director.start(font, rootdir, target, x, y ,w ,h)
		if type(variable) == "table" then
			string = variable:update()
			if type(string) == "string" then director.close() end
		end
		data = love.graphics.newImage(string)
]]

function director.start(font, dir, target, x, y, w, h) -- font, directory, window x, y, w, h. theming will be handled by the program calling director. if a need arises, asset-based theming can be implemented later.
	t = {}
	t.font = font
	t.fonth = t.font:getHeight()
	t.dirtab = love.filesystem.getDirectoryItems(dir)
	t.w = {x,y,w,h} -- this table holds the window's desired location and dimensions.
	t.textinfo = {}
	t.root = dir
	t.dir = dir
	t.dirt = {}
	t.cursor = 1
	t.target = target
	t.ready = false
	t.canvas = love.graphics.newCanvas(w,h)
	t.tr, t.tg, t.tb, t.ta = love.graphics.getColor()
	t.br, t.bg, t.bb, t.ba = love.graphics.getBackgroundColor()
	return setmetatable(t, director)
end

function director.close()
	director[#director] = nil
end

function director:keypressed(k)

	if k == "down" then self.cursor = self.cursor + 1 end
	if k == "up" then self.cursor = self.cursor - 1 end
	if (k == "right" or k == "return") then self:checkFormat() end
	if (k == "right" or k == "return") and love.filesystem.getInfo(self:getDirectory().. "/" .. self.dirtab[self.cursor],"directory") then self:setDirectory(self.dirtab[self.cursor]) end
	if k == "left" and self.dir ~= self.root then self:leaveDirectory() end
	self:refresh()
end

function director:update() -- yeah, it does one thing
	if self.ready == true then return self.dir .. "/" .. self.dirtab[self.cursor] end
end

function director:draw() -- okay so, technically, since this is a vertically limited setup, we need infinite scrolling. so we need to render to texture to prevent display bleed.
	--- also a cool feature would be detecting the widest file name in all directories under graphics and automatically sizing the window to be slightly larger than that one, and as tall as the screen if no size info is given.
	
	love.graphics.push()
		love.graphics.setBlendMode("alpha", "premultiplied")
		love.graphics.draw(self.canvas, t.w[1], t.w[2])
		love.graphics.setBlendMode("alpha")
	love.graphics.pop()
end

function director:getDirectory()
	local string = self.root
	for n = 1, #self.dirt, 1 do
		string = string .. "/" .. self.dirt[n]
	end
	return string
end

function director:setDirectory(dir)
	self.dir = self.dir .. "/" .. dir
	self.dirtab = love.filesystem.getDirectoryItems(self.dir)
	self.dirt[#self.dirt+1] = dir
	self.cursor = 1
end

function director:leaveDirectory(dir)
	self.dirt[#self.dirt] = nil
	self.dir = self:getDirectory()
	self.dirtab = love.filesystem.getDirectoryItems(self.dir)
	self.cursor = 1
end

function director:refresh() -- this is how we handle the bleed problem with render to texture. technically this is also cheaper in processing cost, since we aren't needlessly updating every frame!
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear(0,0,0,0)
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(self.br, self.bg, self.bb, self.ba)
	love.graphics.rectangle("fill", 0, 0, self.w[3], self.w[4])
	love.graphics.setColor(self.tr, self.tg, self.tb, self.ta)
	local ext = ""
	for n, file in ipairs(self.dirtab) do
		if love.filesystem.getInfo(self.dir .. "/" .. file, "directory") then ext = "/" end
		if n == self.cursor then
			love.graphics.setColor(self.tr, self.tg, self.tb, self.ta)
			love.graphics.rectangle("fill",10,9 + ((self.fonth + 2) * (n + 3 - self.cursor)), self.canvas:getWidth()/3,self.fonth + 1)
			love.graphics.rectangle("fill",0,0, self.canvas:getWidth(),self.fonth + 1)
			love.graphics.setColor(self.br, self.bg, self.bb, self.ba)
			love.graphics.print(file..ext, 10, 10 + ((self.fonth + 2) * (n + 3 - self.cursor)))
			love.graphics.print(self.dir, 10, 1)
			love.graphics.setColor(t.tr, t.tg, t.tb, t.ta)
		else 
			love.graphics.print(file..ext, 10, 10 + ((self.fonth + 2) * (n + 3 - self.cursor))) -- thank you love2d wiki, i actually didn't know about ipairs aha
		end
	end
	love.graphics.rectangle("line", 0, 0, t.w[3], t.w[4])
	love.graphics.setCanvas()
end

function director:checkFormat()
	if self.dirtab[self.cursor] ~= string.gsub(self.dirtab[self.cursor], ".png", "hehe") then self.ready = true end
end
