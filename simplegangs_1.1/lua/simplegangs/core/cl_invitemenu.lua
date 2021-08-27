--[[
SimpleGangs 1.1

Clientside invite menu file. Handles requesting
and receiving of online players with their gangs.
Also constructs and populates the menu with the
appropriate data. Invoked by main menu.

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

local invPlayerList

local function populateInvMenu(onlineOrgs)
	-- Function to handle the population of the
	-- gang invitation window, created by the
	-- inviteMenu function below.
	-- Accepts 1 parameter, onlineOrgs, a simple
	-- table with Steam IDs as keys and gang names
	-- as values, containing a list of online
	-- players who are members of gangs.
	-- Simply removes the old list of players and
	-- replaces it with a new one which is then
	-- populated with appropriate attributes
	-- obtained from the onlineOrgs table.

	if !IsValid(invPlayerList) then return end

	local Frame = invPlayerList:GetParent()

	-- Clear online player list and replace with a new one
	invPlayerList:Remove()

	invPlayerList = vgui.Create("DScrollPanel", Frame)
	invPlayerList:DockMargin(20, 160, 20, 90)
	invPlayerList:Dock(FILL)

	-- Setup loop counters
	local numPlayers = player.GetCount()
	local countPly = 0

	-- Begin population
	for _, ply in ipairs(player.GetAll()) do
		countPly = countPly + 1
		-- Setup derma panel for player row with appropriate size and padding
		local plyPanel = invPlayerList:Add("DPanel")
		plyPanel:SetSize(nil, 38)
		if plyPanel == 1 then
			plyPanel:DockMargin(0, 5, 0, 5)
		else
			plyPanel:DockMargin(0, 0, 0, 5)
		end
		plyPanel:Dock(TOP)
		local drawSpacer = countPly != numPlayers
		-- Setup player attributes
		local plyName = ply:Nick()
		local orgName
		if onlineOrgs[ply:SteamID64()] != nil then
			orgName = onlineOrgs[ply:SteamID64()]
		else
			orgName = "---"
		end
		local money
		if DarkRP != nil then
			money = DarkRP.formatMoney(ply:getDarkRPVar("money")):gsub("%$", "")
		else
			money = "---"
		end
		-- Acutally draw attributes on result panel
		plyPanel.Paint = function(pnl, w, h)
			surface.SetFont("sg_uifontM")
			local nameSize = surface.GetTextSize(plyName)
			local orgSize = surface.GetTextSize(orgName)
			local moneySize = surface.GetTextSize(money)

			draw.SimpleText(nameSize <= 242 and plyName or string.sub(plyName, 1, 10) .. "...", "sg_uifontM", 41, 0, color_white)

			-- Exempt attribute 3 (money) if using small window mode
			if Frame:GetWide() < 1000 then
				draw.SimpleText(orgSize <= 264 and orgName or string.sub(orgName, 1, 12) .. "...", "sg_uifontM", w - 6, 0, color_white, TEXT_ALIGN_RIGHT)
			else
				draw.SimpleText(orgSize <= 264 and orgName or string.sub(orgName, 1, 12) .. "...", "sg_uifontM", w / 2, 0, color_white, TEXT_ALIGN_CENTER)

				surface.SetMaterial(SimpleGangs.guap)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(w - moneySize - 30, 2, 23, 23)
				draw.SimpleText(money, "sg_uifontM", w - 6, 0, color_white, TEXT_ALIGN_RIGHT)
				if drawSpacer then
					draw.RoundedBox(0, 0, h - 1, w, 1, color_white)
				end
			end
		end
		-- Setup click function for player panel to send invitation to server
		plyPanel:SetCursor("hand")
		plyPanel.OnMousePressed = function()
			if !IsValid(ply) or ply:SteamID64() == nil then return end
			if onlineOrgs[ply:SteamID64()] != nil and onlineOrgs[ply:SteamID64()] == SimpleGangs.orgs["all"][LocalPlayer():SteamID64()][2] then return end
			if IsValid(Frame) then
				Frame.OnClose = function() end
				Frame:Close()
			end

			local infoBox
			infoBox = Derma_Message("Invited " .. ply:Nick() .. " to the " .. SimpleGangs.UIGroupName .. "!", "Success", "OK")
			infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
			infoBox.OnClose = function() SimpleGangs:inviteMenu() end
	    	net.Start("sg_inviteUser")
	    	net.WriteString(ply:SteamID64())
			net.SendToServer()
		end
		-- Set player icon to respective avatar
		local Avatar = vgui.Create("AvatarImage", plyPanel)
		Avatar:SetCursor("hand")
		Avatar:SetSize(32, 32)
		Avatar:SetPos(0, 0)
		Avatar:SetPlayer(ply, 32)
		Avatar.OnMousePressed = plyPanel.OnMousePressed
	end
end

function SimpleGangs:inviteMenu(oldFrame)
	-- Function to handle the creation of the
	-- gang invitation window, which is later
	-- populated by the populateInvMenu function
	-- above.
	-- Accepts 1 parameter, which is a derma frame
	-- object that is to be closed when the invite
	-- menu is invoked. When called from the button
	-- in the main menu, the main frame is passed.
	-- Creates all the user interface components
	-- populating them with constant or placeholder
	-- data, and making the inital request to
	-- the server for the list of online players
	-- and their gangs to populate with.

	if IsValid(oldFrame) then oldFrame:Close() end

	-- Get text sizes
	surface.SetFont("sg_uifontXL")
	local titleSize = surface.GetTextSize("Invite Members")
    surface.SetFont("sg_uifontM")
    local descSize = surface.GetTextSize(ScrW() >= 1020 and "Please select the user to invite from the list of online players below." or "Please select the user to invite from the list below.")
    local header2Size = surface.GetTextSize("Current " .. self.UIGroupName)
    local header3Size = surface.GetTextSize("Cash")
    local waitSizeW, waitSizeH = surface.GetTextSize("Please Wait...")

    -- Main frame
    local Frame = vgui.Create("DFrame")
    Frame:SetSize(ScrW() >= 1020 and 1000 or ScrW() - 20, ScrH() >= 720 and 700 or ScrH() - 20)
    Frame:Center()
    Frame:SetTitle("Invite Members") 
    Frame:SetVisible(true) 
    Frame:SetDraggable(true)
    Frame:ShowCloseButton(true) 
    Frame:MakePopup()
    Frame.OnClose = function() self:orgMenu() end
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
	refreshButton.DoClick = function()
		net.Start("sg_requestOnline")
		net.SendToServer()
	end

    -- Title and description
    local title = vgui.Create("DLabel", Frame)
    title:SetPos((Frame:GetWide() - titleSize) / 2, 40)
    title:SetFont("sg_uifontXL")
    title:SetText("Invite Members")
    title:SetWrap(false)
    title:SizeToContents()

    local desc = vgui.Create("DLabel", Frame)
    desc:SetPos((Frame:GetWide() - descSize) / 2, 100)
    desc:SetFont("sg_uifontM")
    desc:SetText(ScrW() >= 1020 and "Please select the user to invite from the list of online players below." or "Please select the user to invite from the list below.")
    desc:SetWrap(false)
    desc:SizeToContents()

    -- Column headers
    local header1 = vgui.Create("DLabel", Frame)
    header1:SetPos(25, 150)
    header1:SetFont("sg_uifontM")
    header1:SetText("Player")
    header1:SetWrap(false)
    header1:SizeToContents()

    local header2 = vgui.Create("DLabel", Frame)
    header2:SetPos(Frame:GetWide() >= 1000 and (Frame:GetWide() - header2Size) / 2 or Frame:GetWide() - header2Size - 30, 150)
    header2:SetFont("sg_uifontM")
    header2:SetText("Current " .. self.UIGroupName)
    header2:SetWrap(false)
    header2:SizeToContents()

    if Frame:GetWide() >= 1000 then
	    local header3 = vgui.Create("DLabel", Frame)
	    header3:SetPos(Frame:GetWide() - header3Size - 30, 150)
	    header3:SetFont("sg_uifontM")
	    header3:SetText("Cash")
	    header3:SetWrap(false)
	    header3:SizeToContents()
	end

    -- Player list (localized at the top of file)
    invPlayerList = vgui.Create("DScrollPanel", Frame)
	invPlayerList:DockMargin(20, 160, 20, 90)
	invPlayerList:Dock(FILL)	

    local waitText = vgui.Create("DLabel", invPlayerList)
    waitText:SetPos((Frame:GetWide() - waitSizeW - 40) / 2, (Frame:GetTall() - waitSizeH - 250) / 2)
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

	-- Send initial request for immediate population
	net.Start("sg_requestOnline")
	net.SendToServer()
end

net.Receive("sg_replyOnline", function()
	-- Function to handle an incoming list of online
	-- players and their gangs from the server.
	-- Accepts a table containing the data.
	-- Calls the populate function, passing the
	-- received data table.

	populateInvMenu(net.ReadTable())
end)