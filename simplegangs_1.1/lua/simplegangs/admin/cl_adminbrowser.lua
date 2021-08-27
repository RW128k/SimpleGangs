--[[
SimpleGangs 1.1

Clientside Administration Console Browser window
file. Handles the creation and population of the
UI with data requested and received from the server.
'Search engine frontend'.

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

local adminElements = {}

local function sendSearch(sb, sc)
	-- Function which simply sends a admin search
	-- request to the server.
	-- Accepts 2 parameters: sb, the search entry
	-- box object, and sc, the search type combobox.
	-- Called when the search box is updated, a
	-- search type is selected and when the go
	-- button is pressed. Sends the contents of
	-- the searchbox as the query, the search type
	-- as the combo selection index, and page number 1.

	net.Start("sg_adminSearch")
	net.WriteString(sb:GetValue())
	net.WriteUInt(sc:GetSelectedID() - 1, 1)
	net.WriteUInt(1, 20)
	net.SendToServer()
end

local function populateAdminMenu(searchResults, adminList, searchBox, searchCombo, searchButton, nextButton, pageLabel, prevButton, header1, header2, header3)
	-- Function to handle the population of the
	-- admin browser window, created by the adminMenu
	-- function below.
	-- Accepts 11 parameters, the first being the
	-- search result data to populate with and the
	-- remaining 10 being UI element objects of which
	-- to update with aforementioned data.
	-- Updates column headers, page buttons & label
	-- and displays the search results in the main
	-- list after clearing it.

	if !IsValid(adminList) or !SimpleGangs.EnableAdmin or !SimpleGangs:checkAdmin(LocalPlayer()) then return end

	surface.SetFont("sg_uifontM")
	local pageSize = surface.GetTextSize("Page " .. searchResults["page"] .. " of " .. searchResults["pages"])

	local Frame = adminList:GetParent()

	if searchResults["searchType"] == 0 then
		-- Update column headers for search type gang
	    local header2Size = surface.GetTextSize("Members")
	    local header3Size = surface.GetTextSize("Bank")

		header1:SetText(SimpleGangs.UIGroupName .. " Name")
		header1:SetPos(25, 200)
		header1:SizeToContents()
		header2:SetText("Members")
		header2:SetPos(Frame:GetWide() >= 1000 and (Frame:GetWide() - header2Size) / 2 or Frame:GetWide() - header2Size - 30, 200)
		header2:SizeToContents()
		if header3 != nil and Frame:GetWide() >= 1000 then
			header3:SetText("Bank")
			header3:SetPos(Frame:GetWide() - header3Size - 30, 200)
			header3:SizeToContents()
		end
	else
		-- Update column headers for search type member
	    local header2Size = surface.GetTextSize(SimpleGangs.UIGroupName)
	    local header3Size = surface.GetTextSize("Rank")

		header1:SetText("User Name")
		header1:SetPos(25, 200)
		header1:SizeToContents()
		header2:SetText(SimpleGangs.UIGroupName)
		header2:SetPos(Frame:GetWide() >= 1000 and (Frame:GetWide() - header2Size) / 2 or Frame:GetWide() - header2Size - 30, 200)
		header2:SizeToContents()
		if header3 != nil and Frame:GetWide() >= 1000 then
			header3:SetText("Rank")
			header3:SetPos(Frame:GetWide() - header3Size - 30, 200)
			header3:SizeToContents()
		end
	end

	-- Update page buttons & label
	pageLabel:SetText("Page " .. searchResults["page"] .. " of " .. searchResults["pages"])
	pageLabel:SizeToContents()
	pageLabel:SetPos(Frame:GetWide() - 60 - pageSize, 150)
	prevButton:SetPos(Frame:GetWide() - 100 - pageSize, 150)

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
		net.Start("sg_adminSearch")
		net.WriteString(searchResults["searchQuery"])
		net.WriteUInt(searchResults["searchType"], 1)
		net.WriteUInt(searchResults["page"] + 1, 20)
		net.SendToServer()
	end

	prevButton.DoClick = function()
		net.Start("sg_adminSearch")
		net.WriteString(searchResults["searchQuery"])
		net.WriteUInt(searchResults["searchType"], 1)
		net.WriteUInt(searchResults["page"] - 1, 20)
		net.SendToServer()
	end

	-- Resize search controls so they dont overlap page buttons
	searchBox:SetSize(Frame:GetWide() - (200 + pageSize) > 400 and 200 or (Frame:GetWide() - (200 + pageSize)) / 2, 30)
	searchCombo:SetPos(searchBox:GetWide() + 30, 150)
	searchCombo:SetSize(Frame:GetWide() - (200 + pageSize) > 400 and 200 or (Frame:GetWide() - (200 + pageSize)) / 2, 30)
	searchButton:SetPos(searchCombo:GetPos() + searchCombo:GetWide() + 10, 150)

	-- Clear result list and replace with a new one
	adminList:Remove()
	adminList = vgui.Create("DScrollPanel", Frame)
	adminList:DockMargin(20, 210, 20, 90)
	adminList:Dock(FILL)

	if searchResults["pages"] == 0 then
		-- Empty result set, show no results found
		local failSizeW, failSizeH = surface.GetTextSize("No Results found")
		local failText = vgui.Create("DLabel", adminList)
	    failText:SetPos((Frame:GetWide() - failSizeW - 40) / 2, (Frame:GetTall() - failSizeH - 300) / 2)
	    failText:SetFont("sg_uifontM")
	    failText:SetText("No Results found")
	    failText:SetWrap(false)
	    failText:SizeToContents()
	else
		-- Valid result set, begin population
		local numResults = table.Count(searchResults["searchResults"])
		local countResult = 0

		for identifier, data in pairs(searchResults["searchResults"]) do
			countResult = countResult + 1
			-- Setup derma panel for result with appropriate size and padding
			local resultPanel = adminList:Add("DPanel")
			resultPanel:SetSize(nil, 38)
			if resultPanel == 1 then
				resultPanel:DockMargin(0, 5, 0, 5)
			else
				resultPanel:DockMargin(0, 0, 0, 5)
			end
			resultPanel:Dock(TOP)
			local drawSpacer = countResult != numResults
			-- Setup result attributes based on search type
			local attrib1
			local attrib2
			local attrib3
			if searchResults["searchType"] == 0 then
				attrib1 = identifier
				attrib2 = data[1]
				if DarkRP != nil and SimpleGangs.EnableBank then
					attrib3 = DarkRP.formatMoney(data[2]):gsub("%$", "")
				else
					attrib3 = "---"
				end
			else
				attrib1 = data[1]
				attrib2 = data[2]
				if data[3] == "0" then
					attrib3 = "Member"
				else
					attrib3 = "Owner"
				end
			end
			-- Acutally draw attributes on result panel
			resultPanel.Paint = function(pnl, w, h)
				surface.SetFont("sg_uifontM")
				local attrib1Size = surface.GetTextSize(attrib1)
				local attrib2Size = surface.GetTextSize(attrib2)
				local attrib3Size = surface.GetTextSize(attrib3)

				if searchResults["searchType"] == 0 then
					draw.SimpleText(attrib1Size <= 308 and attrib1 or string.sub(attrib1, 1, 13) .. "...", "sg_uifontM", 41, 0, color_white)
				else
					draw.SimpleText(attrib1Size <= 242 and attrib1 or string.sub(attrib1, 1, 10) .. "...", "sg_uifontM", 41, 0, color_white)
				end

				-- Exempt attribute 3 if using small window mode
				if Frame:GetWide() < 1000 then
					draw.SimpleText(attrib2Size <= 264 and attrib2 or string.sub(attrib2, 1, 12) .. "...", "sg_uifontM", w - 6, 0, color_white, TEXT_ALIGN_RIGHT)
				else
					draw.SimpleText(attrib2Size <= 264 and attrib2 or string.sub(attrib2, 1, 12) .. "...", "sg_uifontM", w / 2, 0, color_white, TEXT_ALIGN_CENTER)					
					if searchResults["searchType"] == 0 then
						surface.SetMaterial(SimpleGangs.guap)
						surface.SetDrawColor(255, 255, 255, 255)
						surface.DrawTexturedRect(w - attrib3Size - 30, 2, 23, 23)
					end
					draw.SimpleText(attrib3, "sg_uifontM", w - 6, 0, color_white, TEXT_ALIGN_RIGHT)
					if drawSpacer then
						draw.RoundedBox(0, 0, h - 1, w, 1, color_white)
					end
				end
			end
			resultPanel:SetCursor("hand")

			if searchResults["searchType"] == 0 then
				-- For gang search type, set result icon to default gang icon
				local Avatar = vgui.Create("DImage", resultPanel)
				Avatar:SetCursor("hand")
				Avatar:SetSize(32, 32)
				Avatar:SetPos(0, 0)
				Avatar:SetImage("simplegangs/org_icon.png")
				Avatar.OnMousePressed = function()
					Frame:Close()
					SimpleGangs:adminInspect(identifier)
				end
				resultPanel.OnMousePressed = Avatar.OnMousePressed
			else
				-- For member search type, set result icon to member avatar
				local Avatar = vgui.Create("AvatarImage", resultPanel)
				Avatar:SetCursor("hand")
				Avatar:SetSize(32, 32)
				Avatar:SetPos(0, 0)
				Avatar:SetSteamID(identifier, 32)
				Avatar.OnMousePressed = function()
					Frame:Close()
					SimpleGangs:adminInspect(nil, identifier)
				end
				resultPanel.OnMousePressed = Avatar.OnMousePressed
			end
		end
	end

	-- Add all elements that should be updated to table
	adminElements = {adminList, searchBox, searchCombo, searchButton, nextButton, pageLabel, prevButton, header1, header2, header3}
end

function SimpleGangs:adminMenu(callFromInspect)
	-- Function to handle the creation of the
	-- admin browser window, which is later
	-- populated by the populateAdminMenu function
	-- above.
	-- Accepts 1 parameter, which is a boolean that
	-- will allow the window to be constructed
	-- even if an admin inspect window is open.
	-- Creates all the user interface components
	-- populating them with constant or placeholder
	-- data as well as setting up the functions of
	-- the top right search controls.

	if IsValid(adminElements[1]) or (IsValid(self.inspectElements[1]) and !callFromInspect) or !self.EnableAdmin then return end

	-- Prevent construction and display error if user is not in the admin pool
	if !self:checkAdmin(LocalPlayer()) then
		local infoBox = Derma_Message("You must be a Server Administrator to use this command!", "Error", "OK")
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
    local descText = "Select " .. self.article .. " " .. self.UIGroupName .. " to manage, or Search for a specific user or " .. self.UIGroupName .. " Below."
    local descSize = surface.GetTextSize(descText)
    if descSize > (ScrW() >= 1020 and 1000 or ScrW() - 20) then
    	descText = "Search for & Select a Member/" .. self.UIGroupName .. " below."
    	descSize = surface.GetTextSize(descText)
    end
    local pageSize = surface.GetTextSize("Page 1 of 0")

    local header2Size = surface.GetTextSize("Members")
    local header3Size = surface.GetTextSize("Bank")
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

	-- Title and description
    local title = vgui.Create("DLabel", Frame)
    title:SetPos((Frame:GetWide() - titleSize) / 2, 40)
    title:SetFont("sg_uifontXL")
    title:SetText(titleText)
    title:SetWrap(false)
    title:SizeToContents()

    local desc = vgui.Create("DLabel", Frame)
    desc:SetPos((Frame:GetWide() - descSize) / 2, 100)
    desc:SetFont("sg_uifontM")
    desc:SetText(descText)
    desc:SetWrap(false)
    desc:SizeToContents()

    -- Search controls
	local searchBox = vgui.Create("DTextEntry", Frame)
	searchBox:SetPos(20, 150)
	searchBox:SetSize(Frame:GetWide() - (200 + pageSize) > 400 and 200 or (Frame:GetWide() - (200 + pageSize)) / 2, 30)
	searchBox:SetFont("sg_uifontButton")
	searchBox:SetPlaceholderText("Search...")

	local searchCombo = vgui.Create("DComboBox", Frame)
	searchCombo:SetPos(searchBox:GetWide() + 30, 150)
	searchCombo:SetSize(Frame:GetWide() - (200 + pageSize) > 400 and 200 or (Frame:GetWide() - (200 + pageSize)) / 2, 30)
	searchCombo:SetFont("sg_uifontButton")
	searchCombo:SetTextColor(color_black)
	searchCombo:AddChoice(self.UIGroupName .. "s")
	searchCombo:AddChoice("Members")
	searchCombo:SetSortItems(false)
	searchCombo:ChooseOptionID(1)

    local searchButton = vgui.Create("DButton", Frame)
    searchButton:SetPos(searchCombo:GetPos() + searchCombo:GetWide() + 10, 150)
    searchButton:SetSize(50, 30)
    searchButton:SetFont("sg_uifontButton")
    searchButton:SetTextColor(color_black)
    searchButton:SetText("Go")

    -- Page controls
    local nextButton = vgui.Create("DButton", Frame)
    nextButton:SetPos(Frame:GetWide() - 50, 150)
    nextButton:SetSize(30, 30)
    nextButton:SetFont("sg_uifontButton")
    nextButton:SetTextColor(color_black)
    nextButton:SetText(">")
    nextButton:SetEnabled(false)

    local pageLabel = vgui.Create("DLabel", Frame)
    pageLabel:SetPos(Frame:GetWide() - 60 - pageSize, 150)
    pageLabel:SetFont("sg_uifontM")
    pageLabel:SetText("Page 0 of 0")
    pageLabel:SetWrap(false)
    pageLabel:SizeToContents()

    local prevButton = vgui.Create("DButton", Frame)
    prevButton:SetPos(Frame:GetWide() - 100 - pageSize, 150)
    prevButton:SetSize(30, 30)
    prevButton:SetFont("sg_uifontButton")
    prevButton:SetTextColor(color_black)
    prevButton:SetText("<")
    prevButton:SetEnabled(false)

    -- Column headers
    local header1 = vgui.Create("DLabel", Frame)
    header1:SetPos(25, 200)
    header1:SetFont("sg_uifontM")
    header1:SetText(self.UIGroupName .. " Name")
    header1:SetWrap(false)
    header1:SizeToContents()

    local header2 = vgui.Create("DLabel", Frame)
    header2:SetPos(Frame:GetWide() >= 1000 and (Frame:GetWide() - header2Size) / 2 or Frame:GetWide() - header2Size - 30, 200)
    header2:SetFont("sg_uifontM")
    header2:SetText("Members")
    header2:SetWrap(false)
    header2:SizeToContents()

    local header3
    if Frame:GetWide() >= 1000 then
	    header3 = vgui.Create("DLabel", Frame)
	    header3:SetPos(Frame:GetWide() - header3Size - 30, 200)
	    header3:SetFont("sg_uifontM")
	    header3:SetText("Bank")
	    header3:SetWrap(false)
	    header3:SizeToContents()
	end

	-- Results list
    local adminList = vgui.Create("DScrollPanel", Frame)
	adminList:DockMargin(20, 210, 20, 90)
	adminList:Dock(FILL)	

    local waitText = vgui.Create("DLabel", adminList)
    waitText:SetPos((Frame:GetWide() - waitSizeW - 40) / 2, (Frame:GetTall() - waitSizeH - 300) / 2)
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

    local delButton = vgui.Create("DButton", Frame)
    delButton:SetPos(236, Frame:GetTall() - 70)
    delButton:SetSize(200, 50)
    delButton:SetFont("sg_uifontButton")
    delButton:SetTextColor(color_black)
    delButton:SetText("Delete All")
    delButton.DoClick = function()
	if IsValid(Frame) then Frame:Close() end
	    local msgBox = Derma_Query("Are you sure you want to delete all " .. self.UIGroupName .. "s and Members?\nThis action cannot be undone!", "Delete all data?", "Yes", function()
			local infoBox
			infoBox = Derma_Message("All Data Deleted!", "Success", "OK")
			infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, self.UIBackgroundColor) end
			infoBox.OnClose = function() self:adminMenu() end
	    	net.Start("sg_adminDelall")
			net.SendToServer()
	    end, "No", function() self:adminMenu() end)
	    msgBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, self.UIBackgroundColor) end    
	end

	-- Setup search function calls
	refreshButton.DoClick = function()
		searchBox:SetValue("")
		searchCombo:ChooseOptionID(1)
	end

	searchButton.DoClick = function() sendSearch(searchBox, searchCombo) end
	searchBox.OnChange = function() sendSearch(searchBox, searchCombo) end
	searchCombo.OnSelect = function() sendSearch(searchBox, searchCombo) end

	-- Add all elements that should be updated to table
    adminElements = {adminList, searchBox, searchCombo, searchButton, nextButton, pageLabel, prevButton, header1, header2, header3}

	-- Send initial search for immediate population
	net.Start("sg_adminSearch")
	net.WriteString("")
	net.WriteUInt(0, 1)
	net.WriteUInt(1, 20)
	net.SendToServer()
end

net.Receive("sg_adminReply", function()
	-- Function to handle incoming search results
	-- from the server.
	-- Accepts a table containing the results.
	-- Calls the populate function, passing the
	-- results table and an unpacked list of
	-- UI elements.
	
	populateAdminMenu(net.ReadTable(), unpack(adminElements))
end)