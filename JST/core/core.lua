local T, C, L, G = unpack(select(2, ...))

local addon_name = G.addon_name
local LCG = LibStub("LibCustomGlow-1.0")

G.TestMod = false
G.TestBossModFrames = {
	--[412761] = true,
}

----------------------------------------------------------
-----------------[[    Frame Holder    ]]-----------------
----------------------------------------------------------
local FrameHolder = CreateFrame("Frame", addon_name.."FrameHolder", UIParent)

local update_rate = .05
local tl_update_rate = .5

T.UpdateAll = function()
	if JST_CDB["GeneralOption"]["disable_all"] then
		FrameHolder:Hide()
	else
		FrameHolder:Show()
	end
	-- update
	T.EditAlertFrame("all") -- ROLE
	T.EditTimerbarFrame("all") -- ROLE
	T.EditTextFrame("all") -- ROLE
	T.EditPlateIcons("all")
	T.EditSoundAlert("all")
	T.EditRFIconAlert("all")
	T.EditBossModsFrame("all") -- ROLE
	T.EditRMFrame("all") -- X
	T.EditTimeline("all") -- X
	T.EditASFrame("all") -- X
	T.EditRaidPAFrame("all") -- X
end

----------------------------------------------------------
----------------------[[    API    ]]---------------------
----------------------------------------------------------

local function CheckConditions(self, register_events, args, event, ...)
	if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" then
		if args.points and G.TestMod and G.TestBossModFrames[args.spellID] then -- 测试
			if not args.points.hide then
				self:Show()
			end
			T.RegisterEventAndCallbacks(self, register_events)
		else		
			if self.enable and T.CheckRole(args.ficon) then
				if self.npcID and T.CheckEncounter(self.npcID, args.ficon) then
					T.RegisterEventAndCallbacks(self, register_events)
					if args.points and not args.points.hide then
						self:Show()
					end
				elseif self.mapID then
					if T.CheckDungeon(self.mapID) then
						T.RegisterEventAndCallbacks(self, register_events)
						if args.points and not args.points.hide then
							self:Show()
						end
					else
						T.UnregisterEventAndCallbacks(self, register_events)
						self:reset()
					end
				end
			else
				T.UnregisterEventAndCallbacks(self, register_events)
				self:reset()
			end
		end
	elseif event == "ENCOUNTER_START" then -- 进入战斗
		local encounterID, _, difficultyID = ...
		if self.enable and self.engageID and encounterID == self.engageID and T.CheckDifficulty(args.ficon, difficultyID) and T.CheckRole(args.ficon) then
			T.RegisterEventAndCallbacks(self, register_events)
			if args.points and not args.points.hide then
				self:Show()
			end
			if self.init_update then
				self:init_update(event, ...)
			end
		end
	elseif event == "ENCOUNTER_END" then -- 脱离战斗
		local encounterID = ...
		if self.enable and self.engageID and encounterID == self.engageID and T.CheckRole(args.ficon) then
			T.UnregisterEventAndCallbacks(self, register_events)
			self:reset(event)
		end
	end
end

local CastEvents = {
	["UNIT_SPELLCAST_START"] = true,
	["UNIT_SPELLCAST_STOP"] = true,
	["UNIT_SPELLCAST_CHANNEL_START"] = true,
	["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
	["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
	["UNIT_SPELLCAST_SUCCEEDED"] = true,
	["ENCOUNTER_PHASE"] = true,
}

local FilterCastbarUnits = function(unit)
	if string.match(unit, "boss%d+") or string.match(unit, "nameplate%d+") or G.TestMod then
		return true
	end
end

local FilterCastSpellID = function(spellID, args)
	if spellID == args.spellID or (args.spellIDs and args.spellIDs[spellID]) then
		return true
	end
end

local function MySpellCheck(spellID)
	if not IsSpellKnownOrOverridesKnown(spellID) then
		return
	end
	local charges = C_Spell.GetSpellCharges(spellID)	
	if charges and charges.currentCharges > 0 then
		return true
	else
		local cd_info = C_Spell.GetSpellCooldown(spellID)
		local start, dur = cd_info.startTime, cd_info.duration
		if start and dur < 2 then
			return true
		end
	end
end

local function MyItemCheck(itemID)
	local itemType = select(6, C_Item.GetItemInfoInstant(itemID))
	if itemType == 2 or itemType == 4 then -- 武器或护甲
		if IsEquippedItem(itemID) then
			local start, duration, enable = GetItemCooldown(itemID)
			if enable == 1 and start and duration < 2 then
				return true
			end
		end
	elseif itemType == 0 then -- 消耗品
		if GetItemCount(itemID) > 0 then
			local start, duration, enable = GetItemCooldown(itemID)
			if enable == 1 and start and duration < 2 then
				return true
			end
		end
	end
end

----------------------------------------------------------
------------------[[    转阶段监控    ]]------------------
----------------------------------------------------------
local PhaseTigger = CreateFrame("Frame", nil, FrameHolder)
PhaseTigger:RegisterEvent("ENCOUNTER_START")
PhaseTigger:RegisterEvent("ENCOUNTER_END")
PhaseTigger:RegisterEvent("ADDON_LOADED")

local current_engageID = 0 -- 当前首领战斗
local phase_data = {} -- 所有首领的转阶段数据

local current_phase = 0
local current_phase_data = {} -- 当前战斗的转阶段计数
local engaged_npc = {} -- 转阶段监控：记录BOSS加入战斗
local spell_count = {} -- 转阶段监控：记录技能次数
local spell_source_byGUID = {} -- 转阶段监控：记录技能来源
local spell_source_byIndex = {} -- 转阶段监控：记录技能来源

function PhaseTigger:outputMsg()
	if G.Timeline.time_offset == 0 then
		T.msg(string.format(L["阶段转换"].." P%s %s", current_phase, date("%M:%S", G.Timeline.passed)))
	else
		T.msg(string.format(L["阶段转换"].." P%s %s ["..L["运行时间"].." %s]", current_phase, date("%M:%S", G.Timeline.passed), date("%M:%S", G.Timeline.fake_passed)))
	end
end
					
PhaseTigger:SetScript("OnEvent", function(self, event, ...)
	if event == "ENCOUNTER_START" then
		local engageID = ...
		current_phase = 1
		
		if phase_data[engageID] then
			current_engageID = engageID
			if phase_data[engageID].CLEU then
				self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
				for i, data in pairs(phase_data[engageID].CLEU) do
					current_phase_data[data.phase] = 0
				end
			end
			if phase_data[engageID].UNIT then
				self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
				for i, data in pairs(phase_data[engageID].UNIT) do
					current_phase_data[data.phase] = 0
				end
			end
		end
		
	elseif event == "ENCOUNTER_END" then
		current_engageID = 0
		current_phase = 0
		
		engaged_npc = table.wipe(engaged_npc)
		spell_count = table.wipe(spell_count)
		spell_source_byGUID = table.wipe(spell_source_byGUID)
		spell_source_byIndex = table.wipe(spell_source_byIndex)
		current_phase_data = table.wipe(current_phase_data)
		
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
		
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then		
		local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		for i, data in pairs(phase_data[current_engageID].CLEU) do
			if sub_event == data.sub_event and data.spellID == spellID and data.count then
				-- 记录次数
				if not spell_count[spellID] then
					spell_count[spellID] = 1
				else
					spell_count[spellID] = spell_count[spellID] + 1
				end
				break
			end
		end
		for i, data in pairs(phase_data[current_engageID].CLEU) do
			if sub_event == data.sub_event and data.spellID == spellID and data.source then
				-- 记录来源
				if not spell_source_byGUID[spellID] then
					spell_source_byGUID[spellID] = {}
				end
				if not spell_source_byIndex[spellID] then
					spell_source_byIndex[spellID] = {}
				end
				if not spell_source_byGUID[spellID][sourceGUID] then
					spell_source_byGUID[spellID][sourceGUID] = true
					table.insert(spell_source_byIndex[spellID], sourceGUID)
				end
				break
			end
		end
		for i, data in pairs(phase_data[current_engageID].CLEU) do
			if sub_event == data.sub_event and data.spellID == spellID then
				if data.source then
					if #spell_source_byIndex[spellID] == data.source and current_phase ~= data.phase then
						current_phase = data.phase
						current_phase_data[current_phase] = current_phase_data[current_phase] + 1
						T.FireEvent("ENCOUNTER_PHASE", current_phase, current_phase_data[current_phase])
						self:outputMsg()
					end
					
				elseif data.count then
					if spell_count[spellID] == data.count then
						current_phase = data.phase
						current_phase_data[current_phase] = current_phase_data[current_phase] + 1
						T.FireEvent("ENCOUNTER_PHASE", current_phase, current_phase_data[current_phase])
						self:outputMsg()
					end
				else
					current_phase = data.phase
					current_phase_data[current_phase] = current_phase_data[current_phase] + 1
					T.FireEvent("ENCOUNTER_PHASE", current_phase, current_phase_data[current_phase])
					self:outputMsg()
				end
			end
		end
	elseif event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
		local boss_index = 1
		local GUID = UnitGUID("boss"..boss_index)
		while GUID do
			local NPC_ID = select(6, strsplit("-", GUID))
			if not engaged_npc[NPC_ID] then -- 有新的NPC加入战斗
				engaged_npc[NPC_ID] = true
				for i, data in pairs(phase_data[current_engageID].UNIT) do
					if data.npcID == NPC_ID then
						current_phase = data.phase
						current_phase_data[current_phase] = current_phase_data[current_phase] + 1
						T.FireEvent("ENCOUNTER_PHASE", current_phase, current_phase_data[current_phase])
						self:outputMsg()
					end
				end
			end
			boss_index = boss_index + 1
			GUID = UnitGUID("boss"..boss_index)
		end
	elseif event == "ADDON_LOADED" then
		local addon = ...
		if C_AddOns.GetAddOnMetadata(addon, "X-JST-journalInstanceID") then
			for ENCID, data in pairs(G.Encounters) do
				if type(ENCID) == "number" and not phase_data[data.engage_id] then -- 只针对首领战斗
					for _, section_data in pairs(data.alerts) do
						if section_data.title and section_data.title == L["阶段转换"] then
							phase_data[data.engage_id] = {}
							for _, args in pairs(section_data.options) do
								if not phase_data[data.engage_id][args.type] then
									phase_data[data.engage_id][args.type] = {}
								end
								if args.type == "CLEU" then
									table.insert(phase_data[data.engage_id][args.type], {
										phase = args.phase,
										sub_event = args.sub_event,
										spellID = args.spellID,
										count = args.count,
										source = args.source,
									})
								elseif args.type == "UNIT" then
									table.insert(phase_data[data.engage_id][args.type], {
										phase = args.phase,
										npcID = args.npcID,
									})
								end	
							end
							break
						end
					end
				end
			end
		end
	end
end)

T.GetCurrentPhase = function()
	return current_phase
end

T.CreatePhase = function(ENCID, option_page, category, args)				
	T.Create_Phase_Options(option_page, category, args)
end

----------------------------------------------------------
-------------------[[    图标提示    ]]-------------------
----------------------------------------------------------
local IconFrames = {}

G.IconFrames = IconFrames

local AlertFrame = CreateFrame("Frame", addon_name.."AlertFrame", FrameHolder)
AlertFrame:SetSize(70,70)
AlertFrame.ActiveIcons = {}

AlertFrame.movingname = L["图标提示"]
AlertFrame.point = { a1 = "BOTTOMRIGHT", a2 = "CENTER", x = -300, y = 90}
T.CreateDragFrame(AlertFrame)

function AlertFrame:PreviewShow()
	IconFrames["test_426010"]:update()
	IconFrames["test_425093"]:update()
	IconFrames["test_200580"]:update()
end

function AlertFrame:PreviewHide()
	IconFrames["test_426010"]:reset()
	IconFrames["test_425093"]:reset()
	IconFrames["test_200580"]:reset()
end
	
local AlertFrame2 = CreateFrame("Frame", addon_name.."AlertFrame2", FrameHolder)
AlertFrame2:SetSize(70,70)
AlertFrame2.ActiveIcons = {}

AlertFrame2.movingname = L["图标提示2"]
AlertFrame2.point = { a1 = "BOTTOMRIGHT", a2 = "CENTER", x = -300, y = 0}
T.CreateDragFrame(AlertFrame2)

local AlertFrame3 = CreateFrame("Frame", addon_name.."AlertFrame3", FrameHolder)
AlertFrame3:SetSize(70,70)

AlertFrame3.movingname = L["PA图标提示"]
AlertFrame3.point = { a1 = "BOTTOMRIGHT", a2 = "CENTER", x = -300, y = -90}
T.CreateDragFrame(AlertFrame3)

local LineUpAlertIcons = function(arg)
	local lastframe
	local parent = (arg == 1 and AlertFrame) or AlertFrame2
	
	local grow_dir = JST_CDB["IconAlertOption"]["grow_dir"]
	local space = JST_CDB["IconAlertOption"]["icon_space"]
	local font_space = JST_CDB["IconAlertOption"]["font_size"]
	
	for frame_key, frame in pairs(parent.ActiveIcons) do
		frame:ClearAllPoints()
		if not lastframe then
			frame:SetPoint(grow_dir, parent, grow_dir)
		elseif grow_dir == "BOTTOM" then
			frame:SetPoint(grow_dir, lastframe, "TOP", 0, space+font_space)
		elseif grow_dir == "TOP" then
			frame:SetPoint(grow_dir, lastframe, "BOTTOM", 0, -space-font_space)
		elseif grow_dir == "LEFT" then
			frame:SetPoint(grow_dir, lastframe, "RIGHT", space, 0)
		elseif grow_dir == "RIGHT" then
			frame:SetPoint(grow_dir, lastframe, "LEFT", -space, 0)	
		end
		lastframe = frame
	end
end

local LineUpPAAlertIcons = function() -- 私人光环
	local lastframe
	
	local grow_dir = JST_CDB["IconAlertOption"]["grow_dir"]
	local space = JST_CDB["IconAlertOption"]["icon_space"]
	local font_space = JST_CDB["IconAlertOption"]["font_size"]

	for i = 1, 4 do
		local frame = IconFrames["private_aura"..i]
		frame:ClearAllPoints()
		if not lastframe then
			frame:SetPoint(grow_dir, AlertFrame3, grow_dir)
		elseif grow_dir == "BOTTOM" then
			frame:SetPoint(grow_dir, lastframe, "TOP", 0, space+font_space)
		elseif grow_dir == "TOP" then
			frame:SetPoint(grow_dir, lastframe, "BOTTOM", 0, -space-font_space)
		elseif grow_dir == "LEFT" then
			frame:SetPoint(grow_dir, lastframe, "RIGHT", space, 0)
		elseif grow_dir == "RIGHT" then
			frame:SetPoint(grow_dir, lastframe, "LEFT", -space, 0)
		end
		lastframe = frame
	end
end

local QueueAlertIcon = function(frame, arg)
	local parent = (arg == 1 and AlertFrame) or AlertFrame2
	
	frame:HookScript("OnShow", function(self)
		parent.ActiveIcons[self.frame_key] = self
		LineUpAlertIcons(arg)		
	end)
	
	frame:HookScript("OnHide", function(self)
		parent.ActiveIcons[self.frame_key] = nil
		LineUpAlertIcons(arg)
	end)
end

T.EditAlertFrame = function(option)
	if option == "all" or option == "enable" then
		if JST_CDB["IconAlertOption"]["enable_pa"] then		
			T.RestoreDragFrame(AlertFrame3)
			AlertFrame3:Show()
		else
			T.ReleaseDragFrame(AlertFrame3)
			AlertFrame3:Hide()
		end
	end
	if option == "all" or option == "icon_size" then
		AlertFrame:SetSize(JST_CDB["IconAlertOption"]["icon_size"], JST_CDB["IconAlertOption"]["icon_size"])
		AlertFrame2:SetSize(JST_CDB["IconAlertOption"]["icon_size"], JST_CDB["IconAlertOption"]["icon_size"])
		AlertFrame3:SetSize(JST_CDB["IconAlertOption"]["privateaura_icon_size"], JST_CDB["IconAlertOption"]["privateaura_icon_size"])
	end
	if option == "all" or option == "alpha" then
		AlertFrame3:SetAlpha(JST_CDB["IconAlertOption"]["privateaura_icon_alpha"])
	end
	if option == "all" or option == "grow_dir" then
		LineUpAlertIcons(1)
		LineUpAlertIcons(2)
		LineUpPAAlertIcons()
	end
	for _, frame in pairs(IconFrames) do
		frame:update_onedit(option)
	end
end

-- 编辑图标
local EditAlertIcon = function(frame, path, option)
	if option == "all" or option == "enable" then
		if path then
			frame.enable = T.ValueFromPath(JST_CDB, path)["enable"]
			if frame.engageID then
				if frame.enable then
					frame:RegisterEvent("ENCOUNTER_START")
					frame:RegisterEvent("ENCOUNTER_END")
				else
					frame:UnregisterEvent("ENCOUNTER_START")
					frame:UnregisterEvent("ENCOUNTER_END")
				end
			elseif frame.mapID then
				if frame.enable then
					frame:RegisterEvent("PLAYER_ENTERING_WORLD")
				else
					frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
				end
			end
			frame:GetScript("OnEvent")(frame, "OPTION_EDIT")
		end
	end
	
	if option == "all" or option == "icon_size" then
		frame:SetSize(JST_CDB["IconAlertOption"]["icon_size"], JST_CDB["IconAlertOption"]["icon_size"])
	end
	
	if option == "all" or option == "font_size" then
		frame.text:SetFont(G.Font, JST_CDB["IconAlertOption"]["font_size"], "OUTLINE")
		frame.brtext:SetFont(G.Font, JST_CDB["IconAlertOption"]["font_size"], "OUTLINE")
		frame.brtext:SetHeight(JST_CDB["IconAlertOption"]["font_size"])
	end
	
	if option == "all" or option == "ifont_size" then
		frame.toptext:SetFont(G.Font, JST_CDB["IconAlertOption"]["ifont_size"], "OUTLINE")
		frame.toptext:SetHeight(JST_CDB["IconAlertOption"]["ifont_size"])
		frame.text2:SetFont(G.Font, JST_CDB["IconAlertOption"]["ifont_size"], "OUTLINE")
	end
			
	if option == "all" or option == "spelldur" then
		if JST_CDB["IconAlertOption"]["show_spelldur"] then
			frame.text:Show()
		else
			frame.text:Hide()
		end
	end
end

-- 创建图标
local CreateAlertIcon = function(frame_key, ENCID, arg, args, path)
	if IconFrames[frame_key] then return IconFrames[frame_key] end
	
	local parent = (arg == 1 and AlertFrame) or AlertFrame2
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(70,70)
	frame:Hide()
	
	T.createborder(frame)
	
	if ENCID then
		if type(ENCID) == "number" then -- 只针对首领战斗
			frame.npcID = G.Encounters[ENCID]["npc_id"]
			frame.engageID = G.Encounters[ENCID]["engage_id"]
		elseif string.find(ENCID, "Trash") then
			frame.mapID = G.Encounters[ENCID]["map_id"]
		end
	end
	
	frame.frame_key = frame_key	
	frame.t = 0
	
	-- 冷却转圈
	frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
	frame.cooldown:SetAllPoints()
	frame.cooldown:SetDrawEdge(false)
	frame.cooldown:SetFrameLevel(frame:GetFrameLevel())
	frame.cooldown:SetHideCountdownNumbers(true)
	frame.cooldown:SetReverse(true)
	
	-- 粗边框
	if args.hl and args.hl ~= "" then
		T.SetHighLightBorderColor(frame, frame, args.hl)
		-- 粗边框闪烁动画
		if string.find(args.hl, "flash") then
			frame.anim = frame:CreateAnimationGroup()
			frame.anim:SetLooping("BOUNCE")
			
			frame.anim:SetScript("OnStop", function(self)
				frame.glow:SetAlpha(1)
			end)
			
			frame.timer = frame.anim:CreateAnimation("Alpha")
			frame.timer:SetChildKey("glow")
			frame.timer:SetDuration(.3)
			frame.timer:SetFromAlpha(1)
			frame.timer:SetToAlpha(.2)
		end	
	end
	
	local spellName, spellIcon = T.GetSpellInfo(args.spellID)
	
	-- 图标材质
	frame.texture = frame:CreateTexture(nil, "BORDER", nil, 1)
	frame.texture:SetTexCoord( .1, .9, .1, .9)
	frame.texture:SetAllPoints()
	frame.texture:SetTexture(spellIcon)
	
	-- 表层框架
	frame.cover = CreateFrame("Frame", nil, frame)
	frame.cover:SetFrameLevel(frame:GetFrameLevel()+5)
	frame.cover:SetAllPoints(frame)

	frame.toptext = T.createtext(frame.cover, "OVERLAY", 12, "OUTLINE", "CENTER") -- 技能名字
	frame.toptext:SetPoint("TOPLEFT", frame.cover, "TOPLEFT", -7, -7)
	frame.toptext:SetPoint("TOPRIGHT", frame.cover, "TOPRIGHT", 7, -7)
	frame.toptext:SetHeight(12)	
	frame.toptext:SetTextColor(1, 1, 0)
	frame.toptext:SetText(spellName)
	
	frame.brtext = T.createtext(frame.cover, "OVERLAY", 20, "OUTLINE", "RIGHT") -- 层数
	frame.brtext:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -4, 2)
	frame.brtext:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 2)
	frame.brtext:SetHeight(18)
	frame.brtext:SetTextColor(0, 1, 1)
	
	frame.text = T.createtext(frame.cover, "OVERLAY", 20, "OUTLINE", "LEFT") -- 时间
	frame.text:SetTextColor(1, 1, 1)
	frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
	
	frame.text2 = T.createtext(frame.cover, "OVERLAY", 12, "OUTLINE", "CENTER") -- 描述
	frame.text2:SetTextColor(0, 1, .5)
	frame.text2:SetPoint("TOP", frame, "BOTTOM", 0, -2)
	frame.text2:SetText(args.tip)
	
	if args.ficon then
		T.CreateFlagIconText(frame.cover, 18, args.ficon, "RIGHT", true, "TOPRIGHT", frame, "TOPRIGHT", 4, 2)
	end
	
	function frame:update_onedit(option) -- 载入配置
		EditAlertIcon(self, path, option)
	end
	
	QueueAlertIcon(frame, arg)
	
	IconFrames[frame_key] = frame
	
	return frame
end

local GetAuraMsg = function(str, spellID)
	local spellName = T.GetSpellInfo(spellID)
	local msg
	msg = T.MsgtoStr(str)
	msg = gsub(msg, "%%name", G.PlayerName)
	msg = gsub(msg, "%%spell", spellName)
	msg = gsub(msg, "%%stack", 2)
	msg = gsub(msg, "%%dur", 3)
	return msg
end

local GetMsgInfo = function(info, spellID)
	local str = ""
	if info.str_applied then
		str = str.." "..GetAuraMsg(info.str_applied, spellID)
	end
	if info.str_cd then
		str = str.." "..GetAuraMsg(info.str_cd, spellID)
	end
	if info.str_rep then
		str = str.." "..GetAuraMsg(info.str_rep, spellID)
	end
	if info.str_stack then
		str = str.." "..GetAuraMsg(info.str_stack, spellID)
	end
	return str
end

