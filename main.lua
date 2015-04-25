

--------------------------------------------------------------------
-- Main
--------------------------------------------------------------------

boardSize = 6
cellWidth = display.contentWidth/boardSize
cellHeight = display.contentWidth/boardSize

local GameController = require "GameController"
local Board = require "Board"
local BoardView = require "BoardView"
local Token = require "Token"
local TokenView = require "TokenView"

local board = Board:new(boardSize)

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