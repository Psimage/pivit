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

return TokenView