-- 图标：光环
T.CreateAura = function(ENCID, option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if args.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.sound})
	end
	if args.msg then
		details.msg_bool = true
		table.insert(detail_options, {key = "msg_bool", text = L["喊话"]..GetMsgInfo(args.msg, args.spellID), default = true})
	end
	
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_AlertIcon_Options(option_page, category, path, args, detail_options)
	
	local frame_key = args.type.."_"..args.spellID
	local frame = CreateAlertIcon(frame_key, ENCID, args.hl and 1 or 2, args, path)
	
	function frame:reset() -- 重置
		self:Hide()
		self.cooldown:SetCooldown(0, 0)
		if self.anim then
			self.anim:Stop()			
		end
	end
	
	function frame:update(AuraData, applied)
		if not self.enable then
			self:reset()
			return
		end
		
		local name = AuraData.name
		local count = AuraData.applications
		local amount = (args.effect and AuraData.points and AuraData.points[args.effect]) or 0
		local duration = AuraData.duration
		local exp_time = AuraData.expirationTime
		
		if applied then
			if args.msg and T.ValueFromPath(JST_CDB, path)["msg_bool"] then -- 消息
				if args.msg.str_applied then
					T.SendAuraMsg(args.msg.str_applied, args.msg.channel, name, count)
				end
				if args.msg.str_rep then
					if duration > 0 then
						self.msg_countdown = duration
					else
						self.msg_update = GetTime()
					end
				end
				if args.msg.str_cd then
					self.msg_countdown = args.msg.cd or 3
				end
			end
			if args.sound and T.ValueFromPath(JST_CDB, path)["sound_bool"] then -- 音效
				T.PlaySound(string.match(args.sound, "%[(.+)%]"))
				if string.match(args.sound, "cd(%d+)") then
					self.voi_countdown = tonumber(string.match(args.sound, "cd(%d+)"))
				end
			end
			if self.anim then
				self.anim:Play()
			end
			if args.tip and string.match(args.tip, "%%s(%d+)") then -- 显示法术效果（如易伤20%，减速40%）
				local value = tonumber(string.match(args.tip, "%%s(%d+)"))
				self.text2:SetText(gsub(args.tip, "%%s%d+", value*count))
			end
			self.count_old = count
		end
		
		-- 层数
		if self.count_old ~= count then
			if args.sound and string.find(args.sound, "stack") and T.ValueFromPath(JST_CDB, path)["sound_bool"] then -- 声音
				if string.match(args.sound, "stackmore(%d+)") then
					local num = tonumber(string.match(args.sound, "stackmore(%d+)"))
					if count >= num then
						if count <= 10 then
							T.PlaySound("count\\"..count)
						else
							T.SpeakText(tostring(count))
						end
					end
				elseif string.match(args.sound, "stackless(%d+)") then
					local num = tonumber(string.match(args.sound, "stackless(%d+)"))
					if count <= num then
						T.PlaySound("count\\"..count)
					end
				elseif string.find(args.sound, "stacksfx") then
					T.PlaySound(string.match(args.sound, "%[(.+)%]"))
				else
					T.PlaySound("count\\"..count)
				end
			end
			if args.msg and args.msg.str_stack and T.ValueFromPath(JST_CDB, path)["msg_bool"] then -- 聊天讯息 层数
				if args.msg.max then
					if count <= args.msg.max then
						T.SendAuraMsg(args.msg.str_stack, args.msg.channel, name, count)
					end
				elseif args.msg.min then
					if count >= args.msg.min then
						T.SendAuraMsg(args.msg.str_stack, args.msg.channel, name, count)
					end
				else
					T.SendAuraMsg(args.msg.str_stack, args.msg.channel, name, count)
				end
			end
			if args.tip and string.match(args.tip, "%%s(%d+)") then -- 显示法术效果（如易伤20%，减速40%）
				local value = tonumber(string.match(args.tip, "%%s(%d+)"))
				self.text2:SetText(gsub(args.tip, "%%s%d+", value*count))
			end
			self.count_old = count
		end
		
		self.brtext:SetText(string.format("|cffFFFF00%s|r|cff00BFFF%s|r", count > 0 and count or "", amount > 0 and T.ShortValue(amount) or ""))
		
		if duration > 0 and exp_time > 0 then
			self.cooldown:SetCooldown(AuraData.expirationTime - AuraData.duration, AuraData.duration) 
			self:SetScript("OnUpdate", function(s, e)
				s.t = s.t + e
				if s.t > update_rate then	
					s.remain = exp_time - GetTime()
					if s.remain > 0 then
						s.text:SetText(T.FormatTime(s.remain))
						
						s.remain_second = ceil(s.remain)
						if args.sound and s.voi_countdown then -- 声音
							if s.remain_second == s.voi_countdown then
								T.PlaySound("count\\"..s.remain_second)
								s.voi_countdown = s.voi_countdown - 1
							end
						end
						
						if args.msg and s.msg_countdown then -- 聊天讯息 倒数
							if s.remain_second == s.msg_countdown then
								if args.msg.str_cd then
									T.SendAuraMsg(args.msg.str_cd, args.msg.channel, name, count, s.remain_second)
								end
								if args.msg.str_rep then
									T.SendAuraMsg(args.msg.str_rep, args.msg.channel, name, count, s.remain_second)
								end
								s.msg_countdown = s.msg_countdown - 1
							end
						end
					else
						s:reset()
					end
					s.t = 0			
				end
			end)
		else
			self.text:SetText("∞")
			self:SetScript("OnUpdate", function(s, e)
				s.t = s.t + e
				if s.t > update_rate then
					if args.msg and args.msg.str_rep and s.msg_update then-- 聊天讯息 重复
						if GetTime() - s.msg_update > 0 then
							T.SendAuraMsg(args.msg.str_rep, args.msg.channel, name, count)
							s.msg_update = GetTime() + 1.5
						end
					end
					s.t = 0			
				end
			end)			
		end
		
		self:Show()
	end
	
	local register_events = {
		["UNIT_AURA"] = {args.unit},
	}
	
	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" or event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
			CheckConditions(self, register_events, args, event, ...)
		elseif event == "UNIT_AURA" then
			local unit, updateInfo = ...
			if unit == args.unit then
				if updateInfo == nil or updateInfo.isFullUpdate then
					self:reset()
					self.auraID = nil
					
					AuraUtil.ForEachAura(unit, args.aura_type, nil, function(AuraData)
						if args.spellID == AuraData.spellId or (args.spellIDs and args.spellIDs[AuraData.spellId]) then
							self.auraID = AuraData.auraInstanceID
							self:update(AuraData, true)
						end
					end, true)
				else
					if updateInfo.addedAuras ~= nil then
						for _, AuraData in pairs(updateInfo.addedAuras) do
							local spellID = AuraData.spellId
							if spellID == args.spellID or (args.spellIDs and args.spellIDs[AuraData.spellId]) then
								self.auraID = AuraData.auraInstanceID
								self:update(AuraData, true)
							end
						end
					end
					if updateInfo.updatedAuraInstanceIDs ~= nil then
						for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do
							if auraID == self.auraID then
								local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
								if AuraData then
									self:update(AuraData)
								else
									self:reset()
									self.auraID = nil
								end
							end
						end
					end
					if updateInfo.removedAuraInstanceIDs ~= nil then
						for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
							if auraID == self.auraID then
								self:reset()
								self.auraID = nil
							end
						end
					end
				end
			end
		end
	end)
end

-- 图标：对我施法
T.CreateCom = function(ENCID, option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if args.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.sound})
	end
	
	if args.msg then
		details.msg_bool = true
		table.insert(detail_options, {key = "msg_bool", text = L["喊话"]..GetMsgInfo(args.msg, args.spellID), default = true})
	end
	
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_AlertIcon_Options(option_page, category, path, args, detail_options)
	
	local frame_key = args.type.."_"..args.spellID
	local frame = CreateAlertIcon(frame_key, ENCID, args.hl and 1 or 2, args, path)
	
	function frame:reset() -- 重置
		self:Hide()
		self.cooldown:SetCooldown(0, 0)
		if self.anim then
			self.anim:Stop()			
		end
	end
	
	function frame:update(unit, cast_type)
		local name, startTimeMS, endTimeMS
		
		if cast_type == "cast" then
			name, _, _, startTimeMS, endTimeMS = UnitCastingInfo(unit)
		else
			name, _, _, startTimeMS, endTimeMS = UnitChannelInfo(unit)
		end
		
		if name and startTimeMS and endTimeMS then
			local start_time = startTimeMS/1000
			local exp_time = endTimeMS/1000
			local duration = exp_time - start_time
			
			if args.msg and T.ValueFromPath(JST_CDB, path)["msg_bool"] then
				if args.msg.str_applied then
					T.SendAuraMsg(args.msg.str_applied, args.msg.channel, name)
				end
				if args.msg.str_rep then
					self.msg_countdown = duration
				end
				if args.msg.str_cd then
					self.msg_countdown = args.msg.cd or 3
				end
			end
			if args.sound and T.ValueFromPath(JST_CDB, path)["sound_bool"] then -- 音效
				T.PlaySound(string.match(args.sound, "%[(.+)%]"))
				if string.match(args.sound, "cd(%d+)") then
					self.voi_countdown = tonumber(string.match(args.sound, "cd(%d+)"))
				end
			end
			if self.anim then
				self.anim:Play()
			end
			
			if duration > 0 and exp_time > 0 then
				self.cooldown:SetCooldown(start_time, duration)		
				self:SetScript("OnUpdate", function(s, e)
					s.t = s.t + e
					if s.t > update_rate then
						s.remain = exp_time - GetTime()
						if s.remain > 0 then
							s.text:SetText(T.FormatTime(s.remain))
							
							s.remain_second = ceil(s.remain)
							if args.sound and s.voi_countdown then -- 声音
								if s.remain_second <= s.voi_countdown then
									T.PlaySound("count\\"..s.remain_second)
									s.voi_countdown = s.voi_countdown - 1
								end
							end
							
							if args.msg and s.msg_countdown then -- 聊天讯息 倒数
								if s.remain_second <= s.msg_countdown then
									if args.msg.str_cd then
										T.SendAuraMsg(args.msg.str_cd, args.msg.channel, name, count, s.remain_second)
									end
									if args.msg.str_rep then
										T.SendAuraMsg(args.msg.str_rep, args.msg.channel, name, count, s.remain_second)
									end
									s.msg_countdown = s.msg_countdown - 1
								end
							end
						else
							s:reset()
						end
						s.t = 0
					end
				end)
			end
			
			self:Show()
		end
	end
	
	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" or event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
			CheckConditions(self, CastEvents, args, event, ...)
		elseif event == "UNIT_SPELLCAST_START" then
			local unit, _, spellID = ...
			if FilterCastbarUnits(unit) and FilterCastSpellID(spellID, args) and self.status ~= "casting" then -- 读条开始
				self.status = "casting"
				C_Timer.After(.2, function()
					if UnitIsUnit(unit.."target", "player") then -- 延迟一下再判定目标
						self:update(unit, "cast") -- 刷新
					end
				end)			
			end
		elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
			local unit, _, spellID = ...
			if FilterCastbarUnits(unit) and FilterCastSpellID(spellID, args) and self.status ~= "channeling" then -- 引导开始
				self.status = "channeling"
				C_Timer.After(.2, function()
					if UnitIsUnit(unit.."target", "player") then -- 延迟一下再判定目标
						self:update(unit, "channel") -- 刷新
					end
				end)
			end
		elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
			local unit, _, spellID = ...
			if FilterCastbarUnits(unit) and FilterCastSpellID(spellID, args) and self.status == "channeling" then -- 引导刷新
				C_Timer.After(.2, function()
					if UnitIsUnit(unit.."target", "player") then -- 延迟一下再判定目标
						self:update(unit, "channel") -- 刷新
					end
				end)
			end
		elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
			local unit, _, spellID = ...
			if FilterCastbarUnits(unit) and FilterCastSpellID(spellID, args) and (self.status == "casting" or self.status == "channeling") then -- 施法/引导结束
				self.status = "none"
				if self:IsShown() then
					self:reset()
				end
			end
		end
	end)
end

-- 图标：BOSS消息
T.CreateBossMsg = function(ENCID, option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if args.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.sound})
	end
	if args.msg then
		details.msg_bool = true
		table.insert(detail_options, {key = "msg_bool", text = L["喊话"]..GetMsgInfo(args.msg, args.spellID), default = true})
	end
	
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_AlertIcon_Options(option_page, category, path, args, detail_options)
	
	local frame_key = args.type.."_"..args.spellID
	local frame = CreateAlertIcon(frame_key, ENCID, args.hl and 1 or 2, args, path)
	local spell_name = T.GetSpellInfo(args.spellID)
	
	function frame:reset() -- 重置
		self:Hide()
		self.cooldown:SetCooldown(0, 0)
		if self.anim then
			self.anim:Stop()			
		end
	end
	
	function frame:update()
		if self:IsShown() then return end
		if args.sound and T.ValueFromPath(JST_CDB, path)["sound_bool"] then -- 音效
			T.PlaySound(string.match(args.sound, "%[(.+)%]"))
			if string.match(args.sound, "cd(%d+)") then
				self.voi_countdown = tonumber(string.match(args.sound, "cd(%d+)"))
			end
		end
		
		if args.msg and T.ValueFromPath(JST_CDB, path)["msg_bool"] then -- 聊天讯息
			if args.msg.str_applied then
				T.SendAuraMsg(args.msg.str_applied, args.msg.channel)
			end
			if args.msg.str_rep then
				self.msg_countdown = args.dur
			end
			if args.msg.str_cd then
				self.msg_countdown = args.msg.cd or 3
			end
		end
		
		self.cooldown:SetCooldown(GetTime(), args.dur)
		self.exp_time = GetTime() + args.dur
		self:SetScript("OnUpdate", function(s, e)
			s.t = s.t + e
			if s.t > update_rate then	
				s.remain = s.exp_time - GetTime()
				if s.remain > 0 then
					s.text:SetText(T.FormatTime(s.remain))
					
					s.remain_second = ceil(s.remain)
					if args.sound and string.match(args.sound, "cd(%d+)") and T.ValueFromPath(JST_CDB, path)["sound_bool"] then -- 声音
						if s.remain_second == s.voi_countdown then
							T.PlaySound("count\\"..s.remain_second)
							s.voi_countdown = s.voi_countdown - 1
						end
					end
					if args.msg and s.msg_countdown then -- 聊天讯息
						if s.remain_second == s.msg_countdown then
							if args.msg.str_cd then
								T.SendAuraMsg(args.msg.str_cd, args.msg.channel, spell_name, nil, s.remain_second)
							end
							if args.msg.str_rep then
								T.SendAuraMsg(args.msg.str_rep, args.msg.channel, spell_name, nil, s.remain_second)
							end
							s.msg_countdown = s.msg_countdown - 1
						end
					end
				else
					s:reset()
				end
				s.t = 0
			end
		end)
		
		self:Show()
		if self.anim then -- 动画
			self.anim:Play()
		end
	end
	
	local register_events = {
		[args.event] = true,
	}
	
	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" or event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
			CheckConditions(self, register_events, args, event, ...)
		elseif event == args.event then	
			local Msg = ...
			if Msg and Msg:find(args.boss_msg) then
				self:update()
			end
		end
	end)
end

-- 图标：私人光环
local CreatePrivateAura = function(index)
	local frame = CreateFrame("Frame", nil, AlertFrame3)
	frame:SetSize(70, 70)
	frame:Hide()
	
	function frame:ShowPrivateAuraIcon()
		if not self.auraAnchorID then
			self.auraAnchorID = C_UnitAuras.AddPrivateAuraAnchor({
				unitToken = "player",
				auraIndex = index,
				parent = self,
				showCountdownFrame = true,
				showCountdownNumbers = true,
				iconInfo = {
					iconWidth = JST_CDB["IconAlertOption"]["privateaura_icon_size"],
					iconHeight = JST_CDB["IconAlertOption"]["privateaura_icon_size"],
					iconAnchor = {
						point = "CENTER",
						relativeTo = self,
						relativePoint = "CENTER",
						offsetX = 0,
						offsetY = 0,
					},
				},
				durationAnchor = {
					point = "TOP",
					relativeTo = self,
					relativePoint = "BOTTOM",
					offsetX = 0,
					offsetY = -1,
				},
			})
			self:Show()			
		end
	end
	
	function frame:HidePrivateAuraIcon()
		if self.auraAnchorID then
			C_UnitAuras.RemovePrivateAuraAnchor(self.auraAnchorID)
			self.auraAnchorID = nil
			self:Hide()			
		end
	end
	
	function frame:update_onedit(option) -- 载入配置
		if option == "all" or option == "enable" then
			if JST_CDB["IconAlertOption"]["enable_pa"] then
				self:ShowPrivateAuraIcon()
			else
				self:HidePrivateAuraIcon()
			end
		end
		
		if option == "all" or option == "icon_size" then
			self:SetSize(JST_CDB["IconAlertOption"]["privateaura_icon_size"], JST_CDB["IconAlertOption"]["privateaura_icon_size"])
			self:HidePrivateAuraIcon()
			self:ShowPrivateAuraIcon()
		end
	end
	
	IconFrames["private_aura"..index] = frame
end

for i = 1, 4 do
	CreatePrivateAura(i)
end

-- 图标：测试
T.CreateTestIcon = function(args)
	local frame_key = args.type.."_"..args.spellID
	local frame = CreateAlertIcon(frame_key, "test", args.hl and 1 or 2, args)
	
	function frame:reset()
		self:Hide()
		self.cooldown:SetCooldown(0, 0)
		if self.anim then
			self.anim:Stop()			
		end
	end
	
	function frame:update()
		self.cooldown:SetCooldown(GetTime(), args.dur)
		
		self.exp_time = GetTime() + args.dur
		
		self:SetScript("OnUpdate", function(s, e)
			s.t = s.t + e
			if s.t > update_rate then	
				s.remain = s.exp_time - GetTime()
				if s.remain > 0 then
					s.text:SetText(T.FormatTime(s.remain))						
				else
					s:reset()
				end
				s.t = 0
			end
		end)
		self:Show()
		
		if self.anim then
			self.anim:Play()
		end
	end
end

T.RegisterInitCallback(function()
	local TestAlertIcons = {
		{type = "test", spellID = 426010, hl = "red_flash", dur = 5, tip = "Tip1"},
		{type = "test", spellID = 425093, hl = "gre", dur = 17, tip = "Tip2"},
		{type = "test", spellID = 200580, dur = 18, tip = "Tip3"},
	}
	
	for i, info in pairs(TestAlertIcons) do
		T.CreateTestIcon(info)
	end
end)
----------------------------------------------------------
------------------[[    计时条提示    ]]------------------
----------------------------------------------------------
local BarFrames = {}

G.BarFrames = BarFrames

local TimerbarFrame = CreateFrame("Frame", addon_name.."TimerbarFrame", FrameHolder)
TimerbarFrame:SetSize(160, 16)
TimerbarFrame.ActiveBars = {}

TimerbarFrame.movingname = L["计时条提示"]
TimerbarFrame.point = { a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 300}
T.CreateDragFrame(TimerbarFrame)

function TimerbarFrame:PreviewShow()
	BarFrames["test_139"]:update()
	BarFrames["test_255952"]:update()
end

function TimerbarFrame:PreviewHide()
	BarFrames["test_139"]:reset()
	BarFrames["test_255952"]:reset()
end

local LineUpAlertBars = function()
	local lastframe
	for frame_key, frame in pairs(TimerbarFrame.ActiveBars) do
		frame:ClearAllPoints()
		if not lastframe then
			frame:SetPoint("TOP", TimerbarFrame, "TOP")
		else
			frame:SetPoint("TOP", lastframe, "BOTTOM", 0, -4)
		end
		lastframe = frame	
	end
end

local QueueAlertBar = function(frame)
	frame:HookScript("OnShow", function(self)
		TimerbarFrame.ActiveBars[self.frame_key] = self
		LineUpAlertBars()
	end)
	
	frame:HookScript("OnHide", function(self)
		TimerbarFrame.ActiveBars[self.frame_key] = nil
		LineUpAlertBars()
	end)
end

T.EditTimerbarFrame = function(option)
	if option == "all" or option == "bar_size" then
		TimerbarFrame:SetSize(JST_CDB["TimerbarOption"]["bar_width"], JST_CDB["TimerbarOption"]["bar_height"])
	end
	for _, frame in pairs(BarFrames) do
		frame:update_onedit(option)
	end
end

-- 编辑计时条
local EditAlertTimerbar = function(frame, path, option)
	if option == "all" or option == "enable" then
		if path then
			frame.enable = T.ValueFromPath(JST_CDB, path)["enable"]
			if frame.engageID then
				if frame.enable then
					frame:RegisterEvent("ENCOUNTER_START")
					frame:RegisterEvent("ENCOUNTER_END")
				else
					frame:UnregisterEvent("ENCOUNTER_START")
					frame:UnregisterEvent("ENCOUNTER_END")
				end
			elseif frame.mapID then
				if frame.enable then
					frame:RegisterEvent("PLAYER_ENTERING_WORLD")
				else
					frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
				end
			end
			frame:GetScript("OnEvent")(frame, "OPTION_EDIT")
		end
	end
	
	if option == "all" or option == "bar_size" then
		frame:SetSize(JST_CDB["TimerbarOption"]["bar_width"], JST_CDB["TimerbarOption"]["bar_height"])
	end
end

-- 计时条分割线
local UpdateTagForTimerbar = function(frame, color, tags)
	if not tags then return end
	
	local r, g, b = unpack(color)
	
	if r + g + b > 1.5 then
		for i in pairs(tags) do
			frame["tag"..i]:SetVertexColor(0, 0, 0)
		end
	else
		for i in pairs(tags) do
			frame["tag"..i]:SetVertexColor(1, 1, 1)
		end
	end

	frame:SetScript("OnMinMaxChanged", function(self, arg1, arg2)
		for i, each_dur in pairs(tags) do
			frame["tag"..i]:SetSize(3, JST_CDB["TimerbarOption"]["bar_height"])
			
			local max_dur = select(2, frame:GetMinMaxValues())
			frame.pointtag(i, each_dur/max_dur)
		end
	end)

	function frame:show_tags()
		for i in pairs(tags) do
			frame["tag"..i]:Show()
		end
	end
	
	function frame:hide_tags()
		for i in pairs(tags) do
			frame["tag"..i]:Hide()
		end
	end
end

-- 创建计时条
local CreateAlertTimerbar = function(frame_key, ENCID, args, path)
	if BarFrames[frame_key] then return BarFrames[frame_key] end
	
	local spellName, _, spellIcon
	
	if args.display_spellID then
		spellName, spellIcon = T.GetSpellInfo(args.display_spellID)
	elseif args.spellID then
		spellName, spellIcon = T.GetSpellInfo(args.spellID)
	end
	
	local flagicons = args.ficon and T.GetFlagIconStr(args.ficon)
	local text = args.text or spellName
	local icon = args.icon_tex or spellIcon
	
	local frame = T.CreateTimerBar(TimerbarFrame, icon, args.glow, true, true, nil, nil, args.color, args.tags and #args.tags)
	frame.frame_key = tostring(frame_key)
	
	if ENCID then
		if type(ENCID) == "number" then -- 只针对首领战斗
			frame.npcID = G.Encounters[ENCID]["npc_id"]
			frame.engageID = G.Encounters[ENCID]["engage_id"]
		elseif string.find(ENCID, "Trash") then
			frame.mapID = G.Encounters[ENCID]["map_id"]
		end
	end
	
	-- 分割线
	UpdateTagForTimerbar(frame, args.color, args.tags)
	
	-- 文字
	frame.left:SetText(string.format("%s %s", flagicons or "", text or ""))
	
	frame.ind_text = T.createtext(frame, "OVERLAY", 14, "OUTLINE", "LEFT")
	frame.ind_text:SetPoint("LEFT", frame.left, "RIGHT", 0, 0)
	frame:HookScript("OnSizeChanged", function(self, width, height)
		self.ind_text:SetFont(G.Font, height-5, "OUTLINE")
	end)
		
	function frame:update_onedit(option) -- 载入配置	
		EditAlertTimerbar(self, path, option)
	end
	
	QueueAlertBar(frame)
	
	BarFrames[frame_key] = frame
	
	if not path and JST_CDB then
		EditAlertTimerbar(frame, path, "all")
	end
	
	return frame
end

T.CreateAlertTimerbar = function(frame_key, icon_tex, text, color, tags)
	return CreateAlertTimerbar(frame_key, nil, {icon_tex = icon_tex, text = text, color = color, tags = tags})
end

--  [50]116139, -- Haunting Memento
--  [55]74637, -- Kiryn's Poison Vial
--  [60]32825, -- Soul Cannon
--  [60]37887, -- Seeds of Nature's Wrath
--  [70]41265, -- Eyesore Blaster

-- C_Item.GetItemInfo(itemID)
-- C_Item.IsItemInRange(itemID, unit)

local UnitOutOfRange = function(unit)	
	if not C_Item.IsItemInRange(116139, unit) then
		return true
	end
end

local UpdateBarRange = function(frame, args, unit)
	if args.range_ck then
		if UnitOutOfRange(unit) then -- 50码之外
			frame:SetAlpha(.2)
			frame:GetStatusBarTexture():SetDesaturated(true)
			frame.ofr = true
		else
			frame:SetAlpha(1)
			frame:GetStatusBarTexture():SetDesaturated(false)
			frame.ofr = false
		end
	else
		frame.ofr = false
	end
end

-- 计时条：施法
T.CreateCastbar = function(ENCID, option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if args.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.sound})
	end
	
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_Timerbar_Options(option_page, category, path, args, detail_options)
	
	local frame_key = args.type.."_"..args.spellID	
	local frame = CreateAlertTimerbar(frame_key, ENCID, args, path)
	
	frame.ind = 0
	frame.ind_channel = 0
	frame.ind_cast = 0
	
	function frame:reset() -- 重置
		self:Hide()
		self:SetScript("OnUpdate", nil)
		if self.anim then
			self.anim:Stop()
		end
	end
	
	function frame:update(unit, cast_type)
		local startTimeMS, endTimeMS
		
		if args.dur then
			self.dur = args.dur
		else
			if cast_type == "cast" then
				startTimeMS, endTimeMS = select(4, UnitCastingInfo(unit))
				self:SetValue(0)
			else
				startTimeMS, endTimeMS = select(4, UnitChannelInfo(unit))
			end
			self.dur = (endTimeMS - startTimeMS)/1000
		end

		self.exp_time = GetTime() + self.dur
		self:SetMinMaxValues(0, self.dur)		
		self:SetScript("OnUpdate", function(s, e)
			s.t = s.t + e
			if s.t > s.update_rate then
				s.remain = s.exp_time - GetTime()
				if s.remain > 0 then		
					s.right:SetText(T.FormatTime(s.remain))
					
					if cast_type == "cast" then
						s:SetValue(s.dur - s.remain)
					else
						s:SetValue(s.remain)
					end
					
					if args.sound and string.find(args.sound, cast_type) and s.voi_countdown and T.ValueFromPath(JST_CDB, path)["sound_bool"] and not s.ofr then -- 倒数
						s.remain_second = ceil(s.remain)
						if s.remain_second <= s.voi_countdown and s.remain_second > 0 then
							T.PlaySound("count\\"..s.remain_second) -- 3..2..1..
							s.voi_countdown = s.voi_countdown - 1
						end
					end
				else
					s:reset()
				end
				s.t = 0
			end
		end)
		
		if self.anim and (args.glow or (cast_type == "cast" and args.glow_cast) or (cast_type == "channel" and args.glow_channel)) then
			self.anim:Play()
		end
		
		self:Show()
	end
	
	function frame:play_sound(unit, cast_type)
		if args.sound and string.find(args.sound, cast_type) and T.ValueFromPath(JST_CDB, path)["sound_bool"] and not self.ofr then
			T.PlaySound(string.match(args.sound, "%[(.+)%]"..cast_type))
			if args.show_tar then -- 与朗读序号冲突
				C_Timer.After(1, function()
					if UnitName(unit.."target") then
						T.SpeakText(UnitName(unit.."target"))
					end
				end)
			end
			if args.count then -- 与朗读目标冲突
				C_Timer.After(1, function()
					local ind
					if cast_type == "cast" then
						ind = self.ind
					elseif cast_type == "channel" then
						ind = self.ind_channel
					else
						ind = self.ind_cast
					end
					T.PlaySound("count\\"..ind) -- 序数
				end)
			end
			if string.find(args.sound, "cd(%d+)") then
				self.voi_countdown = tonumber(string.match(args.sound, "cd(%d+)"))
			end
		end
	end
	
	function frame:update_target(unit)
		if args.show_tar then
			C_Timer.After(0.1, function()
				local GUID = UnitGUID(unit)
				if GUID then
					self.mid:SetText(T.ColorNickNameByGUID(GUID))
				else
					self.mid:SetText("")
				end
			end)
		end
	end
	
	function frame:init_update(event, ...)
		self.ind = 0
		self.ind_channel = 0
		self.ind_cast = 0
	end
	
	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" or event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
			CheckConditions(self, CastEvents, args, event, ...)
		elseif event == "UNIT_SPELLCAST_START" then
			local unit, _, spellID = ...
			if not args.dur and FilterCastbarUnits(unit) and FilterCastSpellID(spellID, args) and self.status ~= "casting" then -- 读条开始
				self.status = "casting"				
				self.ind = self.ind + 1
				
				if args.count then -- 序号
					self.ind_text:SetText(string.format("|cffFFFF00[%d]|r", self.ind))
				end
				
				UpdateBarRange(self, args, unit)
				
				if args.tags then -- 隐藏分段标记
					self:hide_tags()
				end					
				
				self:update_target(unit) -- 刷新目标
				
				self:play_sound(unit, "cast") -- 声音
				
				self:update(unit, "cast") -- 刷新
			end	
		elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
			local unit, _, spellID = ...
			if not args.dur and FilterCastbarUnits(unit) and FilterCastSpellID(spellID, args) and self.status ~= "channeling" then -- 引导开始
				self.status = "channeling"
				self.ind_channel = self.ind_channel + 1
				
				if args.count then -- 序号
					self.ind_text:SetText(string.format("|cffFFFF00[%d]|r", self.ind_channel))
				end
				
				UpdateBarRange(self, args, unit)
					
				if args.tags then -- 显示分段标记
					self:show_tags()
				end
				
				self:update_target(unit) -- 刷新目标
				
				self:play_sound(unit, "channel") -- 声音
			
				self:update(unit, "channel") -- 刷新
			end
		elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
			local unit, _, spellID = ...
			if not args.dur and FilterCastbarUnits(unit) and FilterCastSpellID(spellID, args) and self.status == "channeling" then -- 引导刷新
				self:update(unit, "channel") -- 刷新
			end
		elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
			local unit, _, spellID = ...
			if not args.dur and FilterCastbarUnits(unit) and FilterCastSpellID(spellID, args) and (self.status == "casting" or self.status == "channeling") then -- 施法/引导结束
				self.status = "none"
				self:reset()
			end
		elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
			local unit, _, spellID = ...
			if args.dur and FilterCastbarUnits(unit) and FilterCastSpellID(spellID, args) then
				self.ind_cast = self.ind_cast + 1
				
				if args.count then -- 序号
					self.ind_text:SetText(string.format("|cffFFFF00[%d]|r", self.ind_cast))
				end
				
				UpdateBarRange(self, args, unit)
				
				if args.tags then -- 显示分段标记
					self:show_tags()
				end
				
				self:update_target(unit) -- 刷新目标
				
				self:play_sound(unit, "cast") -- 声音
				
				self:update(unit, "cast") -- 刷新
			end
		elseif event == "ENCOUNTER_PHASE" and args.phase_reset then -- 转阶段重置计数
			self.ind = 0
			self.ind_channel = 0
			self.ind_cast = 0
		end
	end)
