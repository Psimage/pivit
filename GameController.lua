local math = require "math"
local RuleBook = require "RuleBook"
local TurnPanel = require "TurnPanel"

local GameController = {
	boardView = nil,
	selectedToken = nil,
	gameState = nil,
	turnPanel = nil
}

function GameController:new(boardView)
	local newObj = {}
	setmetatable( newObj, self )
	self.__index = self

	newObj.boardView = boardView

	local RedPlayer = {
		owner = "red",
		firstMasterPromotionPlace = 322,
		color = {1, 0, 0, 1}
	}

	local BluePlayer = {
		owner = "blue",
		firstMasterPromotionPlace = 322,
		color = {0, 0, 1, 1}
	}

	RedPlayer.nextPlayer = BluePlayer
	BluePlayer.nextPlayer = RedPlayer

	newObj.gameState = {
		playersList = {["red"] = RedPlayer, ["blue"] = BluePlayer},
		currentPlayer = RedPlayer,
		board = newObj.boardView.board,
		promotionPlace = 1, -- To resolve tiebreaker
		state = "playing"
	}

	newObj.turnPanel = TurnPanel:new(newObj.gameState)
	newObj.turnPanel:select(newObj.gameState.currentPlayer)

	Runtime:addEventListener( "tap", newObj )

	return self
end

function GameController:tap( event )
	local localX, localY = self.boardView.group:contentToLocal(event.x, event.y)

	cellX = math.floor(localX/cellWidth) + 1
	cellY = math.floor(localY/cellHeight) + 1

	local board = self.boardView.board

	if self.gameState.state == "playing" then
		if cellX >= 1 and cellX <= board.width and
			cellY >= 1 and cellY <= board.height then

			if self.selectedToken ~= nil then
				if RuleBook.isValidMove(self.gameState, self.selectedToken, cellX, cellY) then
					RuleBook.performMove(self.gameState, self.selectedToken, cellX, cellY)
					
					self:deselect()

					if RuleBook.isGameOver(self.gameState) then
						print("Game Over")
						self.gameState.state = "gameover"
						RuleBook.getWinner(self.gameState)
					else
						self:nextPlayer()
					end

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
	elseif self.gameState.state == "gameover" then
		-- Do nothing
	end
end

function GameController:nextPlayer()
	self.gameState.currentPlayer = self.gameState.currentPlayer.nextPlayer
	self.turnPanel:select(self.gameState.currentPlayer)
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