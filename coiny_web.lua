--[[
WARNING!
Web interface is not implemented yet!
]]
local function AddPlayerButtons( inName )
	local playerBalance = GetMoney( inName )
	local result = "<form method='POST'><input type='hidden' name='PlayerName' value='"..inName.."'><input type='text' name='Balance' value='"..playerBalance.."'>"
	result = result.."<input type='submit' name='SetPlayerMoney' value='Update'></form>"
	return result
end

local function AddWorldButton( inName )
	return "<form method='POST'><input type='submit' name='WorldFilter' value='"..inName.."'></form>"
end

FilterByWorld = false
FilterWorld = cRoot:Get():GetDefaultWorld()

function HandleRequest_Manage( inRequest )
					-- Processing request
	--------------------------------------------------------------------------------------------------
	if( inRequest.PostParams["DisableFilter"] ~= nil ) then
		FilterByWorld = false
	end
	if( inRequest.PostParams["WorldFilter"] ~= nil ) then
		FilterByWorld = true
		FilterWorld = cRoot:Get():GetWorld( inRequest.PostParams["WorldFilter"] )
	end
	
	if( inRequest.PostParams["SetPlayerMoney"] ~= nil ) then
		SetMoney( inRequest.PostParams["PlayerName"], tonumber( inRequest.PostParams["Balance"] ) )
	end
					-- Generating content
	--------------------------------------------------------------------------------------------------
	local response = GenerateContent()
	return response
end

function GenerateContent()
	local content = ""
	-- World filter content
	if( FilterByWorld ) then
		if( FilterWorld == nil ) then
			content = content.."<h4>Incorrect world filter "
			content = content.."<form method='POST'><input type='submit' name='DisableFilter' value='Disable filter'></form>"
			content = content.."</h4>"
		else
			content = content.."<h4>World filter: "..FilterWorld:GetName()
			content = content.."<form method='POST'><input type='submit' name='DisableFilter' value='Disable filter'></form>"
			content = content.."</h4>"
		end
	else
		local worldCount = 0
		local AddWorldToTable = function( inWorld )
			worldCount = worldCount + 1
			content = content.."<td>"..AddWorldButton( inWorld:GetName() ).."</td>"
		end
		
		content = content.."<h4>World filter</h4>"
		content = content.."<table><tr>"
		cRoot:Get():ForEachWorld( AddWorldToTable )
		if( worldCount == 0 ) then
			content = content.."<td>No worlds! O_O</td>"
		end
		content = content.."</tr></table>"
		content = content.."<br>"
	end
	
	-- Players content
	content = content.."<h4>Players:</h4>"
	if( FilterByWorld ) then
		if( FilterWorld == nil ) then
			content = content..ComposePlayersList( true )
		else
			content = content..ComposePlayersList( false )
		end
	else
		content = content..ComposePlayersList( true )
	end
	return content
end

function ComposePlayersList( inFromRoot )
	local playersContent = "<table>"
	local PlayerNum = 0
	local AddPlayerToTable = function( Player )
		PlayerNum = PlayerNum + 1
		playersContent = playersContent.."<tr>"
		playersContent = playersContent.."<td style='width: 10px;'>"..PlayerNum..".</td>"
		playersContent = playersContent.."<td>"..Player:GetName().."</td>"
		playersContent = playersContent.."<td>"..AddPlayerButtons( Player:GetName() ).."</td>"
		playersContent = playersContent.."</tr>"
	end
	
	if( inFromRoot ) then
		cRoot:Get():ForEachPlayer( AddPlayerToTable )
	else
		WorldFilter:ForEachPlayer( AddPlayerToTable )
	end
	if( PlayerNum == 0 ) then
		playersContent = playersContent.."<tr><td>No connected players</td></tr>"
	end
	playersContent = playersContent.."</table>"
	playersContent = playersContent.."<br>"
	return playersContent
end





