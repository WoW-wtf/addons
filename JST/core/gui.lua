local T, C, L, G = unpack(select(2, ...))

local addon_name = G.addon_name
local font = G.Font
local GUI_width = 950
local GUI_height = 730
--====================================================--
--[[                   -- GUI --                    ]]--
--====================================================--
local GUI = CreateFrame("Frame", addon_name.."_GUI", UIParent, "SettingsFrameTemplate")
G.GUI = GUI

GUI:SetSize(GUI_width, GUI_height)
GUI:SetPoint("TOPRIGHT", UIParent, "CENTER", 415, 365)
GUI:SetFrameStrata("HIGH")
GUI:SetFrameLevel(2)
GUI:Hide()

GUI:RegisterForDrag("LeftButton")
GUI:SetScript("OnDragStart", function(self) self:StartMoving() end)
GUI:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
GUI:SetClampedToScreen(true)
GUI:SetMovable(true)
GUI:EnableMouse(true)
GUI:EnableKeyboard(true)

GUI:SetScript("OnKeyDown", function(self, key)
	if key == "ESCAPE" then
		if not InCombatLockdown() then
			self:SetPropagateKeyboardInput(false)
		end
		GUI:Hide()
	else
		if not InCombatLockdown() then
			self:SetPropagateKeyboardInput(true)
		end
	end
end)

GUI.NineSlice.Text:SetText(G.addon_cname.." "..G.Version)
GUI.NineSlice.Text:SetFont(G.Font, 16, "OUTLINE")
GUI.NineSlice.Text:SetShadowOffset(0, 0)

GUI.updatebutton = T.ClickButton(GUI, 80, {"BOTTOMLEFT", GUI, "BOTTOMLEFT", 17, 10}, L["更新"])
GUI.updatebutton:SetScript("OnClick", function(self)
	T.DisplayCopyString(self, G.link, L["下载网址"].." "..L["复制粘贴"])
end)

GUI.load_roles = T.ClickButton(GUI, 80, {"LEFT", GUI.updatebutton, "RIGHT", 5, 0}, L["加载规则"])
GUI.load_roles:SetScript("OnClick", function(self)
	T.ToggleSetup()
end)

GUI.import = T.ClickButton(GUI, 80, {"LEFT", GUI.load_roles, "RIGHT", 5, 0}, L["导入"])
GUI.import:SetScript("OnClick", function(self)
	T.DisplayCopyString(self, "", nil, function(str) T.ImportSettings(str) end)
end)

GUI.export = T.ClickButton(GUI, 80, {"LEFT", GUI.import, "RIGHT", 5, 0}, L["导出"])
GUI.export:SetScript("OnClick", function(self)
	T.DisplayCopyString(self, T.ExportSettings())
end)

GUI.lock = T.ClickButton(GUI, 80, {"BOTTOMRIGHT", GUI, "BOTTOMRIGHT", -10, 10}, L["锁定框体"])
GUI.lock:SetScript("OnClick", function()
	T.LockAll()
end)

GUI.unlock = T.ClickButton(GUI, 80, {"RIGHT", GUI.lock, "LEFT", -5, 0}, L["解锁框体"])
GUI.unlock:SetScript("OnClick", function()
	if G.current_encounterID then
		JST_CDB["GeneralOption"]["moving_boss"] = G.current_encounterID
	end
	T.UnlockCurrentBoss()
end)

GUI.reload = T.ClickButton(GUI, 80, {"RIGHT", GUI.unlock, "LEFT", -5, 0}, L["重载界面"])
GUI.reload:SetScript("OnClick", ReloadUI)

local UpdateGUIScale = function()
	GUI:SetScale(JST_CDB["GeneralOption"]["gui_scale"]/100)
end
T.UpdateGUIScale = UpdateGUIScale

GUI.logo = GUI:CreateTexture(nil, "BACKGROUND")
GUI.logo:SetSize(170, 170)
GUI.logo:SetPoint("BOTTOMLEFT", GUI, "BOTTOMLEFT", 10, 50)
GUI.logo:SetTexture(G.media.logo)
GUI.logo:SetBlendMode("ADD")
GUI.logo:SetAlpha(.2)
--====================================================--
--[[               -- Options --                    ]]--
--====================================================--
local GUI_TabFrame = CreateFrame("Frame", nil, GUI)
GUI_TabFrame:SetPoint("TOPLEFT", 20, -55)
GUI_TabFrame:SetPoint("BOTTOMLEFT", 20, 45)
GUI_TabFrame:SetWidth(150)
T.createGUIbd(GUI_TabFrame, .2)

