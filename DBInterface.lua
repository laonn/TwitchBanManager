local ffi = require("ffi")
ffi.cdef[[
    int printf(const char* fmt, ...);
]]

-- should move variable
FILE_TABLE = {}
FILE_NAME = "UserData.lua"
FILE_TABLE_NAME = "UserData"
--

-- DataFile Handle Function
function CreateNewDataFile(tableString)
	local file = assert(io.open(FILE_NAME, "w"))

    file:write(FILE_TABLE_NAME .. " =\n")
    file:write(tableString)
    file:close()
end

function ConvertTableToString(node)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    return output_str
end

function LoadData()
    dofile(FILE_NAME)
    local f = assert(loadstring("FILE_TABLE = " .. FILE_TABLE_NAME))
    f()
end

function InsertData(data)
    local dataString = ConvertTableToString(data)
    local file = assert(io.open(FILE_NAME, "a+"))

    table.insert(FILE_TABLE, #FILE_TABLE + 1, data)
    file:write("table.insert(" .. FILE_TABLE_NAME .. ", #" .. FILE_TABLE_NAME .. " + 1, " .. dataString .. ")\n")
    file:close()
end

function RemoveData(pos)
    local file = assert(io.open(FILE_NAME, "a+"))

    table.remove(FILE_TABLE, pos)
    file:write("table.remove(" .. FILE_TABLE_NAME .. ", " .. pos .. ")\n")
    file:close()
end

function CleanUpDataFile()
    CreateNewDataFile(ConvertTableToString(FILE_TABLE))
end
--

-- Data Handle Function
function CreateData(name, date)
    return {["Name"] = name, ["Date"] = date}
end
--

-- GUI
function ShowData()
    for i, t in ipairs(FILE_TABLE) do
        io.write(i .. ".")
        for k, v in pairs(t) do
            io.write(k .. ":" .. v .. "  ")
        end
        io.write("\n")
    end
end
--

--main
LoadData()

ShowData()

-- example
-- InsertData(CreateData("NAME", "DATE"))
-- RemoveData(FILE_TABLE, 2)
-- CleanUpDataFile()

print(FILE_TABLE[3].Date)
--