--[[
SimpleGangs 1.1

Clientside init file loaded at client startup.
Defines some miscellaneous functions, hooks and
other datatypes such as cached colors and materials.

There are no user editable settings located in
this file.

You should follow the configuration guide within
the Owners Manual PDF included with your download.

Should you wish to edit this file and require
advice or assistance, feel free to contact me using
the details provided in the Owners Manual.

© RW128k 2021
--]]

SimpleGangs = SimpleGangs or {}

MsgC(Color(0, 255, 255), "[SimpleGangs] ", Color(253, 185, 19), "Loading SimpleGangs Version 1.1\n")

local fontFace = "coolvetica"

-- Setup fonts to be used in UI and HUD

-- Window titles
surface.CreateFont("sg_uifontXL", {
font = fontFace,
weight = 0,
outline = true,
size = 50
})

-- Inspect menu target name
surface.CreateFont("sg_uifontL", {
font = fontFace,
weight = 0,
outline = true,
size = 40
})

-- Main labels
surface.CreateFont("sg_uifontM", {
font = fontFace,
weight = 0,
outline = true,
size = 30
})

-- Small labels
surface.CreateFont("sg_uifontS", {
font = fontFace,
weight = 0,
outline = true,
size = 20
})

-- Button titles
surface.CreateFont("sg_uifontButton", {
font = fontFace,
weight = 0,
size = 25
})

-- HUD title
surface.CreateFont("sg_hudheadfont", {
font = fontFace,
extended = false,
weight = 0,
outline = true,
size = 25
})


-- Setup local table for storing members of current gang, bank balance and invites
SimpleGangs.orgs = {
	bank = "0",
	invites = {},
	all = {}
}

-- Cache materials to be used in UI and HUD
SimpleGangs.user = Material("simplegangs/player_icon.png")
SimpleGangs.hp = Material("simplegangs/hp_icon.png")
SimpleGangs.armor = Material("simplegangs/armor_icon.png")
SimpleGangs.job = Material("simplegangs/job_icon.png")

-- Cache colors to be used in UI and HUD
SimpleGangs.color_gold = Color(253, 185, 19, 255)
SimpleGangs.color_health = Color(255, 0, 42, 255)
SimpleGangs.color_armor = Color(49, 95, 244, 255)
SimpleGangs.color_guap = Color(15, 206, 78, 255)

function SimpleGangs:getTimeAgo(epoch)
	-- Function which simply returns a human readable
	-- string of how much time has passed since a
	-- given unix time.
	-- Accepts 1 parameter, epoch, the unix timestamp
	-- as a number to calculate the time difference of.
	-- Splits time into seconds, minutes, hours or
	-- days by converting from seconds and rounding.

	local timeInt = os.time() - epoch
	local timeStr
	if timeInt < 60 then
		if timeInt == 1 then
			timeStr = "1 Second"
		else
			timeStr = timeInt .. " Seconds"
		end
	elseif timeInt < 3600 then
		if math.floor(timeInt / 60) == 1 then
			timeStr = "1 Minute"
		else
			timeStr = math.floor(timeInt / 60) .. " Minutes"
		end
	elseif timeInt < 86400 then
		if math.floor(timeInt / 3600) == 1 then
			timeStr = "1 Hour"
		else
			timeStr = math.floor(timeInt / 3600) .. " Hours"
		end
	else
		if math.floor(timeInt / 86400) == 1 then
			timeStr = "1 Day"
		else
			timeStr = math.floor(timeInt / 86400) .. " Days"
		end				
	end

	return timeStr
end

