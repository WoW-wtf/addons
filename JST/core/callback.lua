local T, C, L, G = unpack(select(2, ...))

----------------------------------------------------------
---------------[[        Callbacks        ]]--------------
----------------------------------------------------------

do
	local callbacks = {}

	function fireEvent(event, ...)
		if not callbacks[event] then return end
		for _, v in ipairs(callbacks[event]) do
		    securecall(v, event, ...)
		end
	end

	T.FireEvent = function(event, ...)
		fireEvent(event, ...)
	end

	T.IsCallbackRegistered = function (event, f)
		if not event or type(f) ~= "function" then
			error("Usage: IsCallbackRegistered(event, callbackFunc)", 2)
		end
		if not callbacks[event] then return end
		for i = 1, #callbacks[event] do
			if callbacks[event][i] == f then return true end
		end
		return false
	end

	T.RegisterCallback = function(event, f)
		if not event or type(f) ~= "function" then
			error("Usage: T.RegisterCallback(event, callbackFunc)", 2)
		end
		callbacks[event] = callbacks[event] or {}
		tinsert(callbacks[event], f)
		return #callbacks[event]
	end

	T.UnregisterCallback = function(event, f)
		if not event or not callbacks[event] then return end
		if f then
			if type(f) ~= "function" then
				error("Usage: T.UnregisterCallback(event, callbackFunc)", 2)
			end
			--> checking from the end to start and not stoping after found one result in case of a func being twice registered.
			for i = #callbacks[event], 1, -1 do
				if callbacks[event][i] == f then
					tremove(callbacks[event], i)
				end
			end
		else
			error("Usage: T.UnregisterCallback(event, callbackFunc)", 2)
		end
	end
end

----------------------------------------------------------
-----------------[[    BW Callback    ]]------------------
----------------------------------------------------------

local bw_bars = {}
local bw_nextExpire -- time of next expiring timer

local function bw_recheckTimers()
	local now = GetTime()
	bw_nextExpire = nil
	
	for text, bar in pairs(bw_bars) do
		if bar.expirationTime < now then
			bw_bars[text] = nil
		elseif bw_nextExpire == nil then
			bw_nextExpire = bar.expirationTime
		elseif bar.expirationTime < bw_nextExpire then
			bw_nextExpire = bar.expirationTime
		end
	end
	
	if bw_nextExpire then
		C_Timer.After(bw_nextExpire - now, bw_recheckTimers)
	end
end
	
local BigwigsCallback = function(event, ...)
	if event == "BigWigs_Message" then
		local addon, key, text, color, tex = ...
		if not key then return end

		T.FireEvent("BW_MSG", key, text, color, tex)
		
   elseif event=="BigWigs_StartBar" then
        local addon, key, text, duration = ...
		if not key then return end
		
		local ID = gsub(key, "%((%d+)%)", "")
		local spellID = tonumber(ID)
		if not spellID then return end
		
		local now = GetTime()
		local expirationTime = now + duration
		
		if not bw_bars[text] then
			bw_bars[text] = {}
		end
		
		local bar = bw_bars[text]
		bar.addon = addon
		bar.spellID = spellID
		bar.expirationTime = expirationTime
		
		T.FireEvent("BW_TIMER_START", spellID, text, expirationTime, duration)
		
		if bw_nextExpire == nil or expirationTime < bw_nextExpire then
			C_Timer.After(duration, bw_recheckTimers)
			bw_nextExpire = expirationTime
		end
	
    elseif event == "BigWigs_StopBar" then
        local addon, text = ...
		local bar = bw_bars[text]
        if bar then
			T.FireEvent("BW_TIMER_STOP", bar.spellID, text)			
			bw_bars[text] = nil					
		end
		
    elseif (event == "BigWigs_StopBars" or event == "BigWigs_OnBossDisable" or event == "BigWigs_OnPluginDisable") then
        local addon = ...	
		for text, bar in pairs(bw_bars) do
			if bar.addon == addon then			
				T.FireEvent("BW_TIMER_STOP", bar.spellID, text)
				bw_bars[text] = nil				
			end
		end
    end
end

if BigWigsLoader then
    BWCallbackObj = {}
	BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_Message", BigwigsCallback)
    BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_StartBar", BigwigsCallback)
    BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_StopBar", BigwigsCallback)
    BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_StopBars", BigwigsCallback)
    BigWigsLoader.RegisterMessage(BWCallbackObj, "BigWigs_OnBossDisable", BigwigsCallback)
end

----------------------------------------------------------
-----------------[[    DBM Callback    ]]-----------------
----------------------------------------------------------
local dbm_bars = {}
local dbm_nextExpire -- time of next expiring timer

