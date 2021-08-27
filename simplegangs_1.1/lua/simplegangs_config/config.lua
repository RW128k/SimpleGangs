--[[
SimpleGangs 1.1

Shared general configuration file.

This file houses all the user configurable settings
associated with SimpleGangs.

A detailed guide explaining how to edit this
file can be found in Section 2: Configuration
of the Owners Manual PDF included with your
download.

YOU ARE STRONGLY ADVISED TO READ THE MANUAL BEFORE
EDITING THIS FILE.

If you have any difficulty changing these settings
or require advice or assistance, feel free to
contact me using the details provided in the Owners
Manual.

© RW128k 2021
--]]

SimpleGangs = SimpleGangs or {}


-- GLOBAL UI SETTINGS

SimpleGangs.UITitle = "Gangs"
SimpleGangs.UIGroupName = "Gang"
SimpleGangs.UIBackgroundColor = Color(20, 20, 20, 250)

-- MAIN MENU SETTINGS

SimpleGangs.EnableCommand = true
SimpleGangs.EnableKey = true
SimpleGangs.MenuCommand = "/gangs"
SimpleGangs.MenuKey = KEY_F8

-- ADMIN MENU SETTINGS

SimpleGangs.EnableAdmin = true
SimpleGangs.AdminCommand = "/gangadmin"
SimpleGangs.AdminRanks = {"admin", "superadmin"}

-- LEADERBOARD SETTINGS

SimpleGangs.EnableLeaderboard = true
SimpleGangs.ShowWalletLeaderboard = true
SimpleGangs.ShowOrgLeaderboard = true
SimpleGangs.LeaderboardCommand = "/leaderboard"

-- BANK SETTINGS

SimpleGangs.EnableBank = true
SimpleGangs.BankCurrency = "dollar"

-- CHAT SETTINGS

SimpleGangs.EnableOrgChat = true
SimpleGangs.ReplaceTeamChat = true
SimpleGangs.OrgChatCommand = "/gangchat"

-- FRIENDLY-FIRE SETTINGS

SimpleGangs.DisableFriendlyFire = true
SimpleGangs.PlayFriendlyHitSound = true

-- HUD SETTINGS

SimpleGangs.HUDBackgroundColor = Color(10, 10, 10, 220)
SimpleGangs.HUDAnchor = "topleft"
SimpleGangs.HUDPosX = 10
SimpleGangs.HUDPosY = 10

-- ECONOMY SETTINGS

SimpleGangs.CreateOrgCost = 100



-- The following lines ensure that Lua
-- refresh works correctly and all values
-- get updated properly.
-- DO NOT EDIT THESE LINES!



-- Setup gang article for custom group name
local vowels = {"a", "e", "i", "o", "u"}
SimpleGangs.article = "a"
for _, vowel in ipairs(vowels) do
	if string.StartWith(string.lower(SimpleGangs.UIGroupName), vowel) then
		SimpleGangs.article = "an"
	end
end

-- Setup currency symbol and icon
if CLIENT then
	if SimpleGangs.BankCurrency == "pound" then
		SimpleGangs.guap = Material("simplegangs/money_pound.png")
		SimpleGangs.moneySymbol = "£"
	elseif SimpleGangs.BankCurrency == "euro" then
		SimpleGangs.guap = Material("simplegangs/money_euro.png")
		SimpleGangs.moneySymbol = "€"
	elseif SimpleGangs.BankCurrency == "yen" then
		SimpleGangs.guap = Material("simplegangs/money_yen.png")
		SimpleGangs.moneySymbol = "¥"
	elseif SimpleGangs.BankCurrency == "ruble" then
		SimpleGangs.guap = Material("simplegangs/money_ruble.png")
		SimpleGangs.moneySymbol = "₽"
	else
		SimpleGangs.guap = Material("simplegangs/money_dollar.png")
		SimpleGangs.moneySymbol = "$"
	end
end