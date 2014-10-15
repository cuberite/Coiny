
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
			Handler = handleMoneyBalance,
			Subcommands =
			{
				["balance"] =
				{
					HelpString = "Shows your balance",
					Alias = "show",
					Handler = handleMoneyBalance,
				},  -- balance
				
				["give"] =
				{
					HelpString = "Adds money to the player's account",
					Permission = "coiny.admin.give",
					Alias = "add",
					Handler = handleMoneyGive,
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
					Handler = handleMoneyRemove,
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
					Handler = handleMoneyTransfer,
					ParameterCombinations =
					{
						{
							Params = "Player Amount [Message]",
							Help = "Transfers Amount money from your account to Player, with the optional Message stored in the transaction log",
						}
					}
				},  -- transfer
			}  -- Subcommands
		}  -- "/money"
	},  -- Commands
	
	ConsoleCommands =
	{
		money =
		{
			Subcommands =
			{
				balance =
				{
					HelpString = "Show a player's account balance",
					Handler = handleConsoleMoneyBalance,
					ParameterCombinations =
					{
						{
							Params = "Player",
							Help = "Shows the account balance for the specified player",
						}
					}
				},  -- balance
				
				give =
				{
					HelpString = "Adds money to the player's account",
					Alias = "add",
					Handler = handleConsoleMoneyGive,
					ParameterCombinations =
					{
						{
							Params = "Player Amount [Message]",
							Help = "Adds Amount money to Player, with the optional Message stored in the transaction log",
						}
					}
				},  -- give
				
				remove =
				{
					HelpString = "Removes money from the player's account",
					Alias = "take",
					Handler = handleConsoleMoneyRemove,
					ParameterCombinations =
					{
						{
							Params = "Player Amount [Message]",
							Help = "Removes Amount money from Player, with the optional Message stored in the transactino log",
						}
					}
				},  -- remove
				
				transfer =
				{
					HelpString = "Transfers money from one player's account to another's",
					Alias = "take",
					Handler = handleConsoleMoneyTransfer,
					ParameterCombinations =
					{
						{
							Params = "SrcPlayer DstPlayer Amount [Message]",
							Help = "Transfers Amount money from SrcPlayer to DstPlayer, with the optional Message stored in the transactino log",
						}
					}
				},  -- transfer
			}  -- Subcommands
		}  -- money
	}  -- ConsoleCommands
}




