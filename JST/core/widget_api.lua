local T, C, L, G = unpack(select(2, ...))

local addon_name = G.addon_name
local font = G.Font

local LGF = LibStub("LibGetFrame-1.0")
local LRC = LibStub("LibRangeCheck-3.0")

--====================================================--
--[[                 -- 公用功能 --                 ]]--
--====================================================--

-- 通过ID查找光环
do
	local function SpellIDPredicate(auraSpellIDToFind, _, _, _, _, _, _, _, _, _, _, _, spellID)
		return auraSpellIDToFind == spellID
	end
	
	function AuraUtil.FindAuraBySpellID(spellID, unit, filter)
		return AuraUtil.FindAura(SpellIDPredicate, unit, filter, spellID)
	end
end

-- 上标记
T.SetRaidTarget = function(unit, rm)
	if not JST_CDB["GeneralOption"]["disable_rmark"] then
		SetRaidTarget(unit, rm) -- 上标记
	end
end

T.GetSpellInfo = function(spellID)
  if not spellID then
    return nil
  end

  local spellInfo = C_Spell.GetSpellInfo(spellID)
  if spellInfo then
    return spellInfo.name, spellInfo.iconID, spellInfo.castTime
  end
end

T.GetUnitNameplate = function(unit)
	local f = LGF.GetUnitNameplate(unit)
	return f
end

T.GetUnitFrame = function(unit)
	local f = LGF.GetUnitFrame(unit)
	return f
end

-- 获取距离
T.GetRange = function(unit, checkVisible)
  return LRC:GetRange(unit, checkVisible)
end
--====================================================--
--[[                -- 首领和副本 --                ]]--
--====================================================--

-- 检查难度
local CheckDifficulty = function(ficon, v)
	if G.TestMod or not ficon then
		return true
	elseif not (string.find(ficon, "3") or string.find(ficon, "12")) then
		return true
	elseif string.find(ficon, "3") and v == 15 then
		return true
	elseif string.find(ficon, "12") and v == 16 then
		return true
	end
end
T.CheckDifficulty = CheckDifficulty

local IsBossEngaged = function(npcID)
	for i = 1, 5 do
		local GUID = UnitGUID("boss"..i)
		if GUID then
			local NPC_ID = select(6, strsplit("-", GUID))
			if NPC_ID == npcID then
				return true
			end
		end
	end
end

T.CheckEncounter = function(npcIDs, ficon)
	local difficultyID = select(3, GetInstanceInfo())
	if CheckDifficulty(ficon, difficultyID) then -- 难度符合
		for i, npcID in pairs(npcIDs) do
			if IsBossEngaged(npcID) then
				return true
			end
		end
	end
end

T.CheckDungeon = function(mapID)
	local map = select(8, GetInstanceInfo())
	if map == mapID then
		return true	
	end
end

local FlagRoles = {
	["0"] = "TANK",
	["1"] = "DAMAGER",
	["2"] = "HEALER",
}

T.CheckRole = function(ficon)	
	if not ficon or not JST_CDB["GeneralOption"]["role_enable"] then
		return true
	else
		local ficons = strsplittable(",", ficon)
		local str = ""
		for i, ficon in pairs(ficons) do
			if FlagRoles[ficon] then
				str = str..FlagRoles[ficon]..","
			end
		end
		if str == "" then
			return true	
		else
			local tree = GetSpecialization()
			if tree then
				local role = select(5, GetSpecializationInfo(tree))
				if string.find(str, role) then
					return true
				end
			end
		end		
	end
end

-- 首领名字
T.GetEncounterName = function(encounterID, InstanceID)
	if type(encounterID) == "number" then
		local name = EJ_GetEncounterInfo(encounterID)
		return name
	elseif InstanceID then
		local name = EJ_GetInstanceInfo(InstanceID)
		return name..L["杂兵"]
	else
		return L["杂兵"]
	end
end

-- 首领头像
T.GetEncounterTex = function(encounterID)
	if type(encounterID) == "number" then
		local tex = select(5, EJ_GetCreatureInfo(1, encounterID)) 
		return tex	
	else
		return [[Interface\EncounterJournal\UI-EJ-BOSS-Default]]
	end
