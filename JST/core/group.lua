local T, C, L, G = unpack(select(2, ...))

local NickNameInfo = {}
local GroupInfo = {}
local UnitFrames = {}

local newest = G.Version
local last_scan = 0

local LS = LibStub:GetLibrary("LibSpecialization")
local LGF = LibStub("LibGetFrame-1.0")

--====================================================--
--[[                 -- API --                      ]]--
--====================================================--
local delayframe = CreateFrame("Frame")
delayframe.t = 0
delayframe.func = {}

local DelayFunc = function(delay, func)
	table.insert(delayframe.func, {action = func, wait = delay})	
	if not delayframe:GetScript("OnUpdate") then
		delayframe:SetScript("OnUpdate", function(self, elapsed)
			self.t = self.t + elapsed
			if self.t > 0.1 then
				if delayframe.func[1] then
					delayframe.func[1].wait = delayframe.func[1].wait - self.t
					if delayframe.func[1].wait <= 0 then
						local cur_func = delayframe.func[1].action
						table.remove(delayframe.func, 1)
						cur_func()	
					end
				else
					self:SetScript("OnUpdate", nil)
				end
				self.t = 0
			end
		end)
	end
end

----------------------------------------------------------
---------------------[[     API     ]]--------------------
----------------------------------------------------------
-- 比较版本
local MaxVer = function(ver1, ver2)
	local value1 = tonumber(string.match(ver1, "(%d*%.?%d+)"))
	local value2 = tonumber(string.match(ver2, "(%d*%.?%d+)"))
	if value1 >= value2 then
		return ver1
	else
		return ver2
	end
end

-- 版本染色
local FormatVersionText = function(ver)
	if not ver then return end
	if ver == newest then
		return ver
	elseif ver == "NO ADDON" then
		return string.format("|cffFF0000%s|r", ver) 
	else
		return string.format("|cffFFA500%s|r", ver)
	end
end

-- 根据职业染色文本
local ColorNameText = function(name_text, player)
	local class = select(2, UnitClass(player))
	local colorstr = class and G.Ccolors[class]["colorStr"] or "ffffffff"
	local str = string.format("|c%s%s|r", colorstr, name_text)
	return str
end
T.ColorNameText = ColorNameText

-- 生成用于MRT战术板的名字格式
local ColorNameForMrt = function(name)
	local str = ColorNameText(name, name)
	local mrt_str = string.gsub(str, "|", "||")
	return mrt_str
end
T.ColorNameForMrt = ColorNameForMrt

----------------------------------------------------------
-----------------[[     团队信息 API     ]]---------------
----------------------------------------------------------
-- 获取队伍成员列表
local IterateGroupMembers = function(reversed, forceParty)
  local unit = (not forceParty and IsInRaid()) and 'raid' or 'party'
  local numGroupMembers = unit == 'party' and GetNumSubgroupMembers() or GetNumGroupMembers()
  local i = reversed and numGroupMembers or (unit == 'party' and 0 or 1)
  return function()
    local ret
    if i == 0 and unit == 'party' then
      ret = 'player'
    elseif i <= numGroupMembers and i > 0 then
      ret = unit .. i
    end
    i = i + (reversed and -1 or 1)
    return ret
  end
end
T.IterateGroupMembers = IterateGroupMembers

-- 获取玩家昵称或名字
local GetNameByGUID = function(GUID)
	local use_nickname
	local info = GroupInfo[GUID]
	if JST_CDB.GeneralOption.name_format == "nickname" and info.nick_names and info.nick_names[1] then
		return info.nick_names[1]
	else
		return info.real_name
	end
end
T.GetNameByGUID = GetNameByGUID

-- 获取队伍信息
local GetGroupInfobyGUID = function(GUID)
	local info = GroupInfo[GUID]
	if info then
		return info
	end
end
T.GetGroupInfobyGUID = GetGroupInfobyGUID

-- 根据昵称/名字获取队伍信息
local GetGroupInfobyName = function(name)
	for GUID, info in pairs(GroupInfo) do
		if string.find(name, "-") then
			if info.full_name == name then
				return info
			end
		else
			if info.real_name == name then
				return info
			elseif T.IsInTable(info.nick_names, name) then
				return info
			end
		end
	end
end
T.GetGroupInfobyName = GetGroupInfobyName

-- 生成染色的队友昵称
local ColorNickNameByGUID = function(GUID)
	local unit = GroupInfo[GUID].unit
	return ColorNameText(GetNameByGUID(GUID), unit)
end
T.ColorNickNameByGUID = ColorNickNameByGUID

