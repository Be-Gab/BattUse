--[[#######################################################################
##  d.lua                                                                ##
##                BattUse - myDebug functions                            ##
##                                                                       ##
## Author: BeGab                                                         ##
## URL   : https://github.com/Be-Gab/BattUse                             ##
##                                                                       ##
##                      Copyright (C) "BeGab"                            ##
##                                                                       ##
###########################################################################
## License GNU General Public License v3.0                               ##
#########################################################################]]
local appName = ...
local d = {}

function d.log( s , v, hely )
	local dt = getDateTime()
	local ido = string.format( "%02d:%02d:%02d" , dt.hour, dt.min, dt.sec ) 

	hely = hely or nil
	v = v or nil
	
	s = s .. " [" .. type( v ) .. "] "
	
	if type( v ) == "boolean" then
		if v then
			v = "True"
		else
			v = "False"
		end
	end
	
	if type( v ) == "nil" then
		v = "nil"
	end

	if v then
		s = s .. " => " .. v
	end
	
	if hely then
		print( ido .. ":" .. appName .. " [" .. hely .. "]: " .. s ) 
	else
		print( ido .. ":" .. appName .. ": " .. s ) 
	end
end

function d.printAssoc( msg , tbl, showFunctions, tab )
	local sTab
	
	
	showFunctions = showFunctions or false
	tab = tab or 0
	
	sTab = string.rep( "   " , tab )

	d.log(  sTab .. "==================== >> " , msg )
	
	for key, value in pairs( tbl) do


		if type( value ) == "table" then
			d.printAssoc( key , value, showFunctions, tab + 1 )
		 
		else
		

			-- d.log( "Teszt:"..msg..":" , key )

			if type( value ) == "function" then
				if showFunctions then
					d.log(  sTab .. "   " .. key .. "()" )
				end
			else
				d.log(  sTab .. "   " .. key , value )
			end 

			
		end
	end	

	d.log( sTab .. "==================== << "  , msg )

end

return d

