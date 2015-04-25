--------------------------------------------------------------------
--- Token
--------------------------------------------------------------------
local Token = {	
	x = 0,
	y = 0,

	owner = "blue",
	isHorizontal = true,
	isMaster = false,
	isSelected = false,
	board = nil,

	observers = nil
}

function Token:new(o)
	local newObj = o or {}
	setmetatable( newObj, self )
	self.__index = self

	newObj.observers = {}

	local proxy = {}
	setmetatable( proxy, {
		__index = function (t,k)
		    return newObj[k]
		end,

		__newindex = function ( t, k, v )
			local oldValue = newObj[k]
			newObj[k] = v
			newObj:onValueChanged(k, oldValue, v)
		end
	} )

	return proxy
end

function Token:onValueChanged( key, oldValue, newValue )
	for _, observer in ipairs(self.observers) do
		observer:onValueChanged(key, oldValue, newValue)
	end
end

function Token:registerObserver(observer)
	table.insert( self.observers, observer )
end

function Token:move(x, y)
	board:moveToken(self, x, y)
end

return Token