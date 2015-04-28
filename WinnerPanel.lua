local WinnerPanel = {
	panelGroup = nil,
	label = nil
}

function WinnerPanel:new()
	o = {}
	setmetatable( o, self )
	self.__index = self

	o.panelGroup = display.newGroup()
	o.panelGroup.anchorChildren = true
	o.panelGroup.anchorX = 0.5
	o.panelGroup.anchorY = 1
	o.panelGroup.x = display.contentWidth/2
	o.panelGroup.y = display.contentHeight - 5

	o.label = display.newEmbossedText( {
		parent = o.panelGroup,
		text = "Nothing",
		font = native.systemFontBold,
		fontSize = 25,
		align = "center"
	} )

	o.label.isVisible = false

	return o
end

function WinnerPanel:show(player)
	self.label:setText("The winner is: " .. player.owner:upper())
	self.label:setFillColor( player.color[1], player.color[2], player.color[3])
	self.label.isVisible = true
end

function WinnerPanel:hide()
	self.label.isVisible = false
end

return WinnerPanel