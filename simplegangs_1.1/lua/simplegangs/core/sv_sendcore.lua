--[[
SimpleGangs 1.1

Serverside Core sending file. Defines functions for
distributing gang, invite, bank, hud and notification
data to entire gangs or individual users.

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
util.AddNetworkString("sg_replyOrgs")
util.AddNetworkString("sg_replyInvites")
util.AddNetworkString("sg_replyHud")
util.AddNetworkString("sg_replyBank")
util.AddNetworkString("sg_orgNotify")

function SimpleGangs:sendOrgs(ply, org)
	-- Function to handle the distribution of
	-- client gang data to all online members of a
	-- specified gang or individual player.
	-- Accepts 2 paramaters: ply, if passed, the
	-- player object whos gang to send data to, or
	-- just themself if they are not a member of a
	-- gang, and org, if passed, the case sensitive
	-- gang name to send data to.
	-- Looks up members of supplied gang, adds them
	-- to a table and adds the user object of those
	-- who are online to another table, which is
	-- a list of players to send data to.

	local sendTo = {}
	local plyOrgs = {}

	if org == nil then
		-- Send to player's gang / player if not in gang
		if self.orgs[ply:SteamID64()] == nil then
			table.insert(sendTo, ply)
		else
			local orgName = self.orgs[ply:SteamID64()][2]
			for id, data in pairs(self.orgs) do
				if data[2] == orgName then
					plyOrgs[id] = data
				end
			end
			for _, onlinePlayer in ipairs(player.GetAll()) do
				if self.orgs[onlinePlayer:SteamID64()] != nil and self.orgs[onlinePlayer:SteamID64()][2] == orgName then
					table.insert(sendTo, onlinePlayer)
				end
			end
		end
	else
		-- Send to gang
		for id, data in pairs(self.orgs) do
			if data[2] == org then
				plyOrgs[id] = data
			end
		end
		for _, onlinePlayer in ipairs(player.GetAll()) do
			if self.orgs[onlinePlayer:SteamID64()] != nil and self.orgs[onlinePlayer:SteamID64()][2] == org then
				table.insert(sendTo, onlinePlayer)
			end
		end
	end

	net.Start("sg_replyOrgs")
	net.WriteTable(plyOrgs)
	net.Send(sendTo)
end

function SimpleGangs:sendInvites(ply)
	-- Function to handle the distribution of
	-- invitations to individual players.
	-- Accepts 1 paramater: ply, the player object
	-- of who to send invitations to.
	-- If the player has an invite table, iterate
	-- over it and add each record with the number
	-- of gang members to a temporary table which
	-- is sent to the player.

	local plyInvs = {}
	if self.invites[ply:SteamID64()] != nil then
		for id, data in pairs(self.invites[ply:SteamID64()]) do
			data[3] = self:numMembers(data[2])
			plyInvs[id] = data
		end
	end

	net.Start("sg_replyInvites")
	net.WriteTable(plyInvs)
	net.Send(ply)
end

function SimpleGangs:distributeInvites()
	-- Function which handles the mass distribution
	-- of invitations to all online players.
	-- Accepts no paramaters.
	-- Simply iterates over all online players and
	-- calls the above sendInvites function on
	-- each one.

	for _, onlinePlayer in ipairs(player.GetAll()) do
		self:sendInvites(onlinePlayer)
	end
end

function SimpleGangs:sendHud(ply)
	-- Function to handle the distribution of HUD
	-- preferences to individual players.
	-- Accepts 1 paramater: ply, the player object
	-- of who to send preferences to.
	-- If the player has a HUD preference value,
	-- send it to them.

	if self.huds[ply:SteamID64()] != nil then
		net.Start("sg_replyHud")
		net.WriteUInt(self.huds[ply:SteamID64()], 1)
		net.Send(ply)
	end
end

function SimpleGangs:sendBank(ply, org)
	-- Function to handle the distribution of
	-- gang bank balances to all online members of a
	-- specified gang or player.
	-- Accepts 2 paramaters: ply, if passed, the
	-- player object whos gang to send balances to,
	-- or just themself if they are not a member of a
	-- gang, and org, if passed, the case sensitive
	-- gang name to send balances to.
	-- Looks up members of supplied gang, adds them
	-- to a table and adds the user object of those
	-- who are online to another table, which is
	-- a list of players to send balances to.

	local sendTo = {}
	local plyBank

	if org == nil then
		-- Send to player's gang / player if not in gang
		if self.orgs[ply:SteamID64()] == nil or self.banks[self.orgs[ply:SteamID64()][2]] == nil then
			plyBank = "0"
		else
			plyBank = tostring(self.banks[self.orgs[ply:SteamID64()][2]])
		end

		table.insert(sendTo, ply)
	else
		-- Send to gang
		if self.banks[org] == nil then
			plyBank = "0"
		else
			plyBank = tostring(self.banks[org])
		end
		for _, onlinePlayer in ipairs(player.GetAll()) do
			if self.orgs[onlinePlayer:SteamID64()] != nil and self.orgs[onlinePlayer:SteamID64()][2] == org then
				table.insert(sendTo, onlinePlayer)
			end
		end		
	end
		
	net.Start("sg_replyBank")
	net.WriteString(plyBank)
	net.Send(sendTo)
end

function SimpleGangs:sendNotify(msg, orgName, ply)
	-- Function to handle the dispatching of
	-- notifications to clients or all online members
	-- of a gang.
	-- Accepts 3 paramaters: msg, the notification
	-- message contents to be displayed, orgName,
	-- if passed, the case sensitive gang name whos
	-- members to send the notification to (exempting
	-- ply if passed), and ply, the player object, if
	-- passed, to exempt from send list or to send to
	-- individually if orgName is not passed.
	-- Iterates through online players, and adds those
	-- who are members of the provided gang (excluding
	-- ply) to a table holding the send list. Message
	-- msg is sent to send list.

	local sendTo = {}
	if orgName == nil and ply != nil then
		-- Only ply passed. Send individually
		table.insert(sendTo, ply)
	else
		-- orgName passed. Send to whole gang exempting ply
		for _, onlinePlayer in ipairs(player.GetAll()) do
			if self.orgs[onlinePlayer:SteamID64()] != nil and self.orgs[onlinePlayer:SteamID64()][2] == orgName then
				if not (ply != nil and onlinePlayer:SteamID64() == ply:SteamID64()) then
					table.insert(sendTo, onlinePlayer)
				end
			end
		end
	end
	net.Start("sg_orgNotify")
	net.WriteString(msg)
	net.Send(sendTo)
end