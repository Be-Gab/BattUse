--[[#######################################################################
##  loadable.lua                                                         ##
##                BattUse - loadable                                     ##
##                                                                       ##
## Author: BeGab                                                         ##
## URL   : https://github.com/Be-Gab/BattUse                             ##
##                                                                       ##
##                      Copyright (C) "BeGab"                            ##
##                                                                       ##
###########################################################################
## License GNU General Public License v3.0                               ##
#########################################################################]]
local zone, options, app , settings, flyData = ...

local widget = {}
widget.options = options 
widget.zone		= zone

local dt
dt, errMsg = loadScript( app.dir .. "dt.lua" )( app ) 
dt.setFormat( settings.getDateFormat() )

local logLines  = loadScript( app.dir .. "csvfile.lua" )()

local LOG_PATHS		=	{	[1]	=	"/LOGS/" ,
									[2]	=	app.dir .. "LOGS/" }

local PERCENTS_COUNT		= 6
local LOG_MAX_ROW_COUNT = 10 --20 -- 20  
local PAGE_HEAD_HEIGH	= 40 * lvgl.LCD_SCALE 

local PAGE_WIDGET			= 1
local PAGE_BATSELECT		= 2
local PAGE_SETINPUT		= 3
local PAGE_BEHAVIOR		= 4
local PAGE_LOG_VIEW		= 5

--################# batFile + CSV

flyData.readBatteryFile( settings.getBattFileFullPath() )

--################# batFile + CSV :: End

--            All Settings
-- dtFormat
-- battFile

-- batVoltSource
flyData.setVoltReadSensor( settings.getBatVoltSource() )

-- batUsedMAhSource
flyData.setmAmpSensor( settings.getUsedMAhSource() )

-- batMaxMAhSource
flyData.setMaxMAhSource( settings.getMaxMAhSource() )

-- batBackupVolt
flyData.setBackupVolt( settings.getBackupVolt() )

-- batCell
flyData.setModelCells( settings.getBatCell( ) )

-- Timer
flyData.setTimerID( settings.getTimer() )

-- logPath
flyData.setLogPath( LOG_PATHS[ settings.getLogPathID() ] )

-- landingPercent
flyData.setTargetLandingPercent( settings.getLandingPercent() )

-- warnWhenBatConnect
flyData.setWarnWhenBatConnect(  settings.getWarnWhenBatConnect() )

-- warnFlyBegin
flyData.setWarnFlyBegin( settings.getWarnFlyBegin() )

-- flyOverHapticSec
flyData.setFlyOverHapticSec( settings.getFlyOverHapticSec() )

-- warningBatDissconnectOnFly
flyData.setWarningBatDisconnectOnFly( settings.getWarningBatDisconnectOnFly( ) )

-- minBatStartVolt
flyData.setMinBatStartVolt( settings.getMinBatStartVolt() )

-- warningBatOverUse
flyData.setWarningBatOverUse( settings.getWarningBatOverUse() )

-- hapticPercent
flyData.setBasePercentsTable_Haptic( settings.getHapticPercentAll() )

-- soundPercent 
flyData.setBasePercentsTable_Sound( settings.getSoundPercentAll() )

-- quickSelectChannel
flyData.setQuickSelChannel( settings.getQuickSelChannel() )


--== DateTime Format
flyData.setDateFormat( settings.getDateFormat() )

flyData.setQuickSelChannel( settings.getQuickSelChannel() )


local function fullScreenRefresh()
end

local function askClose()
	lvgl.confirm({title="Exit", message="Really exit?", confirm=(function() lvgl.exitFullScreen(); end) })
end

local function settingsFileName()
	local mi = model.getInfo()
	local modelConfigFile = string.format( "%s/%s.cfg"   , app.dir , mi.name )

	return modelConfigFile
end

-- Segédfüggvény: Komplex gomb leírás generálása
local function buttonCreate( bat, todayUsed, widget, options )
	local BTN_HEIGHT = 60  * lvgl.LCD_SCALE
	local BTN_WIDTH = widget.zone.w * 0.9	
	local BTN_LEFT = BTN_WIDTH * 0.3
	local BTN_CONT_HEIGHT	= BTN_HEIGHT -7 
	local BTN_CONT_WIDTH	= BTN_WIDTH - BTN_LEFT 
	
	local bat_also		= ( bat.count + bat.earlyCount ) .. " Flight"
	local bat_felso	= bat.product .. " " .. bat.capacity .. " mAh " .. bat.cells .. "S "
	local hv, dateColor
	
	local isSelectedColor = COLOR_THEME_PRIMARY2
	
	-- app.d.printAssoc( "bat" , bat, "buttonCreate()" )
	
	if flyData.selectedBatteryRecNum > 0 and flyData.batteryRec.id == bat.id then
		isSelectedColor = COLOR_THEME_SECONDARY2
	end
	
	if todayUsed then
		dateColor = COLOR_THEME_WARNING 	
	end

	if bat.maxVolt > 4.2 then
		hv = " HV"
	else	
		hv = ""
	end
	
	-- app.d.log( "BTN_CONT_WIDTH -30" , BTN_CONT_WIDTH -30 , "buttonCreate()" )
	 
	return {
			type	= "button",
			w		= BTN_WIDTH, 
			h		= BTN_HEIGHT, 
			color = isSelectedColor ,
			press	=	(	
							function() 
								flyData.selectBatteryByID( bat.id ); 
								lvgl.exitFullScreen(); 
							end
						) ,
			children	=	{
				{
					type	= "rectangle" , -- full Button
					x		= 0 , 
					y		= 0 , 
					w		= BTN_WIDTH - 15  , 
					h		= BTN_CONT_HEIGHT	, 
					align = LEFT ,
					flexFlow	= lvgl.FLOW_ROW	,
					flexPad	= 0 , --lvgl.PAD_SMALL, -- 0 ,	-- lvgl.PAD_ZERO	,
					scrollBar= false,  scrollDir = lvgl.SCROLL_OFF ,
					thickness= 0 ,
					children	=	{
						{	type	= "rectangle",  			--LEFT
							w		= BTN_LEFT , 
							h		= BTN_CONT_HEIGHT-2, 
							scrollBar= false,  scrollDir = lvgl.SCROLL_OFF ,
							flexFlow	= lvgl.FLOW_ROW ,
							thickness= 0 ,
							children	= {
								{	type	= "label", 
									press	= nil,
									text	= string.sub( bat.id, 1,6 ) ,
									font	= DBLSIZE,
									align	= CENTER + VCENTER
								}
							},						
						}
						,
						{	type	= "vline", w=2, h=BTN_HEIGHT-11, color=COLOR_THEME_SECONDARY2 } 
						,
						{	type	= "box" , 				-- RIGHT
							w		= BTN_CONT_WIDTH - ( 30 * lvgl.LCD_SCALE ),
							h		= BTN_CONT_HEIGHT -2, 
							press	= nil,
							-- clickable= false,
							-- thickness= 0 ,
							scrollBar= false,  scrollDir = lvgl.SCROLL_OFF ,
							flexFlow	= lvgl.FLOW_COLUMN , 
							children = {
								{	type	= "box" , 			-- right-up
									w		= BTN_CONT_WIDTH - ( 32 * lvgl.LCD_SCALE ) , 
									flexFlow = lvgl.FLOW_ROW , 
									-- thickness= 0 ,
									children = {
										{	type	= "label", 
											w		= 100 * lvgl.LCD_SCALE,
											text	= string.sub( bat.product, 1,10 ) ,
										} ,
										{	type	= "label", 
											w		= 80 * lvgl.LCD_SCALE,
											text	= bat.capacity .. " mAh"
										} ,
										{	type	= "label", 
											w		= 65 * lvgl.LCD_SCALE,
											text	= bat.cells .. "S" .. hv
										} 
									 }
								}	-- right-up
								,
								{	type	= "hline" , w= 280 * lvgl.LCD_SCALE, h=1, color=COLOR_THEME_SECONDARY2 }  
								,
								{	type	= "box" , -- right-down
									w		= BTN_CONT_WIDTH - ( 32  * lvgl.LCD_SCALE ) , -- - BTN_LEFT,-- - 50, 
									press	= nil,
									flexFlow = lvgl.FLOW_ROW , 
									flexPad	= 0 , 
									-- thickness= 0 ,
									children = {
										{	type	= "label", 
											w		= 160 * lvgl.LCD_SCALE,
											text	= dt.getDateTime( bat.lastStartDate ),
											color	= dateColor,
										},
										{	type	= "label", 
											text	= "Flight: "
										},
										{	type	= "label", 
											w		= 40 * lvgl.LCD_SCALE,
											text	= tostring( bat.count + bat.earlyCount ),
										}
									} ,
								}	-- right-down
						}	-- right	
						}
					}
				
				}
			}			
		} 
	 
	 
end

local function createButtons(widget, options)
	local children = {};
	local batList = flyData.getBatteryTable()
	local key, row
	
	-- app.d.printAssoc( "batList" , batList , true )
	
	for key , row in ipairs(batList) do
		if row.retireDate == "" then	

			todayUsed = dt.isToday( row.lastStartDate )
			
			children[#children+1] = buttonCreate( row, todayUsed,widget, options );
			
		end  
	end

	return children;
end 


--#### widget. #########################################################

function isErrorInInputs()
	-- TODO : 
			-- Nem feltétel, default érték jó lesz :: Backup Battery Volt
		-- Battery Cell # 0!  Default érték : 0
		-- Timer : legyen kiválasztva!  Legyen visszaszámoló! Default = 0
		
	if settings.getTimer() < 0 then
		app.d.log( "settings.getTimer()", settings.getTimer() , "isErrorInInputs()" )
		return true
	else
		local mt = model.getTimer( settings.getTimer() )
		-- Start from 0, mean not countdown.
		if mt.start == 0 then
			app.d.log( "mt.start", mt.start , "isErrorInInputs()" )
			return true
		end
	end
	
	-- BatCell is default = 0, have to set it.
	if settings.getBatCell( ) == 0 then
		app.d.log( "settings.getBatCell( )", settings.getBatCell() , "isErrorInInputs()" )
		return true
	end
	
	return false
end

function widget.background( widget )


	flyData.detectBatteryConnect( widget )
	flyData.detectFlightModeChange( widget )
	
	flyData.mAhReadSensor( widget )
	
	if getFlightMode() ~= 0 then
		-- mAh state , sound and other actions
		flyData.mAhAction()
	end
	
end

--local initialized = false;
function widget.update( widget, options )
	
	-- app.d.log( "update() .w", widget.zone.w , "widget.update( widget, options )" )
	
   if (lvgl.isFullScreen() or lvgl.isAppMode()) then
		if isErrorInInputs() then
			widget.switchPage( PAGE_SETINPUT , widget, options )
		else
			widget.switchPage( PAGE_BATSELECT , widget, options )
		end
	else
	
		if isErrorInInputs() then
			app.d.log( "update() ", "isError found!" , "widget.update( widget, options )" )
			lvgl.clear()
			dispError( widget )
		else
			widget.widgetPage( widget,  options )	-- Widget felépítés létrehozása.
		end
	end

	widget.options = options
	 
end

function widget.refresh(event, touchState)

	if lvgl == nil then
		lcd.drawText(widget.zone.x, widget.zone.y, "Lvgl support required", COLOR_THEME_WARNING)
	end
	if (lvgl.isFullScreen()) then
		fullScreenRefresh();
	-- else

		-- if touchState then
			-- app.d.log( "touchState" , touchState , "widget.refresh()" )
			-- app.d.log( "touchState-typ" , type( touchState ) , "widget.refresh()" )
		-- end
		
		-- if event then
			-- app.d.log( "event" , event , "widget.refresh()" )
			-- app.d.log( "event-typ" , type( event ) , "widget.refresh()" )
		-- end
	
	end
	
	widget.background( widget );

end

function widget.pageHead( screenType, subUi, widget, options )
	local headHeight = PAGE_HEAD_HEIGH 
	local btnHeigh = headHeight - ( 16  * lvgl.LCD_SCALE )
	local picWidth = headHeight
	local titleWidth = 120 * lvgl.LCD_SCALE
	local headButtons, iconFile, subTitle
	local title = "BattUse"
	
	-- app.d.log( "flyData.quickSelChannel" , ">" .. flyData.quickSelChannel .. "<", "widget.pageHead()" )
	
	-- local showSelectButton
	-- if ( 0 ~= flyData.quickSelChannel ) then
		-- showSelectButton = false
		-- app.d.log( "flyData.quickSelChannel?" , "<>0" , "widget.pageHead()" )
	-- else
		-- showSelectButton = true
		-- app.d.log( "flyData.quickSelChannel?" , "==0" , "widget.pageHead()" )
	-- end
	
	local btnInputs	=	{ type = "button", text = "Input" ,
									w = 55 * lvgl.LCD_SCALE, h = btnHeigh ,
									press = (function() widget.switchPage( PAGE_SETINPUT, widget, options	); end)
								}
	local btnSelect	=	{ type = "button", text = "Batteries" ,
									w = 80 * lvgl.LCD_SCALE, h = btnHeigh ,
									-- hami érték esetén nem rejti el a gombot...
									visible	= (function() return ( 0 == flyData.quickSelChannel ); end) ,
									press		= (function() widget.switchPage( PAGE_BATSELECT, widget, options ); end)
								}
	local btnBehavior	=	{ type = "button", text = "Behaviour" ,
									w = 90 * lvgl.LCD_SCALE, h = btnHeigh ,
									press = (function() widget.switchPage( PAGE_BEHAVIOR, widget, options ); end)
								}
	local btnLog		=	{ type = "button", text = "Log" ,
									w = 45 * lvgl.LCD_SCALE, h = btnHeigh ,
									press = (function() widget.switchPage( PAGE_LOG_VIEW, widget, options ); end)
								}
	local btnClose		=	{ type = "button", text = "Close" ,
									w = 55 * lvgl.LCD_SCALE, h = btnHeigh ,
									press = (function() lvgl.exitFullScreen(); end)
								}

	if		screenType == PAGE_BATSELECT then

		headButtons = 	{	btnInputs	,	btnBehavior	,	btnLog, btnClose	}
		subTitle		=	"Select Battery"
		iconFile		= app.dir .. "icon/" .. "bat.png"
							
	elseif screenType == PAGE_SETINPUT then

		headButtons = 	{	btnBehavior	,	btnSelect ,	btnLog, btnClose	}
		subTitle		=	"Set Input"
		iconFile		= app.dir .. "icon/" .. "inp.png"
	
	elseif screenType == PAGE_BEHAVIOR then

		headButtons = 	{	btnInputs	,	btnSelect ,	btnLog, btnClose	}
		subTitle		=	"Set Behaviour"
		iconFile		= app.dir .. "icon/" .. "bhvr.png"
		
	elseif screenType == PAGE_LOG_VIEW then

		headButtons = 	{	btnInputs	,	btnBehavior, 	btnSelect ,	btnClose	}
		subTitle		=	"Show Log"
		iconFile		= app.dir .. "icon/" .. "log.png"
		
	end
	
	-- d.log( "widget.zone.w:" , widget.zone.w , "head" )
	-- d.log( "lcd.w:" , LCD_W , "head" )
	-- d.log( "zone.w:" , zone.w , "head" )

	local zw = LCD_W -- 480
	local zh = LCD_H

	--d.log( "image file :" , iconFile					, "pageHead()" )	
	--  /WIDGETS/TstLvgl/icon/bu-icon.bmp
	local base =	{
							{	type = "box", -- id = "fullScreen" ,
								color = WHITE ,
								x = 0 , 
								y = 0 ,
								-- w = zw , -- widget.zone.w , 
								w = zw , 
								h = zh , --widget.zone.h , 
								children = {
									{	type = "rectangle" , -- id = "head" ,
										thickness = 0 ,
										color = COLOR_THEME_SECONDARY1 , filled = true,  
										x = 0, 
										y = 0,
										w = zw, --widget.zone.w , 
										h = headHeight ,
										children =	{
											{	type = "box" , -- id = "pic" ,
												x = 0, 
												y = 0 ,
												w = picWidth , 
												h = headHeight, 
												children = {
													{  type = "image" ,
														w = picWidth , h = headHeight,
														file = iconFile,
														fill = true , -- False = NO resize
													}
												}
											} -- pic
											,
											{	type = "box" , -- id = "title" ,
												flexFlow = lvgl.FLOW_COLUMN , 
												flexPad =  0 , 
												scrollBar = false, scrollDir = 0,
												x = picWidth , 
												y = 0 ,
												w = titleWidth , 
												h = headHeight ,
												children = {
													{	type = "label" ,
														text = title ,
														color = COLOR_THEME_PRIMARY2,
													}
													,
													{	type = "label" ,
														text = subTitle ,
														color = COLOR_THEME_PRIMARY2,
														font	= SMLSIZE , 
													}
												}
											} -- title
											,
											{	type = "rectangle" , -- id = "menu" ,
												thickness = 0 ,
												flexFlow = lvgl.FLOW_ROW , 
												flexPad =  lvgl.PAD_SMALL , 
												x = picWidth + titleWidth ,
												y = 0 ,
												align = VCENTER + CENTER,
												-- w = widget.zone.w - picWidth - titleWidth , 
												w = zw - picWidth - titleWidth , 
												h = headHeight , 
												children = headButtons
											} -- menu
											
										}
									}	-- head
									,
									{ type = "rectangle" , -- id = "body" ,
										y = headHeight ,  
										x = 0 ,
										w = zw,	--widget.zone.w , 
										h = zh - headHeight ,
 										-- h = widget.zone.h - headHeight , 
										color = COLOR_THEME_SECONDARY3 , filled = true, 
										children =	
											{
												{ type = "rectangle" , -- id = "subbody" ,
													thickness = 0 ,
													flexFlow = lvgl.FLOW_COLUMN , flexPad = lvgl.PAD_SMALL , 
													scrollBar = true, scrollDir = lvgl.SCROLL_VER,
													w = zw, --widget.zone.w , 
													-- color = GRAY , filled = true, 
													children =	subUi
												} -- subbody
											}
									} -- body
								}								
							}	--	fullScreen
						}

	lvgl.clear();
	
	return lvgl.build( base )	
		
end

function widget.selectPage(widget, options)
	local gombok = createButtons(widget, options)
	
	-- app.d.log( "indul",3, "widget.selectPage()" )	

	ui = widget.pageHead( PAGE_BATSELECT, gombok ,widget, options )
	
	return ui
end
 
function widget.setInputPage(widget, options)
	local srcFilter =  lvgl.SRC_CLEAR | lvgl.SRC_TELEM
	local srcQS_Filter= lvgl.SRC_CLEAR | lvgl.SRC_POT

	-- TODO : Törölni, Csak teszt idejére bővítve a filter.
	-- srcFilter =  lvgl.SRC_ALL
	
	lvgl.clear();
			
	uit =	{
				{	type = "rectangle",
					thickness = 0 ,
					flexFlow = lvgl.FLOW_ROW, 
					children = {
						{	type	= "label", 
							text	= "Battery file" 
						}
						,
						{	type	= "choice",  
							w		= 260 * lvgl.LCD_SCALE,
							title = "Select battery file",
							values= settings.listBatfiles() ,
							get = (function( ) return settings.getBattFileID(   ); end) , 
							set =	function(s)        
										settings.setBattFileID( s ); 
										flyData.readBatteryFile( settings.getBattFileFullPath() );
									end	
						} 
					}
				}
				,
				{	type = "rectangle",
					thickness = 0 ,
					flexFlow = lvgl.FLOW_ROW, 
					children = {
						{	type = "label", text = "Battery Voltage telemetry sensor : " },
						{	type = "source",  filter = srcFilter, 
							get = (function( ) return settings.getBatVoltSource(   ); end) , 
							set = (	function(s)        
											settings.setBatVoltSource( s ); 
											flyData.setVoltReadSensor(s);
										end
									) } 
					}
				}
				,
				{ type = "rectangle", 
					thickness = 0 ,
					flexFlow = lvgl.FLOW_ROW, 
					children = {
						{	type = "label", text = "Current telemetry sensor : " },
						{	type = "source", filter = srcFilter, 
							get = (function( ) return settings.getUsedMAhSource(   ); end), 
							set = (	function(s)        
											settings.setUsedMAhSource( s ); 
											flyData.setmAmpSensor( settings.getUsedMAhSource() );
										end
									) }											  
					}
				}
				,	
				{ type = "rectangle", 
					thickness = 0 ,
					flexFlow = lvgl.FLOW_ROW, 
					children = {
						{	type = "label", text = "Peak current telemetry sensor : " },
						{	type = "source",   filter = srcFilter, 
							get = (function( ) return settings.getMaxMAhSource(   ); end), 
							set = (	function(s)        
											settings.setMaxMAhSource( s ); 
											flyData.setMaxMAhSource( settings.getMaxMAhSource() );
											end
									) }
					}
				}
				,	
				{ type = "rectangle", 
					thickness	= 0 ,
					flexFlow		= lvgl.FLOW_ROW, 
					children		= {
						{	type	= "label", text = "Battery quick selector channel : " },
						{	type	= "source",   filter = srcQS_Filter , 
							get	= (function( ) return settings.getQuickSelChannel(); end), 
							set	=	(	function(s)        
												settings.setQuickSelChannel( s ); 
												flyData.setQuickSelChannel( settings.getQuickSelChannel() );
											end
										) 
						}
					}
				}
				,
				
				{ type = "rectangle", 
					flexFlow = lvgl.FLOW_ROW, 
					thickness = 0 ,
					children = {
						{	type = "label", text = "Backup battery voltage : "},
						{	type = "numberEdit", min = 0, max = 45, w = 60, 
							get = (function( ) return settings.getBackupVolt(   ); end), 
							set = (	function(v)
											settings.setBackupVolt( v ); 
											flyData.setBackupVolt( settings.getBackupVolt() );
											end
									) }
					}
				}
				,
				{ type = "rectangle", 
					flexFlow = lvgl.FLOW_ROW, 
					thickness = 0 ,
					children = {
						{	type	= "label", 
							text	= "Battery cell count : "
						},
						{	type	= "choice", 
							-- min = 0, max = 45, 
							w		= 60, 
							title	= "Select cell count" ,
							values= { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14" } ,
							get = (function() return settings.getBatCell(); end), 
							set = (	function(v)
											settings.setBatCell( v ); 
											flyData.setModelCells( settings.getBatCell() );
											end
									) 
						}
					}
				}
				,	
				{ type = "rectangle", 
					flexFlow = lvgl.FLOW_ROW, 
					thickness = 0 ,
					children = {
						{	type = "label", text = "Timer " },
						{	type = "timer",  
							get = (function( ) return settings.getTimer(   ); end) , 
							set = (	function(s)
											settings.setTimer( s );
											flyData.setTimerID( settings.getTimer() );
											end
									) },
					}
				}

			}
          

	ui = widget.pageHead( PAGE_SETINPUT, uit, widget, options )
	
	return ui
end
 
function widget.behaviorPage(widget, options)
	local srcFilter =  lvgl.SRC_CLEAR | lvgl.SRC_TELEM
	local tblSoundPercents = {}
	local tblHapticPercents = {}
	
	-- app.d.log( "indul", 2, "widget.behaviorPage()" )	
	
	for i = 1, PERCENTS_COUNT do

		-- HapticPercents
		tblHapticPercents[ #tblHapticPercents + 1 ] =
							{	type	= "numberEdit",
								min	=  0 , 
								max	= 98 ,
								w		= 34 * lvgl.LCD_SCALE,
								get	=	function( ) 
												return settings.getHapticPercent( i );    
											end , 
								set	=	function(s)        
												settings.setHapticPercent( i, s ); 
												flyData.setBasePercentsTable_Haptic( settings.getHapticPercentAll() )
											end
							} 
							
		tblHapticPercents[ #tblHapticPercents + 1 ] =
							{	type	= "label", 
								text	= " % " 
							}

		-- SoundPercents
		tblSoundPercents[ #tblSoundPercents + 1 ] =
							{	type	= "numberEdit",
								min	=  0 , 
								max	= 98 ,
								w		= 34 * lvgl.LCD_SCALE,
								get	=	function( ) 
												return settings.getSoundPercent( i );    
											end , 
								set	=	function(s)        
												settings.setSoundPercent( i, s ); 
												flyData.setBasePercentsTable_Sound( settings.getSoundPercentAll() )
											end
							} 
							
		tblSoundPercents[ #tblSoundPercents + 1 ] =
							{	type	= "label" , 
								text = " % " 
							}

		
	end

	lvgl.clear();
			
	uit =	{
				{	type		= "box",
					flexFlow = lvgl.FLOW_ROW, 
					children = {
						{	type	= "label", 
							text	= "Landing percent : " 
						},
						{	type	= "slider",  
							w		= 260 * lvgl.LCD_SCALE ,
							min	= 20, 
							max	= 90,
							get =	function( ) 
											return settings.getLandingPercent(); 
									end , 
							set =	function(s)        
										settings.setLandingPercent( s ); -- Rounding here.
										flyData.setTargetLandingPercent( settings.getLandingPercent() );
										flyData.mAhCalcFlyable();
									end
						} ,
						{	type	= "label", 
							text	=	function() 
											return math.floor( settings.getLandingPercent() ) .. "%"; 
										end
						}
					}
				}
				,
				{	type		= "box",
					flexFlow	= lvgl.FLOW_ROW, 
					children = {
						{	type	= "label", 
							text	= "Log path : " 
						},
						{	type	= "choice",  
							w		= 260 * lvgl.LCD_SCALE,
							title = "Select log path",
							values=	{	LOG_PATHS[1] , 
											LOG_PATHS[2] 
										} ,
							get	=	function() 
											return settings.getLogPathID(); 
										end , 
							set	=	function(s)
											settings.setLogPathID( s ); 
											flyData.setLogPath( LOG_PATHS[ s ] );
										end
						} 
					}
				}
				,
				{	type		= "box",
					flexFlow = lvgl.FLOW_ROW, 
					children = {
						{	type	= "label", 
							text	= "Date format : " },
						{	type	= "choice",  
							w		= 260 * lvgl.LCD_SCALE,
							title	= "Select DATE format",
							values= dt.getDateFormats() ,
							get	=	function( )
											return settings.getDateFormat(); 
										end, 
							set	=	function(s)        
											settings.setDateFormat( s ); 
											dt.setFormat( s );
											flyData.setDateFormat( s );
										end
						} 
					}
				}
				,
				{	type		= "box",
					flexFlow = lvgl.FLOW_ROW, 
					children = {
						{	type	= "label", 
							text	= "Battery warning when connected : " 
						},
						{	type	= "toggle",  
							get	=	function( ) 
											return settings.getWarnWhenBatConnect(   ); 
										end , 
							set	=	function(s)
											settings.setWarnWhenBatConnect( s ); 
											flyData.setWarnWhenBatConnect( s )
										end
						} 
					}
				}
				,
				{	type		= "box",
					flexFlow = lvgl.FLOW_ROW, 
					children = {
						{	type	= "label", 
							text	= "Battery warning when disconnected in flight " 
						},
						{	type	= "toggle",  
							get	=	function( ) 
											return settings.getWarningBatDisconnectOnFly(); 
										end, 
							set	=	function(s)
											settings.setWarningBatDisconnectOnFly( s );
											flyData.setWarningBatDisconnectOnFly( s );
										end
						} 
					}
				}
				,
				{	type		= "box",
					flexFlow = lvgl.FLOW_ROW, 
					children = {
						{	type	= "label", 
							text	= "Battery warning when flight begins " 
						},
						{	type	= "toggle",  
							get	=	function( ) 
											return settings.getWarnFlyBegin(   ); 
										end , 
							set	=	function(s)
											settings.setWarnFlyBegin( s ); 
											flyData.setWarnFlyBegin( s );
										end
						} 
					}
				}
				,
				{	type		= "box",
					flexFlow = lvgl.FLOW_ROW, 
					children = {
						{	type	= "label", 
							text	= "Warning when battery connected below " 
						} ,
						{	type	= "numberEdit",
							w		= 34  * lvgl.LCD_SCALE,
							min	= 20 , 
							max	= 95 ,
							get	=	function( )
											return settings.getMinBatStartVolt(); 
										end , 
							set	=	function(s)
											settings.setMinBatStartVolt( s ); 
											flyData.setMinBatStartVolt( s );
										end
						} ,
						{	type	= "label", 
							text	= " % of charge" 
						}
					}
				}
				,
				{	type		= "box",
					flexFlow = lvgl.FLOW_ROW, 
					children = {
						{	type	= "label", 
							text	= "Battery overuse warning at " 
						},
						{	type	= "numberEdit",
							w		= 34 * lvgl.LCD_SCALE ,
							min	= 0 , 
							max	= 95,
							get	=	function( ) 
											return settings.getWarningBatOverUse(); 
										end, 
							set	=	function(s)
											settings.getWarningBatOverUse( s ); 
											flyData.setWarningBatOverUse( s );
										end
						},
						{	type	= "label", 
							text	= " %" 
						}
					}
				}
				,
				{	type		= "box",
					flexFlow = lvgl.FLOW_COLUMN, 
					children = {
						{	type	= "label", 
							text	= "Report remaining charge during flight at :" 
						} ,
						{	type		= "box",
							flexFlow = lvgl.FLOW_ROW, 
							children = tblSoundPercents	
						}
					}
				}
				,
				{	type		= "box",
					flexFlow = lvgl.FLOW_COLUMN, 
					children = {
						{	type	= "label", 
							text	= "Haptic notification when battery level drops under" 
						} ,
						{	type		= "box",
							flexFlow = lvgl.FLOW_ROW, 
							children = tblHapticPercents	
						}
					}
				}
				,
				{	type		= "box",
					flexFlow = lvgl.FLOW_ROW, 
					children = {
						{	type	= "label", 
							text	= "Haptic warning when overused, every " 
						},
						{	type	= "numberEdit",
							w		= 34  * lvgl.LCD_SCALE,
							min	=  0 , 
							max	= 20 ,
							get	=	(
											function( ) 
												return settings.getFlyOverHapticSec(); 
											end
										) , 
							set	=	(
											function(s)
												settings.setFlyOverHapticSec( s ); 
												flyData.setFlyOverHapticSec( s );
											end
										) 
						},
						{	type	= "label" ,
							text	= " secs" 
						}
					}
				}
				
			}

	ui = widget.pageHead( PAGE_BEHAVIOR, uit, widget, options )

	return ui
end

function widget.logViewPage(widget, options)
	local BTN_HEIGHT = 32 * lvgl.LCD_SCALE
	local BTN_WIDTH = widget.zone.w * 0.9	
	
	local logFile = flyData.getLogFile()
	local logLineId = 0
	local detailsVisible = false
	
	logLines.readCsv( logFile )
	
	--	Process backwards the last lines, max line count : LOG_MAX_ROW_COUNT
	local logButtons = {};
	local key, row
	local logList = logLines.getTable()
	
	-- app.d.printAssoc( "logViewPage() logList" ,  logList )

	-- app.d.log( "math.min( #logList , LOG_MAX_ROW_COUNT )" , math.min( #logList , LOG_MAX_ROW_COUNT ) , "logViewPage()" )

	for r = #logList , #logList - math.min( #logList , LOG_MAX_ROW_COUNT ) +1, -1 do

		logButtons[#logButtons+1] = 
			{
				type	= "button",
				w		= BTN_WIDTH , 
				h		= BTN_HEIGHT, 
				press	=	(	
								function() 
									logLineId = r;
									detailsVisible = true;
								end
							) ,
				children	=	{
									{
										type	= "box" , -- full Button
										-- x		= 0 , 
										-- y		= 0 , 
										w		= BTN_WIDTH		- 15  , 
										h		= BTN_HEIGHT	-  5	, 
										align = LEFT ,
										flexFlow	= lvgl.FLOW_ROW	,
										flexPad	= 0 ,
										scrollBar= false,  scrollDir = lvgl.SCROLL_OFF ,
										-- clickable= false	,
										children	=	{
															{	type	= "label", 
																w		= 160 * lvgl.LCD_SCALE,
																text	= dt.getDateTime( logList[r].startFly ) 
															} ,
															{	type	= "label", 
																w		= 90 * lvgl.LCD_SCALE,
																text	= logList[r].batteryID 
															} ,
															{	type	= "label", 
																w		= 40 * lvgl.LCD_SCALE,
																text	= logList[r].flyTime
															} ,
															{	type	= "label", 
																w		= 80 * lvgl.LCD_SCALE,
																align	= RIGHT,
																text	= logList[r].mAmpFly .. " mA"
															} 
										}
											
									}
				}
			} 		
		
	end	   -- For

	-- app.d.printAssoc( "logButtons" , logButtons , true )
	-- app.d.printAssoc( "logList" , logList , true )
	
	logLineId = 0

	-- Add details info panel 
	detailBox =	{	type	= "box" ,
						w		= widget.zone.w ,
						h		= widget.zone.h - PAGE_HEAD_HEIGH -5 ,
						flexFlow	= lvgl.FLOW_COLUMN ,
						flexPad	= lvgl.PAD_SMALL ,
						align		= CENTER+VCENTER,
						children =	{
											{	type	= "button" , -- full Button
												cornerRadius = 12 * lvgl.LCD_SCALE,
												w		= widget.zone.w * 0.92 , 
												h		= 220 * lvgl.LCD_SCALE ,
												-- h		= widget.zone.h - PAGE_HEAD_HEIGH -15 ,
												-- align	= CENTER + VCENTER ,
												press		=	(
																	function() 
																		detailsVisible = false;
																	end
																) ,
												children	=	{
																	{	type	= "box" , -- full Button
																		x		= 0 , 
																		y		= 0 , 
																		w		= widget.zone.w * 0.9 , 
																		h		= 220 * lvgl.LCD_SCALE , 
																		flexFlow	= lvgl.FLOW_COLUMN, 
																		scrollBar= false,  scrollDir = lvgl.SCROLL_OFF ,

													-- Start time:  [startFly] - [endFly]
													-- FlyTime	  :                [flyTime]
													-- Amper, Used : [mAmpFly] mAmp    Max: [maxAmp] Amp

													-- Battery,  ID: [batteryID] , Product : [batteryProduct], Start count: [startCount]

													-- Volt at the begining: [startBatVolt] Volt [startBatPercent]%
													-- Volt at the end     : [endBatVolt] Volt [endBatPercent]%

																		children	=	{
																							{	type	=	"box",
																								flexFlow	= lvgl.FLOW_ROW, 
																								flexPad	= 0 ,
																								align		= LEFT,		
																								children	=	{
																									{	type	= "label", 
																										w		= 80 * lvgl.LCD_SCALE,
																										font	= SMLSIZE ,
																										text	= "Date & time : "
																									},
																									{	type	= "label", 
																										-- w		= 320,
																										align	= CENTER ,
																										text	=	(	
																														function() 
																															return dt.getDateTime( logList[ logLineId ].startFly ) 
																															       .. " - " .. 
																																	 dt.getDateTime( logList[ logLineId ].endFly );
																														end
																													) 
																									},

																								}
																							}
																							,
																							{	type	=	"box",
																								flexFlow	= lvgl.FLOW_ROW, 
																								flexPad	= 0 ,
																								align		= LEFT + VCENTER,		
																								children	=	{
																									{	type	= "label", 
																										w		= 80 * lvgl.LCD_SCALE,
																										font	= SMLSIZE ,
																										text	= "Duration : "
																									},
																									{	type	= "label", 
																										w		= 320 * lvgl.LCD_SCALE,
																										align	= CENTER ,
																										font	= MIDSIZE,
																										text	=	(	
																														function() 
																															return logList[ logLineId ].flyTime;
																														end
																													) 
																									},
																									
																								}
																							}
																							,
																							{	type	=	"box",
																								flexFlow	= lvgl.FLOW_ROW, 
																								flexPad	= 0 ,
																								align		= LEFT + VCENTER,		
																								children	=	{
																									-- {	type	= "label", 
																										-- w		= 80,
																										-- font	= SMLSIZE ,
																										-- text	= "Amper:"
																									-- },
																									{	type	= "label", 
																										w		= 80 * lvgl.LCD_SCALE,
																										font	= SMLSIZE ,
																										text	= "Current draw:"
																									},
																									{	type	= "label", 
																										w		= 320 * lvgl.LCD_SCALE,
																										align	= CENTER ,
																										font	= MIDSIZE ,
																										text	=	(	
																														function() 
																															return 
																																	-- "Current draw: " ..
																																	 logList[ logLineId ].mAmpFly .. " mA," ..
																																	 " / Peak: " ..
																																	 logList[ logLineId ].maxAmp .. " A";
																														end
																													) 
																									},
																									
																								}
																							}
																							,
																							{	type		= "box",
																								flexFlow	= lvgl.FLOW_ROW, 
																								flexPad	= 0 ,
																								align		= LEFT + VCENTER,		
																								children	=	{
																									{	type	= "label", 
																										w		= 80 * lvgl.LCD_SCALE,
																										font	= SMLSIZE ,
																										text	= "Battery:"
																									},
																									{	type	= "label", 
																										w		= 320 * lvgl.LCD_SCALE,
																										align	= CENTER ,
																										font	= MIDSIZE,
																										text	=	(	
																														function() 
																															local s;
																															s = logList[ logLineId ].batteryID 
																																 .. " / " ..
																																 logList[ logLineId ].batteryProduct;
																															if logList[ logLineId ].startCount then;
																																s	= s .. " , Count:" ..
																																	 logList[ logLineId ].startCount;
																															end;
																															return s;
																														end
																													) 
																									},
																									
																								}
																							}
																							,
																							{	type		= "box",
																								flexFlow	= lvgl.FLOW_ROW, 
																								flexPad	= 0 ,
																								align		= LEFT + VCENTER,		
																								children	=	{
																									{	type	= "label", 
																										w		= 120 * lvgl.LCD_SCALE,
																										font	= SMLSIZE ,
																										text	= "Initial charge level : "
																									},
																									{	type	= "label", 
																										w		= 280 * lvgl.LCD_SCALE,
																										align	= CENTER ,
																										font	= MIDSIZE,
																										text	=	(	
																														function() 
																															return logList[ logLineId ].startBatVolt 
																																	 .. " V  " ..
																																	 logList[ logLineId ].startBatPercent .. " %";
																														end
																													) 
																									},
																									
																								}
																							}
																							,
																							{	type		= "box",
																								flexFlow	= lvgl.FLOW_ROW, 
																								flexPad	= 0 ,
																								align		= LEFT + VCENTER,		
																								children	=	{
																									{	type	= "label", 
																										w		= 120 * lvgl.LCD_SCALE,
																										font	= SMLSIZE ,
																										text	= "Final charge level : "
																									},
																									{	type	= "label", 
																										w		= 280 * lvgl.LCD_SCALE,
																										align	= CENTER ,
																										font	= MIDSIZE,
																										text	=	(	
																														function() 
																															return logList[ logLineId ].endBatVolt 
																																	 .. " V  " ..
																																	 logList[ logLineId ].endBatPercent .. " %";
																														end
																													) 
																									},
																									
																								}
																							}
																							
																		}
																
																	}
												}
											}
						}
					}	
					

	lvgl.clear();
			
	uit =	{

				{	type		= "box" ,
					h			= widget.zone.h - PAGE_HEAD_HEIGH -5 ,
					w			= widget.zone.w,
					scrollBar= false,
					children =  {
										{	type		= "box" ,
											h			= widget.zone.h - PAGE_HEAD_HEIGH -5,
											w			= widget.zone.w,
											flexFlow	= lvgl.FLOW_COLUMN, 
											flexPad	= lvgl.PAD_SMALL ,
											scrollBar= true, scrollDir = lvgl.SCROLL_VER,
											-- visible	=	(
																-- function()
																	-- return not detailsVisible;
																-- end
															-- ) ,											
											children =  logButtons
										}
										,
										{	type		= "box" ,
											h			= widget.zone.h - PAGE_HEAD_HEIGH -5 ,
											scrollBar = false,
											align		= CENTER,
											visible	=	(
																function()
																	-- app.d.log( "detailsVisible" , detailsVisible , "logViewPage()" )
																	return detailsVisible;
																end
															) ,											
											children =  {	detailBox	}
										}
															
					}
				}
			}	
	
	ui = widget.pageHead( PAGE_LOG_VIEW, uit ,widget, options )
	
	return ui
end


function widget.switchPage(id, widget, options)

	-- app.d.log( "switchPage() id:", id , "widget.switchPage(id)" )	
	
	lvgl.clear()

	if ( id == PAGE_BATSELECT ) then
	
		if	flyData.quickSelChannel == 0 then
			widget.selectPage(widget, options)
		else
			id = PAGE_BEHAVIOR
		end
		
	end
	
	if (id == PAGE_SETINPUT ) then 

		widget.setInputPage(widget, options)
		
	elseif (id == PAGE_BEHAVIOR ) then

		widget.behaviorPage(widget, options)
		
	elseif (id == PAGE_LOG_VIEW ) then

		widget.logViewPage(widget, options)
		
	else
		print("unknown PAGE id:", id)

	end

	widget.activePage = id
	 
   --saveSettings();
end

--######################################################################

function widget.widgetPage( widget, options )
	lvgl.clear();

	-- app.d.log( "options.Display" , options.Display , "widget.widgetPage()" )
	

	if options.Display == 1 then					-- Battery Name
		dispBatteryID( widget )

	elseif options.Display == 2 then				--	Battery properties (Product, Capacity)
		dispProdCapa( widget )
		
	elseif options.Display == 3 then				--	Battery status ( Battery Percent )
		dispBatteryPercent( widget )	

	elseif options.Display == 4 then				--	Flight Count (Start Count)
		dispStartCount( widget )		
		
	elseif options.Display == 5 then				--	Fly Time
		dispFlyTime( widget )

	elseif options.Display == 6 then				--	Landing target	%
		dispLandingTarget( widget )

	elseif options.Display == 7 then				--	Last Used
		dispLastUseDateTime( widget )

	elseif options.Display == 8 then				--	Peak current (MAX Amp)
		dispMaxAmp( widget )		
		
	elseif options.Display == 9 then				--	Quick Selector
		dispQuickSelect( widget )		
		
	elseif options.Display == 10 then				--	Remaining charge (mAh Percent)
		dispMahPercent( widget )		

	end	
	
end

loadScript( app.dir .. "wdraw.lua" )( dt, app, flyData ) 

return widget