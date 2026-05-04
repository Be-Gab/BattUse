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
local BATTFILES_DIR		= app.dir .. "batfiles"
local DEMO_BATT_FILENAME= "demo_batfile.csv"
local TARGET_PERCENT_SLIDER_STEP = 5 

local battFiles = DEMO_BATT_FILENAME

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

local function createDemoBatFile()

	-- create file with head
	f=io.open( BATTFILES_DIR .. "/" .. DEMO_BATT_FILENAME ,"a")
	io.write( f , "id,capacity,product,cells,maxVolt,earlyCount,count,firstStartDate,retireDate,lastStartDate" .. "\n"  )
	io.write( f , "\"Bat1\",5000,\"Prod A\",12,4.2,20,150,\"20190909120000\",\"\",\"20250224163326\"" .. "\n"  )
	io.write( f , "\"Bat2\",5000,\"Prod B\",12,4.35,20,27,\"20190909120000\",\"\",\"20250423161922\"" .. "\n"  )
	io.write( f , "\"Bat3\",5000,\"Prod B\",12,4.2,200, 1,\"20190909120000\",\"20230909\",\"20230901111122\"" .. "\n"  )	
	
	io.close(f)
	
end

local function battFilesDirExists()
	local info = fstat(BATTFILES_DIR)
	
	if info == nil or ( info.attrib ~= AM_DIR) then
      print( BATTFILES_DIR .. " not exist or not a directory !!!!! ")
		return false
   end

	return true
end

function settings.listBatfiles()
	local csv_files = {}

	-- Ellenőrizzük a mappa létezését
	
	if battFilesDirExists() then
	
		for fname in dir( BATTFILES_DIR ) do
			if string.sub(fname, -4) == ".csv" then
				csv_files[ #csv_files + 1 ] = fname
			end
		end
		
	else
		return nil -- Vagy egy üres táblázatot adhatunk vissza, ha ez a kívánt viselkedés
	end

	--csv_files = { "a" , "b" }
	
	if #csv_files == 0 then
		createDemoBatFile()
		settings.listBatfiles()
	end
	
	--printAssoc( "listBatfiles()" , csv_files, true )
	
	return csv_files
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
	
	-- app.d.printAssoc( "data" , data )
	
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
	settings.battFile					= data.battFile or DEMO_BATT_FILENAME
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
	
	-- Check batFile exists	
	if fstat( settings.getBattFileFullPath() ) == nil then
		settings.battFile = DEMO_BATT_FILENAME
	end
	

end

function settings.settingsSave()
	local fileName = settings.getFileName()
	
	file = io.open(fileName, "w")	

	-- fileRW.log( "WriteCSV : " .. saveFN )
	if not file then
		print("fileRW.writeCSV Error: File Open Error! (" .. fileName .. ")" )
		return false
	end
	
	-- d.log("fejelc elött", 0 )
	
	
	io.write(	file, 
					"batVoltSource,batUsedMAhSource,batMaxMAhSource,quickSelChannel,batBackupVolt,batCell,Timer,"  ..
					"battFile,logPath,landingPercent,dtFormat,warnWhenBatConnect,warnFlyBegin,flyOverHapticSec," ..
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
					
					"\"" .. settings.getBattFile() .. "\"" .. "," ..
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

function settings.setBattFile( s )
	settings.battFile = s
	settings.settingsSave()	
	
	-- Todo : Itt változik az aksi file, az újat be kell olvasni, friossíteni flyData -t.
	-- Vagy : Itt:  widget.setInputPage(), ahol ez a kód részlet, meghívásra került
end 
 
function settings.getBattFile( )
	return settings.battFile
end

function settings.getBattFileFullPath( )
	return BATTFILES_DIR .. "/" .. settings.battFile
end

function settings.setBattFileID( n )
	-- Batt listából a kiválasztott név kerül elmentésre a sorszám alapján
	settings.setBattFile( settings.battFiles[ n ] )
	
end 
 
function settings.getBattFileID()
	-- filenév tárolva, de a listában a sorszáma kell..
	local bf = settings.battFiles
	local n = 1		-- default the first item

	for i = 1, #bf do
		if settings.battFile == bf[ i ] then
			n = i
		end
	end

	return n
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

--app.d.printAssoc( "settings" , settings )

settings.battFiles = settings.listBatfiles()

return settings