G.GUI_TabFrame = GUI_TabFrame

local GUI_PageFrame = CreateFrame("Frame", nil, GUI)
GUI_PageFrame:SetPoint("TOPLEFT", GUI_TabFrame, "TOPRIGHT", 5, 0)
GUI_PageFrame:SetPoint("BOTTOMLEFT", GUI_TabFrame, "BOTTOMRIGHT", 5, 0)
GUI_PageFrame:SetWidth(GUI_width - 190)
T.createGUIbd(GUI_PageFrame, .2)

G.GUI_PageFrame = GUI_PageFrame

local tabInfo = {
	L["选项"],
	L["团队副本"],
	L["地下城"],
}

for index, text in pairs(tabInfo) do
	T.CreateGUITab(index, text)
end
--====================================================--
--[[               -- EditBox --                    ]]--
--====================================================--
local editFrame = CreateFrame("Frame", G.addon_name.."editFrame_BG", GUI)
editFrame:SetSize(GUI_width - 8, 150)
editFrame:SetPoint("TOPLEFT", GUI, "BOTTOMLEFT", 6, -1)
editFrame:SetFrameStrata("HIGH")
editFrame:SetFrameLevel(2)
editFrame:Hide()
T.createGUIbd(editFrame)
	
editFrame.title = T.createtext(editFrame, "ARTWORK", 12, "OUTLINE", "LEFT")
editFrame.title:SetPoint("TOPLEFT", 20, -10)
editFrame.title:SetTextColor(1, .82, 0)

editFrame.close = CreateFrame("Button", nil, editFrame, "UIPanelCloseButton")
editFrame.close:SetPoint("TOPRIGHT", -4, -4)
editFrame.close:SetScript("OnClick", function()
	editFrame:Hide()
	editFrame.edit:SetText("")
end)

editFrame.sf = CreateFrame("ScrollFrame", G.addon_name.."editFrame_SC", editFrame, "UIPanelScrollFrameTemplate")
editFrame.sf:SetPoint("TOPLEFT", 10, -25)
editFrame.sf:SetPoint("BOTTOMRIGHT", -50, 10)
T.createborder(editFrame.sf)
	
editFrame.edit = CreateFrame("EditBox", G.addon_name.."editFrame", editFrame.sf)
editFrame.edit:SetPoint("TOPLEFT", editFrame.sf, "TOPLEFT", 0, -3)
editFrame.edit:SetWidth(editFrame.sf:GetWidth()-30)
editFrame.edit:SetHeight(editFrame.sf:GetHeight())

editFrame.edit:SetTextInsets(3, 3, 3, 3)
editFrame.edit:SetFont(G.Font, 12, "OUTLINE")
editFrame.edit:SetMultiLine(true)
editFrame.edit:EnableMouse(true)
editFrame.sf:SetScrollChild(editFrame.edit)
	
editFrame.edit:SetScript("OnEditFocusGained", function(self)
	self:HighlightText()
end)
	
editFrame.edit:SetScript("OnEditFocusLost", function(self)
	self:HighlightText(0,0)
end)

editFrame.accept = T.ClickButton(editFrame, 120, {"BOTTOMRIGHT", editFrame, "BOTTOM", -20, 5}, ACCEPT)
editFrame.cancel = T.ClickButton(editFrame, 120, {"BOTTOMLEFT", editFrame, "BOTTOM", 20, 5}, CANCEL)
editFrame.cancel:SetScript("OnClick", function()
	editFrame:Hide()
end)

