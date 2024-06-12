--[[#######################################################################
##  fd.lua                                                               ##
##                BattUse - Fly Data                                     ##
##                                                                       ##
## Author: BeGab                                                         ##
## URL   : https://github.com/Be-Gab/BattUse                             ##
##                                                                       ##
##                      Copyright (C) "BeGab"                            ##
##                                                                       ##
###########################################################################
## License GNU General Public License v3.0                               ##
#########################################################################]]
local app, batFile = ...

local BATTERY_CONNECTED		= 1
local BATTERY_DISCONNECTED	= 0

QS_LOCK_POSITION_OFF	= 10000

local BATTERY_WARN_ONCONNECT_SOUND	= app.dir .. "media/" .. "batsel.wav"
local BATTERY_WARN_ONFLYMODEL_SOUND	= app.dir .. "media/" .. "batno.wav"
local FLYMAH_OVERUSE_HAPTIC_SOUND	= app.dir .. "media/" .. "batlow.wav"
local BATTERY_ONCONNECT_SOUND			= app.dir .. "media/" .. "batcon.wav"

flyData = {
				saved = {
								isSaved = false 
							} ,
				selectedBatteryRecNum = 0,
				selBatteryName = "Select Battery" ,
				batStatus = BATTERY_DISCONNECTED ,
				batteryRec = {},
				flightEndTime = nil,
				previousFlightMode = 0,
				lastOverUseSec = nil,
				dateFormat = 1,
				usedIsToday = false,
				
				mAhUsable		= 0,
				mAhUsed			= 0,
				
				quickSelLockPosition = QS_LOCK_POSITION_OFF ,
				
				voltReadSensor	=	0	,
				backupVolt		=	0	,
				mAmpSensor		=	0	,
				maxMAhSource	=	0	,
				maxAmp			=	0	,
				quickSelChannel=	0	,
				timerID			=	-1	,	-- not selected
				modelCells		=	0	,
				logPath			=	"/LOG/"	,
				targetLandingPercent 		= 60	,
				basePercentsTable_Sound		= {}	,
				basePercentsTable_Haptic	= {}	,
				mahPercentsTable_Sound		= {}	,
				mahPercentsTable_Haptic 	= {}	,
				warnWhenBatConnect			= true	,
				warnFlyBegin					= true	,
				warningBatDisconnectOnFly	= true	,
				warned_BatteryNotSelected	= false	,
				warningBatOverUse				= true	,
				flyOverHapticSec				= 0	,
				minBatStartVolt				= 0	
			}


-- Data gathered from commercial lipo sensors
local lipoPercentList = {
	{{3.000,0},{3.093,1},{3.196,2},{3.301,3},{3.401,4},{3.477,5},{3.544,6},{3.601,7},{3.637,8},{3.664,9},{3.679,10}},
	{{3.683,11},{3.689,12},{3.692,13},{3.705,14},{3.710,15},{3.713,16},{3.715,17},{3.720,18},{3.731,19},{3.735,20}},
	{{3.744,21},{3.753,22},{3.756,23},{3.758,24},{3.762,25},{3.767,26},{3.774,27},{3.780,28},{3.783,29},{3.786,30}},
	{{3.789,31},{3.794,32},{3.797,33},{3.800,34},{3.802,35},{3.805,36},{3.808,37},{3.811,38},{3.815,39},{3.818,40}},
	{{3.822,41},{3.825,42},{3.829,43},{3.833,44},{3.836,45},{3.840,46},{3.843,47},{3.847,48},{3.850,49},{3.854,50}},
	{{3.857,51},{3.860,52},{3.863,53},{3.866,54},{3.870,55},{3.874,56},{3.879,57},{3.888,58},{3.893,59},{3.897,60}},
	{{3.902,61},{3.906,62},{3.911,63},{3.918,64},{3.923,65},{3.928,66},{3.939,67},{3.943,68},{3.949,69},{3.955,70}},
	{{3.961,71},{3.968,72},{3.974,73},{3.981,74},{3.987,75},{3.994,76},{4.001,77},{4.007,78},{4.014,79},{4.021,80}},
	{{4.029,81},{4.036,82},{4.044,83},{4.052,84},{4.062,85},{4.074,86},{4.085,87},{4.095,88},{4.105,89},{4.111,90}},
	{{4.116,91},{4.120,92},{4.125,93},{4.129,94},{4.135,95},{4.145,96},{4.176,97},{4.179,98},{4.193,99},{4.200,100}},
}
local lipoPercentListHV = {
	{{3.000,0},{3.093,1},{3.196,2},{3.301,3},{3.401,4},{3.477,5},{3.544,6},{3.602,7},{3.631,8},{3.660,9},{3.689,10}},
	{{3.702,11},{3.716,12},{3.729,13},{3.742,14},{3.750,15},{3.757,16},{3.764,17},{3.769,18},{3.773,19},{3.779,20}},
	{{3.784,21},{3.789,22},{3.795,23},{3.800,24},{3.808,25},{3.815,26},{3.823,27},{3.830,28},{3.838,29},{3.845,30}},
	{{3.850,31},{3.855,32},{3.860,33},{3.865,34},{3.870,35},{3.875,36},{3.880,37},{3.885,38},{3.890,39},{3.895,40}},
	{{3.900,41},{3.905,42},{3.910,43},{3.915,44},{3.920,45},{3.925,46},{3.930,47},{3.935,48},{3.940,49},{3.945,50}},
	{{3.950,51},{3.954,52},{3.961,53},{3.967,54},{3.974,55},{3.980,56},{3.986,57},{3.993,58},{3.999,59},{4.005,60}},
	{{4.012,61},{4.018,62},{4.024,63},{4.031,64},{4.037,65},{4.043,66},{4.049,67},{4.055,68},{4.060,69},{4.068,70}},
	{{4.076,71},{4.085,72},{4.093,73},{4.101,74},{4.111,75},{4.120,76},{4.130,77},{4.140,78},{4.149,79},{4.159,80}},
	{{4.169,81},{4.178,82},{4.189,83},{4.200,84},{4.210,85},{4.221,86},{4.232,87},{4.242,88},{4.253,89},{4.263,90}},
	{{4.272,91},{4.281,92},{4.289,93},{4.298,94},{4.305,95},{4.315,96},{4.324,97},{4.333,98},{4.341,99},{4.350,100}},
}

local function now()
	local dt
	dt, errMsg = loadScript( app.dir .. "dt.lua" )( app ) 
	
	dt.getSystemDT()
	
	return dt.getString()	
end

function flyData.fontSize( f )
	-- h = 22, -- SMLSIZE
	-- h = 26, -- 0
	-- h = 34, -- MIDSIZE
	-- h = 80, -- XXLSIZE

	if f < 26 then
		return SMLSIZE
	elseif f < 34 then
		return 0
	elseif f < 80 then
		return MIDSIZE
	else				--if f >= 80 then
		return XXLSIZE
	end

end

function flyData.setVoltReadSensor( batVoltReadSensor )
	flyData.voltReadSensor = batVoltReadSensor
end

function flyData.setBackupVolt( batBackupVolt )
	flyData.backupVolt = batBackupVolt
end

function flyData.setmAmpSensor( mAS )
	flyData.mAmpSensor = mAS
end

function flyData.setTimerID( tID )
	flyData.timerID = tID
end

function flyData.setModelCells( c )
	flyData.modelCells = c
end

function flyData.setLogPath( p )
	flyData.logPath = p
end

function flyData.setMaxMAhSource( s )
	flyData.maxMAhSource = s
end

function flyData.setTargetLandingPercent( p )
	flyData.targetLandingPercent = p
end

function flyData.setWarnWhenBatConnect( p )
	flyData.warnWhenBatConnect = p
end

function flyData.setWarnFlyBegin( p )
	flyData.warnFlyBegin = p
end

function flyData.setFlyOverHapticSec( p )
	flyData.flyOverHapticSec = p
end

function flyData.setWarningBatDisconnectOnFly( p )
	flyData.warningBatDisconnectOnFly = p
end

function flyData.setMinBatStartVolt( p )
	flyData.minBatStartVolt = p
end

function flyData.setWarningBatOverUse( p )
	flyData.warningBatOverUse = p
end

function flyData.setBasePercentsTable_Sound( tbl )
	flyData.basePercentsTable_Sound = tbl
	flyData.mAhActionClear()
end

function flyData.setBasePercentsTable_Haptic( tbl )
	flyData.basePercentsTable_Haptic = tbl
	flyData.mAhActionClear()
end

function flyData.setDateFormat( p )
	flyData.dateFormat = p
end

function flyData.setUsedIsToday(l)
	flyData.usedIsToday = l
end


function flyData.setQuickSelChannel(c)
	flyData.quickSelChannel = c
end

function flyData.getCells()
	-- Ha van kiválasztott aksi
	if flyData.selectedBatteryRecNum > 0 then
		return flyData.batteryRec.cells
	else
		return flyData.modelCells
	end
end

function flyData.isHV()
	-- Ha van kiválasztott aksi, akkor onnan, ha nincs akkor nem HV.
	if flyData.selectedBatteryRecNum > 0 then
		return ( flyData.batteryRec.maxVolt > 4.2 )
	else
		return false
	end
end

function flyData.setQuickSelectLockPosition()
	flyData.quickSelLockPosition = getValue( flyData.quickSelChannel )
end

function flyData.setQuickSelectUnLock()
	flyData.quickSelLockPosition = QS_LOCK_POSITION_OFF
end

function flyData.isQuickSelectLocked()
	return ( flyData.quickSelLockPosition == 1024 + getValue( flyData.quickSelChannel ) )
end

--- This local function return the percentage remaining in a single Lipo cel
--- since running on long array found to be very intensive to hrous cpu, we are splitting the list to small lists
function flyData.getPercent(cellVolt, HV )

	if cellVolt == nil then
		return 0
	end
	HV = HV or flyData.isHV()

	if HV then
		LPL = lipoPercentListHV
	else
		LPL = lipoPercentList
	end 	

	local result = 0;

  for i1, v1 in ipairs(LPL) do
    if (cellVolt <= v1[#v1][1]) then
      for i2, v2 in ipairs(v1) do
        if v2[1] >= cellVolt then
          result = v2[2]
          return result
        end
      end
    end
  end
  
  -- in case somehow voltage is too high (>4.2), don't return nil
	return 100
end

function flyData.formatTime( timeSec )

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

function flyData.Save( wgt )
	local mt = model.getTimer( flyData.timerID )
	local flightTime = math.abs(mt.start - mt.value  )
	
	
	flyData.saved.isSaved = true
	
	-- id,capacity,product,cells,earlyCount,count,firstStartDate,retireDate,lastStartDate
	
	---------------------------------------------
	flyData.saved.batVoltStart	= flyData.batVoltStart
	flyData.saved.batVoltEnd	= flyData.batVoltEnd
	flyData.saved.batCell		= flyData.getCells() -- flyData.modelCells

	-- d.printAssoc( "flyData" , flyData, false )
	
	-- Battery NOT Selected
	if flyData.selectedBatteryRecNum == 0 then
	
		flyData.saved.batPercentEnd	= flyData.getPercent( flyData.batVoltEnd / flyData.modelCells )
		flyData.saved.batPercentStart	= flyData.batPercentEnd	-- flyData.getPercent( flyData.batVoltStart / flyData.modelCells )

		flyData.saved.selBatteryName = "-"
		flyData.saved.selectedBatteryRecNum = 0

		flyData.saved.batteryID = ""
		flyData.saved.batteryProduct = ""
		
		-- batPercentStart

		flyData.saved.batCapcity = 0
		flyData.saved.batMaxVolt = "-"
		flyData.saved.batLastFlight = ""
		flyData.saved.batLastFlightFormated = ""
		
		flyData.saved.batFlightCount = "-"
		
	else
		-- Battery Selected
		
		-- Formated date for widget
		-- d.printAssoc( "flyDataSave()" , flyData )
		
		if flyData.flightEndTime then
			local dt
			dt, errMsg = loadScript( app.dir .. "dt.lua" )( app ) 
			-- dt.setFormat( flyData.dateFormat )

			flyData.saved.batLastFlightFormated	= dt.getDateTime( flyData.flightEndTime, 10 + flyData.dateFormat )
			
		else
			-- Battery connected wo flight => not star, end flight time	
			flyData.saved.batLastFlightFormated	= "-"
			
		end
		-- app.d.log( "flyData.saved.batLastFlightFormated	" ,flyData.saved.batLastFlightFormated	 , "flyDataSave()"  )
		
		
		-- ==============
		
		flyData.saved.batPercentEnd	= flyData.getPercent( flyData.batVoltEnd / flyData.batteryRec.cells )
		flyData.saved.batPercentStart = flyData.getPercent( flyData.batVoltStart / flyData.batteryRec.cells )
		flyData.saved.batCell			= flyData.batteryRec.cells
		flyData.saved.batMaxVolt		= flyData.batteryRec.maxVolt

		flyData.saved.selBatteryName 			= flyData.selBatteryName
		flyData.saved.selectedBatteryRecNum = flyData.selectedBatteryRecNum

		flyData.saved.batteryID			= flyData.batteryRec.id
		flyData.saved.batteryProduct	= flyData.batteryRec.product
	
		flyData.saved.batCapcity		= flyData.batteryRec.capacity
		
		flyData.saved.batLastFlight	= flyData.batteryRec.lastStartDate

	end
	
	-- app.d.log( "flightTime" ,flightTime , "flyDataSave()"  )
	
	flyData.saved.flightTime = flyData.formatTime( flightTime )

	-- --------------------------
	flyData.saved.mAhUsed	= flyData.mAhUsed 
	flyData.saved.mAhUsable = flyData.mAhUsable
	flyData.saved.targetLandingPercent = flyData.targetLandingPercent
	-- --------------------------
	
	flyData.saved.maxAmp	= flyData.maxAmp
	
	if flyData.flightStartTime == nil then
		-- If was not in flight mode, flight count not increment
		flyData.saved.batFlightCount = flyData.batteryRec.count
		flyData.saved.batAllFlightCount = flyData.batteryRec.count
		
	elseif flyData.selectedBatteryRecNum ~= 0 then
		-- Just if battery selected and fly happend
		flyData.saved.batFlightCount = flyData.batteryRec.count + 1
		flyData.saved.batAllFlightCount = flyData.batteryRec.earlyCount + flyData.saved.batFlightCount
		
	else
		-- Battery Not selected
		flyData.saved.batAllFlightCount = ""
		
	end 
	
	if flyData.flightStartTime == nil then
		flyData.saved.flightStartTime = ""
	else
		flyData.saved.flightStartTime = flyData.flightStartTime
	end 

	-- app.d.log( "flightEndTime " ,  flyData.flightEndTime , "flyDataSave()"  )
	
	if flyData.flightEndTime == nil then
		flyData.saved.flightEndTime = "" 
	else
		flyData.saved.flightEndTime = flyData.flightEndTime 
	end	

	-- app.d.log( "flightTime SAVEd" ,  flyData.saved.flightTime , "flyDataSave()"   )
	
end

function flyData.SavedClear()
	flyData.saved = {}
	flyData.saved["isSaved"] = false
	flyData.lastOverUseSec = nil
	
	flyData.mAhActionClear() 
	
	-- d.log( "flyDataSavedClear()" ,  "Finished" )
	
end

function flyData.selectBatteryByID( battID )

	-- app.d.log( "battID" ,  battID , "flyData.selectBatteryByID()"   )

	recNumber = batFile.getRowIdByField( "id", battID )

	flyData.selectBattery( recNumber )

end

function flyData.selectBattery( recNum )

	if flyData.selectedBatteryRecNum ~= recNum then

		flyData.selectedBatteryRecNum = recNum
		
		flyData.batteryRec = batFile.getRow( flyData.selectedBatteryRecNum )	
		
		if flyData.batteryRec.earlyCount == "" then
			flyData.batteryRec.earlyCount = 0
		end 
		if flyData.batteryRec.count == "" then
			flyData.batteryRec.count = 0
		end 
		
		-- Aksi választással új repülési ciklus kezdődik.
		flyData.SavedClear()

		flyData.selBatteryName = string.format( "%s / %s" , flyData.batteryRec.id, flyData.batteryRec.product )

		local sysdt = getDateTime()
		local ymd = string.format( "%04d%02d%02d" , sysdt.year , sysdt.mon , sysdt.day )		
		flyData.setUsedIsToday( ( ymd == string.sub( flyData.batteryRec.lastStartDate , 1, 8 )  ) )
		
		flyData.mAhCalcFlyable()
		
	end

end 

function flyData.getLogFile()
	-- FileName :: FlyLog_YYYYMM_[ModelNeve].csv
	local dt = getDateTime()
	local mi = model.getInfo()
	
	return flyData.logPath .. string.format( "FlyLog_%04d%02d_%s.csv", dt.year, dt.mon, mi.name )
	
end

function addQ( s )
	return '"' .. s .. '"'
end

function flyData.flyLogWrite(wgt)
	local f
	local sFlyLog_FileName = flyData.getLogFile()
	local line = {}
	
	if flyData.saved.flightStartTime == "" then
		-- NOT fly, just connect battery. I made date&time for this event.
		table.insert( line ,  addQ( now() ) )
	else
		table.insert( line , addQ( flyData.saved.flightStartTime ) )
	end
	
	table.insert( line , addQ( flyData.saved.flightEndTime ) )
	
	table.insert( line , addQ( flyData.saved.flightTime ) )
	
	-- Battery		
	if flyData.saved.batteryID  ~= nil then
	
		table.insert( line , addQ( flyData.saved.batteryID ) )
		table.insert( line , addQ( flyData.saved.batteryProduct ) )
		
		--		Current Fly count
		table.insert( line , flyData.saved.batAllFlightCount  )
	
	else
		table.insert( line , addQ( "" ) )	-- batteryID 
		table.insert( line , addQ( "" ) )	-- batteryProduct
		table.insert( line , addQ( "" ) )	-- batAllFlightCount
	end
	
	table.insert( line , string.format("%.2f", flyData.saved.batVoltStart ) )
	if flyData.saved.batPercentStart == nil then
		table.insert( line , 0 )
	else
		table.insert( line , flyData.saved.batPercentStart )
	end
	
	table.insert( line , string.format("%.2f", flyData.saved.batVoltEnd   ) )
	if flyData.saved.batPercentEnd == nil then
		table.insert( line , 0 )
	else
		table.insert( line , flyData.saved.batPercentEnd )
	end
	
	-- app.d.log( "flyData.saved.mAhUsed  :" , flyData.saved.mAhUsed , "flyLogWrite()" )
	-- app.d.printAssoc( "flyLogWrite(), flyData.saved" , flyData.saved )
	
	if flyData.saved.mAhUsed == nil then
		table.insert( line ,  "" )		-- N/A
	else
		table.insert( line , string.format("%d", flyData.saved.mAhUsed ) )
	end 


	-- Max mAh
	if flyData.saved.maxAmp == nil then
		table.insert( line ,  "" )		-- N/A
	else
		table.insert( line , string.format("%d", flyData.saved.maxAmp ) )
	end 

	-- d.log( "line" , table.concat( line , "," )  )
	
	
	-- Ha nem létezik :: új fejléccel létrehozni
	if fstat( sFlyLog_FileName ) == nil then
		-- create file with head
		f=io.open( sFlyLog_FileName,"a")
		io.write(f,	"startFly,endFly,flyTime,batteryID,batteryProduct,startCount,startBatVolt,startBatPercent,endBatVolt,endBatPercent,mAmpFly,maxAmp" .. "\n"  )
		
	else
		-- open file in append mode
		f=io.open( sFlyLog_FileName,"a")
		
	end
	
	io.write(f,	table.concat( line , "," ) .. "\n"  )

	io.close(f)
	
end 

function flyData.warningSound()
	-- playTone(frequency, duration, pause [, flags [, freqIncr [, volume]]])

	 for i = 0, 4 do
		playTone( 349, 500, 40,0,0,5 )
		playTone(1396, 300,  0,0,0,5 )
	end

	-- playFile(filename [, volume])
	app.d.log( "play => warnng.wav:" , "warnng.wav *5" , "flyData.warningSound()"  )
	
	playFile("warnng.wav" ,5)
end

function flyData.detectBatteryConnect( wgt )
	-- local batVolt, isCurrent, isFresh = getSourceValue( wgt.options.BattVSens )
	
	local batVolt = flyData.batVoltReadSensor()

	-- d.log( "flyData.batStatus" , flyData.batStatus, "flyData.detectBatteryConnect()" )
	-- d.log( "batVolt"           , batVolt, "flyData.detectBatteryConnect()" )
	
	-- d.log( "flyData.batStatus" , flyData.batStatus, "flyData.detectBatteryConnect()" )
	-- d.log(  "batVolt " 			, batVolt, 				"flyData.detectBatteryConnect()" )
	


	if batVolt then

		if  flyData.batStatus == BATTERY_CONNECTED then

			if batVolt <  flyData.backupVolt then
				flyData.onBatteryDisconnectEvent( wgt , batVolt )
				
			else
				-- Folyamatosan mentem az értéket, hogy értékhatár alá eséskor meglegyen az előző.
				flyData.batVoltEnd = batVolt 
			end
			
		elseif flyData.batStatus == BATTERY_DISCONNECTED then

			if batVolt > flyData.backupVolt then
				flyData.onBatteryConnectEvent( wgt, batVolt )
			end
		
		end

		-- d.log( "Status" , "End" , "flyData.detectBatteryConnect()" )

	end
	
	-- app.d.log( "flyData.mAhUsed" , flyData.mAhUsed , "flyData.detectBatteryConnect()" )
	-- d.log( "flyData.batVoltEnd" , flyData.batVoltEnd , "flyData.detectBatteryConnect()" )
		
end

function flyData.onBatteryConnectEvent(wgt, batVolt)
	local p = flyData.getPercent( batVolt / flyData.modelCells )
   -- d.log( "onBatteryConnectEvent() -> batVolt" , batVolt )

	--  PlaySound
	app.d.log( "play => BATTERY_ONCONNECT_SOUND:" , BATTERY_ONCONNECT_SOUND , "flyData.onBatteryConnectEvent()"  )
	playFile( BATTERY_ONCONNECT_SOUND )
	
	-- playNumber(value, unit [, attributes])
	-- 13 = UNIT_PERCENT
	app.d.log( "play => Percent :" , batVolt , "flyData.onBatteryConnectEvent()"  )
	playNumber( p, UNIT_PERCENT )

	if flyData.warnWhenBatConnect then
	
		--  PlaySound
		app.d.log( "play => BATTERY_WARN_ONCONNECT_SOUND:" , BATTERY_WARN_ONCONNECT_SOUND , "flyData.onBatteryConnectEvent()"  )
		playFile( BATTERY_WARN_ONCONNECT_SOUND )

	end
	
	flyData.SavedClear()
	
	flyData.batStatus = BATTERY_CONNECTED
	flyData.batVoltStart = batVolt
	flyData.batPercentStart = p
	
	flyData.mAhCalcFlyable()	


   app.d.log( "flyData.batVoltStart" , flyData.batVoltStart , "onBatteryConnectEvent()" )
   app.d.log( "flyData.modelCells" , flyData.modelCells , "onBatteryConnectEvent()" )
	
end 

function flyData.onBatteryDisconnectEvent(wgt )

	-- d.log( "onBatteryDisconnectEvent(wgt) flyData.batStatus = "	, flyData.batStatus )
	-- d.log( "onBatteryDisconnectEvent(wgt)           batVolt = "	, flyData.batVolt )
	--	app.d.printAssoc( "onBatteryDisconnectEvent(wgt) flyData = "		, flyData )
	

	-- FlightMode NOT Zero -> NOT in Normal mode
	if flyData.warningBatDisconnectOnFly and getFlightMode() ~= 0 then

			-- Sound alert! :: Battery disconnected in fly
			flyData.warningSound()			
		
	else
		flyData.flightEndProcedure( wgt )
		
	end

	flyData.batStatus = BATTERY_DISCONNECTED

end 

function flyData.IsBatteryConnected()
	return ( flyData.batStatus == BATTERY_CONNECTED )
end

function flyData.detectFlightModeChange( wgt )
	local currentFlightMode = getFlightMode()

	if flyData.previousFlightMode ~= currentFlightMode then

		app.d.log( "detectFlightModeChange: " .. flyData.previousFlightMode , currentFlightMode )

		if currentFlightMode == 0 and flyData.flightStartTime ~= nil then
			flyData.onFlightEnd( wgt )
		elseif currentFlightMode ~= 0 and flyData.flightStartTime == nil then
			flyData.onFlightStart( wgt )
		end 

		flyData.previousFlightMode = currentFlightMode

	end

end

function flyData.onFlightStart(wgt)

	if flyData.batStatus == BATTERY_DISCONNECTED then
		flyData.SavedClear()
	end
	
	-- TODO: Ez nem a settings ben van?  Figyelmeztetés ha felszálláskor nincs kiválasztott aksi.
	-- settings.getWarnFlyBegin( )  => flyData.warnFlyBegin
	
	if flyData.warnFlyBegin and 
		flyData.selectedBatteryRecNum == 0 then
	
		-- Ha még nem volt figyelmeztetés aksi kiválasztás hiánya miatt (ami csak 1x történik) :
		if not flyData.warned_BatteryNotSelected then

			--  PlaySound
			app.d.log( "play => BATTERY_WARN_ONFLYMODEL_SOUND:" , BATTERY_WARN_ONFLYMODEL_SOUND , "flyData.onFlightStart()"  )
			playFile( BATTERY_WARN_ONFLYMODEL_SOUND )
			
			flyData.warned_BatteryNotSelected = true

		end
		
	end

	flyData.batVoltStart = flyData.batVoltReadSensor()
	flyData.flightStartTime = now()

	-- Calc just at the first start (Not at restart)
	flyData.mAhCalcFlyable()

end 

function flyData.onFlightEnd(wgt)

	-- d.log( "onFlightEnd(wgt), flyData.mAmpSensor   :: " , flyData.mAmpSensor  ) 
	-- d.log( "onFlightEnd(wgt), flyData.mAmpSensor :Value: " , getValue( flyData.mAmpSensor )  ) 

	-- Korábban felírva, Disconnetct-ben
	-- De ha nem is volt aksi adat, csak repülés?
	-- 			flyData.batVoltEnd = flyData.batVoltReadSensor( wgt )
	
	app.d.log( "flyData.batVoltEnd = " , flyData.batVoltEnd , "flyData.onFlightEnd(wgt)" ) 

	flyData.mAhReadSensor(wgt)

	flyData.flightEndTime = now()
	
	if flyData.batStatus == BATTERY_DISCONNECTED then
		-- Nincs aksi adat, de a repülésnek vége akkor indul a mentés
		flyData.flightEndProcedure( wgt )
	end 

	app.d.log( "onFlightEnd(wgt) = " , "Ended" ) 
	
end 

function flyData.flightEndProcedure( wgt )

	-- Ha se aksi se repülés, nem mentünk.
	
	-- d.printAssoc( "flightEndProcedure: flyData" , flyData, false )
	
	flyData.setQuickSelectLockPosition()
	
	if flyData.flightStartTime == nil and flyData.selectedBatteryRecNum == 0 then
	
		app.d.log( "flyData.flightStartTime"       , flyData.flightStartTime       , "flightEndProcedure::NOT writecsv, se aksi se repülés" )
		app.d.log( "flyData.selectedBatteryRecNum" , flyData.selectedBatteryRecNum , "flightEndProcedure::NOT writecsv, se aksi se repülés" )
		
	else

		-- Save Fly data to show on display after resetTimer()
		flyData.Save( wgt )

		-- Fly data write Log 
		flyData.flyLogWrite(wgt)
		
		app.d.log( "flyData.flightStartTime" , flyData.flightStartTime , "flightEndProcedure: Writecsv" )

		-- just if Flight happend	
		if flyData.flightStartTime ~= nil then
		
			-- If battery selected
			if flyData.selectedBatteryRecNum ~= 0 then
				
				batFile.setField( flyData.selectedBatteryRecNum , "count" 			, flyData.saved["batFlightCount"] )
				batFile.setField( flyData.selectedBatteryRecNum , "lastStartDate" , flyData.flightStartTime )
			
				-- Very first start 
				if flyData.batteryRec.firstStartDate == "" then
					batFile.setField( flyData.selectedBatteryRecNum , "firstStartDate" , flyData.flightStartTime )
				end 
				
				app.d.log( "flightEndProcedure" , "writecsv" )
				batFile.writeCsv()
				
			end
			
		end 
		
	end
	
	-- Beolvasott értékek alaphelyzetbe állítása
	flyData.flightModeReset()

end 

function flyData.flightModeReset()

	-- d.log( "Status:" , "Start" , "flightModeReset"  )

	
--	selectedBatteryRecNum = 0
--	wgt.selBatteryID = 0
	flyData.warned_BatteryNotSelected = false
	flyData.batStatus = BATTERY_DISCONNECTED
	flyData.selectedBatteryRecNum = 0
	
	quickSelLockPosition = QS_LOCK_POSITION_OFF

	flyData.selBatteryName = "Select Battery!"
	
	flyData.batPercentStart = nil
	flyData.batVoltStart = nil
	flyData.batVoltEnd = 0
	flyData.previousFlightMode = 0
	flyData.mAhUsable = nil
	flyData.mAhUsed = nil
	flyData.flightStartTime = nil
	flyData.flightEndTime = nil	
	
	flyData.batteryRec = {} 
	
	model.resetTimer( flyData.timerID )
	
	-- app.d.printAssoc( "flyData:" , flyData , "flightModeReset()"  )
	
end 

-- mAhFlyableCalc() Hivása: Connect eseménynél , majd felszálláskor, csak az első alkalommal az adott start-ban.
--                          Leszállási cél % módosulásakor
function flyData.mAhCalcFlyable()


	if flyData.selectedBatteryRecNum > 0 and flyData.batStatus == BATTERY_CONNECTED then

		local startBatPercent= flyData.getPercent( flyData.batVoltStart / flyData.batteryRec.cells  ) 		
		local usableCapacity = flyData.batteryRec.capacity * startBatPercent * 0.01
		local targetCapacity = flyData.batteryRec.capacity * flyData.targetLandingPercent * 0.01
		
		flyData.mAhUsable = math.floor( usableCapacity - targetCapacity )
		
		-- d.log( "mAhFlyableCalc() :: startBatPercent =" , startBatPercent )
		-- d.log( "mAhFlyableCalc() :: flyData.batteryRec.capacity =" , flyData.batteryRec.capacity )
		-- d.log( "mAhFlyableCalc() :: usableCapacity =" , usableCapacity )
		-- d.log( "mAhFlyableCalc() :: targetCapacity =" , targetCapacity )
		-- app.d.log( "FlyableMAh" , flyData.mAhUsable , "mAhFlyableCalc()" )

	else
		flyData.mAhUsable = nil
		
	end	
	
end

function flyData.mAhReadSensor( wgt )

	-- mAmp sensor defined (No selected => "--"  == 0 )
	if flyData.mAmpSensor ~= 0 then
	
		--	OLD:: local uM = getValue( flyData.mAmpSensor )
		-- uM ban az aktuális vagy legutolsó mért érték.
		-- isFresh = true -> van aktuálisan mért érték
		-- isCurrent = false -> Aktuális érték nincs, túl van a SensorLost figyelmeztetésen a kimaradás tartós 

		local uM, isCurrent, isFresh = getSourceValue( flyData.mAmpSensor )
		
		if not uM then 
			uM = 0
		end 	 
	 
		-- TODO: Csak teszt RightSlider (RS)-hez vagy S2-höz
		-- uM = uM + 1024
		
		if uM ~= nil and uM >= 0 then
			flyData.mAhUsed = uM
		else
			flyData.mAhUsed = 0
		end 
		
		-- app.d.log( "mAhReadSensor(), flyData.mAhUsed =  " , flyData.mAhUsed ) 
		
	end 
	
	if flyData.maxMAhSource ~= 0 then
	
		local uM, isCurrent, isFresh = getSourceValue( flyData.maxMAhSource )
		
		if not uM then 
			uM = 0
		end 	 

		-- app.d.log( "uM:MaxAMP " , uM , "mAhReadSensor()") 
		
		-- TODO: Csak teszt RightSlider (RS)-hez vagy S2-höz
		uM = uM + 1024

		
		if uM ~= nil and uM >= 0 then
			flyData.maxAmp = uM
		else
			flyData.maxAmp = 0
		end 
	end
	
end

function flyData.batVoltReadSensor()

	-- BatVolt sensor defined (No selected => "--"  == 0 )
	if ( voltReadSensor ) ~= 0 then
	
		-- isFresh = true -> van aktuálisan mért érték
		-- isCurrent = false -> Aktuális érték nincs, túl van a SensorLost 
		--								figyelmeztetésen a kimaradás tartós 

		local batVolt, isCurrent, isFresh = getSourceValue( flyData.voltReadSensor )
		
		if not isCurrent then 
			batVolt = 0
		end 
	 
		-- Start :: Teszthez  ====================================================================
		-- TODO : Csak a teszthez az érték módosítása
		-- Input -1024 - 1024, Inkább : 0 - 1014 :: 3,7 Volt - 4.2 Volt / Cell = 44.4 - 50,4 
		-- 3.4 = 5% =>       40,8 - 50,4
		
		-- if batVolt < 1 then
			-- batVolt = 0
		-- else
			-- batVolt = 40.8 + ( batVolt * 0.009375 )   -- [40.8 - 50.4]
		-- end
		
		-- d.log(  "batVolt" , batVolt, "flyData.batVoltReadSensor()" )
		-- End :: Teszthez  ======================================================================

	
		return batVolt	
		
		-- d.log( "batVoltReadSensor(), flyData.mAhUsed =  " , flyData.mAhUsed ) 
		
	else
		return nil
		
	end 
	

end 

function flyData.warningHaptic()

	app.d.log( "warningHaptic" , "Start" , "flyData.warningHaptic()" ) 

	-- playHaptic(duration, pause [, PLAY_NOW / 0])
	playHaptic( 50, 25 , PLAY_NOW )
	playHaptic( 50, 25 )
	playHaptic( 50, 25 )
	
end 

function flyData.mAhAction() 

	local function mAhActionDeleteUnder( tbl, val )

		while #tbl > 0 and  tbl[1] >= val do 	
			table.remove(tbl, 1)
		end
		
	end

	if flyData.mAhUsed == nil or flyData.mAhUsable == nil then
		-- d.log( "mAhAction() , flyData.mAhUsed = " 	, flyData.mAhUsed ) 
		-- d.log( "mAhAction() , flyData.mAhUsable = " , flyData.mAhUsable ) 
		return
	end

	local mAhPercent = 100 - math.floor( flyData.mAhUsed  / ( flyData.mAhUsable * 0.01 ) )
	
	-- Sound
	-- Jelenlegi % kisebb mint a következő határ
	if flyData.mahPercentsTable_Sound[ 1 ] and 
		mAhPercent <=  flyData.mahPercentsTable_Sound[ 1 ] and
		mAhPercent >= 0 then
		-- d.log( "mAhAction() , sound , mAhPercent =  " , mAhPercent ) 
		-- d.log( "mAhAction() , sound , flyData.mahPercentsTable_Sound[ 1 ] =  " , flyData.mahPercentsTable_Sound[ 1 ] ) 
		-- d.log( "mAhAction() , sound , mAhPercent <= flyData.mahPercentsTable_Sound[ 1 ] =  " , mAhPercent <= flyData.mahPercentsTable_Sound[ 1 ] ) 
	
		-- playNumber(value, unit [, attributes [, volume]])  => UNIT_PERCENT
	
		playNumber( mAhPercent, UNIT_PERCENT )
		
		mAhActionDeleteUnder( flyData.mahPercentsTable_Sound , mAhPercent )
		
	end
	
	-- Haptic

	if flyData.mahPercentsTable_Haptic[ 1 ] and
		mAhPercent <=  flyData.mahPercentsTable_Haptic[ 1 ] then
		
		flyData.warningHaptic()	

		mAhActionDeleteUnder( flyData.mahPercentsTable_Haptic , mAhPercent )
	
	end
	
	
	
	-- mAh OverUsed  :: flyData.flyOverHapticSec
	-- flyData.lastOverUseSec 
	--			Ebben a másodpercben volt utoljára figyelmeztetés overused miatt. 
	--			Tudni kell ebben a másodpercben volt e már figyelmeztetés, hogy elkerülhető legyen a dupla.
	if flyData.mAhUsed > flyData.mAhUsable and flyData.flyOverHapticSec > 0 then
	
		local mt = model.getTimer( flyData.timerID )
		flyData.lastOverUseSec = flyData.lastOverUseSec or mt.value

		-- app.d.log( "overUsed , mt.value  =  " , mt.value , "mAhAction()"  ) 
		-- app.d.log( "overUsed , ( t % flyData.flyOverHapticSec ) =  " , ( mt.value  % flyData.flyOverHapticSec ) , "mAhAction()" ) 
		-- app.d.log( "overUsed , flyData.lastOverUseSec =  " , flyData.lastOverUseSec , "mAhAction()" ) 

		if ( mt.value  % flyData.flyOverHapticSec ) == 0 and 
			  mt.value ~= flyData.lastOverUseSec	then
			  
			app.d.log( "play => FLYMAH_OVERUSE_HAPTIC_SOUND:" , FLYMAH_OVERUSE_HAPTIC_SOUND , "flyData.mAhAction()"  )
			playFile( FLYMAH_OVERUSE_HAPTIC_SOUND ,5)
			flyData.lastOverUseSec = mt.value
			-- d.log( "mAhAction() , overUsed , SETlastOverUseSec =  " , flyData.lastOverUseSec  ) 
			
			flyData.warningHaptic()
		end	
		
	end 

end 

function flyData.mAhActionClear() 

	local function mAhTblProcess( iTable )
		local oTbl = {}

		for i, v in ipairs(iTable) do
			 oTbl[i] = v
		end	
		
		table.sort( oTbl , function(a, b) return a > b end )

		-- delete double items	
		local rTbl = {}
		local rV = nil
		for i, value in ipairs(oTbl) do
			if value ~= rV then
				table.insert(rTbl, value)
				rV = value
			end
		end	

		-- d.log( "mAhTblProcess() :: Tbl = " , 	table.concat(rTbl,"," ) )
		-- d.log( "mAhTblProcess() :: Tbl 1 = " , 	rTbl[1] )

		return rTbl
	end

	-- d.log( "mAhActionClear() " , "Start" )
	-- mahPercentsTable_Sound
	-- mahPercentsTable_Haptic
	flyData.mahPercentsTable_Sound 	= mAhTblProcess( flyData.basePercentsTable_Sound )
	flyData.ahPercentsTable_Haptic	= mAhTblProcess( flyData.basePercentsTable_Haptic )

	-- d.log( "mAhActionClear() :: flyData.mahPercentsTable_Sound[ 1 ] = " , 	flyData.mahPercentsTable_Sound[ 1 ] )
	-- d.log( "mAhActionClear() :: flyData.mahPercentsTable_Haptic[ 1 ] = " , 	flyData.mahPercentsTable_Haptic[ 1 ] )

	
end

function flyData.readBatteryFile( batteryFile )
	batFile.readCsv( batteryFile )
end

function flyData.getBatteryTable()
	return batFile.getTable()
end

batFile  = loadScript( app.dir .. "csvfile.lua")()

flyData.flightModeReset()

return flyData

