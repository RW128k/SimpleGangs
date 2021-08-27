--[[
SimpleGangs 1.1

Serverside Administration Console Browser window
file. Handles the searching and browsing functions
of the main console window. 'Search engine backend'.
Also handles delete all data function.

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
util.AddNetworkString("sg_adminSearch")
util.AddNetworkString("sg_adminReply")
util.AddNetworkString("sg_adminDelall")

net.Receive("sg_adminSearch", function(len, ply)
	-- Function to handle requests by admins for a
	-- a list of search results containing either
	-- gangs or members, sliced by page number
	-- matching a specified query.
	-- Accepts the search query as a string, the
	-- search type as a unsigned integer (0 for
	-- gangs, 1 for members) and a page number
	-- which is also an unsigned integer.
	-- Constructs a list of results based on type,
	-- which is then sliced to provide the requested
	-- page. This list is added alongside other
	-- metadata to a table which is then sent to the
	-- client.

	local searchQueryIn = net.ReadString()
	local searchTypeIn = net.ReadUInt(1)
	local searchPageIn = net.ReadUInt(20)

	if !SimpleGangs.EnableAdmin or !SimpleGangs:checkAdmin(ply) then return end

	local matches = {}

	if searchTypeIn == 0 then
		-- Search for gangs
		for id, data in pairs(SimpleGangs.orgs) do
			if string.find(string.lower(data[2]), string.lower(searchQueryIn), nil, true) then
				if matches[data[2]] == nil then
					-- Add gang and bank balance with 1 member if not already in matches
					local matchedBank
					if SimpleGangs.banks[data[2]] == nil then
						matchedBank = 0
					else
						matchedBank = SimpleGangs.banks[data[2]]
					end
					matches[data[2]] = {1, matchedBank}
				else
					-- Increase member count if already in matches
					matches[data[2]][1] = matches[data[2]][1] + 1
				end
			end
		end
	else
		-- Search for members
		for id, data in pairs(SimpleGangs.orgs) do
			if string.find(string.lower(data[1]), string.lower(searchQueryIn), nil, true) then
				matches[id] = data
			end
		end
	end

	-- Construct reply table
	local replyTable = {
		searchQuery = searchQueryIn,
		searchType = searchTypeIn,
		page = searchPageIn,
		pages = math.ceil(table.Count(matches) / 20),
		searchResults = {}
	}

	-- Round out of range page number
	if replyTable["page"] > replyTable["pages"] then
		replyTable["page"] = replyTable["pages"]
	end

	-- Slice table to page
	local counter = 1
	for k, v in pairs(matches) do
		if counter > (replyTable["page"] - 1) * 20 and counter <= replyTable["page"] * 20 then
			replyTable["searchResults"][k] = v
		end
		counter = counter + 1
	end

	-- Send to client
	net.Start("sg_adminReply")
	net.WriteTable(replyTable)
	net.Send(ply)
end)

net.Receive("sg_adminDelall", function(len, ply)
	-- Function to handle delete all data requests
	-- by admins.
	-- Does not accept any data.
	-- Removes all values from local data tables,
	-- clears database tables and distributes all
	-- new empty data to connected clients.

	if !SimpleGangs.EnableAdmin or !SimpleGangs:checkAdmin(ply) then return end

	table.Empty(SimpleGangs.orgs)
	table.Empty(SimpleGangs.invites)
	table.Empty(SimpleGangs.huds)
	table.Empty(SimpleGangs.banks)

	SimpleGangs:orgDBQuery("DELETE FROM sg_orgs")
	SimpleGangs:orgDBQuery("DELETE FROM sg_invites")
	SimpleGangs:orgDBQuery("DELETE FROM sg_hud")
	SimpleGangs:orgDBQuery("DELETE FROM sg_bank")

	for _, olPly in ipairs(player.GetAll()) do
		SimpleGangs:sendOrgs(olPly)
		SimpleGangs:sendInvites(olPly)
		SimpleGangs:sendHud(olPly)
		SimpleGangs:sendBank(olPly)
	end
end)