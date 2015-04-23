local RuleBook = {}

function RuleBook.listValidMoves(board, token)
	local listOfMoves = {}

	-- To the left of the token
	if token.x > 1 then
		local y = token.y
		local step = token.isMaster and -1 or -2
		for x=token.x-1, 1, step do
			local hasToken = board:getToken(x, y) ~= nil
			if hasToken then break end

			table.insert(listOfMoves, {x=x, y=y})
		end
	end

	-- To the right of the token
	if token.x < board.width then
		local y = token.y
		local step = token.isMaster and 1 or 2
		for x=token.x+1, board.width, step do
			local hasToken = board:getToken(x, y) ~= nil
			if hasToken then break end

			table.insert(listOfMoves, {x=x, y=y})
		end
	end

	-- To the top of the token
	if token.y > 1 then
		local x = token.x
		local step = token.isMaster and -1 or -2
		for y=token.y-1, 1, step do
			local hasToken = board:getToken(x, y) ~= nil
			if hasToken then break end

			table.insert(listOfMoves, {x=x, y=y})
		end
	end

	-- To the bottom of the token
	if token.y < board.height then
		local x = token.x
		local step = token.isMaster and 1 or 2
		for y=token.y+1, board.height, step do
			local hasToken = board:getToken(x, y) ~= nil
			if hasToken then break end

			table.insert(listOfMoves, {x=x, y=y})
		end
	end

	return listOfMoves
end

return RuleBook