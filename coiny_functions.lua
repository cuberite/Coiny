
-- coiny_functions.lua

-- Implements various helper functions





function SaveData()
	local file = io.open(cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/coiny_players.dat", "w")
	for k, v in pairs(PlayersData) do
		local line = k .. "~" .. (v.was_given_starter and "true" or "false")
		line = line .. "~" .. v.money
		if (v.freeze) then
			line = line .. "~true"
		end
		file:write(line .. "\n")
	end
	file:close()
	LOG(cPluginManager:GetCurrentPlugin():GetName() .. " : Players data was saved")
end





function LoadData()
	local file = io.open(cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/coiny_players.dat", "r")
	if (file == nil) then
		return 1
	end
	for line in file:lines() do
		local Split = StringSplit(line, "~")
		-- split validation!!!
		if (#Split == 3 or #Split == 4) then
			if (PlayersData[Split[1]] == nil) then
				PlayersData[Split[1]] = {}	-- create player's page
			end
			PlayersData[Split[1]].was_given_starter = (Split[2] == "true")
			PlayersData[Split[1]].money = tonumber(Split[3])
			PlayersData[Split[1]].freeze = (Split[4] == "true")
		end
	end
	file:close()
end





function SaveSettings()
	local _ini_file = cIniFile()
	_ini_file:ReadFile(cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/coiny_settings.ini")
	local _save_mode = _ini_file:GetValueSet("Settings", "SaveMode", "Timed")
	if (SaveMode == eSaveMode_Timed)		then	_save_mode = "Timed"		end
	if (SaveMode == eSaveMode_Paranoid)	then	_save_mode = "Paranoid"		end
	if (SaveMode == eSaveMode_Relaxed)		then	_save_mode = "Relaxed"		end
	if (SaveMode == eSaveMode_Dont)		then	_save_mode = "Dont"			end
	_ini_file:SetValue("Settings", "SaveMode", 				_save_mode, 			false)
	_ini_file:SetValueI("Settings", "TicksPerSave", 			SaveEveryNthTick, 		false)
	_ini_file:SetValueI("Settings", "StarterPack", 			StarterPack, 			false)
	_ini_file:SetValueB("Settings", "AllowNegativeBalance", 	AllowNegativeBalance, 	false)
	_ini_file:SetValueB("Settings", "AllowPartialTransfer", 	AllowPartialTransfer, 	false)
	_ini_file:SetValueB("Settings", "LogHackAttempts", 		LogHackAttempts, 		false)
	
	_ini_file:SetValueB("Settings", "AdvancedMessages", 		AdvancedMessages, 		false)
	if (AdvancedMessages) then
		_ini_file:SetValue("AMNegative", "Prefix", AdvancedMessagesData["NegativePrefix"], false)
		_ini_file:SetValue("AMNegative", "Postfix", AdvancedMessagesData["NegativePostfix"], false)
		
		_ini_file:SetValue("AMZero", "MinusOneCoinText", AdvancedMessagesData["MinusOneCoin"], false)
		_ini_file:SetValue("AMZero", "ZeroCoinsText", AdvancedMessagesData["ZeroCoins"], false)
		_ini_file:SetValue("AMZero", "OneCoinText", AdvancedMessagesData["OneCoin"], false)
		
		_ini_file:SetValueI("AMLow", "Value", 	AdvancedMessagesData["LowValue"], false)
		_ini_file:SetValue("AMLow", "Prefix", 	AdvancedMessagesData["LowPrefix"], false)
		_ini_file:SetValue("AMLow", "Postfix", AdvancedMessagesData["LowPostfix"], false)
		
		_ini_file:SetValueI("AMMedium", "Value", 	AdvancedMessagesData["MediumValue"], false)
		_ini_file:SetValue("AMMedium", "Prefix", 	AdvancedMessagesData["MediumPrefix"], false)
		_ini_file:SetValue("AMMedium", "Postfix", 	AdvancedMessagesData["MediumPostfix"], false)
		
		_ini_file:SetValue("AMHigh", "Prefix", AdvancedMessagesData["HighPrefix"], false)
		_ini_file:SetValue("AMHigh", "Postfix",AdvancedMessagesData["HighPostfix"], false)
	end
	
	_ini_file:DeleteKey("Messages")
	for k, v in pairs(Messages) do
		_ini_file:SetValue("Messages", k, v)
	end
	_ini_file:WriteFile(cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/coiny_settings.ini")
end





function LoadSettings()
	local _ini_file = cIniFile()
	_ini_file:ReadFile(cPluginManager:GetCurrentPlugin():GetLocalFolder().. "/coiny_settings.ini")
	local _save_mode = _ini_file:GetValueSet("Settings", "SaveMode", "Timed")
	if (_save_mode == "Timed")		then SaveMode = eSaveMode_Timed		end
	if (_save_mode == "Paranoid")	then SaveMode = eSaveMode_Paranoid	end
	if (_save_mode == "Relaxed")	then SaveMode = eSaveMode_Relaxed	end
	if (_save_mode == "Dont")		then SaveMode = eSaveMode_Dont		end
	SaveEveryNthTick = 		_ini_file:GetValueSetI("Settings", "TicksPerSave", 			2000)
	StarterPack = 			_ini_file:GetValueSetI("Settings", "StarterPack", 			200)
	AllowNegativeBalance = 	_ini_file:GetValueSetB("Settings", "AllowNegativeBalance", 	false)
	AllowPartialTransfer = 	_ini_file:GetValueSetB("Settings", "AllowPartialTransfer", 	false)
	LogHackAttempts = 		_ini_file:GetValueSetB("Settings", "LogHackAttempts", 		false)
	
	AdvancedMessages = 		_ini_file:GetValueSetB("Settings", "AdvancedMessages", 		true)
	if (AdvancedMessages) then
		AdvancedMessagesData["NegativePrefix"] =	_ini_file:GetValueSet("AMNegative", "Prefix", "You owe ")
		AdvancedMessagesData["NegativePostfix"] =	_ini_file:GetValueSet("AMNegative", "Postfix", " coins. Sorry :(")
		
		AdvancedMessagesData["MinusOneCoin"] =	_ini_file:GetValueSet("AMZero", "MinusOneCoinText", "You owe 1 coin")
		AdvancedMessagesData["ZeroCoins"] = 	_ini_file:GetValueSet("AMZero", "ZeroCoinsText", "You're out of coins, mate!")
		AdvancedMessagesData["OneCoin"] = 		_ini_file:GetValueSet("AMZero", "OneCoinText", "You only have 1 coin")
		
		AdvancedMessagesData["LowValue"] = _ini_file:GetValueSetI("AMLow", "Value", 100)
		AdvancedMessagesData["LowPrefix"] = _ini_file:GetValueSet("AMLow", "Prefix", "Your pocket is ")
		AdvancedMessagesData["LowPostfix"] = _ini_file:GetValueSet("AMLow", "Postfix", " coins heavy")
		
		AdvancedMessagesData["MediumValue"] = _ini_file:GetValueSetI("AMMedium", "Value", 1000)
		AdvancedMessagesData["MediumPrefix"] = _ini_file:GetValueSet("AMMedium", "Prefix", "You possess ")
		AdvancedMessagesData["MediumPostfix"] = _ini_file:GetValueSet("AMMedium", "Postfix", " coins")
		
		AdvancedMessagesData["HighPrefix"] = _ini_file:GetValueSet("AMHigh", "Prefix", "Your bank account has ")
		AdvancedMessagesData["HighPostfix"] = _ini_file:GetValueSet("AMHigh", "Postfix", " coins!")
	end
	
	local values = _ini_file:GetNumValues("Messages")
	for index = 0, (values - 1), 1 do
		local valueName = _ini_file:GetValueName("Messages", index)
		Messages[valueName] = _ini_file:GetValue("Messages", valueName)
	end
	_ini_file:WriteFile(cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/coiny_settings.ini")
end





function SetMoney(IN_playername, IN_ammount)
	InitPlayer(IN_playername)
	if (PlayersData[IN_playername].freeze) then
		return true
	end
	PlayersData[IN_playername].money = IN_ammount
	if (AllowNegativeBalance == false
	and PlayersData[IN_playername].money < 0) then
		PlayersData[IN_playername].money = 0
	end
	ExternalCallSaveCheck()
	return true
end




function InitPlayer(a_PlayerName)
	if (PlayersData[a_PlayerName] == nil) then
		PlayersData[a_PlayerName] = {}	-- create player's page
		-- Give the player the starting package:
		PlayersData[a_PlayerName].was_given_starter = 1
		PlayersData[a_PlayerName].money = StarterPack

		-- Paranoid save:
		if (SaveMode == eSaveMode_Paranoid) then
			SaveData()
		end
	end
end





function FormatMessage(inKey, inPlayerName, inAmount)
	return Messages[inKey .. "Prefix"] .. inAmount .. Messages[inKey .. "Middle"] .. inPlayerName .. Messages[inKey .. "Postfix"]
end





function RemindFrozenPlayers()
	for k, v in pairs(PlayersData) do
		if (v.freeze) then
			PROCESSED_MESSAGE = cChatColor.Blue .. "Friendly reminder: your money are still frozen"
			cRoot:Get():FindAndDoWithPlayer(k, ItsAboutSendingAMessage)
		end
	end
end





function ExternalCallSaveCheck()
	if not(FunctionInternalCall) then
		if (SaveMode == eSaveMode_Paranoid) then
			SaveData()
		end
	end
	FunctionInternalCall = false
end





function HackCheck(IN_playername, IN_reason)
	if (LogHackAttempts) then
		LOG(cPluginManager:GetCurrentPlugin():GetName() .. " : Player '" .. IN_playername .. "' had tried to " .. IN_reason)
	end
end




