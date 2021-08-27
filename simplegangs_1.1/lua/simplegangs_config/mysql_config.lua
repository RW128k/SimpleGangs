--[[
SimpleGangs 1.1

Serverside MySQL configuration file.

This file houses all the settings relating to MySQL
for use with SimpleGangs.

You should NOT edit this file if you do not have a
MySQL Database that you wish to use with SimpleGangs.

A detailed guide explaining how to edit this
file can be found in Section 5: MySQL and the
Database of the Owners Manual PDF included with your
download.

YOU ARE STRONGLY ADVISED TO READ THE MANUAL BEFORE
EDITING THIS FILE.

If you have any difficulty changing these settings
or require advice or assistance, feel free to
contact me using the details provided in the Owners
Manual.

© RW128k 2021
--]]

SimpleGangs = SimpleGangs or {}


-- SIMPLEGANGS MYSQL SETTINGS

SimpleGangs.orgsUseMySQL = false

SimpleGangs.orgDBHost = "host"
SimpleGangs.orgDBPort = 3306
SimpleGangs.orgDBDatabase = "database"
SimpleGangs.orgDBUsername = "username"
SimpleGangs.orgDBPassword = "password"

-- DARKRP MYSQL SETTINGS

SimpleGangs.darkrpUseMySQL = false

SimpleGangs.darkrpDBHost = "host"
SimpleGangs.darkrpDBPort = 3306
SimpleGangs.darkrpDBDatabase = "database"
SimpleGangs.darkrpDBUsername = "username"
SimpleGangs.darkrpDBPassword = "password"