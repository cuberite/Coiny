--[[
TODO:
- Web interface
- check for #Split == 4 and Split[4] ~= number IN /money command handler

DELAYED TODO:
- Re-write "HackCheck()" for planned "Cheetah" compatibility (Cheetah should keep its logs separately)
- Move away messages texts to separate hashtable
- Polish messages ("1 coins" -> "1 coin")
]]

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

FunctionsInternalCall = false

HANDY = {}
PLUGIN = {}	-- Reference to own plugin object
PlayersData = {}	-- this would be a hashtable for players coins
PROCESSED_PLAYER = ""
PROCESSED_MESSAGE = ""
WORK_WORLD = cRoot:Get():GetDefaultWorld():GetName()

function Initialize(Plugin)
	Plugin:SetName("Coiny")
	Plugin:SetVersion(4)
	PLUGIN = Plugin
		
	cPluginManager.BindCommand("/money",          "coiny.base",      HandleMoneyCommand,   " - shows your coins ammount")
	cPluginManager.BindCommand("/m",              "coiny.base",      HandleMoneyCommand,   "")
	cPluginManager.BindCommand("/money pay",      "coiny.trade",     DummyFunction,        " (name) (ammount) - you pay to 'name' 'ammount' of your coins")
	cPluginManager.BindCommand("/money give",     "coiny.reward",    DummyFunction,        " (name) (ammount) - gives 'name' 'ammount' of coins from air")
	cPluginManager:BindCommand("/money take",     "coiny.punish",    DummyFunction,        " (name) (ammount) - takes from 'name' 'ammount' of coins")
	cPluginManager:BindCommand("/money freeze",   "coiny.freeze",    DummyFunction,        " - freeze/unfreeze your coins ammount, for testing purposes")
	
	cPluginManager.AddHook(cPluginManager.HOOK_TICK, OnTick)
	
	HANDY = cRoot:Get():GetPluginManager():GetPlugin("Handy")
	
	LoadSettings()
	LoadData()
	LOG("Initialized "..PLUGIN:GetName().." v"..PLUGIN:GetVersion())
	return true
end

function OnDisable()
	SaveSettings()
	if (SaveMode ~= eSaveMode_Dont) then
		SaveData()
	end
	LOG(PLUGIN:GetName().." v"..PLUGIN:GetVersion().." is shutting down...")
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
