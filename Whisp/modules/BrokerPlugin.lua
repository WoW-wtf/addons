--------------------------------------------------------------------------
-- Credit to Morgalm for initially adapting the Whisp FuBar plugin to LibDataBroker 
--------------------------------------------------------------------------

local mod = Whisp:NewModule("Broker Plugin", "AceEvent-3.0")
local icon = LibStub("LibDBIcon-1.0", true)
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local L = LibStub("AceLocale-3.0"):GetLocale("Whisp")
local QTC = LibStub('LibQTip-1.0')
local version = C_AddOns.GetAddOnMetadata("Whisp", "Version") 

mod.modName = L["Broker Plugin"]

local brokerFrame = {}
local Timeframes = {"Session", "Hour", "Day", "Week", "All"}
local UIPlus = "|TInterface\\Buttons\\UI-PlusButton-Up:12:12:1:0|t"
local Contacts = {}
local INcolor
local OUTcolor

local defaults = {
	char = {
		minimap = {
			hide = true,
		},
		tooltipTimeFrame = 1,      -- Which messages should be shown on the fubar tooltop
		tooltipSort = true,              -- Sort method for messages on the fubar tooltip (true = time)
		frameWidth = 500,                  -- Width of the frame
		maxheight = 0,
		timecolor = true,
		maxwidth = 180, 
		showhints = true
	}
}

local options = {
	height = {
		type = "range",
		name = L["Max frame height"],
		desc = L["Maximum height of tooltip before a scrollframe is used. 0 for automatic."],
		get = function() return mod.db.char.maxheight end,
		set = 	function(info, v) mod.db.char.maxheight = v end,
		min = 0, 
		max = 1500, 
		step = 25,
		order = 100
	},
	width = {
		type = "range",
		name = L["Max tooltip width"],
		get = function() return mod.db.char.maxwidth end,
		set = 	function(info, v) mod.db.char.maxwidth = v end,
		min = 50, 
		max = 600, 
		step = 10,
		order = 105
	},
	usetimecolor = {
		type = 'toggle',
		name = L["Timestamp color"],
		desc = L["Use timestamp coloring for age of message"],
		get = function() return mod.db.char.timecolor end,
		set = function(info, v) mod.db.char.timecolor = v end,
		order = 110
	},
	hints = {
		type = 'toggle',
		name = L["Show hints"],
		get = function() return mod.db.char.showhints end,
		set = function(info, v) mod.db.char.showhints = v end,
		order = 115
	},
	b2f = {
		type = "execute",
		name = L["Broker2FuBar options"],
		order = 200,
		desc = L["Open the Broker2FuBar options panel"],
		hidden = function() return not C_AddOns.IsAddOnLoaded('Broker2FuBar') end,
		func = function() LibStub("AceAddon-3.0"):GetAddon("Broker2FuBar", true):OpenGUI() end,
	},
	toggleminimap = {
		type = "toggle",
		name = L["Hide minimap icon"],
		get = function() return mod.db.char.minimap.hide end,
		set = function(info, v) 
				mod.db.char.minimap.hide = v
				mod:ToggleMinimapIcon(v)
		end,
		disabled = function() return not mod:IsEnabled() end,
		order = 250
	},
}

function mod:OnInitialize()
	self.db = Whisp.db:RegisterNamespace("Broker Plugin", defaults)
	brokerFrame = Whisp:CreateMyFrame("BROKER", self.db.char.frameWidth)
	mod.brokerFrame = brokerFrame
	self.skinned = nil
end

function mod:OnEnable()
	mod:RegisterMessage("WHISP_MESSAGE", "OnMessage")
	mod:RegisterMessage("WHISP_SKIN", "OnSkinUpdate")
	mod:CreateLDBObject()
	if not icon:IsRegistered("Whisp") then icon:Register("Whisp", mod.brokerFrame.obj, mod.db.char.minimap) end
	self:OnSkinUpdate()
end

function mod:OnDisable()

end

function mod:OnSkinUpdate()
	Whisp:SkinMyFrame(brokerFrame)
	INcolor = "|c00" .. Whisp:HexColor(Whisp.db.char.colorIncoming)
	OUTcolor = "|c00" .. Whisp:HexColor(Whisp.db.char.colorOutgoing)
end

function mod:ToggleMinimapIcon(HIDE)
	if HIDE then icon:Hide("Whisp")
	else icon:Show("Whisp") end
end

