--[[
SimpleGangs 1.1

Clientside HUD file. Sets up the HUD drawing hook
and receives and applies any changes to the client's
'show on HUD' preferences from the server.

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

SimpleGangs.showOnHUD = false

hook.Add("HUDPaint", "orgHUD", function()
	-- HUD Paint hook used to draw the online
	-- members of the client's gang on the screen
	-- if they choose to enable it.
	-- Checks if client has opted to show the HUD
	-- and then constructs it in the position
	-- specified in the configuration file.

	if SimpleGangs.showOnHUD and SimpleGangs.orgs["all"][LocalPlayer():SteamID64()] != nil then
		-- Get all online gang members
		local onlinePlayers = SimpleGangs:sepOnline(SimpleGangs.orgs["all"][LocalPlayer():SteamID64()][2])

		surface.SetFont("sg_hudheadfont")
		local titleSize = surface.GetTextSize(string.upper(SimpleGangs.orgs["all"][LocalPlayer():SteamID64()][2]))

		local maxMembers = math.floor((ScrH() - 70 - SimpleGangs.HUDPosY) / 50)

		-- Sets up local variables for positioning
		local xpos
		local ypos
		if SimpleGangs.HUDAnchor == "topright" then
			xpos = ScrW() - SimpleGangs.HUDPosX - 400
			ypos = SimpleGangs.HUDPosY
		elseif SimpleGangs.HUDAnchor == "bottomleft" then
			xpos = SimpleGangs.HUDPosX
			ypos = ScrH() - SimpleGangs.HUDPosY - (70 + ((table.Count(onlinePlayers) <= maxMembers and table.Count(onlinePlayers) or maxMembers) * 50))
		elseif SimpleGangs.HUDAnchor == "bottomright" then
			xpos = ScrW() - SimpleGangs.HUDPosX - 400
			ypos = ScrH() - SimpleGangs.HUDPosY - (70 + ((table.Count(onlinePlayers) <= maxMembers and table.Count(onlinePlayers) or maxMembers) * 50))
		else
			xpos = SimpleGangs.HUDPosX
			ypos = SimpleGangs.HUDPosY
		end

		-- Draws main box with title and subtitle
		draw.RoundedBox(0, xpos, ypos, 400, 70 + ((table.Count(onlinePlayers) <= maxMembers and table.Count(onlinePlayers) or maxMembers) * 50), SimpleGangs.HUDBackgroundColor)
		draw.SimpleText(titleSize <= 324 and string.upper(SimpleGangs.orgs["all"][LocalPlayer():SteamID64()][2]) or string.sub(string.upper(SimpleGangs.orgs["all"][LocalPlayer():SteamID64()][2]), 1, 17) .. "...", "sg_hudheadfont", xpos + 10, ypos + 10, color_white)
		draw.RoundedBox(0, xpos + 10, ypos + 30, titleSize <= 324 and titleSize or surface.GetTextSize(string.sub(string.upper(SimpleGangs.orgs["all"][LocalPlayer():SteamID64()][2]), 1, 17) .. "..."), 2, color_white)
		draw.SimpleText(SimpleGangs.UIGroupName .. ": " .. table.Count(onlinePlayers) .. " / " .. table.Count(SimpleGangs.orgs["all"]) .. " Online", "sg_uifontS", xpos + 10, ypos + 40, color_white)

		-- Draw each online member on the HUD
		local numPly = 0
		for id, data in pairs(onlinePlayers) do
			numPly = numPly + 1
			-- Break if maximum players is exceeded (prevent drawing outside of screen)
			if numPly > maxMembers then break end

			local ply = player.GetBySteamID64(id)
			-- Draw player icon and name
			surface.SetMaterial(SimpleGangs.user)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(xpos + 10, ypos + 25 + (numPly * 50), 35, 35)
			surface.SetFont("sg_hudheadfont")
			local memberNameSize = surface.GetTextSize(ply:Nick())
			draw.SimpleText(memberNameSize <= 288 and ply:Nick() or string.sub(ply:Nick(), 1, 15) .. "...", "sg_hudheadfont", xpos + 50, ypos + 22 + (numPly * 50), color_white)
			
			-- Get text sizes for player statistics
			surface.SetFont("sg_uifontS")
			local textWidth1 = surface.GetTextSize(ply:Health() > 0 and ply:Health() or 0)
			local textWidth2 = surface.GetTextSize(ply:Armor())
			local textWidth3
			if DarkRP != nil and ply:getDarkRPVar("job") != nil and ply:getDarkRPVar("money") != nil then
				textWidth3 = surface.GetTextSize(ply:getDarkRPVar("job"))
				textWidth4 = surface.GetTextSize(DarkRP.formatMoney(ply:getDarkRPVar("money")):gsub("%$", ""))
			end
			-- Draw player statistics

			-- Health
			if 80 + textWidth1 < 400 then
				surface.SetMaterial(SimpleGangs.hp)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(xpos + 60, ypos + 47 + (numPly * 50), 15, 15)
				draw.SimpleText(ply:Health() > 0 and ply:Health() or 0, "sg_uifontS", xpos + 80, ypos + 46 + (numPly * 50), SimpleGangs.color_health)
			end
			-- Armor
			if 105 + textWidth1 + textWidth2 < 400 then
				surface.SetMaterial(SimpleGangs.armor)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(xpos + 85 + textWidth1, ypos + 47 + (numPly * 50), 15, 15)
				draw.SimpleText(ply:Armor(), "sg_uifontS", xpos + 105 + textWidth1, ypos + 46 + (numPly * 50), SimpleGangs.color_armor)
			end
			if DarkRP != nil and textWidth3 != nil and textWidth4 != nil then
				-- DarkRP job
				if 130 + textWidth1 + textWidth2 + textWidth3 < 400 then
					surface.SetMaterial(SimpleGangs.job)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(xpos + 110 + textWidth1 + textWidth2, ypos + 47 + (numPly * 50), 15, 15)
					draw.SimpleText(ply:getDarkRPVar("job"), "sg_uifontS", xpos + 130 + textWidth1 + textWidth2, ypos + 46 + (numPly * 50), ColorAlpha(ply:getJobTable()["color"], 255))
				end
				-- DarkRP wallet balance
				if 155 + textWidth1 + textWidth2 + textWidth3 + textWidth4 < 400 then
					surface.SetMaterial(SimpleGangs.guap)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(xpos + 135 + textWidth1 + textWidth2 + textWidth3, ypos + 47 + (numPly * 50), 15, 15)
					draw.SimpleText(DarkRP.formatMoney(ply:getDarkRPVar("money")):gsub("%$", ""), "sg_uifontS", xpos + 155 + textWidth1 + textWidth2 + textWidth3, ypos + 46 + (numPly * 50), SimpleGangs.color_guap)
				end
			end
		end
	end
end)

net.Receive("sg_replyHud", function()
	-- Function to handle the client's incoming
	-- HUD preference.
	-- Accepts an unsigned integer representing
	-- a boolean.
	-- Updates the local preference by converting
	-- the integer to a boolean.

	SimpleGangs.showOnHUD = tobool(net.ReadUInt(1))
end)