-- 生成染色的队友昵称
local ColorNickNameByName = function(name)
	local info = GetGroupInfobyName(name)
	if info then
		return info.format_name
	else
		return name
	end
end
T.ColorNickNameByName = ColorNickNameByName

-- 朗读文本中获取玩家名字
local GetNameByName= function(name)
	local info = GetGroupInfobyName(name)
	if info then
		if JST_CDB["GeneralOption"]["name_format"] == "nickname" and info.nicknames[1] then
			return info.nicknames[1]
		else
			return info.real_name
		end
	else
		return name
	end
end
T.GetNameByName = GetNameByName
----------------------------------------------------------
---------------------[[     GUI     ]]--------------------
----------------------------------------------------------
local OP = G.raid_options

local refresh_btn = T.ClickButton(OP.sfa, 80, {"TOPRIGHT", OP.sfa, "TOPRIGHT", -5, -2}, L["刷新"])
local player_lines = {}

local function FormatNickNames(GUID)
	if GroupInfo[GUID] then
		local nick_names_str = ""
		for i, v in pairs(GroupInfo[GUID].nick_names) do
			if i ~= 1 then
				nick_names_str = nick_names_str.." "
			end
			if #NickNameInfo[v] > 1 then
				nick_names_str = nick_names_str..string.format("|cffFF0000%s|r", v)
			else
				nick_names_str = nick_names_str..v
			end
		end
		return nick_names_str
	else
		return ""
	end
end

local function LineUpRaidInfoLines()
	local num = 1
	for i, frame in pairs(player_lines) do
		frame:ClearAllPoints()
		if frame:IsShown() then
			frame:SetPoint("TOPLEFT", 20, -20-num*25)
			num = num + 1
		end
	end
end

local function CreateRefreshButton(frame)
	local btn = CreateFrame("Button", nil, frame, "BigRedRefreshButtonTemplate")
	
	btn:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	btn:SetSize(20, 20)
	btn.tooltipText = L["刷新版本和昵称"]
	
	btn:SetScript("OnClick", function(self)
		if not frame.playerGUID then return end
		
		local GUID = frame.playerGUID
		
		GroupInfo[GUID].ilvl = 0
		GroupInfo[GUID].nick_names = table.wipe(GroupInfo[GUID].nick_names)
		GroupInfo[GUID].ver = "NO ADDON"
		
		frame.str2:SetText("...")
		frame.str4:SetText("...")
		frame.str5:SetText("...")
	
		self:Disable()
		T.addon_msg("ver", "WHISPER", Ambiguate(GroupInfo[GUID].full_name, "none"))

		C_Timer.After(2, function()
			local info = GetGroupInfobyGUID(GUID)
			frame.str2:SetText(info.ilvl)
			frame.str4:SetText(FormatNickNames(GUID))
			frame.str5:SetText(FormatVersionText(info.ver))
			self:Enable()
		end)
	end)
	
	return btn
end

local function CreateRaidInfoLine()
	local frame = CreateFrame("Frame", nil, OP.sfa)
	frame:SetSize(700, 20)
	frame:Hide()
	
	frame.str1 = T.createtext(frame, "OVERLAY", 14, "OUTLINE", "LEFT")
	frame.str1:SetPoint("LEFT", frame, "LEFT", 0, 0)
	frame.str1:SetWidth(150)
	
	frame.str2 = T.createtext(frame, "OVERLAY", 14, "OUTLINE", "LEFT")
	frame.str2:SetPoint("LEFT", frame.str1, "RIGHT", 0, 0)
	frame.str2:SetWidth(60)
	
	frame.str3 = T.createtext(frame, "OVERLAY", 14, "OUTLINE", "LEFT")
	frame.str3:SetPoint("LEFT", frame.str2, "RIGHT", 0, 0)
	frame.str3:SetWidth(30)
	
	frame.str4 = T.createtext(frame, "OVERLAY", 14, "OUTLINE", "LEFT")
	frame.str4:SetPoint("LEFT", frame.str3, "RIGHT", 0, 0)
	
	frame.str5 = T.createtext(frame, "OVERLAY", 14, "OUTLINE", "LEFT")
	frame.str5:SetPoint("LEFT", frame, "RIGHT", -100, 0)
	
	frame.refresh_btn = CreateRefreshButton(frame)
	
	table.insert(player_lines, frame)
	
	return frame
end

local function GetAvailableRaidInfoLine()
	local available
	for i, frame in pairs(player_lines) do
		if not frame.playerGUID then
			available = frame
			break
		end
	end
	if not available then
		available = CreateRaidInfoLine()
	end
	return available
