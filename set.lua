--[[#######################################################################
##  set.lua                                                              ##
##                BattUse - Settings functions                           ##
##                                                                       ##
## Author: BeGab                                                         ##
## URL   : https://github.com/Be-Gab/BattUse                             ##
##                                                                       ##
##                      Copyright (C) "BeGab"                            ##
##                                                                       ##
###########################################################################
## License GNU General Public License v3.0                               ##
#########################################################################]]
local filename, app = ...
local settings = {}

local PERCENTS_SEP_CHAR	= "|"
local PERCENTS_COUNT		= 6

local TARGET_PERCENT_SLIDER_STEP = 5 

local function split(str, separator)
    local result = {}
    for match in string.gmatch(str, "([^" .. separator .. "]+)") do
        table.insert(result, match)
    end
    return result
end

-- Table-t stringgé konvertálás: {1, 2, 3} -> "1,2,3"  -- PERCENTS_SEP_CHAR
local function perenctTable2String( tblPercents )
	local strTable = {}

	for i = 1, PERCENTS_COUNT do
		if tblPercents[i] then
			strTable[i] = tostring( tblPercents[i] )
		else
			strTable[i] = 0
		end 
		
	end

	return table.concat(strTable, PERCENTS_SEP_CHAR )
end

-- Stringet table-lé konvertálás: "1|2|3" -> {1, 2, 3}
local function perenctString2Table( strPercents )
	local parts = split( strPercents, PERCENTS_SEP_CHAR )
	local result = {}

	for i, part in ipairs(parts) do
		result[i] = tonumber(part)  -- Visszaalakítás számmá (nil lesz, ha nem szám)
	end

	-- Egészítsük ki a táblát az elvárt hosszra, ha rövidebb
	for i = #result, PERCENTS_COUNT do
		result[i] = 0
	end

	table.sort( result, function(a, b) return a > b end )
	
	return result
end

function settings.getBattFiles()
	return battFiles
end

function settings.setFileName( fn )
	filename = fn
end

function settings.getFileName()
	return filename 
end

function settings.settingsLoad()
	local cfgFile  = loadScript(  app.dir .. "csvfile.lua" )()
	local fileName = settings.getFileName()
	local data = {}

	if fstat( fileName ) ~= nil then
		cfgFile.readCsv( fileName  )
		data = cfgFile.getRow( 1 )
		
	end	
	
	-- Input page	
	settings.batVoltSource			= data.batVoltSource	or 0
	settings.batUsedMAhSource		= data.batUsedMAhSource	or 0	
	settings.batMaxMAhSource		= data.batMaxMAhSource	or 0
	settings.quickSelChannel		= data.quickSelChannel	or 0

	-- settings.batMaxMAh				= data.batMaxMAh	or 0
	settings.batBackupVolt			= data.batBackupVolt	or 0
	settings.batCell					= data.batCell	or 0
	settings.Timer						= data.Timer or 0

	-- Behavior page or 1
	settings.landingPercent			= data.landingPercent or 60
	settings.logPath					= data.logPath	or 1
	settings.dtFormat					= data.dtFormat or 1
	settings.warnWhenBatConnect	= data.warnWhenBatConnect or 1
	settings.warnFlyBegin			= data.warnFlyBegin or 1
	settings.flyOverHapticSec		= data.flyOverHapticSec or 5
	settings.warningBatDissconnectOnFly = data.warningBatDissconnectOnFly or 1
	settings.minBatStartVolt		= data.minBatStartVolt or 60
	settings.warningBatOverUse		= data.warningBatOverUse or 25
	settings.hapticPercent			= perenctString2Table( data.hapticPercent or "0|0|20|10|5|2" )
	settings.soundPercent			= perenctString2Table( data.soundPercent  or "75|50|25|15|10|5" )

end

function settings.settingsSave()
	local fileName = settings.getFileName()
	
	file = io.open(fileName, "w")	

	-- fileRW.log( "WriteCSV : " .. saveFN )
	if not file then
		print("fileRW.writeCSV Error: File Open Error! (" .. fileName .. ")" )
		return false
	end
	
	-- app.d.log("fejelc elött, filename =", filename )
	
	
	io.write(	file, 
					"batVoltSource,batUsedMAhSource,batMaxMAhSource,quickSelChannel,batBackupVolt,batCell,Timer,"  ..
					"logPath,landingPercent,dtFormat,warnWhenBatConnect,warnFlyBegin,flyOverHapticSec," ..
					"warningBatDissconnectOnFly,minBatStartVolt,warningBatOverUse,hapticPercent,soundPercent" ..
					"\n"
				)
	
	-- d.log("fejelc utan", 1 )
	-- d.log("settings.getBattFile()", settings.getBattFile() )
	-- d.log("perenctTable2String( settings.hapticPercent )", perenctTable2String( settings.hapticPercent ) )
	
	io.write(	file, 	
					settings.batVoltSource .. "," ..
					settings.batUsedMAhSource .. "," ..
					settings.batMaxMAhSource .. "," ..
					settings.quickSelChannel .. "," ..

					-- settings.batMaxMAh .. "," ..
					settings.batBackupVolt .. "," .. 
					settings.batCell .. "," .. 
					settings.Timer	.. "," .. 
					
					-- "\"" .. settings.getBattFile() .. "\"" .. "," ..
					settings.logPath	.. "," ..
					settings.landingPercent .. "," .. 
					settings.dtFormat	 .. "," .. 
					settings.warnWhenBatConnect .. "," .. 
					settings.warnFlyBegin .. "," ..
					settings.flyOverHapticSec .. "," ..
					
					settings.warningBatDissconnectOnFly .. "," ..
					settings.minBatStartVolt .. "," ..
					settings.warningBatOverUse .. "," ..
					"\"" .. perenctTable2String( settings.hapticPercent ) .. "\""  .. "," ..
					"\"" .. perenctTable2String( settings.soundPercent ) .. "\"" .. 
					"\n"
				)
	-- d.log("fejelc utan", 20 )		
   io.close( file )


end
 
function settings.setBatVoltSource(  s )
	settings.batVoltSource = s
	settings.settingsSave()
end 

function settings.getBatVoltSource( )
	return settings.batVoltSource
end
 
function settings.setUsedMAhSource(  s )
	settings.batUsedMAhSource = s
	settings.settingsSave()
end 
 
function settings.getUsedMAhSource( )
	return settings.batUsedMAhSource
end
 
function settings.setMaxMAhSource(  s )
	settings.batMaxMAhSource = s
	settings.settingsSave()
end 
 
function settings.getMaxMAhSource( )
	return settings.batMaxMAhSource
end

function settings.setBackupVolt(  s )
	settings.batBackupVolt = s
	settings.settingsSave()
end 
 
function settings.getBackupVolt( )
	return settings.batBackupVolt
end

function settings.setBatCell(  s )
	settings.batCell = s
	settings.settingsSave()
end 
 
function settings.getBatCell( )
	return settings.batCell
end

function settings.setTimer( s )
	settings.Timer = s
	settings.settingsSave()
end 
 
function settings.getTimer( )
	return settings.Timer
end

function settings.setLogPathID(  s )
	settings.logPath = s
	settings.settingsSave()
end 
 
function settings.getLogPathID( )
	return settings.logPath
end

local function roundPercent( n )
	if n<0 then 
		return 0
	end
	if n>100 then
		return 100
	end
	local mn = n % TARGET_PERCENT_SLIDER_STEP
	if mn >= ( TARGET_PERCENT_SLIDER_STEP * .5 ) then
		return n + TARGET_PERCENT_SLIDER_STEP - mn
	else
		return n - mn
	end
end

function settings.setLandingPercent(  s )
	settings.landingPercent = roundPercent( s )
	settings.settingsSave()
end 
 
function settings.getLandingPercent( )
	return settings.landingPercent
end

function settings.setDateFormat(  s )
	settings.dtFormat = s
	settings.settingsSave()
end 
 
function settings.getDateFormat( )
	return settings.dtFormat
end

function settings.setWarnWhenBatConnect(  s )
	settings.warnWhenBatConnect = s
	settings.settingsSave()
end 
 
function settings.getWarnWhenBatConnect( )
	return settings.warnWhenBatConnect
end

function settings.setWarnFlyBegin(  s )
	settings.warnFlyBegin = s
	settings.settingsSave()
end 
 
function settings.getWarnFlyBegin( )
	return settings.warnFlyBegin
end

function settings.setFlyOverHapticSec(  s )
	settings.flyOverHapticSec = s
	settings.settingsSave()
end 
 
function settings.getFlyOverHapticSec( )
	return settings.flyOverHapticSec
end

function settings.setWarningBatDisconnectOnFly(  s )
	settings.warningBatDissconnectOnFly = s
	settings.settingsSave()
end 
 
function settings.getWarningBatDisconnectOnFly( )
	return settings.warningBatDissconnectOnFly
end

function settings.setMinBatStartVolt(  s )
	settings.minBatStartVolt = s
	settings.settingsSave()
end 
 
function settings.getMinBatStartVolt( )
	return settings.minBatStartVolt
end

function settings.setWarningBatOverUse(  s )
	settings.warningBatOverUse = s
	settings.settingsSave()
end 
 
function settings.getWarningBatOverUse( )
	return settings.warningBatOverUse
end

function settings.setHapticPercent( i , p )
	settings.hapticPercent[ i ] = p
	settings.settingsSave()
end

function settings.getHapticPercent( i )
	return settings.hapticPercent[ i ]
end

function settings.getHapticPercentAll()
	return settings.hapticPercent
end

function settings.setSoundPercent( i , p )
	settings.soundPercent[ i ] = p
	settings.settingsSave()
end

function settings.getSoundPercent( i )
	return settings.soundPercent[ i ]
end

function settings.getSoundPercentAll()
	return settings.soundPercent
end

-- function settings.setBattFile( s )
	-- settings.battFile = s
	-- settings.settingsSave()	
	
	-- -- Todo : Itt változik az aksi file, az újat be kell olvasni, friossíteni flyData -t.
	-- -- Vagy : Itt:  widget.setInputPage(), ahol ez a kód részlet, meghívásra került
-- end 
 
function settings.getBattFile( )
	return settings.battFile
end

function settings.setQuickSelChannel(  s )
	settings.quickSelChannel = s
	settings.settingsSave()
end 
 
function settings.getQuickSelChannel( )
	return settings.quickSelChannel
end


--##########################################################################################

settings.setFileName( filename )
settings.settingsLoad()

-- app.d.printAssoc( "settings" , settings )


return settings
