--[[
SimpleGangs 1.1

Serverside init file loaded at server startup.
Defines some miscellaneous functions and hooks,
as well as loading gang data into memory.

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

-- Setup local tables for storing member & gang data
SimpleGangs.orgs = {}
SimpleGangs.invites = {}
SimpleGangs.huds = {}
SimpleGangs.banks = {}

function SimpleGangs:numMembers(orgName)
	-- Function which simply gets the number of
	-- members in a gang.
	-- Accepts 1 parameter, orgname, the name of
	-- the gang.
	-- Iterates over all member records and adds
	-- to the counter when the provided gang name
	-- is found. Returns the counter value.

	local members = 0

	for _, data in pairs(self.orgs) do
		if data[2] == orgName then
			members = members + 1
		end
	end

	return members
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

-- Create tables in the database if they do not already exist
SimpleGangs:orgDBQuery("CREATE TABLE IF NOT EXISTS sg_orgs (name TEXT, steamid64 BIGINT, org TEXT, owner INT, offline BIGINT)")
SimpleGangs:orgDBQuery("CREATE TABLE IF NOT EXISTS sg_invites (name TEXT, sender BIGINT, recipient BIGINT, org TEXT)")
SimpleGangs:orgDBQuery("CREATE TABLE IF NOT EXISTS sg_hud (steamid64 BIGINT, enable INT)")
SimpleGangs:orgDBQuery("CREATE TABLE IF NOT EXISTS sg_bank (org TEXT, money BIGINT)")

-- Store member records from database in local table
SimpleGangs:orgDBQuery("SELECT name, CAST(steamid64 AS CHAR) AS steamid64, org, CAST(owner AS CHAR) AS owner, offline FROM sg_orgs", function(rawOrgs)
	if rawOrgs != nil and rawOrgs != false then
		for _, record in pairs(rawOrgs) do
			SimpleGangs.orgs[record["steamid64"]] = {record["name"], record["org"], record["owner"], record["offline"]}
		end

		-- Send gang data to all online members (Upon Lua refresh)
		for _, ply in ipairs(player.GetAll()) do SimpleGangs:sendOrgs(ply) end		
	end
end)

-- Store invite records from database in local table
SimpleGangs:orgDBQuery("SELECT name, CAST(sender AS CHAR) AS sender, CAST(recipient AS CHAR) AS recipient, org FROM sg_invites", function(rawInvs)
	if rawInvs != nil and rawInvs != false then
		for _, record in pairs(rawInvs) do
			if SimpleGangs.invites[record["recipient"]] == nil then
				SimpleGangs.invites[record["recipient"]] = {}
			end
			SimpleGangs.invites[record["recipient"]][record["sender"]] = {record["name"], record["org"]}
		end

		-- Send invites to all online members (Upon Lua refresh)
		for _, ply in ipairs(player.GetAll()) do SimpleGangs:sendInvites(ply) end
	end
end)

-- Store HUD preferences from database in local table
SimpleGangs:orgDBQuery("SELECT CAST(steamid64 AS CHAR) AS steamid64, enable FROM sg_hud", function(rawHuds)
	if rawHuds != nil and rawHuds != false then
		for _, record in pairs(rawHuds) do
			SimpleGangs.huds[record["steamid64"]] = tonumber(record["enable"])
		end

		-- Send HUD preferences to all online members (Upon Lua refresh)
		for _, ply in ipairs(player.GetAll()) do SimpleGangs:sendHud(ply) end
	end
end)

-- Store gang bank balances from database in local table
SimpleGangs:orgDBQuery("SELECT * FROM sg_bank", function(rawBank)
	if rawBank != nil and rawBank != false then
		for _, record in pairs(rawBank) do
			SimpleGangs.banks[record["org"]] = tonumber(record["money"])
		end

		-- Send gang bank balances to all online members (Upon Lua refresh)
		for _, ply in ipairs(player.GetAll()) do SimpleGangs:sendBank(ply) end
	end
end)

hook.Add("Initialize", "disableTeamTalk", function()
	-- Gamemode initialize hook called on startup.
	-- If gang chat is enabled and set to replace
	-- team chat, disable DarkRP group chat command
	-- which overrides it. (Only on DarkRP servers)
	if DarkRP != nil and SimpleGangs.ReplaceTeamChat and SimpleGangs.EnableOrgChat then
		DarkRP.removeChatCommand("g")
	end
end)

hook.Add("PlayerShouldTakeDamage", "orgDmg", function(ply, dmgEnt)
	-- Player damage hook called when a player loses
	-- health points.
	-- If the entity inflicting damage to the player
	-- is another player in the same gang, play the
	-- hurt sound effect if it is enabled in the
	-- configuration and suppress the damage if
	-- friendly fire is disabled.

	if dmgEnt:IsPlayer() and SimpleGangs.orgs[dmgEnt:SteamID64()] != nil and SimpleGangs.orgs[ply:SteamID64()] != nil and SimpleGangs.orgs[ply:SteamID64()][2] == SimpleGangs.orgs[dmgEnt:SteamID64()][2] and ply != dmgEnt then
		if SimpleGangs.PlayFriendlyHitSound then ply:EmitSound("vo/npc/male01/pain0" .. math.random(1, 9) .. ".wav") end
		if SimpleGangs.DisableFriendlyFire then return false end
	end
end)

hook.Add("PlayerDisconnected", "orgDisconnect", function(ply, dmgEnt)
	-- Player disconnect hook called when a player
	-- leaves the server.
	-- If the player who has left is a member of a
	-- gang, update their last online timestamp
	-- with the current unix time both locally and
	-- on the database, and send gang data to all
	-- online members of their gang to refresh
	-- user interfaces.

	if SimpleGangs.orgs[ply:SteamID64()] != nil then
		SimpleGangs.orgs[ply:SteamID64()][4] = math.floor(os.time())
		SimpleGangs:orgDBQuery("UPDATE sg_orgs SET offline = " .. math.floor(os.time()) .. " WHERE steamid64 = '" .. ply:SteamID64() .."'")
		SimpleGangs:sendOrgs(ply)
	end
end)

hook.Add("onPlayerChangedName", "orgChangename", function(ply, old, new)
	-- DarkRP change nickname hook called when a
	-- player updates their in-game name.
	-- If the player who has changed their name
	-- is a member of a gang, update the name
	-- value both locally and on the database,
	-- and send gang data & invites to all
	-- affected players to refresh user interfaces.

	if SimpleGangs.orgs[ply:SteamID64()] != nil then
		SimpleGangs.orgs[ply:SteamID64()][1] = new
		SimpleGangs:orgDBQuery("UPDATE sg_orgs SET name = '" .. new .. "' WHERE steamid64 = '" .. ply:SteamID64() .."'")
		SimpleGangs:sendOrgs(ply)
		SimpleGangs:distributeInvites()
	end
end)