end

local function GetRaidInfoLineForPlayerGUID(GUID)
	for i, frame in pairs(player_lines) do
		if frame.playerGUID == GUID then
			return frame
		end
	end
end

local function UpdateRaidInfoLineByPlayerGUID(GUID)
	if not OP:IsShown() then return end
	local frame = GetRaidInfoLineForPlayerGUID(GUID) or GetAvailableRaidInfoLine()
	local info = GetGroupInfobyGUID(GUID)
	
	frame.str1:SetText(ColorNameText(info.real_name, info.unit))
	frame.str2:SetText(string.format("%.1f", info.ilvl))
	frame.str3:SetText(info.spec_icon and T.GetTextureStr(info.spec_icon) or "")
	frame.str4:SetText(FormatNickNames(info.GUID)) -- 冲突染色
	frame.str5:SetText(FormatVersionText(info.ver))

	frame.playerGUID = GUID
	if not frame:IsShown() then
		frame:Show()
		LineUpRaidInfoLines()
	end
end

local function UpdateLinesByNickName(nick_name)
	for _, GUID in pairs(NickNameInfo[nick_name]) do
		UpdateRaidInfoLineByPlayerGUID(GUID)
	end
	if #NickNameInfo[nick_name] > 1 then
		local str = ""
		for _, GUID in pairs(NickNameInfo[nick_name]) do
			local info = GroupInfo[GUID]
			str = str.." "..ColorNameText(info.real_name, info.unit)
		end
		T.msg(string.format(L["昵称冲突"], nick_name, str))
	end
end

local function RemoveRaidInfoLineByPlayerGUID(GUID)
	if not OP:IsShown() then return end
	local frame = GetRaidInfoLineForPlayerGUID(GUID)
	if frame then
		if frame:IsShown() then
			frame:Hide()
			LineUpRaidInfoLines()
		end
		frame.playerGUID = nil
	end
end

local function RemoveAllRaidInfoLine()
	if not OP:IsShown() then return end
	for i, frame in pairs(player_lines) do	
		frame:Hide()
		frame.playerGUID = nil
	end
end

refresh_btn:SetScript("OnShow", function()
	RemoveAllRaidInfoLine()
	for GUID in pairs(GroupInfo) do
		UpdateRaidInfoLineByPlayerGUID(GUID)
	end
end)

refresh_btn:SetScript("OnClick", function()
	refresh_btn:SetText("...")
	refresh_btn:Disable()
	
	if IsInGroup() then
		RemoveAllRaidInfoLine()
		
		for GUID, info in pairs(GroupInfo) do
			info.ver = "NO ADDON"
			info.ilvl = 0
			info.nick_names = table.wipe(info.nick_names)
			UpdateRaidInfoLineByPlayerGUID(GUID)
		end
		
		LS:RequestSpecialization()
		T.addon_msg("ver", "GROUP")
	end
	
	C_Timer.After(2, function()
		refresh_btn:SetText(L["刷新"])
		refresh_btn:Enable()
	end)
end)

----------------------------------------------------------
--------------------[[     Event     ]]-------------------
----------------------------------------------------------
local function UpdateNickNameByPlayerGUID(GUID, nick_name_str)
	GroupInfo[GUID].nick_names = table.wipe(GroupInfo[GUID].nick_names)
	
	for nick_name, GUIDs in pairs(NickNameInfo) do
		for i, source in pairs(GUIDs) do
			if source == GUID then
				table.remove(NickNameInfo[nick_name], i)
				break
			end
		end
	end
	
	local t = {string.split(" ", nick_name_str)}			
	for i, nick_name in pairs(t) do	
		if nick_name ~= "" then
			if not T.IsInTable(GroupInfo[GUID].nick_names, nick_name) then
				table.insert(GroupInfo[GUID].nick_names, nick_name)
			end
			if not NickNameInfo[nick_name] then
				NickNameInfo[nick_name] = {}
			end
			if not T.IsInTable(NickNameInfo[nick_name], GUID) then
				table.insert(NickNameInfo[nick_name], GUID)
			end
			UpdateLinesByNickName(nick_name)
		end
	end
	
	GroupInfo[GUID].format_name = ColorNickNameByGUID(GUID)
	
	UpdateRaidInfoLineByPlayerGUID(GUID)
end

local function SendMyInfo(target)
	local _, avgItemLevelEquipped = GetAverageItemLevel()
	if target then
		T.addon_msg("send_ver,"..G.Version..","..JST_CDB["GeneralOption"]["mynickname"]..","..avgItemLevelEquipped..","..G.PlayerGUID, "WHISPER", target)
	else
		T.addon_msg("send_ver,"..G.Version..","..JST_CDB["GeneralOption"]["mynickname"]..","..avgItemLevelEquipped..","..G.PlayerGUID, "GROUP")
	end
