
-- Storage.lua

-- Implements the storage for the player data and the functions for accessing it





-- The storage instance that provides the access and context to all the functions
g_Storage = {}






--- Adds the specified amount to the specified account, with the specified message.
-- Returns true on success, nil and error message on failure
function g_Storage:addMoney(a_AccountUuid, a_Amount, a_Message, a_Channel, a_ChannelData)
	-- Check the params:
	assert(type(a_AccountUuid) == "string")
	assert(type(a_Amount) == "number")
	assert(type(a_Message or "") == "string")
	assert(type(a_Channel or "") == "string")
	assert(type(a_ChannelData or "") == "string")
	
	-- Add the transaction to log:
	return self.DB:executeStatement(
		"INSERT INTO Transactions (Account, ContraAccount, Amount, Message, DateTime, Channel, ChannelData) VALUES (?, \"\", ?, ?, ?, ?, ?)",
		{ a_AccountUuid, a_Amount, a_Message or "", os.time(), a_Channel or "", a_ChannelData or "" }
	)
end





--- Returns the current balance of the specified account
-- Returns nil and error message on failure
function g_Storage:getBalance(a_AccountUuid)
	-- Check the params:
	assert(type(a_AccountUuid) == "string")

	-- Add all the incoming and outgoing transactions together to get the balance:
	local balance = 0
	local isSuccess, errMsg = self.DB:executeStatement(
		"SELECT SUM(Amount) AS s FROM Transactions WHERE Account = ?",
		{ a_AccountUuid },
		function (a_Values)
			-- If the query condition returns zero rows, then no value is returned in the resulting table
			balance = a_Values["s"] or 0
		end
	)
	if not(isSuccess) then
		return nil, errMsg
	end

	-- Successfully queried the balance, return it:
	return balance
end





--- Removes the specified amount to the specified account, with the specified message and channel.
-- Returns true on success, nil and error message on failure
function g_Storage:removeMoney(a_AccountUuid, a_Amount, a_Message, a_Channel, a_ChannelData)
	-- Check the params:
	assert(type(a_AccountUuid) == "string")
	assert(type(a_Amount) == "number")
	assert(type(a_Message or "") == "string")
	assert(type(a_Channel or "") == "string")
	assert(type(a_ChannelData or "") == "string")
	
	-- Add the transaction to log:
	return self.DB:executeStatement(
		"INSERT INTO Transactions (Account, ContraAccount, Amount, Message, DateTime, Channel, ChannelData) VALUES (?, \"\", ?, ?, ?, ?, ?)",
		{ a_AccountUuid, -a_Amount, a_Message, os.time(), a_Channel or "", a_ChannelData or "" }
	)
end





--- Transfers the money from src account to dst account, with the specified message and channel.
-- Returns true and the src account final balance on success, nil and error msg on failure
function g_Storage:transferMoney(a_SrcAccount, a_DstAccount, a_Amount, a_Message, a_Channel, a_ChannelData)
	-- Check the params:
	assert(type(a_SrcAccount) == "string")
	assert(type(a_DstAccount) == "string")
	assert(type(a_Amount) == "number")
	assert(type(a_Message or "") == "string")
	assert(type(a_Channel or "") == "string")
	assert(type(a_ChannelData or "") == "string")
	
	
	return self.DB:transaction(
		function()
			-- Get the balance of the src account:
			local srcBalance
			local isSuccess, errMsg = self.DB:executeStatement(
				"SELECT SUM(Amount) AS s FROM Transactions WHERE Account = ?",
				{ a_SrcAccount },
				function (a_Values)
					-- If the query condition returns zero rows, then no value is returned in the resulting table
					srcBalance = a_Values["s"] or 0
				end
			)
			if not(isSuccess) then
				return nil, errMsg
			end
			
			-- Check the balance, is there enough money?
			if (srcBalance < a_Amount) then
				return nil, "Not enough money"
			end
			
			-- Add the outgoing transaction:
			isSuccess, errMsg = self.DB:executeStatement(
				"INSERT INTO Transactions (Account, ContraAccount, Amount, Message, DateTime, Channel, ChannelData) VALUES (?, ?, ?, ?, ?, ?, ?)",
				{ a_SrcAccount, a_DstAccount, -a_Amount, a_Message or "", os.time(), a_Channel or "", a_ChannelData or "" }
			)
			if not(isSuccess) then
				return nil, errMsg
			end
			
			-- Add the incoming transaction:
			isSuccess, errMsg = self.DB:executeStatement(
				"INSERT INTO Transactions (Account, ContraAccount, Amount, Message, DateTime, Channel, ChannelData) VALUES (?, ?, ?, ?, ?, ?, ?)",
				{ a_DstAccount, a_SrcAccount, a_Amount, a_Message or "", os.time(), a_Channel or "", a_ChannelData or "" }
			)
			if not(isSuccess) then
				return nil, errMsg
			end
			
			-- Return the new balance:
			return srcBalance - a_Amount
		end
	)
end





function InitializeStorage()
	-- Open the database:
	local ErrMsg
	g_Storage.DB, ErrMsg = newSQLiteDB("Coiny.sqlite")
	if not(g_Storage) then
		LOGWARNING("Cannot open the Coiny database, economy not available")
		error(ErrMsg)
	end
	
	-- Define the needed structure:
	local transactionsColumns =
	{
		"Account",
		"ContraAccount",
		"Amount",
		"Message",
		"DateTime",
		"Channel",
		"ChannelData",
	}
	local specialAccountsColumns =
	{
		"Uuid PRIMARY KEY",
		"Name",
	}
	
	-- Check / create structure:
	if (
		not(g_Storage.DB:createDBTable("Transactions",    transactionsColumns)) or
		not(g_Storage.DB:createDBTable("SpecialAccounts", specialAccountsColumns))
	) then
		LOGWARNING("Cannot initialize the Coiny database, economy not available.")
		error("Coiny economy DB failure")
	end
end




