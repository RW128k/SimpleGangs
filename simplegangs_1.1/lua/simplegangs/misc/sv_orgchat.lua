--[[
SimpleGangs 1.1

Serverside Gang Chat handling file. Sets up a hook
to listen for player chats and intercepts those
which are Teamtalk and prefixed according to the
configuration.

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

-- Precache netmessages
util.AddNetworkString("sg_orgChat")

local function sendChat(ply, txt)
	-- Helper function called by PlayerSay hook
	-- below to dispatch gang chat messages.
	-- Accepts 2 parameters: ply, the player object
	-- which is sending the message, txt, the
	-- message contents.
	-- Sends error message if player is not in a
	-- gang, otherwise creates a table of online
	-- clients to send to, formats the message and
	-- sends to all players in the table.

	if SimpleGangs.orgs[ply:SteamID64()] == nil then
		-- Send error to ply if not in a gang
		net.Start("sg_orgChat")
		net.WriteTable({Color(255, 0, 0), "You must first join " .. SimpleGangs.article .. " " .. SimpleGangs.UIGroupName .. " before using " .. SimpleGangs.UIGroupName .. " Chat!" .. (SimpleGangs.EnableCommand and ("\nType " .. SimpleGangs.MenuCommand .. " in chat to open the Menu") or "")})
		net.Send(ply)
	else
		-- Send message to ply's gang
		local sendTo = {}
		for _, onlinePlayer in ipairs(player.GetAll()) do
			if SimpleGangs.orgs[onlinePlayer:SteamID64()] != nil and SimpleGangs.orgs[onlinePlayer:SteamID64()][2] == SimpleGangs.orgs[ply:SteamID64()][2] then
				table.insert(sendTo, onlinePlayer)
			end
		end
		net.Start("sg_orgChat")
		net.WriteTable({Color(255, 223, 0), "<" .. SimpleGangs.UIGroupName .. "> ", DarkRP != nil and ColorAlpha(ply:getJobTable()["color"], 255) or Color(50, 205, 50), ply:Nick(), ": ", Color(255, 255, 255), txt})
		net.Send(sendTo)			
	end
end

hook.Add("PlayerSay", "orgChat", function(ply, text, isTeam)
	-- Function to handle incoming player chat
	-- messages and extract those which are gang
	-- chats.
	-- Checks if message is teamtalk, replace chat
	-- and gang chat are enabled or if the gang chat
	-- command was used and if gang chat is enabled
	-- and message is not team then calls above
	-- function.

	if isTeam and SimpleGangs.ReplaceTeamChat and SimpleGangs.EnableOrgChat then
		-- Replace teamtalk feature
		sendChat(ply, text)
		return "" -- Return empty string or DarkRP complains
	elseif !isTeam and SimpleGangs.EnableOrgChat and (string.StartWith(string.lower(text), string.lower(SimpleGangs.OrgChatCommand) .. " ") or string.lower(text) == string.lower(SimpleGangs.OrgChatCommand)) then
		-- Chat command feature
		text = string.Trim(string.sub(text, string.len(SimpleGangs.OrgChatCommand) + 1))
		if text != "" then sendChat(ply, text) end
		return "" -- Return empty string or DarkRP complains
	end
end)