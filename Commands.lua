
-- Commands.lua

-- Implements the in-game command and console command handlers





function HandleMoneyBalance(a_Split, a_Player)
	-- Handler for the "/money balance" in-game command
	-- Check params:
	if ((a_Split[2] ~= nil) and (a_Split[2] ~= "balance") and (a_Split[2] ~= "show")) then
		a_Player:SendMessage(cCompositeChat("Usage: ", mtFailure):AddRunCommandPart(a_Split[1], a_Split[1]))
		return true
	end
	
	-- Initialize the player's storage:
	local playername = a_Player:GetName()
	InitPlayer(playername)

	-- Report the account balance:
	local playerMoney = tonumber(PlayersData[playername].money)
	if (AdvancedMessages) then
		if (playerMoney < -1) then
			a_Player:SendMessage(AdvancedMessagesData["NegativePrefix"] .. playerMoney .. AdvancedMessagesData["NegativePostfix"])
		elseif (playerMoney == -1) then
			a_Player:SendMessage(AdvancedMessagesData["MinusOneCoin"])
		elseif (playerMoney == 0) then
			a_Player:SendMessage(AdvancedMessagesData["ZeroCoins"])
		elseif (playerMoney == 1) then
			a_Player:SendMessage(AdvancedMessagesData["OneCoin"])
		else
			if (playerMoney < tonumber(AdvancedMessagesData["LowValue"])) then
				a_Player:SendMessage(AdvancedMessagesData["LowPrefix"] .. playerMoney .. AdvancedMessagesData["LowPostfix"])
			elseif (playerMoney < tonumber(AdvancedMessagesData["MediumValue"])) then
				a_Player:SendMessage(AdvancedMessagesData["MediumPrefix"] .. playerMoney .. AdvancedMessagesData["MediumPostfix"])
			else
				a_Player:SendMessage(AdvancedMessagesData["HighPrefix"] .. playerMoney .. AdvancedMessagesData["HighPostfix"])
			end
		end
	else
		if (playerMoney == -1) then
			a_Player:SendMessage("Your pocket is -1 coin heavy")
		elseif (playerMoney == 0) then
			a_Player:SendMessage("You don't have any coins")
		elseif (playerMoney == 1) then
			a_Player:SendMessage("Your pocket is 1 coin heavy")
		else
			a_Player:SendMessage("Your pocket is " .. playerMoney .. " coins heavy")
		end
	end
	return true
end





function HandleMoneyGive(a_Split, a_Player)
	-- Handler for the "/money give <player> <amount> [<message>]" command
	-- Also handles the "money give <player> <amount> [<message>]" console command
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

	-- Get the giving player's name, if not from server console:
	local playername = "console"
	if (a_Player ~= nil) then
		playername = a_Player:GetName()
	end

	-- Give the money
	local IsSuccess, ErrMsg = GiveMoney(a_Split[3], amount, a_Split[5] or (playername .. " has given you money"))
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





function HandleMoneyRemove(a_Split, a_Player)
	-- Handler for the "/money remove <player> <amount> [<message>]" command
	-- Also handles the "money remove <player> <amount> [<message>]" console command
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

	-- Get the giving player's name, if not from server console:
	local playername = "console"
	if (a_Player ~= nil) then
		playername = a_Player:GetName()
	end

	-- Give the money
	local IsSuccess, ErrMsg = RemoveMoney(a_Split[3], amount, a_Split[5] or (playername .. " has removed your money"))
	if not(IsSuccess) then
		ErrMsg = ErrMsg or "Cannot remove money, unknown failure"
		if (a_Player ~= nil) then
			a_Player:SendMessageFailure(ErrMsg)
		else
			LOGWARNING(ErrMsg)
		end
		return true
	end
	
	-- Notify each player:
	if (a_Player ~= nil) then
		a_Player:SendMessage(FormatMessage("TakenFrom", a_Split[3], amount))
	end
	cRoot:Get():FindAndDoWithPlayer(a_Split[3],
		function (a_CBPlayer)
			if (a_CBPlayer:GetName() == a_Split[3]) then
				a_CBPlayer:SendMessage(FormatMessage("Taken", "", amount))
			end
		end
	)
	return true
end




function HandleMoneyTransfer(a_Split, a_Player)
	-- Handler for the "/money transfer <player> <amount> [<message>]" command
	-- Check params:
	if (a_Split[4] == nil) then  -- We need at least 4 parameters
		a_Player:SendMessage(cCompositeChat("Usage: ", mtFailure)
			:AddSuggestCommandPart(a_Split[1] .. " transfer", a_Split[1] .. " transfer")
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

	-- Transfer the money
	local srcPlayerName = a_Player:GetName();
	local dstPlayerName = a_Split[3]
	local IsSuccess, ErrMsg = TransferMoney(srcPlayerName, dstPlayerName, amount, a_Split[5] or (srcPlayerName .. " has transferred money to you"))
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




