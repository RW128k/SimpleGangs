--[[
SimpleGangs 1.1

Clientside Leaderboard window file. Handles the
requesting and reception of leaderboard data from
the server. Constructs and populates UI.

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

local lbTabController

local function populateLeaderboard(lbTbl)
	-- Function to handle the population of the
	-- leaderboard window, created by the
	-- leaderboardMenu function below.
	-- Accepts 1 parameter, lbTbl, a table consisting
	-- of a list of the top 10 gang bank balances and
	-- DarkRP wallets, as well as the client's gang
	-- bank and wallet values.
	-- Simply removes the old tab controller and
	-- replaces it with a new one with relevant tabs
	-- which are populated with the data in the
	-- passed table.

	if !IsValid(lbTabController) or !SimpleGangs.EnableLeaderboard then return end

	local Frame = lbTabController:GetParent()

	-- Clear tab controller and replace with a new one
	lbTabController:Remove()

	lbTabController = vgui.Create("DPropertySheet", Frame)
	lbTabController:DockMargin(0, 70, 0, 90)
	lbTabController:Dock(FILL)
    lbTabController.Paint = function(pnl, w, h) end

    -- Populate gank bank leaderboard (if enabled and data is provided)
    if SimpleGangs.EnableBank and DarkRP != nil and lbTbl["lbOrgs"] != nil and SimpleGangs.ShowOrgLeaderboard then
    	-- Setup derma panel for leaderboard. Main panel nested inside a scroll panel for use in small window mode
		local bankContainer = vgui.Create("DScrollPanel", lbTabController)
		local bankPanel = bankContainer:Add("DPanel")
		bankPanel:SetSize(nil, (lbTbl["plyOrg"] != nil and lbTbl["plyOrg"][1] > table.Count(lbTbl["lbOrgs"])) and (table.Count(lbTbl["lbOrgs"]) * 35) + 31 or ((table.Count(lbTbl["lbOrgs"]) - 1) * 35) + 31)
		bankPanel:DockMargin(0, 0, 10, 0)
		bankPanel:Dock(TOP)
		-- Begin leaderboard population
		bankPanel.Paint = function(pnl, w, h)
			if table.Count(lbTbl["lbOrgs"]) == 0 and lbTbl["plyOrg"] == nil then return end

			-- Draw each item in the leaderboard
			for pos, data in ipairs(lbTbl["lbOrgs"]) do
				surface.SetFont("sg_uifontM")
				local nameSize = surface.GetTextSize(pos .. ". " .. data["org"])
				local moneySize = surface.GetTextSize(DarkRP.formatMoney(tonumber(data["money"])):gsub("%$", ""))
				-- Set to gold if item is player's gang
				local textCol
				if lbTbl["plyOrg"] != nil and lbTbl["plyOrg"][1] == pos then
					textCol = SimpleGangs.color_gold
				else
					textCol = color_white
				end

				draw.SimpleText(nameSize <= 284 and pos .. ". " .. data["org"] or string.sub(pos .. ". " .. data["org"], 1, 14) .. "...", "sg_uifontM", 0, (pos - 1) * 35, textCol)
				draw.SimpleText(DarkRP.formatMoney(tonumber(data["money"])):gsub("%$", ""), "sg_uifontM", bankPanel:GetWide() - moneySize, (pos - 1) * 35, textCol)
				surface.SetMaterial(SimpleGangs.guap)
				surface.SetDrawColor(textCol:Unpack())
				surface.DrawTexturedRect(bankPanel:GetWide() - moneySize - 25, ((pos - 1) * 35) + 2, 23, 23)

				draw.RoundedBox(0, 0, ((pos - 1) * 35) + 30, bankPanel:GetWide(), 1, color_white)
			end

			-- Draw player's gang bank rank at the bottom of the leaderboard if it exists and is not in the top 10
			if lbTbl["plyOrg"] != nil and lbTbl["plyOrg"][1] > table.Count(lbTbl["lbOrgs"]) then
				surface.SetFont("sg_uifontM")
				local nameSize = surface.GetTextSize(lbTbl["plyOrg"][1] .. ". " .. lbTbl["plyOrg"][2])
				local moneySize = surface.GetTextSize(DarkRP.formatMoney(tonumber(lbTbl["plyOrg"][3])):gsub("%$", ""))

				draw.SimpleText(nameSize <= 284 and lbTbl["plyOrg"][1] .. ". " .. lbTbl["plyOrg"][2] or string.sub(lbTbl["plyOrg"][1] .. ". " .. lbTbl["plyOrg"][2], 1, 14) .. "...", "sg_uifontM", 0, table.Count(lbTbl["lbOrgs"]) * 35, SimpleGangs.color_gold)
				draw.SimpleText(DarkRP.formatMoney(tonumber(lbTbl["plyOrg"][3])):gsub("%$", ""), "sg_uifontM", bankPanel:GetWide() - moneySize, table.Count(lbTbl["lbOrgs"]) * 35, SimpleGangs.color_gold)
				surface.SetMaterial(SimpleGangs.guap)
				surface.SetDrawColor(253, 185, 19, 255)
				surface.DrawTexturedRect(bankPanel:GetWide() - moneySize - 25, (table.Count(lbTbl["lbOrgs"]) * 35) + 2, 23, 23)
				
				draw.RoundedBox(0, 0, (table.Count(lbTbl["lbOrgs"]) * 35) + 30, bankPanel:GetWide(), 1, color_white)
			end
		end

		-- Add the leaderboard scroll panel to the tab controller as a new tab
		local bankTab = lbTabController:AddSheet(SimpleGangs.UIGroupName .. " Bank Leaderboard", bankContainer, "icon16/coins.png")["Tab"]
	    bankTab.Paint = function(pnl, w, h)
	        draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor)
	    end
	end

	-- Populate DarkRP wallet leaderboard (if enabled and data is provided)
	if DarkRP != nil and lbTbl["lbWallet"] != nil and SimpleGangs.ShowWalletLeaderboard then
		-- Setup derma panel for leaderboard. Main panel nested inside a scroll panel for use in small window mode
		local walletContainer = vgui.Create("DScrollPanel", lbTabController)
		local walletPanel = walletContainer:Add("DPanel")
		walletPanel:SetSize(nil, (lbTbl["plyWallet"] != nil and lbTbl["plyWallet"][1] > table.Count(lbTbl["lbWallet"])) and (table.Count(lbTbl["lbWallet"]) * 35) + 31 or ((table.Count(lbTbl["lbWallet"]) - 1) * 35) + 31)
		walletPanel:DockMargin(0, 0, 10, 0)
		walletPanel:Dock(TOP)
		-- Begin leaderboard population
		walletPanel.Paint = function(pnl, w, h)
			if table.Count(lbTbl["lbWallet"]) == 0 and lbTbl["plyWallet"] == nil then return end

			-- Draw each item in the leaderboard
			for pos, data in ipairs(lbTbl["lbWallet"]) do
				surface.SetFont("sg_uifontM")
				local nameSize = surface.GetTextSize(pos .. ". " .. data["rpname"])
				local moneySize = surface.GetTextSize(DarkRP.formatMoney(tonumber(data["wallet"])):gsub("%$", ""))
				-- Set to gold if item is player's wallet
				local textCol
				if lbTbl["plyWallet"] != nil and lbTbl["plyWallet"][1] == pos then
					textCol = SimpleGangs.color_gold
				else
					textCol = color_white
				end

				draw.SimpleText(nameSize <= 284 and pos .. ". " .. data["rpname"] or string.sub(pos .. ". " .. data["rpname"], 1, 14) .. "...", "sg_uifontM", 0, (pos - 1) * 35, textCol)
				draw.SimpleText(DarkRP.formatMoney(tonumber(data["wallet"])):gsub("%$", ""), "sg_uifontM", walletPanel:GetWide() - moneySize, (pos - 1) * 35, textCol)
				surface.SetMaterial(SimpleGangs.guap)
				surface.SetDrawColor(textCol:Unpack())
				surface.DrawTexturedRect(walletPanel:GetWide() - moneySize - 25, ((pos - 1) * 35) + 2, 23, 23)

				draw.RoundedBox(0, 0, ((pos - 1) * 35) + 30, walletPanel:GetWide(), 1, color_white)
			end

			-- Draw player's wallet rank at the bottom of the leaderboard if it exists and is not in the top 10
			if lbTbl["plyWallet"] != nil and lbTbl["plyWallet"][1] > table.Count(lbTbl["lbWallet"]) then
				surface.SetFont("sg_uifontM")
				local nameSize = surface.GetTextSize(lbTbl["plyWallet"][1] .. ". " .. lbTbl["plyWallet"][2])
				local moneySize = surface.GetTextSize(DarkRP.formatMoney(tonumber(lbTbl["plyWallet"][3])):gsub("%$", ""))
				
				draw.SimpleText(nameSize <= 284 and lbTbl["plyWallet"][1] .. ". " .. lbTbl["plyWallet"][2] or string.sub(lbTbl["plyWallet"][1] .. ". " .. lbTbl["plyWallet"][2], 1, 14) .. "...", "sg_uifontM", 0, table.Count(lbTbl["lbWallet"]) * 35, SimpleGangs.color_gold)
				draw.SimpleText(DarkRP.formatMoney(tonumber(lbTbl["plyWallet"][3])):gsub("%$", ""), "sg_uifontM", walletPanel:GetWide() - moneySize, table.Count(lbTbl["lbWallet"]) * 35, SimpleGangs.color_gold)
				surface.SetMaterial(SimpleGangs.guap)
				surface.SetDrawColor(253, 185, 19, 255)
				surface.DrawTexturedRect(walletPanel:GetWide() - moneySize - 25, (table.Count(lbTbl["lbWallet"]) * 35) + 2, 23, 23)
				
				draw.RoundedBox(0, 0, (table.Count(lbTbl["lbWallet"]) * 35) + 30, walletPanel:GetWide(), 1, color_white)
			end
		end

		-- Add the leaderboard scroll panel to the tab controller as a new tab
		local walletTab = lbTabController:AddSheet("Wallet Leaderboard", walletContainer, "icon16/money.png")["Tab"]
	    walletTab.Paint = function(pnl, w, h)
	        draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor)
	    end
	end
