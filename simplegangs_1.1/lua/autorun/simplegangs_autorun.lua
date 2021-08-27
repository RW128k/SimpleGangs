--[[
SimpleGangs 1.1

Shared autorun file loaded at server and client
startup. Used to define clientside files & resources
as well as loading respective Lua files.

There are no user editable settings located in
this file.

You should follow the configuration guide within
the Owners Manual PDF included with your download.

Should you wish to edit this file and require
advice or assistance, feel free to contact me using
the details provided in the Owners Manual.

© RW128k 2021
--]]


if SERVER then
	-- Marking clientside resource files for download (HUD and UI materials)
	resource.AddFile("materials/simplegangs/armor_icon.png")
	resource.AddFile("materials/simplegangs/hp_icon.png")
	resource.AddFile("materials/simplegangs/job_icon.png")
	resource.AddFile("materials/simplegangs/money_dollar.png")
	resource.AddFile("materials/simplegangs/money_euro.png")
	resource.AddFile("materials/simplegangs/money_pound.png")
	resource.AddFile("materials/simplegangs/money_ruble.png")
	resource.AddFile("materials/simplegangs/money_yen.png")
	resource.AddFile("materials/simplegangs/org_avatar.png")
	resource.AddFile("materials/simplegangs/org_icon.png")
	resource.AddFile("materials/simplegangs/player_icon.png")

	-- Marking clientside Lua files for download
	AddCSLuaFile("simplegangs_config/config.lua")
	AddCSLuaFile("simplegangs/admin/cl_adminbrowser.lua")
	AddCSLuaFile("simplegangs/admin/cl_admininspect.lua")
	AddCSLuaFile("simplegangs/leaderboard/cl_leaderboard.lua")
	AddCSLuaFile("simplegangs/core/cl_invitemenu.lua")
	AddCSLuaFile("simplegangs/core/cl_coremenu.lua")
	AddCSLuaFile("simplegangs/bank/cl_orgbank.lua")
	AddCSLuaFile("simplegangs/misc/cl_hud.lua")
	AddCSLuaFile("simplegangs/cl_init.lua")

	-- Load serverside configuration files
	include("simplegangs_config/config.lua")
	include("simplegangs_config/mysql_config.lua")

	-- Load serverside addon files
	include("simplegangs/admin/sv_adminbrowser.lua")
	include("simplegangs/admin/sv_admininspect.lua")
	include("simplegangs/leaderboard/sv_leaderboard.lua")
	include("simplegangs/core/sv_sendcore.lua")
	include("simplegangs/core/sv_recvcore.lua")
	include("simplegangs/bank/sv_orgbank.lua")
	include("simplegangs/misc/sv_database.lua")
	include("simplegangs/misc/sv_orgchat.lua")
	include("simplegangs/sv_init.lua")
else
	-- Load clientside configuration file
	include("simplegangs_config/config.lua")

	-- Load clientside addon files
	include("simplegangs/admin/cl_adminbrowser.lua")
	include("simplegangs/admin/cl_admininspect.lua")
	include("simplegangs/leaderboard/cl_leaderboard.lua")
	include("simplegangs/core/cl_invitemenu.lua")
	include("simplegangs/core/cl_coremenu.lua")
	include("simplegangs/bank/cl_orgbank.lua")
	include("simplegangs/misc/cl_hud.lua")
	include("simplegangs/cl_init.lua")
end