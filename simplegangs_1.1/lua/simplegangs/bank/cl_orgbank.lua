--[[
SimpleGangs 1.1

Clientside Gang Bank file. Constructs the basic UI
for depositing and withdrawing cash. Sends request
to server.

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

local function deposit()
	-- Function which simply opens a derma dialogue
	-- box requesting a value to deposit in the
	-- client's gang bank.
	-- Accepts no parameters.
	-- Validates input after submitting then sends to
	-- server for further validation before depositing.
	-- Notifies client via messagebox if input was
	-- valid or invalid and returns to appropriate menu.

	local inputBox = Derma_StringRequest("Deposit Cash", "Enter the Amount of Cash to transfer to " .. SimpleGangs.UIGroupName .. " Bank:", "", function(text)
		-- Validate input
		local val = tonumber(text)
		if SimpleGangs.orgs["all"][LocalPlayer():SteamID64()] == nil then
			local infoBox = Derma_Message("You Must be in " .. SimpleGangs.article .. " " .. SimpleGangs.UIGroupName .. " to deposit money!", "Error", "OK")
			infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
			infoBox.OnClose = deposit
		elseif val == nil or val <= 0 or !(val < 1e300) then
			local infoBox = Derma_Message("Please Enter a Valid Amount!", "Error", "OK")
			infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
			infoBox.OnClose = deposit
		elseif val > LocalPlayer():getDarkRPVar("money") then
			local infoBox = Derma_Message("Insufficient Funds in Wallet! Please Specify a smaller amount!", "Error", "OK")
			infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
			infoBox.OnClose = deposit
		else
			-- Send input to server for further validation
			net.Start("sg_depositOrg")
			net.WriteString(text)
			net.SendToServer()

			local infoBox = Derma_Message("Deposited " .. SimpleGangs.moneySymbol .. DarkRP.formatMoney(val):gsub("%$", "") .. " in " .. SimpleGangs.UIGroupName .. " Bank!", "Success", "OK")
			infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
			infoBox.OnClose = function() SimpleGangs:orgMenu() end
		end
	end, function() SimpleGangs:bankMenu() end, "Deposit", "Back")
	inputBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
end

local function withdraw()
	-- Function which simply opens a derma dialogue
	-- box requesting a value to withdraw from the
	-- client's gang bank.
	-- Accepts no parameters.
	-- Validates input after submitting then sends to
	-- server for further validation before withdrawing.
	-- Notifies client via messagebox if input was
	-- valid or invalid and returns to appropriate menu.

	local inputBox = Derma_StringRequest("Withdraw Cash", "Enter the Amount of Cash to transfer to your Wallet:\nFunds Available: " .. SimpleGangs.moneySymbol .. SimpleGangs:formatBank(SimpleGangs.orgs["bank"]), "", function(text)
		-- Validate input
		local val = tonumber(text)
		if SimpleGangs.orgs["all"][LocalPlayer():SteamID64()] == nil then
			local infoBox = Derma_Message("You Must be in " .. SimpleGangs.article .. " " .. SimpleGangs.UIGroupName .. " to withdraw money!", "Error", "OK")
			infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
			infoBox.OnClose = withdraw
		elseif val == nil or val <= 0 or !(val < 1e300) then
			local infoBox = Derma_Message("Please Enter a Valid Amount!", "Error", "OK")
			infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
			infoBox.OnClose = withdraw
		elseif val > tonumber(SimpleGangs.orgs["bank"]) then
			local infoBox = Derma_Message("Insufficient Funds in Bank! Please Specify a smaller amount!", "Error", "OK")
			infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
			infoBox.OnClose = withdraw
		else
			-- Send input to server for further validation 
			net.Start("sg_withdrawOrg")
			net.WriteString(text)
			net.SendToServer()

			local infoBox = Derma_Message("Withdrew " .. SimpleGangs.moneySymbol .. DarkRP.formatMoney(val):gsub("%$", "") .. " from " .. SimpleGangs.UIGroupName .. " Bank!", "Success", "OK")
			infoBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
			infoBox.OnClose = function() SimpleGangs:orgMenu() end
		end
	end, function() SimpleGangs:bankMenu() end, "Withdraw", "Back")
	inputBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, SimpleGangs.UIBackgroundColor) end
end

function SimpleGangs:bankMenu(oldFrame)
	-- Function which opens a derma dialogue box
	-- box with buttons allowing the client to
	-- deposit and withdraw cash from their gang
	-- bank.
	-- Accepts 1 parameter, which is a derma frame
	-- object that is to be closed when the bank
	-- menu is invoked. When called from the button
	-- in the main menu, the main frame is passed.
	-- Calls the deposit and withdraw functions above
	-- depending on which button was pressed.

	if IsValid(oldFrame) then oldFrame:Close() end
    local msgBox = Derma_Query("Would you like to Deposit Cash into your " .. self.UIGroupName .. " Bank or Withdraw to your wallet?\nYour Wallet: " .. self.moneySymbol .. DarkRP.formatMoney(LocalPlayer():getDarkRPVar("money")):gsub("%$", "") .. "    " .. self.UIGroupName .. " Bank: " .. self.moneySymbol .. self:formatBank(self.orgs["bank"]), self.UIGroupName .. " Bank", "Deposit", deposit, "Withdraw", withdraw, "Cancel", function() self:orgMenu() end)
    msgBox.Paint = function(pnl, w, h) draw.RoundedBox(2, 0, 0, w, h, self.UIBackgroundColor) end
end