end

local CLEUbarEvents = {
	["COMBAT_LOG_EVENT_UNFILTERED"] = true,
	["ENCOUNTER_PHASE"] = true,
}

-- 计时条：CLEU
T.CreateCLEUbar = function(ENCID, option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if args.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.sound})
	end
	
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_Timerbar_Options(option_page, category, path, args, detail_options)
	
	local frame_key = args.type.."_"..args.spellID
	local frame = CreateAlertTimerbar(frame_key, ENCID, args, path)
	
	frame.ind = 0	
	frame:SetMinMaxValues(0, args.dur)

	function frame:reset() -- 重置	
		self:Hide()
		self:SetScript("OnUpdate", nil)
		if self.anim then
			self.anim:Stop()
		end
	end
	
	function frame:update()
		self.dur = args.dur
		self.exp_time = GetTime() + self.dur

		self:SetScript("OnUpdate", function(s, e)
			s.t = s.t + e
			if s.t > s.update_rate then
				s.remain = s.exp_time - GetTime()
				if s.remain > 0 then
					s.right:SetText(T.FormatTime(s.remain))
					
					s:SetValue(s.dur - s.remain)
					
					if args.sound and s.voi_countdown and T.ValueFromPath(JST_CDB, path)["sound_bool"] and not s.ofr then -- 倒数
						s.remain_second = ceil(s.remain)
						if s.remain_second <= s.voi_countdown and s.remain_second > 0 then
							T.PlaySound("count\\"..s.remain_second) -- 3..2..1..
							s.voi_countdown = s.voi_countdown - 1
						end
					end
				else
					s:reset()
				end
				s.t = 0
			end
		end)
		
		if args.glow then
			self.anim:Play()
		end
		
		self:Show()
	end
	
	function frame:play_sound(GUID)
		if args.sound and T.ValueFromPath(JST_CDB, path)["sound_bool"] and not self.ofr then	
			T.PlaySound(string.match(args.sound, "%[(.+)%]"))
			if args.show_tar and GUID then -- 与朗读序号冲突
				C_Timer.After(1, function()
					local name = T.GetNameByGUID(GUID)
					if name then
						T.SpeakText(name)
					end
				end)
			end
			if args.count then -- 与朗读目标冲突
				C_Timer.After(1, function()
					T.PlaySound("count\\"..self.ind) -- 序数
				end)
			end
			if string.match(args.sound, "cd(%d+)") then
				self.voi_countdown = tonumber(string.match(args.sound, "cd(%d+)"))
			end
		end	
	end
	
	function frame:update_target(GUID)
		if args.show_tar and GUID then
			self.mid:SetText(T.ColorNickNameByGUID(GUID))
		end
	end
	
	function frame:init_update(event, ...)
		self.ind = 0
	end
	
	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" or event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
			CheckConditions(self, CLEUbarEvents, args, event, ...)
		elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
			local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
			if FilterCastSpellID(spellID, args) and args.event == sub_event and (not args.target_me or destGUID == G.PlayerGUID) and not self:IsShown() then -- 读条开始		
				self.ind = self.ind + 1
				
				if args.count then -- 序号
					self.ind_text:SetText(string.format("|cffFFFF00[%d]|r", self.ind))
				end
				
				if args.range_ck and (sub_event == "SPELL_CAST_START" or sub_event == "SPELL_CAST_SUCCESS")	then
					local boss_unit = T.GetBossUnit(sourceGUID)
					if boss_unit then
						UpdateBarRange(self, args, boss_unit)
					end
				end
				
				self:update_target(destGUID) -- 刷新目标
				
				self:play_sound(destGUID) -- 声音
				
				self:update()	-- 刷新	
			end
		elseif args.phase_reset and event == "ENCOUNTER_PHASE" then -- 转阶段重置计数
			self.ind = 0
		end
	end)
end

-- 计时条：测试
T.CreateTestTimerBar = function(args)
	local frame_key = args.type.."_"..args.spellID
	local frame = CreateAlertTimerbar(frame_key, "test", args)
	
	frame:SetMinMaxValues(0, args.dur)
	
	function frame:reset()
		self:Hide()
		self:SetScript("OnUpdate", nil)
	end
	
	function frame:update()
		self.dur = args.dur
		self.exp_time = GetTime() + self.dur
		
		self:SetScript("OnUpdate", function(s, e)
			s.t = s.t + e
			if s.t > s.update_rate then
				s.remain = s.exp_time - GetTime()
				if s.remain > 0 then
					s.right:SetText(T.FormatTime(s.remain))
					s:SetValue(s.dur - s.remain)
				else
					s:reset()
				end
				s.t = 0
			end
		end)
		self:Show()		
	end
end

T.RegisterInitCallback(function()
	local TestTimerBars = {
		{type = "test", spellID = 139, color = {1, 0, 0}, dur = 6, tags = {2, 4}},
		{type = "test", spellID = 255952, color = {0, 1, 0}, dur = 5}
	}

	for i, info in pairs(TestTimerBars) do
		T.CreateTestTimerBar(info)
	end
end)
----------------------------------------------------------
-------------------[[    文字提示    ]]-------------------
----------------------------------------------------------
local TextFrames = {}

G.TextFrames = TextFrames

local TextFrame = CreateFrame("Frame", G.addon_name.."Text_Alert", FrameHolder)
TextFrame:SetSize(300,30)
TextFrame.ActiveTexts = {}

TextFrame.movingname = L["文字提示"]
TextFrame.point = { a1 = "CENTER", a2 = "CENTER", x = 0, y = 170}
T.CreateDragFrame(TextFrame)

function TextFrame:PreviewShow()
	T.Start_Text_Timer(TextFrames["preview1"], 20, T.GetSpellIcon(139)..L["文字提示"], true)
	T.Start_Text_Timer(TextFrames["preview2"], 20, T.GetSpellIcon(17)..L["文字提示"], true)
end

function TextFrame:PreviewHide()
	TextFrames["preview1"]:Hide()
	TextFrames["preview2"]:Hide()
end
	
local TextFrame2 = CreateFrame("Frame", G.addon_name.."Text_Alert2", FrameHolder)
TextFrame2:SetSize(300,50)
TextFrame2.ActiveTexts = {}

TextFrame2.movingname = L["文字提示2"]
TextFrame2.point = { a1 = "CENTER", a2 = "CENTER", x = 0, y = 300}
T.CreateDragFrame(TextFrame2)

local LineUpTexts = function(arg)
	local lastframe
	local parent = (arg == 1 and TextFrame) or TextFrame2

	for frame_key, frame in pairs(parent.ActiveTexts) do		
		frame:ClearAllPoints()
		
		if not frame.collapse then
			if not lastframe then
				frame:SetPoint("TOP", parent, "TOP")
			else
				frame:SetPoint("TOP", lastframe, "BOTTOM", 0, -5)
			end	
			lastframe = frame
		end
	end
end
T.LineUpTexts = LineUpTexts

local QueueText = function(frame)
	local parent = frame:GetParent()
	
	frame:HookScript("OnShow", function(self)
		parent.ActiveTexts[self.frame_key] = self
		LineUpTexts(self.arg)
	end)
	
	frame:HookScript("OnHide", function(self)
		parent.ActiveTexts[self.frame_key] = nil
		LineUpTexts(self.arg)
	end)
end

T.EditTextFrame = function(option)
	for _, frame in pairs(TextFrames) do
		if frame.update_onedit then
			frame:update_onedit(option)
		end
	end
end

-- 编辑文字
local EditAlertText = function(frame, path, option)		
	if option == "all" or option == "enable" then
		if path then
			frame.enable = T.ValueFromPath(JST_CDB, path)["enable"]
			if frame.engageID then
				if frame.enable then
					frame:RegisterEvent("ENCOUNTER_START")
					frame:RegisterEvent("ENCOUNTER_END")
				else
					frame:UnregisterEvent("ENCOUNTER_START")
					frame:UnregisterEvent("ENCOUNTER_END")
				end
			elseif frame.mapID then
				if frame.enable then
					frame:RegisterEvent("PLAYER_ENTERING_WORLD")
				else
					frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
				end
			end
			frame:GetScript("OnEvent")(frame, "OPTION_EDIT")
		end
	end
	
	if option == "all" or option == "font_size" then
		if frame.arg == 1 then
			frame:SetSize(JST_CDB["TextAlertOption"]["font_size"]*8, JST_CDB["TextAlertOption"]["font_size"])
			frame.text:SetFont(G.Font, JST_CDB["TextAlertOption"]["font_size"], "OUTLINE")
		else
			frame:SetSize(JST_CDB["TextAlertOption"]["font_size_big"]*8, JST_CDB["TextAlertOption"]["font_size_big"])
			frame.text:SetFont(G.Font, JST_CDB["TextAlertOption"]["font_size_big"], "OUTLINE")
		end
	end
end

-- 创建文字
local CreateAlertText = function(frame_key, ENCID, arg, args, path)
	if TextFrames[frame_key] then return TextFrames[frame_key] end
	
	local parent = (arg == 1 and TextFrame) or TextFrame2
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(160, 20)
	frame:Hide()
	
	if ENCID then
		if type(ENCID) == "number" then -- 只针对首领战斗
			frame.npcID = G.Encounters[ENCID]["npc_id"]
			frame.engageID = G.Encounters[ENCID]["engage_id"]
		elseif string.find(ENCID, "Trash") then
			frame.mapID = G.Encounters[ENCID]["map_id"]
		end
	end
	
	frame.frame_key = tostring(frame_key)
	frame.arg = arg
	frame.t = 0.1
	
	frame.text = T.createtext(frame, "OVERLAY", 20, "OUTLINE", "CENTER")
	frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
	
	if args and args.color then
		frame.text:SetTextColor(unpack(args.color))
	end
	
	function frame:update_onedit(option) -- 载入配置
		EditAlertText(self, path, option)
	end
	
	QueueText(frame)
	
	TextFrames[frame_key] = frame
	
	if not path and JST_CDB then
		EditAlertText(frame, path, "all")
	end
	
	return frame
end

-- 用于创建附加文字提示
T.CreateAlertText = function(frame_key, arg, color)
	if color then
		return CreateAlertText(frame_key, nil, arg, {color = color})
	else
		return CreateAlertText(frame_key, nil, arg)
	end
end

local HealthtextEvents = {
	["UNIT_HEALTH"] = {"boss1", "boss2", "boss3", "boss4", "boss5"},
}

T.CreateHealthText = function(ENCID, option_page, category, args)
	local path = {category, args.type, args.data.npc_id}
	T.InitSettings(path, args.enable_tag, args.ficon)
	T.Create_TextAlert_Options(option_page, category, path, args)
	
	if not args.color then
		args.color = {1, 0, 0}
	end
	
	local frame_key = args.type.."_"..args.data.npc_id
	local frame = CreateAlertText(frame_key, ENCID, 1, args, path)
	
	function frame:reset() -- 重置
		self:Hide()
	end
	
	function frame:update(event, unit)
		if unit and T.GetUnitNpcID(unit) == args.data.npc_id then -- 当事件指向我们需要的boss时获取数据，否则忽略	
			local hp = UnitHealth(unit)
			local hp_max = UnitHealthMax(unit)
			local hp_perc

			if hp and hp_max then
				hp_perc = hp/hp_max*100
			end
			
			local show
					
			for i, range in pairs(args.data.ranges) do
				if hp_perc and (hp_perc <= range["ul"]) and (hp_perc >= range["ll"]) then
					self.text:SetText(string.format(range["tip"], hp_perc))
					self:Show()
					show = true
					break
				end
			end

			if not show then
				self:Hide()
			end
		end
	end
	
	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" or event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
			CheckConditions(self, HealthtextEvents, args, event, ...)
		else
			self:update(event, ...)
		end
	end)
end

local PowertextEvents = {
	["UNIT_POWER_UPDATE"] = {"boss1", "boss2", "boss3", "boss4", "boss5"},
}

T.CreatePowerText = function(ENCID, option_page, category, args)
	local path = {category, args.type, args.data.npc_id}
	T.InitSettings(path, args.enable_tag, args.ficon)
	T.Create_TextAlert_Options(option_page, category, path, args)
	
	if not args.color then
		args.color = {0, 1, 1}
	end
	
	local frame_key = args.type.."_"..args.data.npc_id
	local frame = CreateAlertText(frame_key, ENCID, 1, args, path)
	
	function frame:reset() -- 重置
		self:Hide()
	end
	
	function frame:update(event, unit) -- 更新数据
		if unit and T.GetUnitNpcID(unit) == args.data.npc_id then -- 当事件指向我们需要的boss时获取数据，否则忽略	
			local pp = UnitPower(unit)
			local show 
					
			for i, range in pairs(args.data.ranges) do
				if pp and (pp <= range["ul"]) and (pp >= range["ll"]) then
					self.text:SetText(string.format(range["tip"], pp))
					self:Show()
					show = true
					break
				end
			end

			if not show then
				self:Hide()
			end
		end
	end
	
	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" or event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
			CheckConditions(self, PowertextEvents, args, event, ...)
		else
			self:update(event, ...)
		end
	end)
end

T.CreateSpellText = function(ENCID, option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if args.data.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.data.sound})
	end
	
	if args.data.cd_args and args.data.cd_args.prepare_sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = string.format("[%s]",args.data.cd_args.prepare_sound)})
	end
	
	local path = {category, args.type, args.data.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_TextAlert_Options(option_page, category, path, args, detail_options)
	
	if not args.color then
		args.color = {1, 1, 1}
	end
	
	local frame_key = args.type.."_"..args.data.spellID
	local frame = CreateAlertText(frame_key, ENCID, args.data.arg or 1, args, path)
	
	frame.data = args.data
	frame.update = args.update
	
	function frame:reset() -- 重置
		self:Hide()
	end
	
	function frame:init_update(event, ...)
		self:update(event, ...)
	end
	
	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" or event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
			CheckConditions(self, frame.data.events, args, event, ...)
		else		
			self:update(event, ...)
		end
	end)
end

-- 测试文字
T.RegisterInitCallback(function()
	T.CreateAlertText("preview1", 1)
	T.CreateAlertText("preview2", 2)
end)

-- [[文字倒计时通用]] --

-- frame.round = true -- 倒计时数字取整
-- frame.show_time = 4 -- 小于该秒数时显示（延迟显示类模板）
-- frame.count_down_start = 5 -- 倒数开始数字
-- frame.mute_count_down = true -- 倒数静音
-- frame.prepare_sound = "add"/{"add", "aoe"}-- 准备音效（于倒数前播放，会占用一个倒数数字）
-- frame.show_ind = true -- 显示序数（循环）

-- 文字倒计时模板(持续显示)
T.Start_Text_Timer = function(frame, dur, text, show_dur)
	frame.exp_time = GetTime() + dur
	frame.count_down = frame.count_down_start
	frame.prepare = frame.prepare_sound
	
	frame.text:SetText("")
	frame:Show()
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			self.remain = self.exp_time - GetTime()
			if self.remain > 0 then
				self.remain_second = ceil(self.remain)
				
				if show_dur then
					if self.round then
						self.text:SetText(text.." "..self.remain_second)
					else
						self.text:SetText(string.format("%s %.1f", text, self.remain))
					end
				else
					self.text:SetText(text)
				end
				
				if self.count_down and self.remain_second <= self.count_down then
					if self.prepare then
						T.PlaySound(self.prepare)	
						self.prepare = nil
					elseif not self.mute_count_down then	
						T.PlaySound("count\\"..self.remain_second)
					end
					self.count_down = self.count_down - 1
				end				
			else
				self:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.t = 0
		end
	end)
end

-- 文字倒计时模板(倒计时小于4秒时显示)
T.Start_Text_DelayTimer = function(frame, dur, text, show_dur)
	frame.exp_time = GetTime() + dur
	frame.show_time = frame.show_time or 4
	frame.count_down = frame.count_down_start
	frame.prepare = frame.prepare_sound		
	
	if dur > frame.show_time then
		frame.collapse = true
	else
		frame.collapse = false
	end
	
	frame.text:SetText("")
	frame:Show()
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			self.remain = self.exp_time - GetTime()
			if self.remain > self.show_time then
				self.text:SetText("")
				if not self.collapse then
					self.collapse = true
					LineUpTexts(self.arg)
				end
			elseif self.remain > 0 then
				if self.collapse then
					self.collapse = false
					LineUpTexts(self.arg)
				end
				self.remain_second = ceil(self.remain)
				
				if show_dur then
					if self.round then
						self.text:SetText(text.." "..self.remain_second)
					else
						self.text:SetText(string.format("%s %.1f", text, self.remain))
					end
				else
					self.text:SetText(text)
				end
				
				if self.count_down and self.remain_second <= self.count_down then	
					if self.prepare then
						T.PlaySound(self.prepare)
						self.prepare = nil
					elseif not self.mute_count_down then	
						T.PlaySound("count\\"..self.remain_second)
					end
					self.count_down = self.count_down - 1
				end
			else
				self:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.t = 0
		end
	end)
end

-- 文字倒计时模板(依次重复文字倒计时持续显示模板)
T.Start_Text_RowTimer = function(frame, dur_table, text_info, show_dur)
	local ind = 1
	frame.exp_time = GetTime() + dur_table[ind]
	frame.count_down = frame.count_down_start
	frame.prepare = type(frame.prepare_sound) == "table" and frame.prepare_sound[ind] or frame.prepare_sound 
	frame.str = type(text_info) == "table" and text_info[ind] or text_info		
	
	frame.text:SetText(frame.str)
	frame:Show()
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			self.remain = self.exp_time - GetTime()
			if self.remain > 0 then
				self.remain_second = ceil(self.remain)
				if show_dur then
					if self.round then
						self.text:SetText(self.str.." "..self.remain_second)
					else
						self.text:SetText(string.format("%s %.1f", self.str, self.remain))
					end
				end
				
				if self.count_down and self.remain_second <= self.count_down then
					if self.prepare then
						T.PlaySound(self.prepare)
						self.prepare = nil
					elseif not mute_count_down then	
						T.PlaySound("count\\"..self.remain_second)
					end
					self.count_down = self.count_down - 1
				end
			else
				ind = ind + 1
				if dur_table[ind] then
					self.exp_time = self.exp_time + dur_table[ind]
					self.count_down = self.count_down_start
					self.prepare = type(self.prepare_sound) == "table" and self.prepare_sound[ind] or self.prepare_sound
					self.str = type(text_info) == "table" and text_info[ind] or text_info
				else
					self:Hide()
					self:SetScript("OnUpdate", nil)
				end
			end
			self.t = 0
		end
	end)
end

-- 文字倒计时模板(依次重复文字倒计时小于4秒时显示模板)
T.Start_Text_DelayRowTimer = function(frame, dur_table, text_info, show_dur)
	local ind = 1
	frame.exp_time = GetTime() + dur_table[ind]
	frame.show_time = frame.show_time or 4
	frame.count_down = frame.count_down_start
	frame.prepare = type(frame.prepare_sound) == "table" and frame.prepare_sound[ind] or frame.prepare_sound 
	frame.str = type(text_info) == "table" and text_info[ind] or text_info
	
	if dur_table[ind] > frame.show_time then
		frame.collapse = true
	else
		frame.collapse = false
	end
	
	frame.text:SetText(frame.str)
	frame:Show()
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			self.remain = self.exp_time - GetTime()
			if self.remain > self.show_time then
				self.text:SetText("")
				if not self.collapse then
					self.collapse = true
					LineUpTexts(self.arg)
				end
			elseif self.remain > 0 then
				if self.collapse then
					self.collapse = false
					LineUpTexts(self.arg)
				end
				self.remain_second = ceil(self.remain)
				
				if show_dur then
					if self.round then
						self.text:SetText(self.str.." "..ceil(self.remain_second ))
					else
						self.text:SetText(string.format("%s %.1f", self.str, self.remain))
					end
				end
				
				if self.count_down and self.remain_second <= self.count_down then
					if self.prepare then
						T.PlaySound(self.prepare)
						self.prepare = nil
					elseif not self.mute_count_down then	
						T.PlaySound("count\\"..self.remain_second)
					end
					self.count_down = self.count_down - 1				
				end
			else
				ind = ind + 1
				if dur_table[ind] then
					self.exp_time = self.exp_time + dur_table[ind]
					self.count_down = self.count_down_start
					self.prepare = type(self.prepare_sound) == "table" and self.prepare_sound[ind] or self.prepare_sound
					self.str = type(text_info) == "table" and text_info[ind] or text_info
				else
					self:Hide()
					self:SetScript("OnUpdate", nil)
				end
			end
			self.t = 0
		end
	end)
end

-- 文字倒计时模板(循环重复文字倒计时持续显示模板)
T.Start_Text_LoopTimer = function(frame, dur, text, show_dur)
	local ind = 1
	frame.exp_time = GetTime() + dur
	frame.count_down = frame.count_down_start
	frame.prepare = frame.prepare_sound 
	frame.str = (frame.show_ind and string.format("[%d] ", ind) or "")..text
	
	frame.text:SetText(frame.str)
	frame:Show()
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			self.remain = self.exp_time - GetTime()
			if self.remain > 0 then
				self.remain_second = ceil(self.remain)
				if show_dur then
					if self.round then
						self.text:SetText(self.str.." "..self.remain_second)
					else
						self.text:SetText(string.format("%s %.1f", self.str, self.remain))
					end
				end
				
				if self.count_down and self.remain_second <= self.count_down then
					if self.prepare then
						T.PlaySound(self.prepare)
						self.prepare = nil
					elseif not mute_count_down then	
						T.PlaySound("count\\"..self.remain_second)
					end
					self.count_down = self.count_down - 1
				end
			else
				ind = ind + 1
				self.exp_time = self.exp_time + dur
				self.count_down = self.count_down_start
				self.prepare = self.prepare_sound
				self.str = (self.show_ind and string.format("[%d] ", ind) or "")..text
			end
			self.t = 0
		end
	end)
end

-- 文字倒计时模板(循环重复文字倒计时小于4秒时显示模板)
T.Start_Text_DelayLoopTimer = function(frame, dur, text, show_dur)
	local ind = 1
	frame.exp_time = GetTime() + dur
	frame.show_time = frame.show_time or 4
	frame.count_down = frame.count_down_start
	frame.prepare = frame.prepare_sound 
	frame.str = (frame.show_ind and string.format("[%d] ", ind) or "")..text
	
	if dur > frame.show_time then
		frame.collapse = true
	else
		frame.collapse = false
	end
		
	frame.text:SetText(frame.str)
	frame:Show()
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			self.remain = self.exp_time - GetTime()
			if self.remain > self.show_time then
				self.text:SetText("")
				if not self.collapse then
					self.collapse = true
					LineUpTexts(self.arg)
				end
			elseif self.remain > 0 then
				if self.collapse then
					self.collapse = false
					LineUpTexts(self.arg)
				end
				self.remain_second = ceil(self.remain)
				
				if show_dur then
					if self.round then
						self.text:SetText(self.str.." "..self.remain_second)
					else
						self.text:SetText(string.format("%s %.1f", self.str, self.remain))
					end
				end
				
				if self.count_down and self.remain_second <= self.count_down then
					if self.prepare then
						T.PlaySound(self.prepare)
						self.prepare = nil
					elseif not mute_count_down then	
						T.PlaySound("count\\"..self.remain_second)
					end
					self.count_down = self.count_down - 1
				end
			else
				ind = ind + 1
				self.exp_time = self.exp_time + dur
				self.count_down = self.count_down_start
				self.prepare = self.prepare_sound
				self.str = (self.show_ind and string.format("[%d] ", ind) or "")..text
			end
			self.t = 0
		end
	end)
end

-- 停止文字倒计时
T.Stop_Text_Timer = function(frame)
	frame:Hide()
	frame:SetScript("OnUpdate", nil)
end

-- BW/DBM 计时器监控模板
local function StartFrameUpdate(prepare_sound, text_replace, dur, frame, spellID, expirationTime)
	if expirationTime > GetTime() then		
		frame.count_down = dur
		frame.remain = expirationTime - GetTime()
		
		if frame.remain > dur then
			frame.collapse = true
		elseif frame.remain > 0 then
			frame.collapse = false
		end
		
		frame:Show()
		
		frame:SetScript('OnUpdate', function(self, e)
			self.t = self.t + e
			if self.t > 0.05 then			
				self.remain = expirationTime - GetTime()
				if self.remain > dur then -- 还要等等
					self.text:SetText("")
					if not self.collapse then
						self.collapse = true
						LineUpTexts(self.arg)
					end
				elseif self.remain > 0 then
					if not self.data.check or self.data.check() then -- 这个时候显示
						if self.collapse then
							self.collapse = false
							LineUpTexts(self.arg)
						end
						if prepare_sound then -- 音效
							self.remain_second = ceil(self.remain)	
							if self.remain_second == self.count_down then
								if self.remain_second == dur then
									T.PlaySound(prepare_sound)
								elseif self.remain_second <= 3 and self.remain_second > 0 then
									T.PlaySound("count\\"..self.remain_second)
								end
								self.count_down = self.count_down - 1
							end	
						end
						
						if text_replace then -- 文字
							self.text:SetText(string.format("%s %.1f", text_replace, self.remain))
						else
							self.text:SetText(string.format("%s %.1f", T.GetIconLink(spellID), self.remain))
						end
					end
				else -- 已经结束哩
					self:SetScript("OnUpdate", nil)
					self:Hide()
					self.text:SetText("")
				end	
				self.t = 0
			end
		end)
	end
