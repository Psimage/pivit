--------------------------------------------------------------------
-- Main
--------------------------------------------------------------------
local GameController = require "GameController"
local Board = require "Board"
local BoardView = require "BoardView"
local Token = require "Token"
local TokenView = require "TokenView"

ENV = {
	dev = true
}

boardSize = 6
cellWidth = display.contentWidth/boardSize
cellHeight = display.contentWidth/boardSize

local function setup6x6x2()
	local boardSize = 6
	cellWidth = display.contentWidth/boardSize
	cellHeight = display.contentWidth/boardSize
	
	local board = Board:new(6)

	-- TOP
	token = Token:new()
	token.owner = "red"
	token.isHorizontal = false
	board:addToken(2, 1, token)

	token = Token:new()
	token.owner = "blue"
	token.isHorizontal = false
	board:addToken(3, 1, token)

	token = Token:new()
	token.owner = "red"
	token.isHorizontal = false
	board:addToken(4, 1, token)

	token = Token:new()
	token.owner = "blue"
	token.isHorizontal = false
	board:addToken(5, 1, token)

	-- RIGHT
	token = Token:new()
	token.owner = "blue"
	board:addToken(6, 2, token)

	token = Token:new()
	token.owner = "red"
	board:addToken(6, 3, token)

	token = Token:new()
	token.owner = "blue"
	board:addToken(6, 4, token)

	token = Token:new()
	token.owner = "red"
	board:addToken(6, 5, token)

	-- BOTTOM
	token = Token:new()
	token.owner = "red"
	token.isHorizontal = false
	board:addToken(2, 6, token)

	token = Token:new()
	token.owner = "blue"
	token.isHorizontal = false
	board:addToken(3, 6, token)

	token = Token:new()
	token.owner = "red"
	token.isHorizontal = false
	board:addToken(4, 6, token)

	token = Token:new()
	token.owner = "blue"
	token.isHorizontal = false
	board:addToken(5, 6, token)

	-- LEFT
	token = Token:new()
	token.owner = "blue"
	board:addToken(1, 2, token)

	token = Token:new()
	token.owner = "red"
	board:addToken(1, 3, token)

	token = Token:new()
	token.owner = "blue"
	board:addToken(1, 4, token)

	token = Token:new()
	token.owner = "red"
	board:addToken(1, 5, token)

	return board
end

local board = nil

if ENV.dev then
	board = Board:new(boardSize)
	local token = Token:new()
	token.isMaster = true
	board:addToken(1, 1, token)

	token = Token:new()
	token.isMaster = true
	token.owner = "red"
	board:addToken(2, 1, token)

	token = Token:new()
	token.owner = "blue"
	token.isMaster = true
	token.isHorizontal = false
	board:addToken(3, 3, token)

	token = Token:new {
		owner = "red",
		isMaster = false,
		isHorizontal = false
	}
	board:addToken(6, 1, token)
else
	board = setup6x6x2()
end

local boardView = BoardView:new(board)
local boardGroup = boardView.group

local tokensGroup = display.newGroup( )
for _, token in ipairs(board:getAllTokens()) do
	TokenView:new(token, tokensGroup)
end

GameController:new(boardView)

local mainGroup = display.newGroup( )
mainGroup.anchorChildren = true
mainGroup.anchorX = 0.5
mainGroup.anchorY = 0.5
mainGroup.x = display.contentWidth/2
mainGroup.y = display.contentHeight/2

mainGroup:insert( boardGroup )
mainGroup:insert( tokensGroup )