local function dbm_recheckTimers()
	local now = GetTime()
	dbm_nextExpire = nil
	
	for text, bar in pairs(dbm_bars) do
		if bar.expirationTime < now then
			dbm_bars[text] = nil
		elseif dbm_nextExpire == nil then
			dbm_nextExpire = bar.expirationTime
		elseif bar.expirationTime < dbm_nextExpire then
			dbm_nextExpire = bar.expirationTime
		end
	end
	
	if dbm_nextExpire then
		C_Timer.After(dbm_nextExpire - now, dbm_recheckTimers)
	end
end

local DBMCallback = function(event, ...)
	if event== "DBM_TimerStart" then
		local tag, text, duration = ...
		local id = tag:match('%d+')
		if not id then return end
		
		local spellID = tonumber(id)
		local now = GetTime()
		local expirationTime = now + duration
		
		if not dbm_bars[text] then
			dbm_bars[text] = {}
		end
		
		local bar = dbm_bars[text]
		bar.spellID = spellID
		bar.expirationTime = expirationTime
		
		T.FireEvent("DBM_TIMER_START", spellID, text, expirationTime, duration)
		
		if dbm_nextExpire == nil or expirationTime < dbm_nextExpire then
			C_Timer.After(duration, dbm_recheckTimers)
			dbm_nextExpire = expirationTime
		end
				
    elseif event=="DBM_TimerUpdate" then
		local tag, passed, new_dur = ...
		local id = tag:match('%d+')
		if not id then return end
		
		local spellID = tonumber(id)
		local now = GetTime()
		local new_exp = now + (new_dur - passed)
		
		for text, bar in pairs(dbm_bars) do
			if bar.spellID == spellID then
				T.FireEvent("DBM_TIMER_START", spellID, text, new_exp, new_dur)
			end
		end
    elseif event=="DBM_TimerStop" then
		local tag = ...
		local id = tag:match('%d+')
		if not id then return end
		
		local spellID = tonumber(id)
		
        for text, bar in pairs(dbm_bars) do
			if bar.spellID == spellID then
				T.FireEvent("DBM_TIMER_STOP", bar.spellID, text)
				dbm_bars[text] = nil	
			end
		end		
    end
end

if DBM and DBM.Bars then
    hooksecurefunc(DBM.Bars, "CancelBar", function(self, tag)
		local id = tag:match('%d+')
		if not id then return end
		
		local spellID = tonumber(id)
		for text, bar in pairs(dbm_bars) do
			if bar.spellID == spellID then
				T.FireEvent("DBM_TIMER_STOP", bar.spellID, text)
				dbm_bars[text] = nil
			end
		end
    end)
end

if DBM then
    DBM:RegisterCallback("DBM_TimerStart", DBMCallback)
	DBM:RegisterCallback("DBM_TimerUpdate", DBMCallback)
	DBM:RegisterCallback("DBM_TimerStop", DBMCallback)
end

----------------------------------------------------------
----------------------[[    API    ]]---------------------
----------------------------------------------------------

local CallbackEvents = {
	["BW_MSG"] = true,
	["BW_TIMER_START"] = true,
	["BW_TIMER_STOP"] = true,
	["DBM_TIMER_START"] = true,
	["DBM_TIMER_STOP"] = true,
	["TIMELINE_PASSED"] = true,
	["ENCOUNTER_PHASE"] = true,
	["ADDON_MSG"] = true,
	["SPELLS_CHANGED_DELAY"] = true,
	["JST_SPELL_ASSIGN"] = true,
}

T.RegisterEventAndCallbacks = function(frame, events)
	if events then
		for event, units in pairs(events) do
			if CallbackEvents[event] then
				if not frame.OnEventAndCallback then
					local func = frame:GetScript("OnEvent")
					frame.OnEventAndCallback = function(...)
						func(frame, ...)
					end
				end
				if not frame.CallbackRegisted then
					frame.CallbackRegisted = {}
				end
				if not frame.CallbackRegisted[event] then
					T.RegisterCallback(event, frame.OnEventAndCallback)
					frame.CallbackRegisted[event] = true
				end
			else
				if type(units) == "table" then
					frame:RegisterUnitEvent(event, unpack(units))
				else
					frame:RegisterEvent(event)
				end
			end
		end
	end
end

T.UnregisterEventAndCallbacks = function(frame, events)
	if events then
		for event in pairs(events) do
			if CallbackEvents[event] then
				if frame.OnEventAndCallback and frame.CallbackRegisted and frame.CallbackRegisted[event] then
					T.UnregisterCallback(event, frame.OnEventAndCallback)
					frame.CallbackRegisted[event] = nil
				end
			else
				frame:UnregisterEvent(event)
			end
		end
	end
end

----------------------------------------------------------
--------------------[[    Events    ]]--------------------
----------------------------------------------------------

local eventframe = CreateFrame("Frame", nil, UIParent)

eventframe:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, message, channel, sender = ...
		if prefix == "jstpaopao" then
			T.FireEvent("ADDON_MSG", channel, sender, string.split(",", message))
		end
	end
end)

eventframe:RegisterEvent("CHAT_MSG_ADDON")