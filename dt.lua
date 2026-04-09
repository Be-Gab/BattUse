--[[#######################################################################
##  dt.lua                                                               ##
##                BattUse - Date/Time format functions                   ##
##                                                                       ##
## Author: BeGab                                                         ##
## URL   : https://github.com/Be-Gab/BattUse                             ##
##                                                                       ##
##                      Copyright (C) "BeGab"                            ##
##                                                                       ##
###########################################################################
## License GNU General Public License v3.0                               ##
#########################################################################]]
local app = ...
local dt = {}

dt.year = nil
dt.month = nil
dt.day = nil 
dt.hour = nil
dt.min = nil
dt.sec = nil
dt.FormatId = 1				-- "YYYY.MM.DD. HH.MM.SS"

-- local d
-- d,  errMsg = loadScript( app.dir .. "d.lua" )( app ) 

if errMsg then
	print( ":BattUse - DT : D load error:" ..  errMsg )
	widget.errMsg = errMsg
end


function dt.getSystemDT()
	local sysdt = getDateTime()

	dt.year	= sysdt.year
	dt.month = sysdt.mon
	dt.day	= sysdt.day 
	dt.hour	= sysdt.hour
	dt.min	= sysdt.min
	dt.sec	= sysdt.sec

end

function dt.isToday( s )
	local dtT, errMsg = loadScript( app.dir .. "dt.lua" )( app ) 
	local todayUsed
	
	-- d.log( "s" , s , "dt.isToday( s )" )
	
	dtT.setByString( s )
	-- d.log( "dtT.getString()" , dtT.getString() , "dt.isToday( s )" )

	dt.getSystemDT()
	-- d.log( "dt.getString()" , dt.getString() , "dt.isToday( s )" )
	
	if dt.year	== dtT.year and
		dt.month == dtT.month and
		dt.day	== dtT.day then
		
		todayUsed = true
	else
		todayUsed = false
	end	

	return todayUsed
end

function dt.getDateTime( st , fi )
	local f = ""
	local fId = fi or 	dt.FormatId
	
	if st == nil or st == "" then
		return ""
	else
		dt.setByString( st )
	end
	-- app.d.log( " st =" , st , "getDateTime()")
	-- app.d.log( " dt.FormatId" , dt.FormatId , "getDateTime()")
	-- app.d.log( "fId" , fId , "getDateTime()")

	-- app.d.printAssoc( "getDateTime :: dt =" , dt )
	
	if fId == 1 then
		--	MM/DD/YYYY HH:MM:SS
		f = string.format( "%02d/%02d/%04d %02d:%02d:%02d" ,  dt.month , dt.day , dt.year , dt.hour	, dt.min	, dt.sec	 )

	elseif fId == 2 then
		-- DD.MM.YYYY HH:MM:SS
		f = string.format( "%02d.%02d.%04d %02d:%02d:%02d"  , dt.day , dt.month, dt.year , dt.hour	, dt.min	, dt.sec	 )
		
	elseif fId == 3 then
		-- YYYY/MM/DD HH:MM:SS
		f = string.format( "%04d/%02d/%02d %02d:%02d:%02d" , dt.year	, dt.month , dt.day , dt.hour	, dt.min	, dt.sec	 )

	elseif fId == 4 then
		-- YYYY.MM.DD. HH:MM:SS
		f = string.format( "%04d.%02d.%02d. %02d:%02d:%02d" , dt.year	, dt.month , dt.day , dt.hour	, dt.min	, dt.sec	 )
	
	-- Without SEC:
		
	elseif fId == 11 then
		--	MM/DD/YYYY HH:MM:SS
		f = string.format( "%02d/%02d/%04d %02d:%02d" ,  dt.month , dt.day , dt.year , dt.hour	, dt.min	 )

	elseif fId == 12 then
		-- DD.MM.YYYY HH:MM:SS
		f = string.format( "%02d.%02d.%04d %02d:%02d"  , dt.day , dt.month, dt.year , dt.hour	, dt.min	 )
		
	elseif fId == 13 then
		-- YYYY/MM/DD HH:MM:SS
		f = string.format( "%04d/%02d/%02d %02d:%02d" , dt.year	, dt.month , dt.day , dt.hour	, dt.min	 )

	elseif fId == 14 then
		-- YYYY.MM.DD. HH:MM:SS
		f = string.format( "%04d.%02d.%02d. %02d:%02d" , dt.year	, dt.month , dt.day , dt.hour	, dt.min	 )
	else
		f = fId .. ":DateFormat missing"
	end

	return f
end
	
function dt.setFormat( f )
	-- d.log( " format From,To =" , dt.FormatId .. " -> " .. f , "setFormat()")
	dt.FormatId = f
end

function dt.getFormat()
	return dt.FormatId 
end
	
-- Dátum leírása egyetlen stringben : Tároláshoz	
-- YYYYMMDDHHMMSS 	
function dt.getString()	
	local s = ""
	
	if dt.year then
		s = string.format( "%04d%02d%02d%02d%02d%02d" , dt.year	, dt.month , dt.day , dt.hour	, dt.min	, dt.sec	 )
	else
		s = "              "
	end
	
	return s
end
	
function dt.setByString( s )

	if s == "" or string.sub( s,1,4 ) == "    " then
		-- d.log( "A eset, year:" , string.sub( s,1,4 ) , "dt.setByString()" )
		dt.year	= nil
		dt.month	= nil
		dt.day	= nil 
		dt.hour	= nil
		dt.min	= nil
		dt.sec	= nil
	else
		-- log( "B eset, year:" , string.sub( s,1,4 ) , "dt.setByString()" )
		dt.year	= tonumber( string.sub( s, 1, 4 ) )
		dt.month = tonumber( string.sub( s, 5, 6 ) )		
		dt.day	= tonumber( string.sub( s, 7, 8 ) )
		dt.hour	= tonumber( string.sub( s, 9,10 ) )
		dt.min	= tonumber( string.sub( s,11,12 ) )
		dt.sec	= tonumber( string.sub( s,13,14 ) )
	end
	
end

function dt.getDateFormats()
	return	{	"MM/DD/YYYY HH:MM:SS" 	,	--US
					"DD.MM.YYYY HH:MM:SS" 	,	--EU
					"YYYY/MM/DD HH:MM:SS" 	,	--ASIA
					"YYYY.MM.DD. HH:MM:SS"		--HU
				}
end	

function dt.formatTime( timeSec )

	-- d.log("timeSec: " ,  timeSec)

	local dd = math.floor(timeSec / 86400)
	timeSec = timeSec - dd * 86400

	local hh = math.floor(timeSec / 3600)
	timeSec = timeSec - hh * 3600

	local mm = math.floor(timeSec / 60)
	timeSec = timeSec - mm * 60

	local ss = math.floor(timeSec)

	if dd == 0 and hh == 0 then
	 -- less then 1 hour, 59:59
	 timeStr = string.format("%02d:%02d", mm, ss)

	elseif dd == 0 then
	 -- lass then 24 hours, 23:59:59
	 timeStr = string.format("%02d:%02d:%02d", hh, mm, ss)

	else
	 -- more than 24 hours
		-- 5d 23:59:59
	 timeStr = string.format("%dd %02d:%02d:%02d", dd, hh, mm, ss)
	end

	-- d.log( "timeStr: " ,  timeStr)

	return timeStr
end

function dt.test()
	
	dt.getSystemDT()
	app.d.log( "DT start 1" , dt.getString() , "create(zone, options )" )
	app.d.log( "DT start 2" , dt.getDateTime(1) , "create(zone, options )" )
	app.d.log( "DT start 2" , dt.getDateTime(2) , "create(zone, options )" )
	app.d.log( "DT start 2" , dt.getDateTime(3) , "create(zone, options )" )
	app.d.log( "DT start 2" , dt.getDateTime(4) , "create(zone, options )" )
	
	
	dt.setByString( "19670604112233" )
	app.d.log( "DT start 3" , dt.getDateTime(1) , "create(zone, options )" )
	app.d.log( "DT start 3" , dt.getDateTime(2) , "create(zone, options )" )
	app.d.log( "DT start 3" , dt.getDateTime(3) , "create(zone, options )" )
	app.d.log( "DT start 3" , dt.getDateTime(4) , "create(zone, options )" )
	
end

return dt