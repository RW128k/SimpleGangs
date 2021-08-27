--[[
SimpleGangs 1.1

Serverside Leaderboard generator. Handles clients
requests for the leaderboard by querying appropriate
databases, and returns processed table to client.

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
util.AddNetworkString("sg_requestLeaderboard")
util.AddNetworkString("sg_replyLeaderboard")

net.Receive("sg_requestLeaderboard", function(len, ply)
	-- Function to handle requests by clients for
	-- the up to date leaderboard of gang banks
	-- (if enabled) and DarkRP wallets (if enabled).
	-- Does not accept any data.
	-- Constructs a table containing two other tables
	-- holding a processed leaderboard of banks and
	-- wallets obtained from the database and sends
	-- it to the client.

	if !SimpleGangs.EnableLeaderboard then return end

	-- Extract client's gang name
	local plyOrg = ""
	if SimpleGangs.orgs[ply:SteamID64()] != nil then
		plyOrg = SimpleGangs.orgs[ply:SteamID64()][2]
	end

	SimpleGangs:orgDBQuery("SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY money DESC) pos, org, money FROM sg_bank LIMIT 10) p UNION SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY money DESC) pos, org, money FROM sg_bank) q WHERE org = '" .. plyOrg .. "'", function(rawLeaderboard)
		SimpleGangs:darkrpDBQuery("SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY wallet DESC) pos, CAST(uid AS CHAR) AS uid, rpname, wallet FROM darkrp_player WHERE uid > 2000000000000 LIMIT 10) p UNION SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY wallet DESC) pos, CAST(uid AS CHAR) AS uid, rpname, wallet FROM darkrp_player WHERE uid > 2000000000000) q WHERE uid = '" .. ply:SteamID64() .. "'", function(rawWallets)
			local toSend = {
				lbOrgs = {},
				lbWallet = {}
			}

			-- Gang bank leaderboard
			if rawLeaderboard != nil and rawLeaderboard != false then
				for _, data in ipairs(rawLeaderboard) do
					if tonumber(data["pos"]) <= 10 and data["money"] != 0 then
						toSend["lbOrgs"][tonumber(data["pos"])] = data
					end
					if plyOrg != "" and data["org"] == plyOrg and data["money"] != "0" then
						toSend["plyOrg"] = {tonumber(data["pos"]), data["org"], data["money"]}
					end
				end

				if plyOrg != "" and toSend["plyOrg"] == nil then
					toSend["plyOrg"] = {table.Count(SimpleGangs.banks), plyOrg, "0"}
				end
			else
				toSend["lbOrgs"] = nil
			end

			-- DarkRP wallet leaderboard
			if rawWallets != nil and rawLeaderboard != false then
				for _, data in ipairs(rawWallets) do
					if tonumber(data["pos"]) <= 10 then
						toSend["lbWallet"][tonumber(data["pos"])] = data
					end
					if data["uid"] == ply:SteamID64() then
						toSend["plyWallet"] = {tonumber(data["pos"]), ply:Nick(), data["wallet"]}
					end
				end
			else
				toSend["lbWallet"] = nil
			end

			net.Start("sg_replyLeaderboard")
			net.WriteTable(toSend)
			net.Send(ply)
		end)
	end)
end)