end

local function StopFrameUpdate(frame)
	frame:SetScript("OnUpdate", nil)
	frame:Hide()
	frame.text:SetText("")
end

T.UpdateAddonTimer = function(DBM_spellID, BW_spellID, prepare_sound, text_replace, dur, frame, event, ...)
	if event == "DBM_TIMER_START" then
		local spellID, _, expirationTime = ...
		if spellID == DBM_spellID then
			StartFrameUpdate(prepare_sound, text_replace, dur, frame, spellID, expirationTime)
		end
	elseif event == "BW_TIMER_START" then
		local spellID, _, expirationTime = ...
		if spellID == BW_spellID then
			StartFrameUpdate(prepare_sound, text_replace, dur, frame, spellID, expirationTime)
		end
	elseif event == "DBM_TIMER_STOP" then
		local spellID = ...
		if spellID == DBM_spellID then
			StopFrameUpdate(frame)
		end
	elseif event == "BW_TIMER_STOP" then
		local spellID = ...
		if spellID == BW_spellID then
			StopFrameUpdate(frame)
		end
	end
end

-- 技能倒计时模板
local function GetCooldownData(self)
	if self.data.info[self.dif] and self.data.info[self.dif][self.phase] then
		for index, v in pairs(self.data.info[self.dif][self.phase]) do			
			if type(v) == "table" then
				if self.data.info[self.dif][self.phase][self.phase_count] then
					return self.data.info[self.dif][self.phase][self.phase_count][self.count]
				end
			else
				return self.data.info[self.dif][self.phase][self.count]
			end
			break
		end		
	elseif self.data.info["all"] and self.data.info["all"][self.phase] then
		for index, v in pairs(self.data.info["all"][self.phase]) do
			if type(v) == "table" then
				if self.data.info["all"][self.phase][self.phase_count] then
					return self.data.info["all"][self.phase][self.phase_count][self.count]
				end
			else
				return self.data.info["all"][self.phase][self.count]
			end
			break
		end
	end
end
T.UpdateCooldownTimer = function(cast_event, cast_unit, cast_spellID, text, self, event, ...)
	if event == cast_event then
		local unit, _, spellID = ...
		if unit == cast_unit and spellID == cast_spellID then
			self.count = self.count + 1
			local cd = GetCooldownData(self)
			if cd then
				T.Start_Text_DelayTimer(self, cd, text, true)
			end
		end
	elseif event == "ENCOUNTER_PHASE" then
		self.phase, self.phase_count = ...
		if self.phase == 1 then
			self.phase_count = self.phase_count + 1
		end
		self.count  = 1
		
		local cd = GetCooldownData(self)
		if cd then
			T.Start_Text_DelayTimer(self, cd, text, true)
		end
	elseif event == "ENCOUNTER_START" then
		self.dif = select(3, ...)
		self.phase = 1
		self.phase_count = 1
		self.count  = 1
		
		if self.data.cd_args and not self.timer_init then
			for k, v in pairs(self.data.cd_args) do
				self[k] = v
			end
			
			self.timer_init = true
		end

		local cd = GetCooldownData(self)
		if cd then
			T.Start_Text_DelayTimer(self, cd, text, true)
		end
	end
end

----------------------------------------------------------
------------------[[    技能CD同步    ]]------------------
----------------------------------------------------------
local SpellCDShare = CreateFrame("Frame")

local ClassShareSpellData = {
	PRIEST = {
		15487, -- 沉默
		33206, -- 痛苦压制
		47788, -- 守护之魂
	},
	DRUID = {
		78675, -- 日光术
		106839, -- 迎头痛击
		102342, -- 铁木树皮
	},
	SHAMAN = { 
		57994, -- 风剪
	},
	PALADIN = {
		96231, -- 责难
		31935, -- 复仇者之盾
		633, -- 圣疗术
		1022, -- 保护祝福
		6940, -- 牺牲祝福
		1044, -- 自由祝福
	},
	WARRIOR = { 
		6552, -- 拳击
	},
	MAGE = { 
		2139, -- 法术反制
	},
	WARLOCK = { 
		19647, -- 法术封锁
	},
	HUNTER = { 
		147362, -- 反制射击
	},
	ROGUE = { 
		1766, -- 脚踢
	},
	DEATHKNIGHT = {
		47528, -- 心灵冰冻
	},
	MONK = {
		116705, -- 切喉手
		116849, -- 作茧缚命
	},
	DEMONHUNTER = {
		183752, -- 瓦解
	},
	EVOKER = {
		351338, -- 镇压
		357170, -- 时间膨胀
	},
}

local function GetMySpellCD()
	local info = {}
	if ClassShareSpellData[G.myClass] then
		for i, spellID in pairs(ClassShareSpellData[G.myClass]) do
			local learned = IsSpellKnown(spellID) or IsSpellKnown(spellID, true)
			if learned then	
				local tooltip_info = C_TooltipInfo.GetSpellByID(spellID)
				if tooltip_info then
					local cd_text = tooltip_info.lines[3].rightText
					local cd = select(3, string.find(cd_text, "(%d+)"))				
					table.insert(info, {spellID, cd})
				else
					T.test_msg(spellID, "GetMySpellCD bug")
				end
			else
				table.insert(info, {spellID, 0})
			end
		end
	end
	return info
end

local function SendMySpellCD()
	local spellIDs = GetMySpellCD()
	for i, info in pairs(spellIDs) do
		local spellID, cd = unpack(info)	
		T.addon_msg("ShareSpellCD,"..spellID..","..cd..","..G.PlayerGUID, "GROUP")
	end
end

local my_cd_states = {}

local function GetMySpellState()
	local info = {}
	if ClassShareSpellData[G.myClass] then
		for i, spellID in pairs(ClassShareSpellData[G.myClass]) do
			local state = MySpellCheck(spellID) and "READY" or "CD"
			if not my_cd_states[spellID] or my_cd_states[spellID] ~= state then
				table.insert(info, {spellID, state})
				my_cd_states[spellID] = state
			end
		end
	end
	return info
end

local function SendMySpellState()
	local spellIDs = GetMySpellState()
	if #spellIDs > 0 then
		for i, info in pairs(spellIDs) do
			local spellID, state = unpack(info)	
			T.addon_msg("ShareSpellState,"..spellID..","..state, "GROUP")
			--print("ShareSpellState,"..spellID..","..state)
		end
	end
end

SpellCDShare:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" or event == "GROUP_FORMED" then
		T.addon_msg("RequestSpellCD", "GROUP")
	elseif event == "SPELLS_CHANGED" then		
		C_Timer.After(.1, function()
			T.FireEvent("SPELLS_CHANGED_DELAY")
		end)
	elseif event == "SPELLS_CHANGED_DELAY" then
		SendMySpellCD()
	elseif event == "ADDON_MSG" then
		local channel, sender, tag = ...
		if tag == "RequestSpellCD" then
			SendMySpellCD()
		end
	elseif event == "SPELL_UPDATE_COOLDOWN" or event == "LEARNED_SPELL_IN_TAB" then
		SendMySpellState()
	elseif event == "ENCOUNTER_START" then
		SendMySpellState()
	elseif event == "READY_CHECK" then
		T.addon_msg("RequestSpellCD", "GROUP")
		SendMySpellState()
	end
end)

local spell_cd_events = {
	["PLAYER_LOGIN"] = true,
	["READY_CHECK"] = true,
	["GROUP_FORMED"] = true,
	["SPELLS_CHANGED"] = true,
	["SPELLS_CHANGED_DELAY"] = true,
	["ADDON_MSG"] = true,
	["SPELL_UPDATE_COOLDOWN"] = true,
	["LEARNED_SPELL_IN_TAB"] = true,
}

T.RegisterEventAndCallbacks(SpellCDShare, spell_cd_events)
----------------------------------------------------------
------------------[[    姓名板提示    ]]------------------
----------------------------------------------------------
local InterruptSpellData = {
	[351338] = true, -- 镇压
	[78675] = true, -- 日光术
	[106839] = true, -- 迎头痛击
	[15487] = true, -- 沉默
	[96231] = true, -- 责难
	[31935] = true, -- 复仇者之盾
	[57994] = true, -- 风剪
	[116705] = true, -- 切喉手
	[183752] = true, -- 瓦解
	[2139] = true, -- 法术反制
	[147362] = true, -- 反制射击
	[1766] = true, -- 脚踢
	[47528] = true, -- 心灵冰冻
	[6552] = true, -- 拳击
}

local PlateAlertFrames = {}
local PlateIconHolders = {}
local PlateAuraSourceFrames = {}

local Npc = {} -- 打断npcID
local InterruptMrtData = {} -- MRT打断人员信息
local InterruptMrtDataCount = {} -- MRT打断轮次信息
local InterruptData = {} -- 当前打断轮次
local Hidden_Interrupt_Npcs = {} -- 临时禁用的打断npcID

local AutoAssignNpc = {}
local InterruptPlayers = {} -- 有打断的队友
local InterruptQueue = {} -- 等待分配打断的怪
local InterruptAssignment = {} -- 已经分配打断的怪
local InterruptDataAuto = {} -- 当前打断轮次（自动）

G.Npc = Npc
G.AutoAssignNpc = AutoAssignNpc
G.Hidden_Interrupt_Npcs = Hidden_Interrupt_Npcs
G.PlateIconHolders = PlateIconHolders

local NamePlateAlertTrigger = CreateFrame("Frame", G.addon_name.."NamePlateAlertTrigger", UIParent)

----------------------------------------------------------
-- 姓名板API

-- 预备打断音效
T.Play_interrupt_sound = function()
	if JST_CDB["PlateAlertOption"]["interrupt_sound"] ~= "none" then
		T.PlaySound(JST_CDB["PlateAlertOption"]["interrupt_sound"])
	end
end

-- 打断音效
T.Play_interrupt_sound_cast = function()	
	if JST_CDB["PlateAlertOption"]["interrupt_sound_cast"] ~= "none" then
		T.PlaySound(JST_CDB["PlateAlertOption"]["interrupt_sound_cast"])
	end
end

-- 姓名板高亮(unit)
local function UpdatePlateUnit_Highlight(unit, color, tag, action)
	local frame = T.GetUnitNameplate(unit)
	if frame then	
		if action == "start" then
			LCG.PixelGlow_Start(frame, color, 12, .25, nil, 3, 3, 3, true, tag)
		elseif action == "stop" then
			LCG.PixelGlow_Stop(frame, tag)
		end
	end
end

-- 更新打断序号
local function UpdateInterruptInd(GUID, mark)
	--print("更新序数", GUID)
	
	local npcID = select(6, string.split("-", GUID))
	local mark_ind = mark or 9

	local num
	if InterruptMrtDataCount[npcID] then
		if InterruptMrtDataCount[npcID][mark_ind] then -- 有mrt数据
			num = InterruptMrtDataCount[npcID][mark_ind]
		elseif InterruptMrtDataCount[npcID][9] then -- 有mrt数据(不区分标记)
			num = InterruptMrtDataCount[npcID][9]
		else -- 有mrt数据 但没有当前标记或无标记的
			num = Npc[npcID]
		end
	else
		num = Npc[npcID]
	end
	
	if num then
		if not InterruptData[GUID] or InterruptData[GUID] >= num then
			InterruptData[GUID] = 1
		else
			InterruptData[GUID] = InterruptData[GUID] + 1
		end
	end
end

-- 更新打断序号（自动）
local function UpdateInterruptIndAuto(GUID)
	--print("更新序数", GUID)
	if not InterruptAssignment[GUID] then return end
	
	local num = #InterruptAssignment[GUID]	
	
	if num then
		if not InterruptDataAuto[GUID] or InterruptDataAuto[GUID] >= num then
			InterruptDataAuto[GUID] = 1
		else
			InterruptDataAuto[GUID] = InterruptDataAuto[GUID] + 1
		end
	end
end

-- 更新打断文字
local function UpdateInterruptText(unitFrame)
	C_Timer.After(.05, function()
		if not unitFrame.unit then return end
		local GUID = UnitGUID(unitFrame.unit)
		local npcID = select(6, string.split("-", GUID))
		if Npc[npcID] then -- 有打断信息
			local icon = unitFrame.icon_bg.interrupticon
			local ind = InterruptData[GUID]
			if icon and ind then
				--print("更新文字", GUID)
				icon.center_text:SetText(ind)
				-- 显示名字
				local mark = GetRaidTargetIndex(unitFrame.unit) or 9
				if InterruptMrtData[npcID] and InterruptMrtData[npcID][mark] then -- 在MRT中有该标记的打断信息
					if InterruptMrtData[npcID][mark][ind] then -- 本轮有信息
						local t = {}
						for i, GUID in pairs(InterruptMrtData[npcID][mark][ind]) do
							if GUID == G.PlayerGUID then
								T.Play_interrupt_sound()
							end
							local color_name = T.ColorNickNameByGUID(GUID)
							table.insert(t, color_name)
						end
						icon.top:SetText(table.concat(t, " "))
					else -- 本轮无信息
						icon.top:SetText("--")
					end
				elseif InterruptMrtData[npcID] and InterruptMrtData[npcID][9] then -- 在MRT中有无标记打断信息（小怪有标记而打断讯息无标记）
					if InterruptMrtData[npcID][9][ind] then -- 本轮有信息
						local t = {}
						for i, GUID in pairs(InterruptMrtData[npcID][9][ind]) do
							if GUID == G.PlayerGUID then
								T.Play_interrupt_sound()
							end
							local color_name = T.ColorNickNameByGUID(GUID)
							table.insert(t, color_name)
						end
						icon.top:SetText(table.concat(t, " "))
					else -- 本轮无信息
						icon.top:SetText("--")
					end
				else -- 在MRT中无打断信息
					icon.top:SetText("")
				end
			end
		end
	end)
end

-- 更新打断文字（自动）
local function UpdateInterruptTextAuto(unitFrame)
	C_Timer.After(.05, function()
		if not unitFrame.unit then return end
		local GUID = UnitGUID(unitFrame.unit)	
		if InterruptAssignment[GUID] then -- 有打断信息
			local icon = unitFrame.icon_bg.interrupticon_auto
			local ind = InterruptDataAuto[GUID]
			if icon and ind and InterruptAssignment[GUID][ind] then
				local current_name = ind.." "..InterruptAssignment[GUID][ind].format_name
				local queue_name = ""
				for i, info in pairs(InterruptAssignment[GUID]) do
					if i ~= ind then
						if queue_name ~= "" then
							queue_name = queue_name.."\n"
						end
						queue_name = queue_name..i.." "..info.format_name
					end
				end
				icon.center_text:SetText(current_name)
				icon.top:SetText(queue_name)
			end
		end
	end)
end

-- 与我相关的打断
local function InterruptDataHasMine(npcID, mark)
	if InterruptMrtData[npcID] and InterruptMrtData[npcID][mark] then -- 在MRT中有该标记的打断信息
		for ind, t in pairs(InterruptMrtData[npcID][mark]) do
			for i, GUID in pairs(t) do
				--print(mark, ind, i, GUID)
				if GUID == G.PlayerGUID then
					--print("FIND", mark, ind, i, GUID)
					return true
				end
			end
		end
	elseif InterruptMrtData[npcID] and InterruptMrtData[npcID][9] then -- 在MRT中有无标记打断信息（小怪有标记而打断讯息无标记）
		for ind, t in pairs(InterruptMrtData[npcID][9]) do
			for i, GUID in pairs(t) do
				--print("none", ind, i, GUID)
				if GUID == G.PlayerGUID then
					--print("FIND", "none", ind, i, GUID)
					return true
				end
			end
		end
	end
end

-- 与我相关的打断(自动)
local function InterruptDataHasMineAuto(GUID)
	if InterruptAssignment[GUID] then
		for i, info in pairs(InterruptAssignment[GUID]) do
			if info.GUID == G.PlayerGUID then
				return true
			end
		end
	end
end

-- 隐藏打断图标
local function HideInterruptIcon(unitFrame)
	local icon = unitFrame.icon_bg.interrupticon
	if icon then
		icon:Hide()
		icon.top:SetText("")
		icon.center_text:SetText("")
		icon.animtex:Hide()
		icon:SetScript("OnUpdate", nil)
	end
end

-- 隐藏打断图标（自动）
local function HideInterruptIconAuto(unitFrame)
	local icon = unitFrame.icon_bg.interrupticon_auto
	if icon then
		icon:Hide()
		icon.top:SetText("")
		icon.center_text:SetText("")
		icon.animtex:Hide()
		icon:SetScript("OnUpdate", nil)
	end
end

-- 打断声音
local function PlayInterruptSound(unit, GUID)
	if unit and GUID then
		local npcID = select(6, string.split("-", GUID))
		local mark = GetRaidTargetIndex(unit) or 9
		if InterruptMrtData[npcID] and InterruptMrtData[npcID][mark] then
			local ind = InterruptData[GUID]
			if ind and InterruptMrtData[npcID][mark][ind] then -- 本轮有信息
				for i, player_GUID in pairs(InterruptMrtData[npcID][mark][ind]) do
					if player_GUID == G.PlayerGUID then
						T.Play_interrupt_sound_cast()
						break
					end
				end
			end
		end
	end
end

-- 打断声音（自动）
local function PlayInterruptSoundAuto(GUID)
	if GUID and InterruptAssignment[GUID] and InterruptDataAuto[GUID] then
		local ind = InterruptDataAuto[GUID]
		if InterruptAssignment[GUID][ind] and InterruptAssignment[GUID][ind].GUID == G.PlayerGUID then
			T.Play_interrupt_sound_cast()
		end		
	end
end

--0------------------------------------------------------------------
-- 刷新团队标记
local function UpdateRaidTarget(unitFrame)
	if not unitFrame or not unitFrame.unit then return end
	local frame = unitFrame.icon_bg
	local unit = unitFrame.unit
	local index = GetRaidTargetIndex(unit)
	if frame.spellicon then
		if index then
			SetRaidTargetIconTexture(frame.spellicon.raid_mark_icon, index)
			frame.spellicon.raid_mark_icon:Show()
		else
			frame.spellicon.raid_mark_icon:Hide()
		end
	end
	if frame.interrupticon then
		if index then
			SetRaidTargetIconTexture(frame.interrupticon.raid_mark_icon, index)
			frame.interrupticon.raid_mark_icon:Show()
		else
			frame.interrupticon.raid_mark_icon:Hide()
		end
		T.UpdateInterruptSpells(unitFrame, "INIT", unit, UnitGUID(unit))
	end
	if frame.interrupticon_auto then
		if index then
			SetRaidTargetIconTexture(frame.interrupticon_auto.raid_mark_icon, index)
			frame.interrupticon_auto.raid_mark_icon:Show()
		else
			frame.interrupticon_auto.raid_mark_icon:Hide()
		end
	end
end

--1------------------------------------------------------------------
-- 能量小圆圈
local function CreateCircleIcon(parent)
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(JST_CDB["PlateAlertOption"]["size"], JST_CDB["PlateAlertOption"]["size"])
	button:SetPoint("LEFT", parent:GetParent():GetParent(), "RIGHT", JST_CDB["PlateAlertOption"]["x"], 0)
	
	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3) -- 材质
	button.icon:SetAllPoints()
	button.icon:SetTexture(G.media.circle)
	
	button.value = T.createtext(button, "OVERLAY", 14, "OUTLINE", "CENTER") -- 数值
	button.value:SetPoint("CENTER")
	
	button.anim = button:CreateAnimationGroup()
	button.anim:SetLooping("REPEAT")

	button.alpha = button.anim:CreateAnimation('Alpha')
	button.alpha:SetChildKey("icon")
	button.alpha:SetFromAlpha(1)
	button.alpha:SetToAlpha(.3)
	button.alpha:SetDuration(.5)

	button:Hide()
	
	return button
end

-- 刷新能量
local function UpdatePower(unitFrame)
	if not unitFrame.npcID or not unitFrame.unit or not T.ValueFromPath(PlateAlertFrames, {"PlatePower", unitFrame.npcID}) or not T.ValueFromPath(JST_CDB, {"PlateAlert", "PlatePower", unitFrame.npcID, "enable"}) then
		if unitFrame.icon_bg.powericon then
			unitFrame.icon_bg.powericon:Hide()
		end
		return
	end
	
	unitFrame.icon_bg.powericon = unitFrame.icon_bg.powericon or CreateCircleIcon(unitFrame.icon_bg)
	
	local pp = UnitPower(unitFrame.unit) -- 获取数值
	if pp >= 50 then
		unitFrame.icon_bg.powericon.icon:SetVertexColor(1, (200-pp*2)/100, 0, .5) -- 黄色到红色
	else
		unitFrame.icon_bg.powericon.icon:SetVertexColor(pp*2/100, 1, 0, .5) -- 绿色到黄色
	end
	unitFrame.icon_bg.powericon.value:SetText(pp)
	
	local info = T.ValueFromPath(PlateAlertFrames, {"PlatePower", unitFrame.npcID})
	
	if info.hl then
		if pp >= info.hl then			
			if not unitFrame.icon_bg.powericon.anim:IsPlaying() then
				unitFrame.icon_bg.powericon.anim:Play()
			end
		else	
			if unitFrame.icon_bg.powericon.anim:IsPlaying() then	
				unitFrame.icon_bg.powericon.anim:Stop()
			end
		end
	else
		if unitFrame.icon_bg.powericon.anim:IsPlaying() then	
			unitFrame.icon_bg.powericon.anim:Stop()
		end
	end
	
	unitFrame.icon_bg.powericon:Show()
end

--2------------------------------------------------------------------
-- 施法图标
local function CreatePlateSpellIcon(parent, tag)
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(JST_CDB["PlateAlertOption"]["size"], JST_CDB["PlateAlertOption"]["size"])
	
	-- 图标
	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-1, 1)
	button.icon:SetTexture(G.media.blank)
	button.icon:SetTexCoord(.08, .92, 0.08, 0.92)
	
	-- 外边框
	button.bd = button:CreateTexture(nil, "ARTWORK", nil, 6)
	button.bd:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.bd:SetVertexColor(0, 0, 0)
	button.bd:SetPoint("TOPLEFT",button,"TOPLEFT", -1, 1)
	button.bd:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT", 1, -1)
	
	-- 内边框
	button.overlay = button:CreateTexture(nil, "ARTWORK", nil, 7)
	button.overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.overlay:SetAllPoints(button)
	button.overlay:SetVertexColor(1, 1, 1)
	
	-- 左上符号
	button.raid_mark_icon = button:CreateTexture(nil, "OVERLAY", nil, 7)
	button.raid_mark_icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	button.raid_mark_icon:SetSize(10, 10)
	button.raid_mark_icon:SetPoint("TOPLEFT", button,"TOPLEFT", 0, 0)
	
	-- 冷却转圈
	button.cd_frame = CreateFrame("COOLDOWN", nil, button, "CooldownFrameTemplate")
	button.cd_frame:SetPoint("TOPLEFT", 1, -1)
	button.cd_frame:SetPoint("BOTTOMRIGHT", -1, 1)
	button.cd_frame:SetDrawEdge(false)
	button.cd_frame:SetAlpha(.7)
	
	button:Hide()
	
	parent.spellicon = Button
	parent.QueueIcon(button, tag)
	
	return button
end

-- 刷新施法图标
local function UpdatePlateSpellIcon(button, icon, duration, rm)
	button.icon:SetTexture(icon)
	button.cd_frame:SetCooldown(GetTime(), duration)	
	if rm then
		SetRaidTargetIconTexture(button.raid_mark_icon, rm)
	end	
	button:Show()
end

-- 刷新施法
local function UpdateSpells(unitFrame, event, unit, GUID, spellID)	
	if not unitFrame.npcID or not unitFrame.unit or not T.ValueFromPath(PlateAlertFrames, {"PlateSpells", spellID}) or not T.ValueFromPath(JST_CDB, {"PlateAlert", "PlateSpells", spellID, "enable"}) then
		if unitFrame.icon_bg.spellicon then
			unitFrame.icon_bg.spellicon:Hide()
		end
		return
	end
	
	local info = T.ValueFromPath(PlateAlertFrames, {"PlateSpells", spellID})
	
	if event == "UNIT_SPELLCAST_START" then -- 开始施法
		local _, _, texture, startTimeMS, endTimeMS, _, _, notInterruptible, casting_spellID = UnitCastingInfo(unit)
		if casting_spellID == spellID then
			local rm = GetRaidTargetIndex(unit) or 0
			local icon = unitFrame.icon_bg.spellicon or CreatePlateSpellIcon(unitFrame.icon_bg, "PlateSpells")
			UpdatePlateSpellIcon(icon, texture, endTimeMS/1000 - startTimeMS/1000, rm)
			if info.hl_np then
				UpdatePlateUnit_Highlight(unit, info.color, "PlateSpells", "start")
			end
		end
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" then -- 开始引导
		local _, _, texture, startTimeMS, endTimeMS, _, notInterruptible, channel_spellID = UnitChannelInfo(unit)
		if channel_spellID == spellID then
			local rm = GetRaidTargetIndex(unit) or 0
			local icon = unitFrame.icon_bg.spellicon or CreatePlateSpellIcon(unitFrame.icon_bg, "PlateSpells")
			UpdatePlateSpellIcon(icon, texture, endTimeMS/1000 - startTimeMS/1000, rm)
			if info.hl_np then
				UpdatePlateUnit_Highlight(unit, info.color, "PlateSpells", "start")
			end
		end
	elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
		local _, _, texture, startTimeMS, endTimeMS, _, notInterruptible, channel_spellID = UnitChannelInfo(unit)
		if channel_spellID == spellID then
			local icon = unitFrame.icon_bg.spellicon
			if icon then
				UpdatePlateSpellIcon(icon, texture, endTimeMS/1000 - startTimeMS/1000)
			end
		end
	elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		if UnitCastingInfo(unit) or UnitChannelInfo(unit) then return end
		if unitFrame.icon_bg.ActiveIcons["PlateSpells"] then
			unitFrame.icon_bg.ActiveIcons["PlateSpells"]:Hide()
			UpdatePlateUnit_Highlight(unit, nil, "PlateSpells", "stop")
		end
	end
end

