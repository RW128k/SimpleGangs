--[[
SimpleGangs 1.1

Clientside main menu file. Constructs and populates
UI automatically with bank value, invites, offline
and online players. Calls invite and bank menus.
Handles all of the main receive net messages, such
as bank, invites, and gangs.

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

local uiElements = {}
local pleaseWait

local function promote(id, name)
	-- Function which simply requests the promotion
	-- of a specified gang member and displays an
	-- information box.
	-- Accepts 2 parameters: id, the 64 bit Steam ID
	-- of the member to promote, and name, the member's
	-- nickname to be displayed in the message box.
	-- Called when a gang owner selects promote in the
	-- user settings window for a member. Sends the
	-- members's ID to the server.

	local infoBox
	infoBox = Derma_Message(name .. " Has been Promoted to Co-Owner!", "Success", "OK")
	infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
	infoBox.OnClose = function() SimpleGangs:orgMenu() end
	net.Start("sg_promoteUser")
	net.WriteString(id)
	net.SendToServer()		
end

local function kick(id, name)
	-- Function which simply requests the ejection
	-- of a specified gang member and displays an
	-- information box.
	-- Accepts 2 parameters: id, the 64 bit Steam ID
	-- of the member to kick, and name, the member's
	-- nickname to be displayed in the message box.
	-- Called when a gang owner selects kick in the
	-- user settings window for a member. Sends the
	-- members's ID to the server.

	local infoBox
	infoBox = Derma_Message(name .. " Has been Kicked from the " .. SimpleGangs.UIGroupName, "Success", "OK")
	infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
	infoBox.OnClose = function() SimpleGangs:orgMenu() end
	net.Start("sg_kickUser")
	net.WriteString(id)
	net.SendToServer()		
end

local function openProfile(Frame, id)
	-- Function which opens a message box with
	-- buttons relating to gang member management.
	-- of a specified gang member and displays an
	-- information box.
	-- Accepts 2 parameters: Frame, a derma frame
	-- object that is to be closed when the window
	-- is invoked. Most likley the Main Menu frame.
	-- And id, the 64 bit Steam ID of the member to
	-- manage.
	-- Called when a gang owner selects a member in
	-- the main menu's online and offline sections.

	local client = LocalPlayer()
	local data = SimpleGangs.orgs["all"][id]
	if SimpleGangs.orgs["all"][client:SteamID64()] != nil and SimpleGangs.orgs["all"][client:SteamID64()][3] == "1" and data != nil and id != client:SteamID64() then
		if IsValid(Frame) then Frame:Close() end

		local msgBox
		if data[3] == "0" then
			-- Provided user is of the member rank (can promote)
			msgBox = Derma_Query("Please select one of the following actions:", "User Settings for " .. data[1], "Promote to Co-Owner", function()
				promote(id, data[1])
			end, "Kick", function()
				kick(id, data[1])
			end, "Show Profile", function()
				SimpleGangs:orgMenu()
				SimpleGangs:viewProfile(id)
			end, "Cancel", function()
				SimpleGangs:orgMenu()
			end)
		else
			-- Provided user is of the owner rank (cannot promote)
			msgBox = Derma_Query("Please select one of the following actions:", "User Settings for " .. data[1], "Kick", function()
				kick(id, data[1])
			end, "Show Profile", function()
				SimpleGangs:orgMenu()
				SimpleGangs:viewProfile(id)
			end, "Cancel", function()
				SimpleGangs:orgMenu()
			end)
		end

	    msgBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end	
	else
		-- View Steam profile if not a gang owner
		SimpleGangs:viewProfile(id)
	end
end

local function createOrg(Frame)
	-- Function which opens an input box requesting
	-- the name for a new gang, which is validated
	-- and sent to the server for creation &
	-- additional validation when submit.
	-- Accepts 1 parameter: Frame, a derma frame
	-- object that is to be closed when the window
	-- is invoked. Most likley the Main Menu frame.
	-- Called when a non gang member selects create
	-- gang in the main menu.

	if IsValid(Frame) then Frame:Close() end
	local ext = ""
	if DarkRP != nil and SimpleGangs.CreateOrgCost != 0 then ext = "\nCost: " .. SimpleGangs.moneySymbol .. SimpleGangs.CreateOrgCost end
	local msgBox = Derma_StringRequest("Create New " .. SimpleGangs.UIGroupName, "Enter the name for your new " .. SimpleGangs.UIGroupName .. ":" .. ext, "", function(text)
		text = string.Trim(text)
		local infoBox
		if DarkRP != nil and SimpleGangs.CreateOrgCost > LocalPlayer():getDarkRPVar("money") then
			infoBox = Derma_Message("Insufficient Funds in Wallet! You do not have enough cash to create " .. SimpleGangs.article .. " " .. SimpleGangs.UIGroupName .. "!", "Error", "OK")
		elseif text == "" then
			infoBox = Derma_Message("Please Enter a Valid " .. SimpleGangs.UIGroupName .. " Name", "Error", "OK")
		elseif string.len(text) > 25 then
			infoBox = Derma_Message(SimpleGangs.UIGroupName .. " name is too long! (Max 25 Characters)", "Error", "OK")
		elseif SimpleGangs.orgs["all"][LocalPlayer():SteamID64()] != nil then
			infoBox = Derma_Message("You are Already a Member of " .. SimpleGangs.article .. " " .. SimpleGangs.UIGroupName .. "!", "Error", "OK")
		else
			-- Please wait dialogue box localized at the top of file. Destructed and replaced by incoming sg_orgMsgbox
			pleaseWait = Derma_Message("Please Wait...", "Processing", "Close")
			pleaseWait.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end

			net.Start("sg_createOrg")
			net.WriteString(text)
			net.SendToServer()
			return
		end
		infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
		infoBox.OnClose = function() createOrg() end
	end, function() SimpleGangs:orgMenu() end, "Create", "Cancel")
	msgBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
end

local function leaveOrg(Frame)
	-- Function which simply asks user to confirm
	-- that they wish to leave their current gang
	-- via a message box. Leave request is sent to
	-- server following confirmation.
	-- Accepts 1 parameter: Frame, a derma frame
	-- object that is to be closed when the window
	-- is invoked. Most likley the Main Menu frame.
	-- Called when a gang member selects leave gang
	-- in the main menu.

	if IsValid(Frame) then Frame:Close() end
    local msgBox = Derma_Query("Are you sure you want to leave your current " .. SimpleGangs.UIGroupName .. "?\nYou won't be able to re-join without an invite!", "Leave " .. SimpleGangs.UIGroupName .. "?", "Yes", function()
		local infoBox
		infoBox = Derma_Message("You have left your " .. SimpleGangs.UIGroupName .. "!", "Success", "OK")
		infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
		infoBox.OnClose = function() SimpleGangs:orgMenu() end
    	net.Start("sg_leaveOrg")
		net.SendToServer()
    end, "No", function() SimpleGangs:orgMenu() end)
    msgBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
end

local function openInv(Frame, id)
	-- Function which opens a message box with
	-- buttons allowing users to accept or decline
	-- a specified gang invitation.
	-- Accepts 2 parameters: Frame, a derma frame
	-- object that is to be closed when the window
	-- is invoked. Most likley the Main Menu frame.
	-- And id, the 64 bit Steam ID of the user who
	-- sent the invite in question.
	-- Called when the client selects an invitation
	-- in the main menu's invite section.

	local data = SimpleGangs.orgs["invites"][id]
	if IsValid(Frame) then Frame:Close() end
    local msgBox = Derma_Query("Please select one of the following actions:", "Invite to '" .. data[2] .. "' from " .. data[1], "Accept", function()
		-- Accept invite
		local infoBox
		infoBox = Derma_Message("You are now a member of '" .. data[2] .. "'!", "Invite Accepted!", "OK")
		infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
		infoBox.OnClose = function() SimpleGangs:orgMenu() end
    	net.Start("sg_acceptInv")
    	net.WriteString(id)
		net.SendToServer()
    end, "Decline", function()
    	-- Decline invite
		local infoBox
		infoBox = Derma_Message("You have declined the invitation to join '" .. data[2] .. "'!\nYou will need another invite if you wish to join in the futute.", "Invite Deleted!", "OK")
		infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
		infoBox.OnClose = function() SimpleGangs:orgMenu() end
    	net.Start("sg_declineInv")
    	net.WriteString(id)
		net.SendToServer()
    end, "Cancel", function() SimpleGangs:orgMenu() end)
    msgBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end	
end

local function updateUI(Frame, org1Label, org2Label, mainList, oldInvCat, oldInvList, oldOnCat, oldOnList, oldOffCat, oldOffList, but1, but2, but3)
	-- Function to handle the population of the
	-- main menu window, created by the orgMenu
	-- function below.
	-- Accepts 13 parameters, all being UI element
	-- objects of the main menu of which to update
	-- with the latest data from the local tables.
	-- Updates the top 2 labels (gang name and
	-- bank balance), enables / disables buttons
	-- based on situation and populates the invite,
	-- online and offline member sections of the
	-- main window.

	if !IsValid(Frame) then return end

	-- Remove old list catagories
	if oldInvList != nil then oldInvList:Remove() end
	if oldInvCat != nil then oldInvCat:Remove() end
	if oldOnList != nil then oldOnList:Remove() end
	if oldOnCat != nil then oldOnCat:Remove() end
	if oldOffList != nil then oldOffList:Remove() end
	if oldOffCat != nil then oldOffCat:Remove() end

	local client = LocalPlayer()

	local org1Size
	local org2Size

	if SimpleGangs.orgs["all"][client:SteamID64()] == nil then
		-- Client is not a member of a gang

		-- Get text sizes
    	surface.SetFont("sg_uifontM")
    	org1Size = surface.GetTextSize("You are not yet a member of " .. SimpleGangs.article .. " " .. SimpleGangs.UIGroupName .. ".")
    	org2Size = surface.GetTextSize("Accept an invite or create your own below:")

    	-- Setup top 2 labels
    	org1Label:SetPos((600 - org1Size) / 2, 100)
    	org1Label:SetText("You are not yet a member of " .. SimpleGangs.article .. " " .. SimpleGangs.UIGroupName .. ".")
    	org1Label:SizeToContents()
    	org2Label:SetPos((600 - org2Size) / 2, 130)
    	org2Label:SetText("Accept an invite or create your own below:")
    	org2Label.Paint = nil

    	-- Setup buttons
    	but1:SetText("Create " .. SimpleGangs.UIGroupName)
    	but1.DoClick = function() createOrg(Frame) end
    	but2:SetDisabled(true)
    	but2:SetCursor("no")
    	if IsValid(but3) and DarkRP != nil and SimpleGangs.EnableBank then
	    	but3:SetDisabled(true)
	    	but3:SetCursor("no")
	    end
	else
		-- Client is a member of a gang

		-- Get text sizes
    	surface.SetFont("sg_uifontM")
    	org1Size = surface.GetTextSize(SimpleGangs.orgs["all"][client:SteamID64()][2])
    	if DarkRP != nil and SimpleGangs.EnableBank then
    		org2Size = surface.GetTextSize("Bank:     " .. SimpleGangs:formatBank(SimpleGangs.orgs["bank"]))
    	else
    		org2Size = surface.GetTextSize("Members: " .. table.Count(SimpleGangs.orgs["all"]))
    	end

    	-- Setup label 1 with gang name
    	org1Label:SetPos((600 - org1Size) / 2, 100)
    	org1Label:SetText(SimpleGangs.orgs["all"][client:SteamID64()][2])
    	org1Label:SizeToContents()
    	-- Setup label 2 with bank balance if DarkRP and bank is enabled or alternatively member count
    	org2Label:SetPos((600 - org2Size) / 2, 130)
    	if DarkRP != nil and SimpleGangs.EnableBank then
    		org2Label:SetText("Bank:     " .. SimpleGangs:formatBank(SimpleGangs.orgs["bank"]))
    		org2Label.Paint = function(pnl, w, h)
    			surface.SetMaterial(SimpleGangs.guap)
				surface.SetDrawColor(210, 210, 210, 255)
				surface.DrawTexturedRect(65, 2, 23, 23)
    		end 
    	else
    		org2Label:SetText("Members: " .. table.Count(SimpleGangs.orgs["all"]))
    		org2Label.Paint = nil
    	end

    	--Setup buttons
    	but1:SetText("Leave " .. SimpleGangs.UIGroupName)
    	but1.DoClick = function() leaveOrg(Frame) end
    	if SimpleGangs.orgs["all"][client:SteamID64()][3] == "1" then
    		but2:SetDisabled(false)
    		but2:SetCursor("hand")
    	else
    		but2:SetDisabled(true)
    		but2:SetCursor("no")
    	end
    	if IsValid(but3) and DarkRP != nil and SimpleGangs.EnableBank then
	    	but3:SetDisabled(false)
	    	but3:SetCursor("hand")
	    end
	end

	-- Create new invite catagory in the main scrollable list, create another list as its contents and setup loop counters
	local inviteList = vgui.Create("DPanel")
	inviteList.Paint = nil

	local inviteNum = table.Count(SimpleGangs.orgs["invites"])

	local countInv = 0

	local inviteCat = mainList:Add("Invites (" .. inviteNum .. ")")

	if inviteNum == 0 and SimpleGangs.orgs["all"][client:SteamID64()] == nil then
    	-- Client has no invites and is not a member of a gang. Display no invites text
    	surface.SetFont("sg_uifontM")
    	local noInvSize = surface.GetTextSize("You have no new invites!")

    	local invitePanel = vgui.Create("DPanel", inviteList)
    	invitePanel:SetSize(nil, 70)
    	invitePanel:DockMargin(0, 0, 0, 5)
    	invitePanel:Dock(TOP)
    	invitePanel.Paint = function(pnl, w, h) draw.RoundedBox(0, 0, h - 1, w, 1, color_white) end

	    local noInvLabel = vgui.Create("DLabel", invitePanel)
	    noInvLabel:SetPos((531 - noInvSize) / 2, 20)
	    noInvLabel:SetFont("sg_uifontM")
	    noInvLabel:SetText("You have no new invites!")
	    noInvLabel:SetWrap(false)
	    noInvLabel:SizeToContents()		
	end

	-- Begin invite list population
	for id, data in pairs(SimpleGangs.orgs["invites"]) do
		countInv = countInv + 1
		-- Setup derma panel for individual invite with appropriate size and padding
		local invitePanel = vgui.Create("DPanel", inviteList)
		invitePanel:SetSize(nil, 70)
		if countInv == 1 then
			invitePanel:DockMargin(0, 5, 0, 5)
		else
			invitePanel:DockMargin(0, 0, 0, 5)
		end
		invitePanel:Dock(TOP)
		local drawSpacer = countInv != inviteNum
		-- Draw invite details on panel
		invitePanel.Paint = function(pnl, w, h)
			surface.SetFont("sg_uifontM")
			local orgNameSize = surface.GetTextSize(data[2])
			surface.SetFont("sg_uifontS")
			local inviterNameSize = surface.GetTextSize(data[1])
			local status
			if !player.GetBySteamID64(id) then
				status = "Offline"
			else
				status = "Online"
			end
			
			draw.SimpleText(orgNameSize <= 440 and data[2] or string.sub(data[2], 1, 19) .. "...", "sg_uifontM", 70, 0, color_white)
			draw.SimpleText("Invited By: " .. (inviterNameSize <= 322 and data[1] or string.sub(data[1], 1, 22) .. "...") .. " (" .. status .. ")", "sg_uifontS", 70, 30, color_white)
			draw.SimpleText("Members: " .. data[3], "sg_uifontS", 70, 45, color_white)
			if drawSpacer then
				draw.RoundedBox(0, 0, h - 1, w, 1, color_white)
			end
		end
		-- Setup click function for invite panel to open invite options
		invitePanel:SetCursor("hand")
		invitePanel.OnMousePressed = function() openInv(Frame, id) end
		-- Set invite icon to inviter's avatar
		local Avatar = vgui.Create("AvatarImage", invitePanel)
		Avatar:SetCursor("hand")
		Avatar:SetSize(64, 64)
		Avatar:SetPos(0, 0)
		Avatar:SetSteamID(id, 64)
		Avatar.OnMousePressed = function() openInv(Frame, id) end
	end
	countInv = 0

	inviteCat:SetContents(inviteList)

	-- Replace old lists and catagories
	local onlineList = oldOnList
	local onlineCat = oldOnCat
	local offlineList = oldOffList
	local offlineCat = oldOffCat

	local online
	local offline

	if SimpleGangs.orgs["all"][client:SteamID64()] == nil then
		-- Client is not in a gang, empty set
		online = {}
		offline = {}
	else
		-- Client is in a gang, obtain seperated online & offline members.
		online, offline = SimpleGangs:sepOnline()

		-- Create new online member catagory in the main scrollable list, create another list as its contents and setup loop counters		
		onlineList = vgui.Create("DPanel")
		onlineList.Paint = nil

		local onlineNum = table.Count(online)

		local countOn = 0

		onlineCat = mainList:Add("Online (" .. onlineNum .. ")")

		-- Begin online member list population
		for id, data in pairs(online) do
			countOn = countOn + 1
			-- Setup derma panel for individual member with appropriate size and padding
			local onlinePanel = vgui.Create("DPanel", onlineList)
			onlinePanel:SetSize(nil, 70)
			if countOn == 1 then
				onlinePanel:DockMargin(0, 5, 0, 5)
			else
				onlinePanel:DockMargin(0, 0, 0, 5)
			end
			onlinePanel:Dock(TOP)
			local drawSpacer = countOn != onlineNum
			-- Setup member attributes
			local role
			if data[3] == "0" then
				role = "Member"
			else
				role = "Owner"
			end
			-- Draw member details on panel
			onlinePanel.Paint = function(pnl, w, h)
				surface.SetFont("sg_uifontM")
				-- Draw nickname, use exact if member is client
				if id == client:SteamID64() then
					local onNameSize = surface.GetTextSize(client:Nick())
					draw.SimpleText(onNameSize <= 440 and client:Nick() or string.sub(client:Nick(), 1, 19) .. "...", "sg_uifontM", 70, 0, color_white)
				else
					local onNameSize = surface.GetTextSize(data[1])
					draw.SimpleText(onNameSize <= 440 and data[1] or string.sub(data[1], 1, 19) .. "...", "sg_uifontM", 70, 0, color_white)
				end

				-- Draw role in gang
				draw.SimpleText(SimpleGangs.UIGroupName .. " " .. role, "sg_uifontS", 70, 30, color_white)
				-- Draw member's player statistics (if still online)
				if IsValid(player.GetBySteamID64(id)) and player.GetBySteamID64(id):Health() != nil then
					-- Get text sizes
					surface.SetFont("sg_uifontS")
					local textWidth1 = surface.GetTextSize(player.GetBySteamID64(id):Health() > 0 and player.GetBySteamID64(id):Health() or 0)
					local textWidth2 = surface.GetTextSize(player.GetBySteamID64(id):Armor())
					local textWidth3, textWidth4
					if DarkRP != nil then
						textWidth3 = surface.GetTextSize(player.GetBySteamID64(id):getDarkRPVar("job"))
						textWidth4 = surface.GetTextSize(DarkRP.formatMoney(player.GetBySteamID64(id):getDarkRPVar("money")):gsub("%$", ""))
					end

					-- Health
					if 90 + textWidth1 < 528 then
						surface.SetMaterial(SimpleGangs.hp)
						surface.SetDrawColor(255, 255, 255, 255)
						surface.DrawTexturedRect(70, 50, 15, 15)
						draw.SimpleText(player.GetBySteamID64(id):Health() > 0 and player.GetBySteamID64(id):Health() or 0, "sg_uifontS", 90, 49, SimpleGangs.color_health)
					end
					-- Armor
					if 115 + textWidth1 + textWidth2 < 528 then
						surface.SetMaterial(SimpleGangs.armor)
						surface.SetDrawColor(255, 255, 255, 255)
						surface.DrawTexturedRect(95 + textWidth1, 50, 15, 15)
						draw.SimpleText(player.GetBySteamID64(id):Armor(), "sg_uifontS", 115 + textWidth1, 49, SimpleGangs.color_armor)
					end
					if DarkRP != nil then
						-- DarkRP job
						if 140 + textWidth1 + textWidth2 + textWidth3 < 528 then
							surface.SetMaterial(SimpleGangs.job)
							surface.SetDrawColor(255, 255, 255, 255)
							surface.DrawTexturedRect(120 + textWidth1 + textWidth2, 50, 15, 15)
							draw.SimpleText(player.GetBySteamID64(id):getDarkRPVar("job"), "sg_uifontS", 140 + textWidth1 + textWidth2, 49, ColorAlpha(player.GetBySteamID64(id):getJobTable()["color"], 255))
						end
						-- DarkRP wallet balance
						if 165 + textWidth1 + textWidth2 + textWidth3 + textWidth4 < 528 then
							surface.SetMaterial(SimpleGangs.guap)
							surface.SetDrawColor(255, 255, 255, 255)
							surface.DrawTexturedRect(145 + textWidth1 + textWidth2 + textWidth3, 50, 15, 15)
							draw.SimpleText(DarkRP.formatMoney(player.GetBySteamID64(id):getDarkRPVar("money")):gsub("%$", ""), "sg_uifontS", 165 + textWidth1 + textWidth2 + textWidth3, 49, SimpleGangs.color_guap)
						end
					end
				end
				if drawSpacer then
					draw.RoundedBox(0, 0, h - 1, w, 1, color_white)
				end
			end
			-- Setup click function for member panel to open user options or view profile depending on rank
			onlinePanel:SetCursor("hand")
			onlinePanel.OnMousePressed = function() openProfile(Frame, id) end
			-- Set invite icon to member's avatar
			local Avatar = vgui.Create("AvatarImage", onlinePanel)
			Avatar:SetCursor("hand")
			Avatar:SetSize(64, 64)
			Avatar:SetPos(0, 0)
			Avatar:SetSteamID(id, 64)
			Avatar.OnMousePressed = function() openProfile(Frame, id) end
		end

		countOn = 0

		-- Remove online catagory if there are no online members
		if onlineNum == 0 then
			onlineList:Remove()
		else
			onlineCat:SetContents(onlineList)
		end
		
		-- Create new offline member catagory in the main scrollable list, create another list as its contents and setup loop counters		
		offlineList = vgui.Create("DPanel")
		offlineList.Paint = nil

		local offlineNum = table.Count(offline)

		local countOff = 0

		offlineCat = mainList:Add("Offline (" .. offlineNum .. ")")

		-- Begin offline member list population
		for id, data in pairs(offline) do
			countOff = countOff + 1
			-- Setup derma panel for individual member with appropriate size and padding
			local offlinePanel = vgui.Create("DPanel", offlineList)
			offlinePanel:SetSize(nil, 70)
			if countOff == 1 then
				offlinePanel:DockMargin(0, 5, 0, 5)
			else
				offlinePanel:DockMargin(0, 0, 0, 5)
			end
			offlinePanel:Dock(TOP)
			local drawSpacer = countOff != offlineNum
			-- Setup member attributes
			local role
			if data[3] == "0" then
				role = "Member"
			else
				role = "Owner"
			end
			-- Draw member details on panel
			offlinePanel.Paint = function(pnl, w, h)
				surface.SetFont("sg_uifontM")
				local offNameSize = surface.GetTextSize(data[1])

				draw.SimpleText(offNameSize <= 440 and data[1] or string.sub(data[1], 1, 19) .. "...", "sg_uifontM", 70, 0, color_white)
				draw.SimpleText(SimpleGangs.UIGroupName .. " " .. role, "sg_uifontS", 70, 30, color_white)
				draw.SimpleText("Last Online: " .. SimpleGangs:getTimeAgo(data[4]) .. " Ago", "sg_uifontS", 70, 45, color_white)
				if drawSpacer then
					draw.RoundedBox(0, 0, h - 1, w, 1, color_white)
				end
			end
			-- Setup click function for member panel to open user options or view profile depending on rank
			offlinePanel:SetCursor("hand")
			offlinePanel.OnMousePressed = function() openProfile(Frame, id) end
			-- Set invite icon to member's avatar
			local Avatar = vgui.Create("AvatarImage", offlinePanel)
			Avatar:SetCursor("hand")
			Avatar:SetSize(64, 64)
			Avatar:SetPos(0, 0)
			Avatar:SetSteamID(id, 64)
			Avatar.OnMousePressed = function() openProfile(Frame, id) end
		end

		countOff = 0

		-- Remove offline catagory if there are no offline members
		if offlineNum == 0 then
			offlineList:Remove()
		else
			offlineCat:SetContents(offlineList)
		end
	end

	-- Add all elements that should be updated to table
    uiElements = {Frame, org1Label, org2Label, mainList, inviteCat, inviteList, onlineCat, onlineList, offlineCat, offlineList, but1, but2, but3}
end

function SimpleGangs:orgMenu()
	-- Function to handle the creation of the
	-- main menu window, which is later populated
	-- by the updateUI function above.
	-- Accepts no parameters.
	-- Creates all the user interface components
	-- populating them with constant or placeholder
	-- data, then calls the main populate function 
	-- (above) to display the latest gang data
	-- stored in local tables.

	if IsValid(uiElements[1]) then return end

	-- Get text sizes
	surface.SetFont("sg_uifontXL")
	local titleSize = surface.GetTextSize(self.UITitle)
    surface.SetFont("sg_uifontM")
    local org1Size = surface.GetTextSize("You are not yet a member of " .. self.article .. " " .. self.UIGroupName .. ".")
    local org2Size = surface.GetTextSize("Accept an invite or create your own below:")

    -- Main frame
    local Frame = vgui.Create("DFrame")
    Frame:SetSize(600, ScrH() >= 720 and 700 or ScrH() - 20) 
    Frame:Center()
    Frame:SetTitle(self.UITitle) 
    Frame:SetVisible(true) 
    Frame:SetDraggable(true)
    Frame:ShowCloseButton(true) 
    Frame:MakePopup()
    Frame.Paint = function(pnl, w, h)
        draw.RoundedBox(2, 0, 0, w, h, self.UIBackgroundColor)
    end
    Frame.OnScreenSizeChanged = function(pnl, oldScrW, oldScrH)
    	pnl.OnClose = function() end
    	pnl:Close()
    end

    local refreshButton = vgui.Create("DImageButton", Frame)
    refreshButton:SetPos(480, 4)
	refreshButton:SetImage("icon16/arrow_refresh.png")
	refreshButton:SizeToContents()
	refreshButton.DoClick = function()
		net.Start("sg_requestOrgs")
		net.SendToServer()
		net.Start("sg_requestInvites")
		net.SendToServer()
		net.Start("sg_requestHud")
		net.SendToServer()
		net.Start("sg_requestBank")
		net.SendToServer()
	end

	-- Window title
    local titleLabel = vgui.Create("DLabel", Frame)
    titleLabel:SetPos((600 - titleSize) / 2, 40)
    titleLabel:SetFont("sg_uifontXL")
    titleLabel:SetText(self.UITitle)
    titleLabel:SetWrap(false)
    titleLabel:SizeToContents()

    -- Top 2 labels used for displaying gang information such as name & bank balance
    local org1Label = vgui.Create("DLabel", Frame)
    org1Label:SetPos((600 - org1Size) / 2, 100)
    org1Label:SetFont("sg_uifontM")
    org1Label:SetText("You are not yet a member of " .. self.article .. " " .. self.UIGroupName .. ".")
    org1Label:SetWrap(false)
    org1Label:SizeToContents()

    local org2Label = vgui.Create("DLabel", Frame)
    org2Label:SetPos((600 - org2Size) / 2, 130)
    org2Label:SetFont("sg_uifontM")
    org2Label:SetText("Accept an invite or create your own below:")
    org2Label:SetWrap(false)
    org2Label:SizeToContents()

	-- Main scrollable list which houses all of the catagories (invites, online and offline members)
	local mainList = vgui.Create("DCategoryList", Frame)
	mainList:DockMargin(20, 150, 20, 120)
	mainList:Dock(FILL)
	mainList.Paint = function(pnl, w, h) end

	-- Placeholder catagories
	local inviteCat = mainList:Add("Invites (0)")
	local inviteList = vgui.Create("DPanel")
	inviteList.Paint = nil
	inviteCat:SetContents(inviteList)

	local onlineCat = mainList:Add("Online (0)")
	local onlineList = vgui.Create("DPanel")
	onlineList.Paint = nil
	onlineCat:SetContents(onlineList)

	local offlineCat = mainList:Add("Offline (0)")
	local offlineList = vgui.Create("DPanel")
	offlineList.Paint = nil
	offlineCat:SetContents(offlineList)

	-- Show gang members on HUD checkbox
	local showHUDBox = vgui.Create("DCheckBox", Frame)
    showHUDBox:SetPos(26, Frame:GetTall() - 100)
    showHUDBox:SetValue(self.showOnHUD)
    showHUDBox.OnChange = function(pnl, isChecked)
    	self.showOnHUD = isChecked
    	net.Start("sg_changeHud")
    	net.WriteBool(self.showOnHUD)
    	net.SendToServer()
    end

    -- Show gang members on HUD clickable label which toggles the checkbox
	local showHUDLabel = vgui.Create("DButton", Frame)
    showHUDLabel:SetPos(45, Frame:GetTall() - 103)
    showHUDLabel:SetFont("sg_uifontS")
    showHUDLabel:SetTextColor(color_white)
    showHUDLabel:SetText("Show " .. self.UIGroupName .. " Members on HUD")
    showHUDLabel:SetWrap(false)
    showHUDLabel:SizeToContents()
    showHUDLabel.Paint = function() end
    showHUDLabel.DoClick = function() showHUDBox:Toggle() end
    showHUDLabel:SetCursor("hand")

    -- Create / leave gang button which changes text and function based on whether client is in a gang or not
    local createOrgButton = vgui.Create("DButton", Frame)
    createOrgButton:SetPos(26, Frame:GetTall() - 70)
    createOrgButton:SetSize(176, 50)
    createOrgButton:SetFont("sg_uifontButton")
    createOrgButton:SetTextColor(color_black)
    createOrgButton:SetText("Create " .. self.UIGroupName)

    -- Invite members button which only is clickable if client is in a gang and is an owner
    local inviteOrgButton = vgui.Create("DButton", Frame)
    inviteOrgButton:SetPos(212, Frame:GetTall() - 70)
    inviteOrgButton:SetSize(176, 50)
    inviteOrgButton:SetFont("sg_uifontButton")
    inviteOrgButton:SetTextColor(color_black)
    inviteOrgButton:SetText("Invite Members")
    inviteOrgButton:SetDisabled(true)
    inviteOrgButton.DoClick = function() self:inviteMenu(Frame) end

    -- Gang bank button which only appears if server is running DarkRP and bank is enabled
    local bankOrgButton
    if DarkRP != nil and self.EnableBank then
	    bankOrgButton = vgui.Create("DButton", Frame)
	    bankOrgButton:SetPos(398, Frame:GetTall() - 70)
	    bankOrgButton:SetSize(176, 50)
	    bankOrgButton:SetFont("sg_uifontButton")
	    bankOrgButton:SetTextColor(color_black)
	    bankOrgButton:SetText(self.UIGroupName .. " Bank")
	    bankOrgButton:SetDisabled(true)
	    bankOrgButton.DoClick = function() self:bankMenu(Frame) end
	end

	-- Add all elements that should be updated to table
    uiElements = {Frame, org1Label, org2Label, mainList, inviteCat, inviteList, onlineCat, onlineList, offlineCat, offlineList, createOrgButton, inviteOrgButton, bankOrgButton}

    -- Populate window with current data
    updateUI(unpack(uiElements))
end

net.Receive("sg_replyOrgs", function()
	-- Function to handle an incoming list of
	-- members of the client's gang.
	-- Accepts a table containing the data.
	-- Updates the local gang table and attempts
	-- to repopulate the main menu if it exists.

	SimpleGangs.orgs["all"] = net.ReadTable()
	updateUI(unpack(uiElements))
end)

net.Receive("sg_replyInvites", function()
	-- Function to handle an incoming list of
	-- invites addressed to the client.
	-- Accepts a table containing the data.
	-- Updates the local invite table and attempts
	-- to repopulate the main menu if it exists.

	SimpleGangs.orgs["invites"] = net.ReadTable()
	updateUI(unpack(uiElements))
end)

net.Receive("sg_replyBank", function()
	-- Function to handle an incoming gang bank
	-- balance of the client's gang.
	-- Accepts a string containing the balance.
	-- Updates the local balance and attempts to
	-- repopulate the main menu if it exists.

	SimpleGangs.orgs["bank"] = net.ReadString()
	updateUI(unpack(uiElements))
end)

net.Receive("sg_orgMsgbox", function()
	-- Function to construct a messagebox with
	-- the title and message provided by the
	-- server. Usually for letting a client
	-- know whether gang creation was successful.
	-- Accepts 2 strings containing the title
	-- and message of the box.
	-- Closes the please wait box and replaces it
	-- with a new one with the provided text.

	local msg = net.ReadString()
	local title = net.ReadString()

	if IsValid(pleaseWait) then pleaseWait:Close() end
	local infoBox = Derma_Message(msg, title, "OK")
	infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
	if title == "Success" then
		infoBox.OnClose = function() SimpleGangs:orgMenu() end
	else
		infoBox.OnClose = function() createOrg() end
	end
end)