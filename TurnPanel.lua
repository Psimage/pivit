local TurnPanel = {
	panelGroup = nil,
	sectionsList = nil,
	selectedSection = nil
}

function TurnPanel:new(gameState)
	o = {}
	setmetatable( o, self )
	self.__index = self

	o.panelGroup = display.newGroup()
	o.panelGroup.anchorChildren = true
	o.panelGroup.anchorX = 0.5
	o.panelGroup.anchorY = 0
	o.panelGroup.x = display.contentWidth/2
	o.panelGroup.y = 10

	o.sectionsList = {}

	local numOfPlayers = 0
	for _, _ in pairs(gameState.playersList) do
		numOfPlayers = numOfPlayers + 1
	end

	local indent = 3
	local sectionWidth = display.contentWidth / numOfPlayers - (numOfPlayers+1)*indent
	local sectionHeight = sectionWidth / 3

	local offsetX = 0
	for owner, player in pairs(gameState.playersList) do
		local section = display.newRect( o.panelGroup, offsetX, 50, sectionWidth, sectionHeight )
		offsetX = offsetX + sectionWidth + indent
		section.fill = player.color
		section.strokeWidth = 3
		section:setStrokeColor( 0, 1 )
		o.sectionsList[owner] = section
	end
	return o
end

function TurnPanel:select(player)
	if self.selectedSection ~= nil then
		self.selectedSection:setStrokeColor( 0, 0 )
	end
	self.selectedSection = self.sectionsList[player.owner]
	self.selectedSection:setStrokeColor( 255/193, 187/255, 51/255 )
end

return TurnPanel