end

-- 首领序号
T.GetBossUnit = function(bossGUID)
	local i = 1
	local GUID = UnitGUID("boss"..i)
	while GUID do		
		if GUID == bossGUID then
			return "boss"..i
		end
		i = i + 1
		GUID = UnitGUID("boss"..i)
	end
end
--====================================================--
--[[                  -- NPC功能 --                 ]]--
--====================================================--

-- 获取NPCID
T.GetUnitNpcID = function(unit)
	local GUID = UnitGUID(unit)
	if GUID then
		return select(6, strsplit("-", GUID))
	end
end

-- 获取NPC名字
local scanTooltip = CreateFrame("GameTooltip", "NPCNameToolTip", nil, "GameTooltipTemplate") --fake tooltipframe used for reading localized npc names -- by lunaic
T.GetNameFromNpcID = function(npcID)
	local name
	if JST_DB and JST_DB["NpcNames"][npcID] then
		name = JST_DB["NpcNames"][npcID]
	else
		scanTooltip:SetOwner(UIParent,"ANCHOR_NONE")
		scanTooltip:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0000000000", npcID))
		if scanTooltip:NumLines()>0 then
			name = NPCNameToolTipTextLeft1:GetText()
			scanTooltip:Hide()
			if name and JST_DB then
				JST_DB["NpcNames"][npcID] = name
			end
		end
	end
	
	if name then
		return name
	else
		T.msg(string.format(L["加载失败"], npcID))
		return "npc"..npcID	
	end
end

-- 获取NPC名字带文本格式
T.GetFomattedNameFromNpcID = function(npcID)
	local name = T.GetNameFromNpcID(npcID)
	return string.format("|cffFFFFFF[%s]|r", name)
end

--====================================================--
--[[                    -- 表格 --                  ]]--
--====================================================--

-- 是否在表内
T.IsInTable = function(t, v)
	for i, value in pairs(t) do
		if value == v then
			return true
		end
	end
end

-- 获取表内讯息
T.GetTableInfoByValue = function(t, k, v)
	for i, info in pairs(t) do
		if info[k] == v then
			return info
		end
	end
end

-- 获取下一个可用项
T.GetNextValueAvailable = function(t, t2)
	for i, name in pairs(t) do
		if not t2[name] then
			t2[name] = true
			return name
		end
	end
end

-- 表格子项目数量
T.GetTableNum = function(t)
	local num = 0
	for k, v in pairs(t) do
		num = num + 1
	end
	return num
end

