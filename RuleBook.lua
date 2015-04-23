local RuleBook = {}

local function addIfValid(board, token, x, y, listOfMoves)
	local foundToken = board:getToken(x, y)
	if foundToken ~= nil then
		if foundToken.owner ~= token.owner then
			table.insert(listOfMoves, {x=x, y=y})
		end
		return true
	end

	if not token.isMaster then
		if (x+y+token.x+token.y)%2 ~= 0 then
			table.insert(listOfMoves, {x=x, y=y})
		end
	else
		table.insert(listOfMoves, {x=x, y=y})
	end

	return false
end

function RuleBook.listValidMoves(board, token)
	local listOfMoves = {}

	if token.isHorizontal then
		-- To the left of the token
		if token.x > 1 then
			local y = token.y
			for x=token.x-1, 1, -1 do
				if addIfValid(board, token, x, y, listOfMoves) then break end
			end
		end

		-- To the right of the token
		if token.x < board.width then
			local y = token.y
			for x=token.x+1, board.width, 1 do
				if addIfValid(board, token, x, y, listOfMoves) then break end
			end
		end
	else
		-- To the top of the token
		if token.y > 1 then
			local x = token.x
			for y=token.y-1, 1, -1 do
				if addIfValid(board, token, x, y, listOfMoves) then break end
			end
		end

		-- To the bottom of the token
		if token.y < board.height then
			local x = token.x
			for y=token.y+1, board.height, 1 do
				if addIfValid(board, token, x, y, listOfMoves) then break end
			end
		end
	end
	return listOfMoves
end

return RuleBook