end

local function UpdateMyInfo()
	local _, avgItemLevelEquipped = GetAverageItemLevel()
	GroupInfo[G.PlayerGUID].ver = G.Version
	GroupInfo[G.PlayerGUID].ilvl = avgItemLevelEquipped
	UpdateNickNameByPlayerGUID(G.PlayerGUID, JST_CDB["GeneralOption"]["mynickname"])
end

local function ScanUnit(unit)
	local GUID = UnitGUID(unit)
	local name, realm = UnitFullName(unit)
	realm = realm or GetRealmName()
	
	if not GroupInfo[GUID] then
		GroupInfo[GUID] = {}
	end

	if not GroupInfo[GUID].nick_names then
		GroupInfo[GUID].nick_names = {}
	end
	
	if not GroupInfo[GUID].ver then
		GroupInfo[GUID].ver = "NO ADDON"
	end
	
	if not GroupInfo[GUID].ilvl then
		GroupInfo[GUID].ilvl = 0
	end
	
	GroupInfo[GUID].GUID = GUID
	GroupInfo[GUID].unit = unit	
	GroupInfo[GUID].real_name = name
	GroupInfo[GUID].full_name = string.format("%s-%s", name, realm)
	GroupInfo[GUID].format_name = ColorNickNameByGUID(GUID)
	
	if GUID == G.PlayerGUID then
		UpdateMyInfo()
	end
	
	if not UnitFrames[unit] then
		LGF:ScanForUnitFrames()
		UnitFrames[unit] = true
	end
	
	UpdateRaidInfoLineByPlayerGUID(GUID)
end

local function RemovePlayer(GUID)
	GroupInfo[GUID] = nil			
	RemoveRaidInfoLineByPlayerGUID(GUID)
	
	for nick_name, GUIDs in pairs(NickNameInfo) do
		for i, source in pairs(GUIDs) do
			if source == GUID then
				table.remove(NickNameInfo[nick_name], i)
				UpdateLinesByNickName(nick_name)
				break
			end
		end
	end
end

local function ScanGroupMembers()
	if GetTime() - last_scan > .5 then
		for GUID, info in pairs(GroupInfo) do
			local unit = UnitTokenFromGUID(GUID)
			if not unit or not UnitInAnyGroup(unit) then
				RemovePlayer(GUID)
			end
		end
	
		for unit in IterateGroupMembers() do
			ScanUnit(unit)
		end
		
		T.addon_msg("ver", "GROUP")
		
		last_scan = GetTime()
	end
end

local eventframe = CreateFrame("Frame")

eventframe:SetScript("OnEvent", function(self, event, ...)
	if event == "READY_CHECK" or event == "GROUP_FORMED" then
		SendMyInfo()
	elseif event == "PLAYER_LOGIN" or event == "GROUP_ROSTER_UPDATE" then
		ScanGroupMembers()
	elseif event == "ADDON_MSG" then
		--if InCombatLockdown() then return end
		local channel, sender, mark = ...
		if mark == "ver" then
			SendMyInfo(channel == "WHISPER" and Ambiguate(sender, "none"))				
		elseif mark == "send_ver" then
			local ver, nick_name_str, item_lvl, GUID = select(4, ...)
			if not ver then return end	
			newest = MaxVer(newest, ver)		
			if GroupInfo[GUID] then
				GroupInfo[GUID].ver = ver
				GroupInfo[GUID].ilvl = item_lvl or 0
				UpdateNickNameByPlayerGUID(GUID, nick_name_str)
			end
		end
	end
end)

local update_events = {
	["READY_CHECK"] = true,
	["GROUP_FORMED"] = true,
	["PLAYER_LOGIN"] = true,
	["GROUP_ROSTER_UPDATE"] = true,
	["ADDON_MSG"] = true,
}

T.RegisterEventAndCallbacks(eventframe, update_events)

local function GroupSpecUpdate(specId, role, position, name)
	--print(string.format("%s [%d] %s %s", real_name, specId, role, position))
	local full_name
	if string.find("-", name) then
		full_name = name
	else
		full_name = string.format("%s-%s", name, GetRealmName())
	end
	for GUID, info in pairs(GroupInfo) do
		if info.full_name == full_name then
			info.role = role
			info.spec_id = specId
			info.spec_icon = select(4, GetSpecializationInfoByID(specId))
			info.pos = position
			
			UpdateRaidInfoLineByPlayerGUID(GUID)
			break
		end
	end