editFrame:SetScript("OnShow", function(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
end)

editFrame:SetScript("OnHide", function(self)
	self.lastbutton = nil
	self.edit:SetText("")
end)

local UpdateEditFrame = function(text, title_text, on_accept)
	if on_accept then
		editFrame.sf:SetPoint("BOTTOMRIGHT", -50, 30)
		editFrame.close:Hide()
		editFrame.accept:Show()
		editFrame.cancel:Show()
				
		editFrame.accept:SetScript("OnClick", function()
			on_accept(editFrame.edit:GetText())
			editFrame:Hide()
		end)
	else
		editFrame.sf:SetPoint("BOTTOMRIGHT", -50, 10)
		editFrame.close:Show()
		editFrame.accept:Hide()
		editFrame.cancel:Hide()
	end
	
	editFrame.title:SetText(title_text or L["复制粘贴"])
	editFrame.edit:SetText(text)
	editFrame:Show()
end

T.DisplayCopyString = function(button, text, title_text, on_accept)	
	if editFrame.lastbutton == button then
		editFrame:Hide()
	else
		editFrame.lastbutton = button
		UpdateEditFrame(text, title_text, on_accept)
		button:SetScript("OnHide", function(self)
			if self == editFrame.lastbutton then
				editFrame:Hide()
			end
		end)
	end
end
--====================================================--
--[[              -- Detail Panel --                ]]--
--====================================================--
local detailFrame = CreateFrame("Frame", G.addon_name.."detailFrame_BG", GUI)

detailFrame.data = {}
detailFrame.options = {}

detailFrame:SetSize(GUI_width - 8, 100)
detailFrame:SetPoint("TOPLEFT", GUI, "BOTTOMLEFT", 6, -1)
detailFrame:SetFrameStrata("HIGH")
detailFrame:SetFrameLevel(2)
detailFrame:Hide()
T.createGUIbd(detailFrame)

detailFrame.title = T.createtext(detailFrame, "ARTWORK", 14, "OUTLINE", "LEFT")
detailFrame.title:SetPoint("TOPLEFT", 20, -10)
detailFrame.title:SetTextColor(1, .82, 0)

detailFrame.close = CreateFrame("Button", nil, detailFrame, "UIPanelCloseButton")
detailFrame.close:SetPoint("TOPRIGHT", -4, -4)
detailFrame.close:SetScript("OnClick", function()
	detailFrame:Hide()
end)

detailFrame.reset = T.ClickButton(detailFrame, 80, {"RIGHT", detailFrame.close, "LEFT", -5, 0}, L["重置设置"])

detailFrame.sfa = CreateFrame("Frame", nil, detailFrame)
detailFrame.sfa:SetPoint("TOPLEFT", detailFrame, "TOPLEFT", 20, -40)
detailFrame.sfa:SetPoint("BOTTOMRIGHT", detailFrame, "BOTTOMRIGHT", -30, 0)

detailFrame:SetScript("OnShow", function(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
	editFrame:SetPoint("TOPLEFT", detailFrame, "BOTTOMLEFT", 0, -4)
end)

detailFrame:SetScript("OnHide", function(self)
	editFrame:SetPoint("TOPLEFT", GUI, "BOTTOMLEFT", 6, -2)
	self.lastbutton = nil
end)

G.detailFrame = detailFrame

--====================================================--
--[[              -- Option List --                  ]]--
--====================================================--
local opFrame = CreateFrame("Frame", G.addon_name.."OptionListFrame_BG", GUI)

opFrame.options = {}

opFrame:SetSize(460, 200)
opFrame:SetFrameStrata("DIALOG")
opFrame:Hide()
opFrame:EnableMouse(true)
T.createGUIbd(opFrame, 1)

opFrame.title = T.createtext(opFrame, "ARTWORK", 14, "OUTLINE", "LEFT")
opFrame.title:SetPoint("TOPLEFT", 20, -10)
opFrame.title:SetTextColor(1, .82, 0)

opFrame.close = CreateFrame("Button", nil, opFrame, "UIPanelCloseButton")
opFrame.close:SetPoint("TOPRIGHT", -4, -4)
opFrame.close:SetScript("OnClick", function()
	opFrame:Hide()
end)

for i = 1, 4 do
	T.CreateSupportSpellDDFrame(opFrame, i)
end

T.InitSupportSpecDD(opFrame.dd_frame4.dd)

function opFrame:InitOptions()
	T.UpdateSpellCountDD(self, self.alert.support_spells)
	T.UpdateSpellIndexDD(self, #self.alert.info)
	T.UpdateSupportSpellDD(self)
	T.UpdateSupportSpecDD(self)
end

opFrame.add_btn = T.ClickButton(opFrame, 40, {"LEFT", opFrame.dd_frame4, "RIGHT", 20, 2}, L["添加"])
opFrame.add_btn:SetScript("OnClick", function()
	opFrame:Add()
end)

opFrame.sf = CreateFrame("ScrollFrame", G.addon_name.."OptionListFrame_ScrollFrame", opFrame, "UIPanelScrollFrameTemplate")
opFrame.sf:SetPoint("TOPLEFT", opFrame, "TOPLEFT", 10, -35)
opFrame.sf:SetSize(420, 160)
opFrame.sf:SetFrameLevel(opFrame:GetFrameLevel()+1)

opFrame.sfa = CreateFrame("Frame", G.addon_name.."OptionListFrame_ScrollAnchor", opFrame.sf)
opFrame.sfa:SetPoint("TOPLEFT", opFrame.sf, "TOPLEFT", 0, 0)
opFrame.sfa:SetWidth(opFrame.sf:GetWidth())
opFrame.sfa:SetHeight(opFrame.sf:GetHeight())

opFrame.sf:SetScrollChild(opFrame.sfa)

function opFrame:LineupOptionFrames()
	local t = {}
	
	for _, frame in pairs(self.options) do
		if frame.active then
			table.insert(t, frame)
		end
	end
	
	table.sort(t, function(a, b)
		if a.spell_count < b.spell_count then
			return true
		elseif a.spell_count == b.spell_count and a.spell_ind < b.spell_ind then			
			return true
		elseif a.spell_count == b.spell_count and a.spell_ind == b.spell_ind and a.ind < b.ind then
			return true
		end
	end)
	
	for i, frame in pairs(t) do
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", self.sfa, "TOPLEFT", 5, 25-i*30)
	end
end

local function FormatSpecStr(all_spec, spec_info)
	local str = ""
	if all_spec then
		str = ALL..SPECIALIZATION
	else
		local t = {}
		for specID in pairs(spec_info) do
			table.insert(t, specID)		
		end
		table.sort(t)
		for _, specID in pairs(t) do
			local _, name, _, icon = GetSpecializationInfoByID(specID)
			str = str.."|T"..icon..":12:12:0:0:64:64:4:60:4:60|t "..name
		end
	end
	return str
end

function opFrame:CreateOptionFrame()
	local frame = CreateFrame("Frame", nil, opFrame.sfa)
	frame:SetSize(410, 25)
	frame:Hide()
	T.createGUIbd(frame)
	
	for i = 1, 5 do
		frame["text"..i] = T.createtext(frame, "OVERLAY", 12, "OUTLINE", "LEFT")			
		if i == 1 then
			frame["text"..i]:SetPoint("LEFT", frame, "LEFT", 5, 0)
			frame["text"..i]:SetSize(30, 25)
		else
			if i == 2 or i == 3 then
				frame["text"..i]:SetSize(50, 25)
			elseif i == 4 then
				frame["text"..i]:SetSize(100, 25)
			elseif i == 5 then
				frame["text"..i]:SetSize(150, 25)
			end		
			frame["text"..i]:SetPoint("LEFT", frame["text"..(i-1)], "RIGHT", 0, 0)
		end
	end
	
	frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.close:SetPoint("LEFT", frame.text5, "RIGHT", 0, 0)
	frame.close:Show()
	
	frame.close:SetScript("OnEnter", function(s)	
		GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
		GameTooltip:AddLine(DELETE)
		GameTooltip:Show()
	end)
	
	frame.close:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	frame.close:SetScript("OnClick", function() 
		opFrame:Remove(frame.ind)
		frame:remove()
		opFrame:LineupOptionFrames()		
	end)
	
	function frame:update(spellID, ind, spell_count, spell_ind, support_spellID, all_spec, spec_info)		
		frame.spell_count = spell_count
		frame.spell_ind = spell_ind
		frame.ind = ind
		
		frame.text1:SetText(T.GetSpellIcon(spellID))
		frame.text2:SetText(string.format(L["第%d轮"], spell_count))
		frame.text3:SetText(string.format(L["%d号位"], spell_ind))
		frame.text4:SetText(T.GetIconLink(support_spellID))
		frame.text5:SetText(FormatSpecStr(all_spec, spec_info))
		
		frame:Show()
		frame.active = true
	end
	
	function frame:remove()
		frame:Hide()
		frame.active = false
	end
	
	table.insert(opFrame.options, frame)
	
	return frame
end

function opFrame:GetAvailableOption()
	for i, frame in pairs(self.options) do
		if not frame.active then
			return frame
		end
	end
	return self:CreateOptionFrame()
end

function opFrame:DisplayData()
	for _, frame in pairs(self.options) do
		frame:remove()
	end
	
	for i, info in pairs(JST_CDB["BossMod"][self.alert.config_id]["option_list_btn"]) do
		local frame = self:GetAvailableOption()
		frame:update(self.alert.config_id, i, info.spell_count, info.spell_ind, info.support_spellID, info.all_spec, info.spec_info)
	end
	
	self:LineupOptionFrames()
end

function opFrame:Add()
	local ind = #JST_CDB["BossMod"][self.alert.config_id]["option_list_btn"] + 1
	local spell_count = UIDropDownMenu_GetSelectedValue(self.dd_frame1.dd)
	local spell_ind = UIDropDownMenu_GetSelectedValue(self.dd_frame2.dd)
	local support_spellID = UIDropDownMenu_GetSelectedValue(self.dd_frame3.dd)
	local all_spec = self.dd_frame4.dd:IsAllSelected()
		
	if all_spec then
		table.insert(JST_CDB["BossMod"][self.alert.config_id]["option_list_btn"], {
			spell_count = spell_count,
			spell_ind = spell_ind,
			support_spellID = support_spellID,
			all_spec = true,
		})
	else
		local t = {}
		for specID in pairs(self.dd_frame4.dd.active_specs) do
			t[specID] = true
		end
		table.insert(JST_CDB["BossMod"][self.alert.config_id]["option_list_btn"], {
			spell_count = spell_count,
			spell_ind = spell_ind,
			support_spellID = support_spellID,
			spec_info = t,
		})
	end
	
	local frame = self:GetAvailableOption()
	frame:update(self.alert.config_id, ind, spell_count, spell_ind, support_spellID, all_spec, self.dd_frame4.dd.active_specs)
	
	self:LineupOptionFrames()
end

function opFrame:Remove(ind)
	table.remove(JST_CDB["BossMod"][self.alert.config_id]["option_list_btn"], ind)
end

opFrame:SetScript("OnShow", function(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
	self:InitOptions()
	self:DisplayData()
end)

opFrame:SetScript("OnHide", function(self)
	self.lastbutton = nil
end)

local Toggle_opFrame = function(button, alert)
	if opFrame:IsShown() then
		opFrame:Hide()
	else
		opFrame.lastbutton = button
		opFrame.alert = alert
		opFrame:Show()
		opFrame:ClearAllPoints()
		opFrame:SetPoint("BOTTOMLEFT", button, "TOPLEFT", 4, 0)
		button:SetScript("OnHide", function(self)
			if self == opFrame.lastbutton then
				opFrame:Hide()
			end
		end)
	end
end
T.Toggle_opFrame = Toggle_opFrame
--====================================================--
--[[                   -- 通用 --                   ]]--
--====================================================--
local options = T.CreateOptionPage(1, nil, "general", L["通用"])

T.CreateGUIOpitons(options.sfa, "GeneralOption", 1, 10)
T.CreateGUIOpitons(options.sfa, "IconAlertOption")
T.CreateGUIOpitons(options.sfa, "TimerbarOption")
T.CreateGUIOpitons(options.sfa, "TextAlertOption")
T.CreateGUIOpitons(options.sfa, "RFIconOption")
T.CreateGUIOpitons(options.sfa, "PlateAlertOption")
T.CreateGUIOpitons(options.sfa, "GeneralOption", 11, 17)
--====================================================--
--[[                   -- 小工具 --                 ]]--
--====================================================--
local tool_options = T.CreateOptionPage(1, nil, "tools", L["小工具"])

T.CreateGUIOpitons(tool_options.sfa, "GeneralOption", 18)

--====================================================--
--[[                  -- 团队信息 --                ]]--
--====================================================--
local raid_options = T.CreateOptionPage(1, nil, "raid", L["团队信息"])

T.CreateGUIOpitons(raid_options.sfa, "RaidInfo")

G.raid_options = raid_options

--====================================================--
--[[                   -- 制作 --                   ]]--
--====================================================--
local credits = T.CreateOptionPage(1, nil, "credits", L["制作"])

local logo = credits.sfa:CreateTexture(nil, "OVERLAY")
logo:SetSize(300, 300)
logo:SetPoint("TOP", credits.sfa, "TOP", 0, -50)
logo:SetTexture(G.media.logo)
logo:SetBlendMode("ADD")

local info = T.createtext(credits.sfa, "OVERLAY", 25, "OUTLINE", "CENTER")
info:SetPoint("TOP", logo, "BOTTOM", 0, -50)
info:SetText(L["制作文本"])

local contact = T.createtext(credits.sfa, "OVERLAY", 15, "OUTLINE", "CENTER")
contact:SetPoint("TOP", info, "BOTTOM", 0, -50)
contact:SetTextColor(.5, .5, .5)
contact:SetText(G.Contacts)
--====================================================--
--[[                -- Init --                      ]]--
--====================================================--
GUI:HookScript("OnHide", function(self)
	editFrame:Hide()
	detailFrame:Hide()
	opFrame:Hide()
end)

local memorytext = T.createtext(UIParent, "OVERLAY", 14, "OUTLINE", "RIGHT")
memorytext:SetPoint("TOP", 0, -60)

local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("ADDON_LOADED")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
eventframe.t = 0

if G.TestMod then
	eventframe:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > .5 then
			UpdateAddOnMemoryUsage()
			memorytext:SetText(T.memFormat(GetAddOnMemoryUsage(addon_name)))
			self.t = 0
		end
	end)
end

local loaded_instance = {}
local loaded_soundpack = {}

T.LoadData = function()
	for EJ_InstanceID, info in pairs(G.Encounter_Order) do
		if not loaded_instance[EJ_InstanceID] then
			-- 副本				
			local name, description, _, _, _, bgImage, _, _, _, _, isRaid = EJ_GetInstanceInfo(EJ_InstanceID)
			local InstanceType = (isRaid) and 2 or 3
			local instance_option_page = T.CreateCollectTab(InstanceType, EJ_InstanceID, name, bgImage)
			-- 首领
			for ind, ENCID in pairs(info) do
				local name = T.GetEncounterName(ENCID)
				local option_page = T.CreateOptionPage(InstanceType, EJ_InstanceID, "encounter"..ENCID, T.hex_str(ind, {1, .82, 0}).." "..name)
				T.CreateEncounterOptions(option_page.sfa, name, EJ_InstanceID, ENCID)
			end
			loaded_instance[EJ_InstanceID] = true
		end
	end
end

function eventframe:ADDON_LOADED(addon)
	if addon == G.addon_name then
		T.LoadAccountVariables()
		T.LoadVariables()
		T.ToggleMinimapButton()
		
		UpdateGUIScale()
		
		for _, func in next, G.Init_callbacks do
			func()
		end
		
		local info = C_VoiceChat.GetTtsVoices()
		for i, v in pairs(info) do
			table.insert(G.ttsSpeakers, {v.voiceID, v.name})
		end
	else
		-- 语音包
		local pack_name = C_AddOns.GetAddOnMetadata(addon, "X-JST-SoundPack-Name")
		local pack_file = C_AddOns.GetAddOnMetadata(addon, "X-JST-SoundPack-File")
		if pack_name and pack_file and not loaded_soundpack[addon] then
			table.insert(G.SoundPacks, {addon, pack_name, pack_file})
			loaded_soundpack[addon] = true
		end
	end
end

function eventframe:PLAYER_ENTERING_WORLD()
	T.LoadData()
	
	T.apply_sound_pack()
	T.ToggleNicknameCheck()
	T.UpdateAll()	
	
	print("|T"..G.media.logo..":18:18:0:0:64:64:0:64:0:64|t"..G.addon_cname.." "..G.Version)
	
	for _, func in next, G.EnteringWorld_callbacks do
		func()
	end
	
	eventframe:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

----------------------------------------------------------
--------------------[[     CMD     ]]---------------------
----------------------------------------------------------
SLASH_JST1 = "/jst"
SlashCmdList["JST"] = function(ARG)
	local arg = string.lower(ARG)
	if arg == "testhl1" then -- 测试团队框架高亮
		T.GlowRaidFramebyUnit_Show("pixel", "pixel_test", "player", {0, 1, 0}, 5)
	elseif arg == "testhl2" then -- 测试团队框架高亮
		T.GlowRaidFramebyUnit_Show("proc", "proc_test", "player", {0, 1, 1}, 5)	
	elseif arg == "testhl3" then -- 测试团队框架高亮
		T.GlowRaidFramebyUnit_Show("blz", nil, "player", {1, 0, 1, 1}, 5)
	elseif arg == "ds" then
		T.ShowDSFrame(3)
	elseif string.find(arg, "map") then -- 测试小地图		
		local frame = G.BossModFrames[425576]
		if G.Minimapdata.updated then
			frame:PreviewHide()
		else
			frame:PreviewShow()	
		end		
	elseif arg == "dispel" then -- 驱散我
		T.addon_msg("DispelMe,"..G.PlayerGUID, "GROUP")
	elseif string.find(arg, "add") then -- 增加我
		if arg == "add" then
			T.addon_msg("TargetMe,"..G.PlayerGUID, "GROUP")
		else
			local index = string.match(arg, "add(%d+)")
			T.addon_msg("TargetMe"..index..","..G.PlayerGUID, "GROUP")
		end
	elseif string.find(arg, "remove") then -- 移除我
		if arg == "remove" then
			T.addon_msg("RemoveMe,"..G.PlayerGUID, "GROUP")
		else
			local index = string.match(arg, "remove(%d+)")
			T.addon_msg("RemoveMe"..index..","..G.PlayerGUID, "GROUP")
		end
	elseif string.find(arg, "spell") then -- 法术请求
		local arg1, arg2 = string.split(" ", ARG)
		if not (arg1 and arg2) then
			T.msg(L["法术请求格式错误"])
			return
		end
		
		local target
		if arg1 == "%t" then
			local target_GUID = UnitGUID("target")
			if target_GUID then
				local info = T.GetGroupInfobyGUID(target_GUID)
				if info then
					target = Ambiguate(info.full_name, "none")
				else
					T.msg(string.format(L["法术请求目标不在队伍中"]))
					return
				end
			else
				T.msg(string.format(L["法术请求目标不在队伍中"]))
				return
			end
		else
			local info = T.GetGroupInfobyName(arg1)
			if info then
				target = Ambiguate(info.full_name, "none")
			else
				T.msg(string.format(L["法术请求玩家不在队伍中"], arg1))
				return
			end
		end

		local spellID_str = string.match(arg2, "spell(%d+)")
		if not spellID_str then
			T.msg(L["法术请求无法术"])
			return
		end
		
		local spellID = tonumber(spellID_str)
		if not T.GetSpellInfo(spellID) then
			T.msg(string.format(L["法术请求法术ID错误"], spellID))
			return
		end
		
		if target and spellID then
			local spell_name = T.GetIconLink(spellID)
			T.addon_msg("AskSpell,"..spellID..","..G.PlayerGUID, "WHISPER", target)
			T.msg(string.format(L["法术请求已发送"], target, spell_name))
		end
	else
		if GUI:IsShown() then
			GUI:Hide()
		else
			GUI:Show()
		end
	end
end

----------------------------------------------------------
----------------[[     Minimap Button     ]]--------------
----------------------------------------------------------
local MinimapButton = CreateFrame("Button", "JST_MinimapButton", Minimap)
MinimapButton:SetSize(32,32)
MinimapButton:SetFrameStrata("MEDIUM")
MinimapButton:SetFrameLevel(8)
MinimapButton:SetPoint("CENTER", 12, -105)
MinimapButton:SetDontSavePosition(true)
MinimapButton:RegisterForDrag("LeftButton")
	
MinimapButton.icon = MinimapButton:CreateTexture(nil, "BORDER")
MinimapButton.icon:SetTexture(G.media.logo)
MinimapButton.icon:SetSize(25, 25)
MinimapButton.icon:SetPoint("CENTER")

MinimapButton.icon2 = MinimapButton:CreateTexture(nil, "BORDER")
MinimapButton.icon2:SetTexture(G.media.logo)
MinimapButton.icon2:SetSize(25, 25)
MinimapButton.icon2:SetPoint("CENTER")
MinimapButton.icon2:Hide()

MinimapButton.bg = MinimapButton:CreateTexture(nil, "BACKGROUND")
MinimapButton.bg:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
MinimapButton.bg:SetVertexColor(0, 0, 0)
MinimapButton.bg:SetSize(20,20)
MinimapButton.bg:SetPoint("CENTER",0,0)

MinimapButton.anim = MinimapButton:CreateAnimationGroup()
MinimapButton.anim:SetLooping("BOUNCE")
MinimapButton.timer = MinimapButton.anim:CreateAnimation()
MinimapButton.timer:SetDuration(2)

MinimapButton:SetScript("OnEnter",function(self) 
	GameTooltip:SetOwner(self, "ANCHOR_LEFT") 
	GameTooltip:AddLine(G.addon_cname)
	GameTooltip:Show()
	
	self.timer:SetScript("OnUpdate", function(s,elapsed) 
		self.icon2:SetAlpha(s:GetProgress())
	end)
	self.anim:Play()
	self.icon:Hide()
	self.icon2:Show()
end)

MinimapButton:SetScript("OnLeave", function(self)    
	GameTooltip:Hide()
	
	self.timer:SetScript("OnUpdate", nil)
	self.anim:Stop()
	self.icon:Show()
	self.icon2:Hide()
end)

MinimapButton:SetScript("OnClick", function()
	if GUI:IsShown() then
		GUI:Hide()
	else
		GUI:Show()
	end
end)

local minimapShapes = {
	["ROUND"] = {true, true, true, true},
	["SQUARE"] = {false, false, false, false},
	["CORNER-TOPLEFT"] = {false, false, false, true},
	["CORNER-TOPRIGHT"] = {false, false, true, false},
	["CORNER-BOTTOMLEFT"] = {false, true, false, false},
	["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
	["SIDE-LEFT"] = {false, true, false, true},
	["SIDE-RIGHT"] = {true, false, true, false},
	["SIDE-TOP"] = {false, false, true, true},
	["SIDE-BOTTOM"] = {true, true, false, false},
	["TRICORNER-TOPLEFT"] = {false, true, true, true},
	["TRICORNER-TOPRIGHT"] = {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local function IconMoveButton(self)
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	px, py = px / scale, py / scale
	
	local angle = math.atan2(py - my, px - mx)
	local x, y, q = math.cos(angle), math.sin(angle), 1
	if x < 0 then q = q + 1 end
	if y > 0 then q = q + 2 end
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = minimapShapes[minimapShape]
	if quadTable[q] then
		x, y = x*105, y*105
	else
		local diagRadius = 103.13708498985 --math.sqrt(2*(80)^2)-10
		x = math.max(-105, math.min(x*diagRadius, 105))
		y = math.max(-105, math.min(y*diagRadius, 105))
	end
	self:ClearAllPoints()
	self:SetPoint("CENTER", Minimap, "CENTER", x, y)
	JST_CDB["GeneralOption"]["IconMiniMapLeft"] = x
	JST_CDB["GeneralOption"]["IconMiniMapTop"] = y
end

MinimapButton:SetScript("OnDragStart", function(self)
	self:LockHighlight()
	self:SetScript("OnUpdate", IconMoveButton)
	GameTooltip:Hide()
end)

MinimapButton:SetScript("OnDragStop", function(self)
	self:UnlockHighlight()
	self:SetScript("OnUpdate", nil)
end)

T.ToggleMinimapButton = function()
	if JST_CDB["GeneralOption"]["hide_minimap"] then
		MinimapButton:Hide()
	else
		MinimapButton:Show()
	end
	MinimapButton:SetPoint("CENTER", Minimap, "CENTER", JST_CDB["GeneralOption"]["IconMiniMapLeft"], JST_CDB["GeneralOption"]["IconMiniMapTop"])
end

AddonCompartmentFrame:RegisterAddon({
	text = C_AddOns.GetAddOnMetadata("JST", "Title"),
	icon = C_AddOns.GetAddOnMetadata("JST", "IconTexture"),
	registerForAnyClick = true,
	notCheckable = true,
	func = function(btn, arg1, arg2, checked, mouseButton)
		if GUI:IsShown() then
			GUI:Hide()
		else
			GUI:Show()
		end
	end,
})