function SimpleGangs:formatBank(unformatted)
	-- Modified version of the DarkRP.formatMoney
	-- function which accepts a string instead of
	-- a number and does not add a currency symbol.
	-- Accepts 1 parameter, unformatted, the money
	-- value as a string to format.
	-- Inserts commas into the string and correctly
	-- formats decimal places. Used in the main
	-- menu and bank menu for formatting gang bank
	-- balances, as they are stored as strings.

	if tonumber(unformatted) < 1e14 then
	    local dp = string.find(unformatted, "%.") or #unformatted + 1

	    for i = dp - 4, 1, -3 do
	        unformatted = unformatted:sub(1, i) .. "," .. unformatted:sub(i + 1)
	    end

	    if unformatted[#unformatted - 1] == "." then
	        unformatted = unformatted .. "0"
	    end
	end

    return unformatted
end

function SimpleGangs:sepOnline()
	-- Function which simply returns two tables,
	-- seperating online and offline members of
	-- the client's gang.
	-- Accepts no parameters.
	-- Iterates over all members of the client's
	-- gang, adding them to either the online or
	-- offline table based on whether a player
	-- can be found matching their Steam ID.

	local onlineTbl = {}
	local offlineTbl = {}

	for id, data in pairs(self.orgs["all"]) do
		if !player.GetBySteamID64(id) then
			offlineTbl[tostring(id)] = data
		else
			onlineTbl[tostring(id)] = data
		end
	end

	return onlineTbl, offlineTbl
end

function SimpleGangs:checkAdmin(ply)
	-- Function which simply checks if a provided
	-- player is in the admin pool specified in
	-- the configuration file.
	-- Accepts 1 parameter, ply, the player object
	-- of which to check admin status of.
	-- Iterates over all rank names in the admin
	-- pool and returns true if the supplied player
	-- has the rank. If no ranks match, false is
	-- returned.

	for _, rank in ipairs(self.AdminRanks) do
		if ply:GetUserGroup() == rank then return true end
	end
	return false
end

function SimpleGangs:viewProfile(id)
	-- Function which creates a simple window with
	-- a derma HTML panel to display steam profiles.
	-- Accepts 1 parameter, id, a 64 bit Steam ID
	-- of a player whose profile to open.
	-- Creates all the user interface components
	-- and sets the HTML panel's address to the
	-- Steam community page for the given ID.

	-- Get text sizes
	surface.SetFont("sg_uifontM")
	local loadingW, loadingH = surface.GetTextSize("Loading Page...")

    -- Main frame
    local Frame = vgui.Create("DFrame")
    Frame:SetSize(ScrW() >= 1020 and 1000 or ScrW() - 20, ScrH() >= 720 and 700 or ScrH() - 20) 
    Frame:Center()
    Frame:SetTitle("User Profile") 
    Frame:SetVisible(true) 
    Frame:SetDraggable(true)
    Frame:ShowCloseButton(true) 
    Frame:MakePopup()
    Frame.Paint = function(pnl, w, h)
        draw.RoundedBox(2, 0, 0, w, h, self.UIBackgroundColor)
    end
    Frame.OnScreenSizeChanged = function(pnl, oldScrW, oldScrH)
    	pnl.OnClose = function() end
    	pnl:Close()
    end

    -- Loading text (behind HTML panel)
    local loading = vgui.Create("DLabel", Frame)
    loading:SetPos((Frame:GetWide() - loadingW) / 2, (Frame:GetTall() - loadingH) / 2)
    loading:SetFont("sg_uifontM")
    loading:SetText("Loading Page...")
    loading:SetWrap(false)
    loading:SizeToContents()

    -- HTML panel displaying the webpage
	local html = vgui.Create("DHTML", Frame)
	html:Dock(FILL)
	html:OpenURL("https://steamcommunity.com/profiles/" .. id)
end

hook.Add("Think", "orgFirstRun", function()
	-- Gamemode think hook called once when client
	-- has completed login and is ready to
	-- dispatch and receive net messages, then is
	-- removed.
	-- Used instead of initialize hook as net
	-- messages do not work properly when game is
	-- still starting.
	-- First checks if the game is running in
	-- single player mode and warns the user then
	-- makes the inital requests for all necessary
	-- data (members, invites, HUD prefs, bank
	-- balance) and finally removes the hook.

	if game.SinglePlayer() then
		local singleplayerWarn = Derma_Message("Unfortunately, this addon does not support single player mode. Please recreate your game selecting 2 or more players, or upload this addon to a dedicated server.\nThank you for using SimpleGangs.", "SimpleGangs", "OK")
		singleplayerWarn.Paint = function(pnl, w, h)
			draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor)
		end
	end

	net.Start("sg_requestOrgs")
	net.SendToServer()
	net.Start("sg_requestInvites")
	net.SendToServer()
	net.Start("sg_requestHud")
	net.SendToServer()
	net.Start("sg_requestBank")
	net.SendToServer()

	hook.Remove("Think", "orgFirstRun")
end)

hook.Add("OnPlayerChat", "orgCommand", function(ply, msg, isTeam, isDead)
	-- Player chat hook used to register chat
	-- commands.
	-- Checks if a message contains the command
	-- for the main menu, admin menu or
	-- leaderboard, and if their respective menus
	-- have chat command invocation enabled, then
	-- calls their function if the client was
	-- the player who dispatched the message and
	-- suppress it from showing in the chat feed.

	msg = string.lower(msg)

	if (string.StartWith(msg, string.lower(SimpleGangs.MenuCommand) .. " ") or msg == string.lower(SimpleGangs.MenuCommand)) and SimpleGangs.EnableCommand then
		-- Main menu
		if ply == LocalPlayer() then SimpleGangs:orgMenu() end
		return true
	elseif (string.StartWith(msg, string.lower(SimpleGangs.AdminCommand) .. " ") or msg == string.lower(SimpleGangs.AdminCommand)) and SimpleGangs.EnableAdmin then
		-- Admin Menu
		if ply == LocalPlayer() then SimpleGangs:adminMenu() end
		return true
	elseif (string.StartWith(msg, string.lower(SimpleGangs.LeaderboardCommand) .. " ") or msg == string.lower(SimpleGangs.LeaderboardCommand)) and DarkRP != nil and SimpleGangs.EnableLeaderboard then
		-- Leaderboard
		if ply == LocalPlayer() then SimpleGangs:leaderboardMenu() end
		return true
	end
end)

hook.Add("PlayerButtonDown", "orgKeyboard", function(ply, button)
	-- Player keyboard button press hook used to
	-- register hotkeys.
	-- Checks if the pressed key matches the one
	-- specified in the configuration for the main
	-- menu and if keyboard button invocation is
	-- enabled, then calls the main menu if the
	-- client was the player who pressed the button.

	if input.IsKeyDown(SimpleGangs.MenuKey) and SimpleGangs.EnableKey then
		if ply == LocalPlayer() then SimpleGangs:orgMenu() end
	end
end)

net.Receive("sg_orgNotify", function()
	-- Function to handle an incoming notification
	-- from the server.
	-- Accepts a string containing the message
	-- contents.
	-- Adds the message to the screen for 7 seconds
	-- and plays the default notification 'tick'
	-- sound effect.

    local msg = net.ReadString()
    notification.AddLegacy(msg, 0, 7)
    surface.PlaySound("buttons/button15.wav")
end)

net.Receive("sg_orgChat", function()
	-- Function to handle an incoming gang chat
	-- message from the server.
	-- Accepts a table containing strings and
	-- colors to be displayed.
	-- Unpacks and concatenates the provided
	-- table into the chat feed, formatted
	-- with the correct colors.

    local msg = net.ReadTable()
    chat.AddText(unpack(msg))
end)