-- 获取路径值
do
	local ValueFromPath
	ValueFromPath = function(data, path)
		if not data then
			return nil
		end
		if (#path == 0) then
			return data
		elseif(#path == 1) then
			return data[path[1]]
		else
			local reducedPath = {}
			for i= 2, #path do
				reducedPath[i-1] = path[i]
			end
			return ValueFromPath(data[path[1]], reducedPath)
		end
	end
	T.ValueFromPath = ValueFromPath
end

-- 路径赋值
do
	local ValueToPath
	function ValueToPath(data, path, value)
		if not data then
			return
		end
		if(#path == 1) then
			data[path[1]] = value
		else
			local reducedPath = {}
			for i= 2, #path do
				reducedPath[i-1] = path[i]
			end
			if data[path[1]] == nil then
				data[path[1]] = {}
			end
			ValueToPath(data[path[1]], reducedPath, value)
		end
	end
	T.ValueToPath = ValueToPath
end

-- 复制并插入表格
T.CopyTableInsertElement = function(copy_t, new_element)
	local target_t = {}
	for k, v in pairs(copy_t) do
		target_t[k] = v
	end
	table.insert(target_t, new_element)
	return target_t
end

--====================================================--
--[[                 -- 音效/朗读 --                ]]--
--====================================================--

-- 获取语音包路径
T.apply_sound_pack = function()
	local var = JST_CDB["GeneralOption"]["sound_pack"]
	local info = T.GetTableInfoByValue(G.SoundPacks, 1, var)
	if info then
		JST_CDB["GeneralOption"]["sound_file"] = info[3]
	else
		T.msg(string.format(L["语音包缺失"], var))
	end
end

-- 播放音效
T.PlaySound = function(sound, sound2)
	if not sound then return end
	if JST_CDB["GeneralOption"]["disable_sound"] then return end
	if JST_CDB["GeneralOption"]["sound_channel"] == "Master" then
		PlaySoundFile(JST_CDB["GeneralOption"]["sound_file"]..sound..".ogg", "Master")
	elseif JST_CDB["GeneralOption"]["sound_channel"] == "Dialog" then
		PlaySoundFile(JST_CDB["GeneralOption"]["sound_file"]..sound..".ogg", "Dialog")
	else -- SFX
		PlaySoundFile(JST_CDB["GeneralOption"]["sound_file"]..sound..".ogg")
	end
	if sound2 then
		C_Timer.After(1, function()
			if JST_CDB["GeneralOption"]["sound_channel"] == "Master" then
				PlaySoundFile(JST_CDB["GeneralOption"]["sound_file"]..sound2..".ogg", "Master")
			elseif JST_CDB["GeneralOption"]["sound_channel"] == "Dialog" then
				PlaySoundFile(JST_CDB["GeneralOption"]["sound_file"]..sound2..".ogg", "Dialog")
			else -- SFX
				PlaySoundFile(JST_CDB["GeneralOption"]["sound_file"]..sound2..".ogg")
			end
		end)
	end
end

-- 倒数
T.CountDown = function(number)
	for i = number, 1, -1 do
		C_Timer.After(number-i, function()
			T.PlaySound("count\\"..i)
		end)
	end
end

-- 朗读
T.SpeakText = function(script)
	if JST_CDB["GeneralOption"]["disable_sound"] then return end
	C_VoiceChat.StopSpeakingText()
	C_Timer.After(.1, function() C_VoiceChat.SpeakText(JST_CDB["GeneralOption"]["tts_speaker"], script, 1, 0, JST_CDB["GeneralOption"]["tl_sound_volume"]) end)
end
--====================================================--
--[[                 -- 消息/喊话 --                ]]--
--====================================================--

-- 发消息
T.SendChatMsg = function(msg, rp, channel)
	if not JST_CDB["GeneralOption"]["disbale_msg"] then
		if rp then
			local ticker = C_Timer.NewTicker(1, function(self)
				local remain = rp - floor(GetTime() - self.start) + 1
				local msg_rp = gsub(msg, "%%dur", remain)
				SendChatMessage(msg_rp.."..", channel or "SAY")
			end, rp)
			ticker.start = GetTime()
		else
			SendChatMessage(msg.."..", channel or "SAY")
		end
	end
end

-- 发消息（光环讯息）
T.SendAuraMsg = function(str, channel, spell, stack, dur, tag)
	local msg
	msg = gsub(str, "%%name", G.PlayerName)
	if spell then
		msg = gsub(msg, "%%spell", spell)
	end
	if stack then
		msg = gsub(msg, "%%stack", stack)
	end
	if dur then
		msg = gsub(msg, "%%dur", function(a) return ceil(dur) end)
	end
	if tag then
		msg = gsub(msg, "%%tag", tag)
	end
	T.SendChatMsg(msg, nil, channel or "SAY")
end

--====================================================--
--[[                 -- 颜色处理 --                 ]]--
--====================================================--

-- 插件主题色
T.color_text = function(text)
	return string.format(G.addon_colorStr.."%s|r", text)
end

-- 染色
T.hex_str = function(str, color)
	local r, g, b = unpack(color)
	return ('|cff%02x%02x%02x%s|r'):format(r * 255, g * 255, b * 255, str)
end

T.ColorByProgress = function(value, gre)
	local v
	v = min(value, 1)
	v = max(0, v)
	
	local r, g, b = 1, 1, 1
	if gre then-- 1 绿 .5 黄 0 红
		if v >= .5 then
			r = (1 - v)*2
			g = 1
			b = 0
		else
			r = 1
			g = v*2
			b = 0
		end
	else -- 1 红 .5 黄 0 绿
		if v >= .5 then
			r = 1
			g = (1-v)*2
			b = 0
		else										
			r = v*2
			g = 2
			b = 0	
		end
	end
	return r, g, b
end

--====================================================--
--[[                 -- 文本处理 --                 ]]--
--====================================================--

-- 聊天框提示（一般讯息）
T.msg = function(...)
	local msg = strjoin(" ", ...)
	print(G.addon_colorStr.."JST|r> "..msg)
end

-- 聊天框提示（测试讯息）
T.test_msg = function(...)
	if G.TestMod then
		local msg = strjoin(" ", ...)
		print(G.addon_colorStr.."JST TEST|r> "..msg)
	end
end

local SendAddonMessageResult = {
	--[0] = "成功 Success",
	[1] = "发送插件讯息失败，前缀无效 Invalid Prefix",
	[2] = "发送插件讯息失败，讯息无效 Invalid Message",
	[3] = "发送插件讯息失败，插件讯息受限 Addon Message Throttle",	
	[4] = "发送插件讯息失败，聊天类型无效 Invalid ChatType",
	[5] = "发送插件讯息失败，不在队伍中 Not In Group",
	[6] = "发送插件讯息失败，需要接收目标 Target Required",	
	[7] = "发送插件讯息失败，频道无效 Invalid channel",
	[8] = "发送插件讯息失败，频道受限 channel Throttle",
	[9] = "发送插件讯息失败，其他错误 General Error",	
}

local GetChannel = function(str)
	local CHANNEL
	if IsInGroup() and str == "GROUP" then		
		CHANNEL = (IsInRaid(1) and "RAID") or (IsInGroup(1) and "PARTY") or (IsInGroup(2) and "INSTANCE_CHAT")
	elseif IsInRaid() and str == "RAID" then
		CHANNEL = (IsInRaid(1) and "RAID") or (IsInRaid(2) and "INSTANCE_CHAT")
	elseif IsInGroup() and str == "PARTY" then
		CHANNEL = (IsInGroup(1) and "PARTY") or (IsInGroup(2) and "INSTANCE_CHAT") 
	elseif str == "WHISPER" then
		CHANNEL = str
	end
	return CHANNEL
end

-- 插件消息
T.addon_msg = function(msg, channel, whisper_tar)
	if whisper_tar then
		local succeed, reason = C_ChatInfo.SendAddonMessage("jstpaopao", msg, "WHISPER", whisper_tar)
		if reason and SendAddonMessageResult[reason] then
			T.test_msg(SendAddonMessageResult[reason].." "..msg.." "..whisper_tar)
		end
	else
		local CHANNEL = GetChannel(channel)
		if CHANNEL then
			local succeed, reason = C_ChatInfo.SendAddonMessage("jstpaopao", msg, CHANNEL)
			if reason and SendAddonMessageResult[reason] then
				T.test_msg(SendAddonMessageResult[reason].." "..msg)
			end
		end
	end
end

-- 时间格式
local day, hour, minute = 86400, 3600, 60
T.FormatTime = function(s, v)
    if v then
		return format("%.1f", s)
	elseif s >= day then
        return format("%dd", floor(s/day + 0.5))
    elseif s >= hour then
        return format("%dh", floor(s/hour + 0.5))
    elseif s >= minute then
        return format("%dm", floor(s/minute + 0.5))
	elseif s >= 2 then
		return format("%d", s)
	else
		return format("%.1f", s)
    end
end

-- 内存格式
T.memFormat = function(num)
	if num > 1024 then
		return format("%.2f mb", (num / 1024))
	else
		return format("%.1f kb", floor(num))
	end
end

-- 数值缩短
T.ShortValue = function(val)
	if type(val) == "number" then
		if G.Client == "zhCN" or G.Client == "zhTW" then
			if (val >= 1e7) then
				return ("%.1fkw"):format(val / 1e7)
			elseif (val >= 1e4) then
				return ("%.1fw"):format(val / 1e4)
			else
				return ("%d"):format(val)
			end
		else
			if (val >= 1e6) then
				return ("%.1fm"):format(val / 1e6)
			elseif (val >= 1e3) then
				return ("%.1fk"):format(val / 1e3)
			else
				return ("%d"):format(val)
			end
		end
	else
		return val
	end
end

-- 团队标记
T.FormatRaidMark = function(text)
	if type(text) == "number" then
		return string.format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t", text)
	else
		local marks = strsplittable(",", text)
		local result = ""
		for _, mark in pairs(marks) do
			result = result..string.format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%s:0|t", mark)
		end
		return result
	end
end

-- 法术图标
T.GetSpellIcon = function(spellID)
	if not T.GetSpellInfo(spellID) then
		T.msg(spellID.."出错 请检查")
		return ""
	end
	local name, icon = T.GetSpellInfo(spellID)
	return "|T"..icon..":12:12:0:0:64:64:4:60:4:60|t"
end

-- 法术图标和链接
T.GetIconLink = function(spellID)
	if not T.GetSpellInfo(spellID) then
		T.msg(spellID.."出错 请检查")
		return ""
	end
	local name, icon = T.GetSpellInfo(spellID)
	return (icon and "|T"..icon..":12:12:0:0:64:64:4:60:4:60|t" or "").."|cff71d5ff["..name.."]|r"
end

-- 材质转文本
T.GetTextureStr = function(tex)
	return "|T"..tex..":12:12:0:0:64:64:4:60:4:60|t"
end

-- 喊话转文本
T.MsgtoStr = function(text)
	local result = gsub(text, "{rt(%d)}", function(e) return string.format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t", e) end)
	return result
end

-- 喊话转朗读文本
local RTScriptList = { "星星","大饼","紫菱","三角","月亮","方块","叉叉","骷髅",}
T.MsgtoScript = function(text)
	local result = gsub(text, "{rt(%d)}", function(e) return RTScriptList[tonumber(e)] end)
	return result
end

-- 打断模板
T.GetInterruptStr = function(mobID, spellID, rt, interrupt)
	local mobs = {string.split(",", mobID)}
	local result = ""
	for ind, npcID in pairs(mobs) do
		local spell = T.GetSpellInfo(spellID)
		local npcName = T.GetNameFromNpcID(npcID)
		local title = string.format(L["打断模板"], npcName, spell)
		local str = string.format("#%s-%d-%d-%s", title, npcID, interrupt, rt)..strrep("( )", interrupt)
		if ind == 1 then
			result = result..str
		else
			result = result.."\n"..str
		end
	end
	return result
end
--====================================================--
--[[               -- 地下城手册标记 --             ]]--
--====================================================--

-- 小标记
local filtermarks = {
	[3] = true,
	[12] = true,
}

-- 序号转字串
--EncounterJournal_SetFlagIcon
T.GetFlagIconStr = function(ficon, filter)
	local str = ""
	if ficon then 
		local marks = {string.split(",", ficon)}
		for i, mark in pairs(marks) do
			local index = tonumber(mark)
			if not filter or not filtermarks[index] then
				local iconSize = 32
				local columns = 256/iconSize -- 8
				local rows = 64/iconSize -- 2
				local l = mod(index, columns)*iconSize+8
				local r = l+iconSize-14
				local t = floor(index/columns)*iconSize+8
				local b = t+iconSize-14
				
				local icon = string.format("|TInterface\\EncounterJournal\\UI-EJ-Icons:0:0:0:0:256:64:%d:%d:%d:%d|t", l, r, t, b)
				str = str..icon
			end
		end
	end
	return str
end

-- 序号转文字
T.CreateFlagIconText = function(parent, size, ficon, anchor, filter, ...)
	local text = T.createtext(parent, "OVERLAY", size, "OUTLINE", anchor)
	text:SetPoint(...)
	text:SetText(T.GetFlagIconStr(ficon, filter))
end

-- 图标材质
T.EncounterJournal_SetFlagIcon = function(texture, index)
	if index == 0 then
		texture:Hide()
	else
		local iconSize = 32
		local columns = 256/iconSize
		local rows = 64/iconSize
		local l = mod(index, columns) / columns
		local r = l + (1/columns)
		local t = floor(index/columns) / rows
		local b = t + (1/rows)
		texture:SetTexCoord(l, r, t, b)
		texture:Show()
	end
end

--====================================================--
--[[                  -- 外观功能 --                ]]--
--====================================================--
-- 边框
T.createborder = function(f, r, g, b, a)
	if f.style then return end
	
	f.sd = CreateFrame("Frame", nil, f, "BackdropTemplate")
	local lvl = f:GetFrameLevel()
	f.sd:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
	f.sd:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\AddOns\\JST\\media\\glow",
		edgeSize = 3,
		insets = { left = 3, right = 3, top = 3, bottom = 3,}
	})
	f.sd:SetPoint("TOPLEFT", f, -3, 3)
	f.sd:SetPoint("BOTTOMRIGHT", f, 3, -3)
	if not (r and g and b) then
		f.sd:SetBackdropColor(.05, .05, .05, .7)
		f.sd:SetBackdropBorderColor(0, 0, 0)
	else
		f.sd:SetBackdropColor(r, g, b, a)
		f.sd:SetBackdropBorderColor(0, 0, 0)
	end
	f.style = true
end

-- 边框框体
T.createbdframe = function(f)
	local bg
	
	if f:GetObjectType() == "Texture" then
		bg = CreateFrame("Frame", nil, f:GetParent(), "BackdropTemplate")
		local lvl = f:GetParent():GetFrameLevel()
		bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
	else
		bg = CreateFrame("Frame", nil, f, "BackdropTemplate")
		local lvl = f:GetFrameLevel()
		bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
	end
	
	bg:SetPoint("TOPLEFT", f, -3, 3)
	bg:SetPoint("BOTTOMRIGHT", f, 3, -3)
	
	bg:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\AddOns\\JST\\media\\glow",
		edgeSize = 3,
			insets = { left = 3, right = 3, top = 3, bottom = 3,}
		})
		
	bg:SetBackdropColor(.05, .05, .05, .5)
	bg:SetBackdropBorderColor(0, 0, 0)
	
	return bg
