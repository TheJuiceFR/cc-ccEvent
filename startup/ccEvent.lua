

local handlerList = {}

for _,f in pairs(fs.list("/evt")) do
	local file = require("/evt/"..string.gsub(f,".lua$",""))
	
	for k,v in pairs(file) do
		if not handlerList[k] then handlerList[k] = {} end
		table.insert(handlerList[k],v)
	end
end

--Stash away the old functions to add our own
if not _ccevent then
	_G._ccevent = {PE = os.pullEvent, PER = os.pullEventRaw}
end

local function pullEventEither(filter,raw)
	while true do
		local eventTable
		if raw then
			eventTable = {_ccevent.PER()}
		else
			eventTable = {_ccevent.PE()}
		end
		
		local mask = false
		repeat
			local caught = false
			if handlerList[eventTable[1]] then
				
				local outputTable
				for _,handler in pairs(handlerList[eventTable[1]]) do
					local resultTable = {handler(table.unpack(eventTable))}
					
					if resultTable[1] == true then
						-- Mask this event
						caught = true
						mask = true
					elseif not resultTable[1] then
						-- Not handled by this handler
					else
						caught = true
						outputTable = resultTable
					end
				end
				if outputTable then eventTable = outputTable end
				
			end
		until (not caught) or mask
		
		if not mask and (not filter or eventTable[1] == filter) then
			return table.unpack(eventTable)
		end
		
	end
end

function os.pullEvent(filter)
	return pullEventEither(filter, false)
end

function os.pullEventRaw(filter)
	return pullEventEither(filter, true)
end

