
-- sqlite.lua

-- Declares the cSQLite class representing a single SQLite database connection, with common operations





local cSQLite = {}
cSQLite.__index = cSQLite





--- Creates the table of the specified name and columns[]
-- If the table exists, any columns missing are added; existing data is kept
function cSQLite:createDBTable(a_TableName, a_Columns)
	-- Check params:
	assert(self ~= nil)
	assert(a_TableName ~= nil)
	assert(a_Columns ~= nil)
	
	-- Try to create the table first
	local sql = "CREATE TABLE IF NOT EXISTS '" .. a_TableName .. "' ("
	sql = sql .. table.concat(a_Columns, ", ") .. ")"
	local execResult = self.DB:exec(sql)
	if (execResult ~= sqlite3.OK) then
		LOGWARNING(self.PluginPrefix .. "Cannot create DB Table " .. a_TableName .. ": " .. ExecResult)
		LOGWARNING(self.PluginPrefix .. "Command: \"" .. sql .. "\".")
		return false
	end
	-- SQLite doesn't inform us if it created the table or not, so we have to continue anyway
	
	-- Check each column whether it exists
	-- Remove all the existing columns from a_Columns:
	local removeExistingColumn = function(a_Values)
		if (a_Values.name ~= nil) then
			local ColumnName = a_Values.name:lower()
			-- Search the a_Columns if they have that column:
			for j = 1, #a_Columns do
				-- Cut away all column specifiers (after the first space), if any:
				local SpaceIdx = string.find(a_Columns[j], " ")
				if (SpaceIdx ~= nil) then
					SpaceIdx = SpaceIdx - 1
				end
				local ColumnTemplate = string.lower(string.sub(a_Columns[j], 1, SpaceIdx))
				-- If it is a match, remove from a_Columns:
				if (ColumnTemplate == ColumnName) then
					table.remove(a_Columns, j)
					break  -- for j
				end
			end  -- for j - a_Columns[]
		end  -- if (a_Values.name ~= nil)
	end
	if (not(self:executeStatement("PRAGMA table_info(" .. a_TableName .. ")", {}, removeExistingColumn))) then
		LOGWARNING(self.PluginPrefix .. "Cannot query DB table structure")
		return false
	end
	
	-- Create the missing columns
	-- a_Columns now contains only those columns that are missing in the DB
	if (#a_Columns > 0) then
		LOGINFO(self.PluginPrefix .. "Database table \"" .. a_TableName .. "\" is missing " .. #a_Columns .. " columns, fixing now.")
		for idx, ColumnName in ipairs(a_Columns) do
			if (not(self:executeStatement("ALTER TABLE '" .. a_TableName .. "' ADD COLUMN '" .. ColumnName .. "'", {}))) then
				LOGWARNING(self.PluginPrefix .. "Cannot add DB table \"" .. a_TableName .. "\" column \"" .. ColumnName .. "\"")
				return false
			end
		end
		LOGINFO(self.PluginPrefix .. "Database table \"" .. a_TableName .. "\" columns fixed.")
	end
	
	return true
end





--- Executes the SQL statement, substituting "?" in the SQL with the specified params
-- Calls a_Callback for each row
-- The callback receives a dictionary table containing the row values (stmt:nrows())
-- Returns false and error message on failure, or true on success
function cSQLite:executeStatement(a_SQL, a_Params, a_Callback, a_RowIDCallback)
	-- Check params:
	assert(self ~= nil)
	assert(a_SQL ~= nil)
	assert(a_Params ~= nil)
	assert(self.DB ~= nil)
	assert((a_Callback == nil) or (type(a_Callback) == "function"))
	assert((a_RowIDCallback == nil) or (type(a_RowIDCallback) == "function"))
	
	-- Prepare the statement (SQL-compile):
	local Stmt, ErrCode, ErrMsg = self.DB:prepare(a_SQL)
	if (Stmt == nil) then
		ErrMsg = (ErrCode or "<unknown>") .. " (" .. (ErrMsg or self.DB:errmsg() or "<no message>") .. ")"
		LOGWARNING(self.PluginPrefix .. "Cannot prepare SQL \"" .. a_SQL .. "\": " .. ErrMsg)
		LOGWARNING(self.PluginPrefix .. "  Params = {" .. table.concat(a_Params, ", ") .. "}")
		return nil, ErrMsg
	end
	
	-- Bind the values into the statement:
	ErrCode = Stmt:bind_values(unpack(a_Params))
	if ((ErrCode ~= sqlite3.OK) and (ErrCode ~= sqlite3.DONE)) then
		ErrMsg = (ErrCode or "<unknown>") .. " (" .. (self.DB:errmsg() or "<no message>") .. ")"
		LOGWARNING(self.PluginPrefix .. "Cannot bind values to statement \"" .. a_SQL .. "\": " .. ErrMsg)
		Stmt:finalize()
		return nil, ErrMsg
	end
	
	-- Step the statement:
	if (a_Callback == nil) then
		ErrCode = Stmt:step()
		if ((ErrCode ~= sqlite3.ROW) and (ErrCode ~= sqlite3.DONE)) then
			ErrMsg = (ErrCode or "<unknown>") .. " (" .. (self.DB:errmsg() or "<no message>") .. ")"
			LOGWARNING(self.PluginPrefix .. "Cannot step statement \"" .. a_SQL .. "\": " .. ErrMsg)
			Stmt:finalize()
			return nil, ErrMsg
		end
		if (a_RowIDCallback ~= nil) then
			a_RowIDCallback(self.DB:last_insert_rowid())
		end
	else
		-- Iterate over all returned rows:
		for v in Stmt:nrows() do
			a_Callback(v)
		end
		
		if (a_RowIDCallback ~= nil) then
			a_RowIDCallback(self.DB:last_insert_rowid())
		end
	end
	Stmt:finalize()
	return true
end





--- Executes the a_Runnable function within a transaction
-- If the transaction fails to commit, retries the entire execution up to a_MaxRetries times
-- Returns true and all values returned by a_Runnable when successful
-- Returns nil and error message on failure
-- If a_Runnable throws an error, it is considered a failure, the entire function will abort further processing
-- (but the transaction will still be rolled back)
-- If a_Runnable returns nil as its first return, it is considered failure as well
function cSQLite:transaction(a_Runnable, a_MaxRetries)
	-- Check params, apply defaults:
	a_MaxRetries = a_MaxRetries or 10000
	assert(type(a_MaxRetries) == "number")
	
	-- If already within a transaction, simply execute the a_Runnable:
	if (self.isInTransaction) then
		local res = { pcall(a_Runnable) }
		if not(res and res[1]) then
			return nil, res[2]  -- pcall() returns false, we want to return nil on failure
		end
		return unpack(res)
	end
	
	-- Repeat at most a_MaxRetries - times
	for i = 1, a_MaxRetries do
		-- Start the transaction:
		local isSuccess, errMsg = self.DB:execute("BEGIN TRANSACTION")
		if not(isSuccess) then
			return nil, errMsg
		end
		self.isInTransaction = true
	
		-- Do the operation, remember all returned values:
		local res = { pcall(a_Runnable) }
		
		-- If the operation failed, rollback the transaction and abort:
		if not(res and res[1] and res[2]) then
			self.DB:execute("ROLLBACK TRANSACTION")
			self.isInTransaction = false
			return nil, unpack(res, 3)
		end
		
		-- Commit the transaction:
		isSuccess, errMsg = self.DB:execute("COMMIT TRANSACTION")
		if (isSuccess) then
			self.isInTransaction = false
			return true, unpack(res, 2)
		end

		-- We weren't successful, retry
	end
	
	-- We weren't successful and reached the max retry count, report an error:
	self.isInTransaction = false
	return nil, "DB Transaction failed to commit"
end





--- Returns a new cSQLite instance with the database connection open to the specified file
-- Returns false and a reason string on failure
function newSQLiteDB(a_FileName)
	-- Create a new instance:
	local res = {}
	setmetatable(res, cSQLite)
	-- cSQLite.__index = cSQLite
	res.PluginPrefix = cRoot:Get():GetPluginManager():GetCurrentPlugin():GetName() .. ": "
	
	-- Open the DB file:
	local ErrMsg
	res.DB, ErrMsg = sqlite3.open(a_FileName)
	if not(res.DB) then
		return false, (ErrMsg or "<no details>")
	end
	
	return res
end




