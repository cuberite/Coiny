function HandleMoneyCommand(Split, IN_player)
	local _action_was_performed = false
	local _playername = IN_player:GetName()
	if (IN_player:HasPermission("coiny.base") == true) then
		FunctionInternalCall = true
		InitPlayer(_playername)
		if (#Split == 1) then
			IN_player:SendMessage("Your pocket is "..PlayersData[_playername].money.." coins heavy")
		end
		--------------------------------------------------------------------------------------------------------
		if (#Split == 2 or #Split == 3) then	-- miswritten!
			if (Split[2] == "freeze") then
				if (IN_player:HasPermission("coiny.freeze") == false) then
					HackCheck(_playername, "freeze coins!")
					return true
				end
				if (PlayersData[_playername].freeze ~= true) then
					PlayersData[_playername].freeze = true
					IN_player:SendMessage("Your coins were frozen")
				else
					PlayersData[_playername].freeze = false
					IN_player:SendMessage("Your coins were unfrozen")
				end
				_action_was_performed = true
			elseif (Split[2] == "pay") then
				if (IN_player:HasPermission("coiny.trade") == false) then
					HackCheck(_playername, "trade!")
					return true
				end
				IN_player:SendMessage("You're doing it wrong. Usage: /money pay (name) (ammount)")
			elseif (Split[2] == "give") then
				if (IN_player:HasPermission("coiny.reward") == false) then
					HackCheck(_playername, "gift money!")
					return true
				end
				IN_player:SendMessage("You're doing it wrong. Usage: /money give (name) (ammount)")
			elseif (Split[2] == "take") then
				if (IN_player:HasPermission("coiny.punish") == false) then
					HackCheck(_playername, "take money!")
					return true
				end
				IN_player:SendMessage("You're doing it wrong. Usage: /money take (name) (ammount)")
			else
				IN_player:SendMessage("You're doing it horribly wrong. Use /help")
			end
		end
		--------------------------------------------------------------------------------------------------------
		if (#Split == 4) then			-- SEEMS LEGIT YAY!
			local _ammount = tonumber(Split[4])
			local _other_player = HANDY:Call("GetExactPlayername", Split[3])
			--//////////////////////////////////
			if (Split[2] == "pay") then
				if (IN_player:HasPermission("coiny.trade") == false) then
					HackCheck(_playername, "trade!")
					return true
				end
				if (_ammount < 0) then
					IN_player:SendMessage("One does not simply trade negative ammount of money (with Mordor)")
					HackCheck(_playername, "trade negative coins!")
					return true
				end
				_transferred_ammount = TransferMoney(_playername, _other_player, _ammount)
				if (_transferred_ammount == -1) then
					IN_player:SendMessage("You don't have enought money!")
				else
					IN_player:SendMessage("".._transferred_ammount.." coins were transferred to ".._other_player)
					PROCESSED_MESSAGE = "You were given ".._ammount.." coins from ".._playername
					cRoot:Get():FindAndDoWithPlayer(_other_player, ItsAboutSendingAMessage)
					_action_was_performed = true
				end
			
			--//////////////////////////////////
			elseif (Split[2] == "give") then
				if (IN_player:HasPermission("coiny.reward") == false) then
					HackCheck(_playername, "gift coins!")
					return true
				end
				if (_ammount < 0) then
					IN_player:SendMessage("One does not simply give negative ammount of money (to Mordor)")
					HackCheck(_playername, "give negative coins!")
					return true
				end
				GiveMoney(_other_player, _ammount)
				IN_player:SendMessage("".._ammount.." coins were given to "..Split[3])
				PROCESSED_MESSAGE = "You were given ".._ammount.." coins. Use wisely"
				cRoot:Get():FindAndDoWithPlayer(_other_player, ItsAboutSendingAMessage)
				_action_was_performed = true
			
			--//////////////////////////////////
			elseif (Split[2] == "take") then
				if (IN_player:HasPermission("coiny.punish") == false) then
					HackCheck(_playername, "punish others!")
					return true
				end
				if (_ammount < 0) then
					IN_player:SendMessage("One does not simply take negative ammount of money (from Mordor)")
					HackCheck(_playername, "take negative coins!")
					return true
				end
				TakeMoney(_other_player, _ammount)
				IN_player:SendMessage("".._ammount.." coins were taken from ".._other_player..", and I don't care if he happened to had less!")
				PROCESSED_MESSAGE = "You happened to lost ".._ammount.." coins. Sad :("
				cRoot:Get():FindAndDoWithPlayer(_other_player, ItsAboutSendingAMessage)
				_action_was_performed = true
			end
		end
	end
	----------------------------- PARANOID MODE ON
	if (SaveMode == eSaveMode_Paranoid
	and _action_was_performed == true) then
		SaveData()
	end
	return true
end
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function SaveData()
	file = io.open(PLUGIN:GetLocalDirectory().."/coiny_players.dat", "w")
	for k,v in pairs(PlayersData) do
		local line = ""..k
		line = line.."~"..v.was_given_starter
		line = line.."~"..v.money
		if (v.freeze == true) then
			line = line.."~"..v.freeze
		end
		file:write(line.."\n")
	end
	file:close()
	LOG(PLUGIN:GetName().." v"..PLUGIN:GetVersion()..": Players data was saved")
end
function LoadData()
	file = io.open(PLUGIN:GetLocalDirectory().."/coiny_players.dat", "r")
	if (file == nil) then		return 1	end
	for line in file:lines() do
		local Split = LineSplit(line, "~")
		-- split validation!!!
		if (#Split == 3 or #Split == 4) then
			if (PlayersData[Split[1]] == nil) then
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
	_ini_file = cIniFile(PLUGIN:GetLocalDirectory() .. "/coiny_settings.ini")
	_ini_file:ReadFile()
	local _save_mode = _ini_file:GetValueSet("Settings", "SaveMode", "Timed")
	if (SaveMode == eSaveMode_Timed)	then	_save_mode = "Timed"		end
	if (SaveMode == eSaveMode_Paranoid)	then	_save_mode = "Paranoid"		end
	if (SaveMode == eSaveMode_Relaxed)	then	_save_mode = "Relaxed"		end
	if (SaveMode == eSaveMode_Dont)		then	_save_mode = "Dont"			end
	_ini_file:SetValue("Settings", "SaveMode", 					_save_mode, 			false)
	_ini_file:SetValueI("Settings", "TicksPerSave", 			SaveEveryNthTick, 		false)
	_ini_file:SetValueI("Settings", "StarterPack", 				StarterPack, 			false)
	_ini_file:SetValueB("Settings", "AllowNegativeBalance", 	AllowNegativeBalance, 	false)
	_ini_file:SetValueB("Settings", "AllowPartialTransfer", 	AllowPartialTransfer, 	false)
	_ini_file:SetValueB("Settings", "LogHackAttempts", 			LogHackAttempts, 		false)
	_ini_file:WriteFile()
end
function LoadSettings()
	_ini_file = cIniFile(PLUGIN:GetLocalDirectory() .. "/coiny_settings.ini")
	_ini_file:ReadFile()
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
	_ini_file:WriteFile()
end
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function TransferMoney(IN_from_name, IN_to_name, IN_ammount)
	local _ammount = 0
	InitPlayer(IN_to_name)
	if (PlayersData[IN_from_name].freeze == true) then
			FunctionInternalCall = true
		GiveMoney(IN_to_name, IN_ammount)
		_ammount = IN_ammount
	else
		if (tonumber(PlayersData[IN_from_name].money) < tonumber(IN_ammount)) then
			if (AllowPartialTransfer == true) then
				_ammount = PlayersData[IN_from_name].money
					FunctionInternalCall = true
				GiveMoney(IN_to_name, _ammount)
				PlayersData[IN_from_name].money = 0
			else
				_ammount = -1
			end
		else
				FunctionInternalCall = true
			GiveMoney(IN_to_name, IN_ammount)
				FunctionInternalCall = true
			TakeMoney(IN_from_name, IN_ammount)
			_ammount = IN_ammount
		end
	end
	ExternalCallSaveCheck()
	return _ammount
end
function GiveMoney(IN_playername, IN_ammount)
	InitPlayer(IN_playername)
	if (PlayersData[IN_playername].freeze == true) then
		return true
	end
	PlayersData[IN_playername].money = PlayersData[IN_playername].money + IN_ammount
	ExternalCallSaveCheck()
end

function TakeMoney(IN_playername, IN_ammount)
	InitPlayer(IN_playername)
	if (PlayersData[IN_playername].freeze == true) then
		return true
	end
	PlayersData[IN_playername].money = PlayersData[IN_playername].money - IN_ammount
	if (AllowNegativeBalance == false
	and PlayersData[IN_playername].money < 0) then
		PlayersData[IN_playername].money = 0
	end
	ExternalCallSaveCheck()
end


---
function GetMoney(IN_playername)
	InitPlayer(IN_playername)
	return PlayersData[IN_playername].money
end

function SetMoney(IN_playername, IM_ammount)
	InitPlayer(IN_playername)
	if (PlayersData[IN_playername].freeze == true) then
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
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function InitPlayer(IN_playername)
	if (PlayersData[IN_playername] == nil) then
		PlayersData[IN_playername] = {}	-- create player's page
		PlayersData[IN_playername].was_given_starter = 1	-- we know for sure that player is online and we had no note for him, sooo...
		-- It's dangerous to go alove here! Take THIS
		PlayersData[IN_playername].money = StarterPack
		if (SaveMode == eSaveMode_Paranoid) then
			SaveData()
		end
	end
end
function ItsAboutSendingAMessage(IN_player)
	IN_player:SendMessage(PROCESSED_MESSAGE)
end
function RemindFrozenPlayers()
	for k,v in pairs(PlayersData) do
		if (v.freeze == true) then
			PROCESSED_MESSAGE = cChatColor.Blue.."Friendly reminder: your money are still frozen"
			cRoot:Get():FindAndDoWithPlayer(k, ItsAboutSendingAMessage)
		end
	end
end
---
function ExternalCallSaveCheck()
	if (FunctionInternalCall == false) then
		if (SaveMode == eSaveMode_Paranoid) then
			SaveData()
		end
	end
	FunctionInternalCall = false
end

function HackCheck(IN_playername, IN_reason)
	if (LogHackAttempts == true) then
		LOG(PLUGIN:GetName().." v"..PLUGIN:GetVersion()..": Player '"..IN_playername.."' had tried to "..IN_reason)
	end
end
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- splits line by any desired symbol
function LineSplit(pString, pPattern)		-- THANK YOU, stackoverflow!
	local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = pString:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(Table,cap)
		end
		last_end = e+1
		s, e, cap = pString:find(fpat, last_end)
	end
	if last_end <= #pString then
		cap = pString:sub(last_end)
		table.insert(Table, cap)
	end
	return Table
end