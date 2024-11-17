-----------------------------------
-----------------------------------
-- Whisp by Anea
--
-- Makes chatting fun again
-- Type /whisp in-game for options
-----------------------------------
-- core.lua
-- Main routines and functionionality
-----------------------------------

-- Create Ace3 instance
Whisp = LibStub("AceAddon-3.0"):NewAddon("Whisp", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Whisp")
Whisp.media = LibStub("LibSharedMedia-3.0", true)
Whisp:SetDefaultModuleState(false)


-- Default settings and variables
local defaults = {
	profile = {
		modules = {},                      -- Module settings
		version = 0,                       -- The version we are running
		timeout = 720,                     -- How long should conversations be saved in hours (0 indicates session)
		notifyDebug = false,               -- Shows debug messages
		classColor = true,                 -- Colorise playernames by class
		bnetnames = true,
	},
	char = {
		linesShown = 10,                   -- How many lines to show in the panes
		paneSortDown = true,               -- Show messages in the pane newest down
		
		-- Customisation
		paneColor = {0.09, 0.09, 0.09, 0.8},  -- Color for the background of the panes
		paneBackground = "Blizzard Tooltip",
		paneBorder = "Blizzard Tooltip",
		paneBorderColor = {0.5, 0.5, 0.5, 0.8},
		paneFont = "Arial Narrow",
		fontSize = 14,
		timeFormat = "%H:%M:%S",
		timeColor = {1,1,1,1},
		timeColorByChannel = false,
		colorIncoming = {1,0.5,1},         -- Color for incoming messages
		colorOutgoing = {0.73,0.73,1},     -- Color for outgoing messages
	},
	realm = {
		chatHistory = {},                  -- All conversations
		playerClass = {},                  -- Cache with player classes
	},
}

-- local variables
Whisp.currentBuild = 20240727        -- Latest build
Whisp.tellTarget = nil               -- Current tell-target
Whisp.lastSender = nil               -- Person who last send you a tell
Whisp.editBoxFrame = {}              -- Pane to attach to the editbox
Whisp.tooltipFrame = {}              -- Pane to attach to fubar
Whisp.clickableTooltip = true        -- Ensures that the FuBar tooltip is clickable
Whisp.sessionStart = 0               -- Start time of this session

-----------------------------------
-----------------------------------
-- Initialisation functions

function Whisp:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("WhispDB", defaults, "Default")
	self.sessionStart = time() - 30
	self:SetupOptions()
end

function Whisp:OnEnable()
	-- Cache incoming and outgoing whispers
	self:RegisterEvent("CHAT_MSG_WHISPER", Whisp.ChatEventIncoming)
	self:RegisterEvent("CHAT_MSG_WHISPER_INFORM", Whisp.ChatEventOutgoing)
	self:RegisterEvent("CHAT_MSG_BN_WHISPER", Whisp.BNChatEventIncoming)
	self:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM", Whisp.BNChatEventOutgoing)
	-- Schedules
	self:ScheduleRepeatingTimer(Whisp.CollectGarbage, 300)
	
	-- Load Modules  
	for k, v in self:IterateModules() do
		if self.db.profile.modules[k] ~= false then v:Enable() end
	end

	-- Add self to the player class-cache
	local localizedClass, class = UnitClass("player")
	Whisp.db.realm.playerClass[GetUnitName("player")] = class
end

function Whisp:OnDisable()
	self:UnregisterAllEvents()
	
	-- UnLoad Modules  
	for k, v in self:IterateModules() do
		if self.db.profile.modules[k] ~= false then v:Disable() end
	end
end

function Whisp:OnProfileChanged()
	for k, v in self:IterateModules() do
		if self.db.profile.modules[k] ~= false then v:OnSkinUpdate() end
	end
end

function Whisp:debug(message)
	DEFAULT_CHAT_FRAME:AddMessage(message)
end

-----------------------------------
-----------------------------------
-- Events

function Whisp:ChatEventIncoming(msg, plr)
	Whisp:UpdateChatHistory(msg, plr, plr, true)
	Whisp:SendMessage("WHISP_MESSAGE")
end

function Whisp:ChatEventOutgoing(msg, plr)
	Whisp:UpdateChatHistory(msg, plr, UnitName("player"), false)
	Whisp:SendMessage("WHISP_MESSAGE")
end

function Whisp:BNChatEventIncoming(msg, plr, _, _, _, _, _, _, _, _, _, _, bnSenderID)
--workaround to make Bnet chat persistent
	local btag = C_BattleNet.GetAccountInfoByID(bnSenderID).battleTag
	plr = btag

	Whisp:UpdateChatHistory(msg, plr, plr, true, bnSenderID)
	Whisp:SendMessage("WHISP_MESSAGE")
end

function Whisp:BNChatEventOutgoing(msg, plr, _, _, _, _, _, _, _, _, _, _, bnSenderID)
--workaround to make Bnet chat persistent
	local btag = C_BattleNet.GetAccountInfoByID(bnSenderID).battleTag
	plr = btag

	Whisp:UpdateChatHistory(msg, plr, UnitName("player"), false, bnSenderID)
	Whisp:SendMessage("WHISP_MESSAGE")
end
-----------------------------------
-----------------------------------
-- Generic Frame functions


function Whisp:CreateMyFrameNew(name, width)
	local frame = CreateFrame("Frame", "WHISP_"..name, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	frame:SetWidth(width)  
	frame:SetHeight(20)
	frame:SetMinResize(200,20)
	frame:SetFrameLevel(GameTooltip:GetFrameLevel() - 1)
	
	-- Setup text part
	local chatframe = CreateFrame("ScrollingMessageFrame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
	chatframe:SetFading(false)
	chatframe:SetMaxLines(100)
	chatframe:SetTimeVisible(120)
	chatframe:SetJustifyH("LEFT")
	chatframe:EnableMouse(true)
	chatframe:EnableMouseWheel(1)
	chatframe:UnregisterAllEvents()
	chatframe:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
	chatframe:AddMessage("Test",1,1,1,1)
	chatframe:SetAllPoints(frame)
	chatframe:Show()
	
	-- Set background and border
	frame:SetFrameStrata("TOOLTIP")
	Whisp:SkinMyFrame(frame)
	
	frame.chatframe = chatframe
	
	return frame
end


function Whisp:CreateMyFrame(name, width)
	local frame = CreateFrame("Frame", "WHISP_"..name, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	frame:ClearAllPoints()
	-- Size is required to be set or SetPoint() won't work later on
	frame:SetWidth(width)  
	frame:SetHeight(20)
	frame:SetResizeBounds(200,20)
	frame:SetFrameLevel(GameTooltip:GetFrameLevel() + 10)
	-- Setup textfields
	frame.text = frame:CreateFontString("WHISP_EDITBOXTEXT","OVERLAY","ChatFontNormal")
	frame.text:SetJustifyH("LEFT")
	frame.text:SetJustifyV("TOP")
	frame.text:SetTextColor(1.0,1.0,1.0,1.0)
	-- Set background and border
	frame:SetFrameStrata("TOOLTIP")
	Whisp:SkinMyFrame(frame)
	frame:Hide()
	return frame
end


function Whisp:UpdateMyFrameNew(frame, plr)
	frame.chatframe:AddMessage("Test",1,1,1,1)
	
	if plr then
		if Whisp.db.realm.chatHistory[plr] then
			frame.chatframe:Clear()
			frame.chatframe:ScrollToBottom()
			frame:SetHeight(200)
			
			local n = #Whisp.db.realm.chatHistory[plr].message
			-- Generate conversation
			for i= 1, n do
				local color = Whisp.db.realm.chatHistory[plr].incoming[i] and Whisp.db.char.colorIncoming or Whisp.db.char.colorOutgoing
				local t = Whisp:FormatTimeStamp(Whisp.db.realm.chatHistory[plr].time[i], color)
				local m = Whisp:Colorise(Whisp.db.realm.chatHistory[plr].message[i], Whisp:HexColor(color))
				local s = Whisp:FormatPlayerName(Whisp.db.realm.chatHistory[plr].sender[i])
				frame.chatframe:AddMessage(t.." "..s..": "..m, 0.5, 0.5, 0.5, 1)
			end
		end
	end
end


function Whisp:UpdateMyFrame(frame, plr)
	frame.text:SetText(Whisp:GetChatHistory(plr, Whisp.db.char.linesShown))
	frame.text:SetPoint("TOPLEFT",frame,"TOPLEFT",5,-5)
	-- Adjust height of the frame to the height of the text
	frame.text:SetWidth(frame:GetRight() - frame:GetLeft() - 10)
	frame:SetHeight(frame.text:GetHeight()+15)
end

function Whisp:SkinMyFrame(frame)
	-- Set border and background texture
	local bg = Whisp.media:Fetch('background', Whisp.db.char.paneBackground, "Blizzard Tooltip")
	local ed = Whisp.media:Fetch('border', Whisp.db.char.paneBorder, "Blizzard Tooltip")
	frame:SetBackdrop({
		bgFile = bg, tile = true, tileSize = 16,
		edgeFile = ed, edgeSize = 16,
		insets = {left = 3, right = 3, top = 3, bottom = 3},
	})
	-- Set font
	local font = Whisp.media:Fetch('font', Whisp.db.char.paneFont)
	--  local _, _, style = frame.chatframe:GetFont()
	frame.text:SetFont(font, Whisp.db.char.fontSize)
	
	-- Set background-color
	local c,d = Whisp.db.char.paneColor, Whisp.db.char.paneBorderColor
	frame:SetBackdropColor(c[1], c[2], c[3], c[4])
	frame:SetBackdropBorderColor(d[1], d[2], d[3], d[4])
end

-----------------------------------
-----------------------------------
-- Log window functions

function Whisp:ShowLogFrame(plr)
	if plr and Whisp.db.realm.chatHistory[plr] then
		local msg = Whisp:GetChatHistory(plr, #Whisp.db.realm.chatHistory[plr].time)
		if msg then
			Whisp_EditBox:SetText(msg)
			WhispUIParent:Show()
		end
	end
end

-----------------------------------
-----------------------------------
-- ChatHistory

-- Chat message event
function Whisp:UpdateChatHistory(msg, plr, snd, incoming, bnSenderID)
	if not plr then return end
	if bnSenderID and not Whisp.db.profile.bnetnames then
		local toon = C_BattleNet.GetAccountInfoByID(bnSenderID).gameAccountInfo.characterName
		plr = toon
		if incoming then snd = plr end
	end
	if Whisp:HideAddonMessage(msg, plr) then return end
	if not Whisp.db.realm.chatHistory[plr] then
		Whisp.db.realm.chatHistory[plr] = {sender = {}, message = {}, time = {}, incoming = {}, tells = 0}
	end
	if not Whisp.db.realm.chatHistory[plr].tells then Whisp.db.realm.chatHistory[plr].tells = 0 end
	if snd == UnitName("player") then Whisp.db.realm.chatHistory[plr].tells = 0
	else Whisp.db.realm.chatHistory[plr].tells = Whisp.db.realm.chatHistory[plr].tells + 1 end
	
	-- Update player class cache
	local _, class = UnitClass(plr) 
	Whisp.db.realm.playerClass[plr] = class
	
	Whisp.lastSender = plr
	-- Insert new message
	tinsert(Whisp.db.realm.chatHistory[plr].sender, snd)
	tinsert(Whisp.db.realm.chatHistory[plr].message, msg)
	tinsert(Whisp.db.realm.chatHistory[plr].incoming, incoming)
	tinsert(Whisp.db.realm.chatHistory[plr].time, time())
end

-- Returns the combined recent messages from this player
function Whisp:GetChatHistory(plr, max)
	local msg = ""
	if plr then
		if Whisp.db.realm.chatHistory[plr] then
			local n = #Whisp.db.realm.chatHistory[plr].message
			local output = {}
			-- Generate conversation
			for i= n>max and n-max or 1, n do
				local color = Whisp.db.realm.chatHistory[plr].incoming[i] and Whisp.db.char.colorIncoming or Whisp.db.char.colorOutgoing
				local t = Whisp:FormatTimeStamp(Whisp.db.realm.chatHistory[plr].time[i], color)
				local m = Whisp:Colorise(Whisp.db.realm.chatHistory[plr].message[i], Whisp:HexColor(color))
				local s = Whisp:FormatPlayerName(Whisp.db.realm.chatHistory[plr].sender[i])
				tinsert(output, t.." "..s..": "..m)
			end
			-- Sort output
			local pd = Whisp.db.char.paneSortDown
			for i = pd and 1 or #output, pd and #output or 1, pd and 1 or -1 do
				msg = msg .. output[i]
				if (pd and (i<#output)) or ((not pd) and (i>1)) then 
					msg = msg.."\n"
				end
			end
		end
	end
	if msg == "" then return nil end
	return msg
end

-- Garbage collection of message cache
function Whisp:CollectGarbage()
	local t = Whisp.sessionStart
	if Whisp.db.profile.timeout > 0 then 
		t = time() - (3600 * Whisp.db.profile.timeout)
	end
	
	-- Remove full entries of the player if the conversation has timed out
	for i,v in pairs(Whisp.db.realm.chatHistory) do
		local ct = Whisp.db.realm.chatHistory[i].time[#Whisp.db.realm.chatHistory[i].time]
		if ct and ct < t then
			Whisp.db.realm.chatHistory[i] = nil
			Whisp.db.realm.playerClass[i] = nil
		end
	end
		
	-- Remove individual entries of the player if they have timed out
	for i,v in pairs(Whisp.db.realm.chatHistory) do
		for j=1, #Whisp.db.realm.chatHistory[i].time do
			if Whisp.db.realm.chatHistory[i].time[j] and Whisp.db.realm.chatHistory[i].time[j] < t then
				tremove(Whisp.db.realm.chatHistory[i].sender,j)
				tremove(Whisp.db.realm.chatHistory[i].message,j)
				tremove(Whisp.db.realm.chatHistory[i].time,j)
				tremove(Whisp.db.realm.chatHistory[i].incoming,j)
			end
		end
	end
	
	Whisp:SendMessage("WHISP_MESSAGE")
end

-----------------------------------
-----------------------------------
-- Hide addon messages 

function Whisp:HideAddonMessage(msg, plr)
	if (strsub(msg, 1,5) == "DBMv4") then
		return true
	elseif (strsub(msg, 1,4) == "LVBM") then
		return true
	end
	return false
end

-----------------------------------
-----------------------------------
-- Utility and other functions

-- Output message to the chatframe
-- Level can be either:
-- 0: System message
-- 3: Debug
function Whisp:Msg(text)
	if not text then return end
	--if level==0 or level==3 and self.db.profile.notifyDebug then
		DEFAULT_CHAT_FRAME:AddMessage(text, 0.6, 0.6, 1)
	--end
end

-- Create a link to a playername
function Whisp:FormatPlayerName(name)
	local simple = "|cffffff00"..name.."|r"
	local class = Whisp.db.realm.playerClass[name]
	if not (Whisp.db.profile.classColor and class) then return simple end
	local classColorTable = RAID_CLASS_COLORS[class]
	if ( not classColorTable ) then
		return simple
	end
	return string.format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..name.."\124r"
end

function Whisp:FormatTimeStamp(t, c)
	if t < time() - 86400 then
		t = date("%d/%m - "..Whisp.db.char.timeFormat, t)
	else
		t = date(Whisp.db.char.timeFormat, t)
	end
	return Whisp:Colorise(t, Whisp:HexColor(Whisp.db.char.timeColorByChannel and c or Whisp.db.char.timeColor))
end

-- Returns the hexvalue of the rgb
function Whisp:HexColor(r, g, b)
	if type(r)=="table" then
		r, g, b = r[1], r[2], r[3]
	end
	return string.format("%02x%02x%02x", 255*r, 255*g, 255*b)
end

-- Colorise the text
function Whisp:Colorise(text, hexcolor)
	text = gsub(text, "(|c.-|H.-|r)", "|r%1|cff"..hexcolor)
	return "|cff"..hexcolor..text.."|r"
end

function Whisp:Test(count)
	for i = 1, count do
		Whisp:UpdateChatHistory("Some nice test message", "Test"..i, "Test"..i, true, UnitGUID("Player"))
	end
end