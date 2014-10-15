
-- Commands.lua

-- Implements the in-game command and console command handlers





function handleMoneyBalance(a_Split, a_Player)
	-- Handler for the "/money balance" in-game command
	-- Check params:
	if ((a_Split[2] ~= nil) and (a_Split[2] ~= "balance") and (a_Split[2] ~= "show")) then
		a_Player:SendMessage(cCompositeChat("Usage: ", mtFailure):AddRunCommandPart(a_Split[1], a_Split[1]))
		return true
	end
	
	-- Report the account balance:
	local balance = getBalanceByName(a_Player:GetName())
	if (AdvancedMessages) then
		if (balance < -1) then
			a_Player:SendMessage(AdvancedMessagesData["NegativePrefix"] .. balance .. AdvancedMessagesData["NegativePostfix"])
		elseif (balance == -1) then
			a_Player:SendMessage(AdvancedMessagesData["MinusOneCoin"])
		elseif (balance == 0) then
			a_Player:SendMessage(AdvancedMessagesData["ZeroCoins"])
		elseif (balance == 1) then
			a_Player:SendMessage(AdvancedMessagesData["OneCoin"])
		else
			if (balance < tonumber(AdvancedMessagesData["LowValue"])) then
				a_Player:SendMessage(AdvancedMessagesData["LowPrefix"] .. balance .. AdvancedMessagesData["LowPostfix"])
			elseif (balance < tonumber(AdvancedMessagesData["MediumValue"])) then
				a_Player:SendMessage(AdvancedMessagesData["MediumPrefix"] .. balance .. AdvancedMessagesData["MediumPostfix"])
			else
				a_Player:SendMessage(AdvancedMessagesData["HighPrefix"] .. balance .. AdvancedMessagesData["HighPostfix"])
			end
		end
	else
		a_Player:SendMessageInfo("Your balance is " .. balance);
	end
	return true
end





function handleMoneyGive(a_Split, a_Player)
	-- Handler for the "/money give <player> <amount> [<message>]" command
	-- Check params:
	if (a_Split[4] == nil) then  -- We need at least 4 parameters
		a_Player:SendMessage(cCompositeChat("Usage: ", mtFailure)
			:AddSuggestCommandPart(a_Split[1] .. " give", a_Split[1] .. " give")
			:AddTextPart("PlayerName Amount [Message]", "@2")
		)
		return true
	end
	
	-- Check the amount:
	local amount = tonumber(a_Split[4])
	if not(amount) then
		a_Player:SendMessageFailure("Not a valid number: " .. a_Split[4])
		return true
	end
	if (amount < 0) then
		a_Player:SendMessageFailure("Cannot give a negative amount.")
		return true
	end

	-- Give the money
	local playername = a_Player:GetName()
	local IsSuccess, ErrMsg = addMoneyByName(a_Split[3], amount, a_Split[5] or (playername .. " has given you money"))
	if not(IsSuccess) then
		ErrMsg = ErrMsg or "Cannot give money, unknown failure"
		if (a_Player ~= nil) then
			a_Player:SendMessageFailure(ErrMsg)
		else
			LOGWARNING(ErrMsg)
		end
		return true
	end
	
	-- Notify each player:
	if (a_Player ~= nil) then
		a_Player:SendMessage(FormatMessage("GivenTo", a_Split[3], amount))
	end
	cRoot:Get():FindAndDoWithPlayer(a_Split[3],
		function (a_CBPlayer)
			if (a_CBPlayer:GetName() == a_Split[3]) then
				a_CBPlayer:SendMessage(FormatMessage("Given", "", amount))
			end
		end
	)
	return true
end





--- Handler for the "/money remove <player> <amount> [<message>]" command
function handleMoneyRemove(a_Split, a_Player)
	-- Check params:
	if (a_Split[4] == nil) then  -- We need at least 4 parameters
		a_Player:SendMessage(cCompositeChat("Usage: ", mtFailure)
			:AddSuggestCommandPart(a_Split[1] .. " remove", a_Split[1] .. " remove")
			:AddTextPart("PlayerName Amount [Message]", "@2")
		)
		return true
	end
	
	-- Check the amount:
	local amount = tonumber(a_Split[4])
	if not(amount) then
		a_Player:SendMessageFailure("Not a valid number: " .. a_Split[4])
		return true
	end
	if (amount < 0) then
		a_Player:SendMessageFailure("Cannot remove a negative amount.")
		return true
	end


	-- Give the money
	local playername = a_Player:GetName()
	local IsSuccess, ErrMsg = removeMoneyByName(a_Split[3], amount, a_Split[5] or (playername .. " has removed your money"))
	if not(IsSuccess) then
		a_Player:SendMessageFailure(ErrMsg or "Cannot remove money, unknown failure")
		return true
	end
	
	-- Notify each player:
	a_Player:SendMessageInfo(FormatMessage("TakenFrom", a_Split[3], amount))
	cRoot:Get():FindAndDoWithPlayer(a_Split[3],
		function (a_CBPlayer)
			if (a_CBPlayer:GetName() == a_Split[3]) then
				a_CBPlayer:SendMessage(FormatMessage("Taken", "", amount))
			end
		end
	)
	return true
end




--- Handler for the "/money transfer <player> <amount> [<message>]" command
function handleMoneyTransfer(a_Split, a_Player)
	-- Check params:
	if (a_Split[4] == nil) then  -- We need at least 4 parameters
		a_Player:SendMessage(cCompositeChat("Usage: ", mtFailure)
			:AddSuggestCommandPart(a_Split[1] .. " transfer", a_Split[1] .. " transfer")
			:AddTextPart("PlayerName Amount [Message]", "@2")
		)
		return true
	end
	local srcPlayerName = a_Player:GetName();
	local dstPlayerName = a_Split[3]
	
	-- Check the amount:
	local amount = tonumber(a_Split[4])
	if not(amount) then
		a_Player:SendMessageFailure("Not a valid number: " .. a_Split[4])
		return true
	end
	if (amount < 0) then
		a_Player:SendMessageFailure("Cannot give a negative amount.")
		return true
	end

	-- Get the message
	local msg
	if (a_Split[5] == nil) then
		msg = srcPlayerName .. " has transfered money"
	else
		msg = table.concat(a_Split, " ", 5)
	end

	-- Transfer the money
	local IsSuccess, ErrMsg = transferMoneyByName(srcPlayerName, dstPlayerName, amount, msg)
	if not(IsSuccess) then
		a_Player:SendMessageFailure(ErrMsg or "Cannot transfer money, unknown failure");
		return true
	end
	
	-- Notify each player:
	if (a_Player ~= nil) then
		a_Player:SendMessage(FormatMessage("Transfer", dstPlayerName, amount))
	end
	cRoot:Get():FindAndDoWithPlayer(dstPlayerName,
		function (a_CBPlayer)
			if (a_CBPlayer:GetName() == dstPlayerName) then
				a_CBPlayer:SendMessage(FormatMessage("GivenFrom", srcPlayerName, amount))
			end
		end
	)
	return true
end




