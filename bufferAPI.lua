
-- Made by Xelostar: https://www.youtube.com/channel/UCDE2STpSWJrIUyKtiYGeWxw

local screenBuffer = {}

local colorChar = {}
for i = 1, 16 do
	colorChar[2 ^ (i - 1)] = ("0123456789abcdef"):sub(i, i)
end

local function round(number)
	return math.floor(number + 0.5)
end

local function linear(x1, y1, x2, y2)
	local dy = y2 - y1
	local dx = x2 - x1

	local a = math.pow(10, 99)
	if (dx ~= 0) then
		a = dy / dx
	end
	local b = y1 - a * x1

	return a, b
end

function newBuffer(x1, y1, x2, y2)
	local buffer = {x1 = x1, y1 = y1, x2 = x2, y2 = y2, screenBuffer = {{}}, blittleWindow = -1}

	function buffer:setBufferSize(x1, y1, x2, y2)
		buffer.x1 = x1
		buffer.y1 = y1

		buffer.x2 = x2
		buffer.y2 = y2

		buffer:clear(colors.white)
	end

	function buffer:clear(color)
		buffer.screenBuffer.c1 = {}
		buffer.screenBuffer.c2 = {}
		buffer.screenBuffer.chars = {}
		for y = 1, buffer.y2 - buffer.y1 + 1 do
			buffer.screenBuffer.c1[y] = {}
			buffer.screenBuffer.c2[y] = {}
			buffer.screenBuffer.chars[y] = {}
			for x = 1, buffer.x2 - buffer.x1 + 1 do
				buffer.screenBuffer.c1[y][x] = colorChar[color]
				buffer.screenBuffer.c2[y][x] = colorChar[color]
				buffer.screenBuffer.chars[y][x] = " "
			end
		end
	end

	function buffer:setPixel(x, y, c1, c2, char)
		local x = round(x)
		local y = round(y)

		if (x >= 1 and x <= (buffer.x2 - buffer.x1 + 1)) then
			if (y >= 1 and y <= (buffer.y2 - buffer.y1 + 1)) then
				buffer.screenBuffer.c1[y][x] = colorChar[c1]
				buffer.screenBuffer.c2[y][x] = colorChar[c2]
				buffer.screenBuffer.chars[y][x] = char
			end
		end
	end

	function buffer:write(x, y, c1, c2, string)
		local charNr = 0
		for char in string:gmatch(".") do
			buffer:setPixel(x + charNr, y, c1, c2, char)
			charNr = charNr + 1
		end
	end

	function buffer:loadImage(dx, dy, image, useBlittle)
		for y, row in pairs(image) do
			for x, value in pairs(row) do
				if (value ~= nil and value > 0) then
					if (useBlittle == true) then
						buffer:setPixel(x + (dx - 1) * 2, y + (dy - 1) * 3, value, value, " ")
					else
						buffer:setPixel(x + dx - 1, y + dy - 1, value, value, " ")
					end
				end
			end
		end
	end

	function buffer:loadBox(x1, y1, x2, y2, c1, c2, char)
		for x = x1, x2 do
			for y = y1, y2 do
				buffer:setPixel(x, y, c1, c2, char)
			end
		end
	end

	function buffer:loadBorderBox(x1, y1, x2, y2, c1, c2, char)
		for x = x1, x2 do
			if (x == x1) then
				for y = y1, y2 do
					if (y == y1) then
						buffer:setPixel(x, y, c1, c2, string.char(151))
					elseif (y == y2) then
						buffer:setPixel(x, y, c2, c1, string.char(138))
					else
						buffer:setPixel(x, y, c1, c2, string.char(149))
					end
				end
			elseif (x == x2) then
				for y = y1, y2 do
					if (y == y1) then
						buffer:setPixel(x, y, c2, c1, string.char(148))
					elseif (y == y2) then
						buffer:setPixel(x, y, c2, c1, string.char(133))
					else
						buffer:setPixel(x, y, c2, c1, string.char(149))
					end
				end
			else
				for y = y1, y2 do
					if (y == y1) then
						buffer:setPixel(x, y, c1, c2, string.char(131))
					elseif (y == y2) then
						buffer:setPixel(x, y, c2, c1, string.char(143))
					else
						buffer:setPixel(x, y, c1, c2, char)
					end
				end
			end
		end
	end

	function buffer:loadBorderBoxBlittle(x1, y1, x2, y2, c1, c2, char)
		for x = x1, x2 do
			for y = y1, y2 do
				if (x == x1 or x == x2 or y == y1 or y == y2) then
					buffer:setPixel(x, y, c2, c1, " ")
				else
					buffer:setPixel(x, y, c1, c2, " ")
				end
			end
		end
	end

	function buffer:loadLine(x1, y1, x2, y2, c, char, charc)
		local a, b = linear(x1, y1, x2, y2)

		if (x2 >= x1) then
			local start = x1>1 and x1 or 1
			for x = start, x2 do
				local y = a * x + b
				buffer:setPixel(x, y, charc, c, char)

				if (x > buffer.x2 - buffer.x1 + 6) then
					break
				end
			end
		else
			local start = x2>1 and x2 or 1
			for x = start, x1 do
				local y = a * x + b
				buffer:setPixel(x, y, charc, c, char)

				if (x > buffer.x2 - buffer.x1 + 6) then
					break
				end
			end
		end

		if (y2 >= y1) then
			local start = y1>1 and y1 or 1
			for y = start, y2 do
				local x = (y - b) / a
				buffer:setPixel(x, y, charc, c, char)

				if (y > buffer.y2 - buffer.y1 + 6) then
					break
				end
			end
		else
			local start = y2>1 and y2 or 1
			for y = start, y1 do
				local x = (y - b) / a
				buffer:setPixel(x, y, charc, c, char)

				if (y > buffer.y2 - buffer.y1 + 6) then
					break
				end
			end
		end
	end

	function buffer:horLine(a1, b1, a2, b2, startY, endY, c, char, charc)
		if (startY < 0) then startY = 0
		elseif (startY > buffer.y2 - buffer.y1 + 2) then startY = buffer.y2 - buffer.y1 + 2 end
		if (endY < 0) then endY = 0
		elseif (endY > buffer.y2 - buffer.y1 + 2) then endY = buffer.y2 - buffer.y1 + 2 end

		for y = startY, endY do
			local y2 = y
			if (y ~= startY and y ~= endY) then
				y2 = round(y)
			end

			local x1 = round((round(y2 - 0.5) - b1) / a1)
			local x2 = round((round(y2 - 0.5) - b2) / a2)

			if (x1 < 0) then x1 = 0
			elseif (x1 > buffer.x2 - buffer.x1 + 2) then x1 = buffer.x2 - buffer.x1 + 2 end
			if (x2 < 0) then x2 = 0
			elseif (x2 > buffer.x2 - buffer.x1 + 2) then x2 = buffer.x2 - buffer.x1 + 2 end

			if (x1 < x2) then
				for x = x1, x2 do
					buffer:setPixel(x, y2, charc, c, char)
				end
			else
				for x = x2, x1 do
					buffer:setPixel(x, y2, charc, c, char)
				end
			end
		end
	end

	function buffer:loadTriangle(x1, y1, x2, y2, x3, y3, c, char, charc)
		char = char or " "
		charc = charc or c

		if (x1 < 0 and x2 < 0 and x3 < 0 or x1 > buffer.x2 - buffer.x1 + 2 and x2 > buffer.x2 - buffer.x1 + 2 and x3 > buffer.x2 - buffer.x1 + 2 or y1 < 0 and y2 < 0 and y3 < 0 or y1 > buffer.y2 - buffer.y1 + 2 and y2 > buffer.y2 - buffer.y1 + 2 and y3 > buffer.y2 - buffer.y1 + 2) then
			return
		elseif (x1 == x2 and x2 == x3 and y1 == y2 and y2 == y3) then
			buffer:setPixel(x1, y1, charc, c, char)
		elseif (math.min(x1, x2, x3) >= math.max(x1, x2, x3) - 1 and math.min(y1, y2, y3) >= math.max(y1, y2, y3) - 1) then
			buffer:setPixel(x1, y1, charc, c, char)
			buffer:setPixel(x2, y2, charc, c, char)
			buffer:setPixel(x3, y3, charc, c, char)
		else
			local a1, b1 = linear(x1, y1, x2, y2)
			local a2, b2 = linear(x2, y2, x3, y3)
			local a3, b3 = linear(x1, y1, x3, y3)

			buffer:loadLine(x1, y1, x2, y2, c, char, charc)
			buffer:loadLine(x2, y2, x3, y3, c, char, charc)
			buffer:loadLine(x3, y3, x1, y1, c, char, charc)

			if (y1 <= y2 and y1 <= y3) then
				if (y2 <= y3) then
					if (a1 ~= 0) then
						buffer:horLine(a1, b1, a3, b3, y1, y2, c, char, charc)
					end
					if (a2 ~= 0) then
						buffer:horLine(a2, b2, a3, b3, y2, y3, c, char, charc)
					end
				else
					if (a3 ~= 0) then
						buffer:horLine(a1, b1, a3, b3, y1, y3, c, char, charc)
					end
					if (a2 ~= 0) then
						buffer:horLine(a1, b1, a2, b2, y3, y2, c, char, charc)
					end
				end
			elseif (y2 <= y1 and y2 <= y3) then
				if (y1 <= y3) then
					if (a1 ~= 0) then
						buffer:horLine(a1, b1, a2, b2, y2, y1, c, char, charc)
					end
					if (a3 ~= 0) then
						buffer:horLine(a2, b2, a3, b3, y1, y3, c, char, charc)
					end
				else
					if (a2 ~= 0) then
						buffer:horLine(a1, b1, a2, b2, y2, y3, c, char, charc)
					end
					if (a3 ~= 0) then
						buffer:horLine(a1, b1, a3, b3, y3, y1, c, char, charc)
					end
				end
			else
				if (y1 <= y2) then
					if (a3 ~= 0) then
						buffer:horLine(a2, b2, a3, b3, y3, y1, c, char, charc)
					end
					if (a1 ~= 0) then
						buffer:horLine(a1, b1, a2, b2, y1, y2, c, char, charc)
					end
				else
					if (a2 ~= 0) then
						buffer:horLine(a2, b2, a3, b3, y3, y2, c, char, charc)
					end
					if (a1 ~= 0) then
						buffer:horLine(a1, b1, a3, b3, y2, y1, c, char, charc)
					end
				end
			end
		end
	end

	function buffer:loadCircle(x, y, c1, c2, char, radius)
		for loopX = buffer.x1, buffer.x2 do
			for loopY = buffer.y1, buffer.y2 do
				local dx = loopX - x
				local dy = loopY - y
				local distance = math.sqrt(dx^2 + dy^2)

				if (round(distance) <= radius) then
					buffer:setPixel(loopX, loopY, c1, c2, char)
				end
			end
		end
	end

	function buffer:drawBuffer(blittleOn)
		if (blittleOn == false) then
			for y = 1, buffer.y2 - buffer.y1 + 1 do
				local chars = table.concat(buffer.screenBuffer.chars[y])
				local c1s = table.concat(buffer.screenBuffer.c1[y])
				local c2s = table.concat(buffer.screenBuffer.c2[y])

				term.setCursorPos(buffer.x1, y + buffer.y1 - 1)
				term.blit(chars, c1s, c2s)
			end
		else
			if (buffer.blittleWindow == -1) then
				buffer.blittleWindow = blittle.createWindow(term.current(), (buffer.x1-1)*0.5+1, (buffer.y1-1)*0.333333 + 1, (buffer.x2 - buffer.x1)*0.5+1, (buffer.y2 - buffer.y1)*0.333333, false)
			end

			for y = 1, buffer.y2 - buffer.y1 - 2 do
				local chars = table.concat(buffer.screenBuffer.chars[y])
				local c1s = table.concat(buffer.screenBuffer.c1[y])
				local c2s = table.concat(buffer.screenBuffer.c2[y])

				buffer.blittleWindow.setCursorPos(1, y)
				buffer.blittleWindow.blit(chars, c1s, c2s)
			end
			buffer.blittleWindow.setVisible(true)
			buffer.blittleWindow.setVisible(false)
		end
	end

	return buffer
end