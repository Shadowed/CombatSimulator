CombatSim = {}
local setHandler, setFunc

local function fireEvent(...)
	local logData = {...}
	for id, data in pairs(logData) do
		if( tonumber(data) == data ) then
			logData[id] = tonumber(data)
		elseif( string.match(data, [["(.+)"]]) ) then
			logData[id] = string.match(data, [["(.+)"]])
		elseif( data == "nil" ) then
			logData[id] = nil
		end
	end
	
	setHandler[setFunc](setHandler, "COMBAT_LOG_EVENT_UNFILTERED", nil, logData[1], logData[2], logData[3], logData[4], logData[5], logData[6], logData[7], logData[8], logData[9], logData[10], logData[11], logData[12], logData[13], logData[14], logData[15], logData[16], logData[17], logData[18], logData[19], logData[20], logData[21], logData[22], logData[23])
end

local logQueue = {}
local toFire = {}
local frame = CreateFrame("Frame")
frame.startTime = 0
frame:Hide()
frame:SetScript("OnUpdate", function(self, elapsed)
	local time = GetTime()
	self.currentTime = self.currentTime + (time - self.lastUpdate)
	self.lastUpdate = time
	
	for id=#(logQueue), 1, -1 do
		local log = logQueue[id]
		if( log.time <= self.currentTime ) then
			table.insert(toFire, log.line)
			table.remove(logQueue, id)
		end
	end
	
	for i=#(toFire), 1, -1 do
		fireEvent(string.split(",", toFire[i]))
		table.remove(toFire, i)
	end
	
	if( #(logQueue) <= 0 ) then
		self:Hide()
	end
end)

--function Uckfup:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
--5/27 18:59:27.668  SPELL_DAMAGE,0x0500000002CCEE1F,"Eejette",0x8000514,0x05000000024EEDC9,"Kroot",0x511,65120,"Searing Light",0x42,3000,0,66,0,0,0,nil,nil,nil


function CombatSim:Run(handler, func)
	setHandler = handler
	setFunc = func

	for id, log in pairs(CombatSimLog) do
		local date, line = string.match(log, "(.+)  (.+)")
		local hour, minute, seconds = string.match(date, "(%d+):(%d+):(.+)")
		local time = (hour * (60 * 60)) + (minute * 60) + seconds
		
		table.insert(logQueue, {time = time, line = line})

		if( id == 1 ) then
			frame.currentTime = time
		end
	end
	
	frame.lastUpdate = GetTime()
	frame:Show()
end

SLASH_COMBATSIM1 = "/combatsim"
SLAHS_COMBATSIM2 = "/combatsimulator"
SlashCmdList["COMBATSIM"] = function(msg)
	msg = msg or ""
	
	if( msg == "" ) then
		print("/combatsim <handler> <func> - Handler/function combination to send simulated data to.")
		return
	end
	
	local handlerText, func = string.split(" ", msg)
	local handler = getglobal(handlerText)
	
	func = func or "COMBAT_LOG_EVENT_UNFILTERED"
	
	if( not handler ) then
		DEFAULT_CHAT_FRAME:AddMessage(string.format("Cannot find handler %s.", handlerText))
		return
	elseif( not handler[func] ) then
		DEFAULT_CHAT_FRAME:AddMessage(string.format("Cannot find function %s inside handler %s.", func, handlerText))
		return
	end
	
	CombatSim:Run(handler, func)
end
