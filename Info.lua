
-- Info.lua

-- Implements the g_PluginInfo standard plugin description





g_PluginInfo = 
{
	Name = "Coiny",
	Date = "2014-10-04",
	Description =
[[
Provides the base for all economy plugins by implementing accounts for player's currency, and transactions
over those accounts. Other plugins use this to implement money-based services in the minecraft server.
]],

	Commands =
	{
		["/money"] =
		{
			HelpString = "Shows your balance",
			Alias = "m",
			Handler = HandleMoneyBalance,
			Subcommands =
			{
				["balance"] =
				{
					HelpString = "Shows your balance",
					Alias = "show",
					Handler = HandleMoneyBalance,
				},  -- balance
				
				["give"] =
				{
					HelpString = "Adds money to the player's account",
					Permission = "coiny.admin.give",
					Handler = HandleMoneyGive,
					ParameterCombinations =
					{
						{
							Params = "Player Amount [Message]",
							Help = "Adds Amount money to Player, with the optional Message stored in the transaction log",
						}
					}
				},  -- give
				
				["remove"] =
				{
					HelpString = "Removes money from the player's account",
					Permission = "coiny.admin.take",
					Alias = "take",
					Handler = HandleMoneyRemove,
					ParameterCombinations =
					{
						{
							Params = "Player Amount [Message]",
							Help = "Removes Amount money from Player, with the optional Message stored in the transactino log",
						}
					}
				},  -- remove
				
				["transfer"] =
				{
					HelpString = "Transfers money from you to another player",
					Alias = "pay",
					Permission = "coiny.user.transfer",
					Handler = HandleMoneyTransfer,
					ParameterCombinations =
					{
						{
							Params = "Player Amount [Message]",
							Help = "Transfers Amount money from your account to Player, with the optional Message stored in the transaction log",
						}
					}
				},  -- transfer
			}  -- Subcommands
		}  -- "money"
	}  -- Commands
}




