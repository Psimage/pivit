local math = require "math"

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
			token.isSelected = not token.isSelected
		end

		return true 
	end
end

return GameController