end

function SimpleGangs:leaderboardMenu()
	-- Function to handle the creation of the
	-- leaderboard window, which is later
	-- populated by the populateLeaderboard
	-- function above.
	-- Accepts no parameters.
	-- Creates all the user interface components
	-- populating them with constant or placeholder
	-- data, and making the inital request to the
	-- server for leaderboard data which is used to
	-- to populate the UI.

	if IsValid(lbTabController) or !self.EnableLeaderboard then return end

	-- Get text sizes
	surface.SetFont("sg_uifontXL")
	local titleSize = surface.GetTextSize("Leaderboard")

    -- Main frame
    local Frame = vgui.Create("DFrame")
    Frame:SetSize(600, ScrH() >= 640 and 620 or ScrH() - 20)
    Frame:Center()
    Frame:SetTitle("Leaderboard") 
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
	    net.Start("sg_requestLeaderboard")
		net.SendToServer()
	end

    -- Window title
    local titleLabel = vgui.Create("DLabel", Frame)
    titleLabel:SetPos((600 - titleSize) / 2, 40)
    titleLabel:SetFont("sg_uifontXL")
    titleLabel:SetText("Leaderboard")
    titleLabel:SetWrap(false)
    titleLabel:SizeToContents()

	-- Main tab controller (localized at the top of file)
	lbTabController = vgui.Create("DPropertySheet", Frame)
	lbTabController:DockMargin(0, 70, 0, 90)
	lbTabController:Dock(FILL)
    lbTabController.Paint = function(pnl, w, h) end	

    -- Frame buttons
    local doneButton = vgui.Create("DButton", Frame)
    doneButton:SetPos(26, Frame:GetTall() - 70)
    doneButton:SetSize(200, 50)
    doneButton:SetFont("sg_uifontButton")
    doneButton:SetTextColor(color_black)
    doneButton:SetText("Done")
    doneButton.DoClick = function() Frame:Close() end

	-- Send initial request for immediate population
	net.Start("sg_requestLeaderboard")
	net.SendToServer()
end

net.Receive("sg_replyLeaderboard", function()
	-- Function to handle an incoming table of
	-- leaderboard data from the server.
	-- Accepts a table containing the data.
	-- Calls the populate function, passing the
	-- received data table.	
	
	populateLeaderboard(net.ReadTable())
end)