end

T.createGUIbd = function(f, a)
	f.sd = CreateFrame("Frame", nil, f, "BackdropTemplate")
	
	local lvl = f:GetFrameLevel()
	f.sd:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
	f.sd:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 12,
		insets = { left = 3, right = 3, top = 2, bottom = 3 }
	})
	f.sd:SetPoint("TOPLEFT", f, -3, 3)
	f.sd:SetPoint("BOTTOMRIGHT", f, 3, -3)
	
	f.sd:SetBackdropColor(.12, .12, .12, a or 0.8)
	f.sd:SetBackdropBorderColor(.5, .5, .5)
end

-- 彩色边框
local hl_colors = {
	["red"] = {1, 0, 0},
	["gre"] = {0, 1, 0},
	["blu"] = {0, 1, 1},
	["pur"] = {.6, 0, 1},
	["org"] = {1, .5, 0},
	["yel"] = {1, 1, 0},
}

-- 图标粗边框
T.SetHighLightBorderColor = function(frame, anchor, color)	
	frame.glow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	frame.glow:SetFrameLevel(frame:GetFrameLevel()+1)
	frame.glow:SetAllPoints(anchor)
	frame.glow:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 5,
		insets = { left = 5, right = 5, top = 5, bottom = 5}
	})
	frame.glow:SetBackdropColor(0, 0, 0, 0)
	
	if type(color) == "table" then
		frame.glow:SetBackdropBorderColor(unpack(color))
	else
		local color_key = gsub(color, "_flash", "")
		frame.glow:SetBackdropBorderColor(unpack(hl_colors[color_key]))
	end
end

-- 文本
T.createtext = function(frame, layer, fontsize, flag, justifyh)
	local text = frame:CreateFontString(nil, layer)
	text:SetFont(font, fontsize, flag)
	text:SetJustifyH(justifyh or "CENTER")
	return text
end