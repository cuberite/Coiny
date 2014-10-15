
-- API.lua

-- Implements the functions that are to be called from external plugins as API





--- Returns the UUID of the specified player
-- Only uses the local UUID cache; if the player is not in cache, returns nil
-- Uses offline UUIDs if the server is in offline mode
local function lookupUuid(a_PlayerName)
	-- Check params:
	assert(type(a_PlayerName) == "string")
	
	-- Get the UUID:
	if (cRoot:Get():GetServer():ShouldAuthenticate()) then
		local uuid = cMojangAPI:GetUUIDFromPlayerName(a_PlayerName, true)
		-- Convert from empty string to nil for failures:
		if (uuid == "") then
			return nil
		end
		return uuid
	else
		return cClientHandle:GenerateOfflineUUID(a_PlayerName)
	end
end





--- Gives the specified amount of money to the specified player, adding the message to the transaction log
-- Returns true if successful, nil and error message if not
function addMoneyByName(a_PlayerName, a_Amount, a_Message, a_Channel, a_ChannelData)
	-- Check params:
	assert(type(a_PlayerName) == "string")
	assert(tonumber(a_Amount) ~= nil)
	assert(type(a_Message or "") == "string")
	assert(type(a_Channel or "") == "string")
	assert(type(a_ChannelData or "") == "string")
	
	-- Look up the UUID:
	local dstUuid, errMsg = lookupUuid(a_PlayerName)
	if not(dstUuid) then
		return nil, errMsg
	end

	-- Call the storage to do the actual transaction:
	return g_Storage:addMoney(dstUuid, a_Amount, a_Message, a_Channel or "", a_ChannelData or "")
end





--- Returns the amount of money in the specified player's account
-- Returns number on success, nil and reason on failure
function getBalanceByName(a_PlayerName)
	-- Check params:
	assert(type(a_PlayerName) == "string")
	
	-- Look up the UUID:
	local uuid, errMsg = lookupUuid(a_PlayerName)
	if not(uuid) then
		return nil, errMsg
	end

	return g_Storage:getBalance(uuid)
end





--- Removes the specified amount of money from the specified player, adding the message to the transaction log
-- Returns true if successful, nil and error message if not
function removeMoneyByName(a_PlayerName, a_Amount, a_Message, a_Channel, a_ChannelData)
	-- Check params:
	assert(type(a_PlayerName) == "string")
	assert(tonumber(a_Amount) ~= nil)
	assert(type(a_Message or "") == "string")
	assert(type(a_Channel or "") == "string")
	assert(type(a_ChannelData or "") == "string")
	
	-- Look up the UUID:
	local uuid, errMsg = lookupUuid(a_PlayerName)
	if not(uuid) then
		return nil, errMsg
	end

	return g_Storage:removeMoney(uuid, a_Amount, a_Message, a_Channel or "", a_ChannelData or "")
end




--- Transfers money from one player account to another, adding the message to the transaction log
-- Returns true and src final balance on success, nil and message on failure
-- Note that the transfer fails if the src player doesn't have enough coins.
function transferMoneyByName(a_SrcPlayerName, a_DstPlayerName, a_Amount, a_Message, a_Channel, a_ChannelData)
	-- Check params:
	assert(type(a_SrcPlayerName) == "string")
	assert(type(a_DstPlayerName) == "string")
	assert(tonumber(a_Amount) ~= nil)
	assert(type(a_Message or "") == "string")
	assert(type(a_Channel or "") == "string")
	assert(type(a_ChannelData or "") == "string")
	
	-- look up the UUIDs:
	local srcUuid, dstUuid, errMsg
	srcUuid, errMsg = lookupUuid(a_SrcPlayerName)
	if not(srcUuid) then
		return nil, "Cannot find sender's account: " .. (errMsg or "<unspecified error>")
	end
	dstUuid, errMsg = lookupUuid(a_DstPlayerName)
	if not(dstUuid) then
		return nil, "Cannot find receiver's account: " .. (errMsg or "<unspecified error>")
	end

	-- Do the transfer:
	return g_Storage:transferMoney(srcUuid, dstUuid, a_Amount, a_Message, a_Channel or "", a_ChannelData or "")
end




