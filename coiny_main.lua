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
	PLUGIN = Plugin
	PLUGIN:SetName("Coiny")
	PLUGIN:SetVersion(3)	-- cause V-twin is much cooler than v1.
	
	PluginManager = cRoot:Get():GetPluginManager()
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_TICK)
	HANDY = PluginManager:GetPlugin("Handy")
	
	Plugin:AddCommand("/money",			" - shows your coins ammount",											"coiny.base")
	Plugin:AddCommand("/m",				" - shortcut for /money",												"coiny.base")
	Plugin:AddCommand("/money pay",		" (name) (ammount) - you pay to 'name' 'ammount' of your coins",		"coiny.trade")
	Plugin:AddCommand("/money give",	" (name) (ammount) - gives 'name' 'ammount' of coins from air",			"coiny.reward")
	Plugin:AddCommand("/money take",	" (name) (ammount) - takes from 'name' 'ammount' of coins",				"coiny.punish")
	Plugin:AddCommand("/money freeze",	" - freeze/unfreeze your coins ammount, for testing purposes",			"coiny.freeze")
	
	Plugin:BindCommand("/money",	"coiny.base",		HandleMoneyCommand)
	Plugin:BindCommand("/m",		"coiny.base",		HandleMoneyCommand)
	
	--Plugin:AddWebTab("Manage coins", HandleRequest_Coiny)	-- commented due to not being implemented
	
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