--3------------------------------------------------------------------
-- 打断图标
local function CreateInterruptSpellIcon(parent, tag)
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(JST_CDB["PlateAlertOption"]["size"], JST_CDB["PlateAlertOption"]["size"])
	button.t = 0
	
	-- 图标
	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-1, 1)
	button.icon:SetTexture(G.media.blank)
	button.icon:SetTexCoord(.08, .92, 0.08, 0.92)
		
	-- 外边框
	button.bd = button:CreateTexture(nil, "ARTWORK", nil, 6)
	button.bd:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.bd:SetVertexColor(0, 0, 0)
	button.bd:SetPoint("TOPLEFT",button,"TOPLEFT", -1, 1)
	button.bd:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT", 1, -1)
		
	-- 内边框
	button.overlay = button:CreateTexture(nil, "ARTWORK", nil, 7)
	button.overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.overlay:SetAllPoints(button)
	button.overlay:SetVertexColor(1, 1, 1)
	
	-- 左上符号
	button.raid_mark_icon = button:CreateTexture(nil, "OVERLAY", nil, 7)
	button.raid_mark_icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	button.raid_mark_icon:SetSize(10, 10)
	button.raid_mark_icon:SetPoint("TOPLEFT", button,"TOPLEFT", 0, 0)
	
	-- 上方文字
	button.top = T.createtext(button, "OVERLAY", tag == "interrupticon_auto" and 10 or 14, "OUTLINE", "CENTER")
	button.top:SetPoint("BOTTOM", button, "TOP", 0, 5)
	
	-- 中间数字
	button.center_text = T.createtext(button, "OVERLAY", tag == "interrupticon_auto" and 14 or 21, "OUTLINE", "CENTER")
	button.center_text:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.center_text:SetTextColor(1, 0, 0)

	button.animtex = button:CreateTexture(nil, "OVERLAY", nil, 4)
	button.animtex:SetAllPoints(button)
	button.animtex:SetTexture(G.media.blank)
	button.animtex:SetVertexColor(0, 1, 0)
	button.animtex:Hide()
	
	button.anim = button:CreateAnimationGroup()
	button.anim:SetLooping("REPEAT")
	
	button.anim:SetScript("OnPlay", function(self)
		button.animtex:Show()
	end)
	
	button.anim:SetScript("OnStop", function(self)
		button.animtex:Hide()
		button.animtex:SetAlpha(1)
	end)
		
	button.timer = button.anim:CreateAnimation("Alpha")
	button.timer:SetDuration(.5)
	button.timer:SetChildKey("animtex")
	button.timer:SetFromAlpha(1)
	button.timer:SetToAlpha(.2)
	
	button:Hide()
	
	parent[tag] = button
	parent.QueueIcon(button, tag)
	
	return button
end

-- 刷新打断
local function UpdateInterruptSpells(unitFrame, event, unit, GUID, spellID)
	if not unitFrame.npcID or not unitFrame.unit or not PlateAlertFrames["PlateInterrupt"] then
		HideInterruptIcon(unitFrame)
		return
	end
	
	if event == "INIT" then -- 单位刷新类事件
		if Npc[unitFrame.npcID] and not Hidden_Interrupt_Npcs[unitFrame.npcID] then -- 有单位且是需要监测的单位
			local icon = unitFrame.icon_bg.interrupticon or CreateInterruptSpellIcon(unitFrame.icon_bg, "interrupticon")			
			icon.GUID = GUID
			
			local mark = GetRaidTargetIndex(unit) or 9
			if not JST_CDB["PlateAlertOption"]["interrupt_only_mine"] or InterruptDataHasMine(unitFrame.npcID, mark) then
				InterruptData[GUID] = InterruptData[GUID] or 1
				UpdateInterruptText(unitFrame)
				icon:Show()
			else
				HideInterruptIcon(unitFrame)
			end
		else -- 隐藏图标
			HideInterruptIcon(unitFrame)
		end
	elseif spellID then -- 施法类事件
		local icon = unitFrame.icon_bg.interrupticon
		if icon then
			local info = T.ValueFromPath(PlateAlertFrames, {"PlateInterrupt", spellID})
			if info then
				local enable = T.ValueFromPath(JST_CDB, {"PlateAlert", "PlateInterrupt", spellID, "enable"})
				if enable then
					if event == "UNIT_SPELLCAST_START" then -- 开始施法
						local _, _, _, startTimeMS, endTimeMS, _, _, notInterruptible, casting_spellID = UnitCastingInfo(unit)
						if casting_spellID == spellID then
							if info.hl_np then
								UpdatePlateUnit_Highlight(unit, info.color, "PlateInterrupt", "start")
							end
							
							icon.anim:Play()
							PlayInterruptSound(unit, GUID)
						end
					elseif event == "UNIT_SPELLCAST_CHANNEL_START" then -- 开始引导
						local _, _, _, startTimeMS, endTimeMS, _, notInterruptible, channel_spellID = UnitChannelInfo(unit)
						if channel_spellID == spellID then
							if info.hl_np then
								UpdatePlateUnit_Highlight(unit, info.color, "PlateInterrupt", "start")
							end
							
							icon.anim:Play()
							PlayInterruptSound(unit, GUID)
						end
					elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
						local _, _, _, startTimeMS, endTimeMS, _, notInterruptible, channel_spellID = UnitChannelInfo(unit)
						if channel_spellID == spellID then
							icon.exp = endTimeMS/1000
						end		
					elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
						if UnitCastingInfo(unit) or UnitChannelInfo(unit) then return end
						UpdateInterruptText(unitFrame)
						icon:SetScript("OnUpdate", nil)
						icon.anim:Stop()
						UpdatePlateUnit_Highlight(unit, nil, "PlateInterrupt", "stop")
					end
				end
			end
		end
	end
end
T.UpdateInterruptSpells = UpdateInterruptSpells

--4------------------------------------------------------------------
-- 自动打断图标
local function UpdateInterruptAssignment(unitFrame, event, unit, GUID, spellID)
	if not unitFrame.npcID or not unitFrame.unit or not PlateAlertFrames["PlateInterruptAuto"] then
		HideInterruptIconAuto(unitFrame)
		return
	end
	
	if event == "INIT" then -- 单位刷新类事件		
		if AutoAssignNpc[unitFrame.npcID] and InterruptAssignment[GUID] and #InterruptAssignment[GUID] > 0 then
			local icon = unitFrame.icon_bg.interrupticon_auto or CreateInterruptSpellIcon(unitFrame.icon_bg, "interrupticon_auto")			
			icon.GUID = GUID
			
			if not JST_CDB["PlateAlertOption"]["interrupt_only_mine"] or InterruptDataHasMineAuto(GUID) then
				InterruptDataAuto[GUID] = InterruptDataAuto[GUID] or 1
				UpdateInterruptTextAuto(unitFrame)
				UpdateRaidTarget(unitFrame)
				icon:Show()
				T.test_msg("显示打断图标"..T.GetFomattedNameFromNpcID(unitFrame.npcID))
			else
				HideInterruptIconAuto(unitFrame)
			end
		else -- 隐藏图标
			HideInterruptIconAuto(unitFrame)
		end
	elseif spellID then -- 施法类事件
		local icon = unitFrame.icon_bg.interrupticon_auto
		if icon then
			local info = T.ValueFromPath(PlateAlertFrames, {"PlateInterruptAuto", spellID})
			if info then
				local enable = T.ValueFromPath(JST_CDB, {"PlateAlert", "PlateInterruptAuto", spellID, "enable"})
				if enable then
					if event == "UNIT_SPELLCAST_START" then -- 开始施法
						local _, _, _, startTimeMS, endTimeMS, _, _, notInterruptible, casting_spellID = UnitCastingInfo(unit)
						if casting_spellID == spellID then
							if info.hl_np then
								UpdatePlateUnit_Highlight(unit, info.color, "PlateInterruptAuto", "start")
							end
							
							icon.anim:Play()
							PlayInterruptSoundAuto(GUID)
						end
					elseif event == "UNIT_SPELLCAST_CHANNEL_START" then -- 开始引导
						local _, _, _, startTimeMS, endTimeMS, _, notInterruptible, channel_spellID = UnitChannelInfo(unit)
						if channel_spellID == spellID then
							if info.hl_np then
								UpdatePlateUnit_Highlight(unit, info.color, "PlateInterruptAuto", "start")
							end
							
							icon.anim:Play()
							PlayInterruptSoundAuto(GUID)
						end
					elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
						local _, _, _, startTimeMS, endTimeMS, _, notInterruptible, channel_spellID = UnitChannelInfo(unit)
						if channel_spellID == spellID then
							icon.exp = endTimeMS/1000
						end		
					elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
						if UnitCastingInfo(unit) or UnitChannelInfo(unit) then return end
						UpdateInterruptTextAuto(unitFrame)
						icon:SetScript("OnUpdate", nil)
						icon.anim:Stop()
						UpdatePlateUnit_Highlight(unit, nil, "PlateInterruptAuto", "stop")
					end
				end
			end
		end
	end
end

--5------------------------------------------------------------------
-- 光环层数图标
local function CreatePlateStackAuraIcon(parent, tag) 
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(JST_CDB["PlateAlertOption"]["size"], JST_CDB["PlateAlertOption"]["size"])

	-- 图标
	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-1, 1)
	button.icon:SetTexture(G.media.blank)
	button.icon:SetTexCoord(.08, .92, 0.08, 0.92)
	
	-- 外边框
	button.bd = button:CreateTexture(nil, "ARTWORK", nil, 6)
	button.bd:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.bd:SetVertexColor(0, 0, 0)
	button.bd:SetPoint("TOPLEFT",button,"TOPLEFT", -1, 1)
	button.bd:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT", 1, -1)
	
	-- 内边框
	button.overlay = button:CreateTexture(nil, "ARTWORK", nil, 7)
	button.overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.overlay:SetAllPoints(button)
	button.overlay:SetVertexColor(1, 0, 0)
	
	-- 中间数字
	button.center_text = T.createtext(button, "OVERLAY", 21, "OUTLINE", "CENTER")
	button.center_text:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.center_text:SetTextColor(1, 0, 0)

	button:Hide()
	parent.QueueIcon(button, tag)
	
	return button
end

-- 刷新光环层数图标
local aura_stack_color = {{1, 1, 1}, {0, 1, 0}, {1, 1, 0}, {1, 0, 0},}
local function UpdatePlateStackAuraIcon(button, count)
	button.icon:SetTexture(G.media.blank) -- 图标
	button.center_text:SetText(count > 0 and count or "")
	if count and count > 0 then -- 层数
		local color = aura_stack_color[count] or aura_stack_color[4]
		button.icon:SetVertexColor(unpack(color))
	else
		button.icon:SetVertexColor(1, 1, 1)
	end
	
	button:Show()
end

-- 刷新光环层数
local function UpdatePlateStackAuras(unitFrame, unit, updateInfo)
	if not PlateAlertFrames.PlateStackAuras then return end
	
	if updateInfo == nil or updateInfo.isFullUpdate then
		for tag, icon in pairs(unitFrame.icon_bg.ActiveIcons) do	
			if string.find(tag, "PlateStackAuras") then
				icon:Hide()
				UpdatePlateUnit_Highlight(unit, nil, "PlateStackAuras", "stop")
			end
		end
	
		for spellID, info in pairs(PlateAlertFrames.PlateStackAuras) do
			AuraUtil.ForEachAura(unit, info.aura_type or "HELPFUL", nil, function(AuraData)
				if spellID == AuraData.spellId then
					local enable = T.ValueFromPath(JST_CDB, {"PlateAlert", "PlateStackAuras", spellID, "enable"})
					if enable then
						local auraID = AuraData.auraInstanceID
						local icon = CreatePlateStackAuraIcon(unitFrame.icon_bg, "PlateStackAuras"..auraID)		
						UpdatePlateStackAuraIcon(icon, AuraData.applications)
						if info.hl_np then
							UpdatePlateUnit_Highlight(unit, info.color, "PlateStackAuras", "start")
						end
					end
				end		
			end, true)
		end
	else
		if updateInfo.addedAuras ~= nil then
			for _, AuraData in pairs(updateInfo.addedAuras) do
				local spellID = AuraData.spellId
				local info = T.ValueFromPath(PlateAlertFrames, {"PlateStackAuras", spellID})				
				if info then
					local enable = T.ValueFromPath(JST_CDB, {"PlateAlert", "PlateStackAuras", spellID, "enable"})
					if enable then
						local auraID = AuraData.auraInstanceID
						if not unitFrame.icon_bg.ActiveIcons["PlateStackAuras"..auraID] then
							local icon = CreatePlateStackAuraIcon(unitFrame.icon_bg, "PlateStackAuras"..auraID)		
							UpdatePlateStackAuraIcon(icon, AuraData.applications)
							if info.hl_np then
								UpdatePlateUnit_Highlight(unit, info.color, "PlateStackAuras", "start")
							end
						end
					end
				end
			end
		end
		if updateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do
				local icon = unitFrame.icon_bg.ActiveIcons["PlateStackAuras"..auraID]
				if icon then
					local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
					if AuraData then
						UpdatePlateStackAuraIcon(icon, AuraData.applications)
					else
						icon:Hide()
						UpdatePlateUnit_Highlight(unit, nil, "PlateStackAuras", "stop")
					end
				end			
			end
		end
		if updateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
				local icon = unitFrame.icon_bg.ActiveIcons["PlateStackAuras"..auraID]
				if icon then
					icon:Hide()
					UpdatePlateUnit_Highlight(unit, nil, "PlateStackAuras", "stop")
				end
			end
		end
	end
end

--6------------------------------------------------------------------
-- 光环图标
local function CreatePlateAuraIcon(parent, tag) 
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(JST_CDB["PlateAlertOption"]["size"], JST_CDB["PlateAlertOption"]["size"])

	-- 图标
	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-1, 1)
	button.icon:SetTexture(G.media.blank)
	button.icon:SetTexCoord(.08, .92, 0.08, 0.92)
	
	-- 外边框
	button.bd = button:CreateTexture(nil, "ARTWORK", nil, 6)
	button.bd:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.bd:SetVertexColor(0, 0, 0)
	button.bd:SetPoint("TOPLEFT",button,"TOPLEFT", -1, 1)
	button.bd:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT", 1, -1)
	
	-- 内边框
	button.overlay = button:CreateTexture(nil, "ARTWORK", nil, 7)
	button.overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.overlay:SetAllPoints(button)
	button.overlay:SetVertexColor(1, 0, 0)
	
	-- 魔法、激怒符号
	button.aura_type_icon = button:CreateTexture(nil, "OVERLAY", nil, 7)
	button.aura_type_icon:SetTexture([[Interface\EncounterJournal\UI-EJ-Icons]])
	button.aura_type_icon:SetSize(20, 20)
	button.aura_type_icon:SetPoint("TOPRIGHT", button,"TOPRIGHT", 6, 6)
	button.aura_type_icon:Hide()
	
	-- 冷却转圈
	button.cd_frame = CreateFrame("COOLDOWN", nil, button, "CooldownFrameTemplate")
	button.cd_frame:SetPoint("TOPLEFT", 1, -1)
	button.cd_frame:SetPoint("BOTTOMRIGHT", -1, 1)
	button.cd_frame:SetDrawEdge(false)
	button.cd_frame:SetAlpha(.7)
	
	-- 层数
	button.text = T.createtext(button, "OVERLAY", 7, "OUTLINE", "RIGHT")
	button.text:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, 2)
	button.text:SetTextColor(.4, .95, 1)
			
	button:Hide()
	parent.QueueIcon(button, tag)
	
	return button
end

-- 刷新光环图标
local function UpdatePlateAuraIcon(button, icon, count, duration, expirationTime, debuffType)
	local color = debuffType and DebuffTypeColor[debuffType] or DebuffTypeColor.none -- 颜色
	
	button.overlay:SetVertexColor(color.r, color.g, color.b)
	button.icon:SetTexture(icon) -- 图标
	if count and count > 0 then
		button.text:SetText(count)
	else
		button.text:SetText("")
	end	
	button.cd_frame:SetCooldown(expirationTime - duration, duration) -- 冷却转圈
	
	if debuffType == "Magic" then
		T.EncounterJournal_SetFlagIcon(button.aura_type_icon, 7)
	elseif debuffType == "Enrage" then
		T.EncounterJournal_SetFlagIcon(button.aura_type_icon, 11)	
	else
		T.EncounterJournal_SetFlagIcon(button.aura_type_icon, 0)
	end
	
	button:Show()
end

-- 刷新光环
local function UpdatePlateAuras(unitFrame, unit, updateInfo)
	if not PlateAlertFrames.PlateAuras then return end
	
	if updateInfo == nil or updateInfo.isFullUpdate then
		for tag, icon in pairs(unitFrame.icon_bg.ActiveIcons) do
			if string.find(tag, "PlateAuras") then
				icon:Hide()
				UpdatePlateUnit_Highlight(unit, nil, "PlateAuras", "stop")
			end
		end
		
		for spellID, info in pairs(PlateAlertFrames.PlateAuras) do
			AuraUtil.ForEachAura(unit, info.aura_type or "HELPFUL", nil, function(AuraData)
				if spellID == AuraData.spellId then
					local enable = T.ValueFromPath(JST_CDB, {"PlateAlert", "PlateAuras", spellID, "enable"})
					if enable then
						local auraID = AuraData.auraInstanceID
						local icon = CreatePlateAuraIcon(unitFrame.icon_bg, "PlateAuras"..auraID)
						UpdatePlateAuraIcon(icon, AuraData.icon, AuraData.applications, AuraData.duration, AuraData.expirationTime, AuraData.dispelName)
						if info.hl_np then
							UpdatePlateUnit_Highlight(unit, info.color, "PlateAuras", "start")
						end
					end
				end
			end, true)
		end
	else
		if updateInfo.addedAuras ~= nil then
			for _, AuraData in pairs(updateInfo.addedAuras) do
				local spellID = AuraData.spellId
				local info = T.ValueFromPath(PlateAlertFrames, {"PlateAuras", spellID})
				if info then
					local enable = T.ValueFromPath(JST_CDB, {"PlateAlert", "PlateAuras", spellID, "enable"})
					if enable then
						local auraID = AuraData.auraInstanceID
						if not unitFrame.icon_bg.ActiveIcons["PlateAuras"..auraID] then
							local icon = CreatePlateAuraIcon(unitFrame.icon_bg, "PlateAuras"..auraID)
							UpdatePlateAuraIcon(icon, AuraData.icon, AuraData.applications, AuraData.duration, AuraData.expirationTime, AuraData.dispelName)
							if info.hl_np then
								UpdatePlateUnit_Highlight(unit, info.color, "PlateAuras", "start")
							end
						end
					end
				end
			end
		end
		if updateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do
				local icon = unitFrame.icon_bg.ActiveIcons["PlateAuras"..auraID]
				if icon then
					local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
					if AuraData then
						UpdatePlateAuraIcon(icon, AuraData.icon, AuraData.applications, AuraData.duration, AuraData.expirationTime, AuraData.dispelName)
					else
						icon:Hide()
						UpdatePlateUnit_Highlight(unit, nil, "PlateAuras", "stop")
					end
				end
			end
		end
		if updateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
				local icon = unitFrame.icon_bg.ActiveIcons["PlateAuras"..auraID]
				if icon then
					icon:Hide()
					UpdatePlateUnit_Highlight(unit, nil, "PlateAuras", "stop")
				end
			end
		end
	end
end

--7------------------------------------------------------------------
-- 刷新光环来源
local function UpdatePlateAuraSource(updateInfo)
	if not PlateAlertFrames.PlayerAuraSource then return end
	
	if updateInfo == nil or updateInfo.isFullUpdate then	
		for auraID, tex_frame in pairs(PlateAuraSourceFrames) do
			tex_frame:Hide()
			local unitFrame = tex_frame:GetParent()
			UpdatePlateUnit_Highlight(unitFrame.unit, nil, "PlayerAuraSource", "stop")
			PlateAuraSourceFrames[auraID] = nil
		end
		
		for spellID, info in pairs(PlateAlertFrames.PlayerAuraSource) do
			AuraUtil.ForEachAura("player", info.aura_type or "HELPFUL", nil, function(AuraData)
				if spellID == AuraData.spellId then
					local enable = T.ValueFromPath(JST_CDB, {"PlateAlert", "PlayerAuraSource", spellID, "enable"})
					if enable then
						local auraID = AuraData.auraInstanceID
						local source = AuraData.sourceUnit
						if source then -- 有需要找到来源的debuff
							local namePlate = C_NamePlate.GetNamePlateForUnit(source)						
							if namePlate and namePlate.jstuf then
								PlateAuraSourceFrames[auraID] = namePlate.jstuf:GetAvailableTex()
								if info.hl_np then	
									UpdatePlateUnit_Highlight(source, info.color, "PlayerAuraSource", "start")
								end
							end
						end
					end
				end
			end, true)
		end
	else
		if updateInfo.addedAuras ~= nil then
			for _, AuraData in pairs(updateInfo.addedAuras) do	
				local spellID = AuraData.spellId
				local source = AuraData.sourceUnit
				if source then -- 有需要找到来源的debuff	
					local info = T.ValueFromPath(PlateAlertFrames, {"PlayerAuraSource", spellID})
					if info then
						local enable = T.ValueFromPath(JST_CDB, {"PlateAlert", "PlayerAuraSource", spellID, "enable"})
						if enable then
							local namePlate = C_NamePlate.GetNamePlateForUnit(source)						
							if namePlate and namePlate.jstuf then
								local auraID = AuraData.auraInstanceID
								if not PlateAuraSourceFrames[auraID] then
									PlateAuraSourceFrames[auraID] = namePlate.jstuf:GetAvailableTex()
									if info.hl_np then
										UpdatePlateUnit_Highlight(source, info.color, "PlayerAuraSource", "start")
									end
								end
							end
						end
					end
				end
			end
		end
		if updateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do
				local tex_frame = PlateAuraSourceFrames[auraID]
				if tex_frame then
					local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID("player", auraID)
					if not AuraData then
						tex_frame:Hide()
						local unitFrame = tex_frame:GetParent()
						UpdatePlateUnit_Highlight(unitFrame.unit, nil, "PlayerAuraSource", "stop")	
						PlateAuraSourceFrames[auraID] = nil
					end
				end		
			end
		end
		if updateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
				local tex_frame = PlateAuraSourceFrames[auraID]
				if tex_frame then
					tex_frame:Hide()
					local unitFrame = tex_frame:GetParent()
					UpdatePlateUnit_Highlight(unitFrame.unit, nil, "PlayerAuraSource", "stop")
					PlateAuraSourceFrames[auraID] = nil
				end
			end
		end
	end
end

--8------------------------------------------------------------------
-- 刷新姓名板高亮
local function UpdateNPCHighlight(unitFrame)
	if not unitFrame or not unitFrame.npcID then return end
	
	local info = T.ValueFromPath(PlateAlertFrames, {"PlateNpcID", unitFrame.npcID})
	if info then
		local enable = T.ValueFromPath(JST_CDB, {"PlateAlert", "PlateNpcID", unitFrame.npcID, "enable"})
		if enable then
			UpdatePlateUnit_Highlight(unitFrame.unit, info.color, "PlateNpcID", "start")
		else
			UpdatePlateUnit_Highlight(unitFrame.unit, nil, "PlateNpcID", "stop")
		end
	else
		UpdatePlateUnit_Highlight(unitFrame.unit, nil, "PlateNpcID", "stop")
	end
end

--------------------------------------------------------------------
local function CreatePlateMark(parent)
	local tex_frame = CreateFrame("Frame", nil, parent)
	tex_frame:SetSize(35, 35)
	tex_frame:SetPoint("CENTER", parent, 0, 0)
	
	tex_frame.tex1 = tex_frame:CreateTexture(nil, "ARTWORK")
	tex_frame.tex1:SetAllPoints()
	tex_frame.tex1:SetAtlas("Ping_UnitMarker_BG_Warning")
	
	tex_frame.tex2 = tex_frame:CreateTexture(nil, "OVERLAY")
	tex_frame.tex2:SetSize(32, 32)
	tex_frame.tex2:SetPoint("CENTER")
	tex_frame.tex2:SetAtlas("Ping_SpotGlw_Warning_Out")
	
	tex_frame.tex3 = tex_frame:CreateTexture(nil, "OVERLAY")
	tex_frame.tex3:SetSize(21, 21)
	tex_frame.tex3:SetPoint("CENTER")
	tex_frame.tex3:SetAtlas("Ping_Marker_Icon_Warning")	
	
	tex_frame.tex4 = tex_frame:CreateTexture(nil, "ARTWORK")
	tex_frame.tex4:SetSize(5, 30)
	tex_frame.tex4:SetPoint("TOP", tex_frame, "CENTER", 0, -12)
	tex_frame.tex4:SetAtlas("Ping_GroundMarker_Pin_Warning")

	return tex_frame	
end

-- 姓名板刷新事件
local function OnNamePlateCreated(namePlate)
	namePlate.jstuf = CreateFrame("Button", "$parent_JST_UnitFrame", namePlate)
	namePlate.jstuf:SetSize(1,1)
	namePlate.jstuf:SetPoint("BOTTOM", namePlate, "TOP", 0, JST_CDB["PlateAlertOption"]["y"])
	namePlate.jstuf:SetFrameLevel(namePlate:GetFrameLevel())
	namePlate.jstuf:EnableMouse(false)
		
	namePlate.jstuf.textures = {}

	function namePlate.jstuf:CreateTex()
		local ind = #self.textures + 1

		local tex_frame = CreatePlateMark(namePlate.jstuf)
		
		tex_frame:HookScript("OnHide", function(self)
			self.active = false
		end)
		
		self.textures[ind] = tex_frame
		
		return tex_frame
	end
	
	function namePlate.jstuf:GetAvailableTex()
		for _, tex_frame in pairs(self.textures) do
			if not tex_frame.active then
				tex_frame.active = true
				tex_frame:Show()
				return tex_frame
			end
		end
		local new_tex = self:CreateTex()
		new_tex.active = true
		return new_tex
	end
	
	namePlate.jstuf.icon_bg = CreateFrame("Frame", nil, namePlate.jstuf)
	namePlate.jstuf.icon_bg:SetAllPoints(namePlate.jstuf)
	namePlate.jstuf.icon_bg:SetFrameLevel(namePlate:GetFrameLevel()+1)
	table.insert(PlateIconHolders, namePlate.jstuf.icon_bg)
	
	namePlate.jstuf.icon_bg.ActiveIcons = {}
	namePlate.jstuf.icon_bg.LineUpIcons = function()
		local active_num = 0
		for _, bu in pairs(namePlate.jstuf.icon_bg.ActiveIcons) do
			active_num = active_num + 1
		end
		local offset = ((JST_CDB["PlateAlertOption"]["size"]+4)*active_num-4)/2
		
		local lastframe
		for _, bu in pairs(namePlate.jstuf.icon_bg.ActiveIcons) do			
			bu:ClearAllPoints()
			if not lastframe then
				bu:SetPoint("LEFT", namePlate.jstuf.icon_bg, "CENTER", -offset, 0) -- 根据图标数量定位第一个
			else
				bu:SetPoint("LEFT", lastframe, "RIGHT", 3, 0)
			end
			lastframe = bu
		end
	end
	
	namePlate.jstuf.icon_bg.QueueIcon = function(bu, tag)	
		bu:HookScript("OnShow", function()
			namePlate.jstuf.icon_bg.ActiveIcons[tag] = bu			
			namePlate.jstuf.icon_bg.LineUpIcons()
		end)
		
		bu:HookScript("OnHide", function()
			namePlate.jstuf.icon_bg.ActiveIcons[tag] = nil			
			namePlate.jstuf.icon_bg.LineUpIcons()
		end)
	end