end

LS:Register("JST", GroupSpecUpdate)
----------------------------------------------------------
---------------[[     GUI 昵称按钮     ]]-----------------
----------------------------------------------------------
local GUI = G.GUI

GUI.name = T.ClickButton(GUI, 150, {"LEFT", GUI.export, "RIGHT", 5, 0})
GUI.name:SetScript("OnShow", function(self)
	self:SetText(string.format(L["我的昵称"], JST_CDB["GeneralOption"]["mynickname"]))
end)

GUI.name:SetScript("OnClick", function(self)
	T.DisplayCopyString(self, JST_CDB["GeneralOption"]["mynickname"], L["输入昵称"], function(str)
		JST_CDB["GeneralOption"]["mynickname"] = str
		self:SetText(string.format(L["我的昵称"], JST_CDB["GeneralOption"]["mynickname"]))
		UpdateNickNameByPlayerGUID(G.PlayerGUID, JST_CDB["GeneralOption"]["mynickname"])
		SendMyInfo()
	end)
end)

--====================================================--
--[[               -- 昵称检测 --                   ]]--
--====================================================--
local function GetGroupNickNameInfo()
	local namelist = ""
	local num = 0
	for unit in IterateGroupMembers() do
		local GUID = UnitGUID(unit)
		local name = UnitName(unit)
		if not (GroupInfo[GUID] and GroupInfo[GUID].nick_names and GroupInfo[GUID].nick_names[1]) then
			num = num + 1
			if num <= 3 then
				namelist = namelist..ColorNameText(name, unit).." "
			end
		end
	end
	if num == 0 then
		return L["所有昵称已加载"]
	elseif num <= 3 then
		return string.format(L["昵称未加载"], namelist)
	else
		return string.format(L["多人昵称未加载"], namelist, num)
	end
end

local RaidStatusCheckFrame = CreateFrame("Frame", G.addon_name.."RaidStatusCheckFrame", UIParent)
RaidStatusCheckFrame:SetSize(130, 30)

RaidStatusCheckFrame.movingname = L["昵称实时检测"]
RaidStatusCheckFrame.point = { a1 = "CENTER", a2 = "TOP", x = 0, y = -50}
T.CreateDragFrame(RaidStatusCheckFrame)

RaidStatusCheckFrame.refresh_btn = CreateFrame("Button", nil, RaidStatusCheckFrame)
RaidStatusCheckFrame.refresh_btn:SetSize(15, 15)
RaidStatusCheckFrame.refresh_btn:SetPoint("TOPLEFT", RaidStatusCheckFrame, "TOPLEFT", 0, 0)
T.createborder(RaidStatusCheckFrame.refresh_btn)

RaidStatusCheckFrame.refresh_btn:SetNormalTexture("uitools-icon-refresh")

RaidStatusCheckFrame.refresh_btn:SetScript("OnEnter", function(self) 
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
	GameTooltip:AddLine(L["刷新"])
	GameTooltip:Show()
end)

RaidStatusCheckFrame.refresh_btn:SetScript("OnLeave", function(self)
	GameTooltip:Hide()
end)

RaidStatusCheckFrame.refresh_btn:SetScript("OnClick", function(self)	
	self:GetNormalTexture():SetVertexColor(1, 0, 0)
	self:EnableMouse(false)
	
	LS:RequestSpecialization()
	T.addon_msg("ver", "GROUP")
	
	C_Timer.After(1, function()
		RaidStatusCheckFrame.text:SetText(GetGroupNickNameInfo())
		self:GetNormalTexture():SetVertexColor(1, 1, 1)
		self:EnableMouse(true)
	end)
end)

RaidStatusCheckFrame.text = T.createtext(RaidStatusCheckFrame, "OVERLAY", 16, "OUTLINE", "LEFT")
RaidStatusCheckFrame.text:SetPoint("TOPLEFT", 20, 0)

RaidStatusCheckFrame.t = 15

RaidStatusCheckFrame:SetScript("OnUpdate", function(self, e)
	self.t = self.t + e
	if self.t > 15 then
		self.text:SetText(GetGroupNickNameInfo())
		self.t = 0
	end
end)

T.ToggleNicknameCheck = function()
	if JST_CDB["GeneralOption"]["nickname_check"] then
		T.RestoreDragFrame(RaidStatusCheckFrame)
		RaidStatusCheckFrame:Show()
	else
		T.ReleaseDragFrame(RaidStatusCheckFrame)
		RaidStatusCheckFrame:Hide()
	end
end
