--[[#######################################################################
##  csvfile.lua - Read/Write/Update csv format file                      ##
##                                                                       ##
## Author:  BeGab                                                        ##
## Date:    2024-07-20                                                   ##
## Version: 0.6.0                                                        ##
## URL : https://github.com/Be-Gab/BattUse                               ##
##                                                                       ##
##                      Copyright (C) "BeGab"                            ##
##                                                                       ##
###########################################################################
## License GNU General Public License v3.0                               ##
#########################################################################]]
local app_ver = "0.6"
local fileRW = {}

local string_gsub = string.gsub 
local string_gmatch = string.gmatch 
local _tostring = tostring

local fileName 			-- readed csv filename (full path)
local fileLines = {} 	-- readed csv file records
local LF = "\n"  			-- LineFeed
local fieldNames = {}	-- fieldnames in indexed table
local fieldPos = {}		-- fieldnames in associated table

local fieldType = {}		-- field types, string or numeric 
local NUMERIC = 1
local STRING  = 2

--#########################################################################--

function fileRW.version()
	return app_ver
end 

function fileRW.log(s)
--  return;
  print("BattUse: fileRW : " .. s)
end

-- 0 - numeric, 1 - string
function fileRW.setFieldDataType( fieldPs, fieldTy )
	-- fileRW.log("Ps, Ty : " .. fieldPs .. ", " .. fieldTy )
	fieldType[ fieldPs ] = fieldTy
end

function fileRW.readCsv(readFileName)
	local itemID = 0
	local buffer

	fileName = readFileName

	-- fileRW.log( fileName )
	
	-- Ha nem létezik a file
	if fstat( fileName ) == nil then
		print("fileRW.readCSV Error: File Open Error! File not exist? (" .. fileName .. ")" )
		return nil
   end
	
	-- fileRW.log( "fileName:" ..fileName )
	
   local file = io.open(fileName, "r")

	if file == nil then
		 fileRW.log("Hiba a fájl megnyitásakor : " .. fileName )
		 return nil
	end

	buffer = io.read(file, 2048 * 32)  

	-- Process lines
	fileLines = {}
   for line in string.gmatch(buffer, "(.-)\n") do  
		
		-- Read Heading
		if itemID == 0  then
		
			local cnt = 1

			for   val in string_gmatch( line.."," , "([^,]*)," ) do
				fieldNames[cnt] = val
				fieldPos[ val ] = cnt
				-- fileRW.log( "Head: " .. cnt .. " : " .. val .. " => "  .. fieldNames[cnt] .. " #: " .. #fieldNames )
				cnt = cnt + 1
			end
		 
			itemID = 1
			
		else
			
			-- Read DataLines
			-- fileRW.log( "itemId: " .. itemID )
			 
			local cnt = 1
			local fields = {}
			
			for v in string.gmatch( line.."," , "([^,]*)," ) do
			
				val = string.gsub(   v , '^["]', '')
				val = string.gsub( val , '["]$', '')

				-- fileRW.log( "readCsv :: Line/field A: " .. itemID .. "/" .. cnt .. ":" .. v  .. "<>" .. val )

				if itemID == 1 and fieldType[ cnt ] == nil then
					if val ~= v then
						fieldType[ cnt ] = STRING
					else
						fieldType[ cnt ] = NUMERIC
					end
				end
				
				-- if val == nil then
					-- print( "fileRW.readCsv: Not numeric! (field:" , fieldNames[cnt]  , " value: [" , v , "] )" )
				-- end 
				
				if fieldType[ cnt ] == NUMERIC then
					val = tonumber( val )
				end		
			
				fields[ fieldNames[cnt] ] = val
				-- fileRW.log( "Line/field B: " .. itemID .. "/" .. cnt .. " : " .. fieldNames[cnt] .. " => "  .. tostring( val ) .. "/" .. v )
				
				cnt = cnt + 1
			end

			fileLines[ itemID ] = fields

			itemID = itemID + 1
			
		end
		 
   end  
	
   io.close(file) 	
	
	return fileLines 
end

-- write the [saveFileName] csv file. Have to define with full path
-- if missing, overwrite the readed file
function fileRW.writeCsv( saveFileName )
	local file, saveFN
	local tableData
	
	if saveFileName == nil then
		saveFN = fileName
	else
		saveFN = saveFileName
	end


	-- fileRW.log( "WriteCSV : Before - txtTableData" )

	-- Create before write, if error occure, the file is unhurt
	tableData = fileRW.txtTableData()
	
	file = io.open(saveFN, "w")	

	-- fileRW.log( "WriteCSV : " .. saveFN )
	if not file then
		print("fileRW.writeCSV Error: File Open Error! (" .. saveFN .. ")" )
		return false
	end
	
	io.write( file, tableData )

   io.close( file )
	
	return true
	 
end

-- get copy(!) of the full csv file
function fileRW.getTable()
	local retTbl = {}
	local rowTable = {}
	
	for key , row in ipairs(fileLines) do

		-- fileRW.log( "GetTable sor k:" .. key .. " row : " .. #row )
	
		rowTable = {}
		
		-- getFields order by heads order ::  KIvenni a mezők értékeit a fejléc sorrendjében
		for k , v in ipairs(fieldNames) do
			rowTable[v] = row[ v ]
			-- fileRW.log( row[ v ] .. " k:" .. k .. " #rowT:" .. #rowTable )
		end
		
		retTbl[ key ] = rowTable;

		-- txtData = txtData .. table.concat( rowTable , ";" ) .. LF
		-- fileRW.log( txtData )
		
	end
	
	return retTbl
end

-- get record id (record number) by field name and value
function fileRW.getRowIdByField( fieldName, value )
	local rowID
	local lExists , fieldPos = fileRW.isFieldExists( fieldName )
	
	
	if not lExists then
		return nil
	end
	
	for key , row in ipairs(fileLines) do
		if row[ fieldName ] == value then
			return key
		end
	end
	
	return nil
end

-- get record copy(!), in an associated table
function fileRW.getRow( rowID )
	local tRow = {}
	local ertek
	
	if fileLines[ rowID ] == nil then
		print("fileRW.getROW Error: ID not exist! (" .. rowID .. ")" )
		return false
	end
	
	-- KIvenni a mezők értékeit a fejléc sorrendjében
	-- get fields order by original head order
	for k , v in ipairs(fieldNames) do
		tRow[ v ] = fileLines[ rowID ][ v ]
	end
	
	return tRow
end

-- update full record with fields in [newRow]
function fileRW.updateRow( rowID , newRow )

	if fileLines[ rowID ] == nil then
		print("fileRW.updateROW Error: ID not exist! (" .. rowID .. ")" )
		return false
	else

		-- csak a newRow ban érkezett mezőket frissíteni, ha van olyan mező...
		for k , v in pairs(newRow) do
			fileRW.setField( rowID, k, v )
		end
		
	end
		
	return true
end

-- Csak azok a mezők kerülnek be, amik szerepelnek a fejlécben
-- create new record filled with fields in [newRow] (can't create new field )
function fileRW.addRow( newRow )
	local newRowID = #fileLines + 1 
	
	fileLines[ newRowID ] = {}
	
	-- Kivenni a mezőket az új sorból
	for k , v in pairs( newRow ) do
	
		-- Ellenőrizni van e ilyen mező név
		if fileRW.isFieldExists( k ) == nil then
			print("fileRW.addROW Error: field not exist! (" .. k .. ")" )
		else
			fileLines[ newRowID ][ k ] = v 
		end
		
	end	
	
	return true
end

-- delete the record, result the deleted record.
function fileRW.delRow( rowID )

	if fileLines[ rowID ] == nil then
		print( "fileRW.delRow::Record Not Exist! (" .. rowID .. ")" )
		return false
	else
		return table.remove( fileLines, rowID );
	end
		
end

-- delete all record without heading 
function fileRW.clearData()

	fileLines	= {}

end

-- get fields value of the specified record in [rowID] 
function fileRW.getField( rowID, fieldName )

	if fileLines[ rowID ] == nil then
		fileRW.log( "getField::Record Not Exist :" .. rowID .. "/" .. fieldName )
		return false
	
	elseif fileRW.isFieldExists( fieldName ) then
		return fileLines[ rowID ][fieldName]
		
	else
		fileRW.log( "getField : Field Not Exist :" .. rowID .. "/" .. fieldName )
		return false
	end

end

-- set field with value of the specified record in [rowID] 
function fileRW.setField( rowID, fieldName, value )
	
	if fileLines[ rowID ] == nil then
	
		fileRW.log( "setField::Record Not Exist :" .. rowID .. "/" .. fieldName )
		return false
		
	elseif fileRW.isFieldExists( fieldName ) then
	
		fileLines[ rowID ][ fieldName ] = value
		return true
		
	else
	
		fileRW.log( "setField::Field Not Exist :" .. rowID .. "/" .. fieldName )
		return false
		
	end
			
end

-- checking field exist?
function fileRW.isFieldExists( fieldName )

	if fieldPos[ fieldName ] == nil then
	
		for k,v in pairs( fieldPos ) do
			if fieldName ~= k then
				if fieldName == v then
					stat = "==" 
				else
					stat = " Not ==" 
				end
				fileRW.log( "isFieldExists() NotExists: " .. v .. "=" .. k .. "?=" .. fieldName .. ":" .. stat )
			end
		end
		
		return false, 0
	else
		return true, fieldPos[ fieldName ]
	end

end

-- return the full csv file in one string
function fileRW.txtTableData()
	local txtData 
	local rowVal
	
	-- Head
	-- fileRW.log( table.concat(fieldNames, ";") )
	
	txtData = table.concat(fieldNames, ",")   .. LF
	
	-- Data	
	for key , row in ipairs(fileLines) do

		-- fileRW.log( " sor k:" .. key .. " row : " .. #row )
		-- fileRW.log( "fileRW.txtTableData, Rec:" .. key .. " #row : " .. #row )


		local rowTable = {}
		
		-- KIvenni a mezők értékeit a fejléc sorrendjében
		for k , v in ipairs(fieldNames) do

			-- fileRW.log( "fileRW.txtTableData, Fields k:" .. k .. " row : " .. v )


			if v == nil or row[ v ] == nil then	-- Field exists but do not have value
				rowVal = ""
			else					
				rowVal = row[ v ]
			end	

			-- fileRW.log( "rowVal:" .. rowVal )

		
			if fieldType[ k ] == STRING then
				rowVal = "\"" .. rowVal .. "\""
			else
				rowVal = tonumber( rowVal )
				if rowVal == nil then
					print( "fileRW.txtTableData: Not numeric! (" , k  , "/" , v , ")" )
					-- Not numeric!
					rowVal = ""
				end
			end

			rowTable[k] = rowVal
			-- jó ::fileRW.log( row[ v ] .. " k:" .. k .. " #rowT:" .. #rowTable )
			
		end

		txtData = txtData .. table.concat( rowTable , "," ) .. LF
		
	end

	return txtData
end 

-- print full csv file to debug
function fileRW.logTableData()
	local slines, line
	local cnt = 0
	
	-- The Debug window unable to process linefeeds
	slines = fileRW.txtTableData()
	
   for line in string.gmatch(slines, "([^\n]+)\n") do  
		print( "fileRW :: [Line " .. cnt .. "]" .. line )
		cnt = cnt + 1
	end

end	

return fileRW