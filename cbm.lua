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


-- csv file :
--						batId, modelID 
--						batId, modelID 
--						batId, modelID 

-- cbm.data :
--						batId, { modelID, modelID , modelID } 
--						batId, { modelID, modelID , modelID } 

cbm.data		= {}			-- [batID][modelID] = true
cbm.csvLuaFile	= ""			-- fullname of csvfile.lua
cbm.csvFile		= ""			-- cbm data file : fullname of cbm.csv 
cbm.cbmFile		= ""			-- object :: cbm.csvLuaFile

function cbm.load( csvLuaFile , csvFile )
	cbm.csvLuaFile	=	csvLuaFile
	cbm.csvFile	=	csvFile
	
	cbm.cbmFile  =	loadScript( cbm.csvLuaFile )()	
	cbm.cbmFile.setFieldDataType(  1 , 2 )	-- First  field String = 2
	cbm.cbmFile.setFieldDataType(  2 , 1 )	-- Second field Numeric = 1

	cbm.cbmFile.readCsv( cbm.csvFile )	

	t = cbm.cbmFile.getTable()
	
	
	cbm.data = {}
	for _ , aT in pairs( t ) do
		if cbm.data[ aT.batID ] == nil then
			cbm.data[ aT.batID ]	= {}
		end
		-- table.insert( cbm.data[ aT.batID ] , aT.modelID  )
		cbm.data[ aT.batID ][aT.modelID] = true
	end
	
	-- app.d.printAssoc( "cbm.load() : cbm.data " , cbm.data )	
end

function cbm.save()

	app.d.printAssoc( "elött - cbm.save()::cbm.data" , cbm.data )
	
	cbm.cbmFile.clearData()
	
	for batID, aModels in pairs( cbm.data ) do
	
		if aModels then 			--- != nill
			for modelID, v in pairs( aModels ) do

				cbm.cbmFile.addRow( {	["batID"]	= batID ,
												["modelID"] = modelID	} )
			end
		end
		
	end

	app.d.printAssoc( "után - cbm.save()::GetTable" , cbm.cbmFile.getTable() )

	cbm.cbmFile.writeCsv()
end

function cbm.getData()
	return cbm.data
end

function cbm.addConnect( batID , modelID )
	if cbm.data[batID] == nil then
		cbm.data[batID]	= {}
	end
	cbm.data[batID][modelID]	= true
end

function cbm.delConnect( batID , modelID )
	if cbm.data[batID] ~= nil then
		cbm.data[batID][modelID]	= false
	end
end

function cbm.removeModel( modelID )

	for bID, aModels in pairs( cbm.data ) do
		for mID, v in pairs( aModels ) do
			if v and mID == modelID then
				cbm.data[bID][mID]	= nil
			end
		end
		
	end
	
end

function cbm.removeBattery( batID )

	cbm.data[batID]	= false
	
end

-- store all modell what connected to the battery, Param aModels = { m1ID, m2ID, ..}
-- Overwrite all Battery==batID model connection
function cbm.setBatteryModels( batID , aModels )

	cbm.data[batID] = aModels
	
end

function cbm.getBatteryModels( batID  )
	if not ( cbm.data[batID] ) then
		return {}
	else
		return cbm.data[batID]
	end
end

function cbm.getModelBatteries( modelID )
	local batIDs	= {}

	for bID, aModels in pairs( cbm.data ) do
	
		for mID, v in pairs( aModels ) do
			if v and mID == modelID then
				table.insert( batIDs , bID )
			end
		end
		
	end

	return batIDs
end





function cbm.test()

	-- cbm.load( 	"/WIDGETS/BattUse/csvfile.lua" , 
					-- "/WIDGETS/BattUse/batfiles/batmodel.csv"	)

	-- cbm.addConnect(  "ZZ-001" , 4 )	
	-- cbm.addConnect(  "ZZ-002" , 4 )	
	-- cbm.addConnect(  "ZZ-002" , 8 )	
	-- cbm.addConnect(  "ZZ-003" , 5 )	
	
	-- zz = cbm.getBatteryModels( "ZZ-002"  )	
	-- app.d.printAssoc( "zz-002" , zz )
	-- cbm.setBatteryModels( zz )	

	-- app.d.printAssoc( "cbm.data" , cbm.data )
	
	-- app.d.printAssoc( "getModelBatteries() :: 4" , cbm.getModelBatteries( 4 ) )

	-- cbm.delConnect( "ZZ-002" , 4 )	
	-- cbm.delConnect( "ZZ-002" , 8 )	
	
	-- ---------------------
	
	-- cbm.addConnect( "Bat99"	, 99 ) 
	-- cbm.addConnect( "Bat99"	, 98 )
	-- cbm.addConnect( "Bat99"	, 97 )

	-- app.d.printAssoc( "cbm.data" , cbm.data )
	
	-- app.d.log( "cbm.removeBattery( Bat99 )" , "" )
	-- cbm.removeBattery( "Bat99" )

	-- app.d.printAssoc( "cbm.data" , cbm.data )

	-- cbm.addConnect( "Bat99"	, 99 )
	-- cbm.addConnect( "Bat99"	, 98 )
	-- cbm.addConnect( "Bat98"	, 99 )
	-- cbm.addConnect( "Bat97"	, 99 )

	-- app.d.printAssoc( "cbm.data" , cbm.data )
	
	-- app.d.log( "cbm.removeModel( 99 )" , "" )
	-- cbm.removeModel( 99 )
	
	-- app.d.printAssoc( "cbm.data" , cbm.data )
	
	-- cbm.removeBattery( "Bat99" )
	-- cbm.save()
end

return cbm