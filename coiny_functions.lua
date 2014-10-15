
-- coiny_functions.lua

-- Implements various helper functions





function SaveSettings()
	local ini = cIniFile()
	ini:ReadFile(cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/coiny_settings.ini")
	ini:SetValueI("Settings", "StarterPack", StarterPack, false)
	
	ini:SetValueB("Settings", "AdvancedMessages", AdvancedMessages, false)
	if (AdvancedMessages) then
		ini:SetValue("AMNegative", "Prefix",  AdvancedMessagesData["NegativePrefix"],  false)
		ini:SetValue("AMNegative", "Postfix", AdvancedMessagesData["NegativePostfix"], false)
		
		ini:SetValue("AMZero", "MinusOneCoinText", AdvancedMessagesData["MinusOneCoin"], false)
		ini:SetValue("AMZero", "ZeroCoinsText",    AdvancedMessagesData["ZeroCoins"],    false)
		ini:SetValue("AMZero", "OneCoinText",      AdvancedMessagesData["OneCoin"],      false)
		
		ini:SetValueI("AMLow", "Value", 	AdvancedMessagesData["LowValue"],   false)
		ini:SetValue ("AMLow", "Prefix", 	AdvancedMessagesData["LowPrefix"],  false)
		ini:SetValue ("AMLow", "Postfix", AdvancedMessagesData["LowPostfix"], false)
		
		ini:SetValueI("AMMedium", "Value",    AdvancedMessagesData["MediumValue"],   false)
		ini:SetValue ("AMMedium", "Prefix",   AdvancedMessagesData["MediumPrefix"],  false)
		ini:SetValue ("AMMedium", "Postfix",  AdvancedMessagesData["MediumPostfix"], false)
		
		ini:SetValue("AMHigh", "Prefix",  AdvancedMessagesData["HighPrefix"],  false)
		ini:SetValue("AMHigh", "Postfix", AdvancedMessagesData["HighPostfix"], false)
	end
	
	ini:DeleteKey("Messages")
	for k, v in pairs(Messages) do
		ini:SetValue("Messages", k, v)
	end
	ini:WriteFile(cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/coiny_settings.ini")
end





function LoadSettings()
	local ini = cIniFile()
	ini:ReadFile(cPluginManager:GetCurrentPlugin():GetLocalFolder().. "/coiny_settings.ini")
	StarterPack = ini:GetValueSetI("Settings", "StarterPack", 200)
	
	AdvancedMessages = ini:GetValueSetB("Settings", "AdvancedMessages", true)
	if (AdvancedMessages) then
		AdvancedMessagesData["NegativePrefix"]  = ini:GetValueSet("AMNegative", "Prefix",  "You owe ")
		AdvancedMessagesData["NegativePostfix"] =	ini:GetValueSet("AMNegative", "Postfix", " coins. Sorry :(")
		
		AdvancedMessagesData["MinusOneCoin"] = ini:GetValueSet("AMZero", "MinusOneCoinText", "You owe 1 coin")
		AdvancedMessagesData["ZeroCoins"]    = ini:GetValueSet("AMZero", "ZeroCoinsText",    "You're out of coins, mate!")
		AdvancedMessagesData["OneCoin"]      = ini:GetValueSet("AMZero", "OneCoinText",      "You only have 1 coin")
		
		AdvancedMessagesData["LowValue"]   = ini:GetValueSetI("AMLow", "Value",   100)
		AdvancedMessagesData["LowPrefix"]  = ini:GetValueSet ("AMLow", "Prefix",  "Your pocket is ")
		AdvancedMessagesData["LowPostfix"] = ini:GetValueSet ("AMLow", "Postfix", " coins heavy")
		
		AdvancedMessagesData["MediumValue"]   = ini:GetValueSetI("AMMedium", "Value",   1000)
		AdvancedMessagesData["MediumPrefix"]  = ini:GetValueSet ("AMMedium", "Prefix",  "You possess ")
		AdvancedMessagesData["MediumPostfix"] = ini:GetValueSet ("AMMedium", "Postfix", " coins")
		
		AdvancedMessagesData["HighPrefix"]  = ini:GetValueSet("AMHigh", "Prefix",  "Your bank account has ")
		AdvancedMessagesData["HighPostfix"] = ini:GetValueSet("AMHigh", "Postfix", " coins!")
	end
	
	local values = ini:GetNumValues("Messages")
	for index = 0, (values - 1), 1 do
		local valueName = ini:GetValueName("Messages", index)
		Messages[valueName] = ini:GetValue("Messages", valueName)
	end
	ini:WriteFile(cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/coiny_settings.ini")
end





function FormatMessage(inKey, inPlayerName, inAmount)
	return Messages[inKey .. "Prefix"] .. inAmount .. Messages[inKey .. "Middle"] .. inPlayerName .. Messages[inKey .. "Postfix"]
end





