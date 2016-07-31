require( "mysqloo" )

local DATABASE_HOST = "127.0.0.1"
local DATABASE_PORT = 3306
local DATABASE_NAME = ""
local DATABASE_USERNAME = ""
local DATABASE_PASSWORD = ""

local function ConnectToDatabase()

	coredb = mysqloo.connect(DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_NAME, DATABASE_PORT)
	
	function coredb:onConnected()
		print("\n*** Connectet to Mysql Database ***") 
		print("Host Info:", coredb:hostInfo() )
		print("\n")
	end

	function coredb:onConnectionFailed( err )
		print( "Connection to database failed!" )
		print( "Error:", err )
	end
	
	coredb:connect()
	
	timer.Simple(1, function() hook.Call("DatabaseLoaded") end)
end
hook.Add("Initialize", "Initialize_databse", ConnectToDatabase)

function corequery(querystr, callback)
	if !querystr then print("Querystr failed") return end
	if !coredb then ConnectToDatabase(); timer.Simple(1.5, function() corequery(querystr, callback); end) end

	local status = coredb:status()
	if status == 2 or status == 3 then
		print("Status Failed")
		return
	end
	
	local Query = coredb:query(querystr)
	
	if Query == nil then timer.Simple(1, function() corequery(querystr, callback); print("Query Failed... retrying") end) return end
	
	function Query.onSuccess( userdata )
		if callback then
			callback(Query:getData()) 
		end
	end
 
    function Query:onError( err, sql )
        print( "Query errored!" )
        print( "Query:", sql )
        print( "Error:", err )
    end
 
    Query:start()
end
