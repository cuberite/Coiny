
-- API.lua

-- Implements the functions that are to be called from external plugins as API





-- Transfers money from one player account to another, adding the message to the transaction log
-- Returns true on success, false and message on failure
function TransferMoney(a_SrcPlayerName, a_DstPlayerName, a_Amount, a_Message)
	-- Make sure both players have their data initialized:
	InitPlayer(a_SrcPlayerName)
	InitPlayer(a_DstPlayerName)
	
	-- If src is frozen, handle as Give instead
	if (PlayersData[a_SrcPlayerName].freeze) then
		return GiveMoney(a_DstPlayerName, a_Amount)
	end
	
	-- If there's not enough money in the src account, return an error:
	if (PlayersData[a_SrcPlayerName].money < a_Amount) then
		return false, "Not enough money in the account"
	end
	
	-- Transfer the money:
	FunctionInternalCall = true  -- Skip the paranoid saving after Give
	GiveMoney  (a_DstPlayerName, a_Amount, a_Message)
	RemoveMoney(a_SrcPlayerName, a_Amount, a_Message)
	ExternalCallSaveCheck()
	return true
end





-- Gives the specified amount of money to the specified player, adding the message to the transaction log
-- Returns true if successful, false and error message if not
function GiveMoney(a_PlayerName, a_Amount, a_Message)
	InitPlayer(a_PlayerName)
	if (PlayersData[a_PlayerName].freeze) then
		return false, "Player has their account frozen"
	end
	PlayersData[a_PlayerName].money = PlayersData[a_PlayerName].money + a_Amount
	-- TODO: Save message into transaction log
	ExternalCallSaveCheck()
	return true
end





--- Removes the specified amount of money from the specified player, adding the message to the transaction log
-- Returns true if successful, false and error message if not
function RemoveMoney(a_PlayerName, a_Amount)
	InitPlayer(a_PlayerName)
	if (PlayersData[a_PlayerName].freeze) then
		return false, "Player has their account frozen"
	end
	PlayersData[a_PlayerName].money = PlayersData[a_PlayerName].money - a_Amount
	if (not(AllowNegativeBalance) and (PlayersData[a_PlayerName].money < 0)) then
		PlayersData[a_PlayerName].money = 0
	end
	ExternalCallSaveCheck()
	return true
end




--- Returns the amount of money in the specified player's account
-- Returns false and reason on failure
function GetMoney(a_PlayerName)
	InitPlayer(a_PlayerName)
	if not(PlayersData[a_PlayerName]) then
		return false, "No such player account"
	end
	return PlayersData[a_PlayerName].money
end