function mod:OnMessage()
	local count = ""
	local lastsender = Whisp.lastSender
	local tellcount 
	if Whisp.lastSender and Whisp.db.realm.chatHistory[Whisp.lastSender] then
		if Whisp.db.realm.chatHistory[Whisp.lastSender].tells then
			tellcount = Whisp.db.realm.chatHistory[lastsender].tells
			if tellcount > 0 then 
				count = string.format("(%s)", tellcount) 
				lastsender = lastsender .. count
			end
		end
		local v = Whisp.db.realm.chatHistory[Whisp.lastSender]
		local inc = v.incoming[#v.incoming]
		local color = inc and Whisp.db.char.colorIncoming or Whisp.db.char.colorOutgoing
		mod.brokerFrame.obj.text = Whisp:Colorise(lastsender, Whisp:HexColor(color))
	else 
		mod.brokerFrame.obj.text = "Whisp"
	end
	if mod.tooltip and mod.tooltip:IsShown() then
		mod.tooltip:Clear()
		mod:DisplayTooltip()
	end
end

function mod:CreateLDBObject()
	if mod.brokerFrame.obj then return end
	mod.brokerFrame.obj = ldb:NewDataObject("Whisp", {
		type = "data source",
		text = "Whisp",
		icon = "Interface\\AddOns\\Whisp\\icon",
		OnClick = function(frame, button)
			if button == "RightButton" then
				Whisp:OpenConfig()
			else
				if Whisp.lastSender then
					if IsControlKeyDown() then
						Whisp:ShowLogFrame(self.lastSender)
					else
						if string.find(Whisp.lastSender, "#") then 
							for i=1,BNGetNumFriends() do 
								acc=C_BattleNet.GetFriendAccountInfo(i);
								if acc.battleTag==Whisp.lastSender then 
									Whisp.lastSender=acc.accountName
								break end 
							end 
						end
						if string.find(Whisp.lastSender, "|k") then
							ChatFrame_SendBNetTell(Whisp.lastSender)
						else
							ChatFrame_SendTell(Whisp.lastSender)
						end			
					end
				end
			end
		end,
		OnEnter = function(frame)
			local tooltip = QTC:Acquire("Whisp_Tooltip", 2, "LEFT", "RIGHT")
			tooltip:Clear()
			tooltip:SmartAnchorTo(frame)
			tooltip:SetScript("OnLeave", mod.HideTooltip)
			tooltip:SetScript("OnUpdate", function(f) if not MouseIsOver(frame) then mod:HideTooltip() end end)
			mod.tooltip = tooltip
			mod:DisplayTooltip()
		end,
		OnLeave = function()
			mod:HideTooltip()
		end,
	})
end

function mod:HideTooltip(force)
	if self.tooltip then
		if MouseIsOver(self.tooltip) and not force then return end
		self.tooltip:SetScript("OnLeave", nil)
		self.tooltip:SetScript("OnUpdate", nil)
		self.tooltip:Hide()
		QTC:Release(self.tooltip)
		self.tooltip = nil
	end
end

function mod:HandleTTClick(name, button)
	if not name then return end
        
        local db = mod.db.char
        if name == "timeframe" then
		db.tooltipTimeFrame = db.tooltipTimeFrame + 1
		if db.tooltipTimeFrame > 5 then db.tooltipTimeFrame = 1 end
	elseif name == "sortby" then
		db.tooltipSort = not db.tooltipSort 
	else
		if IsControlKeyDown() then
			Whisp:ShowLogFrame(name)
		elseif IsShiftKeyDown() then
			Whisp.db.realm.chatHistory[name] = nil
			if Whisp.lastSender == name then Whisp.lastSender = nil end
			mod:OnMessage()
		else
			-- make sure bnet names are still clickable
			if string.find(name, "#") then 
				for i=1,BNGetNumFriends() do 
					acc=C_BattleNet.GetFriendAccountInfo(i);
					if acc.battleTag==name then	name=acc.accountName
					break end 
				end 
			end
			if string.find(name, "|k") then
				ChatFrame_SendBNetTell(name)
			else
				ChatFrame_SendTell(name)
			end
		end
	end
	mod.tooltip:Clear()
	mod:DisplayTooltip()
end

function mod:DisplayTooltip()
	local tooltip = mod.tooltip
	if not tooltip then return end
	
	local db = mod.db.char
	local ttime = time()
	local y, x = tooltip:AddLine()
	tooltip:SetCell(y, 1, "|c001eff00" .. "Whisp " .. "|r" .. version, nil, "CENTER", 2)
	tooltip:AddLine("")	
	
	local timeframe = db.tooltipTimeFrame
	local y, x = tooltip:AddLine(UIPlus .. L["Timeframe"], Timeframes[timeframe])
	tooltip:SetLineScript(y, "OnMouseDown", mod.HandleTTClick, "timeframe") 
	local sortby = (db.tooltipSort and "Time") or "Name"
	local y, x = tooltip:AddLine(UIPlus .. L["Sort by"], sortby)
	tooltip:SetLineScript(y, "OnMouseDown", mod.HandleTTClick, "sortby") 
	
	Contacts = {}
	for i,v in pairs(Whisp.db.realm.chatHistory) do
		if v.time[1] then
			tinsert(Contacts, {time = v.time[#v.time], plr = i, inc = v.incoming[#v.incoming], tells = v.tells})
		end
	end
	if not db.tooltipSort then
		table.sort(Contacts, function(a,b) return a.plr<b.plr end)
	else
		table.sort(Contacts, function(a,b) return a.time>b.time end)
	end
		
	tooltip:AddSeparator() 
	tooltip:AddLine("")	
	for i = 1, #Contacts do
		local inc = Contacts[i].inc
		local plr = Contacts[i].plr
		local systime = Contacts[i].time
		local tells = Contacts[i].tells
		local skip = nil
		
		if (timeframe == 1 and systime < Whisp.sessionStart) or (timeframe == 2 and ttime - systime > 3600) or (timeframe == 3 and ttime - systime > 86400) or (timeframe == 4 and ttime - systime > 604800) then
			skip = true
		end
		
		if not skip then
			local timecolor = "|c00ffffff"
			if db.timecolor then
				if ttime - systime > 86400 then timecolor = "|c00ff0000"
				elseif ttime - systime > 3600 then timecolor = "|c00ffff00" 
				else timecolor = "|c0000ff00" end
			end
			if timeframe == 4 or timeframe == 5 then
				systime = date("%d/%m - %H:%M:%S", systime)
			else
				systime = date("%H:%M:%S", systime)
			end
			local color = (inc and INcolor) or OUTcolor
			local missed = ""
			if tells and tells > 0 then 
				count = string.format("(%s)", tells) 
				missed = count
			end
			local y, x = tooltip:AddLine(timecolor .. systime .. "|r", color .. plr .. missed .. "|r")
			tooltip:SetLineScript(y, "OnEnter", mod.ShowBrokerFrame, plr) 
			tooltip:SetLineScript(y, "OnLeave", mod.HideBrokerFrame) 
			tooltip:SetLineScript(y, "OnMouseDown", mod.HandleTTClick, plr) 
		end
	end
	tooltip:AddSeparator() 
	
	if db.showhints then
		local line = tooltip:AddLine(" ") 
	      	tooltip:SetCell(line, 1, L["|c00ffff00Click|r |c001eff00to reply|r. |c00ffff00Control-click|r |c001eff00to open log. |c00ffff00Shift-click|r |c001eff00to delete player history|r"], "LEFT", 2, nil, 5, 5, db.maxwidth)
	end
	if db.maxheight ~= 0 then tooltip:UpdateScrolling(db.maxheight) end 
        tooltip:Show()
end

function mod:ShowBrokerFrame(plr)
	if not plr then return end
	local tip = mod.tooltip
	brokerFrame:ClearAllPoints()
	brokerFrame:SetPoint(mod:Point(), tip, mod:RelPoint())
	Whisp:UpdateMyFrame(brokerFrame, plr)
	brokerFrame:Show()
end

function mod:GetScaledCursorPosition()
	local x, y = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	return x / scale, y / scale, scale
end

function mod:RelPoint()
	local x,y = mod:GetScaledCursorPosition()
	local xp = mod:XPoint(x)
	return (y<GetScreenHeight() / 2) and "TOP"..xp or "BOTTOM"..xp
end

function mod:Point()
	local x,y = mod:GetScaledCursorPosition()
	local xp = mod:XPoint(x)
	return (y<GetScreenHeight() / 2) and "BOTTOM"..xp or "TOP"..xp
end

function mod:XPoint(x)
	if x < GetScreenWidth()/2 - GetScreenWidth()/4 then
		return "LEFT"
	elseif x > GetScreenWidth()/2 + GetScreenWidth()/4 then
		return "RIGHT"
	end
	return ""
end

function mod:HideBrokerFrame()
	brokerFrame:Hide()
end

function mod:GetOptions()
	return options
end

function mod:Info()
	return L["Allows you to quickly review your message history using your favourite Broker display.\n\nFor use with FuBar: Download the Broker2Fubar addon."]
end