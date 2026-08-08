--[[#######################################################################
##  wdraw.lua                                                            ##
##                BattUse - BattUseDisplay functions                     ##
##                                                                       ##
## Author: BeGab                                                         ##
## URL   : https://github.com/Be-Gab/BattUse                             ##
##                                                                       ##
##                      Copyright (C) "BeGab"                            ##
##                                                                       ##
###########################################################################
## License GNU General Public License v3.0                               ##
#########################################################################]]
local dt, app, flyData = ...

local PERCENT_LINE_GREEN	= 60	-- Percent line in the widget is Green until this percent.
local PERCENT_LINE_RED		= 90	-- Percent line in the widget is Red from this percent.
											-- Between this two the color is ORANGE

function dispBatteryID( widget )
	
	-- app.d.log( ".id = " , flyData.batteryRec.id , "dispBatteryID()" )
	-- flyData.fontSize( widget.zone.h ) ,
	 
   widget.ui = lvgl.build({
		{	type	= "box", 
			w		= widget.zone.w ,
			h		= widget.zone.h ,
			align		= CENTER, 
			children = {
				{	type		= "box", 
					align		= CENTER, 
					children = {
							{	type	= "label", 
								w		= widget.zone.w , 
								align	= LEFT, 
								font	= SMLSIZE,
								text	=	function(s)
												local lbl = "";
												if flyData.batteryRec.id or flyData.saved.isSaved then;
													lbl = "Battery ID";
												end;
												return lbl;
											end	
							}	
					}
				} 
				,
				{	type		= "box", 
						y	=	0, 
						h	=	widget.zone.h,
						children = {
							{	type	= "label", 
								w		= widget.zone.w , 
								align	= CENTER + VCENTER, 
								font	= MIDSIZE,
								text	=	function(s)
												if flyData.saved.isSaved then;
													batId = flyData.saved.batteryID;
												else;
													batId = flyData.batteryRec.id or "Select Battery!" ;
												end;
												return batId ;
											end	
							}
					}		
				}
			}

		}
	});

end

function dispProdCapa( widget )
	local WZW = math.floor( widget.zone.w  / 2) * 2		-- Párosszámra lefelé kerekítve.
	local f = 0
	
	if widget.zone.h / 2 < ( 22 * lvgl.LCD_SCALE ) then
		f = SMLSIZE
	end	
	-- d.log( "widget.zone.w = " ,widget.zone.w, "dispProdCapa()" )
	-- d.printAssoc( "dispProdCapa" , widget.zone, 1 )
	 
    widget.ui = lvgl.build({
        {	type = "box", 
				flexFlow = lvgl.FLOW_COLUMN , 
				flexPad	= 0,
				w			= WZW , 
				align = CENTER,
				children = {
					{	type = "box", 
						w = WZW - 2, 
						flexFlow = lvgl.FLOW_ROW , 
						flexPad	= 0,
						children = {
							{	type = "label", 
								w = ( WZW -2 ) / 2 , 
								align = LEFT, 
								font	= f,
								text	=	function(s)        
												if flyData.saved.isSaved then;
													s = flyData.saved.batteryProduct or "-";
												else
													s = flyData.batteryRec.product or "-";
												end;												
												return s;
											end	
							} 
							,
							{	type = "label", 
								align = RIGHT, 
								font	= f,
								w		= ( WZW -2 ) / 2 , 
								text	=	function(s)        
												if flyData.saved.isSaved then;
													s = flyData.saved.batCell or "-";
												else
													s = flyData.batteryRec.cells or "-";
												end;												
												return s .. "S" ;
											end	
							}
						}
					}
					,
					{	type = "box", 
						flexFlow = lvgl.FLOW_ROW , 
						flexPad	= 0,
						w			= WZW - 2, 
						children = {
							{	type	= "label", 
								w		= ( WZW -2 ) / 2 , 
								font	= f,
								align = LEFT, 
								text	=	function(s)        
												if flyData.saved.isSaved then;
													s = flyData.saved.batCapcity or "-";
												else;
													s = flyData.batteryRec.capacity or "-";
												end;

												return s .. " mAh" ;
											end	
							} 
							,
							{	type	= "label", 
								w		= ( WZW -2 ) / 2 , 
								font	= f,
								align = RIGHT, 
								text	=	function(s)        
												if flyData.saved.isSaved then;
													s = flyData.saved.batMaxVolt or "";
												else;
													s = flyData.batteryRec.maxVolt or "";
												end;
												
												return s .. "V/cell" ;
											end	
							}
						}
					}
				}
			}
		});


end

function dispLastUseDateTime( widget )
	local dtColor = 0

	-- app.d.log( "dispLastUseDateTime" , "Run!" , "dispLastUseDateTime()" )

	if flyData.saved.batLastFlightIsToday then
		dtColor = RED
	end
	
   widget.ui = lvgl.build({
		{	type		= "box", 
			flexFlow	= lvgl.FLOW_COLUMN,
			align		= CENTER, 
			children = {
				{	type	= "label", 
					w		= widget.zone.w , 
					align	= LEFT, 
					font	= SMLSIZE,
					text	= "Last use" 					
				}	,
				{	type	= "label", 
					w		= widget.zone.w , 
					align = CENTER, 
					font	=  MIDSIZE, --0,
					color =	function()
									local dtColor = COLOR_THEME_SECONDARY1;
									if not flyData.saved.isSaved and flyData.usedIsToday then;
										dtColor = RED;
									end;
									return dtColor;
								end ,
					text =	function()
									if flyData.saved.isSaved then;
											s = flyData.saved.batLastFlightFormated;
									else;
										if flyData.batteryRec.id ~= nil and flyData.batteryRec.lastStartDate > "" then;
											s = dt.getDateTime( flyData.batteryRec.lastStartDate , ( 10 + dt.getFormat() ) );
										else;
											s = "-";
										end;
									end;
									return s;
								end	
				}
			}

		}
	});

end

function dispStartCount( widget )

   widget.ui = lvgl.build({
		{	type	= "box", 
			w		= widget.zone.w ,
			h		= widget.zone.h ,
			align	= CENTER, 
			children = {
				{	type	= "box", 
					align	= CENTER, 
					children= {
						{	type	= "label", 
							w		= widget.zone.w , 
							align	= LEFT, 
							w		= 70 * lvgl.LCD_SCALE,
							font	= SMLSIZE,
							text	= "Battery flight count"	
						}	
					}
				} 
				,
				{	type	= "box", 
					y		=	0, 
					h		=	widget.zone.h,
					children = {
						{	type	= "label", 
							w		= widget.zone.w , 
							align	= CENTER + VCENTER, 
							font	= flyData.fontSize( widget.zone.h ) ,
							text	=	function()
											local s ="";
											if flyData.saved.isSaved then;
												s = flyData.saved.batFlightCount;
											else;
												if flyData.batteryRec.id ~= nil then;
													s = flyData.batteryRec.count;
												else;
													s = "-";
												end;
											end;
											return s;
										end	
						}
					}		
				}
			}

		}
	});

end

function dispFlyTime( widget )
	local ROUND = 8
	local BORDER_WIDTH = 3  * lvgl.LCD_SCALE
	local BOX_WIDTH = math.min( widget.zone.w , ( 180 * lvgl.LCD_SCALE ) )
	local FontSize = 0

	local box_h = widget.zone.h - BORDER_WIDTH

	FontSize = flyData.fontSize( box_h )
	
	local disp =	{	type		= "box",
							flexFlow	= FLOW_COLUMN,
							align		= CENTER,
							children	= {
									-- ===== Shadow =====
								{	type	= "rectangle",
									w		= BOX_WIDTH,
									h		= box_h,	-- 50,
									x		= (widget.zone.w - BOX_WIDTH ) / 2 + BORDER_WIDTH,
									y		= BORDER_WIDTH,
									rounded	= ROUND, -- 8,
									filled	= true ,
									color		= GREY ,
									opacity	= 125
								}
								,	-- ===== Border =====
								{	type	= "rectangle",
									w		= BOX_WIDTH,
									h		= box_h,	--50,
									x		= (widget.zone.w - BOX_WIDTH) / 2,
									rounded	= ROUND, --8,
									filled	= false,
									thickness= BORDER_WIDTH, -- 3,
									color		= BLACK,
									children = {
										{  type	= "rectangle",
										-- ===== Background ===== --
											h		= box_h - BORDER_WIDTH - BORDER_WIDTH,	--44,
											rounded= ROUND - BORDER_WIDTH , --6,
											filled= true,
											color	= WHITE,
											pad	= PAD_SMALL,
											children = {
													{	type	= "label",
														w		= BOX_WIDTH - BORDER_WIDTH - BORDER_WIDTH; --144,
														align	= CENTER + VCENTER,
														color	= BLACK,
														font	= FontSize,	--DBLSIZE,
														text	=	function()
																		if flyData.saved.isSaved then;
																			return flyData.saved.flightTime;
																		else;
																			local mt = model.getTimer(flyData.timerID);
																			return flyData.formatTime(	math.abs(mt.start - mt.value) );
																		end;
																	end
													}
											  }
										 }
									}
								}
							}
						}



   widget.ui = lvgl.build({ disp })


end

function dispMahPercent( widget )
	-- [Kirepülhető mAh]	[Kirepült mAh]
	-- 		Csík a %-al
	--	[Induló %]	[ Tervezett vége %]

	local WZH 				= widget.zone.h
	local WZW				= widget.zone.w
	local INFO_LINE_INS	= 10 * lvgl.LCD_SCALE
	
	-- app.d.log( "WZH" , WZH , "dispMahPercent()" )
	
	-- WZH = 39
	local INFO_LINE_H		= 15 * lvgl.LCD_SCALE
	local INFO_LINE_FONT	= SMLSIZE
		
	if WZH > 80 then
		INFO_LINE_H		= 20 * lvgl.LCD_SCALE
		INFO_LINE_FONT	= 0 --SMLSIZE
		
	elseif WZH <= 39 then -- Top Main
		INFO_LINE_H		= 0
		INFO_LINE_FONT	= 0 --SMLSIZE

	end
	
	local PERCENT_H		= WZH - INFO_LINE_H - INFO_LINE_H
	local PERCENT_BORDER	= math.floor(  2 * lvgl.LCD_SCALE )
	local PERCENT_FONT	= flyData.fontSize( PERCENT_H )

	local disp =	{	type		= "box",
							align		= CENTER,
							w 			= WZW ,
							h 			= WZH ,
							children	=	{
								-- Head with mAh
								{	type		= "box",
									h	= INFO_LINE_H  ,
									children	=	{
										{	type	= "label",
											-- usable mAh
											w		= ( WZW / 2 ) - INFO_LINE_INS,
											x		= 0 + INFO_LINE_INS,
											h		= INFO_LINE_H ,
											align = LEFT,
											font	= INFO_LINE_FONT , --0, 	-- default
											text	=	function()
															if flyData.saved.isSaved then;
																return ( flyData.saved.mAhUsable or "-" ) .." mAh";
															else;
																return ( flyData.mAhUsable       or "-" ) .. " mAh";
															end;
														end
										}
										,
										{	type	= "label",						-- used mAh
											w 		= ( WZW / 2 ) - INFO_LINE_INS,
											h		= INFO_LINE_H ,
											x 		= WZW / 2,
											align	= RIGHT,
											font	= INFO_LINE_FONT , --0, 	-- default
											text	=	function()
															if flyData.saved.isSaved then;
																return ( flyData.saved.mAhUsed or "-" ) .. " mAh";
															else;
																return ( flyData.mAhUsed or "-" ) .. " mAh";
															end;
														end
										}
									}
								}
								,
								-- Percent line
								{	type		= "box",
									y			= INFO_LINE_H,
									w			= WZW ,
									h			= PERCENT_H ,
									children	=	{
										-- keret
										{	type	= "rectangle",
											thickness = PERCENT_BORDER,
											h		= PERCENT_H ,
											w		= WZW ,
											filled= false,
											color	= BLACK ,
										}
										,																			
										-- kitöltés alap szinnel
										{	type	= "rectangle",
											x		= PERCENT_BORDER,
											y		= PERCENT_BORDER,
											h		= PERCENT_H  - PERCENT_BORDER - PERCENT_BORDER,
											w		= WZW - PERCENT_BORDER - PERCENT_BORDER,
											thickness = 0,
											filled= true,
											color	= WHITE
										}
										,																			
										-- % csík
										{	type	= "rectangle",
											x		= PERCENT_BORDER,
											y		= PERCENT_BORDER,
											thickness = 0,
											filled= true,
											color =	function()
															local p = 0;
															
															if flyData.saved.isSaved then;
																if flyData.saved.mAhUsable and flyData.saved.mAhUsed then;
																	p = math.floor( flyData.saved.mAhUsed / ( flyData.saved.mAhUsable * 0.01 ) );
																end;
															else;
																if flyData.mAhUsable and flyData.mAhUsed then;
																	p = math.floor( flyData.mAhUsed / ( flyData.mAhUsable * 0.01 ) );
																end;
															end;
															
															if p < PERCENT_LINE_GREEN then;
																return GREEN;
															elseif p >= PERCENT_LINE_RED then;
																return RED;
															else;
																return ORANGE;
															end;
															
														end ,
											size	=	function()
															local w = 0;
															if flyData.saved.isSaved then;
																if flyData.saved.mAhUsable and flyData.saved.mAhUsed then;
																	w = math.min( 100, math.floor( flyData.saved.mAhUsed / ( flyData.saved.mAhUsable * 0.01 ) ) ) * 0.01 * ( WZW - PERCENT_BORDER - PERCENT_BORDER );
																end;
															else;
																if flyData.mAhUsable and flyData.mAhUsed then;
																	w = math.min( 100, math.floor( flyData.mAhUsed / ( flyData.mAhUsable * 0.01 ) ) ) * 0.01 * ( WZW - PERCENT_BORDER - PERCENT_BORDER );
																end;
															end;
															return  w , PERCENT_H  - PERCENT_BORDER - PERCENT_BORDER;
														end
										}
									}
								} 
								,
								-- Footer with %
								{	type	= "box",
									y		= PERCENT_H + INFO_LINE_H,
									h		= INFO_LINE_H  ,
									children	=	{
										{	type	= "label",
											w		= ( WZW / 2 ) - INFO_LINE_INS,
											x		= 0 + INFO_LINE_INS,
											h		= INFO_LINE_H ,
											align = LEFT,
											font	= INFO_LINE_FONT , --0, 	-- default
											text	=	function()
															if flyData.saved.isSaved then;
																return ( flyData.saved.batPercentStart  or "-" )    .." %";
															else;
																return ( flyData.batPercentStart or "-" ) .. " %";
															end;
														end;											
										}
										,
										{	type	= "label",
											w 		= ( WZW / 2 ) - INFO_LINE_INS,
											h		= INFO_LINE_H ,
											x 		= WZW / 2,
											align	= RIGHT,
											font	= INFO_LINE_FONT , 
											color =	function()
															if flyData.saved.isSaved and flyData.saved.batPercentEnd < flyData.warningBatOverUse then;
																return RED;
															else;
																return COLOR_THEME_SECONDARY1;
															end;
														end ,
											text	=	function()
															if flyData.saved.isSaved then;
																return flyData.saved.batPercentEnd      .." %";
															else;
																return "- %";
															end;
														end											
										}
									}
								}
								,
								{	type	= "box",			-- %
									y		= 0 , 
									h		= WZH , 
									children =	{
										{	type	= "label",
											w 		= WZW ,
											align	= CENTER + VCENTER,
											font	= PERCENT_FONT , 
											color =	function()
															local p = 0;
															if flyData.saved.isSaved then;
																if flyData.saved.mAhUsable and flyData.saved.mAhUsed then;
																	p = math.floor( flyData.saved.mAhUsed / ( flyData.saved.mAhUsable * 0.01 ) );
																end;
																
															else;
																if flyData.mAhUsable and flyData.mAhUsed then;
																	p = math.floor( flyData.mAhUsed / ( flyData.mAhUsable * 0.01 ) );
																end;
															end;

															if p < PERCENT_LINE_GREEN then;
																return RED;
															-- elseif p > 90 then;
																-- return WHITE;
															else;
																return WHITE;
															end;
														end ,
											text	=	function()
															if flyData.saved.isSaved then;
																if flyData.saved.mAhUsable and flyData.saved.mAhUsed then;
																	return ( math.floor( flyData.saved.mAhUsed / ( flyData.saved.mAhUsable * 0.01 ) ) )  .. "%";
																else
																	return "- %";
																end;

															else;
																if flyData.mAhUsable and flyData.mAhUsed then;
																	return ( math.floor( flyData.mAhUsed / ( flyData.mAhUsable * 0.01 ) ) )  .. "%";
																else
																	return "- %";
																end;
															end;
														end
										}
									}
									
								}
								
							}
	
						}

   widget.ui = lvgl.build({ disp })

end

function dispMaxAmp( widget )
	
   widget.ui = lvgl.build({
		{	type	= "box", 
			w		= widget.zone.w ,
			h		= widget.zone.h ,
			align	= CENTER, 
			children = {
				{	type	= "box", 
					align	= CENTER, 
					children = {
							{	type	= "label", 
								w		= widget.zone.w , 
								align	= LEFT, 
								font	= SMLSIZE,
								text	=	"Max current draw"	
							}	
					}
				} 
				,
				{	type	= "box", 
					y		=	0, 
					h		=	widget.zone.h,
					children = {
						{	type	= "label", 
							w		= widget.zone.w , 
							align	= CENTER + VCENTER, 
							font	= flyData.fontSize( widget.zone.h - ( 11 * lvgl.LCD_SCALE ) ) ,
							text	= 	function(s)
											if flyData.saved.isSaved then;
												a = flyData.saved.maxAmp;
											else;
												a = flyData.maxAmp;
											end;
											return a ;
										end	
						}
					}		
				}
			}

		}
	});
	

end

function dispBatteryPercent( widget )
	local state
	local st = {}
	st.NODATA			= 0
	st.BEFORE_START_LOW_BATTERY	= 1
	st.BEFORE_START	= 2
	st.START				= 3
	st.START_END		= 4
	
	state = st.NODATA
	
	-- app.d.printAssoc( ".zone " , widget.zone , "dispBatteryPercent()" )

	if widget.zone.h >= 40 then	-- 40 !
	
		-- Widget on screen
		
		-- local SHIFT = 16
		-- local BCK_SHIFT = math.min( 4 , ( widget.zone.h - SHIFT ) / 20 )

--[[#######################################################################
 Ami kéne:
	Első felszállás elött (flyData.flightStartTime == nil ) 
	és az aksi csatlakoztatott flyData.batStatus = BATTERY_CONNECTED
	és feszültsége alacsonyabb a settings.getMinBatStartVolt( )
	
		Teljes háttér piros
		Cimke fehér
		Volt sárga
		Százalék Sárga
	 
	Egyébként ( Felszállás után )
	
		Teljes háttér piros
		Cimke fehér
		Volt sárga
		Százalék Sárga

	Egyébként ( Leszállás után )
	 
		Teljes háttér normál
		Cimke fehér
		Volt sárga
		Százalék Sárga
		
-----------------
	Állapotok:
		Start elött
			Aksi nincs összedugva
			Aksi adatokkal
				Alacsony töltöttség
				Normál töltöttség
		Start közben
		Start végén - pillanatnyi, utolsó adat
		
		lehet e egyszer számítani az állapotokat és utána felhasználni az összes elemben??
		LEHET!LEHET!
		
#########################################################################]]		
		
		
	   widget.ui = lvgl.build({
			{	type		=	"rectangle" , 
				align		=	CENTER , 
				thickness=	0 ,
				color		=	COLOR_THEME_WARNING,
				filled	=	function()
									
									if flyData.flightStartTime == nil then

										state = st.BEFORE_START
									
										if  flyData.IsBatteryConnected()  then
											if flyData.getPercent( flyData.batVoltReadSensor() / flyData.getCells() ) < flyData.minBatStartVolt then
												state = st.BEFORE_START_LOW_BATTERY
											end
										end

									elseif flyData.saved.isSaved then -- LEszállUtán
										state = st.START_END
									else			-- repül
										state = st.START
									end
									
									return ( st.BEFORE_START_LOW_BATTERY == state );
									
								end,
				children = {
					{	type		= "box",
						children = {
							{	type	= "label" ,
								w		= widget.zone.w ,
								-- align	= LEFT ,
								font	= SMLSIZE ,
								w		= 60 * lvgl.LCD_SCALE,
								text	=	"Battery Volt" ,
								color	=	function()
												c = COLOR_THEME_PRIMARY3
												if state == st.BEFORE_START_LOW_BATTERY then
													c = WHITE
												end
												return c
											end
							}
							,
							{	type	= "label" , 
								w		= widget.zone.w , 
								align	= RIGHT ,
								font	= 0 ,
								color	=	function()
												local c = COLOR_THEME_SECONDARY3;
												if flyData.IsBatteryConnected() and getFlightMode() == 0 then;
													if flyData.getPercent( flyData.batVoltReadSensor() / flyData.getCells() ) < flyData.minBatStartVolt then;
														c = RED;
													end;
												end;
												return c;
											end ,
								text	=	function()
												local s = "";
												if flyData.IsBatteryConnected() and getFlightMode() == 0 then;
													s = math.floor( flyData.batVoltReadSensor() )  .. " V " 
													if flyData.isHV() then
														s = s .. ", HV"
													end
												end;
												return s .. state;
											end ,
							}
						}
					}
					,
					{	type	= "box", 		-- %
						y		=	0,
						h		=	widget.zone.h,
						children = {
							{	type	= "label", 
								-- y = 16,
								w		= widget.zone.w , 
								font	=  flyData.fontSize( widget.zone.h ) , 
								align	= CENTER, --  + VCENTER, 
								color	=	function()
												local c = COLOR_THEME_SECONDARY3;
												if  state == st.BEFORE_START_LOW_BATTERY then;
													c = COLOR_THEME_WARNING;
												end;
												return c;
											end ,								
								text	=	function()
												local s = "--";
												if flyData.IsBatteryConnected() and getFlightMode() == 0 then;
													s = flyData.getPercent( flyData.batVoltReadSensor() / flyData.getCells() ) .. "%";
												end;
												return s;
											end
							}
						}
					}
				}
			}
		});

	else
	
		-- MAIN position (ON TOP)
		r = ( widget.zone.h - 1 ) / 2
		 
		widget.ui = lvgl.build({
			{	type		= "box", 
				w = widget.zone.w ,
				h = widget.zone.h ,
				align		= CENTER, 
				children = {
						{	type	= "circle", 
							y		= r,
							x		= widget.zone.w / 2,
							radius= r,
							align	= CENTER + VCENTER, 
							filled= true ,
							color	=	function()
											local c = COLOR_THEME_SECONDARY1;
											if flyData.IsBatteryConnected() and getFlightMode() == 0 then;
												if flyData.getPercent( flyData.batVoltReadSensor() / flyData.getCells() ) < flyData.minBatStartVolt then;
													c = RED;
												else;
													c = GREEN;
												end;
											end;
											return c;
										end ,
						}
						,
						{	type	= "label", 
							x		= 0,
							y		= 0,
							-- h 		= widget.zone.h ,
							w		= widget.zone.w , 
							align	= CENTER + VCENTER, 
							font	=  flyData.fontSize( widget.zone.h ), 
							color	=	function()
											local c = COLOR_THEME_PRIMARY1;
											if flyData.IsBatteryConnected() and getFlightMode() == 0 then;
												if flyData.getPercent( flyData.batVoltReadSensor() / flyData.getCells() ) < flyData.minBatStartVolt then;
													c = WHITE;
												else;
													c = BLACK;
												end;
											end;
											return c;
										end ,
							text	=	function()
											local s = "--";
											if flyData.IsBatteryConnected() and getFlightMode() == 0 then;
												s = flyData.getPercent( flyData.batVoltReadSensor() / flyData.getCells() )
											end;
											return s;
										end
						}						

				}
			} 
		});
		
	end
end

function dispQuickSelect( widget )
	local batList = flyData.getBatteryTable()
	local batBox = {}
	local boxW = ( widget.zone.w / #batList ) -2 - ( #batList * 1 )
	local boxH = widget.zone.h - ( 40 * lvgl.LCD_SCALE )
	local chRange = ( 2048 / #batList ) + 1
	local previousQS_ChannelValue = -1
	
	-- app.d.printAssoc( "dispQuickSelect() -> batList" , batList )
	
	
	-- for i = 1, #flyData.batteryRec do
	for i = 1, #batList do
	
		batBox[ #batBox +1 ] = 
						{	type	= "rectangle", 
							w			= boxW ,
							h			= boxH ,
							color		= BLACK ,
							opacity	= 90 ,
							filled	= false ,
							thickness= 2 ,
							children = {
								{	type	= "rectangle" ,
									w		= boxW -4 ,
									h		= boxH -4 ,
									filled= true ,
									color =	function()
													if batList[ i ].id == flyData.batteryRec.id then;
														return GREEN;
													else;
														return WHITE;
													end;
												end
								}
							}
						}
		
	end


   widget.ui = lvgl.build({
			{	type		= "box", 
				flexFlow	= lvgl.FLOW_ROW,
				align		= CENTER, 
				visible	=	function() 
									return ( 0 == flyData.quickSelChannel ); 
								end ,
				children = {
					{	type	= "label", 
						w		= widget.zone.w , 
						align	= CENTER + VCENTER ,
						color	= RED ,
						font	= 0,
						text	= "Quick Select Channel is NOT set!" 					
					}
				}
			}
			,
			{	type		= "box", 
				w			= widget.zone.w ,
				h			= widget.zone.h ,
				visible	=	function() 
									return ( 0 < flyData.quickSelChannel ); 
								end ,
				flexFlow	= lvgl.FLOW_COLUMN ,
				flexPad	= 0 ,
				children = {
					{	type	= "box", 
						align	= LEFT, 
						children = {
								{	type	= "label", 
									w		= widget.zone.w , 
									align	= LEFT, 
									font	= SMLSIZE,
									text	=	function(s)
													local qsValue = 1024 + getValue( flyData.quickSelChannel );
													
													if ( 0 < flyData.quickSelChannel ) and
														previousQS_ChannelValue ~= qsValue then;
														
														previousQS_ChannelValue = qsValue
														
														if not flyData.flightStartTime and 
															not flyData.isQuickSelectLocked() then;
														
															flyData.setQuickSelectUnLock();
	
															local b = math.floor( qsValue / chRange ) + 1;
															local d = batList[ b ].id;
															
															if d ~= flyData.batteryRec.id then;
																flyData.selectBatteryByID( batList[ b ].id );
															end;
															
														end;
														
													end;
													
													return "Quick Select";
												end				
								}	
						}
					} 
					,
					{	type	= "box", 
						w		=	widget.zone.w,
						h		=	widget.zone.h,
						flexFlow	= lvgl.FLOW_ROW ,
						flexPad	= lvgl.PAD_SMALL ,
						children = 	batBox
					}

				}

			}
		});
end

function dispLandingTarget( widget )

   widget.ui = lvgl.build({
		{	type	= "box", 
			w		= widget.zone.w ,
			h		= widget.zone.h ,
			align	= CENTER, 
			children = {
				{	type	= "box", 
					align	= CENTER, 
					children= {
						{	type	= "label", 
							w		= widget.zone.w , 
							align	= LEFT, 
							font	= SMLSIZE,
							w		= 60 * lvgl.LCD_SCALE ,
							text	= "Landing target"	
						}	
					}
				} 
				,
				{	type	= "box", 
					y		=	0, 
					h		=	widget.zone.h,
					children = {
						{	type	= "label", 
							w		= widget.zone.w , 
							align	= CENTER + VCENTER, 
							font	= flyData.fontSize( widget.zone.h - 8 ) ,
							text	=	function()
											return flyData.targetLandingPercent .. "%";
										end	
						}
					}		
				}
			}

		}
	});
	
	
end



function dispError( widget )
	 
   widget.ui = lvgl.build({
		{	type	= "box", 
			w		= widget.zone.w ,
			h		= widget.zone.h ,
			align	= CENTER, 
			children = {
				{	type	= "label", 
					w		= widget.zone.w , 
					align	= CENTER + VCENTER, 
					font	= SMLSIZE,
					color	= COLOR_THEME_WARNING ,
					text	=	"Setup Missing, Go to Input page (Timer, Cells)"					
				}	
			}
		}
	});

end

