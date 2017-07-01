
require( "mysqloo" )

local C_HOST = "127.0.0.1"
local C_PORT = 3306
local C_DATABASE = ""
local C_DATABASE_USERNAME = ""
local C_DATABASE_USERPASSWORD = ""

local function C_InitialConnect()

	coredb = mysqloo.connect(C_HOST, C_PORT, C_DATABASE, C_DATABASE_USERNAME, C_DATABASE_USERPASSWORD)

	function coredb:onConnected()
		print("\n*** C_ Connected to the database! ***")
		print("\n")
	end

	function coredb:onConnectionFailed( err )
		print( "\n*** C_ Connection to database failed! ***" )
		print( "Error:", err )
		print("\n")
	end

	coredb:connect()

	timer.Simple(1, function() hook.Call("C_DATABASE_LOADED") end)
end
hook.Add("Initialize", "C_InitialConnect", C_InitialConnect)

function corequery(querystr, callback)
	if !querystr then return end
	if !coredb then ConnectToDatabase(); timer.Simple(1.5, function() corequery(querystr, callback) end) end

	local status = coredb:status()
	if status == 2 or status == 3 then
		print("\n*** C_ Connection failed ***")
		return
	end

	local Query = coredb:query(querystr)

	if Query == nil then timer.Simple(1, function() corequery(querystr, callback) end) return end

	function Query.onSuccess( userdata )
		if callback then
			callback(Query:getData())
		end
	end

    function Query:onError( err, sql )
        print( "\n*** C_ Query errored! ***" )
        print( "Query:", sql )
        print( "Error:", err )
				print("\n")
    end

    Query:start()
end
