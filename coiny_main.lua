

-- Global variables
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





