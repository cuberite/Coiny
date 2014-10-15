
-- ConsoleCommands.lua

-- Implements the handlers for console commands





--- Handles the "money balance <playername>" console command
function handleConsoleMoneyBalance(a_Split)
	-- Check params:
	if ((a_Split[3] == nil) or (a_Split[4] ~= nil)) then
		return true, "Usage: 'money balance <PlayerName>'"
	end
	
	-- Get the player's balance:
	local balance, errMsg = getBalanceByName(a_Split[3])
	if not(balance) then
		return true, errMsg
	end
	
	-- Return the formatted balance report:
	return true, a_Split[3] .. " has " .. balance .. " coins"
end






--- Handles the "money give <player> <amount> [<message>]" console command
function handleConsoleMoneyGive(a_Split)
	-- Check params:
	if (a_Split[4] == nil) then  -- We need at least 4 parameters
		return true, "Usage: money give <PlayerName> <Amount> [<Message>]"
	end
	
	-- Check the amount:
	local amount = tonumber(a_Split[4])
	if not(amount) then
		return true, "Not a valid number: " .. a_Split[4]
	end
	if (amount < 0) then
		return true, "Cannot give a negative amount."
	end

	-- Get the message
	local msg
	if (a_Split[5] == nil) then
		msg = "admin has given you money"
	else
		msg = table.concat(a_Split, " ", 5)
	end

	-- Give the money
	local isSuccess, errMsg = addMoneyByName(a_Split[3], amount, msg, "console")
	if not(isSuccess) then
		return true, errMsg or "Cannot give money, unknown failure"
	end
	
	-- Notify each player:
	cRoot:Get():FindAndDoWithPlayer(a_Split[3],
		function (a_CBPlayer)
			if (a_CBPlayer:GetName() == a_Split[3]) then
				a_CBPlayer:SendMessage(FormatMessage("Given", "", amount))
			end
		end
	)
	
	-- Find the new balance:
	local balance
	balance, errMsg = getBalanceByName(a_Split[3])
	if not(isSuccess) then
		return true, "Money given, unable to query new balance"
	else
		return true, "Money given, current balance is " .. balance
	end
end





--- Handles the "money remove <player> <amount> [<message>]" console command
function handleConsoleMoneyRemove(a_Split)
	-- Check params:
	if (a_Split[4] == nil) then  -- We need at least 4 parameters
		return true, "Usage: money remove <PlayerName> <Amount> [<Message>]"
	end
	
	-- Check the amount:
	local amount = tonumber(a_Split[4])
	if not(amount) then
		return true, "Not a valid number: " .. a_Split[4]
	end
	if (amount < 0) then
		return true, "Cannot remove a negative amount."
	end

	-- Get the message
	local msg
	if (a_Split[5] == nil) then
		msg = "admin has removed your money"
	else
		msg = table.concat(a_Split, " ", 5)
	end

	-- Remove the money
	local isSuccess, errMsg = removeMoneyByName(a_Split[3], amount, msg, "console")
	if not(isSuccess) then
		return true, errMsg or "Cannot remove money, unknown failure"
	end
	
	-- Notify each player:
	cRoot:Get():FindAndDoWithPlayer(a_Split[3],
		function (a_CBPlayer)
			if (a_CBPlayer:GetName() == a_Split[3]) then
				a_CBPlayer:SendMessage(FormatMessage("Taken", "", amount))
			end
		end
	)

	-- Find the new balance:
	local balance
	balance, errMsg = getBalanceByName(a_Split[3])
	if not(isSuccess) then
		return true, "Money removed, unable to query new balance"
	else
		return true, "Money removed, current balance is " .. balance
	end
end





--- Handles the "money transfer <SrcPlayerName> <DstPlayerName> <Amount> [<Message>]" console command
function handleConsoleMoneyTransfer(a_Split)
	-- Check params:
	if (a_Split[5] == nil) then  -- We need at least 5 parameters
		return true, "Usage: money transfer <SrcPlayerName> <DstPlayerName> <Amount> [<Message>]"
	end
	
	-- Check the amount:
	local amount = tonumber(a_Split[5])
	if not(amount) then
		return true, "Not a valid number: " .. a_Split[5]
	end
	if (amount < 0) then
		return true, "Cannot remove a negative amount."
	end

	-- Get the message
	local msg
	if (a_Split[6] == nil) then
		msg = "admin has transfered money"
	else
		msg = table.concat(a_Split, " ", 6)
	end

	-- Give the money
	local IsSuccess, ErrMsg = transferMoneyByName(a_Split[3], a_Split[4], amount, msg, "console")
	if not(IsSuccess) then
		return true, ErrMsg or "Cannot transfer money, unknown failure"
	end
	
	-- Notify each player:
	cRoot:Get():FindAndDoWithPlayer(a_Split[3],
		function (a_CBPlayer)
			if (a_CBPlayer:GetName() == a_Split[3]) then
				a_CBPlayer:SendMessage(FormatMessage("Transfer", "", amount))
			end
		end
	)
	cRoot:Get():FindAndDoWithPlayer(a_Split[4],
		function (a_CBPlayer)
			if (a_CBPlayer:GetName() == a_Split[4]) then
				a_CBPlayer:SendMessage(FormatMessage("GivenFrom", "", amount))
			end
		end
	)
	return true, "Money transferred"
end




