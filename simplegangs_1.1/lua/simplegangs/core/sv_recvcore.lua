--[[
SimpleGangs 1.1

Serverside Core receiving file. Handles all of the
basic gang actions such as creation, leaving,
invites etc.

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
util.AddNetworkString("sg_requestOnline")
util.AddNetworkString("sg_requestOrgs")
util.AddNetworkString("sg_requestInvites")
util.AddNetworkString("sg_requestHud")
util.AddNetworkString("sg_requestBank")
util.AddNetworkString("sg_leaveOrg")
util.AddNetworkString("sg_createOrg")
util.AddNetworkString("sg_acceptInv")
util.AddNetworkString("sg_declineInv")
util.AddNetworkString("sg_promoteUser")
util.AddNetworkString("sg_kickUser")
util.AddNetworkString("sg_inviteUser")
util.AddNetworkString("sg_changeHud")
util.AddNetworkString("sg_orgMsgbox")
util.AddNetworkString("sg_replyOnline")

local function sendMsgbox(msg, title, ply)
	-- Function which simply sends client a title and
	-- a message for constructing a messagebox.
	-- Called by the create gang handler to inform user
	-- whether the specified gang name already exists
	-- or if creation was successful.

	net.Start("sg_orgMsgbox")
	net.WriteString(msg)
	net.WriteString(title)
	net.Send(ply)	
end

net.Receive("sg_leaveOrg", function(len, ply)
	-- Function to handle client requests to leave
	-- current gang. 
	-- Does not accept any data.
	-- Checks client is in a gang, notifies remaining
	-- members, deletes from local storage and database,
	-- distributes data to affected members.

	if IsValid(ply) and SimpleGangs.orgs[ply:SteamID64()] != nil then
		local oldOrgName = SimpleGangs.orgs[ply:SteamID64()][2]
		SimpleGangs:sendNotify(ply:Nick() .. " Has left your " .. SimpleGangs.UIGroupName .. "!", SimpleGangs.orgs[ply:SteamID64()][2], ply)
		SimpleGangs.orgs[ply:SteamID64()] = nil
		SimpleGangs:orgDBQuery("DELETE FROM sg_orgs WHERE steamid64='" .. ply:SteamID64() .. "'")
		SimpleGangs:sendOrgs(ply)
		SimpleGangs:sendOrgs(nil, oldOrgName)
		SimpleGangs:distributeInvites()
		SimpleGangs:sendBank(ply)
	end
end)

net.Receive("sg_createOrg", function(len, ply)
	-- Function to handle client requests to create
	-- a new gang.
	-- Accepts new gang name input from querybox.
	-- Checks client is not in a gang and new name is
	-- valid, subtracts money if DarkRP and cost is
	-- configured, deletes old bank value and invites
	-- (if applicable), updates all affected clients
	-- and sends appropriate message box.

	local orgName = sql.SQLStr(string.Trim(net.ReadString()), true)
	if IsValid(ply) and SimpleGangs.orgs[ply:SteamID64()] == nil and orgName != "" and string.len(orgName) <= 25 then
		if DarkRP != nil and ply:getDarkRPVar("money") < SimpleGangs.CreateOrgCost then return end

		if SimpleGangs:numMembers(orgName) != 0 then
			sendMsgbox(SimpleGangs.UIGroupName .. " name already exists! Please choose another.", "Error", ply)
		else
			if DarkRP != nil then ply:addMoney(-SimpleGangs.CreateOrgCost) end
			SimpleGangs.orgs[ply:SteamID64()] = {ply:Nick(), orgName, "1", math.floor(os.time())}
			SimpleGangs.banks[orgName] = nil
			for recipient, items in pairs(SimpleGangs.invites) do
				for sender, data in pairs(items) do
					if data[2] == orgName then
						SimpleGangs.invites[recipient][sender] = nil
					end
				end
			end
			SimpleGangs:orgDBQuery("INSERT INTO sg_orgs VALUES ('" .. ply:Nick() .. "', ".. ply:SteamID64() .. ", '" .. orgName .. "', 1, ".. math.floor(os.time()) .. ")")
			SimpleGangs:orgDBQuery("DELETE FROM sg_bank WHERE org = '" .. orgName .. "'")
			SimpleGangs:orgDBQuery("DELETE FROM sg_invites WHERE org = '" .. orgName .. "'")
			SimpleGangs:sendOrgs(ply)
			SimpleGangs:sendBank(ply)
			SimpleGangs:distributeInvites()
			sendMsgbox("You have created the " .. SimpleGangs.UIGroupName .. " '" .. orgName .. "'!", "Success", ply)
		end
	end
end)

net.Receive("sg_acceptInv", function(len, ply)
	-- Function to handle client invitation acceptance.
	-- Accepts the 64 bit Steam ID of the inviter,
	-- handled by the main menu.
	-- Checks client has requested invite, deletes all
	-- of their other invites, updates their gang status
	-- locally and on the database, notifies online gang
	-- members and distributes data to all affected
	-- clients.

	local id = net.ReadString()
	if IsValid(ply) and SimpleGangs.invites[ply:SteamID64()] != nil and SimpleGangs.invites[ply:SteamID64()][id] != nil then
		local orgName = SimpleGangs.invites[ply:SteamID64()][id][2]
		local oldOrgName
		if SimpleGangs.orgs[ply:SteamID64()] != nil then
			oldOrgName = SimpleGangs.orgs[ply:SteamID64()][2]
		end
		SimpleGangs.orgs[ply:SteamID64()] = {ply:Nick(), orgName, "0", math.floor(os.time())}
		SimpleGangs:sendNotify(ply:Nick() .. " Has joined your " .. SimpleGangs.UIGroupName .. "!", orgName, ply)
		for k, v in pairs(SimpleGangs.invites[ply:SteamID64()]) do
			if v[2] == orgName then
				SimpleGangs.invites[ply:SteamID64()][k] = nil
			end
		end
		SimpleGangs:orgDBQuery("DELETE FROM sg_orgs WHERE steamid64 = '" .. ply:SteamID64() .. "'")
		SimpleGangs:orgDBQuery("INSERT INTO sg_orgs VALUES ('" .. ply:Nick() .. "', ".. ply:SteamID64() .. ", '" .. orgName .. "', 0, " .. math.floor(os.time()) .. ")")
		SimpleGangs:orgDBQuery("DELETE FROM sg_invites WHERE recipient = '" .. ply:SteamID64() .. "' AND org = '" .. orgName .. "'")
		SimpleGangs:sendOrgs(ply)
		if oldOrgName != nil then
			SimpleGangs:sendOrgs(nil, oldOrgName)
		end
		SimpleGangs:distributeInvites()
		SimpleGangs:sendBank(ply)
	end
end)

net.Receive("sg_declineInv", function(len, ply)
	-- Function to handle client invitation rejection.
	-- Accepts the 64 bit Steam ID of the inviter,
	-- handled by the main menu.
	-- Checks client has requested invite, deletes all
	-- of their other invites, updates their gang status
	-- locally and on the database, notifies online gang
	-- members and distributes invites to all affected
	-- clients.

	local id = net.ReadString()
	if IsValid(ply) and SimpleGangs.invites[ply:SteamID64()] != nil and SimpleGangs.invites[ply:SteamID64()][id] != nil then
		if player.GetBySteamID64(id) then
			SimpleGangs:sendNotify(ply:Nick() .. " Has declined your Invitation!", nil, player.GetBySteamID64(id))
		end
		SimpleGangs.invites[ply:SteamID64()][id] = nil
		SimpleGangs:orgDBQuery("DELETE FROM sg_invites WHERE recipient = '" .. ply:SteamID64() .. "' AND sender = '" .. id .. "'")
		SimpleGangs:sendInvites(ply)
	end
end)

net.Receive("sg_promoteUser", function(len, ply)
	-- Function to handle promotion requests of gang
	-- members by owners.
	-- Accepts the 64 bit Steam ID of the target,
	-- handled by the main menu.
	-- Checks client has permissions and is valid,
	-- notifies online gang members, updates the rank
	-- locally and on the database and distributes gang
	-- data to all online members.

	local id = net.ReadString()
	if IsValid(ply) and SimpleGangs.orgs[ply:SteamID64()] != nil and SimpleGangs.orgs[ply:SteamID64()][3] == "1" and SimpleGangs.orgs[id] != nil and SimpleGangs.orgs[id][2] == SimpleGangs.orgs[ply:SteamID64()][2] and SimpleGangs.orgs[id][3] == "0" and id != ply:SteamID64() then
		SimpleGangs:sendNotify(SimpleGangs.orgs[id][1] .. " Has been promoted to " .. SimpleGangs.UIGroupName .. " Owner!", SimpleGangs.orgs[ply:SteamID64()][2])
		SimpleGangs.orgs[id][3] = "1"
		SimpleGangs:orgDBQuery("UPDATE sg_orgs SET owner = 1 WHERE steamid64 = '" .. id .."'")
		SimpleGangs:sendOrgs(ply)
	end
end)

net.Receive("sg_kickUser", function(len, ply)
	-- Function to handle ejection requests of gang
	-- members by owners.
	-- Accepts the 64 bit Steam ID of the target,
	-- handled by the main menu.
	-- Checks client has permissions and is valid,
	-- notifies online gang members, updates the target's
	-- gang status locally and on the database and
	-- distributes relevant data to appropriate clients.

	local id = net.ReadString()
	if IsValid(ply) and SimpleGangs.orgs[ply:SteamID64()] != nil and SimpleGangs.orgs[ply:SteamID64()][3] == "1" and SimpleGangs.orgs[id] != nil and SimpleGangs.orgs[id][2] == SimpleGangs.orgs[ply:SteamID64()][2] and id != ply:SteamID64() then
		SimpleGangs:sendNotify(SimpleGangs.orgs[id][1] .. " Has been kicked from the " .. SimpleGangs.UIGroupName .. "!", SimpleGangs.orgs[ply:SteamID64()][2])
		SimpleGangs.orgs[id] = nil
		SimpleGangs:orgDBQuery("DELETE FROM sg_orgs WHERE steamid64 = '" .. id .. "'")
		SimpleGangs:sendOrgs(ply)
		if player.GetBySteamID64(id) != false then
			SimpleGangs:sendOrgs(player.GetBySteamID64(id))
			SimpleGangs:sendBank(player.GetBySteamID64(id))
		end
		SimpleGangs:distributeInvites()
	end
end)

net.Receive("sg_inviteUser", function(len, ply)
	-- Function to handle sending invites from one
	-- client to another.
	-- Accepts the 64 bit Steam ID of the target,
	-- handled by the main menu.
	-- Checks client has permissions and is valid,
	-- notifies recipient (if online), adds an invite
	-- record to the invite table locally and on the
	-- database and distributes invites to appropriate
	-- clients.

	local id = net.ReadString()
	if IsValid(ply) and SimpleGangs.orgs[ply:SteamID64()] != nil and SimpleGangs.orgs[ply:SteamID64()][3] == "1" and IsValid(player.GetBySteamID64(id)) then
		if SimpleGangs.invites[id] != nil and SimpleGangs.invites[id][ply:SteamID64()] != nil and SimpleGangs.invites[id][ply:SteamID64()][2] == SimpleGangs.orgs[ply:SteamID64()][2] then return end
		if SimpleGangs.orgs[id] != nil and SimpleGangs.orgs[id][2] == SimpleGangs.orgs[ply:SteamID64()][2] then return end
		if player.GetBySteamID64(id) then
			SimpleGangs:sendNotify(ply:Nick() .. " Has invited you to join the " .. SimpleGangs.UIGroupName .. " '" .. SimpleGangs.orgs[ply:SteamID64()][2] .. "'!", nil, player.GetBySteamID64(id))		
		end
		if SimpleGangs.invites[id] == nil then SimpleGangs.invites[id] = {} end
		SimpleGangs.invites[id][ply:SteamID64()] = {ply:Nick(), SimpleGangs.orgs[ply:SteamID64()][2]}
		SimpleGangs:orgDBQuery("DELETE FROM sg_invites WHERE recipient = '" .. id .. "' AND sender = '" .. ply:SteamID64() .. "'")
		SimpleGangs:orgDBQuery("INSERT INTO sg_invites VALUES ('" .. ply:Nick() .. "', " .. ply:SteamID64() .. ", " .. id .. ", '" .. SimpleGangs.orgs[ply:SteamID64()][2] .. "')")
		SimpleGangs:sendInvites(ply)
		if player.GetBySteamID64(id) != false then SimpleGangs:sendInvites(player.GetBySteamID64(id)) end
	end
end)

net.Receive("sg_changeHud", function(len, ply)
	-- Function to handle updating client's HUD
	-- preferences.
	-- Accepts a boolean of whether to enable the HUD,
	-- handled by the main menu checkbox.
	-- Checks client is valid and updates the value
	-- locally and on the database.

	local val = net.ReadBool()
	if IsValid(ply) then
		if val then
			SimpleGangs.huds[ply:SteamID64()] = 1
		else
			SimpleGangs.huds[ply:SteamID64()] = 0
		end

		SimpleGangs:orgDBQuery("DELETE FROM sg_hud WHERE steamid64 = '" .. ply:SteamID64() .. "'")
		SimpleGangs:orgDBQuery("INSERT INTO sg_hud VALUES ('" .. ply:SteamID64() .. "', " .. SimpleGangs.huds[ply:SteamID64()] .. ")")
	end
end)

net.Receive("sg_requestOnline", function(len, ply)
	-- Function to handle requests for online player's
	-- gang names.
	-- Does not accept any data.
	-- Iterates over all online players, adding those
	-- who are a member of a gang to a table, then
	-- sends it to the client.

	local onlineOrgs = {}
	for _, onlinePlayer in ipairs(player.GetAll()) do
		if SimpleGangs.orgs[onlinePlayer:SteamID64()] != nil then
			onlineOrgs[onlinePlayer:SteamID64()] = SimpleGangs.orgs[onlinePlayer:SteamID64()][2]
		end
	end

	net.Start("sg_replyOnline")
	net.WriteTable(onlineOrgs)
	net.Send(ply)
end)

net.Receive("sg_requestOrgs", function(len, ply)
	-- Function to handle requests for gang data.
	-- Does not accept any data.

	SimpleGangs:sendOrgs(ply)
end)

net.Receive("sg_requestInvites", function(len, ply)
	-- Function to handle requests for invitation data.
	-- Does not accept any data.

	SimpleGangs:sendInvites(ply)
end)

net.Receive("sg_requestHud", function(len, ply)
	-- Function to handle requests for HUD preferences.
	-- Does not accept any data.

	SimpleGangs:sendHud(ply)
end)

net.Receive("sg_requestBank", function(len, ply)
	-- Function to handle requests for gang bank balance.
	-- Does not accept any data.

	SimpleGangs:sendBank(ply)
end)