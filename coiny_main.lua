

-- LOGIC
eSaveMode_Paranoid = -1
eSaveMode_Timed = 0
eSaveMode_Relaxed = 1
eSaveMode_Dont = 100500

-- Global variables
SaveMode = eSaveMode_Timed
SaveEveryNthTick = 2000
SaveTicksCounter = 0
RemindTicksCounter = 0
RemindEveryNthTick = 2400	-- approximately every 2 minutes
StarterPack = 300
AllowNegativeBalance = false
AllowPartialTransfer = true
LogHackAttempts = false	-- not really logs hack attempts, but could point at players who start to play with TNT and lighter.
AdvancedMessages = true
AdvancedMessagesData = {}

FunctionsInternalCall = false

PlayersData = {}	-- this would be a hashtable for players coins
PROCESSED_PLAYER = ""
PROCESSED_MESSAGE = ""
WORK_WORLD = cRoot:Get():GetDefaultWorld():GetName()

Messages = {}





function Initialize(a_Plugin)
	-- Initialize commands:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoCommands()
	-- TODO: No console commands yet
	-- RegisterPluginInfoConsoleCommands()
	
	cPluginManager.AddHook(cPluginManager.HOOK_TICK, OnTick)
	
	LoadSettings()
	LoadData()
	
	a_Plugin:AddWebTab("Manage", HandleRequest_Manage)
	LOG("Initialized Coiny v.6")
	return true
end





function OnDisable()
	SaveSettings()
	if (SaveMode ~= eSaveMode_Dont) then
		SaveData()
	end
	LOG(cPluginManager:GetCurrentPlugin():GetName().." is shutting down...")
end





function OnTick()
	if (SaveMode == eSaveMode_Timed) then
		SaveTicksCounter = SaveTicksCounter + 1
		if (SaveTicksCounter == SaveEveryNthTick) then
			SaveTicksCounter = 0
			SaveData()
		end
	end
	RemindTicksCounter = RemindTicksCounter + 1
	if (RemindTicksCounter == RemindEveryNthTick) then
		RemindTicksCounter = 0
		RemindFrozenPlayers()
	end
end




