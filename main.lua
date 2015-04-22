-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

cellWidth = 40
cellHeight = 40

--------------------------------------------------------------------
--- Board
--------------------------------------------------------------------
local Board = {}

function Board:new()
	local newObj = {
		width = 6,
		height = 6,
		map = {}
	}

	for i = newObj.height, 1, -1 do
		newObj.map[i] = {}
	end

	self.__index = self
	return setmetatable( newObj, self )
end

function Board:addToken( x, y, token)
	self.map[x][y] = token
	token.board = self
	token.x = x
	token.y = y
end

function Board:getToken( x, y )
	return self.map[x][y]
end

function Board:moveToken(token, x, y )
	self.map[token.x][token.y] = nil;
	self.map[x][y] = token
	token.x = x
	token.y = y
end

--------------------------------------------------------------------
--- Token
--------------------------------------------------------------------
local Token = {	
	x = 0,
	y = 0,

	owner = "blue",
	isHorizontal = true,
	isMaster = false,
	isSelected = false,
	board = nil,

	observers = nil
}

function Token:new(o)
	local newObj = o or {}
	setmetatable( newObj, self )
	self.__index = self

	newObj.observers = {}

	local proxy = {}
	setmetatable( proxy, {
		__index = function (t,k)
		    return newObj[k]
		end,

		__newindex = function ( t, k, v )
			local oldValue = newObj[k]
			newObj[k] = v
			newObj:onValueChanged(k, oldValue, v)
		end
	} )

	return proxy
end

function Token:onValueChanged( key, oldValue, newValue )
	for _, observer in ipairs(self.observers) do
		observer:onValueChanged(key, oldValue, newValue)
	end
end

function Token:registerObserver(observer)
	table.insert( self.observers, observer )
end

function Token:move(x, y)
	board:moveToken(self, x, y)
end
--------------------------------------------------------------------
--- Token View
--------------------------------------------------------------------
local TokenView = {
	token = nil,
	img = nil,
	group = nil,
	imgSelected = nil
}

function TokenView:new(tokenObj, group)
	local newObj = {}
	setmetatable( newObj, self )
	self.__index = self

	newObj.token = tokenObj
	newObj.group = group
	newObj.imgSelected = display.newRect( group, 0, 0, cellWidth, cellHeight )
	newObj.imgSelected.fill = nil
	newObj.imgSelected.stroke = {255/193, 187/255, 51/255}
	newObj.imgSelected.strokeWidth = 3
	newObj:updateImg()

	-- Runtime:addEventListener( "tap", newObj )

	tokenObj:registerObserver(newObj)

	return newObj
end

function TokenView:onValueChanged( key, oldValue, newValue )
	print(tostring(self) .. ": '" .. tostring(key) .. 
		"' changed from '" .. tostring(oldValue) .. 
		"' to '" .. tostring(newValue) .. "'")

	self:updateImg()
end

function TokenView:updateImg()
	if self.token.board == nil then
		return
	end

	if self.img then
		self.img:removeSelf();
	end

	local myimg = display.newImageRect(self.group,
					"res/" ..
					self.token.owner .. "_" ..
					(self.token.isHorizontal and "horizontal" or "vertical") .. "_" ..
					(self.token.isMaster and "master" or "normal") .. ".png",
					system.ResourceDirectory,
					cellWidth, cellHeight)

	myimg.x = cellWidth/2+(self.token.x-1)*cellWidth
	myimg.y = cellHeight/2+(self.token.y-1)*cellHeight

	self.img = myimg

	self.imgSelected.x = myimg.x
	self.imgSelected.y = myimg.y

	self.imgSelected.isVisible = self.token.isSelected
end

-- function TokenView:tap( event )
-- 	if self.img == nil then
-- 		return false
-- 	end

-- 	local localX, localY = self.img:contentToLocal(event.x, event.y)
-- 	localX = localX + self.img.width / 2
-- 	localY = localY + self.img.height / 2

-- 	if localX >= 0 and localX <= self.img.width and
-- 		localY >= 0 and localY <= self.img.height then

-- 		self.token.isSelected = not self.token.isSelected
-- 		return true 
-- 	end
-- end
--------------------------------------------------------------------
--- Token View
--------------------------------------------------------------------
local BoardView = {
	board = nil,
	group = nil
}

function BoardView:new(board, group)
	o = {}
	setmetatable( o, self )
	self.__index = self

	o.board = board
	o.group = group

	o:init()

	return o
end

function BoardView:init()
	local board = self.board

	for x = 0, board.width-1 do
		for y = 0, board.height-1 do
			local rect = display.newRect(self.group,
				cellWidth/2+x*cellWidth, cellHeight/2+y*cellHeight, 
				cellWidth, cellHeight)

			if (x+y) % 2 == 0 then
				rect.fill = {0.5}
			else
				rect.fill = {1, 1, 1}
			end
		end
	end
end
--------------------------------------------------------------------
-- local function drawBoard(board)
-- 	local boardGroup = display.newGroup( )

-- 	for x = 0, board.width-1 do
-- 		for y = 0, board.height-1 do
-- 			local rect = display.newRect(boardGroup,
-- 				cellWidth/2+x*cellWidth, cellHeight/2+y*cellHeight, 
-- 				cellWidth, cellHeight)

-- 			if (x+y) % 2 == 0 then
-- 				rect.fill = {0.5}
-- 			else
-- 				rect.fill = {1, 1, 1}
-- 			end
-- 		end
-- 	end

-- 	return boardGroup
-- end
--------------------------------------------------------------------

local GameController = require "GameController"

local board = Board:new()

-- Tokens
local tokensGroup = display.newGroup( )
local token = Token:new()
board:addToken(1, 1, token)
TokenView:new(token, tokensGroup)

token = Token:new()
token.owner = "red"
board:addToken(2, 1, token)
TokenView:new(token, tokensGroup)

token = Token:new()
token.owner = "blue"
token.isMaster = true
token.isHorizontal = false
board:addToken(3, 3, token)
TokenView:new(token, tokensGroup)

token = Token:new {
	owner = "red",
	isMaster = true,
	isHorizontal = false
}
board:addToken(6, 6, token)
TokenView:new(token, tokensGroup)

local boardGroup = display.newGroup( )
local boardView = BoardView:new(board, boardGroup)

GameController:new(boardView)

local mainGroup = display.newGroup( )
mainGroup.anchorChildren = true
mainGroup.anchorX = 0.5
mainGroup.anchorY = 0.5
mainGroup.x = display.contentWidth/2
mainGroup.y = display.contentHeight/2

mainGroup:insert( boardGroup )
mainGroup:insert( tokensGroup )

print(tokensGroup.numChildren)

timer.performWithDelay(2000, function()
	board:moveToken(token, 6, 1)
end)

timer.performWithDelay(3000, function()
	token.isMaster = false
	token.isHorizontal = true
end)