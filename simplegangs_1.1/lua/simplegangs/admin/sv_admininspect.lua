--[[
SimpleGangs 1.1

Serverside Administration Console Inspect window
file. Handles all admin actions for gangs and
members such as kicking, renaming, promoting etc.
Also provides the data to populate the window.

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
util.AddNetworkString("sg_adminOrgSearch")
util.AddNetworkString("sg_adminOrgReply")
util.AddNetworkString("sg_adminPromoteDemote")
util.AddNetworkString("sg_adminKick")
util.AddNetworkString("sg_adminDelete")
util.AddNetworkString("sg_adminRename")
util.AddNetworkString("sg_adminBank")
util.AddNetworkString("sg_adminJoin")

net.Receive("sg_adminOrgSearch", function(len, ply)
	-- Function to handle requests by admins for details
	-- about a specific gang or member with a specifed
	-- section (page) of gang members.
	-- Accepts the 64 bit Steam ID of a member to inspect,
	-- a case sensitive gang name, and a page number which
	-- is an unsigned integer.
	-- Constructs a list of gang members, which is then
	-- sliced to provide the requested page. This list
	-- is added alongside other processed information
	-- to a table which is then sent to the client.

	local searchPlayerIn = net.ReadString()
	local searchOrgIn = net.ReadString()
	local searchPageIn = net.ReadUInt(20)

	if !SimpleGangs.EnableAdmin or !SimpleGangs:checkAdmin(ply) then return end

	-- Extract gang name
	local orgName
	if searchOrgIn == "" then
		if SimpleGangs.orgs[searchPlayerIn] == nil then
			orgName = ""
		else
			orgName = SimpleGangs.orgs[searchPlayerIn][2]
		end
	else
		orgName = searchOrgIn
	end

	-- Find gang members
	local matches = {}
	for id, data in pairs(SimpleGangs.orgs) do
		if data[2] == orgName then
			matches[id] = data
		end
	end

	-- Find gang bank balance
	local plyBank
	if SimpleGangs.banks[orgName] == nil then
		plyBank = 0
	else
		plyBank = SimpleGangs.banks[orgName]
	end

	-- Construct reply table
	local replyTable = {
		page = searchPageIn,
		pages = math.ceil(table.Count(matches) / 20),
		orgSize = table.Count(matches),
		orgBank = plyBank,
		searchResults = {}
	}

	-- Round out of range page number
	if replyTable["page"] > replyTable["pages"] then
		replyTable["page"] = replyTable["pages"]
	end

	-- Add player / gang name and data based off search type
	if searchOrgIn == "" then
		replyTable["searchPlayer"] = searchPlayerIn
		replyTable["playerData"] = SimpleGangs.orgs[replyTable["searchPlayer"]]
	else
		replyTable["searchOrg"] = searchOrgIn
	end

	-- Slice table to page
	local counter = 1
	for id, data in pairs(matches) do
		if counter > (replyTable["page"] - 1) * 20 and counter <= replyTable["page"] * 20 then
			replyTable["searchResults"][id] = data
		end
		counter = counter + 1
	end

	-- Send to client
	net.Start("sg_adminOrgReply")
	net.WriteTable(replyTable)
	net.Send(ply)
end)

net.Receive("sg_adminPromoteDemote", function(len, ply)
	-- Function to handle promotion and demotion requests
	-- of gang members by admins.
	-- Accepts a boolean depicting whether to promote or
	-- demote the target, and their 64 bit Steam ID
	-- handled by the inspect menu.
	-- Checks client has permissions and is valid,
	-- notifies online gang members, updates the rank
	-- locally and on the database and distributes gang
	-- data to all online members.

	local isPromote = net.ReadBool()
	local id = net.ReadString()

	if IsValid(ply) and SimpleGangs.orgs[id] != nil and SimpleGangs.EnableAdmin and SimpleGangs:checkAdmin(ply) then
		if isPromote then
			SimpleGangs:sendNotify(SimpleGangs.orgs[id][1] .. " Has been promoted to " .. SimpleGangs.UIGroupName .. " Owner!", SimpleGangs.orgs[id][2])
			SimpleGangs.orgs[id][3] = "1"
			SimpleGangs:orgDBQuery("UPDATE sg_orgs SET owner = 1 WHERE steamid64 = '" .. id .."'")
		else
			SimpleGangs:sendNotify(SimpleGangs.orgs[id][1] .. " Has been demoted to " .. SimpleGangs.UIGroupName .. " Member!", SimpleGangs.orgs[id][2])
			SimpleGangs.orgs[id][3] = "0"
			SimpleGangs:orgDBQuery("UPDATE sg_orgs SET owner = 0 WHERE steamid64 = '" .. id .."'")
		end
		SimpleGangs:sendOrgs(nil, SimpleGangs.orgs[id][2])
	end
end)

net.Receive("sg_adminKick", function(len, ply)
	-- Function to handle ejection requests of gang
	-- members by admins.
	-- Accepts the 64 bit Steam ID of the target,
	-- handled by the inspect menu.
	-- Checks client has permissions and is valid,
	-- notifies online gang members, updates the target's
	-- gang status locally and on the database and
	-- distributes relevant data to appropriate clients.

	local id = net.ReadString()

	if IsValid(ply) and SimpleGangs.orgs[id] != nil and SimpleGangs.EnableAdmin and SimpleGangs:checkAdmin(ply) then
		local targetOrg = SimpleGangs.orgs[id][2]
		SimpleGangs:sendNotify(SimpleGangs.orgs[id][1] .. " Has been kicked from the " .. SimpleGangs.UIGroupName .. "!", targetOrg)
		SimpleGangs.orgs[id] = nil
		SimpleGangs:orgDBQuery("DELETE FROM sg_orgs WHERE steamid64 = '" .. id .. "'")
		SimpleGangs:sendOrgs(nil, targetOrg)
		if player.GetBySteamID64(id) != false then
			SimpleGangs:sendOrgs(player.GetBySteamID64(id))
			SimpleGangs:sendBank(player.GetBySteamID64(id))
		end
		SimpleGangs:distributeInvites()
	end
end)

net.Receive("sg_adminDelete", function(len, ply)
	-- Function to handle deletion requests of entire
	-- gangs by admins.
	-- Accepts the case sensitive gang name, handled by
	-- the inspect menu.
	-- Checks client has permissions and is valid,
	-- iterates over all members and deletes records
	-- which are members of provided gang locally and on
	-- the database and distributes relevant data to
	-- appropriate clients.

	local org = net.ReadString()

	if IsValid(ply) and SimpleGangs.EnableAdmin and SimpleGangs:checkAdmin(ply) then
		for id, data in pairs(SimpleGangs.orgs) do
			if data[2] == org then
				SimpleGangs.orgs[id] = nil
				if player.GetBySteamID64(id) != false then
					SimpleGangs:sendOrgs(player.GetBySteamID64(id))
					SimpleGangs:sendBank(player.GetBySteamID64(id))
				end
			end
		end
		SimpleGangs:orgDBQuery("DELETE FROM sg_orgs WHERE org = '" .. org .. "'")
		SimpleGangs:distributeInvites()
	end
end)

net.Receive("sg_adminRename", function(len, ply)
	-- Function to handle rename requests of entire
	-- gangs by admins.
	-- Accepts the case sensitive old gang name, handled by
	-- the inspect menu, and the case sensitive new gang
	-- name, handled by the rename querybox.
	-- Checks client has permissions and is valid,
	-- iterates over all members and updates record's gang
	-- name for all which are members of provided gang locally
	-- and on the database and distributes relevant data to
	-- appropriate clients.

	local old = net.ReadString()
	local new = net.ReadString()

	if IsValid(ply) and new != "" and string.len(new) <= 25 and SimpleGangs.EnableAdmin and SimpleGangs:checkAdmin(ply) then
		for id, data in pairs(SimpleGangs.orgs) do
			if data[2] == old then
				SimpleGangs.orgs[id][2] = new
			end
		end

		SimpleGangs.banks[new] = SimpleGangs.banks[old]
		SimpleGangs.banks[old] = nil

		for recipient, items in pairs(SimpleGangs.invites) do
			for sender, data in pairs(items) do
				if data[2] == old then
					SimpleGangs.invites[recipient][sender][2] = new
				end
			end
		end

		SimpleGangs:orgDBQuery("UPDATE sg_orgs SET org = '" .. new .. "' WHERE org = '" .. old .."'")
		SimpleGangs:orgDBQuery("DELETE FROM sg_bank WHERE org = '" .. new .. "'")
		SimpleGangs:orgDBQuery("UPDATE sg_bank SET org = '" .. new .. "' WHERE org = '" .. old .."'")
		SimpleGangs:orgDBQuery("UPDATE sg_invites SET org = '" .. new .. "' WHERE org = '" .. old .."'")
		SimpleGangs:sendOrgs(nil, new)
		SimpleGangs:sendBank(nil, new)
		SimpleGangs:distributeInvites()
	end
end)

net.Receive("sg_adminBank", function(len, ply)
	-- Function to handle requests to update gang bank
	-- balance by admins.
	-- Accepts the case sensitive gang name to modify,
	-- handled by the inspect menu, and the new balance,
	-- handled by the balance querybox.
	-- Checks client has permissions and is valid as well
	-- as the new balance, updates value locally and on the
	-- database and distributes bank value to all online
	-- members.

	local org = net.ReadString()
	local balance = tonumber(net.ReadString())

	if IsValid(ply) and SimpleGangs:numMembers(org) != 0 and balance != nil and balance >= 0 and SimpleGangs.EnableBank and SimpleGangs.EnableAdmin and SimpleGangs:checkAdmin(ply) then
		SimpleGangs.banks[org] = balance
		SimpleGangs:orgDBQuery("DELETE FROM sg_bank WHERE org = '" .. org .. "'")
		SimpleGangs:orgDBQuery("INSERT INTO sg_bank VALUES ('" .. org .. "', " .. balance .. ")")
		SimpleGangs:sendBank(nil, org)
	end
end)

net.Receive("sg_adminJoin", function(len, ply)
	-- Function to handle requests from admins to join
	-- a specified gang.
	-- Accepts the case sensitive gang name to join,
	-- handled by the inspect menu.
	-- Checks client has permissions and is valid,
	-- updates their gang status locally and on the
	-- database, notifies online gang members and
	-- distributes data to all affected clients.

	local org = net.ReadString()

	if IsValid(ply) and SimpleGangs.EnableAdmin and SimpleGangs:checkAdmin(ply) then
		local oldOrgName
		if SimpleGangs.orgs[ply:SteamID64()] != nil then
			oldOrgName = SimpleGangs.orgs[ply:SteamID64()][2]
		end
		SimpleGangs.orgs[ply:SteamID64()] = {ply:Nick(), org, "1", math.floor(os.time())}
		SimpleGangs:sendNotify(ply:Nick() .. " Has joined your " .. SimpleGangs.UIGroupName .. "!", org, ply)

		SimpleGangs:orgDBQuery("DELETE FROM sg_orgs WHERE steamid64 = '" .. ply:SteamID64() .. "'")
		SimpleGangs:orgDBQuery("INSERT INTO sg_orgs VALUES ('" .. ply:Nick() .. "', ".. ply:SteamID64() .. ", '" .. org .. "', 1, " .. math.floor(os.time()) .. ")")
		SimpleGangs:sendOrgs(ply)
		if oldOrgName != nil then SimpleGangs:sendOrgs(nil, oldOrgName) end
		SimpleGangs:sendBank(ply)
	end
end)