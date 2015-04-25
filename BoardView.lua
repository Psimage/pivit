--------------------------------------------------------------------
--- Board View
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

return BoardView