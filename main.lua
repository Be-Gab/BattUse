--[[#######################################################################
##  main.lua                                                             ##
##                BattUse - main                                         ##
##                                                                       ##
## Author: BeGab                                                         ##
## Date:    2026-04-01                                                   ##
## Version: 1.0.0 RC1                                                    ## 
## URL   : https://github.com/Be-Gab/BattUse                             ##
##                                                                       ##
##                      Copyright (C) "BeGab"                            ##
##                                                                       ##
###########################################################################
## License GNU General Public License v3.0                               ##
#########################################################################]]
local app = {}

app.name  = "BattUse"
app.version = "v1.0.0 RC1"
app.dir = "/WIDGETS/BattUse/"

local settings	= {}
local flyData	= {}
local loadedModel = ""

local batFile	= {}

-- Debug Window filter : /(.:BattUse.|.:BattUse.^f_stat|filerw|error^f_stat|warning|^f_stat|-(E|W)-)/i

local options =	{	
							{ "Display"	, CHOICE	,	1, {	
																	"Battery name"	,
																	"Battery properties"	,		-- Product, Capacity
																	"Battery status"	,			-- Battery Voltage in %
																	"Flight Count"	,
																	"Fly Time"	,
																	"Landing target %"	,
																	"Last used"	,
																	"Peak current"	,				-- MAX Amp
																	"Quick Selector"	,
																	"Remaining charge"	,		-- mAh Percent : % Line
																} 
							}
						}


local function create(zone, options )
	local mi = model.getInfo()
	local modelConfigFile = string.format( "%s/%s.cfg"   , app.dir , mi.name )
	local errMsg

	print( ":BattUse: Create() Widget Start. Model:" .. mi.name  )
	
	if (lvgl == nil) then
		return {zone = zone, options = options, name = app.name }
	end
	
	if loadedModel ~= mi.name then
		local dbg 
		dbg,  errMsg = loadScript( app.dir .. "d.lua" )( app.name ) 
		app.d = dbg

		-- ================================================================================
		settings, errMsg = loadScript( app.dir .. "set.lua" )( modelConfigFile , app ) 

		if errMsg then
			print( ":BattUse : SET load error:" ..  errMsg )
			widget.errMsg = errMsg
		end
	
		-- app.d.log( "flyData.selBatteryName" , flyData.selBatteryName , "create()" )

		-- ================================================================================
		-- Load only once
		
		flyData, errMsg = loadScript( app.dir .. "fd.lua" )( app , batFile ) 
		
		if errMsg then
			print( ":BattUse : FD load error:" ..  errMsg )
			widget.errMsg = errMsg
		end

		loadedModel = mi.name
		print( ":BattUse: Create() Loaded Model:" .. loadedModel  )
		
	end
	
	-- ================================================================================
	widget, errMsg = loadScript( app.dir .. "loadable.lua" )(zone, options, app, settings, flyData )

	if errMsg then
		print( ":BattUse : LoadAble load error:" ..  errMsg )
		widget.errMsg = errMsg
	end

	return widget
																
end

local function update( widget, options )
	widget.update(widget, options);
end

local function background(wgt)
end

local function refresh(widget, event, touchState)
    widget.refresh(event, touchState)
end


return { 
	useLvgl	= true, 
	name		= app.name, 
	options	= options, 
	create	= create, 
	update	= update, 
	refresh	= refresh ,
	background=background,
	}
