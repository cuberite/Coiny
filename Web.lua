
-- Web.lua

-- Implements the webadmin tab for managing the players' money





--- Holds the world filter (cWorld) or nil if showing all players
local filterByWorld = nil

-- Local aliases of the functions:
local ins = table.insert
local con = table.concat





--- Returns the HTML code for a single button of the world filter
local function getWorldFilterForm(a_WorldName)
	return "<form method='POST'><input type='submit' name='WorldFilter' value='" .. a_WorldName .. "'></form>"
end





--- Returns the HTML code of the table row for the specified player
local function getPlayerRow(a_Idx, a_PlayerName)
	local res = {"<tr><td>"}
	ins(res, tostring(a_Idx))
	ins(res, "</td><td>")
	ins(res, a_PlayerName)
	ins(res, "</td><td>")
	ins(res, "<form method='POST'><input type='hidden' name='PlayerName' value='")
	ins(res, a_PlayerName)
	ins(res, "'><input type='text' name='Balance' value='")
	ins(res, tostring(getBalanceByName(a_PlayerName) or 0))
	ins(res, "'><input type='submit' name='SetPlayerMoney' value='Update'></form></td></tr>")
	return con(res, "")
end





--- Returns the complete HTML table of all shown players
-- Takes into account world filtering
local function composePlayersList(inFromRoot)
	-- Make a list of displayed players:
	local playerNames = {}
	local addPlayerToTable = function(a_CBPlayer)
		table.insert(playerNames, a_CBPlayer:GetName())
	end
	if (filterByWorld) then
		filterByWorld:ForEachPlayer(addPlayerToTable)
	else
		cRoot:Get():ForEachPlayer(addPlayerToTable)
	end

	-- Compose the table:
	local playerContent
	if (playerNames[1] == nil) then
		-- No players
		playerContent = { "<tr><td>No connected players</td></tr>" }
	else
		-- List each player:
		playerContent = {}
		table.sort(playerNames)
		for idx, name in ipairs(playerNames) do
			ins(playerContent, getPlayerRow(idx, name))
		end
	end
	
	return "<table>" .. con(playerContent, "") .. "</table><br/>"
end





--- Generates the entire HTML contents of the web tab
local function generateContent()
	local content = {}
	
	-- World filter:
	if (filterByWorld) then
		ins(content, "<h4>World filter: ")
		ins(content, filterByWorld:GetName())
		ins(content, "</h4>")
		ins(content, "<form method='POST'><input type='submit' name='DisableFilter' value='Disable filter'></form><br/>")
	else
		-- Collect names of all worlds:
		local worldNames = {}
		cRoot:Get():ForEachWorld(
			function(a_CBWorld)
				ins(worldNames, a_CBWorld:GetName())
			end
		)
		
		-- Only show the world filter if there are multiple worlds
		if (worldNames[2] ~= nil) then
			table.sort(worldNames)
			ins(content, "<h4>World filter</h4><table><tr>")
			for _, name in ipairs(worldNames) do
				ins(content, getWorldFilterForm(name))
			end
			ins(content, "</tr></table><br/>")
		end
	end
	
	-- List of players:
	ins(content, "<h4>Players:</h4>")
	ins(content, composePlayersList())
	return con(content, "")
end





--- Handles the webadmin request
function HandleRequest_Manage(a_Request)
	-- Process requests:
	if (a_Request.PostParams["DisableFilter"] ~= nil) then
		filterByWorld = nil
	end
	if (a_Request.PostParams["WorldFilter"] ~= nil) then
		filterByWorld = cRoot:Get():GetWorld(a_Request.PostParams["WorldFilter"])
	end
	
	if (a_Request.PostParams["SetPlayerMoney"] ~= nil) then
		local playerName = a_Request.PostParams["PlayerName"]
		local curBalance = getBalanceByName(playerName)
		local newBalance = tonumber(a_Request.PostParams["Balance"])
		if (curBalance < newBalance) then
			addMoneyByName(playerName, newBalance - curBalance, "Adjusted by webadmin", "webadmin")
		else
			removeMoneyByName(playerName, curBalance - newBalance, "Adjusted by webadmin", "webadmin")
		end
	end
	
	-- Generate content:
	return generateContent()
end





