--[[
SimpleGangs 1.1

Serverside Gang Bank file. Simply handles the
deposit and withdraw netmessages.

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
util.AddNetworkString("sg_depositOrg")
util.AddNetworkString("sg_withdrawOrg")

net.Receive("sg_depositOrg", function(len, ply)
	-- Function to handle cash deposits in gang bank.
	-- Accepts input from clientside querybox providing it is
	-- validated.
	-- Validates request serverside, creates a local gang bank
	-- if one does not already exist, subtracts from client
	-- wallet, updates the database and updates the bank value
	-- for all online gang members.

	local amount = tonumber(net.ReadString())

	if IsValid(ply) and amount != nil and amount > 0 and SimpleGangs.orgs[ply:SteamID64()] != nil and ply:getDarkRPVar("money") >= amount and SimpleGangs.EnableBank then
		ply:addMoney(-amount)
		if SimpleGangs.banks[SimpleGangs.orgs[ply:SteamID64()][2]] == nil then
			SimpleGangs.banks[SimpleGangs.orgs[ply:SteamID64()][2]] = amount
		else
			SimpleGangs.banks[SimpleGangs.orgs[ply:SteamID64()][2]] = SimpleGangs.banks[SimpleGangs.orgs[ply:SteamID64()][2]] + amount
		end
		SimpleGangs:orgDBQuery("DELETE FROM sg_bank WHERE org = '" .. SimpleGangs.orgs[ply:SteamID64()][2] .. "'")
		SimpleGangs:orgDBQuery("INSERT INTO sg_bank VALUES ('" .. SimpleGangs.orgs[ply:SteamID64()][2] .. "', " .. SimpleGangs.banks[SimpleGangs.orgs[ply:SteamID64()][2]] .. ")")
		SimpleGangs:sendBank(nil, SimpleGangs.orgs[ply:SteamID64()][2])
	end
end)

net.Receive("sg_withdrawOrg", function(len, ply)
	-- Function to handle cash withdrawals in gang bank.
	-- Accepts input from clientside querybox providing it is
	-- validated.
	-- Validates request serverside, adds to local gang bank,
	-- subtracts from client wallet, updates the database and
	-- updates the bank value for all online gang members.

	local amount = tonumber(net.ReadString())

	if IsValid(ply) and amount != nil and amount > 0 and SimpleGangs.orgs[ply:SteamID64()] != nil and SimpleGangs.banks[SimpleGangs.orgs[ply:SteamID64()][2]] != nil and SimpleGangs.banks[SimpleGangs.orgs[ply:SteamID64()][2]] >= amount and SimpleGangs.EnableBank then
		SimpleGangs.banks[SimpleGangs.orgs[ply:SteamID64()][2]] = SimpleGangs.banks[SimpleGangs.orgs[ply:SteamID64()][2]] - amount
		ply:addMoney(amount)
		SimpleGangs:orgDBQuery("DELETE FROM sg_bank WHERE org = '" .. SimpleGangs.orgs[ply:SteamID64()][2] .. "'")
		SimpleGangs:orgDBQuery("INSERT INTO sg_bank VALUES ('" .. SimpleGangs.orgs[ply:SteamID64()][2] .. "', " .. SimpleGangs.banks[SimpleGangs.orgs[ply:SteamID64()][2]] .. ")")
		SimpleGangs:sendBank(nil, SimpleGangs.orgs[ply:SteamID64()][2])
	end
end)