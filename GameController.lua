local math = require "math"
local RuleBook = require "RuleBook"

local GameController = {
	boardView = nil,
	selectedToken = nil
}

function GameController:new(boardView)
	local newObj = {}
	setmetatable( newObj, self )
	self.__index = self

	newObj.boardView = boardView

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

		local token = board:getToken(cellX, cellY)
		if token then			
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