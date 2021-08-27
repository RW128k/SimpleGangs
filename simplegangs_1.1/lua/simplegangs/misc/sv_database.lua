--[[
SimpleGangs 1.1

Serverside Database setup file. Defines 2 functions
for querying SimpleGangs and DarkRP databases. Handles
SQL errors and switches between SQLite and MySQL.

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

pcall(require, "mysqloo")

local orgDB, darkrpDB

if mysqloo != nil and SimpleGangs.orgsUseMySQL then
	-- Define database query function with appropriate
	-- callback based on whether MySQL or SQLite is
	-- chosen as the primary DBMS.
	-- This function is used for all queries to the
	-- SimpleGangs database. For DarkRP queries, see
	-- below.
	-- Database query function accepts 2 parameters:
	-- query, the SQL query to execute which is a string
	-- and callback, a function to run on query success
	-- which accepts 1 parameter of the query response.

	-- Setup MySQL connection
	orgDB = mysqloo.connect(SimpleGangs.orgDBHost, SimpleGangs.orgDBUsername, SimpleGangs.orgDBPassword, SimpleGangs.orgDBDatabase, SimpleGangs.orgDBPort)

	orgDB.onConnected = function(db)
		MsgC(Color(0, 255, 255), "[SimpleGangs] ", Color(0, 255, 0), "Success: Connection Established between Server and SimpleGangs MySQL Database\n")
	end
	orgDB.onConnectionFailed = function(db, err)
		MsgC(Color(0, 255, 255), "[SimpleGangs] ", Color(255, 0, 0), "Error: Connection to SimpleGangs MySQL Database Failed. The following Error Message was provided:\n", err, "\n")
		
		-- Fallback to SQLite query function
		function SimpleGangs:orgDBQuery(query, callback)
			local data = sql.Query(query)
			if callback != nil then callback(data) end
		end
	end

	-- MySQL query function
	function SimpleGangs:orgDBQuery(query, callback)
		local q = orgDB:query(query)

		q.onSuccess = function(self, data)
			if callback != nil then callback(data) end
		end
		q.onError = function(self, err, sql)
			if callback != nil then callback() end
			MsgC(Color(0, 255, 255), "[SimpleGangs] ", Color(255, 0, 0), "Error: Query to SimpleGangs MySQL Database Failed. The following Error Message was provided:\n", err, "\n")
		end

		q:start()
	end

	orgDB:connect()
else
	if mysqloo == nil and SimpleGangs.orgsUseMySQL then
		MsgC(Color(0, 255, 255), "[SimpleGangs] ", Color(255, 0, 0), "Error: A MySQL Configuration was provided for SimpleGangs but the required module 'mysqloo' was not found.\nCheck the installation guide and ensure the correct architecture has been installed.\n")
	end

	-- SQLite query function
	function SimpleGangs:orgDBQuery(query, callback)
		local data = sql.Query(query)
		if callback != nil then callback(data) end
	end
end

if mysqloo != nil and SimpleGangs.darkrpUseMySQL then
	-- Define database query function with appropriate
	-- callback based on whether MySQL or SQLite is
	-- chosen as the primary DBMS.
	-- This function is used for all queries to the
	-- DarkRP database. For SimpleGangs queries, see
	-- above.
	-- Database query function accepts 2 parameters:
	-- query, the SQL query to execute which is a string
	-- and callback, a function to run on query success
	-- which accepts 1 parameter of the query response.

	-- Setup MySQL connection
	darkrpDB = mysqloo.connect(SimpleGangs.darkrpDBHost, SimpleGangs.darkrpDBUsername, SimpleGangs.darkrpDBPassword, SimpleGangs.darkrpDBDatabase, SimpleGangs.darkrpDBPort)

	darkrpDB.onConnected = function(db)
		MsgC(Color(0, 255, 255), "[SimpleGangs] ", Color(0, 255, 0), "Success: Connection Established between Server and DarkRP MySQL Database\n")
	end
	darkrpDB.onConnectionFailed = function(db, err)
		MsgC(Color(0, 255, 255), "[SimpleGangs] ", Color(255, 0, 0), "Error: Connection to DarkRP MySQL Database Failed. The following Error Message was provided:\n", err, "\n")
		
		-- Fallback to SQLite query function
		function SimpleGangs:darkrpDBQuery(query, callback)
			local data = sql.Query(query)
			if callback != nil then callback(data) end
		end
	end

	-- MySQL query function
	function SimpleGangs:darkrpDBQuery(query, callback)
		local q = darkrpDB:query(query)

		q.onSuccess = function(self, data)
			if callback != nil then callback(data) end
		end
		q.onError = function(self, err, sql)
			if callback != nil then callback() end
		end

		q:start()
	end

	darkrpDB:connect()
else
	if mysqloo == nil and SimpleGangs.darkrpUseMySQL then
		MsgC(Color(0, 255, 255), "[SimpleGangs] ", Color(255, 0, 0), "Error: A MySQL Configuration was provided for DarkRP but the required module 'mysqloo' was not found.\nCheck the installation guide and ensure the correct architecture has been installed.\n")
	end

	-- SQLite query function
	function SimpleGangs:darkrpDBQuery(query, callback)
		local data = sql.Query(query)
		if callback != nil then callback(data) end
	end
end