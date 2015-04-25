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
	local toToken = self.map[x][y]
	if toToken ~= nil then
		toToken.board = nil
	end
	self.map[token.x][token.y] = nil;
	self.map[x][y] = token
	token.x = x
	token.y = y
end

function Board:getAllTokens()
	local tokensList = {}

	for x=1, self.width, 1 do
		for y=1, self.height, 1 do
			local token = self:getToken(x, y)
			if token ~= nil then
				table.insert( tokensList, token )
			end
		end
	end

	return tokensList
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
		if self.img ~= nil then
			self.img:removeSelf()
		end
		return
	end

	if self.img then
		self.img:removeSelf()
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

--------------------------------------------------------------------
--- Token View
--------------------------------------------------------------------
local BoardView = {
	board = nil,
	highlightsArray = {},
	group = nil
}

function BoardView:new(board, group)
	o = {}
	setmetatable( o, self )
	self.__index = self

	o.board = board
	o.group = display.newGroup()

	o:init()

	return o
end

function BoardView:init()
	local board = self.board

	local boardLayer = display.newGroup()
	self.group:insert(boardLayer)

	local highlightLayer = display.newGroup()
	self.group:insert(highlightLayer)

	for y = 0, board.width-1 do
		for x = 0, board.height-1 do
			local posX = cellWidth/2+x*cellWidth
			local posY = cellHeight/2+y*cellHeight

			local rect = display.newRect(boardLayer,
				posX, posY, 
				cellWidth, cellHeight)

			if (x+y) % 2 == 0 then
				rect.fill = {0.5}
			else
				rect.fill = {1, 1, 1}
			end

			local highlight = display.newRoundedRect(highlightLayer, 
				posX, posY, 
				cellWidth-3, cellHeight-3, 3)
			highlight.fill = {0.1, 0.9, 0.9, 0.3}
			highlight.stroke = {255/255, 25/255, 0/255, 0.3}
			highlight.strokeWidth = 3
			highlight.isVisible = false
			table.insert(self.highlightsArray, highlight)
		end
	end
end

function BoardView:setHighlight(x, y, value)
	self.highlightsArray[(y-1)*self.board.width+x].isVisible = value
end

function BoardView:hideAllHighlights()
	for x=1, self.board.width, 1 do
		for y=1, self.board.height, 1 do
			self:setHighlight(x, y, false)
		end
	end
end
--------------------------------------------------------------------
-- Main
--------------------------------------------------------------------

local GameController = require "GameController"

local board = Board:new()

-- Tokens
local tokensGroup = display.newGroup( )
local token = Token:new()
token.isMaster = true
board:addToken(1, 1, token)
TokenView:new(token, tokensGroup)

token = Token:new()
token.isMaster = true
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
	isMaster = false,
	isHorizontal = false
}
board:addToken(6, 1, token)
TokenView:new(token, tokensGroup)

local boardView = BoardView:new(board)
local boardGroup = boardView.group

GameController:new(boardView)

local mainGroup = display.newGroup( )
mainGroup.anchorChildren = true
mainGroup.anchorX = 0.5
mainGroup.anchorY = 0.5
mainGroup.x = display.contentWidth/2
mainGroup.y = display.contentHeight/2

mainGroup:insert( boardGroup )
mainGroup:insert( tokensGroup )

-- timer.performWithDelay(2000, function()
-- 	board:moveToken(token, 6, 1)
-- end)

-- timer.performWithDelay(3000, function()
-- 	token.isMaster = false
-- 	token.isHorizontal = true
-- end)