end

local PlateCastingEvents = {
	["UNIT_SPELLCAST_START"] = true,
	["UNIT_SPELLCAST_STOP"] = true,
	["UNIT_SPELLCAST_CHANNEL_START"] = true,
	["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
	["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
}

local function OnNamePlateAdded(unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	local unitFrame = namePlate.jstuf
	unitFrame.unit = unit
	unitFrame.npcID = select(6, strsplit("-", UnitGUID(unit)))
	
	-- 隐藏动画边框
	UpdatePlateUnit_Highlight(unitFrame.unit, nil, "PlateSpells", "stop")
	UpdatePlateUnit_Highlight(unitFrame.unit, nil, "PlateInterrupt", "stop")
	UpdatePlateUnit_Highlight(unitFrame.unit, nil, "PlateInterruptAuto", "stop")
	UpdatePlateUnit_Highlight(unitFrame.unit, nil, "PlateStackAuras", "stop")
	UpdatePlateUnit_Highlight(unitFrame.unit, nil, "PlateAuras", "stop")
	UpdatePlateUnit_Highlight(unitFrame.unit, nil, "PlayerAuraSource", "stop")
	UpdatePlateUnit_Highlight(unitFrame.unit, nil, "PlateNpcID", "stop")	
	
	-- 状态刷新
	UpdateInterruptSpells(unitFrame, "INIT", unitFrame.unit, UnitGUID(unitFrame.unit))
	UpdateInterruptAssignment(unitFrame, "INIT", unitFrame.unit, UnitGUID(unitFrame.unit))
	UpdatePower(unitFrame)
	UpdateNPCHighlight(unitFrame)
	UpdateRaidTarget(unitFrame)	
	UpdatePlateStackAuras(unitFrame, unitFrame.unit)
	UpdatePlateAuras(unitFrame, unitFrame.unit)
	UpdatePlateAuraSource()
	
	-- 注册事件，按事件刷新
	unitFrame:RegisterUnitEvent("UNIT_AURA", unitFrame.unit)
	unitFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", unitFrame.unit)
	for event, v in pairs(PlateCastingEvents) do
		unitFrame:RegisterUnitEvent(event, unitFrame.unit)
	end
	unitFrame:SetScript("OnEvent", function(self, event, unit, ...)
		if event == "UNIT_AURA" and unit == self.unit then	
			UpdatePlateStackAuras(self, unit, ...)
			UpdatePlateAuras(self, unit, ...)
		elseif event == "UNIT_POWER_UPDATE" and unit and unit == self.unit then
			UpdatePower(self)
		elseif PlateCastingEvents[event] and unit and unit == self.unit then		
			UpdateSpells(self, event, unit, ...)
			UpdateInterruptSpells(self, event, unit, ...)
			UpdateInterruptAssignment(self, event, unit, ...)
		end
	end)
end

local function OnNamePlateRemoved(unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	local unitFrame = namePlate.jstuf
	unitFrame.unit = nil
	unitFrame.npcID = nil
	
	-- 隐藏残余图标
	for k, icon in pairs(unitFrame.icon_bg.ActiveIcons) do
		icon:Hide()
	end
	
	-- 隐藏残余材质
	for k, tex_frame in pairs(unitFrame.textures) do
		tex_frame:Hide()
	end

	-- 状态刷新
	UpdateInterruptSpells(unitFrame, "INIT")
	UpdateInterruptAssignment(unitFrame, "INIT")
	UpdatePower(unitFrame)

	-- 取消事件，停止刷新
	unitFrame:UnregisterAllEvents()
	unitFrame:SetScript("OnEvent", nil)
end

local function GetNextPlayerAvailable(GUID)
	for i, info in pairs(InterruptPlayers) do
		if not info.occupied and info.alive then
			info.occupied = GUID
			return info.GUID, info.format_name, info.spellID, info.cd
		end
	end
end

local function QueueAssignInterrupt(GUID, spellCDs)
	if not InterruptQueue[GUID] and not InterruptAssignment[GUID] then
		InterruptQueue[GUID] = InterruptQueue[GUID] or 0
		
		for i, spellCD in pairs(spellCDs) do
			InterruptQueue[GUID] = InterruptQueue[GUID] + 1/spellCD
		end
		
		T.test_msg("加入待打断怪物序列", T.GetFomattedNameFromNpcID(select(6, strsplit("-", GUID))))
	end
end

local function AssignInterruptPlayers(GUID)
	if GUID and InterruptQueue[GUID] then
		T.test_msg("分配", T.GetFomattedNameFromNpcID(select(6, strsplit("-", GUID))), InterruptQueue[GUID])
		
		if not InterruptAssignment[GUID] then
			InterruptAssignment[GUID] = {}
		end
		
		local PlayerGUID, format_name, spellID, cd = GetNextPlayerAvailable(GUID)
		while InterruptQueue[GUID] > 0 and PlayerGUID and format_name and spellID and cd do			
			table.insert(InterruptAssignment[GUID], {GUID = PlayerGUID, format_name = format_name, spellID = spellID, cd = cd})

			InterruptQueue[GUID] = InterruptQueue[GUID] - 1/cd
			
			T.test_msg("分配打断人员", format_name, InterruptQueue[GUID])
			
			local unit = UnitTokenFromGUID(GUID)
			if unit then
				local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
				if namePlate then
					local unitFrame = namePlate.jstuf
					UpdateInterruptAssignment(unitFrame, "INIT", unit, GUID)
				end
			end
			
			PlayerGUID, format_name, spellID, cd = GetNextPlayerAvailable(GUID)
		end
		
		if InterruptQueue[GUID] <= 0 then
			InterruptQueue[GUID] = nil
		end
	end
end

local function CancelAssignment(GUID)
	for ind, info in pairs(InterruptPlayers) do
		if info.GUID == GUID then
			info.occupied = nil
			T.test_msg("解放打断人员", info.format_name)
			break
		end
	end
end

local function NamePlates_OnEvent(self, event, ...)
	if event == "ADDON_MSG" then
		local channel, sender, tag, spellID, cd, GUID = ...		
		if tag == "ShareSpellCD" then
			spellID = tonumber(spellID)
			cd = tonumber(cd)
			if sender and InterruptSpellData[spellID] then				
				if cd ~= 0 then -- 无打断技能
					local exsit
					for i, info in pairs(InterruptPlayers) do
						if info.GUID == GUID and info.spellID == spellID then
							exsit = true
						end
					end
					if not exsit then
						local info = T.GetGroupInfobyGUID(GUID)
						if info and info.unit and info.format_name then
							table.insert(InterruptPlayers, {
								GUID = GUID,
								format_name = info.format_name,
								unit = info.unit,
								spellID = spellID,
								cd = cd,
								alive = true,
							})
							table.sort(InterruptPlayers, function(a, b)
								if a.cd < b.cd then
									return true
								elseif a.cd == b.cd then
									return a.GUID > b.GUID
								end							
							end)
							T.test_msg("添加打断数据", info.format_name, spellID, cd)
						end
					end
				else
					for i, info in pairs(InterruptPlayers) do
						if info.GUID == GUID and info.spellID == spellID then
							table.remove(InterruptPlayers, i)
							
							local info = T.GetGroupInfobyGUID(GUID)
							T.test_msg("删除打断数据", info.format_name, spellID)
							
							break
						end
					end
				end
			end
		end
	elseif event == "GROUP_ROSTER_UPDATE" then
		for i, info in pairs(InterruptPlayers) do
			local unit = UnitTokenFromGUID(info.GUID)
			if not unit or not UnitInAnyGroup(unit) then
				T.test_msg("删除打断数据", info.format_name, info.spellID)
				table.remove(InterruptPlayers, i)
			end
		end
	elseif event == "UNIT_THREAT_LIST_UPDATE" then
		local unit = ...
		if unit and string.find(unit, "nameplate") then
			local GUID = UnitGUID(unit)
			local npcID = GUID and select(6, string.split("-", GUID))
			if npcID and AutoAssignNpc[npcID] and UnitDetailedThreatSituation("player", unit) then							
				if not (InterruptQueue[GUID] or InterruptAssignment[GUID]) then
					QueueAssignInterrupt(GUID, AutoAssignNpc[npcID])
					AssignInterruptPlayers(GUID)
				end
			end
		end
	elseif event == "VARIABLES_LOADED" then -- 刷新所有姓名板状态
		for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
			local unitFrame = namePlate.jstuf
			UpdateInterruptSpells(unitFrame, "INIT", unitFrame.unit, UnitGUID(unitFrame.unit))
			UpdatePower(unitFrame)
			UpdateNPCHighlight(unitFrame)
			UpdateRaidTarget(unitFrame)
		end
	elseif event == "NAME_PLATE_CREATED" then -- 姓名板创建
		local namePlate = ...
		OnNamePlateCreated(namePlate)
	elseif event == "NAME_PLATE_UNIT_ADDED" then -- 姓名板单位添加
		local unit = ...
		OnNamePlateAdded(unit)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then -- 姓名板单位删除
		local unit = ...
		OnNamePlateRemoved(unit)
	elseif event == "UNIT_AURA" then -- 刷新来源光环图标		
		local unit, updateInfo = ...
		if unit == "player" then
			UpdatePlateAuraSource(updateInfo)
		end
	elseif event == "RAID_TARGET_UPDATE" then -- 刷新团队标记和打断讯息
		for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
			local unitFrame = namePlate.jstuf
			UpdateInterruptText(unitFrame)
			UpdateRaidTarget(unitFrame)
		end		
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then -- 刷新打断的轮次
		if PlateAlertFrames.PlateInterrupt then
			local _, sub_event, _, sourceGUID, _, _, sourceRaidFlags, destGUID, _, _, destRaidFlags, spellID, _, _, extraSpellId = CombatLogGetCurrentEventInfo()
			-- 施法被打断
			if sub_event == "SPELL_INTERRUPT" and extraSpellId and T.ValueFromPath(PlateAlertFrames, {"PlateInterrupt", extraSpellId}) then
				local NpcID = select(6, string.split("-", destGUID))
				if Npc[NpcID] then
					UpdateInterruptInd(destGUID, T.GetRaidFlagsMark(destRaidFlags))
				end
			-- 施法成功
			elseif sub_event == "SPELL_CAST_SUCCESS" and spellID and T.ValueFromPath(PlateAlertFrames, {"PlateInterrupt", spellID}) then
				local NpcID = select(6, string.split("-", sourceGUID))
				if Npc[NpcID] then
					UpdateInterruptInd(sourceGUID, T.GetRaidFlagsMark(sourceRaidFlags))	
				end
			end
		end
		
		if PlateAlertFrames.PlateInterruptAuto then
			local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, _, _, extraSpellId = CombatLogGetCurrentEventInfo()
			-- 施法被打断
			if sub_event == "SPELL_INTERRUPT" and extraSpellId and T.ValueFromPath(PlateAlertFrames, {"PlateInterruptAuto", extraSpellId}) then				
				local NpcID = select(6, string.split("-", destGUID))
				if AutoAssignNpc[NpcID] then
					UpdateInterruptIndAuto(destGUID)
				end
			-- 施法成功
			elseif sub_event == "SPELL_CAST_SUCCESS" and spellID and T.ValueFromPath(PlateAlertFrames, {"PlateInterruptAuto", spellID}) then
				local NpcID = select(6, string.split("-", sourceGUID))
				if Npc[NpcID] then
					UpdateInterruptIndAuto(destGUID)
				end
			-- 对象死亡
			elseif sub_event == "UNIT_DIED" then
				local need_reassign
				if InterruptQueue[destGUID] then
					InterruptQueue[destGUID] = nil
				end
				if InterruptAssignment[destGUID] then
					for i, v in pairs(InterruptAssignment[destGUID]) do
						CancelAssignment(v.GUID)
						need_reassign = true
					end
					InterruptAssignment[destGUID] = nil
					InterruptDataAuto[destGUID] = nil
				end
				if need_reassign then
					for GUID, spellCD in pairs(InterruptQueue) do
						AssignInterruptPlayers(GUID)
					end
				end
			end
		end
	elseif event == "UNIT_FLAGS" then
		local unit = ...
		if unit then
			for i, info in pairs(InterruptPlayers) do
				if info.unit and UnitIsUnit(info.unit, unit) then
					if UnitIsDeadOrGhost(unit) and info.alive then
						info.alive = false
						T.test_msg("打断人员死亡", info.format_name)
						local GUID = info.occupied
						if GUID and InterruptAssignment[GUID] then
							T.test_msg("删除现有分配", T.GetFomattedNameFromNpcID(select(6, strsplit("-", GUID))))
							for i, v in pairs(InterruptAssignment[GUID]) do
								CancelAssignment(v.GUID)
							end
							InterruptAssignment[GUID] = nil
							InterruptDataAuto[GUID] = nil
							local npcID = select(6, string.split("-", GUID))
							QueueAssignInterrupt(GUID, AutoAssignNpc[npcID])
						end	
						for GUID, spellCD in pairs(InterruptQueue) do
							AssignInterruptPlayers(GUID)
						end
					elseif not UnitIsDeadOrGhost(unit) and not info.alive then
						info.alive = true
						T.test_msg("打断人员复活", info.format_name)
						for GUID, spellCD in pairs(InterruptQueue) do
							AssignInterruptPlayers(GUID)
						end
					end
					break
				end
			end
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		if not T.IsGroupInCombat() then
			for _, info in pairs(InterruptAssignment) do
				for i, v in pairs(info) do
					CancelAssignment(v.GUID)
				end
			end
			InterruptQueue = table.wipe(InterruptQueue)
			InterruptAssignment = table.wipe(InterruptAssignment)
			InterruptDataAuto = table.wipe(InterruptDataAuto)
		end
	elseif event == "ENCOUNTER_START" then -- 获取MRT打断讯息 格式：#打断xx-npcID-轮次-{rt1} (名字) (名字 名字)
		InterruptMrtData = table.wipe(InterruptMrtData)
		
		if C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1 then
			local text = _G.VExRT.Note.Text1
			for line in text:gmatch('#打断[^\r\n]+') do
				local npcID, num = select(2, string.split("-",line))
				
				if npcID and Npc[npcID] and num and tonumber(num) and tonumber(num) > 0 then
					-- 打断轮数
					local interrupt_count = tonumber(num)
					
					-- 团队标记
					local markstr, mark = line:match("{rt(%d)}")
					if markstr and tonumber(markstr) and tonumber(markstr) < 9 then
						mark = tonumber(markstr) -- 有标记
					else
						mark = 9 -- 无标记
					end
					
					-- 打断轮数数据整理
					if not InterruptMrtDataCount[npcID] then
						InterruptMrtDataCount[npcID] = {}
					end
					InterruptMrtDataCount[npcID][mark] = interrupt_count
					
					-- 打断人员数据整理
					if not InterruptMrtData[npcID] then
						InterruptMrtData[npcID] = {}
					end
					InterruptMrtData[npcID][mark] = {}
					local count = 0
					for players in line:gmatch("%(([^)]*)%)") do
						count = count + 1
						InterruptMrtData[npcID][mark][count] = {}
						local idx = 0
						for name in players:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
							idx = idx + 1
							local info = T.GetGroupInfobyName(name)
							if info then
								InterruptMrtData[npcID][mark][count][idx] = info.GUID
							else
								T.msg(string.format(L["昵称错误"], name))
							end
							--print("InterruptMrtData", npcID, count, idx, name)
						end 
					end
				end	
			end
		end	
	end
end

local plate_events = {
	["UNIT_THREAT_LIST_UPDATE"] = true,
	["UNIT_FLAGS"] = true,
	["VARIABLES_LOADED"] = true,
	["NAME_PLATE_CREATED"] = true,
	["NAME_PLATE_UNIT_ADDED"] = true,
	["NAME_PLATE_UNIT_REMOVED"] = true,
	["COMBAT_LOG_EVENT_UNFILTERED"] = true,
	["UNIT_AURA"] = true,
	["ENCOUNTER_START"] = true,
	["RAID_TARGET_UPDATE"] = true,	
	["ADDON_MSG"] = true,
	["GROUP_ROSTER_UPDATE"] = true,
	["PLAYER_REGEN_ENABLED"] = true,
}

NamePlateAlertTrigger:SetScript("OnEvent", NamePlates_OnEvent)

T.RegisterEventAndCallbacks(NamePlateAlertTrigger, plate_events)

--------------------------------------------------------------------
local PlateAlertColor = {
	PlatePower = {1,1,0,1},
	PlateNpcID = {1,0,0,1},
	PlateAuras = {0,1,0,1},
	PlateStackAuras = {0,1,0,1},
	PlayerAuraSource = {1,0,0,1},
	PlateSpells = {0,1,1,1},
	PlateInterrupt = {1,0,0,1},
	PlateInterruptAuto = {1,0,0,1},
}

T.CreatePlateAlert = function(ENCID, option_page, category, args)
	local frame_key
	if args.type == "PlatePower" or args.type == "PlateNpcID" then
		frame_key = args.mobID
	else
		frame_key = args.spellID
	end
	
	local path = {category, args.type, frame_key}
	local details = {}
	local detail_options = {}
	
	if args.type == "PlateInterrupt" then
		details.interrupt_sl = args.interrupt
		table.insert(detail_options, {key = "interrupt_sl", text = L["无MRT设置的循环次数"], default = args.interrupt, min = 2, max = 5, apply = function(value, alert, button)
			local enable = T.ValueFromPath(JST_CDB, path)["enable"]
			local npcIDs = {string.split(",", args.mobID)}
			for i, npcID in pairs(npcIDs) do
				if enable then
					G.Npc[npcID] = value
				else
					G.Npc[npcID] = nil
				end
			end
		end})
		table.insert(detail_options, {key = "copy_interrupt_btn", text = L["粘贴MRT模板"], mobID = args.mobID, spellID = args.spellID})
	end
	
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_PlateAlert_Options(option_page, category, path, args, detail_options)
	
	if args.type == "PlateInterruptAuto" then
		local enable = T.ValueFromPath(JST_CDB, path)["enable"]
		local npcID = args.mobID
		if enable then
			if not AutoAssignNpc[npcID] then
				AutoAssignNpc[npcID] = {}
			end
			AutoAssignNpc[npcID] = table.wipe(AutoAssignNpc[npcID])
			table.insert(AutoAssignNpc[npcID], args.spellCD)
		else
			AutoAssignNpc[npcID] = nil
		end
	end
	
	if not PlateAlertFrames[args.type] then
		PlateAlertFrames[args.type] = {}
	end
	
	PlateAlertFrames[args.type][frame_key] = {
		hl = args.hl,
		hl_np = args.hl_np,
		aura_type = args.aura_type,
		color = {1,1,1,1},
	}
	
	if args.color then
		for k, v in pairs(args.color) do
			PlateAlertFrames[args.type][frame_key].color[k] = v
		end
	else
		for k, v in pairs(PlateAlertColor[args.type]) do
			PlateAlertFrames[args.type][frame_key].color[k] = v
		end
	end
	
	for i, info in pairs(detail_options) do
		if info.apply then
			local value = T.ValueFromPath(JST_CDB, path)[info.key]
			info.apply(value)
		end
	end
end

-- 姓名板设置
T.EditPlateIcons = function(tag)
	if tag == "enable" or tag == "all" then
		if JST_CDB["GeneralOption"]["disable_all"] or JST_CDB["GeneralOption"]["disable_plate"] then
			for k, frame in pairs(PlateIconHolders) do frame:SetAlpha(0) end
		else
			for k, frame in pairs(PlateIconHolders) do frame:SetAlpha(1) end
		end
	end
	
	if tag == "icon_size" or tag == "all" then
		local size = JST_CDB["PlateAlertOption"]["size"]
		for k, frame in pairs(PlateIconHolders) do
			for _, icon in pairs{frame:GetChildren()} do
				if icon:IsObjectType("Frame") then
					icon:SetSize(size, size)				
				end
			end
			frame.LineUpIcons()
		end
	end
	
	if tag == "x" or tag == "y" or tag == "all" then
		local x, y = JST_CDB["PlateAlertOption"]["x"], JST_CDB["PlateAlertOption"]["y"]
		for k, frame in pairs(PlateIconHolders) do
			local unitFrame = frame:GetParent()
			local namePlate = unitFrame:GetParent()
			unitFrame:SetPoint("BOTTOM", namePlate, "TOP", 0, JST_CDB["PlateAlertOption"]["y"])	
			if frame.powericon then
				frame.powericon:SetPoint("LEFT", namePlate, "RIGHT", x, 0)
			end
		end
	end
end

----------------------------------------------------------
-------------------[[    声音提示    ]]-------------------
----------------------------------------------------------
local SoundFrames = {}
local PASoundTiggerFrames = {}

G.PASoundTiggerFrames = PASoundTiggerFrames

local SoundTrigger = CreateFrame("Frame", addon_name.."SoundTrigger", FrameHolder)

SoundTrigger:SetScript("OnEvent", function(self, event, ...)	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if G.sound_suffix[sub_event] then
			local sound_type = G.sound_suffix[sub_event][1]
			local info = T.ValueFromPath(SoundFrames, {sound_type, spellID})
			if info and (not info.target_me or destGUID == G.PlayerGUID) then
				local enable = T.ValueFromPath(JST_CDB, {"Sound", sound_type, spellID, "enable"})
				if enable then
					T.PlaySound(info.file)
				end
			end
		end
	end
end)

local EnablePrivateAuraSound = function(frame, spellID, sound)
	if not frame.auraSoundIDs[spellID] then	
		frame.auraSoundIDs[spellID] = C_UnitAuras.AddPrivateAuraAppliedSound({
			unitToken = "player",
			spellID = spellID,
			soundFileName = JST_CDB["GeneralOption"]["sound_file"]..sound..".ogg",
			outputChannel = JST_CDB["GeneralOption"]["sound_channel"],
		})
		--print("+", frame.auraSoundIDs[spellID])
		--print(spellID,JST_CDB["GeneralOption"]["sound_file"]..sound..".ogg",JST_CDB["GeneralOption"]["sound_channel"])
	end
end

local DisablePrivateAuraSound = function(frame)
	for spellID, auraSoundID in pairs(frame.auraSoundIDs) do
		--print("-", auraSoundID)
		C_UnitAuras.RemovePrivateAuraAppliedSound(auraSoundID)
		frame.auraSoundIDs[spellID] = nil
	end
end

local CreatePrivateAuraSound = function(spellID, sound, spellIDs)
	local frame = CreateFrame("Frame", nil, SoundTrigger)
	frame.auraSoundIDs = {}
	
	function frame:update_onedit()
		local enable = T.ValueFromPath(JST_CDB, {"Sound", "aura", spellID, "enable"})
		if enable and not JST_CDB["GeneralOption"]["disable_sound"] and not JST_CDB["GeneralOption"]["disable_all"] then
			EnablePrivateAuraSound(frame, spellID, sound)
			if spellIDs then
				for sub_spellID in pairs(spellIDs) do
					EnablePrivateAuraSound(frame, sub_spellID, sound)
				end
			end
		else
			DisablePrivateAuraSound(frame)
		end
	end
	
	PASoundTiggerFrames[spellID] = frame
end

T.EditSoundAlert = function(option)
	if option == "enable" or option == "all" then	
		if not JST_CDB["GeneralOption"]["disable_sound"] and not JST_CDB["GeneralOption"]["disable_all"] then
			SoundTrigger:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		else
			SoundTrigger:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
		
		for spellID, frame in pairs(PASoundTiggerFrames) do
			frame:update_onedit()
		end
	end
end

T.CreateSoundAlert = function(ENCID, option_page, category, args)
	local sound_type = G.sound_suffix[args.sub_event][1]
	local path = {category, sound_type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon)
	T.Create_Sound_Options(option_page, category, path, args)
	
	if not SoundFrames[sound_type] then
		SoundFrames[sound_type] = {}
	end
	
	SoundFrames[sound_type][args.spellID] = {
		target_me = args.target_me,
		file = string.match(args.file, "%[(.+)%]"),
	}

	if args.private_aura then
		CreatePrivateAuraSound(args.spellID, string.match(args.file, "%[(.+)%]"), args.spellIDs)
	end
end

----------------------------------------------------------
-----------------[[    团队框架图标    ]]-----------------
----------------------------------------------------------
local RFIconFrames = {}
local RFIconSpellIDs = {} -- 转换技能ID
local RFIconHolders = {}
local RFIndex = {}

local RFTrigger = CreateFrame("Frame", addon_name.."RFTrigger", FrameHolder)

-- 团队框架序号
local CreateRFIndex = function(parent, index)
	if JST_CDB["GeneralOption"]["disable_all"] or JST_CDB["GeneralOption"]["disable_rf"] then return end
	
	if not parent.RFIndex then
		local icon = CreateFrame("Frame", nil, parent)
		icon:SetFrameStrata("FULLSCREEN")
		icon:SetPoint("CENTER", parent, "CENTER", 0, 5)
		icon:SetFrameLevel(parent:GetFrameLevel()+3)
		icon:SetSize(JST_CDB["RFIconOption"]["RFIndex_size"], JST_CDB["RFIconOption"]["RFIndex_size"])
		
		icon.text = T.createtext(icon, "OVERLAY", JST_CDB["RFIconOption"]["RFIndex_size"], "OUTLINE", "CENTER")
		icon.text:SetPoint("CENTER", icon, "CENTER", 0, 0)
		icon.text:SetTextColor(1, 0, 0)
		icon.text:SetShadowOffset(2, -2)
		
		function icon:UpdateSize()			
			icon:SetSize(JST_CDB["RFIconOption"]["RFIndex_size"], JST_CDB["RFIconOption"]["RFIndex_size"])
			icon.text:SetFont(G.Font, JST_CDB["RFIconOption"]["RFIndex_size"], "OUTLINE")
		end
		
		table.insert(RFIndex, icon)	
		parent.RFIndex = icon		
	end
	
	parent.RFIndex:UpdateSize()
	parent.RFIndex.text:SetText(index)
	parent.RFIndex.ind = index
	parent.RFIndex:Show()
end
T.CreateRFIndex = CreateRFIndex

local HideRFIndexbyParent = function(parent)
	if parent.RFIndex then
		parent.RFIndex:Hide()
	end
end
T.HideRFIndexbyParent = HideRFIndexbyParent

local HideRFIndexbyIndex = function(index)
	for k, icon in pairs(RFIndex) do
		if icon.ind == index then
			icon:Hide()
		end
	end
end
T.HideRFIndexbyIndex = HideRFIndexbyIndex

local HideAllRFIndex = function()
	for k, icon in pairs(RFIndex) do
		icon:Hide()
	end
end
T.HideAllRFIndex = HideAllRFIndex

-- 团队框架法术图标
local function CreateRFIcon(parent, frame)
	local icon = CreateFrame("Frame", nil, frame)
	icon:SetSize(JST_CDB["RFIconOption"]["RFIcon_size"], JST_CDB["RFIconOption"]["RFIcon_size"])
	icon:SetFrameLevel(parent:GetFrameLevel()+3)
	icon:Hide()
	icon.t = 0
	
	icon.cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	icon.cd:SetAllPoints(icon)
	icon.cd:SetDrawBling(false)
	icon.cd:SetDrawEdge(false)
	icon.cd:SetHideCountdownNumbers(true)
	
	icon.texture = icon:CreateTexture(nil, "ARTWORK")
	icon.texture:SetTexCoord( .1, .9, .1, .9)
	icon.texture:SetAllPoints()
	
	function icon:SetUpdateCooldown(dur, expiration)
		icon.cd:SetCooldown(expiration-dur, dur)
		icon.exp = expiration
		icon:SetScript("OnUpdate", function(self, e)
			self.t = self.t + e
			if self.t > .05 then
				self.remain = self.exp - GetTime()
				if self.remain <= 0 then
					self:Hide()
					self:SetScript("OnUpdate", nil)
				end
				self.t = 0
			end
		end)
		icon:Show()
	end
	
	icon:SetScript("OnShow", function()
		LCG.ButtonGlow_Start(icon)
		frame:lineup()
	end)
	
	icon:SetScript("OnHide", function()
		LCG.ButtonGlow_Stop(icon)
		frame:lineup()
	end)
	
	icon.last_update = 0
	return icon
end

local function CreateRFIconHolders(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("CENTER", parent, "CENTER")
	frame:SetSize(JST_CDB["RFIconOption"]["RFIcon_size"], JST_CDB["RFIconOption"]["RFIcon_size"])
	frame.activeicons = {}
	
	function frame:updatesize()
		local size = JST_CDB["RFIconOption"]["RFIcon_size"]
		frame:SetSize(size, size)
		for tag, icon in pairs(frame.activeicons) do
			icon:SetSize(size, size)
		end
		frame:lineup()
	end
	
	function frame:lineup()
		local t = {}
		
		for tag, icon in pairs(frame.activeicons) do
			table.insert(t, icon)
		end
		
		table.sort(t, function(a, b) return a.last_update < b.last_update end)
		
		for i, icon in pairs(t) do
			icon:ClearAllPoints()
			if i == 1 then
				icon:SetPoint("LEFT", frame, "CENTER", -((JST_CDB["RFIconOption"]["RFIcon_size"]+2)*#t-2)/2,0) -- 根据图标数量定位第一个
			else
				icon:SetPoint("LEFT", t[i-1], "RIGHT", 2, 0)	
			end
		end
	end
	
	function frame:geticon(tag)
		if not frame.activeicons[tag] then
			frame.activeicons[tag] = CreateRFIcon(parent, frame)
		end
		return frame.activeicons[tag]
	end
	
	function frame:updateicon(tag, spellID, dur, expiration)
		local spell_icon = spellID and select(2, T.GetSpellInfo(spellID)) or G.media.blank
		local icon = frame:geticon(tag)
		if string.find(tag, "cast") then
			if GetTime() - icon.last_update > .5 then
				icon:SetUpdateCooldown(dur, expiration)	
				icon.texture:SetTexture(spell_icon)	
				icon.last_update = GetTime()
			end		
		end
	end
	
	function frame:stopicon(tag)
		if tag then
			local icon = frame.activeicons[tag]
			if icon then
				icon.cd:Clear()
				icon:SetScript("OnUpdate", nil)	
				icon:Hide()
				frame.activeicons[tag] = nil
			end
		else
			for tag, icon in pairs(frame.activeicons) do
				icon.cd:Clear()
				icon:SetScript("OnUpdate", nil)	
				icon:Hide()
				frame.activeicons[tag] = nil
			end
		end
	end
	
	table.insert(RFIconHolders, frame)	
	parent.iconholder = frame
	
	return frame
end

local function HideAllRFicon()
	for i, frame in pairs(RFIconHolders) do
		frame:stopicon()
	end
end

RFTrigger:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_SPELLCAST_START" then
		local unit, _, cast_spellID = ...
		local spellID = RFIconSpellIDs[cast_spellID] or cast_spellID
		local info = T.ValueFromPath(RFIconFrames, {"Cast", spellID})
		if info then
			local enable = T.ValueFromPath(JST_CDB, {"RFIcon", "Cast", spellID, "enable"})
			if enable then
				C_Timer.After(.2, function() -- 延迟一下再判定目标
					local target_unit = unit.."target"
					if UnitInAnyGroup(target_unit) then
						local startTimeMS, endTimeMS = select(4, UnitCastingInfo(unit))
						local frame = T.GetUnitFrame(target_unit)
						if startTimeMS and endTimeMS and frame then
							local GUID = UnitGUID(unit)
							local iconholder = frame.iconholder or CreateRFIconHolders(frame)
							iconholder:updateicon("cast"..GUID, cast_spellID, (endTimeMS-startTimeMS)/1000, endTimeMS/1000)
						end
					end
				end)
			end
		end
	elseif event == "UNIT_SPELLCAST_STOP" then
		local unit, _, cast_spellID = ...
		local spellID = RFIconSpellIDs[cast_spellID] or cast_spellID
		local info = T.ValueFromPath(RFIconFrames, {"Cast", spellID})
		if unit and spellID and info then
			local enable = T.ValueFromPath(JST_CDB, {"RFIcon", "Cast", spellID, "enable"})
			if enable then
				local GUID = UnitGUID(unit) 
				if GUID then
					for i, iconholder in pairs(RFIconHolders) do
						iconholder:stopicon("cast"..GUID)
					end
				end
			end
		end
	end
end)

T.CreateRFIconAlert = function(ENCID, option_page, category, args)
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon)
	T.Create_RFIcon_Options(option_page, category, path, args)
	
	if not RFIconFrames[args.type] then
		RFIconFrames[args.type] = {}
	end
	
	RFIconFrames[args.type][args.spellID] = {}
	
	if args.spellIDs then
		for spellID in pairs(args.spellIDs) do
			RFIconSpellIDs[spellID] = args.spellID
		end
	end
end

T.EditRFIconAlert = function(option)
	if option == "enable" or option == "all" then	
		if JST_CDB["GeneralOption"]["disable_all"] or JST_CDB["GeneralOption"]["disable_rf"] then
			RFTrigger:UnregisterEvent("UNIT_SPELLCAST_START")
			RFTrigger:UnregisterEvent("UNIT_SPELLCAST_STOP")
			HideAllRFicon()
			HideAllRFIndex()
		else
			RFTrigger:RegisterEvent("UNIT_SPELLCAST_START")
			RFTrigger:RegisterEvent("UNIT_SPELLCAST_STOP")
		end
	end
	
	if option == "icon_size" or option == "all" then
		for i, frame in pairs(RFIconHolders) do
			frame:updatesize()
		end
	end
	
	if option == "index_size" or option == "all" then
		for i, frame in pairs(RFIndex) do
			frame:UpdateSize()
		end
	end
end

----------------------------------------------------------
-------------------[[    首领模块    ]]-------------------
----------------------------------------------------------
G.BossModFrames = {}

local EditAlertBossMod = function(frame, path, option, detail_options)
	if option == "all" or option == "enable" then
		frame.enable = T.ValueFromPath(JST_CDB, path)["enable"]
		
		for i, info in pairs(detail_options) do
			if info.apply then
				local value = T.ValueFromPath(JST_CDB, path)[info.key]
				info.apply(value, frame)
			end
		end
		
		if frame.enable then
			if frame.engageID then
				frame:RegisterEvent("ENCOUNTER_START")
				frame:RegisterEvent("ENCOUNTER_END")
			elseif frame.mapID then
				frame:RegisterEvent("PLAYER_ENTERING_WORLD")
			end
			T.RestoreDragFrame(frame)		
			if frame.sub_frames then
				for i, f in pairs(frame.sub_frames) do
					if f.enable then
						T.RestoreDragFrame(f)
					end
				end
			end
		else
			if frame.engageID then
				frame:UnregisterEvent("ENCOUNTER_START")
				frame:UnregisterEvent("ENCOUNTER_END")
			elseif frame.mapID then
				frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
			end
			T.ReleaseDragFrame(frame)
			if frame.sub_frames then
				for i, f in pairs(frame.sub_frames) do	
					T.ReleaseDragFrame(f)
				end
			end
		end

		frame:GetScript("OnEvent")(frame, "OPTION_EDIT")
	end
end

T.EditBossModsFrame = function(option)
	for k, frame in pairs(G.BossModFrames) do
		frame:update_onedit(option)
	end
end

T.CreateBossMod = function(ENCID, option_page, category, args)
	if G.BossModFrames[args.spellID] then
		T.test_msg(args.spellID, "首领模块标签重复")
	end
	if not args.enable_tag then
		T.test_msg(args.spellID, args.name, "首领模块未设置enable_tag")
	end
	
	local path = {category, args.spellID}
	local frame = CreateFrame("Frame", addon_name.."_"..args.spellID.."_Mods", FrameHolder)
	
	G.BossModFrames[args.spellID] = frame
	
	frame.config_id = args.spellID
	frame.config_name = args.name
	frame.enable_tag = args.enable_tag
	frame.ficon = args.ficon
	frame.events = args.events
	
	frame.reset = args.reset
	frame.update = args.update
	
	frame.encounterID = ENCID
	frame.InstanceID = option_page.InstanceID
	
	if type(ENCID) == "number" then -- 只针对首领战斗
		frame.npcID = G.Encounters[ENCID]["npc_id"]
		frame.engageID = G.Encounters[ENCID]["engage_id"]
	elseif string.find(ENCID, "Trash") then
		frame.mapID = G.Encounters[ENCID]["map_id"]
	end
	
	-- 位置
	frame.movingtag = ENCID
	frame.movingname = T.GetEncounterName(ENCID, frame.InstanceID).."\n".. (args.name or string.format("%s %s", T.GetIconLink(args.spellID), L["首领模块"]))
	
	if args.points.hide then
		frame:SetPoint("CENTER", UIParent, "CENTER")	
	else
		frame.point = { a1 = args.points.a1, a2 = args.points.a2, x = args.points.x, y = args.points.y}
		if args.points.width and args.points.height then
			frame:SetSize(args.points.width, args.points.height)
		end
		T.CreateDragFrame(frame)	
	end
	
	frame.t = 0	
	frame:Hide()
	
	-- 初始化
	args.init(frame)
	
	local details = {}
	local detail_options = {}
	
	if args.custom then
		for i, t in pairs(args.custom) do -- 细节选项
			details[t.key] = t.default
		end
		for i, info in pairs(args.custom) do
			table.insert(detail_options, info)
		end
	end

	for i, info in pairs(detail_options) do
		if info.key == "mrt_custom_btn" then
			info.onclick = function(alert, button, self)
				T.DisplayCopyString(self, alert:copy_mrt(), L["复制粘贴"])
			end
		elseif info.key == "option_list_btn" then
			info.onclick = function(alert, button, self)
				T.Toggle_opFrame(self, alert)
			end
		end
	end

	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_BossMod_Options(option_page, category, path, args, detail_options)
	
	function frame:update_onedit(option) -- 载入配置
		EditAlertBossMod(self, path, option, detail_options)
	end

	function frame:init_update(event, ...)
		self:update(event, ...)
	end
	
	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" or event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
			CheckConditions(self, frame.events, args, event, ...) -- 显示框体、注册事件
		elseif self.events[event] then
			if self.enable then
				self.update(self, event, ...)
			end
		end
	end)
end

----------------------------------------------------------
---------------[[    获得团队标记提醒    ]]---------------
----------------------------------------------------------
local RMFrame = CreateFrame("Frame", addon_name.."RMFrame", FrameHolder)
RMFrame.text_frame = T.CreateAlertText("RMFrame", 2)

T.EditRMFrame = function(option)
	if option == "all" or option == "enable" then
		if JST_CDB["GeneralOption"]["rm"] then		
			RMFrame:RegisterEvent("RAID_TARGET_UPDATE")
		else
			RMFrame:UnregisterEvent("RAID_TARGET_UPDATE")
		end
	end
end

RMFrame:SetScript("OnEvent", function(self, event)
	if JST_CDB["GeneralOption"]["rm"] then
		local index = GetRaidTargetIndex("player")
		if index and self.old ~= index then
			self.old = index
			--print("index changed to"..index)
			local text = string.format(L["当前标记"], T.FormatRaidMark(index))
			T.Start_Text_Timer(self.text_frame, 3, text)
		elseif not index then
			self.old = 0
			T.Stop_Text_Timer(self.text_frame)
		end
	else
		self.old = 0
		T.Stop_Text_Timer(self.text_frame)
	end
end)

----------------------------------------------------------
-------------------[[    动态战术板    ]]-----------------
----------------------------------------------------------

local function FormatSec(remain)
	local str
	if remain < 0 then
		str = string.format("|cffC0C0C0------|r")
	elseif remain < 3 then
		str = string.format("|cffFF0000%.1f|r", remain)
	elseif remain < 5 then
		str = string.format("|cffFFD700%d|r", remain)
	elseif remain < 10 then 
		str = string.format("|cff00FF00%d|r", remain)
	else
		str = date("|cff40E0D0%M:%S|r", remain)
	end
	return str
end

local function GetMyScript(str)
	local org_str
	org_str = gsub(str, " ", "") -- 去掉空格
	org_str = gsub(org_str, "@|c%x%x%x%x%x%x%x%x([^|]+)|r", function(a) return string.format("{target:%s}", a) end) --剔除目标
	local info = {}	
	local my_str = ""
	for name, str in org_str:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|r([^|]+)") do
		table.insert(info, {n = name, str = str})
	end
	for index, v in pairs(info) do
		local info = T.GetGroupInfobyName(v.n)
		if info and info.GUID == G.PlayerGUID then -- 识别到自己（含昵称）
			my_str = my_str..v.str
		end
	end
	return my_str
end

local TTS_failed_type = {
	"无效的朗读引擎类型", -- 1
	"朗读引擎分配失败", -- 2
	"不支持", -- 3
	"超过最大字符数", -- 4
	"持续时间过短", -- 5
	"进入朗读等候队列", -- 6
	"SDK未初始化", -- 7
	"朗读等候队列满", -- 8
	"无需加入朗读队列", -- 9
	"未找到语音", -- 10
	"未找到发音人", -- 11
	"无效的参数", -- 12
	"内部错误", -- 13
}

local Timeline = CreateFrame("Frame", addon_name.."TLFrame", FrameHolder)
Timeline:SetSize(600,100)
Timeline:Hide()

Timeline.title = CreateFrame("Frame", nil, Timeline) 
Timeline.title:SetSize(100, 40)
Timeline.title:SetPoint("TOPLEFT", Timeline, "TOPLEFT", 0, 0)

Timeline.clock = T.createtext(Timeline.title, "OVERLAY", 20, "OUTLINE", "LEFT")
Timeline.clock:SetPoint("LEFT", Timeline.title, "LEFT", 5, 0)	

Timeline.movingname = L["动态战术板"]
Timeline.point = { a1 = "TOPLEFT", a2 = "TOPLEFT", x = 300, y = -30}
T.CreateDragFrame(Timeline)

G.Timeline = Timeline

local timeicon = "|T134376:12:12:0:0:64:64:4:60:4:60|t"

Timeline.t = 0
Timeline.tl_dur = 5 -- 到时间点后保留显示的时间
Timeline.start = 0 -- 战斗开始时间
Timeline.time_offset = 0 -- 校准时间偏移量
Timeline.assignment_cd = {} -- 当前战斗战术板条目
Timeline.phase_cd = {} -- 当前战斗战术板转阶段条目

Timeline.Lines = {} -- 条目
Timeline.ActiveLines = {} -- 活跃条目
Timeline.Encounter_Tags = {} -- MRT战术板 标题标记

Timeline.events = {
	["ENCOUNTER_START"] = true,
	["ENCOUNTER_END"] = true,
	["ENCOUNTER_PHASE"] = true,
	["TIMELINE_PASSED"] = true,
	["VOICE_CHAT_TTS_PLAYBACK_STARTED"] = true,
	["VOICE_CHAT_TTS_PLAYBACK_FINISHED"] = true,
	["VOICE_CHAT_TTS_PLAYBACK_FAILED"] = true,
	["VOICE_CHAT_TTS_SPEAK_TEXT_UPDATE"] = true,
}

T.EditTimeline = function(option)
	if option == "all" or option == "enable" then
		if JST_CDB["GeneralOption"]["tl"] then			
			T.RegisterEventAndCallbacks(Timeline, Timeline.events)
			T.RestoreDragFrame(Timeline)
		else
			T.UnregisterEventAndCallbacks(Timeline, Timeline.events)
			T.ReleaseDragFrame(Timeline)
			Timeline:Hide()
		end
	end
	
	if option == "all" or option == "enable" or option == "bar" then
		if not (JST_CDB["GeneralOption"]["tl"] and JST_CDB["GeneralOption"]["tl_bar"]) then
			for key, line in pairs(Timeline.Lines) do
				line.bar:Hide()
			end
		end
	end
	
	if option == "all" or option == "enable" or option == "text" then	
		if not (JST_CDB["GeneralOption"]["tl"] and JST_CDB["GeneralOption"]["tl_text"]) then
			for key, line in pairs(Timeline.Lines) do
				line.text_frame:Hide()
			end
		end
	end
	
	if option == "all" or option == "font_size" then
		Timeline.title:SetSize(10*JST_CDB["GeneralOption"]["tl_font_size"], JST_CDB["GeneralOption"]["tl_font_size"]+6)
		Timeline.clock:SetFont(G.Font, JST_CDB["GeneralOption"]["tl_font_size"], "OUTLINE")	
	end
	
	for k, line in pairs(Timeline.Lines) do
		line:update_onedit(option)
	end
end

-- 文字条
local function Timeline_LineUpLines()
	local t = {}
	for i, line in pairs(Timeline.ActiveLines) do
		if line and line:IsVisible() then
			table.insert(t, line)
		end
	end
	if #t > 1 then
		table.sort(t, function(a, b) 
			if a.row_time < b.row_time then
				return true
			elseif a.row_time == b.row_time and a.ind < b.ind then
				return true
			end
		end)
	end
	local lastline
	for i, line in pairs(t) do
		line:ClearAllPoints()
		if line:IsVisible() then
			if not lastline then
				line:SetPoint("TOPLEFT", Timeline.title, "BOTTOMLEFT", 0, -5)
				lastline = line
			else
				line:SetPoint("TOPLEFT", lastline, "BOTTOMLEFT", 0, -5)
				lastline = line
			end
		end
	end
end

local function Timeline_QueueLine(frame)	
	frame:HookScript("OnShow", function(self)
		Timeline.ActiveLines[self.frame_key] = self
		Timeline_LineUpLines()
	end)
	
	frame:HookScript("OnHide", function(self)
		Timeline.ActiveLines[self.frame_key] = nil
		Timeline_LineUpLines()
	end)
end

local function Timeline_CreateLine(ind)
	local frame = CreateFrame("Frame", nil, Timeline)
	frame:SetSize(1000, JST_CDB["GeneralOption"]["tl_font_size"])
	frame:Hide()
	
	local fs = JST_CDB["GeneralOption"]["tl_font_size"] - 5
	
	frame.left = T.createtext(frame, "OVERLAY", fs, "OUTLINE", "LEFT")
	frame.left:SetPoint("LEFT", frame, "LEFT", 0, 0)
	frame.left:SetSize(60, fs)
	
	frame.right = T.createtext(frame, "OVERLAY", fs, "OUTLINE", "LEFT")
	frame.right:SetPoint("LEFT", frame.left, "RIGHT", 0, 0)
	frame.right:SetSize(940, fs)
	
	frame:HookScript("OnSizeChanged", function(self, width, height)
		self.left:SetFont(G.Font, height-5, "OUTLINE")
		self.right:SetFont(G.Font, height-5, "OUTLINE")
	end)
	
	frame.t = 0
	frame.ind = ind
	frame.frame_key = "timeline"..ind	
	frame.target_glow_enabled = true
	frame.script_play_enabled = true
	frame.sounds = {}

	frame.bar = T.CreateAlertTimerbar("timeline"..ind, 134376, "", {0, 1, .7})
	frame.text_frame = T.CreateAlertText("timeline"..ind, 2)
	
	function frame:update_onedit(option)
		if option == "all" or option == "font_size" then
			self:SetHeight(JST_CDB["GeneralOption"]["tl_font_size"])
		end
		
		if option == "all" or option == "format" then
			self:update_text()
		end
	end
	
	function frame:reset()
		--print("reset", frame.frame_key)
		self:Hide()
		self:SetScript("OnUpdate", nil)
		
		self.bar:Hide()
		self.text_frame:Hide()
		
		self.target_glow_enabled = nil
		self.script_play_enabled = nil
	end
	
	function frame:update_text()
		if JST_CDB["GeneralOption"]["tl_show_time"] then
			self.right:SetText(self.line_text_t)
		else
			self.right:SetText(self.line_text)
		end
	end
	
	function frame:glow_target()
		if self.target_glow_enabled then
			for name in frame.script:gmatch("{target:([^}]+)}") do -- 识别指向技能及目标
				local info = T.GetGroupInfobyName(name)
				if info then
					T.GlowRaidFramebyUnit_Show("proc", "timelinetarget", info.unit, {1, 1, 1}, 3)
				end
			end
			self.target_glow_enabled = nil
		end
	end
	
	function frame:play_script()
		if self.script_play_enabled then
			if #self.sounds > 0 then -- 用语音文件
				local ticker = C_Timer.NewTicker(0.5, function(s)
					s.ind = s.ind + 1
					T.PlaySound("custom\\"..self.sounds[s.ind]) 
				end, #self.sounds)
				ticker.ind = 0
			else -- 去掉不需要朗读的字符
				T.SpeakText(frame.script:gsub("{spell:(%d+)}", T.GetSpellInfo):gsub("{target:([^}]+)}", T.GetNameByName))
			end
			
			self.script_play_enabled = nil
		end
	end
	
	Timeline.Lines[frame.frame_key] = frame
	
	Timeline_QueueLine(frame)
end

local function Timeline_UpdateLine(frame, str, row_time, exp_time)
	--print("update", frame.frame_key)
	
	frame.row_time = row_time
	frame.exp_time = exp_time
	frame.sounds = table.wipe(frame.sounds)
	
	frame.line_text = str:gsub("%d+:%d+", ""):gsub("{spell:(%d+)}", T.GetSpellIcon):gsub("%[#([^%]]+)%]", "%1")
	frame.line_text_t = str:gsub("{spell:(%d+)}", T.GetSpellIcon):gsub("%[#([^%]]+)%]", "%1")
	frame:update_text()
	
	frame.script = GetMyScript(str)
	
	if frame.script ~= "" then
		frame.my_script = frame.script:gsub("%[#([^%]]+)%]", "%1"):gsub("{spell:(%d+)}", T.GetSpellIcon):gsub("{target:([^}]+)}", T.ColorNickNameByName)
		
		for v in frame.script:gmatch("%[#([^%]]+)%]") do -- 识别语音文件
			table.insert(frame.sounds, v)
		end
		
		frame.text_frame.text:SetText(frame.my_script)
		
		frame.bar.left:SetText(frame.my_script)
		frame.bar:SetMinMaxValues(0, JST_CDB["GeneralOption"]["tl_bar_dur"])
		frame.bar:SetValue(0)
		
		frame.target_glow_enabled = true
		frame.script_play_enabled = true
	end
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > update_rate then
			self.remain = self.exp_time - GetTime()
			if self.remain > 0 then
				self.event_remain = self.remain - Timeline.tl_dur
				self.left:SetText(FormatSec(self.event_remain))
				
				if self.script ~= "" then
					if self.event_remain > 0 then
						if JST_CDB["GeneralOption"]["tl_glowtarget"] and self.event_remain < 3 then
							self:glow_target()  -- 团队框架动画
						end
						
						if JST_CDB["GeneralOption"]["tl_sound"] and self.event_remain < JST_CDB["GeneralOption"]["tl_sound_dur"] then
							self:play_script() -- 声音提示
						end
						
						if JST_CDB["GeneralOption"]["tl_text"] and self.event_remain < JST_CDB["GeneralOption"]["tl_text_dur"] then
							if not self.text_frame:IsShown() then
								self.text_frame:Show() -- 文字提示
							end
							if JST_CDB["GeneralOption"]["tl_text_show_dur"] then
								self.text_frame.text:SetText(string.format("%s %.1f", self.my_script, self.event_remain))
							end
						end
						
						if JST_CDB["GeneralOption"]["tl_bar"] and self.event_remain < JST_CDB["GeneralOption"]["tl_bar_dur"] then
							if not self.bar:IsShown() then
								self.bar:Show() -- 计时条提示
							end
							self.bar.right:SetText(T.FormatTime(self.event_remain))
							self.bar:SetValue(JST_CDB["GeneralOption"]["tl_bar_dur"] - self.event_remain)
						end
					else
						if JST_CDB["GeneralOption"]["tl_text"] and self.text_frame:IsShown() then
							self.text_frame:Hide()
						end
						if JST_CDB["GeneralOption"]["tl_bar"] and self.bar:IsShown() then
							self.bar:Hide()
						end
					end
				end
			else
				self:reset()
			end
			self.t = 0
		end
	end)
	
	frame:Show()
end

Timeline:SetScript("OnUpdate", function(self, e)
	self.t = self.t + e
	if self.t > tl_update_rate then
		self.dur = GetTime() - self.start
		self.passed = floor(self.dur)
		self.fake_passed = floor(self.dur + self.time_offset) 
		if self.last ~= self.passed then	
			T.FireEvent("TIMELINE_PASSED", self.fake_passed)
			self.last = self.passed
		end
		
		if self.time_offset == 0 then
			self.clock:SetText(string.format("%s %s", timeicon, date("%M:%S", self.passed)))
		else
			self.clock:SetText(string.format("%s %s [%s %s]", timeicon, date("%M:%S", self.passed), L["运行时间"], date("%M:%S", self.fake_passed)))
		end
		self.t = 0
	end
end)

local function GetPhaseInfo(str)
	local phase_str, reset_m_str, reset_s_str = string.match(str, "P(.+) (%d+):(%d+)")
	if not (phase_str and reset_m_str and reset_s_str) then return end
	
	local phase = tonumber(phase_str)
	local minute = tonumber(reset_m_str)
	local second = tonumber(reset_s_str)
	
	if phase and minute and second then
		local dur = 60*minute + second
		return phase, dur
	end
end

Timeline:SetScript("OnEvent", function(self, event, ...)
	if event == "ENCOUNTER_START" then
		local engageID = ...
		self.start = GetTime()
		self:Show()
		
        if C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note then
			if JST_CDB["GeneralOption"]["tl_use_raid"] and _G.VExRT.Note.Text1 then
				local text = _G.VExRT.Note.Text1
				local betweenLine = false
				for line in text:gmatch('[^\r\n]+') do
					if line:match(L["战斗结束"]) then
						betweenLine = false
					end
					if betweenLine then                
						local str = line:gsub("||", "|")					
						if string.match(str, "P(.+) (%d+):(%d+)") then
							local phase, dur = GetPhaseInfo(str)
							if phase and dur then								
								if not self.phase_cd[phase] then
									self.phase_cd[phase] = {}
								end
								table.insert(self.phase_cd[phase], dur)
							end
						else
							local m, s = string.match(str, "(%d+):(%d+)")
							if m and s then
								local r = tonumber(m)*60+tonumber(s)
								local t = max(r - JST_CDB["GeneralOption"]["tl_advance"], 0)
								local info = {
									cd_str = str,
									row_time = r,
									show_time = t,
									hide_time = r + self.tl_dur,
								}
								table.insert(self.assignment_cd, info)
								--print(#self.assignment_cd, str, r, t)
							end
						end
					end
					if line:match(L["时间轴"]) then
						betweenLine = true
					end
				end    
			end
			if JST_CDB["GeneralOption"]["tl_use_self"] and _G.VExRT.Note.SelfText then		
				local text = _G.VExRT.Note.SelfText
				local betweenLine = false
				local phase_cd_cache = {}
				
				for line in text:gmatch('[^\r\n]+') do
					if line:match(L["战斗结束"]) then
						betweenLine = false
					end
					if betweenLine then                
						local str = line:gsub("||", "|")
						if string.match(str, "P(.+) (%d+):(%d+)") then
							local phase, dur = GetPhaseInfo(str)
							if phase and dur then
								if not phase_cd_cache[phase] then
									phase_cd_cache[phase] = {}
								end
								table.insert(phase_cd_cache[phase], dur)		
							end
						else
							local m, s = string.match(str, "(%d+):(%d+)")
							if m and s then
								local r = tonumber(m)*60+tonumber(s)
								local t = max(r - JST_CDB["GeneralOption"]["tl_advance"], 0)
								local info = {
									cd_str = str,
									row_time = r,
									show_time = t,
									hide_time = r + self.tl_dur,
								}
								table.insert(self.assignment_cd, info)
								--print(#self.assignment_cd, str, r, t)
							end
						end
					end

					if line and self.Encounter_Tags[engageID] and line:match(self.Encounter_Tags[engageID]..L["时间轴"]) then
						betweenLine = true
					end
				end
				-- 覆盖转阶段信息
				for phase, info in pairs(phase_cd_cache) do
					if not self.phase_cd[phase] then
						self.phase_cd[phase] = {}
					end
					for index, dur in pairs(phase_cd_cache[phase]) do
						self.phase_cd[phase][index] = dur
					end
				end
			end
        end    
    elseif event == "ENCOUNTER_END" then
		self.start = 0
		
		self.time_offset = 0
		self.assignment_cd = table.wipe(self.assignment_cd)
		self.phase_cd = table.wipe(self.phase_cd)
		
		if JST_CDB["GeneralOption"]["tl_glowtarget"] then -- 隐藏高亮
			T.GlowRaidFrame_HideAll("proc", "timelinetarget")
		end
		
		for _, line in pairs(self.ActiveLines) do  
			line:reset()
		end
		
		self:Hide()
	elseif event == "TIMELINE_PASSED" then
		local fake_passed = ...
		for i, t in pairs (self.assignment_cd) do
			if t.show_time <= fake_passed and t.hide_time > fake_passed then
				if not Timeline.Lines["timeline"..i] then
					Timeline_CreateLine(i)
				end
				if not Timeline.Lines["timeline"..i]:IsShown() then
					Timeline_UpdateLine(Timeline.Lines["timeline"..i], t.cd_str, t.row_time, self.start + t.row_time + self.tl_dur - self.time_offset)
				end
			elseif Timeline.Lines["timeline"..i] and Timeline.Lines["timeline"..i]:IsShown() then
				Timeline.Lines["timeline"..i]:reset()
			end			
		end	
	elseif event == "ENCOUNTER_PHASE" then
		local phase, count = ...
		local to_time = self.phase_cd[phase] and self.phase_cd[phase][count]
		if to_time then			
			self.time_offset = to_time - (GetTime() - self.start)
		
			for _, frame in pairs(self.ActiveLines) do
				frame.exp_time = self.start + frame.row_time + self.tl_dur - self.time_offset
			end
		end
	elseif event == "ADDON_LOADED" then
		local addon = ...
		if C_AddOns.GetAddOnMetadata(addon, "X-JST-journalInstanceID") then
			for ENCID, data in pairs(G.Encounters) do
				if type(ENCID) == "number" then -- 只针对首领战斗					
					if data.engage_id and not self.Encounter_Tags[data.engage_id] then
						self.Encounter_Tags[data.engage_id] = "JST"..ENCID
					end
				end
			end
		end
	elseif string.find(event, "VOICE_CHAT") then
		--print(event)
		if event == "VOICE_CHAT_TTS_PLAYBACK_FAILED" or event == "VOICE_CHAT_TTS_SPEAK_TEXT_UPDATE" then
			local status, utteranceID = ...
			if TTS_failed_type[status] then
				T.msg(string.format(L["朗读失败"], TTS_failed_type[status]))
			end
		end
    end
end)

Timeline:RegisterEvent("ADDON_LOADED")

---------------------------------------------------------
----------------[[    法术请求按钮    ]]------------------
----------------------------------------------------------
local ASFrame = CreateFrame("Frame", addon_name.."ASFrame", FrameHolder)
ASFrame.text_frames = {}

function ASFrame:CreateOptionFrame()
	local ind = #self.text_frames + 1
	local frame = T.CreateAlertText("ASFrame"..ind, 2)

	frame:HookScript("OnHide", function(self)
		self.active = false
	end)
	
	self.text_frames[ind] = frame

	return frame
end

function ASFrame:GetAvailableTextFrame()
	for i, frame in pairs(self.text_frames) do
		if not frame.active then
			frame.active = true
			return frame
		end
	end
	local new_frame = self:CreateOptionFrame()
	new_frame.active = true
	return new_frame
end

local Play_askspell_sound = function(player, spell)
	if JST_CDB["GeneralOption"]["cs_sound"] ~= "none" then
		if JST_CDB["GeneralOption"]["cs_sound"] ~= "speak" then
			T.PlaySound(JST_CDB["GeneralOption"]["cs_sound"])
		else
			T.SpeakText(spell..player)
		end
	end
end
T.Play_askspell_sound = Play_askspell_sound

local FormatAskedSpell = function(GUID, spellID, dur)
	local info = T.GetGroupInfobyGUID(GUID)
	local spell_name, spell_icon = T.GetSpellInfo(spellID)
	
	if info then
		Play_askspell_sound(T.GetNameByGUID(GUID), spell_name)
		
		local str = string.format("%s %s %s", T.GetTextureStr(spell_icon), info.format_name, T.GetTextureStr(spell_icon))
		
		local text_frame = ASFrame:GetAvailableTextFrame()
		T.Start_Text_Timer(text_frame, dur, str)
	
		T.GlowRaidFramebyUnit_Show("proc", "asspell", info.unit, {0, 1, 0}, dur) -- 团队框架动画
	end
end
T.FormatAskedSpell = FormatAskedSpell

local HideAskedSpell = function(GUID)
	if GUID then
		local info = T.GetGroupInfobyGUID(GUID)
		if info then
			T.GlowRaidFramebyUnit_Hide("proc", "asspell", info.unit)
		end
	else
		T.GlowRaidFrame_HideAll("proc", "asspell")
	end
	T.Stop_Text_Timer(ASFrame.text_frame)
end
T.HideAskedSpell = HideAskedSpell

local function UpdateAskSpell(event, ...)
	local channel, sender, mark, spell, GUID = ...
	if mark == "AskSpell" then
		if spell and GUID then
			local spellID = tonumber(spell)
			local info = T.GetGroupInfobyGUID(GUID)
			if info and spellID and T.GetSpellInfo(spellID) then
				T.msg(string.format(L["收到法术请求"], info.format_name, T.GetIconLink(spellID)))
				FormatAskedSpell(GUID, spellID, 3)
			end
		end
	end
end

T.EditASFrame = function(option)
	if option == "all" or option == "enable" then
		if JST_CDB["GeneralOption"]["cs"] then
			if not ASFrame.registed then
				T.RegisterCallback("ADDON_MSG", UpdateAskSpell)
				ASFrame.registed = true
			end
		else
			if ASFrame.registed then
				T.UnregisterCallback("ADDON_MSG", UpdateAskSpell)
				ASFrame.registed = nil
			end
		end
	end
end

----------------------------------------------------------
----------------[[    自保技能提示    ]]------------------
----------------------------------------------------------
local DSFrame = CreateFrame("Frame", addon_name.."DSFrame", FrameHolder)
DSFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
DSFrame:SetSize(400, 60)
DSFrame:Hide()

DSFrame.text = T.createtext(DSFrame, "OVERLAY", 30, "OUTLINE", "LEFT")
DSFrame.text:SetPoint("BOTTOM", DSFrame, "CENTER", 0, 10)

DSFrame.anim = DSFrame:CreateAnimationGroup()
DSFrame.anim:SetLooping("REPEAT")

DSFrame.alpha = DSFrame.anim:CreateAnimation("Alpha")
DSFrame.alpha:SetChildKey("text")
DSFrame.alpha:SetDuration(.6)
DSFrame.alpha:SetFromAlpha(.1)
DSFrame.alpha:SetToAlpha(1)

local DSIcons = {}
local DSActiveIcons = {}
local DSIconsize = 40

local LineUpDSIcons = function()
	local active_num = 0
	for _, icon in pairs(DSActiveIcons) do
		active_num = active_num + 1
	end
	local offset = ((DSIconsize+DSIconsize/4)*active_num-DSIconsize/4)/2
	
	local lasticon
	
	for _, icon in pairs(DSActiveIcons) do
		icon:ClearAllPoints()
		if not lasticon then
			icon:SetPoint("TOPLEFT", DSFrame, "CENTER", -offset, 0)
		else
			icon:SetPoint("LEFT", lasticon, "RIGHT", DSIconsize/4, 0)	
		end
		lasticon = icon
	end
end

local function QueueAlertIcon(frame)
	frame:HookScript("OnShow", function(self)
		DSActiveIcons[self.frame_key] = self
		LineUpDSIcons()
	end)
	
	frame:HookScript("OnHide", function(self)
		DSActiveIcons[self.frame_key] = nil
		LineUpDSIcons()
	end)
end

local function CreateDSIconBase()
	local frame = CreateFrame("Frame", nil, DSFrame)
	frame:SetSize(DSIconsize, DSIconsize)
	T.createborder(frame)
	frame:Hide()
	
	-- 图标材质
	frame.texture = frame:CreateTexture(nil, "BORDER", nil, 1)
	frame.texture:SetTexCoord( .1, .9, .1, .9)
	frame.texture:SetAllPoints()	
	
	-- 发光边框
	frame.glow = frame:CreateTexture(nil, "OVERLAY")
	frame.glow:SetPoint("TOPLEFT", -DSIconsize/2, DSIconsize/2)
	frame.glow:SetPoint("BOTTOMRIGHT", DSIconsize/2, -DSIconsize/2)
	frame.glow:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
	frame.glow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
	frame.glow:Hide()
	
	QueueAlertIcon(frame)
	
	table.insert(DSIcons, frame)

	return frame
end

local function CreateDsSpellIcon(spellID, auraID)
	local frame = CreateDSIconBase()
	frame.texture:SetTexture(select(2, T.GetSpellInfo(spellID)))
	
	frame.spellID = spellID
	frame.auraID = auraID
	frame.frame_key = "spell"..spellID

	function frame:update()
		if self.auraID and AuraUtil.FindAuraBySpellID(self.auraID, "player", "HELPFUL") then
			self.glow:Show()
			self:Show()
		else
			self.glow:Hide()
			if MySpellCheck(self.spellID) then
				self:Show()
			else
				self:Hide()
			end
		end
	end
	
	function frame:SetActive(enable)
		if enable then
			if self.auraID then
				self:RegisterUnitEvent("UNIT_AURA", "player")
			end
			self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
			self:update()
		else
			if self.auraID then
				self:UnregisterEvent("UNIT_AURA")
			end
			self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
			self.glow:Hide()
			self:Hide()
		end
	end

	frame:SetScript("OnEvent", function(self)
		self:update()
	end)
end

local function CreateDsItemIcon(itemID, auraID)
	local frame = CreateDSIconBase()
	frame.texture:SetTexture(select(5, C_Item.GetItemInfoInstant(itemID)))
	
	frame.itemID = itemID
	frame.auraID = auraID
	frame.frame_key = "item"..itemID
	
	function frame:update()
		if self.auraID and AuraUtil.FindAuraBySpellID(self.auraID, "player", "HELPFUL") then
			self.glow:Show()
			self:Show()
		else
			self.glow:Hide()
			if MyItemCheck(self.itemID) then
				self:Show()
			else
				self:Hide()
			end
		end
	end

	function frame:SetActive(enable)
		if enable then
			if self.auraID then
				self:RegisterUnitEvent("UNIT_AURA", "player")
			end
			self:RegisterEvent("BAG_UPDATE_COOLDOWN")
			self:update()
		else
			if self.auraID then
				self:UnregisterEvent("UNIT_AURA")
			end
			self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
			self.glow:Hide()
			self:Hide()
		end
	end
	
	frame:SetScript("OnEvent", function(self, event)
		self:update()
	end)
end

local Defense_spell_class = {
	PRIEST = { 
        {19236, 19236}, -- 绝望祷言
		{33206, 33206}, -- 痛苦压制
		{47788, 47788}, -- 守护之魂
		{47585, 47585}, -- 消散
	},
	DRUID = {
		{22812}, -- 树皮术
	    {102342}, -- 铁木树皮
		{61336}, -- 生存本能
		{22842}, -- 狂暴回复
	},
	SHAMAN = { 
		{108271}, -- 星界转移
	},
	PALADIN = {
        {498}, -- 圣佑术
		{642}, -- 圣盾术
	},
	WARRIOR = { 
		{12975}, -- 破釜沉舟
		{871}, -- 盾墙
		{184364}, -- 狂怒回复
		{118038}, -- 剑在人在
	},
	MAGE = { 
		{45438}, -- 寒冰屏障
	},
	WARLOCK = { 
		{104773}, -- 不灭决心
	},
	HUNTER = { 
		{186265}, -- 灵龟守护
	},
	ROGUE = { 
		{31224}, -- 暗影斗篷
		{1966}, -- 佯攻
	},
	DEATHKNIGHT = {
		{48707}, -- 反魔法护罩
		{48792}, -- 冰封之韧
	},
	MONK = {
		{116849}, -- 作茧缚命
		{115203}, -- 壮胆酒
		{122470}, -- 业报之触
		{122783}, -- 散魔功
	},
	DEMONHUNTER = {
		{196555}, -- 虚空行走 浩劫
		{187827}, -- 恶魔变形
		{212084}, -- 邪能毁灭
		{204021}, -- 烈火烙印
		{203720}, -- 恶魔尖刺
	},
	EVOKER = {

	},
}

local Defense_spell_common = {
	--{203720}, -- 恶魔尖刺
}

local Defense_item_common = {
	{5512}, -- 治疗石
}

T.RegisterInitCallback(function()
	for i, info in pairs(Defense_spell_class[G.myClass]) do
		CreateDsSpellIcon(info[1], info[2])
	end
	for i, info in pairs(Defense_spell_common) do
		CreateDsSpellIcon(info[1], info[2])
	end
	for i, info in pairs(Defense_item_common) do
		CreateDsItemIcon(info[1], info[2])
	end
end)

function DSFrame:update()
	local perc = UnitHealth("player")/UnitHealthMax("player")
	self.text:SetTextColor(1, perc, 0)
	self.text:SetText(string.format(L["注意自保血量"], perc*100))
end

DSFrame:SetScript("OnEvent", function(self, event)
	if event == "UNIT_HEALTH" then
		self:update()
    end
end)

local HideDSFrame = function()
	for i, frame in pairs(DSIcons) do
		frame:SetActive(false)
	end
	DSFrame:UnregisterEvent("UNIT_HEALTH")
	DSFrame:Hide()
	DSFrame.anim:Stop()
end
T.HideDSFrame = HideDSFrame

local ShowDSFrame = function(dur)
	for i, frame in pairs(DSIcons) do
		frame:SetActive(true)
	end
	DSFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
	DSFrame:update()
	DSFrame:Show()
	DSFrame.anim:Play()
	if dur then
		C_Timer.After(dur, HideDSFrame)
	end
end
T.ShowDSFrame = ShowDSFrame
----------------------------------------------------------
----------------[[    团队私人光环    ]]------------------
----------------------------------------------------------
local raid_pa_tag = "#jst_pa_start"
G.raid_pa_tag = raid_pa_tag

local RaidPAFrame = CreateFrame("Frame", addon_name.."PAFrame", FrameHolder)
RaidPAFrame:SetSize(200, 200)
RaidPAFrame.unitframes = {}
RaidPAFrame.encounters = {}

RaidPAFrame.movingname = L["团队PA光环"]
RaidPAFrame.point = { a1 = "TOPLEFT", a2 = "TOPLEFT", x = 20, y = -170}
T.CreateDragFrame(RaidPAFrame)

function RaidPAFrame:PreviewShow()
	RaidPAFrame.generate_all()
end

function RaidPAFrame:PreviewHide()
	RaidPAFrame.release_all()
end

T.GetMrtForPrivateAuraRaidFrame = function()		
	local raidlist = ""
	local i = 0
	
	for unit in T.IterateGroupMembers() do
		i = i + 1
		local name = UnitName(unit)
		if i == 1 then
			raidlist = raidlist..string.format("[%d]", ceil(i/5))..T.ColorNameForMrt(name).." "
		elseif mod(i, 5) == 1 then
			raidlist = raidlist.."\n"..string.format("[%d]", ceil(i/5))..T.ColorNameForMrt(name).." "
		else
			raidlist = raidlist..T.ColorNameForMrt(name).." "
		end
	end
	
	raidlist = string.format("%s\n%s\nend", G.raid_pa_tag, raidlist).."\n"
	
	local button = _G[G.addon_name.."toolsScrollAnchor"].pa_copy_mrt		
	T.DisplayCopyString(button, raidlist)
end

local function Hook_PrivateAura_Anchor(uf)
	for i = 1, 4 do
		if not uf["auraAnchorID"..i] then
			uf["auraAnchorID"..i] = C_UnitAuras.AddPrivateAuraAnchor({
				unitToken = uf.unit,
				auraIndex = i,
				parent = uf,
				showCountdownFrame = true,
				showCountdownNumbers = false,
				iconInfo = {
					iconWidth = JST_CDB["GeneralOption"]["raid_pa_height"],
					iconHeight = JST_CDB["GeneralOption"]["raid_pa_height"],
					iconAnchor = {
						point = "LEFT",
						relativeTo = uf,
						relativePoint = "RIGHT",
						offsetX = 2+(i-1)*(JST_CDB["GeneralOption"]["raid_pa_height"]+2),
						offsetY = 0,
					},
				},
			})
		end
	end
end

local function Remove_PrivateAura_Anchor(uf)
	for i = 1, 4 do
		if uf["auraAnchorID"..i] then
			C_UnitAuras.RemovePrivateAuraAnchor(uf["auraAnchorID"..i])
			uf["auraAnchorID"..i] = nil
		end
	end
end

local function Create_PrivateAura_UF(GUID, w, h, font_size, icon_num, frame_num, num)
	local info = T.GetGroupInfobyGUID(GUID)
	local uf = CreateFrame("Frame", nil, RaidPAFrame)
	local uf_width = w+2+icon_num*(h+2) -- 框架+图标宽度
	
	uf:SetSize(w, h)
	uf:SetPoint("TOPLEFT", RaidPAFrame, "TOPLEFT", frame_num*(uf_width+5), -num*(h+3))
	
	uf.text = T.createtext(uf, "OVERLAY", font_size, "OUTLINE", "CENTER")
	uf.text:SetPoint("LEFT", uf, "LEFT", 3, 0)
	uf.text:SetText(info.format_name)
	
	T.createborder(uf, .3, .3, .3)
	
	if UnitIsUnit(info.unit, "player") then
		uf.sd:SetBackdropColor(0, 1, 0)
	end
	
	uf.Update = function()
		local w, h, font_size, icon_num = JST_CDB["GeneralOption"]["raid_pa_width"], JST_CDB["GeneralOption"]["raid_pa_height"], JST_CDB["GeneralOption"]["raid_pa_fsize"], JST_CDB["GeneralOption"]["raid_pa_icon_num"]
		local uf_width = w+2+icon_num*(h+2)
		uf:SetSize(w, h)
		uf.text:SetFont(G.Font, font_size, "OUTLINE")
		uf:ClearAllPoints()
		uf:SetPoint("TOPLEFT", RaidPAFrame, "TOPLEFT", frame_num*(uf_width+5), -num*(h+3))
	end
	
	uf.unit = info.unit
	Hook_PrivateAura_Anchor(uf)	
	
	table.insert(RaidPAFrame.unitframes, uf)
end

T.EditRaidPAFrame = function(option)
	if option == "all" or option == "enable" then
		if JST_CDB["GeneralOption"]["raid_pa"] then
			T.RestoreDragFrame(RaidPAFrame)
			RaidPAFrame:RegisterEvent("ENCOUNTER_START")
			RaidPAFrame:RegisterEvent("ENCOUNTER_END")
		else
			T.ReleaseDragFrame(RaidPAFrame)
			RaidPAFrame:UnregisterEvent("ENCOUNTER_START")
			RaidPAFrame:RegisterEvent("ENCOUNTER_END")
			RaidPAFrame.release_all()
		end
	end
	
	if option == "all" or option == "size" then
		local w, h, font_size, icon_num = JST_CDB["GeneralOption"]["raid_pa_width"], JST_CDB["GeneralOption"]["raid_pa_height"], JST_CDB["GeneralOption"]["raid_pa_fsize"], JST_CDB["GeneralOption"]["raid_pa_icon_num"]
		local uf_width = w+2+icon_num*(h+2)
		if C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1 then
			local text = _G.VExRT.Note.Text1
			local betweenLine = false
			local frame_num, frame_num_each = 0, 0
						
			for line in text:gmatch('[^\r\n]+') do
				if line == "end" then
					betweenLine = false
				end
				if betweenLine then
					local num = 0
					for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do						
						num = num + 1
					end
					frame_num_each = max(frame_num_each, num) -- 最大单列人数
					if num > 0 then
						frame_num = frame_num + 1 -- 增加列数
					end
				end
				if line:match(raid_pa_tag) then
					betweenLine = true
				end
			end
			
			for i, uf in pairs(RaidPAFrame.unitframes) do
				uf:Update()
			end
			
			if frame_num > 0 and frame_num_each > 0 then
				RaidPAFrame:SetSize(frame_num*uf_width+(frame_num-1)*5, frame_num_each*(h+3)-3)
			else
				RaidPAFrame:SetSize(2*uf_width+5, 5*(h+3)-3)
			end
		else
			-- 没写战术板时2*10
			RaidPAFrame:SetSize(2*uf_width+5, 5*(h+3)-3)
		end
	end
end

RaidPAFrame.generate_all = function()
	if C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1 then		
		local text = _G.VExRT.Note.Text1
		local betweenLine = false	
		local frame_num, frame_num_each = 0, 0
		local w, h, font_size, icon_num = JST_CDB["GeneralOption"]["raid_pa_width"], JST_CDB["GeneralOption"]["raid_pa_height"], JST_CDB["GeneralOption"]["raid_pa_fsize"], JST_CDB["GeneralOption"]["raid_pa_icon_num"]
		local uf_width = w+2+icon_num*(h+2)
		
		for line in text:gmatch('[^\r\n]+') do
			if line == "end" then
				betweenLine = false
			end
			if betweenLine then
				local num = 0
				for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
					local info = T.GetGroupInfobyName(name)
					if info then
						Create_PrivateAura_UF(info.GUID, w, h, font_size, icon_num, frame_num, num)
						num = num + 1
					else
						T.test_msg(string.format(L["昵称错误"], name))
					end
				end
				frame_num_each = max(frame_num_each, num) -- 最大单列人数
				if num > 0 then
					frame_num = frame_num + 1 -- 增加列数
				end
			end
			if line:match(raid_pa_tag) then
				betweenLine = true
			end
			
			if frame_num > 0 and frame_num_each > 0 then
				RaidPAFrame:SetSize(frame_num*uf_width+(frame_num-1)*5, frame_num_each*(h+3)-3)
			else
				RaidPAFrame:SetSize(2*uf_width+5, 5*(h+3)-3)
			end
		end
		
		RaidPAFrame:Show()
	end
end

RaidPAFrame.release_all = function()
	for i, uf in pairs(RaidPAFrame.unitframes) do
		uf:Hide()
		Remove_PrivateAura_Anchor(uf)
	end
	RaidPAFrame.unitframes = table.wipe(RaidPAFrame.unitframes)
	RaidPAFrame:Hide()
end

RaidPAFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
RaidPAFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		for _, info in pairs(G.Encounters) do
			if info.engage_id then
				self.encounters[info.engage_id] = true
			end
		end
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	elseif event == "ENCOUNTER_START" then
		local engageID = ...
		if self.encounters[engageID] then
			self.generate_all()
		end
	elseif event == "ENCOUNTER_END" then
		self.release_all()
	end
end)