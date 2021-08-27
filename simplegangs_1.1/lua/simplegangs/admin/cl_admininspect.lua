--[[
SimpleGangs 1.1

Clientside Administration Console Inspect window
file. Handles the creation and population of the
UI with data requested and received from the server.

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

SimpleGangs.inspectElements = {}

local function populateInspectMenu(searchResults, userAvatar, userTitle, detail1, detail2, detail3, action1, action2, action3, action4, adminList, nextButton, pageLabel, prevButton, refreshButton, prevTitle)
	-- Function to handle the population of the
	-- admin inspect window, created by the
	-- adminInspect function below.
	-- Accepts 16 parameters, the first being the
	-- inspect target data to populate with, the
	-- middle 14 being UI element objects of which
	-- to update with aforementioned data, and the
	-- last the previous window title, used when
	-- in small window mode to decide whether to
	-- switch tabs on population (Changing page
	-- vs changing inspection target).
	-- Updates target title, details, avatar &
	-- action buttons, and the member list and its
	-- respective controls, such as page buttons
	-- & label.

	if !IsValid(adminList) or !SimpleGangs.EnableAdmin or !SimpleGangs:checkAdmin(LocalPlayer()) then return end

	-- Setup local variables used for positioning elements depending on if small window mode is used
	local newTitle = searchResults["playerData"] != nil and searchResults["playerData"][1] or searchResults["searchOrg"]

	local managementParent = userAvatar:GetParent()
    local memberListParent = adminList:GetParent()
    local Frame = managementParent
	
    local xShiftManagement = 26
    local yShiftManagement = 100
    local xShiftMemberList = 0
    local yShiftMemberList = 300    

	if managementParent:GetName() != "DFrame" then
		Frame = managementParent:GetParent():GetParent()
    	xShiftManagement = 0
    	yShiftManagement = 10
	    xShiftMemberList = 13
		yShiftMemberList = 0
		if newTitle != prevTitle then
			managementParent:GetParent():SetActiveTab(managementParent:GetParent():GetItems()[1]["Tab"])
		end
	end

	-- Delete elements which need to be replaced. Avatar can be either DImage or AvatarImage
	userAvatar:Remove()
	adminList:Remove()

	if table.Count(searchResults["searchResults"]) == 0 then
		-- Empty result set, show no longer exists with ? avatar
		surface.SetFont("sg_uifontL")
		local userTitleSize = surface.GetTextSize("User or " .. SimpleGangs.UIGroupName .. " no longer exists!")
		surface.SetFont("sg_uifontM")
		local pageSize = surface.GetTextSize("Page 0 of 0")
		local errorSizeW, errorSizeH = surface.GetTextSize("Unavailable")

		userAvatar = vgui.Create("AvatarImage", managementParent)
		userAvatar:SetSize(200, 200)
		userAvatar:SetPos(xShiftManagement, yShiftManagement)
		userAvatar:SetSteamID("", 256)

		userTitle:SetText(xShiftManagement + 210 + userTitleSize < Frame:GetWide() - 26 and "User or " .. SimpleGangs.UIGroupName .. " no longer exists!" or "No longer exists!")
		userTitle:SizeToContents()

		detail1:SetText(" ")
		detail1:SizeToContents()
		detail2:SetText(" ")
		detail2:SizeToContents()
		detail3:SetText(" ")
		detail3:SizeToContents()

		action1:SetEnabled(false)
		action2:SetEnabled(false)
		action3:SetEnabled(false)
		action4:SetEnabled(false)

		pageLabel:SetText("Page 0 of 0")
		pageLabel:SizeToContents()
		pageLabel:SetPos(Frame:GetWide() - pageSize - xShiftMemberList - 60, yShiftMemberList)
		prevButton:SetPos(Frame:GetWide() - pageSize - xShiftMemberList - 100, yShiftMemberList)
		
		nextButton:SetEnabled(false)
		prevButton:SetEnabled(false)

	    adminList = vgui.Create("DScrollPanel", memberListParent)
		adminList:DockMargin(20 - xShiftMemberList, yShiftMemberList == 300 and yShiftMemberList + 60 or yShiftMemberList + 89, 20 - xShiftMemberList, yShiftMemberList == 300 and 90 or 0)
		adminList:Dock(FILL)	

	    local errorText = vgui.Create("DLabel", adminList)
	    errorText:SetPos((Frame:GetWide() - errorSizeW - 40) / 2, (Frame:GetTall() - errorSizeH - (yShiftMemberList == 300 and 360 or 159) - 90) / 2)
	    errorText:SetFont("sg_uifontM")
	    errorText:SetText("Unavailable")
	    errorText:SetWrap(false)
	    errorText:SizeToContents()

	else
		-- Valid result set, begin population

		-- Delete action buttons as they are replaced
		action1:Remove()
		action2:Remove()
		action3:Remove()
		action4:Remove()

		if searchResults["searchOrg"] == nil then
			-- Inspection target is a player
			local rank
			if searchResults["playerData"][3] == "0" then
				rank = "Member"
			else
				rank = "Owner"
			end

			-- Get text sizes for title and details
			surface.SetFont("sg_uifontL")
			local userTitleSize = surface.GetTextSize(searchResults["playerData"][1])
			surface.SetFont("sg_uifontM")
			local detail1Size = surface.GetTextSize(SimpleGangs.UIGroupName .. ": " .. searchResults["playerData"][2])
			local detail2Size = surface.GetTextSize("Rank: " .. SimpleGangs.UIGroupName .. " " .. rank)
			local detail3Size = surface.GetTextSize("Last Online: " .. os.date("%x", searchResults["playerData"][4]) .. " (" .. SimpleGangs:getTimeAgo(searchResults["playerData"][4]) .. " Ago)")

			-- Set avatar to user's SteamID and title to their name
			userAvatar = vgui.Create("AvatarImage", managementParent)
			userAvatar:SetSize(200, 200)
			userAvatar:SetPos(xShiftManagement, yShiftManagement)
			userAvatar:SetSteamID(searchResults["searchPlayer"], 256)

			userTitle:SetText(xShiftManagement + 210 + userTitleSize < Frame:GetWide() - 26 and searchResults["playerData"][1] or string.sub(searchResults["playerData"][1], 1, 12) .. "...")
			userTitle:SizeToContents()

			-- Set detail label contents
			detail1:SetText(xShiftManagement + 210 + detail1Size < Frame:GetWide() - 26 and SimpleGangs.UIGroupName .. ": " .. searchResults["playerData"][2] or string.sub(SimpleGangs.UIGroupName .. ": " .. searchResults["playerData"][2], 1, 18) .. "...")
			detail1:SizeToContents()
			detail2:SetText(xShiftManagement + 210 + detail2Size < Frame:GetWide() - 26 and "Rank: " .. SimpleGangs.UIGroupName .. " " .. rank or "Rank: " .. rank)
			detail2.Paint = function(pnl, w, h) end
			detail2:SizeToContents()
			if player.GetBySteamID64(searchResults["searchPlayer"]) != false then
				detail3:SetText("Currently Online")
			else
				detail3:SetText(xShiftManagement + 210 + detail3Size < Frame:GetWide() - 26 and "Last Online: " .. os.date("%x", searchResults["playerData"][4]) .. " (" .. SimpleGangs:getTimeAgo(searchResults["playerData"][4]) .. " Ago)" or "Last Online: " .. os.date("%x", searchResults["playerData"][4]))
			end
			detail3:SizeToContents()

			-- Get text sizes for actions
			surface.SetFont("sg_uifontButton")
			local a1Size = surface.GetTextSize("View Profile")
			local a2Size = surface.GetTextSize("View " .. SimpleGangs.UIGroupName)
			local a3Size
			if searchResults["playerData"][3] == "0" then
				a3Size = surface.GetTextSize("Promote to Co-Owner")
			else
				a3Size = surface.GetTextSize("Demote to Member")
			end
			local a4Size = surface.GetTextSize("Kick")

			local sameLine = xShiftManagement + a1Size + a2Size + a3Size + a4Size + 290 < Frame:GetWide() - 26

		    -- Create action buttons with appropriate text, function and position

		    -- View profile	
		    action1 = vgui.Create("DButton", managementParent)
		    action1:SetPos(xShiftManagement + 210, yShiftManagement + 150)
		    action1:SetSize(a1Size + 10, 40)
		    action1:SetFont("sg_uifontButton")
		    action1:SetTextColor(color_black)
		    action1:SetText("View Profile")
		    action1.DoClick = function() SimpleGangs:viewProfile(searchResults["searchPlayer"]) end

		    -- View gang
		    action2 = vgui.Create("DButton", managementParent)
		    action2:SetPos(xShiftManagement + a1Size + 230, yShiftManagement + 150)
		    action2:SetSize(a2Size + 10, 40)
		    action2:SetFont("sg_uifontButton")
		    action2:SetTextColor(color_black)
		    action2:SetText("View " .. SimpleGangs.UIGroupName)
			action2.DoClick = function()
				net.Start("sg_adminOrgSearch")
				net.WriteString("")
				net.WriteString(searchResults["playerData"][2] or "")
				net.WriteUInt(1, 20)
				net.SendToServer()
			end		    

			-- Promote / demote
		    action3 = vgui.Create("DButton", managementParent)
		    action3:SetPos(sameLine and xShiftManagement + a1Size + a2Size + 250 or xShiftManagement + 210, sameLine and yShiftManagement + 150 or yShiftManagement + 200)
		    action3:SetSize(a3Size + 10, 40)
		    action3:SetFont("sg_uifontButton")
		    action3:SetTextColor(color_black)
		    if searchResults["playerData"][3] == "0" then
				action3:SetText("Promote to Co-Owner")
			else
				action3:SetText("Demote to Member")
			end
			action3.DoClick = function()
				net.Start("sg_adminPromoteDemote")
				net.WriteBool(searchResults["playerData"][3] == "0")
				net.WriteString(searchResults["searchPlayer"])
				net.SendToServer()

				Frame.OnClose = function() end
				Frame:Close()

				local substr
				if searchResults["playerData"][3] == "0" then
					substr = "Promoted to Co-Owner"
				else
					substr = "Demoted to Member"
				end
				local infoBox = Derma_Message(searchResults["playerData"][1] .. " Has been " .. substr .. "!", "Success", "OK")
				infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
				infoBox.OnClose = function() SimpleGangs:adminInspect(nil, searchResults["searchPlayer"]) end
			end

			-- Kick from gang
		    action4 = vgui.Create("DButton", managementParent)
		    action4:SetPos(sameLine and xShiftManagement + a1Size + a2Size + a3Size + 270 or xShiftManagement + a3Size + 230, sameLine and yShiftManagement + 150 or yShiftManagement + 200)
		    action4:SetSize(a4Size + 10, 40)
		    action4:SetFont("sg_uifontButton")
		    action4:SetTextColor(color_black)
		    action4:SetText("Kick")
			action4.DoClick = function()
				net.Start("sg_adminKick")
				net.WriteString(searchResults["searchPlayer"])
				net.SendToServer()

				Frame.OnClose = function() end
				Frame:Close()

				local infoBox = Derma_Message(searchResults["playerData"][1] .. " Has been Kicked from the " .. SimpleGangs.UIGroupName, "Success", "OK")
				infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
				if searchResults["pages"] <= 1 and table.Count(searchResults["searchResults"]) <= 1 then
					infoBox.OnClose = function() SimpleGangs:adminMenu() end
				else
					infoBox.OnClose = function() SimpleGangs:adminInspect(searchResults["playerData"][2]) end
				end
			end
		else
			-- Inspection target is a gang

			-- Get text size for title
			surface.SetFont("sg_uifontL")
			local userTitleSize = surface.GetTextSize(searchResults["searchOrg"])

			-- Set avatar to default gang icon and title to gang name
			userAvatar = vgui.Create("DImage", managementParent)
			userAvatar:SetSize(200, 200)
			userAvatar:SetPos(xShiftManagement, yShiftManagement)
			userAvatar:SetImage("simplegangs/org_avatar.png")

			userTitle:SetText(xShiftManagement + 210 + userTitleSize < Frame:GetWide() - 26 and searchResults["searchOrg"] or string.sub(searchResults["searchOrg"], 1, 12) .. "...")
			userTitle:SizeToContents()

			-- Set detail label contents
			detail1:SetText("Members: " .. searchResults["orgSize"])
			detail1:SizeToContents()
			if DarkRP != nil and SimpleGangs.EnableBank then
				detail2:SetText("Bank:     " .. DarkRP.formatMoney(searchResults["orgBank"]):gsub("%$", ""))
	    		detail2.Paint = function(pnl, w, h)
	    			surface.SetMaterial(SimpleGangs.guap)
					surface.SetDrawColor(210, 210, 210, 255)
					surface.DrawTexturedRect(65, 2, 23, 23)
	    		end 
			else
				detail2:SetText("Bank: Not Available")
	    		detail2.Paint = function(pnl, w, h) end 
			end
			detail2:SizeToContents()
			detail3:SetText(" ")
			detail3:SizeToContents()

			-- Get text sizes for actions
			surface.SetFont("sg_uifontButton")
			local a1Size = surface.GetTextSize("Delete")
			local a2Size = surface.GetTextSize("Rename")
			local a3Size = surface.GetTextSize("Set Bank Value")
			local a4Size = surface.GetTextSize("Join")

			local sameLine = xShiftManagement + a1Size + a2Size + a3Size + a4Size + 290 < Frame:GetWide() - 26

			-- Create action buttons with appropriate text, function and position

			-- Delete gang
		    action1 = vgui.Create("DButton", managementParent)
		    action1:SetPos(xShiftManagement + 210, yShiftManagement + 150)
		    action1:SetSize(a1Size + 10, 40)
		    action1:SetFont("sg_uifontButton")
		    action1:SetTextColor(color_black)
		    action1:SetText("Delete")
			action1.DoClick = function()
				net.Start("sg_adminDelete")
				net.WriteString(searchResults["searchOrg"])
				net.SendToServer()

				Frame.OnClose = function() end
				Frame:Close()

				local infoBox = Derma_Message(SimpleGangs.UIGroupName .. " '" .. searchResults["searchOrg"] .. "' has been Deleted!", "Success", "OK")
				infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
				infoBox.OnClose = function() SimpleGangs:adminMenu() end
			end

		    -- Rename gang
		    action2 = vgui.Create("DButton", managementParent)
		    action2:SetPos(xShiftManagement + a1Size + 230, yShiftManagement + 150)
		    action2:SetSize(a2Size + 10, 40)
		    action2:SetFont("sg_uifontButton")
		    action2:SetTextColor(color_black)
		    action2:SetText("Rename")
		    action2.DoClick = function()
		    	Frame.OnClose = function() end
				Frame:Close()

				local inputBox = Derma_StringRequest("Rename " .. SimpleGangs.UIGroupName, "Enter the new name for the " .. SimpleGangs.UIGroupName .. " '" .. searchResults["searchOrg"] .. "'\nSpecifying the name of an existing " .. SimpleGangs.UIGroupName .. " will merge the two together, keeping this " .. SimpleGangs.UIGroupName .. "'s Bank Balance.", "", function(text)
					text = string.Trim(text)
					-- Validate input
					local infoBox
					if text == "" then
						infoBox = Derma_Message("Please Enter a Valid " .. SimpleGangs.UIGroupName .. " Name", "Error", "OK")
						infoBox.OnClose = function() SimpleGangs:adminInspect(searchResults["searchOrg"]) end
					elseif string.len(text) > 25 then
						infoBox = Derma_Message(SimpleGangs.UIGroupName .. " name is too long! (Max 25 Characters)", "Error", "OK")
						infoBox.OnClose = function() SimpleGangs:adminInspect(searchResults["searchOrg"]) end
					else
						infoBox = Derma_Message(SimpleGangs.UIGroupName .. " '" .. searchResults["searchOrg"] .. "' has been renamed to '" .. text .. "'!", "Success", "OK")
						infoBox.OnClose = function() SimpleGangs:adminInspect(text) end

						net.Start("sg_adminRename")
						net.WriteString(searchResults["searchOrg"])
						net.WriteString(text)
						net.SendToServer()
					end
					infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
				end, function() SimpleGangs:adminInspect(searchResults["searchOrg"]) end, "Rename", "Cancel")
				inputBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end	    
		   	end

		   	-- Set gang bank balance
		    action3 = vgui.Create("DButton", managementParent)
		    action3:SetPos(sameLine and xShiftManagement + a1Size + a2Size + 250 or xShiftManagement + 210, sameLine and yShiftManagement + 150 or yShiftManagement + 200)
		    action3:SetSize(a3Size + 10, 40)
		    action3:SetFont("sg_uifontButton")
		    action3:SetTextColor(color_black)
		    action3:SetText("Set Bank Value")
		    action3:SetEnabled(DarkRP != nil and SimpleGangs.EnableBank)
		    action3.DoClick = function()
		    	Frame.OnClose = function() end
				Frame:Close()

				local inputBox = Derma_StringRequest("Set Bank Value", "Enter the new Bank Balance for '" .. searchResults["searchOrg"] .. "'\nCurrent Balance: " .. SimpleGangs.moneySymbol .. DarkRP.formatMoney(searchResults["orgBank"]):gsub("%$", ""), "", function(text)
					local val = tonumber(text)
					local infoBox
					if val == nil or val < 0 or !(val < 1e300) then
						infoBox = Derma_Message("Please Enter a Valid Amount!", "Error", "OK")
					else
						net.Start("sg_adminBank")
						net.WriteString(searchResults["searchOrg"])
						net.WriteString(text)
						net.SendToServer()

						infoBox = Derma_Message("Set the Bank Balance of '" .. searchResults["searchOrg"] .. "' to " .. SimpleGangs.moneySymbol .. DarkRP.formatMoney(val):gsub("%$", "") .. "!", "Success", "OK")
					end
					infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
					infoBox.OnClose = function() SimpleGangs:adminInspect(searchResults["searchOrg"]) end
				end, function() SimpleGangs:adminInspect(searchResults["searchOrg"]) end, "Set", "Cancel")
				inputBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end	    
		   	end

		    -- Join gang
		    action4 = vgui.Create("DButton", managementParent)
		    action4:SetPos(sameLine and xShiftManagement + a1Size + a2Size + a3Size + 270 or xShiftManagement + a3Size + 230, sameLine and yShiftManagement + 150 or yShiftManagement + 200)
		    action4:SetSize(a4Size + 10, 40)
		    action4:SetFont("sg_uifontButton")
		    action4:SetTextColor(color_black)
		    action4:SetText("Join")
			action4.DoClick = function()
				net.Start("sg_adminJoin")
				net.WriteString(searchResults["searchOrg"])
				net.SendToServer()

				Frame.OnClose = function() end
				Frame:Close()

				local infoBox = Derma_Message("You are now a member of '" .. searchResults["searchOrg"] .. "'!", "Success", "OK")
				infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
				infoBox.OnClose = function() SimpleGangs:adminInspect(searchResults["searchOrg"]) end
			end
		end

		-- Begin population of member list

		-- Update page buttons & label
		surface.SetFont("sg_uifontM")
		local pageSize = surface.GetTextSize("Page " .. searchResults["page"] .. " of " .. searchResults["pages"])

		pageLabel:SetText("Page " .. searchResults["page"] .. " of " .. searchResults["pages"])
		pageLabel:SizeToContents()
		pageLabel:SetPos(Frame:GetWide() - pageSize - xShiftMemberList - 60, yShiftMemberList)
		prevButton:SetPos(Frame:GetWide() - pageSize - xShiftMemberList - 100, yShiftMemberList)

		if searchResults["page"] == searchResults["pages"] then
			nextButton:SetEnabled(false)
		else
			nextButton:SetEnabled(true)
		end

		if searchResults["page"] <= 1 then
			prevButton:SetEnabled(false)
		else
			prevButton:SetEnabled(true)
		end

		nextButton.DoClick = function()
			net.Start("sg_adminOrgSearch")
			net.WriteString(searchResults["searchPlayer"] or "")
			net.WriteString(searchResults["searchOrg"] or "")
			net.WriteUInt(searchResults["page"] + 1, 20)
			net.SendToServer()
		end

		prevButton.DoClick = function()
			net.Start("sg_adminOrgSearch")
			net.WriteString(searchResults["searchPlayer"] or "")
			net.WriteString(searchResults["searchOrg"] or "")
			net.WriteUInt(searchResults["page"] - 1, 20)
			net.SendToServer()
		end

		-- Update refresh button to refresh current target
		refreshButton.DoClick = function()
			net.Start("sg_adminOrgSearch")
			net.WriteString(searchResults["searchPlayer"] or "")
			net.WriteString(searchResults["searchOrg"] or "")
			net.WriteUInt(1, 20)
			net.SendToServer()
		end

		-- Replace member list
		adminList = vgui.Create("DScrollPanel", memberListParent)
		adminList:DockMargin(20 - xShiftMemberList, yShiftMemberList == 300 and yShiftMemberList + 60 or yShiftMemberList + 89, 20 - xShiftMemberList, yShiftMemberList == 300 and 90 or 0)
		adminList:Dock(FILL)

		-- Setup loop counters
		local numResults = table.Count(searchResults["searchResults"])
		local countResult = 0

		for identifier, data in pairs(searchResults["searchResults"]) do
			countResult = countResult + 1
			-- Setup derma panel for member with appropriate size and padding
			local resultPanel = adminList:Add("DPanel")
			resultPanel:SetSize(nil, 38)
			if resultPanel == 1 then
				resultPanel:DockMargin(0, 5, 0, 5)
			else
				resultPanel:DockMargin(0, 0, 0, 5)
			end
			resultPanel:Dock(TOP)
			local drawSpacer = countResult != numResults
			-- Setup member attributes
			local attrib1 = data[1]
			local attrib2
			if player.GetBySteamID64(identifier) != false then
				attrib2 = "Online Now"
			else
				attrib2 = os.date("%x", data[4])
			end
			local attrib3
			if data[3] == "0" then
				attrib3 = "Member"
			else
				attrib3 = "Owner"
			end
			-- Acutally draw attributes on result panel
			resultPanel.Paint = function(pnl, w, h)
				surface.SetFont("sg_uifontM")
				local attrib1Size = surface.GetTextSize(attrib1)
				local attrib3Size = surface.GetTextSize(attrib3)

				draw.SimpleText(attrib1Size <= 352 and attrib1 or string.sub(attrib1, 1, 15) .. "...", "sg_uifontM", 41, 0, color_white)

				-- Exempt attribute 2 if using small window mode
				if Frame:GetWide() >= 1000 then
					draw.SimpleText(attrib2, "sg_uifontM", w / 2, 0, color_white, TEXT_ALIGN_CENTER)
				end

				draw.SimpleText(attrib3, "sg_uifontM", w - 6, 0, color_white, TEXT_ALIGN_RIGHT)
				if drawSpacer then
					draw.RoundedBox(0, 0, h - 1, w, 1, color_white)
				end
			end
			-- Setup click function for member panel to change inspect target
			resultPanel:SetCursor("hand")
			resultPanel.OnMousePressed = function()
				net.Start("sg_adminOrgSearch")
				net.WriteString(identifier or "")
				net.WriteString("")
				net.WriteUInt(1, 20)
				net.SendToServer()				
			end

			-- Set member icon to default gang icon
			local Avatar = vgui.Create("AvatarImage", resultPanel)
			Avatar:SetCursor("hand")
			Avatar:SetSize(32, 32)
			Avatar:SetPos(0, 0)
			Avatar:SetSteamID(identifier, 32)
			Avatar.OnMousePressed = resultPanel.OnMousePressed
		end
	end

	-- Add all elements that should be updated to table
	SimpleGangs.inspectElements = {userAvatar, userTitle, detail1, detail2, detail3, action1, action2, action3, action4, adminList, nextButton, pageLabel, prevButton, refreshButton, newTitle}
end

function SimpleGangs:adminInspect(org, ply)
	-- Function to handle the creation of the
	-- admin inspect window, which is later
	-- populated by the populateInspectMenu
	-- function above.
	-- Accepts 2 parameters, org, the name a gang
	-- to inspect and ply, the 64 bit Steam ID of
	-- a member to inspect. Only one parameter is
	-- supplied, leaving the other as nil. If both
	-- are passed, the server will ignore the second.
	-- Creates all the user interface components
	-- populating them with constant or placeholder
	-- data, and making the inital request to
	-- the server for information about supplied
	-- parameters.

	if !self.EnableAdmin then return end

	-- Prevent construction and display error if user is not in the admin pool
	if !self:checkAdmin(LocalPlayer()) then
		local infoBox = Derma_Message("You must be a Server Administrator to do this!", "Error", "OK")
		infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, self.UIBackgroundColor) end
		return
	end

	-- Get text sizes
	surface.SetFont("sg_uifontXL")
	local titleText = self.UIGroupName .. " Administration Console"
	local titleSize = surface.GetTextSize(titleText)
    if titleSize > (ScrW() >= 1020 and 1000 or ScrW() - 20) then
    	titleText = self.UITitle
    	titleSize = surface.GetTextSize(titleText)
    end
    surface.SetFont("sg_uifontM")
    local pageSize = surface.GetTextSize("Page 0 of 0")

	local header2Size = surface.GetTextSize("Last Online")
	local header3Size = surface.GetTextSize("Rank")
	local waitSizeW, waitSizeH = surface.GetTextSize("Please Wait...")

    -- Main frame
    local Frame = vgui.Create("DFrame")
    Frame:SetSize(ScrW() >= 1020 and 1000 or ScrW() - 20, ScrH() >= 720 and 700 or ScrH() - 20) 
    Frame:Center()
    Frame:SetTitle(self.UIGroupName .. " Administration Console") 
    Frame:SetVisible(true) 
    Frame:SetDraggable(true)
    Frame:ShowCloseButton(true) 
    Frame:MakePopup()
    Frame.OnClose = function() self:adminMenu(true) end
    Frame.Paint = function(pnl, w, h)
        draw.RoundedBox(2, 0, 0, w, h, self.UIBackgroundColor)
    end
    Frame.OnScreenSizeChanged = function(pnl, oldScrW, oldScrH)
    	pnl.OnClose = function() end
    	pnl:Close()
    end

    local refreshButton = vgui.Create("DImageButton", Frame)
    refreshButton:SetPos(Frame:GetWide() - 120, 4)
	refreshButton:SetImage("icon16/arrow_refresh.png")
	refreshButton:SizeToContents()

    -- Window title
    local title = vgui.Create("DLabel", Frame)
    title:SetPos((Frame:GetWide() - titleSize) / 2, 40)
    title:SetFont("sg_uifontXL")
    title:SetText(titleText)
    title:SetWrap(false)
    title:SizeToContents()

    -- Setup local variables used for positioning elements depending on if small window mode is used
    local managementParent = Frame
    local memberListParent = Frame

    local xShiftManagement = 26
    local yShiftManagement = 100
    local xShiftMemberList = 0
    local yShiftMemberList = 300
    if Frame:GetWide() < 1000 or Frame:GetTall() < 700 then
    	-- Setup tab controller and 2 tabs for management and member list if small window mode is used. Modify positioning variables to fit the tabs
		local inspectTabController = vgui.Create("DPropertySheet", Frame)
		inspectTabController:DockMargin(0, 70, 0, 70)
		inspectTabController:Dock(FILL)
	    inspectTabController.Paint = function(pnl, w, h) end

	    managementParent = vgui.Create("DPanel", inspectTabController)
	    managementParent.Paint = function(pnl, w, h) end
	    local managementTab = inspectTabController:AddSheet("Info and Management", managementParent, "icon16/wrench.png")["Tab"]
	    managementTab.Paint = function(pnl, w, h)
	        draw.RoundedBox(2, 0, 0, w, h, self.UIBackgroundColor)
	    end

    	xShiftManagement = 0
    	yShiftManagement = 10

	    memberListParent = vgui.Create("DPanel", inspectTabController)
	    memberListParent.Paint = function(pnl, w, h) end
	    local memberListTab = inspectTabController:AddSheet(self.UIGroupName .. " Members", memberListParent, "icon16/group.png")["Tab"]
	    memberListTab.Paint = function(pnl, w, h)
	        draw.RoundedBox(2, 0, 0, w, h, self.UIBackgroundColor)
	    end

	    xShiftMemberList = 13
		yShiftMemberList = 0
    end

    -- Avartar and inspect target title
	local userAvatar = vgui.Create("DImage", managementParent)
	userAvatar:SetSize(200, 200)
	userAvatar:SetPos(xShiftManagement, yShiftManagement)

    local userTitle = vgui.Create("DLabel", managementParent)
    userTitle:SetPos(xShiftManagement + 210, yShiftManagement)
    userTitle:SetFont("sg_uifontL")
    userTitle:SetText(" ")
    userTitle:SetWrap(false)
    userTitle:SizeToContents()

    -- Detail labels
    local detail1 = vgui.Create("DLabel", managementParent)
    detail1:SetPos(xShiftManagement + 210, yShiftManagement + 50)
    detail1:SetFont("sg_uifontM")
    detail1:SetText(" ")
    detail1:SetWrap(false)
    detail1:SizeToContents()

    local detail2 = vgui.Create("DLabel", managementParent)
    detail2:SetPos(xShiftManagement + 210, yShiftManagement + 80)
    detail2:SetFont("sg_uifontM")
    detail2:SetText(" ")
    detail2:SetWrap(false)
    detail2:SizeToContents()

    local detail3 = vgui.Create("DLabel", managementParent)
    detail3:SetPos(xShiftManagement + 210, yShiftManagement + 110)
    detail3:SetFont("sg_uifontM")
    detail3:SetText(" ")
    detail3:SetWrap(false)
    detail3:SizeToContents()

    -- Action buttons
    local action1 = vgui.Create("DButton", managementParent)
    action1:SetPos(xShiftManagement + 210, yShiftManagement + 150)
    action1:SetSize(120, 40)
    action1:SetFont("sg_uifontButton")
    action1:SetTextColor(color_black)
    action1:SetText(" ")

    local action2 = vgui.Create("DButton", managementParent)
    action2:SetPos(xShiftManagement + 340, yShiftManagement + 150)
    action2:SetSize(180, 40)
    action2:SetFont("sg_uifontButton")
    action2:SetTextColor(color_black)
    action2:SetText(" ")

    local action3 = vgui.Create("DButton", managementParent)
    action3:SetPos(xShiftManagement + 530, yShiftManagement + 150)
    action3:SetSize(220, 40)
    action3:SetFont("sg_uifontButton")
    action3:SetTextColor(color_black)
    action3:SetText(" ")

    local action4 = vgui.Create("DButton", managementParent)
    action4:SetPos(xShiftManagement + 760, yShiftManagement + 150)
    action4:SetSize(70, 40)
    action4:SetFont("sg_uifontButton")
    action4:SetTextColor(color_black)
    action4:SetText(" ")

    -- Page controls
    local nextButton = vgui.Create("DButton", memberListParent)
    nextButton:SetPos(Frame:GetWide() - xShiftMemberList - 50, yShiftMemberList)
    nextButton:SetSize(30, 30)
    nextButton:SetFont("sg_uifontButton")
    nextButton:SetTextColor(color_black)
    nextButton:SetText(">")
    nextButton:SetEnabled(false)

    local pageLabel = vgui.Create("DLabel", memberListParent)
    pageLabel:SetPos(Frame:GetWide() - pageSize - xShiftMemberList - 60, yShiftMemberList)
    pageLabel:SetFont("sg_uifontM")
    pageLabel:SetText("Page 0 of 0")
    pageLabel:SetWrap(false)
    pageLabel:SizeToContents()

    local prevButton = vgui.Create("DButton", memberListParent)
    prevButton:SetPos(Frame:GetWide() - pageSize - xShiftMemberList - 100, yShiftMemberList)
    prevButton:SetSize(30, 30)
    prevButton:SetFont("sg_uifontButton")
    prevButton:SetTextColor(color_black)
    prevButton:SetText("<")
    prevButton:SetEnabled(false)

    -- Member list column headers
    local header1 = vgui.Create("DLabel", memberListParent)
    header1:SetPos(25 - xShiftMemberList, yShiftMemberList + 50)
    header1:SetFont("sg_uifontM")
    header1:SetText("User Name")
    header1:SetWrap(false)
    header1:SizeToContents()

    if Frame:GetWide() >= 1000 then
	    local header2 = vgui.Create("DLabel", memberListParent)
	    header2:SetPos(((Frame:GetWide() - (2 * xShiftMemberList)) - header2Size) / 2, yShiftMemberList + 50)
	    header2:SetFont("sg_uifontM")
	    header2:SetText("Last Online")
	    header2:SetWrap(false)
	    header2:SizeToContents()
	end

    local header3 = vgui.Create("DLabel", memberListParent)
    header3:SetPos(Frame:GetSize() - header3Size - xShiftMemberList - 30, yShiftMemberList + 50)
    header3:SetFont("sg_uifontM")
    header3:SetText("Rank")
    header3:SetWrap(false)
    header3:SizeToContents()

    -- Member list
    local adminList = vgui.Create("DScrollPanel", memberListParent)
	adminList:DockMargin(20 - xShiftMemberList, yShiftMemberList == 300 and yShiftMemberList + 60 or yShiftMemberList + 89, 20 - xShiftMemberList, yShiftMemberList == 300 and 90 or 0)
	adminList:Dock(FILL)

    local waitText = vgui.Create("DLabel", adminList)
    waitText:SetPos((Frame:GetWide() - waitSizeW - 40) / 2, (Frame:GetTall() - waitSizeH - (yShiftMemberList == 300 and 360 or 159) - 90) / 2)
    waitText:SetFont("sg_uifontM")
    waitText:SetText("Please Wait...")
    waitText:SetWrap(false)
    waitText:SizeToContents()

    -- Frame buttons
    local doneButton = vgui.Create("DButton", Frame)
    doneButton:SetPos(26, Frame:GetTall() - 70)
    doneButton:SetSize(200, 50)
    doneButton:SetFont("sg_uifontButton")
    doneButton:SetTextColor(color_black)
    doneButton:SetText("Done")
    doneButton.DoClick = function() Frame:Close() end
    
	-- Setup refresh button function
	refreshButton.DoClick = function()
		net.Start("sg_adminOrgSearch")
		net.WriteString(ply or "")
		net.WriteString(org or "")
		net.WriteUInt(1, 20)
		net.SendToServer()
	end

    -- Add all elements that should be updated to table
    self.inspectElements = {userAvatar, userTitle, detail1, detail2, detail3, action1, action2, action3, action4, adminList, nextButton, pageLabel, prevButton, refreshButton, ""}

	-- Send initial search for immediate population
	net.Start("sg_adminOrgSearch")
	net.WriteString(ply or "")
	net.WriteString(org or "")
	net.WriteUInt(1, 20)
	net.SendToServer()
end

net.Receive("sg_adminOrgReply", function()
	-- Function to handle incoming information
	-- about an inspect target from the server.
	-- Accepts a table containing the data.
	-- Calls the populate function, passing the
	-- data table and an unpacked list of UI
	-- elements.

	populateInspectMenu(net.ReadTable(), unpack(SimpleGangs.inspectElements))
end)