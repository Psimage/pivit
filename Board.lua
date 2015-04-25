--------------------------------------------------------------------
--- Board
--------------------------------------------------------------------
local Board = {}

function Board:new(size)
	local newObj = {
		width = size,
		height = size,
		map = {}
	}

	for i = newObj.height, 1, -1 do
		newObj.map[i] = {}
	end

	self.__index = self
	return setmetatable( newObj, self )
end

function Board:addToken( x, y, token)
	self.map[x][y] = token
	token.board = self
	token.x = x
	token.y = y
end

function Board:getToken( x, y )
	return self.map[x][y]
end

function Board:moveToken(token, x, y )
	local toToken = self.map[x][y]
	if toToken ~= nil then
		toToken.board = nil
	end
	self.map[token.x][token.y] = nil;
	self.map[x][y] = token
	token.x = x
	token.y = y
end

function Board:getAllTokens()
	local tokensList = {}

	for x=1, self.width, 1 do
		for y=1, self.height, 1 do
			local token = self:getToken(x, y)
			if token ~= nil then
				table.insert( tokensList, token )
			end
		end
	end

	return tokensList
end

return Board