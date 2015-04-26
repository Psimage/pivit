local RuleBook = {}

local function addIfValid(board, token, x, y, listOfMoves)
	local foundToken = board:getToken(x, y)
	if foundToken ~= nil then
		if foundToken.owner ~= token.owner then
			if not token.isMaster then
				if (x+y+token.x+token.y)%2 ~= 0 then
					table.insert(listOfMoves, {x=x, y=y})
				end
			else
				table.insert(listOfMoves, {x=x, y=y})
			end
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

function RuleBook.isValidMove(gameState, token, toX, toY)
	local listOfValidMoves = RuleBook.listValidMoves(gameState.board, token)

	for _, pos in ipairs(listOfValidMoves) do
		if pos.x == toX and pos.y == toY then
			return true
		end
	end

	return false
end

function RuleBook.performMove(gameState, token, toX, toY)
	-- TODO: Validate move?

	local board = gameState.board

	board:moveToken(token, toX, toY)
	token.isHorizontal = not token.isHorizontal
	if (toX == 1 and toY == 1) or
		(toX == 1 and toY == board.height) or
		(toX == board.width and toY == 1) or
		(toX == board.width and toY == board.height) then
		token.isMaster = true
		if gameState.currentPlayer.firstMasterPromotionPlace == 322 then
			gameState.currentPlayer.firstMasterPromotionPlace = gameState.promotionPlace
			gameState.promotionPlace = gameState.promotionPlace + 1
		end
	end

	local gameOver = RuleBook.isGameOver(gameState)

	if gameOver then
		print("Game Over")
		RuleBook.getWinner(gameState)
	else
		gameState.currentPlayer = gameState.currentPlayer.nextPlayer
	end
end

local function isOnePlayerLeft(gameState)
	local onePlayerLeft = true

	local tokensList = gameState.board:getAllTokens()
	for _, t in ipairs(tokensList) do
		if t.owner ~= gameState.currentPlayer.owner then
			onePlayerLeft = false
			break
		end
	end

	return onePlayerLeft
end

function RuleBook.isGameOver(gameState)
	-- Check winning conditions
	local tokensList = gameState.board:getAllTokens()
	local minionsOnBoard = false
	for _, t in ipairs(tokensList) do
		if not t.isMaster then
			minionsOnBoard = true
			break
		end
	end

	local onePlayerOnBoard = isOnePlayerLeft(gameState)

	local isGameOver = minionsOnBoard == false or onePlayerOnBoard
	return isGameOver
end

function RuleBook.getWinner(gameState)
	local winner = nil

	-- Determine the winner
	if isOnePlayerLeft(gameState) then
		print("The winner is (the only one left): " .. gameState.currentPlayer.owner)
		winner = gameState.currentPlayer.owner
	else
		local mastersCountByOwner = {}
		for _, t in ipairs(gameState.board:getAllTokens()) do
			mastersCountByOwner[t.owner] = (mastersCountByOwner[t.owner] == nil) and 1 or (mastersCountByOwner[t.owner]+1)
		end

		local sortedMastersCount = {}
		for owner, count in pairs(mastersCountByOwner) do
			table.insert(sortedMastersCount, {["owner"] = owner, ["count"] = count})
		end
		table.sort( sortedMastersCount, function (a, b) return a.count > b.count end )


		if sortedMastersCount[1].count == sortedMastersCount[2].count then
			print("Tiebreaker!")
			
			local maxCount = sortedMastersCount[1].count
			winner = sortedMastersCount[1].owner
			for i=2, #sortedMastersCount, 1 do
				if sortedMastersCount[i].count == maxCount then
					local player = gameState.playersList[sortedMastersCount[i].owner]
					if player.firstMasterPromotionPlace < gameState.playersList[winner].firstMasterPromotionPlace then
						winner = player.owner
					end
				else
					break
				end
			end

			print("The winner is (via promotion place): " .. winner)
		else
			winner = sortedMastersCount[1].owner
			print("The winner is (by num of masters " .. sortedMastersCount[1].count .. "): " .. winner)
		end
	end

	return winner
end

return RuleBook