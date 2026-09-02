--[[#######################################################################
##  cbm.lua                                                              ##
##                BattUse - Connect Battery to Model                     ##
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
local cbm = {}

cbm.data		= {}			-- [batID][modelID] = true
cbm.csvLuaFile	= ""			-- fullname of csvfile.lua
cbm.csvFile		= ""			-- cbm data file : fullname of cbm.csv 
cbm.cbmFile		= ""			-- object :: cbm.csvLuaFile

function cbm.load( csvLuaFile , csvFile )
	cbm.csvLuaFile	=	csvLuaFile
	cbm.csvFile	=	cbmFile

	cbm.cbmFile  =	loadScript( cbm.csvLuaFile )()
	cbm.cbmFile.readCsv( cbm.csvFile )	
	
	cbm.data = cbm.getTable()
	
end

function cbm.save()

	cbm.cbmFile.clearData()

	for batID, aModels in pairs( cbm.data ) do
	
		for modelID, v in pairs( aModels ) do
			if v then
				cbm.cbmFile.addRow( { batID, modelID } )
			end
		end
		
	end

	cbm.cbmFile.Save()
end

function cbm.addConnect( batID , modelID )
	if #cbm.data[batID] == 0 then
		cbm.data[batID]	= {}
	end
	cbm.data[batID][modelID]	= true
end

function cbm.delConnect( batID , modelID )
	if #cbm.data[batID] > 0 then
		cbm.data[batID][modelID]	= false
	end
end

function cbm.removeModel( modelID )
end

function cbm.setModelBatteries( batID , aModels )
end



function cbm.getModelBatteries( modelID )
	local batIDs	= {}
	
	return batIDs
end

function cbm.getBatteryModels( batID )
	return cbm.data[batID]
end





function cbm.test()
	cbm.load( 	"/WIDGETS/BattUse/csvfile.lua" , 
					"/WIDGETS/BattUse/batfiles/batteries.csv"	)
	cbm.save()
end

return cbm