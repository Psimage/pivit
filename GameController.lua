local math = require "math"
local RuleBook = require "RuleBook"

local GameController = {
	boardView = nil,
	selectedToken = nil,
	gameState = nil
}

function GameController:new(boardView)
	local newObj = {}
	setmetatable( newObj, self )
	self.__index = self

	newObj.boardView = boardView

	local RedPlayer = {
		owner = "red",
		firstMasterPromotionPlace = 322
	}

	local BluePlayer = {
		owner = "blue",
		firstMasterPromotionPlace = 322
	}

	RedPlayer.nextPlayer = BluePlayer
	BluePlayer.nextPlayer = RedPlayer

	newObj.gameState = {
		playersList = {["red"] = RedPlayer, ["blue"] = BluePlayer},
		currentPlayer = RedPlayer,
		board = newObj.boardView.board,
		promotionPlace = 1 -- To resolve tiebreaker
	}

	Runtime:addEventListener( "tap", newObj )

	return self
end

function GameController:tap( event )
	local localX, localY = self.boardView.group:contentToLocal(event.x, event.y)

	cellX = math.floor(localX/cellWidth) + 1
	cellY = math.floor(localY/cellHeight) + 1

	local board = self.boardView.board

	if cellX >= 1 and cellX <= board.width and
		cellY >= 1 and cellY <= board.height then

		if self.selectedToken ~= nil then
			if RuleBook.isValidMove(self.gameState, self.selectedToken, cellX, cellY) then
				RuleBook.performMove(self.gameState, self.selectedToken, cellX, cellY)
				self:deselect()
				return true
			end
		end

		local token = board:getToken(cellX, cellY)
		if token and token.owner == self.gameState.currentPlayer.owner then
			if token ~= self.selectedToken then
				self:deselect()
				self:selectToken(token)
			else
				self:deselect()
			end
		end

		return true 
	end
end

function GameController:selectToken(token)
	self.selectedToken = token

	token.isSelected = true
	
	local listOfMoves = RuleBook.listValidMoves(self.boardView.board, token)
	for _, pos in ipairs(listOfMoves) do
		self.boardView:setHighlight(pos.x, pos.y, true)
	end
end

function GameController:deselect()
	if self.selectedToken == nil then return end

	self.selectedToken.isSelected = false
	self.selectedToken = nil

	self.boardView:hideAllHighlights()
end

return GameController