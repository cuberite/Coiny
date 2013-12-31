function DummyFunction()
	
end

function HandleMoneyCommand( Split, IN_player )
    --HANDY = cRoot:Get():GetPluginManager():GetPlugin( "Handy" )
	local _action_was_performed = false
	local _playername = IN_player:GetName()
	if( IN_player:HasPermission( "coiny.base" ) == true ) then
		FunctionInternalCall = true
		InitPlayer( _playername )
		if( #Split == 1 ) then
			playerMoney = tonumber( PlayersData[_playername].money )
			if( AdvancedMessages ) then
				if( playerMoney < -1 ) then
					IN_player:SendMessage( AdvancedMessagesData["NegativePrefix"]..playerMoney..AdvancedMessagesData["NegativePostfix"] )
				elseif( playerMoney == -1 ) then
					IN_player:SendMessage( AdvancedMessagesData["MinusOneCoin"] )
				elseif( playerMoney == 0 ) then
					IN_player:SendMessage( AdvancedMessagesData["ZeroCoins"] )
				elseif( playerMoney == 1 ) then
					IN_player:SendMessage( AdvancedMessagesData["OneCoin"] )
				else
					if( playerMoney < tonumber( AdvancedMessagesData["LowValue"] ) ) then
						IN_player:SendMessage( AdvancedMessagesData["LowPrefix"]..playerMoney..AdvancedMessagesData["LowPostfix"] )
					elseif( playerMoney < tonumber( AdvancedMessagesData["MediumValue"] ) ) then
						IN_player:SendMessage( AdvancedMessagesData["MediumPrefix"]..playerMoney..AdvancedMessagesData["MediumPostfix"] )
					else
						IN_player:SendMessage( AdvancedMessagesData["HighPrefix"]..playerMoney..AdvancedMessagesData["HighPostfix"] )
					end
				end
			else
				if( playerMoney == -1 ) then
					IN_player:SendMessage( "Your pocket is -1 coin heavy" )
				elseif( playerMoney == 0 ) then
					IN_player:SendMessage( "You don't have any coins" )
				elseif( playerMoney == 1 ) then
					IN_player:SendMessage( "Your pocket is 1 coin heavy" )
				else
					IN_player:SendMessage( "Your pocket is "..playerMoney.." coins heavy" )
				end
			end
		end
		--------------------------------------------------------------------------------------------------------
		if( #Split == 2 or #Split == 3 ) then	-- miswritten!
			if( Split[2] == "freeze" ) then
				if( IN_player:HasPermission( "coiny.freeze" ) == false ) then
					HackCheck( _playername, "freeze coins!" )
					return true
				end
				if( PlayersData[_playername].freeze ~= true ) then
					PlayersData[_playername].freeze = true
					IN_player:SendMessage( Messages["Frozen"] )
				else
					PlayersData[_playername].freeze = false
					IN_player:SendMessage( Messages["Unfrozen"] )
				end
				_action_was_performed = true
			elseif( Split[2] == "pay" ) then
				if( IN_player:HasPermission( "coiny.trade" ) == false ) then
					HackCheck( _playername, "trade!" )
					return true
				end
				IN_player:SendMessage( Messages["WrongPay"] )
			elseif( Split[2] == "give" ) then
				if( IN_player:HasPermission("coiny.reward") == false ) then
					HackCheck( _playername, "gift money!" )
					return true
				end
				IN_player:SendMessage( Messages["WrongGive"] )
			elseif( Split[2] == "take" ) then
				if( IN_player:HasPermission( "coiny.punish" ) == false) then
					HackCheck( _playername, "take money!" )
					return true
				end
				IN_player:SendMessage( Messages["WrongTake"] )
			else
				IN_player:SendMessage( Messages["HorriblyWrong"] )
			end
		end
		--------------------------------------------------------------------------------------------------------
		if( #Split == 4 ) then			-- SEEMS LEGIT YAY!
			local _ammount = tonumber( Split[4] )
			local _other_player = HANDY:Call( "GetExactPlayername", Split[3] )
			--//////////////////////////////////
			if( Split[2] == "pay" ) then
				if( IN_player:HasPermission( "coiny.trade" ) == false ) then
					HackCheck( _playername, "trade!" )
					return true
				end
				if( _ammount < 0 ) then
					IN_player:SendMessage( Messages["NegativeTrade"] )
					HackCheck( _playername, "trade negative coins!" )
					return true
				end
				_transferred_ammount = TransferMoney( _playername, _other_player, _ammount )
				if( _transferred_ammount == -1 ) then
					IN_player:SendMessage( Messages["NotEnoughMoney"] )
				else
					IN_player:SendMessage( FormatMessage( "Transfer", _other_player, _transferred_ammount ) )
					PROCESSED_MESSAGE = FormatMessage( "GivenFrom", _playername, _transferred_ammount )
					cRoot:Get():FindAndDoWithPlayer( _other_player, ItsAboutSendingAMessage )
					_action_was_performed = true
				end
			
			--//////////////////////////////////
			elseif( Split[2] == "give" ) then
				if( IN_player:HasPermission("coiny.reward") == false ) then
					HackCheck( _playername, "gift coins!" )
					return true
				end
				if( _ammount < 0 ) then
					IN_player:SendMessage( Messages["NegativeGive"] )
					HackCheck( _playername, "give negative coins!" )
					return true
				end
				GiveMoney( _other_player, _ammount )
				IN_player:SendMessage( FormatMessage( "GivenTo", _other_player, _ammount ) )
				PROCESSED_MESSAGE = FormatMessage( "Given", "", _ammount )
				cRoot:Get():FindAndDoWithPlayer( _other_player, ItsAboutSendingAMessage )
				_action_was_performed = true
			
			--//////////////////////////////////
			elseif( Split[2] == "take" ) then
				if( IN_player:HasPermission( "coiny.punish" ) == false ) then
					HackCheck( _playername, "punish others!" )
					return true
				end
				if( _ammount < 0 ) then
					IN_player:SendMessage( Messages["NegativeTake"] )
					HackCheck( _playername, "take negative coins!" )
					return true
				end
				TakeMoney( _other_player, _ammount )
				
				IN_player:SendMessage( FormatMessage( "TakenFrom", _other_player, _ammount ) )
				PROCESSED_MESSAGE = FormatMessage( "Taken", "", _ammount )
				cRoot:Get():FindAndDoWithPlayer( _other_player, ItsAboutSendingAMessage )
				_action_was_performed = true
			end
		end
	end
	----------------------------- PARANOID MODE ON
	if( SaveMode == eSaveMode_Paranoid
	and _action_was_performed == true ) then
		SaveData()
	end
	return true
end
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function SaveData()
	file = io.open( PLUGIN:GetLocalFolder().. "/coiny_players.dat", "w" )
	for k,v in pairs( PlayersData ) do
		local line = ""..k
		line = line.."~"..v.was_given_starter
		line = line.."~"..v.money
		if( v.freeze == true ) then
			line = line.."~"..v.freeze
		end
		file:write( line.."\n" )
	end
	file:close()
	LOG( PLUGIN:GetName().." v"..PLUGIN:GetVersion()..": Players data was saved" )
end
function LoadData()
	file = io.open( PLUGIN:GetLocalFolder().."/coiny_players.dat", "r" )
	if( file == nil ) then		return 1	end
	for line in file:lines() do
		local Split = LineSplit( line, "~" )
		-- split validation!!!
		if( #Split == 3 or #Split == 4 ) then
			if( PlayersData[Split[1]] == nil ) then
				PlayersData[Split[1]] = {}	-- create player's page
			end
			PlayersData[Split[1]].was_given_starter = Split[2]
			PlayersData[Split[1]].money = Split[3]
			if (#Split == 4) then
				PlayersData[Split[1]].freeze = Split[4]
			end
		end
	end
	file:close()
end
function SaveSettings()
	_ini_file = cIniFile()
	_ini_file:ReadFile( PLUGIN:GetLocalFolder() .. "/coiny_settings.ini" )
	local _save_mode = _ini_file:GetValueSet( "Settings", "SaveMode", "Timed" )
	if( SaveMode == eSaveMode_Timed )		then	_save_mode = "Timed"		end
	if( SaveMode == eSaveMode_Paranoid )	then	_save_mode = "Paranoid"		end
	if( SaveMode == eSaveMode_Relaxed )		then	_save_mode = "Relaxed"		end
	if( SaveMode == eSaveMode_Dont )		then	_save_mode = "Dont"			end
	_ini_file:SetValue( "Settings", "SaveMode", 				_save_mode, 			false )
	_ini_file:SetValueI( "Settings", "TicksPerSave", 			SaveEveryNthTick, 		false )
	_ini_file:SetValueI( "Settings", "StarterPack", 			StarterPack, 			false )
	_ini_file:SetValueB( "Settings", "AllowNegativeBalance", 	AllowNegativeBalance, 	false )
	_ini_file:SetValueB( "Settings", "AllowPartialTransfer", 	AllowPartialTransfer, 	false )
	_ini_file:SetValueB( "Settings", "LogHackAttempts", 		LogHackAttempts, 		false )
	
	_ini_file:SetValueB( "Settings", "AdvancedMessages", 		AdvancedMessages, 		false )
	if( AdvancedMessages ) then
		_ini_file:SetValue( "AMNegative", "Prefix", AdvancedMessagesData["NegativePrefix"], false )
		_ini_file:SetValue( "AMNegative", "Postfix", AdvancedMessagesData["NegativePostfix"], false )
		
		_ini_file:SetValue( "AMZero", "MinusOneCoinText", AdvancedMessagesData["MinusOneCoin"], false )
		_ini_file:SetValue( "AMZero", "ZeroCoinsText", AdvancedMessagesData["ZeroCoins"], false )
		_ini_file:SetValue( "AMZero", "OneCoinText", AdvancedMessagesData["OneCoin"], false )
		
		_ini_file:SetValueI("AMLow", "Value", 	AdvancedMessagesData["LowValue"], false )
		_ini_file:SetValue( "AMLow", "Prefix", 	AdvancedMessagesData["LowPrefix"], false )
		_ini_file:SetValue( "AMLow", "Postfix", AdvancedMessagesData["LowPostfix"], false )
		
		_ini_file:SetValueI("AMMedium", "Value", 	AdvancedMessagesData["MediumValue"], false )
		_ini_file:SetValue( "AMMedium", "Prefix", 	AdvancedMessagesData["MediumPrefix"], false )
		_ini_file:SetValue( "AMMedium", "Postfix", 	AdvancedMessagesData["MediumPostfix"], false )
		
		_ini_file:SetValue( "AMHigh", "Prefix", AdvancedMessagesData["HighPrefix"], false )
		_ini_file:SetValue( "AMHigh", "Postfix",AdvancedMessagesData["HighPostfix"], false )
	end
	
	for k,v in pairs( Messages ) do
		_ini_file:SetValue( "Messages", k, v )
	end
	_ini_file:WriteFile(PLUGIN:GetLocalFolder() .. "/coiny_settings.ini")
end
function LoadSettings()
	_ini_file = cIniFile()
	_ini_file:ReadFile( PLUGIN:GetLocalFolder() .. "/coiny_settings.ini" )
	local _save_mode = _ini_file:GetValueSet( "Settings", "SaveMode", "Timed" )
	if( _save_mode == "Timed" )		then SaveMode = eSaveMode_Timed		end
	if( _save_mode == "Paranoid" )	then SaveMode = eSaveMode_Paranoid	end
	if( _save_mode == "Relaxed" )	then SaveMode = eSaveMode_Relaxed	end
	if( _save_mode == "Dont" )		then SaveMode = eSaveMode_Dont		end
	SaveEveryNthTick = 		_ini_file:GetValueSetI( "Settings", "TicksPerSave", 			2000 )
	StarterPack = 			_ini_file:GetValueSetI( "Settings", "StarterPack", 			200 )
	AllowNegativeBalance = 	_ini_file:GetValueSetB( "Settings", "AllowNegativeBalance", 	false )
	AllowPartialTransfer = 	_ini_file:GetValueSetB( "Settings", "AllowPartialTransfer", 	false )
	LogHackAttempts = 		_ini_file:GetValueSetB( "Settings", "LogHackAttempts", 		false )
	
	AdvancedMessages = 		_ini_file:GetValueSetB( "Settings", "AdvancedMessages", 		true )
	if( AdvancedMessages ) then
		AdvancedMessagesData["NegativePrefix"] =	_ini_file:GetValueSet( "AMNegative", "Prefix", "You owe " )
		AdvancedMessagesData["NegativePostfix"] =	_ini_file:GetValueSet( "AMNegative", "Postfix", " coins. Sorry :(" )
		
		AdvancedMessagesData["MinusOneCoin"] =	_ini_file:GetValueSet( "AMZero", "MinusOneCoinText", "You owe 1 coin" )
		AdvancedMessagesData["ZeroCoins"] = 	_ini_file:GetValueSet( "AMZero", "ZeroCoinsText", "You're out of coins, mate!" )
		AdvancedMessagesData["OneCoin"] = 		_ini_file:GetValueSet( "AMZero", "OneCoinText", "You only have 1 coin" )
		
		AdvancedMessagesData["LowValue"] = _ini_file:GetValueSetI( "AMLow", "Value", 100 )
		AdvancedMessagesData["LowPrefix"] = _ini_file:GetValueSet( "AMLow", "Prefix", "Your pocket is " )
		AdvancedMessagesData["LowPostfix"] = _ini_file:GetValueSet( "AMLow", "Postfix", " coins heavy" )
		
		AdvancedMessagesData["MediumValue"] = _ini_file:GetValueSetI( "AMMedium", "Value", 1000 )
		AdvancedMessagesData["MediumPrefix"] = _ini_file:GetValueSet( "AMMedium", "Prefix", "You possess " )
		AdvancedMessagesData["MediumPostfix"] = _ini_file:GetValueSet( "AMMedium", "Postfix", " coins" )
		
		AdvancedMessagesData["HighPrefix"] = _ini_file:GetValueSet( "AMHigh", "Prefix", "Your bank account has " )
		AdvancedMessagesData["HighPostfix"] = _ini_file:GetValueSet( "AMHigh", "Postfix", " coins!" )
	end
	
	local values = _ini_file:GetNumValues( "Messages" )
	for index = 0, (values - 1), 1 do
		local valueName = _ini_file:GetValueName( "Messages", index )
		Messages[valueName] = _ini_file:GetValue( "Messages", valueName )
	end
	_ini_file:WriteFile( PLUGIN:GetLocalFolder() .. "/coiny_settings.ini" )
end
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function TransferMoney( IN_from_name, IN_to_name, IN_ammount )
	local _ammount = 0
	InitPlayer( IN_to_name )
	if( PlayersData[IN_from_name].freeze == true ) then
			FunctionInternalCall = true
		GiveMoney( IN_to_name, IN_ammount )
		_ammount = IN_ammount
	else
		if( tonumber( PlayersData[IN_from_name].money ) < tonumber( IN_ammount ) ) then
			if( AllowPartialTransfer == true ) then
				_ammount = PlayersData[IN_from_name].money
					FunctionInternalCall = true
				GiveMoney( IN_to_name, _ammount )
				PlayersData[IN_from_name].money = 0
			else
				_ammount = -1
			end
		else
				FunctionInternalCall = true
			GiveMoney( IN_to_name, IN_ammount )
				FunctionInternalCall = true
			TakeMoney( IN_from_name, IN_ammount )
			_ammount = IN_ammount
		end
	end
	ExternalCallSaveCheck()
	return _ammount
end

function GiveMoney( IN_playername, IN_ammount )
	InitPlayer( IN_playername )
	if( PlayersData[IN_playername].freeze == true ) then
		return true
	end
	PlayersData[IN_playername].money = PlayersData[IN_playername].money + IN_ammount
	ExternalCallSaveCheck()
end

function TakeMoney( IN_playername, IN_ammount )
	InitPlayer( IN_playername )
	if( PlayersData[IN_playername].freeze == true ) then
		return true
	end
	PlayersData[IN_playername].money = PlayersData[IN_playername].money - IN_ammount
	if( AllowNegativeBalance == false
	and PlayersData[IN_playername].money < 0 ) then
		PlayersData[IN_playername].money = 0
	end
	ExternalCallSaveCheck()
end
---
function GetMoney( IN_playername )
	InitPlayer( IN_playername )
	return PlayersData[IN_playername].money
end

function SetMoney( IN_playername, IN_ammount )
	InitPlayer( IN_playername )
	if( PlayersData[IN_playername].freeze == true ) then
		return true
	end
	PlayersData[IN_playername].money = IN_ammount
	if( AllowNegativeBalance == false
	and PlayersData[IN_playername].money < 0 ) then
		PlayersData[IN_playername].money = 0
	end
	ExternalCallSaveCheck()
	return true
end
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function InitPlayer( IN_playername )
	if( PlayersData[IN_playername] == nil ) then
		PlayersData[IN_playername] = {}	-- create player's page
		PlayersData[IN_playername].was_given_starter = 1	-- we know for sure that player is online and we had no note for him, sooo...
		-- It's dangerous to go alove here! Take THIS
		PlayersData[IN_playername].money = StarterPack
		if( SaveMode == eSaveMode_Paranoid ) then
			SaveData()
		end
	end
end

function ItsAboutSendingAMessage( IN_player )
	IN_player:SendMessage(PROCESSED_MESSAGE)
end

function FormatMessage( inKey, inPlayerName, inAmmount )
	local message = Messages[inKey.."Prefix"]..inAmmount..Messages[inKey.."Middle"]..inPlayerName..Messages[inKey.."Postfix"]
	return message
end

function RemindFrozenPlayers()
	for k,v in pairs( PlayersData ) do
		if (v.freeze == true) then
			PROCESSED_MESSAGE = cChatColor.Blue.."Friendly reminder: your money are still frozen"
			cRoot:Get():FindAndDoWithPlayer( k, ItsAboutSendingAMessage )
		end
	end
end
---
function ExternalCallSaveCheck()
	if( FunctionInternalCall == false ) then
		if( SaveMode == eSaveMode_Paranoid ) then
			SaveData()
		end
	end
	FunctionInternalCall = false
end

function HackCheck( IN_playername, IN_reason )
	if( LogHackAttempts == true ) then
		LOG(PLUGIN:GetName().." v"..PLUGIN:GetVersion()..": Player '"..IN_playername.."' had tried to "..IN_reason)
	end
end
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- splits line by any desired symbol
function LineSplit( pString, pPattern )		-- THANK YOU, stackoverflow!
	local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = pString:find( fpat, 1 )
	while s do
		if( s ~= 1 or cap ~= "" ) then
			table.insert( Table,cap )
		end
		last_end = e + 1
		s, e, cap = pString:find( fpat, last_end )
	end
	if( last_end <= #pString ) then
		cap = pString:sub( last_end )
		table.insert( Table, cap )
	end
	return Table
end
