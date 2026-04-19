

local handlerList = {}

for _,f in pairs(fs.list("/evt")) do
	local file = require("/evt/"..string.gsub(f,".lua$",""))
	
	for k,v in pairs(file) do
		if not handlerList[k] then handlerList[k] = {} end
		table.insert(handlerList[k],v)
	end
end






local function pullEventEither(filter,raw)
	while true do
		local eventTable
		if raw then
			eventTable = {os.pullEventRaw()}
		else
			eventTable = {os.pullEvent()}
		end
		
		local outputTable
		if handlerList[eventTable[1]] then
			for k,v in pairs(handlerList[eventTable[1]]) do
				local resultTable = {v(table.unpack(eventTable))}
				
				if resultTable[1] == true then
					outputTable = {true}
				elseif not resultTable[1] then
					-- Not handled by this handler
				else
					outputTable = resultTable
				end
			end
		end
		
		if not outputTable then
			outputTable = eventTable
		end
		
		if not filter or outputTable[1] == filter then
			return table.unpack(outputTable)
		end
	end
end

local ccEvent = {}

function ccEvent.pullEvent(filter)
	return pullEventEither(filter, false)
end

function ccEvent.pullEventRaw(filter)
	return pullEventEither(filter, true)
end



return ccEvent
