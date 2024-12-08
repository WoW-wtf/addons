local T, C, L, G = unpack(select(2, ...))

local enable_tags = {
	everyone = { tag = L["所有人加载"],		tip = L["所有人加载tip"]},
	rl		 = { tag = L["RL加载"], 		tip = L["RL加载tip"]},
	spell 	 = { tag = L["技能分配加载"], 	tip = L["技能分配加载tip"]},
	role 	 = { tag = L["职责加载"], 		tip = L["职责加载tip"]},
}

local sound_suffix = {
	["SPELL_AURA_APPLIED"] = {"aura", L["获得光环音效"]},
	["SPELL_AURA_REMOVED"] = {"auralose", L["移除光环音效"]},
	["SPELL_AURA_APPLIED_DOSE"] = {"stack", L["层数增加音效"]},
	["SPELL_CAST_START"] = {"cast", L["开始施法音效"]},
	["SPELL_CAST_SUCCESS"] = {"succeed", L["施法成功音效"]},
	["SPELL_SUMMON"] = {"summon", L["召唤小怪音效"]},
	["SPELL_DAMAGE"] = {"dmg", L["伤害音效"]},
}
G.sound_suffix = sound_suffix

local PhaseTriggerEvents  = {
	["SPELL_AURA_APPLIED"] = L["获得光环"],
	["SPELL_AURA_REMOVED"] = L["移除光环"],
	["SPELL_AURA_APPLIED_DOSE"] = L["光环堆叠"],	
	["SPELL_CAST_START"] = L["开始施法"],
	["SPELL_CAST_SUCCESS"] = L["施法成功"],
}

--====================================================--
--[[                -- 通用按钮 --                  ]]--
--====================================================--
-- 声音预览按钮
local CreateSoundPreviewButton = function(button, sound, points)
	local sound_description = ""
	local file = string.match(sound, "%[(.+)%]")
	local cd = string.match(sound, "cd(%d+)")
	local stack = string.find(sound, "stack")
	local cap, stacksfx 
	
	if cd then
		sound_description = sound_description.." "..string.format(L["倒数"], cd)
	elseif stack then	
		local more = string.match(sound, "stackmore(%d+)")
		local less = string.match(sound, "stackless(%d+)")
		local stacksfx = string.find(sound, "stacksfx")
		if more then
			sound_description = sound_description.." "..string.format(L["层数大于"], more)
			cap = tonumber(more)
		elseif less then
			sound_description = sound_description.." "..string.format(L["层数小于"], less)
			cap = tonumber(less)
		elseif stacksfx then 
			sound_description = sound_description.." "..L["层数变化"]
		end
	end
	
	local bu = CreateFrame("Button", nil, button)	
	bu:SetSize(20, 20)
	bu:SetPoint(unpack(points))
	
	bu.text = T.createtext(bu, "OVERLAY", 14, "OUTLINE", "LEFT")
	bu.text:SetPoint("LEFT", bu, "RIGHT", 0, 0)
	bu.text:SetText(sound_description)
	
	bu:SetNormalTexture("chatframe-button-icon-voicechat")
	bu:GetNormalTexture():SetDesaturated(true)
	bu:GetNormalTexture():SetVertexColor(1, 1, 1)
	bu:SetHighlightTexture("chatframe-button-icon-voicechat")
	bu:GetHighlightTexture():SetDesaturated(true)
	bu:GetHighlightTexture():SetVertexColor(1, .82, 0)
	
	bu:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
		GameTooltip:AddLine(PREVIEW)
		GameTooltip:Show()
	end)
	
	bu:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	bu:SetScript("OnClick", function(self)
		if file then
			T.PlaySound(file)
			if cd then
				C_Timer.After(1.5, function()
					T.CountDown(tonumber(cd))
				end)
			elseif stack then
				if cap then
					C_Timer.After(1.5, function()
						if cap <= 10 then
							T.PlaySound("count\\"..cap)
						else
							T.SpeakText(tostring(cap))
						end
					end)
				elseif stacksfx then
					C_Timer.After(1.5, function()
						T.PlaySound(stacksfx)
					end)
				end
			end
		elseif cd then
			T.CountDown(tonumber(cd))
		elseif stack then
			if cap then
				if cap <= 10 then
					T.PlaySound("count\\"..cap)
				else
					T.SpeakText(tostring(cap))
				end
			elseif stacksfx then
				T.PlaySound(stacksfx)
			end
		end
	end)
end

-- 隐藏滑动条
local function HideScorllBar(scrollframe)
	local scrollBar = scrollframe.ScrollBar
	scrollBar:SetAlpha(0)
	scrollBar:EnableMouse(false)
	
	scrollBar.ScrollDownButton:SetAlpha(0)
	scrollBar.ScrollDownButton:EnableMouse(false)
	
	scrollBar.ScrollUpButton:SetAlpha(0)
	scrollBar.ScrollUpButton:EnableMouse(false)
	
	scrollBar.ThumbTexture:SetAlpha(0)
	scrollBar.ThumbTexture:EnableMouse(false)
end
--====================================================--
--[[                -- 依赖关系 --                  ]]--
--====================================================--
-- 启用依赖关系
local createDR = function(parent, ...)
	for i=1, select("#", ...) do
		local object = select(i, ...)
		parent:HookScript("OnShow", function(self)
			if self:GetChecked() and self:IsEnabled() then
				if object.Enable then
					object:Enable()
				end
			else
				if object.Disable then
					object:Disable()
				end
			end
		end)
		parent:HookScript("OnClick", function(self)
			if self:GetChecked() and self:IsEnabled() then
				if object.Enable then
					object:Enable()
				end
			else
				if object.Disable then
					object:Disable()
				end
			end
		end)		
		parent:HookScript("OnEnable", function(self)
			if self:GetChecked() and self:IsEnabled() then
				if object.Enable then
					object:Enable()
				end
			else
				if object.Disable then
					object:Disable()
				end
			end
		end)
		parent:HookScript("OnDisable", function()
			if object.Disable then
				object:Disable()
			end
		end)
	end
end

-- 显示依赖关系
local createVisibleDR = function(func, parent, ...)
	for i=1, select("#", ...) do
		local object = select(i, ...)
		parent:HookScript("OnShow", function(self)
			if func() then
				object:Show()
			else
				object:Hide()
			end
		end)
		if parent:HasScript("OnClick") then
			parent:HookScript("OnClick", function(self)
				if func() then
					object:Show()
				else
					object:Hide()
				end
			end)
		else
			local oldfunc = parent.visible_apply
			parent.visible_apply = function()
				if oldfunc then
					oldfunc()
				end
				if func() then
					object:Show()
				else
					object:Hide()
				end
			end
		end
	end
end

--====================================================--
--[[              -- GUI 选项排列 --                ]]--
--====================================================--
local SetGUIPoint = function(parent, width_perc, obj, before_gap, after_gap, x, y)
	local width = parent:GetWidth()
	local line_height = 30
	
	parent.option_x = parent.option_x or 0
	parent.option_y = parent.option_y or 0
	
	if before_gap then -- 与上一项之间的行间距
		parent.option_y = parent.option_y + before_gap
	end
	
	if obj.istitle then
		local line = parent:CreateTexture(nil, "BACKGROUND")
		line:SetTexture(G.media.blank)
		line:SetGradient("HORIZONTAL", CreateColor(1, .82, 0, .8), CreateColor(0, 0, 0, 0))
		line:SetSize(parent:GetWidth(), 1)
		line:SetPoint("TOPLEFT", obj, "BOTTOMLEFT", -40, -5)
		
		local bgtex = parent:CreateTexture(nil, "BACKGROUND")
		bgtex:SetTexture(G.media.blank)
		bgtex:SetColorTexture(0, 0, 0, .5)
		bgtex:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, 0)
		
		parent.bgtex = bgtex
	end
	
	local obj_type = obj:GetObjectType()
	local x_off, y_off = 0, 0
	
	if obj_type == "Slider" then
		x_off = 160
		y_off = 8
	elseif obj.dd then
		y_off = -8
	end
	
	if parent.option_x + width_perc*width > width then -- 需要换行
		obj:SetPoint("TOPLEFT", parent, "TOPLEFT", 10 + x_off + (x or 0), - parent.option_y - line_height + y_off + (y or 0))
		
		-- 下一项的锚点
		parent.option_x = width_perc*width
		parent.option_y = parent.option_y + math.ceil(width_perc)*line_height
		
		if not obj.istitle and parent.bgtex then
			parent.bgtex:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, - parent.option_y - line_height - 10)
		end
				
		if after_gap then -- 与下一项之间的行间距
			parent.option_y = parent.option_y + after_gap
		end
	else
		obj:SetPoint("TOPLEFT", parent, "TOPLEFT", 10 + x_off + (x or 0) + parent.option_x, - parent.option_y + y_off + (y or 0))
		
		-- 下一项的锚点
		parent.option_x = parent.option_x + width_perc*width
	end
end

local iconnum_per_line = 10
local SetIconButtonPoint = function(parent, category, bu)
	local x = 10 + mod(parent[category.."IconNum"], iconnum_per_line)*75
	local y = - parent[category.."option_y"]
	
	bu:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)		
	
	parent[category.."IconNum"] = parent[category.."IconNum"] + 1
end

--====================================================--
--[[             -- 标题/描述/分割线 --             ]]--
--====================================================--
local function CreateGUITitle(parent, text)
	local fs = T.createtext(parent, "OVERLAY", 14, "OUTLINE", "LEFT")
	fs:SetText(text or " ")	
	fs:SetTextColor(1, .82, 0)
	fs.istitle = true
	return fs
end

local function CreateGUIDesciption(parent, text)
	local fs = T.createtext(parent, "OVERLAY", 14, "OUTLINE", "LEFT")
	fs:SetWidth(parent:GetWidth()-40)
	fs:SetText(text or " ")
	return fs
end

--====================================================--
--[[                -- 普通按钮 --                ]]--
--====================================================--
local ClickButton = function(parent, width, points, text, tip)
	local bu = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	
	if points then
		bu:SetPoint(unpack(points))
	end
	
	bu.Text:SetFont(G.Font, 14, "OUTLINE")
	bu:SetText(text or "")
	
	if width == 0 then
		bu:SetSize(bu.Text:GetWidth() + 5, 25)
	else
		bu:SetSize(width, 25)
	end

	if tip then
		bu:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT",  -20, 10)
			GameTooltip:AddLine(tip)
			GameTooltip:Show() 
		end)
		bu:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	
	return bu
end
T.ClickButton = ClickButton

local ClickButton_DB = function(parent, path)
	local info = T.GetOptionInfo(path)
	local frame = ClickButton(parent, 150, nil, info.text, info.tip)
		
	frame:SetScript("OnClick", function(self)
		if info.apply then info.apply() end
	end)
	
	return frame
end

local CreateAddtionalMarkDropdownforMrtCopy = function(parent)
	local option_table = {
		{"", L["忽略标记"]},
	}
	for i = 1, 8 do
		table.insert(option_table, {"{rt"..i.."}", T.FormatRaidMark(i)})
	end
	
	local frame = T.UIDropDownMenuFrame(parent, "", {"LEFT", parent, "RIGHT", -5, 0})
	frame.dd:SetPoint("LEFT", frame, "LEFT", -5, -2)
	UIDropDownMenu_SetWidth(frame.dd, 90)
	
	local function DD_UpdateChecked(self, arg1)
		return (UIDropDownMenu_GetSelectedValue(frame.dd) == arg1)
	end
	
	local function DD_SetChecked(self, arg1, arg2)
		T.UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, arg1)
	end
	
	UIDropDownMenu_Initialize(frame.dd, function(self, level)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, #option_table do
			dd_info.value = option_table[i][1]
			dd_info.arg1 = option_table[i][1]
			dd_info.text = option_table[i][2]
			dd_info.checked = DD_UpdateChecked
			dd_info.func = DD_SetChecked
			UIDropDownMenu_AddButton(dd_info)
		end
	end)

	T.UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, "")
	
	parent.rt_dd = frame.dd
end

local CreateAddtionalNumDropdownforMrtCopy = function(parent)
	local option_table = {}
	for i = 2, 5 do
		table.insert(option_table, {i, string.format(L["MRT循环次数%d"], i)})
	end
	
	local frame = T.UIDropDownMenuFrame(parent, "", {"LEFT", parent.rt_dd, "RIGHT", -5, 0})
	frame.dd:SetPoint("LEFT", frame, "LEFT", -20, 0)
	UIDropDownMenu_SetWidth(frame.dd, 90)
	
	local function DD_UpdateChecked(self, arg1)
		return (UIDropDownMenu_GetSelectedValue(frame.dd) == arg1)
	end
	
	local function DD_SetChecked(self, arg1, arg2)
		T.UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, arg1)
	end
	
	UIDropDownMenu_Initialize(frame.dd, function(self, level)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, #option_table do
			dd_info.value = option_table[i][1]
			dd_info.arg1 = option_table[i][1]
			dd_info.text = option_table[i][2]
			dd_info.checked = DD_UpdateChecked
			dd_info.func = DD_SetChecked
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	T.UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, 3)

	parent.num_dd = frame.dd
end

local ClickButton_Detail_DB = function(info, key_path, button, alert)
	local detailFrame = G.detailFrame
	local frame = ClickButton(detailFrame, 150, nil, info.text)
	
	if info.key == "copy_interrupt_btn" then
		CreateAddtionalMarkDropdownforMrtCopy(frame)
		CreateAddtionalNumDropdownforMrtCopy(frame)
		
		info.onclick = function()
			local rt = UIDropDownMenu_GetSelectedValue(frame.rt_dd)
			local num = UIDropDownMenu_GetSelectedValue(frame.num_dd)
			local str = T.GetInterruptStr(info.mobID, info.spellID, rt, num)
			T.DisplayCopyString(frame, str)
		end
	end
	
	frame:SetScript("OnClick", function(self)
		if info.onclick then 
			info.onclick(alert, button, self)
		end
	end)
	
	table.insert(detailFrame.options, frame)
	
	return frame
end

--====================================================--
--[[                 -- 勾选按钮 --                 ]]--
--====================================================--
local Checkbutton = function(parent, text)
	local bu = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	bu:SetHitRectInsets(0, -50, 0, 0)
	
	bu.Text:SetFont(G.Font, 14, "OUTLINE")
	bu.Text:SetText(text)
	bu.Text:SetTextColor(1, 1, 1)
	bu.Text:SetJustifyH("LEFT")
	
	bu:SetScript("OnDisable", function(self)
		bu.Text:SetTextColor(.5, .5, .5)
	end)
	
	bu:SetScript("OnEnable", function(self)
		bu.Text:SetTextColor(1, 1, 1)
	end)
	
	return bu
end

local Checkbutton_DB = function(parent, path)
	local info = T.GetOptionInfo(path)
	local bu = Checkbutton(parent, info.text)	
	
	bu:SetScript("OnShow", function(self)
		self:SetChecked(T.ValueFromPath(JST_CDB, path))
	end)
	
	bu:SetScript("OnClick", function(self)
		local value = self:GetChecked()
		if ( value ) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		end
		T.ValueToPath(JST_CDB, path, value)
		if info.apply then info.apply() end
	end)

	return bu
end

local Checkbutton_Detail_DB = function(info, key_path, button, alert)
	local detailFrame = G.detailFrame
	local bu = Checkbutton(detailFrame, info.text)
	
	bu:SetScript("OnShow", function(self)
		self:SetChecked(T.ValueFromPath(JST_CDB, key_path))
	end)
	
	bu:SetScript("OnClick", function(self)
		local value = self:GetChecked()
		if ( value ) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		end
		T.ValueToPath(JST_CDB, key_path, value)
		if info.apply then
			info.apply(value, alert, button)
		end		
	end)
	
	table.insert(detailFrame.options, bu)
	
	if info.sound then
		CreateSoundPreviewButton(bu, info.sound, {"LEFT", bu.Text, "RIGHT", 10, 0})
	end
	
	return bu
end

local CreateTagFrame = function(bu, enable_tag, ficon)
	local str, tip = ""
	
	if enable_tag then
		str = str..enable_tags[enable_tag].tag
		tip = enable_tags[enable_tag].tip
	end
	
	if ficon then
		str = str..T.GetFlagIconStr(ficon, false)
	end
	
	local frame = CreateFrame("Frame", nil, bu)
	frame:SetPoint("RIGHT", bu, "LEFT", 0, 0)	
	frame:SetSize(80,30)
	
	frame.text = T.createtext(bu, "OVERLAY", 14, "OUTLINE", "RIGHT")
	frame.text:SetPoint("RIGHT", frame, "RIGHT", 0, 0)	
	frame.text:SetText(str)
	
	if enable_tag then
		frame:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT",  -20, 10)
			GameTooltip:AddLine(tip)
			GameTooltip:Show() 
		end)
		frame:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
end

local Checkbutton_Encounter_DB = function(parent, path, text, enable_tag, ficon)
	local bu = Checkbutton(parent, text)
	bu.Text:SetWidth(600)
	
	CreateTagFrame(bu, enable_tag, ficon)	
	SetGUIPoint(parent, 1, bu, nil, nil, 80)
		
	bu:SetScript("OnShow", function(self)
		self:SetChecked(T.ValueFromPath(JST_CDB, path))
	end)
	
	bu:SetScript("OnClick", function(self)
		local value = self:GetChecked()
		if ( value ) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		end
		T.ValueToPath(JST_CDB, path, value)
		if self.apply then self.apply() end
	end)
	
	return bu
end

--====================================================--
--[[                 -- 输入框 --                   ]]--
--====================================================--
local EditboxWithButton = function(parent, width, points, tip)	
	local box = CreateFrame("EditBox", nil, parent)
	if points then
		box:SetPoint(unpack(points))
	end
	
	box:SetSize(width or 200, 20)	
	T.createborder(box)

	box:SetFont(G.Font, 14, "OUTLINE")
	box:SetAutoFocus(false)
	box:SetTextInsets(3, 0, 0, 0)

	box.button = ClickButton(box, 0, {"RIGHT", box, "RIGHT", -2, 0}, OKAY)
	box.button:Hide()
	box.button:SetScript("OnClick", function()
		if box:GetScript("OnEnterPressed") then
			box:GetScript("OnEnterPressed")(box)
		end
	end)
	
	box:SetScript("OnChar", function(self)
		self.button:Show()
		self.sd:SetBackdropBorderColor(1, 1, 0)
	end)
	
	box:SetScript("OnEditFocusGained", function(self)
		self.sd:SetBackdropBorderColor(1, 1, 1)
	end)
	
	box:SetScript("OnEditFocusLost", function(self)
		self.sd:SetBackdropBorderColor(0, 0, 0)
	end)
	
	box:SetScript("OnHide", function(self) 
		self.button:Hide()
	end)

	if tip then
		box:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, 10)
			GameTooltip:AddLine(tip)
			GameTooltip:Show() 
		end)
		box:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	
	box:SetScript("OnEnable", function(self)
		self:SetTextColor(1, 1, 1, 1)
	end)
	
	box:SetScript("OnDisable", function(self)
		self:SetTextColor(0.7, 0.7, 0.7, 0.5)
	end)

	return box
end

-- 带标题的输入框组合
local EditFrame = function(parent, width, text, points, tip)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(20, 20)
	if points then
		frame:SetPoint(unpack(points))
	end
	
	local name = T.createtext(frame, "OVERLAY", 14, "OUTLINE", "LEFT")
	name:SetPoint("LEFT", frame, "LEFT", 0, 0)
	name:SetText(text or "")	
	frame.name = name
	
	local box = EditboxWithButton(frame, width, {"LEFT", frame, "LEFT", 100, 0}, tip)
	frame.box = box
	
	return frame
end
T.EditFrame = EditFrame

--====================================================--
--[[                 -- 滑动条 --                   ]]--
--====================================================--
local SliderWithValueText = function(parent, name, points, min, max, step, tip, button)
	local slider = CreateFrame("Slider", name and (G.addon_name..name.."MiniSlider"), parent, "MinimalSliderTemplate")
	slider:SetSize(120, 12)
	if points then
		slider:SetPoint(unpack(points))
	end
	
	slider.Text = T.createtext(slider, "OVERLAY", 10, "OUTLINE")
	slider.Text:SetPoint("LEFT", slider, "RIGHT", -5, 0)

	slider:SetMinMaxValues(min, max)
	slider:SetValueStep(step)
	slider:SetObeyStepOnDrag(true)
	
	if button then
		slider.button = ClickButton(slider, 50, {"LEFT", slider, "RIGHT", 30, 0}, APPLY)
		slider.button:Hide()
		
		slider:SetScript("OnHide", function(self)
			self.button:Hide()
		end)
	end
	
	slider.Enable = function()		
		slider:SetEnabled(true)
		slider.Text:SetTextColor(1, 1, 1, 1)
		slider.Thumb:Show()
	end
	
	slider.Disable = function()
		slider:SetEnabled(false)
		slider.Text:SetTextColor(0.7, 0.7, 0.7, 0.5)
		slider.Thumb:Hide()
		if slider.button then
			slider.button:Hide()
		end
	end
	
	if tip then
		slider:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, 10)
			GameTooltip:AddLine(tip)
			GameTooltip:Show() 
		end)
		slider:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	
	return slider
end
T.SliderWithValueText = SliderWithValueText

local SliderWithSteppers = function(parent, text, points, min, max, step, tip, button)
	local frame = CreateFrame("Slider", nil, parent, "MinimalSliderWithSteppersTemplate")
	frame:SetWidth(180)
	if points then
		frame:SetPoint(unpack(points))
	end
	
	frame.LeftText:SetFont(G.Font, 14, "OUTLINE")
	frame.LeftText:ClearAllPoints()
	frame.LeftText:SetPoint("LEFT", frame.Slider, "LEFT", -175, 0)
	frame.LeftText:SetJustifyH("LEFT")
	frame.LeftText:SetText(text)
	frame.LeftText:SetTextColor(1, 1, 1, 1)
	frame.LeftText:Show()
	
	frame.RightText:SetFont(G.Font, 14, "OUTLINE")
	frame.RightText:ClearAllPoints()
	frame.RightText:SetPoint("LEFT", frame.Slider, "RIGHT", 15, 0)
	frame.RightText:SetTextColor(1, 1, 1, 1)
	frame.RightText:Show()

	frame.Slider:SetMinMaxValues(min, max)
	frame.Slider:SetValueStep(step)
	frame.Slider:SetObeyStepOnDrag(true)
	
	frame.Enable = function()
		frame.Slider:SetEnabled(true)
		frame.Slider.Thumb:Show()
		frame.Back:Enable()
		frame.Forward:Enable()
		frame.LeftText:SetTextColor(1, 1, 1, 1)
		frame.RightText:SetTextColor(1, 1, 1, 1)
	end
	
	frame.Disable = function()
		frame.Slider:SetEnabled(false)
		frame.Slider.Thumb:Hide()
		frame.Back:Disable()
		frame.Forward:Disable()
		frame.LeftText:SetTextColor(0.7, 0.7, 0.7, 0.5)
		frame.RightText:SetTextColor(0.7, 0.7, 0.7, 0.5)
		if button then
			frame.button:Hide()
		end
	end
	
	if tip then
		frame:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, 10)
			GameTooltip:AddLine(tip)
			GameTooltip:Show() 
		end)
		frame:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	
	if button then
		frame.button = ClickButton(frame, 50, {"LEFT", frame, "RIGHT", 30, 0}, APPLY)
		frame:SetScript("OnHide", function(self)
			self.button:Hide()
		end)
	end
	
	return frame
end

local Slider_DB = function(parent, path)
	local info = T.GetOptionInfo(path)
	local multipler = (info.min < 1 and info.min > 0 and 100) or 1

	local frame = SliderWithSteppers(parent, info.text, nil, info.min*multipler, info.max*multipler, info.step*multipler, info.tip)
	
	frame.Slider:SetScript("OnShow", function(self)
		local value = T.ValueFromPath(JST_CDB, path)
		self:SetValue(value*multipler)
		frame.RightText:SetText(floor(value*multipler)..((multipler == 100 and "%") or ""))
	end)
	
	frame.Slider:SetScript("OnValueChanged", function(self, getvalue)
		if getvalue ~= self.old_value then
			T.ValueToPath(JST_CDB, path, getvalue/multipler)
			frame.RightText:SetText(getvalue..((multipler == 100 and "%") or ""))
			if info.apply then
				info.apply()
			end
			self.old_value = getvalue
		end
	end)
	
	return frame
end

local Slider_Detail_DB = function(info, key_path, button, alert)
	local detailFrame = G.detailFrame
	local frame = SliderWithSteppers(detailFrame, info.text, nil, info.min, info.max, 1)
	
	frame.Slider:SetScript("OnShow", function(self)
		local value = T.ValueFromPath(JST_CDB, key_path)
		self:SetValue(value)
		if info.div then
			frame.RightText:SetText(value/info.div)
		else
			frame.RightText:SetText(value)
		end
	end)
	
	frame.Slider:SetScript("OnValueChanged", function(self, getvalue, userInput)
		if getvalue ~= self.old_value then
			T.ValueToPath(JST_CDB, key_path, getvalue)
			if info.div then
				frame.RightText:SetText(getvalue/info.div)
			else
				frame.RightText:SetText(getvalue)
			end
			if info.apply then
				info.apply(getvalue, alert, button)
			end
			self.old_value = getvalue
		end
	end)
	
	table.insert(detailFrame.options, frame)
	
	return frame
end

--====================================================--
--[[                 -- 下拉菜单 --                 ]]--
--====================================================--
local UIDropDownMenu_SetSelectedValueText = function(dd, t, value)
	UIDropDownMenu_SetSelectedValue(dd, value)
	for i, info in pairs(t) do
		if info[1] == value then
			UIDropDownMenu_SetText(dd, info[2])
			break
		end
	end
end
T.UIDropDownMenu_SetSelectedValueText = UIDropDownMenu_SetSelectedValueText

local UIDropDownMenuFrame = function(parent, text, points)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(20, 20)
	
	if points then
		frame:SetPoint(unpack(points))
	end
	
	local name = T.createtext(frame, "OVERLAY", 14, "OUTLINE", "LEFT")
	name:SetPoint("LEFT", frame, "LEFT", 0, 0)
	name:SetTextColor(1, 1, 1)
	name:SetText(text or "")
	frame.name = name
	
	local dd = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate")
	dd:SetPoint("LEFT", frame, "LEFT", 155, 0)
	UIDropDownMenu_SetWidth(dd, 160)
	
	dd.Text:SetFont(G.Font, 14, "OUTLINE")
	dd.Text:SetPoint("RIGHT", dd.Right, "RIGHT", -40, 0)	
	
	frame.dd = dd

	frame.Enable = function()
		frame.name:SetTextColor(1, 1, 1)
		UIDropDownMenu_EnableDropDown(frame.dd)
	end
	
	frame.Disable = function()
		frame.name:SetTextColor(.5, .5, .5)
		UIDropDownMenu_DisableDropDown(frame.dd)
	end
	
	return frame
end
T.UIDropDownMenuFrame = UIDropDownMenuFrame

local UIDropDownMenuFrame_DB = function(parent, path)
	local info = T.GetOptionInfo(path)
	local option_table = info.option_table
	local frame = UIDropDownMenuFrame(parent, info.text)
	
	local function DD_UpdateChecked(self, arg1)
		return (T.ValueFromPath(JST_CDB, path) == arg1)
	end
	
	local function DD_SetChecked(self, arg1, arg2)
		T.ValueToPath(JST_CDB, path, arg1)
		UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, arg1)
		if info.apply then info.apply() end
		if frame.visible_apply then frame.visible_apply() end
	end
	
	UIDropDownMenu_Initialize(frame.dd, function(self, level)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, #option_table do
			dd_info.value = option_table[i][1]
			dd_info.arg1 = option_table[i][1]
			dd_info.text = option_table[i][2]
			dd_info.checked = DD_UpdateChecked
			dd_info.func = DD_SetChecked
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	frame:SetScript("OnShow", function()
		UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, T.ValueFromPath(JST_CDB, path))
	end)
	
	return frame
end

local UIDropDownMenuFrame_Detail_DB = function(info, key_path, button, alert)
	local detailFrame = G.detailFrame
	local option_table = info.key_table
	local frame = UIDropDownMenuFrame(detailFrame, info.text)
	
	local function DD_UpdateChecked(self, arg1)
		return (T.ValueFromPath(JST_CDB, key_path) == arg1)
	end
	
	local function DD_SetChecked(self, arg1, arg2)
		T.ValueToPath(JST_CDB, key_path, arg1)
		UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, arg1)
		if info.apply then
			info.apply(arg1, alert, button)
		end
	end
	
	UIDropDownMenu_Initialize(frame.dd, function(self, level)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, #option_table do
			dd_info.value = option_table[i][1]
			dd_info.arg1 = option_table[i][1]
			dd_info.text = option_table[i][2]
			dd_info.checked = DD_UpdateChecked
			dd_info.func = DD_SetChecked
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	frame:SetScript("OnShow", function()
		UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, T.ValueFromPath(JST_CDB, key_path))		
	end)
	
	table.insert(detailFrame.options, frame)
	
	return frame
end

--====================================================--
--[[                  -- 设置页面 --                ]]--
--====================================================--
local GUITabs = {}

local CreateTabBase = function(index, title)
	local parent = GUITabs[index]
	
	local tab = CreateFrame("Button", nil, parent.sfa, "SelectableButtonTemplate")
	tab:SetSize(140, 30)
	
	tab.bg = tab:CreateTexture(nil, "BORDER")
	tab.bg:SetAllPoints()
	tab.bg:SetAtlas("ShipMission_FollowerListButton")
	tab.bg:SetAlpha(.8)
	
	tab.text = T.createtext(tab, "OVERLAY", 14, "OUTLINE", "LEFT")
	tab.text:SetText(title)
	tab.text:SetJustifyH("LEFT")
	tab.text:SetPoint("LEFT", tab, "LEFT", 5, 0)
	tab.text:SetSize(140, 14)
	
	return tab
end

-- 选项标签
local CreateFrameTab = function(index, collect_id, title)
	local parent = GUITabs[index]
	
	local tab = CreateTabBase(index, title)
	
	tab.selected_tex = tab:CreateTexture(nil, "OVERLAY")
	tab.selected_tex:SetAllPoints()
	tab.selected_tex:SetAtlas("ShipMission_FollowerListButton-Highlight") 
	tab.selected_tex:SetDesaturated(true)
	tab.selected_tex:SetVertexColor(1, .82, 0)
	tab.selected_tex:SetBlendMode("ADD")
	
	function tab:SetSelected(Selected)
		if Selected then
			self.text:SetTextColor(1, .82, 0)
			self.selected_tex:Show()
			self.bg:SetAlpha(.2)
			self.setting_page:Show()
			self.selected = true
			
			parent.selected_tab = self
		else
			self.text:SetTextColor(1, 1, 1)
			self.selected_tex:Hide()
			self.bg:SetAlpha(.8)
			self.setting_page:Hide()
			self.selected = false
		end
	end
	
	function tab:IsSelected()
		return self.selected
	end
	
	tab:SetScript("OnClick", function(self, button, down, slience)
		if not self:IsSelected() then
			for i, t in pairs(parent.tabs) do
				if t.children_tabs then
					for i, t in pairs(t.children_tabs) do
						t:SetSelected(false)
					end
				else
					t:SetSelected(false)
				end
			end
			self:SetSelected(true)
			if not slience then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			end
		end
	end)
	
	if collect_id then
		local collect_tab = parent.collect_tabs[collect_id]
		if collect_tab then
			table.insert(collect_tab.children_tabs, tab)
		end
	else
		table.insert(parent.tabs, tab)
	end
	
	return tab
end

-- 标题标签
local CreateCollectTab = function(index, collect_id, title, texture)	
	local parent = GUITabs[index]
	
	local tab = CreateTabBase(index, title)
	tab.text:SetWidth(130)
		
	local img_tex = tab:CreateTexture(nil, "BACKGROUND")
	img_tex:SetPoint("TOPLEFT", 1, -1)
	img_tex:SetPoint("BOTTOMRIGHT", -1, 1)
	img_tex:SetTexture(texture)
	img_tex:SetTexCoord(0, 1, .4, .6)

	tab.collapsetex = tab:CreateTexture(nil, "OVERLAY")
	tab.collapsetex:SetSize(20, 20)
	tab.collapsetex:SetPoint("RIGHT", tab, "RIGHT", -2, 0)
	tab.collapsetex:SetDesaturated(true)
	
	function tab:Collepse()
		self.collapsetex:SetAtlas("Soulbinds_Collection_CategoryHeader_Expand")
		self.text:SetTextColor(1, 1, 1)
		self.collapse = true
	end
	
	function tab:Expand()
		self.collapsetex:SetAtlas("Soulbinds_Collection_CategoryHeader_Collapse")
		self.text:SetTextColor(1, .82, 0)
		self.collapse = false
	end
	
	function tab:IsCollapse()
		return self.collapse
	end
	
	tab:Collepse()
	tab.children_tabs = {}
	
	tab:SetScript("OnClick", function(self, button, down, slience)
		if self:IsCollapse() then
			self:Expand()
		else
			self:Collepse()
		end
		parent:LineUpTabs()
		if not slience then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end)
	
	parent.collect_tabs[collect_id] = tab
	
	table.insert(parent.tabs, tab)
end
T.CreateCollectTab = CreateCollectTab

-- GUI标签
local function CreateGUITab(index, text)
	local tab = CreateFrame("Button", nil, G.GUI_TabFrame, "SelectableButtonTemplate")
	tab:SetSize(100, 25)
	
	tab.Middle = tab:CreateTexture(nil, "BORDER")
	tab.Middle:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	tab.Middle:SetSize(70, 30)
	tab.Middle:SetPoint("BOTTOM", tab, "BOTTOM", 0, 2)
	tab.Middle:SetTexCoord(0.15625, 0.84375, 0, 1.0)
	
	tab.Left = tab:CreateTexture(nil, "BORDER")
	tab.Left:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	tab.Left:SetSize(20, 30)
	tab.Left:SetPoint("RIGHT", tab.Middle, "LEFT")
	tab.Left:SetTexCoord(0, 0.15625, 0, 1.0)

	tab.Right = tab:CreateTexture(nil, "BORDER")
	tab.Right:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	tab.Right:SetSize(20, 30)
	tab.Right:SetPoint("LEFT", tab.Middle, "RIGHT")
	tab.Right:SetTexCoord(0.84375, 1.0, 0, 1.0)
		
	tab.text = T.createtext(tab, "OVERLAY", 14, "OUTLINE", "CENTER")
	tab.text:SetPoint("CENTER")
	tab.text:SetText(text)
	
	tab.tabs = {}
	tab.collect_tabs = {}
	
	if index == 1 then
		tab:SetPoint("BOTTOMLEFT", G.GUI_TabFrame, "TOPLEFT", 10, 0)
	else
		tab:SetPoint("LEFT", GUITabs[index-1], "RIGHT", 0, 0)
	end
	
	function tab:LineUpTabs()
		local lastbutton
	
		for i, t in pairs(self.tabs) do
			if not lastbutton then
				t:SetPoint("TOP", self.sfa, "TOP", 0, -5)
			else
				t:SetPoint("TOP", lastbutton, "BOTTOM", 0, -5)
			end
			t:Show()
			lastbutton = t
			
			if t.children_tabs then
				if t:IsCollapse() then
					for i, sub_tab in pairs(t.children_tabs) do	
						sub_tab:Hide()
					end
				else
					for i, sub_tab in pairs(t.children_tabs) do
						sub_tab:SetPoint("TOP", lastbutton, "BOTTOM", 0, -5)
						sub_tab:Show()
						lastbutton = sub_tab
					end
				end		
			end
		end
	end
	
	tab:SetScript("PreClick", function()
		for _, t in pairs(GUITabs) do
			t:SetSelected(false)
			t.text:SetTextColor(1, 1, 1)
			t.sf:Hide()
			t.page:Hide()
		end
	end)
	
	tab:SetScript("OnClick", function(self, button, down, slience)
		if not self.selected_tab then
			if self.tabs[1] then
				self.tabs[1]:GetScript("OnClick")(self.tabs[1], "LeftButton", false, true)
				if self.tabs[1]["children_tabs"] then
					self.tabs[1]["children_tabs"][1]:GetScript("OnClick")(self.tabs[1]["children_tabs"][1], "LeftButton", false, true)
				end
			end
		end
		if not slience then
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		end
		self:SetSelected(true)
		self.text:SetTextColor(1, .82, 0)
		self.sf:Show()
		self.page:Show()
		self:LineUpTabs()
	end)
	
	tab.sf = CreateFrame("ScrollFrame", G.addon_name.."tab"..index.."ScrollFrame", tab, "UIPanelScrollFrameTemplate")
	tab.sf:SetAllPoints(G.GUI_TabFrame)
	HideScorllBar(tab.sf)
	
	tab.sfa = CreateFrame("Frame", G.addon_name.."tab"..index.."ScrollAnchor", tab.sf)
	tab.sfa:SetPoint("TOPLEFT", tab.sf, "TOPLEFT", 0, 0)
	tab.sfa:SetWidth(tab.sf:GetWidth())
	tab.sfa:SetHeight(tab.sf:GetHeight())

	tab.sf:SetScrollChild(tab.sfa)

	tab.page = CreateFrame("Frame", nil, tab)
	tab.page:SetAllPoints(G.GUI_PageFrame)
	
	G.GUI:HookScript("OnShow", function()
		local selected
		for _, tab in pairs(GUITabs) do
			if tab:IsSelected() then
				selected = true
				return
			end
		end
		if not selected then
			GUITabs[1]:GetScript("OnClick")(GUITabs[1], "LeftButton", false, true)
		end
	end)
	
	GUITabs[index] = tab
end
T.CreateGUITab = CreateGUITab

-- 选项页面
local function CreateOptionPage(tab_type, collect_id, name, title)
	local frame = CreateFrame("Frame", G.addon_name..name.."OptionPage", GUITabs[tab_type].page)
	frame:SetAllPoints()
	
	local tab = CreateFrameTab(tab_type, collect_id, title)
	tab.setting_page = frame
	tab:SetSelected(false)
	
	frame.sf = CreateFrame("ScrollFrame", G.addon_name..name.."ScrollFrame", frame, "UIPanelScrollFrameTemplate")
	frame.sf:SetAllPoints()
	frame.sf:SetFrameLevel(frame:GetFrameLevel()+1)
	HideScorllBar(frame.sf)
	
	frame.sfa = CreateFrame("Frame", G.addon_name..name.."ScrollAnchor", frame.sf)
	frame.sfa:SetPoint("TOPLEFT", frame.sf, "TOPLEFT", 0, 0)
	frame.sfa:SetWidth(frame.sf:GetWidth())
	frame.sfa:SetHeight(frame.sf:GetHeight())
	frame.sfa:SetFrameLevel(frame.sf:GetFrameLevel()+1)
	
	frame.sf:SetScrollChild(frame.sfa)

	return frame
end
T.CreateOptionPage = CreateOptionPage

--====================================================--
--[[                -- 细节选项 --                  ]]--
--====================================================--
-- 刷新细节选项
local UpdateDetailFrame = function(button, path, text, detail_options, alert)
	local detailFrame = G.detailFrame
	
	if not button.detail_options then
		button.detail_options = {}
	end
	
	for i, info in pairs(detail_options) do
		local key_path = T.CopyTableInsertElement(path, info.key)
		if not button.detail_options[info.key] then
			local obj
			if string.find(info.key, "_sl") then	
				obj = Slider_Detail_DB(info, key_path, button, alert)
			elseif string.find(info.key, "_dd") then
				obj = UIDropDownMenuFrame_Detail_DB(info, key_path, button, alert)
			elseif string.find(info.key, "_bool") then				
				obj = Checkbutton_Detail_DB(info, key_path, button, alert)
			elseif string.find(info.key, "_btn") then
				obj = ClickButton_Detail_DB(info, key_path, button, alert)
			end
			button.detail_options[info.key] = obj
		end
	end
	
	for i, obj in pairs(detailFrame.options) do
		obj:Hide()
	end
	
	for key, obj in pairs(button.detail_options) do
		obj:Show()
	end
	
	detailFrame.sfa.option_y = 0
	detailFrame.sfa.option_x = 0
	
	for i, obj in pairs(detailFrame.options) do
		if obj:IsShown() then
			obj:ClearAllPoints()
			SetGUIPoint(detailFrame.sfa, .5, obj)
		end
	end
	
	detailFrame:SetHeight(detailFrame.sfa.option_y + 80)
	
	detailFrame.title:SetText(text)
	
	detailFrame.reset:SetScript("OnClick", function()
		for i, info in pairs(detail_options) do
			local key_path = T.CopyTableInsertElement(path, info.key)
			T.ValueToPath(JST_CDB, key_path, info.default)
			if info.apply then
				info.apply(info.default, alert, button)
			end
		end	
		detailFrame:Hide()
		detailFrame:Show()
	end)
	
	detailFrame:Show()
end

-- 细节选项按钮
local CreateDetailOptionButton = function(button, path, text, detail_options, alert)
	local detailFrame = G.detailFrame
	local bu = CreateFrame("Button", nil, button.cover or button)
	bu:SetSize(25, 25)
	if button.cover then
		bu:SetPoint("TOPRIGHT", button, "TOPRIGHT", 5, 5)
	else
		bu:SetPoint("LEFT", button, "LEFT", 630, 0)
	end
	
	bu:SetNormalTexture("GM-icon-settings")
	bu:GetNormalTexture():SetDesaturated(true)
	bu:GetNormalTexture():SetTexCoord( .2, .8, .2, .8)
	bu:GetNormalTexture():SetVertexColor(1, 1, 1)
	bu:SetHighlightTexture("GM-icon-settings")
	bu:GetHighlightTexture():SetDesaturated(true)
	bu:GetHighlightTexture():SetTexCoord( .2, .8, .2, .8)
	bu:GetHighlightTexture():SetVertexColor(1, .82, 0)

	bu:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
		GameTooltip:AddLine(SETTINGS)
		GameTooltip:Show()
	end)
	
	bu:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	bu:SetScript("OnClick", function(self)	
		if detailFrame.lastbutton == self then
			detailFrame:Hide()
		else
			detailFrame.lastbutton = self
			UpdateDetailFrame(button, path, text, detail_options, alert)
			self:SetScript("OnHide", function(self)
				if self == detailFrame.lastbutton then
					detailFrame:Hide()
				end
			end)
		end
	end)
	
	button.detail_bu = bu
end

--====================================================--
--[[              -- 给技能设置列表 --              ]]--
--====================================================--
-- 技能列表
local Support_spell_class = {
	PRIEST = {
		33206, -- 痛苦压制
		47788, -- 守护之魂
		73325, -- 信仰飞跃
	},
	DRUID = {
	    102342, -- 铁木树皮
	},
	SHAMAN = { 
		
	},
	PALADIN = {
		633, -- 圣疗术
		1022, -- 保护祝福
		6940, -- 牺牲祝福
		1044, -- 自由祝福	
	},
	WARRIOR = { 
		3411, -- 援护
	},
	MAGE = { 

	},
	WARLOCK = { 
		20707, -- 灵魂石
	},
	HUNTER = { 
		34477, -- 误导
	},
	ROGUE = { 
		57934, -- 嫁祸诀窍
	},
	DEATHKNIGHT = {
		
	},
	MONK = {
		116849, -- 作茧缚命
	},
	DEMONHUNTER = {
		
	},
	EVOKER = {
		370665, -- 营救
		357170, -- 时间膨胀
	},
}

local Support_spell_common = {

}

local My_Support_spells = {}

for i, spellID in pairs(Support_spell_class[G.myClass]) do
	table.insert(My_Support_spells, {spellID, T.GetIconLink(spellID)})
end
for i, spellID in pairs(Support_spell_common) do
	table.insert(My_Support_spells, {spellID, T.GetIconLink(spellID)})
end

local function FormatClassName(class, className)
	return string.format("|c%s%s|r", G.Ccolors[class]["colorStr"], className)
end

local function FormatSpecName(name, icon)
	return "|T"..icon..":12:12:0:0:64:64:4:60:4:60|t "..name
end

-- 专精列表
local SpecTable = {}

for classID = 1, 13 do
	local className, class = GetClassInfo(classID)
	table.insert(SpecTable, {class, FormatClassName(class, className), spec = {}})
	
	for j = 1, GetNumSpecializationsForClassID(classID) do
		local id, name, _, icon  = GetSpecializationInfoForClassID(classID, j)
		table.insert(SpecTable[classID].spec, {id, FormatSpecName(name, icon)})
	end
end

local CreateSupportSpellDDFrame = function(parent, i)
	local frame = T.UIDropDownMenuFrame(parent, "")
	frame:SetWidth(95)
	
	frame.dd:SetPoint("LEFT", frame, "LEFT", 0, 0)
	UIDropDownMenu_SetWidth(frame.dd, 75)
	frame.dd.Text:SetWidth(65)
	
	if i == 1 then
		frame:SetPoint("TOPLEFT", parent, "TOPLEFT", -10, -10)
	else
		frame:SetPoint("LEFT", parent["dd_frame"..(i-1)], "RIGHT", 0, 0)
	end
	
	parent["dd_frame"..i] = frame
end
T.CreateSupportSpellDDFrame = CreateSupportSpellDDFrame

-- 轮次
local function UpdateSpellCountDD(self, max_count)
	UIDropDownMenu_Initialize(self.dd_frame1.dd, function(dd)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, max_count do
			dd_info.value = i
			dd_info.arg1 = i
			dd_info.text = string.format(L["第%d轮"], i)
			dd_info.checked = function(_, arg1)
				return (UIDropDownMenu_GetSelectedValue(dd) == arg1)
			end
			dd_info.func = function(_, arg1)
				UIDropDownMenu_SetSelectedValue(dd, i)
				UIDropDownMenu_SetText(dd, string.format(L["第%d轮"], i))
			end
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	UIDropDownMenu_SetSelectedValue(self.dd_frame1.dd, 1)
	UIDropDownMenu_SetText(self.dd_frame1.dd, string.format(L["第%d轮"], 1))
end
T.UpdateSpellCountDD = UpdateSpellCountDD

-- 序号
local function UpdateSpellIndexDD(self, max_count)
	UIDropDownMenu_Initialize(self.dd_frame2.dd, function(dd)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, max_count do
			dd_info.value = i
			dd_info.arg1 = i
			dd_info.text = string.format(L["%d号位"], i)
			dd_info.checked = function(_, arg1)
				return (UIDropDownMenu_GetSelectedValue(dd) == arg1)
			end
			dd_info.func = function(_, arg1)
				UIDropDownMenu_SetSelectedValue(dd, i)
				UIDropDownMenu_SetText(dd, string.format(L["%d号位"], i))
			end
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	UIDropDownMenu_SetSelectedValue(self.dd_frame2.dd, 1)
	UIDropDownMenu_SetText(self.dd_frame2.dd, string.format(L["%d号位"], 1))
end
T.UpdateSpellIndexDD = UpdateSpellIndexDD

-- 技能
local function UpdateSupportSpellDD(self)
	UIDropDownMenu_Initialize(self.dd_frame3.dd, function(dd)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i, spellInfo in pairs(My_Support_spells) do
			dd_info.value = spellInfo[1]
			dd_info.arg1 = spellInfo[1]
			dd_info.text = spellInfo[2]
			dd_info.checked = function(_, arg1)
				return (UIDropDownMenu_GetSelectedValue(dd) == arg1)
			end
			dd_info.func = function(_, arg1)
				UIDropDownMenu_SetSelectedValue(dd, spellInfo[1])
				UIDropDownMenu_SetText(dd, spellInfo[2])
			end
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	if My_Support_spells[1] then
		UIDropDownMenu_SetSelectedValue(self.dd_frame3.dd, My_Support_spells[1][1])
		UIDropDownMenu_SetText(self.dd_frame3.dd, My_Support_spells[1][2])
	end
end
T.UpdateSupportSpellDD = UpdateSupportSpellDD

-- 专精
local function InitSupportSpecDD(dd)
	dd.active_specs = {}
	
	function dd:SelectSpec(specID)
		self.active_specs[specID] = true	
	end
	
	function dd:CancelSpec(specID)
		self.active_specs[specID] = nil	
	end
	
	function dd:SelectAll()
		for classID, data in pairs(SpecTable) do
			for i, specInfo in pairs(data.spec) do
				self:SelectSpec(specInfo[1])
			end
		end
	end
	
	function dd:CancelAll()
		self.active_specs = table.wipe(self.active_specs)
	end
	
	function dd:IsSpecSelected(specID)
		return self.active_specs[specID]
	end
	
	function dd:IsAllSelectedForClass(classID)
		for i, specInfo in pairs(SpecTable[classID].spec) do
			if not self.active_specs[specInfo[1]] then
				return false
			end
		end
		return true
	end
	
	function dd:IsAllSelected()
		for classID, data in pairs(SpecTable) do
			for i, specInfo in pairs(data.spec) do
				if not self.active_specs[specInfo[1]] then
					return false
				end
			end
		end
		return true
	end
	
	function dd:IsNoneSelected()
		for k, v in pairs(self.active_specs) do
			return false
		end
		return true
	end
	
	function dd:UpdateCheckForAll()
		if self:IsAllSelected() then
			_G["DropDownList1Button1Check"]:Show()
			_G["DropDownList1Button1UnCheck"]:Hide()
		else
			_G["DropDownList1Button1Check"]:Hide()
			_G["DropDownList1Button1UnCheck"]:Show()
		end
		
		if self:IsNoneSelected() then
			_G["DropDownList1Button2Check"]:Show()
			_G["DropDownList1Button2UnCheck"]:Hide()
		else
			_G["DropDownList1Button2Check"]:Hide()
			_G["DropDownList1Button2UnCheck"]:Show()
		end
	end
	function dd:UpdateCheckForClass(classID)
		local checkImage = _G["DropDownList1Button"..(classID+2).."Check"]
		local uncheckImage = _G["DropDownList1Button"..(classID+2).."UnCheck"]
		if checkImage and uncheckImage then
			if dd:IsAllSelectedForClass(classID) then
				checkImage:Show()
				uncheckImage:Hide()
			else
				checkImage:Hide()
				uncheckImage:Show()
			end
		end
	end
end
T.InitSupportSpecDD = InitSupportSpecDD	

function UpdateSupportSpecDD(self)
	UIDropDownMenu_Initialize(self.dd_frame4.dd, function(dd, level, menuList)
		local dd_info = UIDropDownMenu_CreateInfo()
		dd_info.keepShownOnClick = true	
		if level == 1 then		
			dd_info.text = L["全部勾选"]
			dd_info.checked = function()
				return dd:IsAllSelected()
			end
			dd_info.func = function()
				dd:SelectAll()
				dd:UpdateCheckForAll()
				for classID in pairs(SpecTable) do
					dd:UpdateCheckForClass(classID)
				end
			end
			UIDropDownMenu_AddButton(dd_info)
			
			dd_info.text = L["全部取消"]
			dd_info.checked = function()
				return dd:IsNoneSelected()
			end
			dd_info.func = function()
				dd:CancelAll()
				dd:UpdateCheckForAll()
				for classID in pairs(SpecTable) do
					dd:UpdateCheckForClass(classID)
				end
			end
			UIDropDownMenu_AddButton(dd_info)
			
			for classID, classInfo in pairs(SpecTable) do
				dd_info.value = classInfo[1]
				dd_info.text = classInfo[2]
				dd_info.hasArrow = true
				dd_info.checked = function()
					return dd:IsAllSelectedForClass(classID)
				end				
				dd_info.func = function(btn)
					dd:UpdateCheckForClass(classID)
				end		
				dd_info.menuList = "class"..classID
				UIDropDownMenu_AddButton(dd_info)
			end
		elseif menuList then
			local classID = string.match(menuList, "class(%d+)")
			if classID then
				classID = tonumber(classID)
				for i, specInfo in pairs(SpecTable[classID].spec) do
					dd_info.value = specInfo[1]
					dd_info.arg1 = specInfo[1]
					dd_info.text = specInfo[2]
					dd_info.hasArrow = false				
					dd_info.checked = function()
						return dd:IsSpecSelected(specInfo[1])
					end
					dd_info.func = function(_, arg1)
						if dd:IsSpecSelected(specInfo[1]) then
							dd:CancelSpec(arg1)
						else
							dd:SelectSpec(arg1)
						end
						dd:UpdateCheckForClass(classID)
						dd:UpdateCheckForAll()
					end
					UIDropDownMenu_AddButton(dd_info, level)
				end
			end
		end
	end)
	
	self.dd_frame4.dd:SelectAll()
	UIDropDownMenu_SetText(self.dd_frame4.dd, SPECIALIZATION)
end
T.UpdateSupportSpecDD = UpdateSupportSpecDD

--====================================================--
--[[                -- 首领功能 --                  ]]--
--====================================================--
local CreateTitleAnchor = function(option_page)
	local anchor = CreateFrame("Frame", nil, option_page)
	anchor:SetSize(25, 25)
	anchor.istitle = true
	
	return anchor
end

local CreateTitleIcon = function(anchor, i, portrait, tex, text, spellID)
	local icon = CreateFrame("Frame", nil, anchor)
	icon:SetSize(30, 30)			
	T.createborder(icon)
	
	icon.tex = icon:CreateTexture(nil, "ARTWORK")
	icon.tex:SetAllPoints(icon)
	
	if portrait then
		SetPortraitTextureFromCreatureDisplayID(icon.tex, tex)
		icon.tex:SetTexCoord( .15, .85, .15, .85)
	else
		icon.tex:SetTexture(tex)
		icon.tex:SetTexCoord( .1, .9, .1, .9)
	end
	
	icon.text = T.createtext(icon, "ARTWORK", 25, "OUTLINE", "LEFT")
	icon.text:SetTextColor(1, .82, 0)
	icon.text:SetPoint("LEFT", icon, "RIGHT", 10, 0)
	icon.text:SetText(text)
	
	if spellID then
		icon:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, 10)
			GameTooltip:SetSpellByID(spellID)
			GameTooltip:Show() 
		end)
		
		icon:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	
	if i == 1 then
		icon:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, 0)
	else
		icon:SetPoint("LEFT", anchor["icon"..(i-1)].text, "RIGHT", 10, 0)
	end
	
	anchor["icon"..i] = icon
end

-- 技能标题
local CreateEncounterSectionTitle = function(option_page, data)
	if data.title then
		local title = CreateGUITitle(option_page, data.title)
		SetGUIPoint(option_page, 1, title, 30)
	else
		local anchor = CreateTitleAnchor(option_page)
		SetGUIPoint(option_page, 1, anchor, 40)
		
		local i = 0
		if data.npcs then
			for _, info in pairs(data.npcs) do
				i = i + 1
				local sectionInfo = C_EncounterJournal.GetSectionInfo(info[1])
				if sectionInfo then
					CreateTitleIcon(anchor, i, true, sectionInfo.creatureDisplayID, T.GetFlagIconStr(info[2])..sectionInfo.title)
				else
					T.test_msg(info[1], "sectionInfo error")
				end
			end
		end
		if data.spells then
			for _, info in pairs(data.spells) do
				i = i + 1
				local spellName, spellIcon = T.GetSpellInfo(info[1])
				CreateTitleIcon(anchor, i, false, spellIcon, T.GetFlagIconStr(info[2])..spellName, info[1])
			end					
		end
	end
end

-- 图标提示
T.Create_AlertIcon_Options = function(option_page, category, path, args, detail_options)	
	local frame_key = args.type.."_"..args.spellID
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local spellName = T.GetIconLink(args.spellID)
	
	local text = (args.tip and string.format("[%s]", args.tip:gsub("%%s", ""))) or (args.type == "com" and "["..L["对我施法"].."]") or ""
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, string.format(L["图标%s"], spellName, text), args.enable_tag, args.ficon)
	
	bu.apply = function()
		G.IconFrames[frame_key]:update_onedit("enable")
	end
	
	if detail_options and #detail_options > 0 then	
		CreateDetailOptionButton(bu, path, spellName, detail_options, G.IconFrames[frame_key])
	end
end

-- 计时条提示
T.Create_Timerbar_Options = function(option_page, category, path, args, detail_options)
	local frame_key = args.type.."_"..args.spellID
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local spellName = args.display_spellID and T.GetIconLink(args.display_spellID) or T.GetIconLink(args.spellID)
	
	local text = args.text and string.format("[%s]", args.text) or ""
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, string.format(L["计时条%s"], spellName, text), args.enable_tag, args.ficon)

	bu.apply = function()
		G.BarFrames[frame_key]:update_onedit("enable")
	end
	
	if detail_options and #detail_options > 0 then		
		CreateDetailOptionButton(bu, path, spellName, detail_options, G.BarFrames[frame_key])
	end	
end

-- 姓名板提示
T.Create_PlateAlert_Options = function(option_page, category, path, args, detail_options)
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local frame_key, str
	
	if args.type == "PlatePower" then
		frame_key = args.mobID
		str = string.format(L["显示姓名板能量图标"], T.GetNameFromNpcID(args.mobID) or "??")
	elseif args.type == "PlateNpcID" then
		frame_key = args.mobID
		str = string.format(L["显示姓名板动画边框"], T.GetNameFromNpcID(args.mobID) or "??")
	elseif args.type == "PlateInterrupt" then
		frame_key = args.spellID
		str = string.format(L["显示姓名板图标打断"], T.GetIconLink(args.spellID))
	elseif args.type == "PlateInterruptAuto" then
		frame_key = args.spellID
		str = string.format(L["自动分配打断"], T.GetIconLink(args.spellID))
	elseif args.type == "PlateStackAuras" then
		frame_key = args.spellID
		str = string.format(L["显示姓名板图标光环层数"], T.GetIconLink(args.spellID))
	elseif args.type == "PlateSpells" then
		frame_key = args.spellID
		str = string.format(L["姓名板法术图标"], T.GetIconLink(args.spellID))
	elseif args.type == "PlateAuras" then
		frame_key = args.spellID
		str = string.format(L["姓名板法术图标"], T.GetIconLink(args.spellID))
	elseif args.type == "PlayerAuraSource" then
		frame_key = args.spellID
		str = string.format(L["姓名板法术图标"], T.GetIconLink(args.spellID))
	end
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, str, args.enable_tag, args.ficon)
	
	bu.apply = function()
		if args.type == "PlateInterrupt" then
			local enable = T.ValueFromPath(JST_CDB, path)["enable"]
			local interrupt_sl = T.ValueFromPath(JST_CDB, path)["interrupt_sl"]
			local npcIDs = {string.split(",", args.mobID)}		
			for i, npcID in pairs(npcIDs) do			
				if enable then
					G.Npc[npcID] = interrupt_sl
				else
					G.Npc[npcID] = nil
				end
			end
		elseif args.type == "PlateInterruptAuto" then
			local enable = T.ValueFromPath(JST_CDB, path)["enable"]
			local npcID = args.mobID	
			if enable then
				if not G.AutoAssignNpc[npcID] then
					G.AutoAssignNpc[npcID] = {}
				end
				G.AutoAssignNpc[npcID] = table.wipe(G.AutoAssignNpc[npcID])
				table.insert(G.AutoAssignNpc[npcID], args.spellCD)
			else
				G.AutoAssignNpc[npcID] = nil
			end
		end
	end
	
	if detail_options and #detail_options > 0 then		
		CreateDetailOptionButton(bu, path, str, detail_options)
	end
end

-- 团队框架提示
T.Create_RFIcon_Options = function(option_page, category, path, args)
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local spellName = T.GetIconLink(args.spellID)
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, string.format(L["团队框架图标%s"], spellName), args.enable_tag, args.ficon)
end

-- 首领模块
T.Create_BossMod_Options = function(option_page, category, path, args, detail_options)
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local str = args.name or string.format("%s %s", T.GetIconLink(args.spellID), L["首领模块"])
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, str, args.enable_tag, args.ficon)
	bu.apply = function() 
		G.BossModFrames[args.spellID]:update_onedit("enable")		
	end

	if detail_options and #detail_options > 0 then
		CreateDetailOptionButton(bu, path, str, detail_options, G.BossModFrames[args.spellID])
	end
end

-- 音效提示
T.Create_Sound_Options = function(option_page, category, path, args)
	local enable_path = T.CopyTableInsertElement(path, "enable")	
	local str = string.format(sound_suffix[args.sub_event][2], T.GetIconLink(args.spellID))..(args.private_aura and "(Private Aura)" or "")
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, str, args.enable_tag, args.ficon)
	bu.apply = function()
		local frame = G.PASoundTiggerFrames[args.spellID]
		if frame then
			frame:update_onedit()
		end
	end
	
	CreateSoundPreviewButton(bu, args.file, {"LEFT", bu, "LEFT", 630, 0})
end

-- 文字提示
T.Create_TextAlert_Options = function(option_page, category, path, args, detail_options)
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local str
	local frame_key
	
	if args.type == "hp" then
		str = string.format(args.data.ranges[1]["tip"], (args.data.ranges[1]["ul"]+args.data.ranges[1]["ll"])/2)
		str = L["血量提示"].." "..T.hex_str(str, args.color or {1, 0, 0})
		frame_key = args.type.."_"..args.data.npc_id
	elseif args.type == "pp" then
		str = string.format(args.data.ranges[1]["tip"], (args.data.ranges[1]["ul"]+args.data.ranges[1]["ll"])/2)
		str = L["能量提示"].." "..T.hex_str(str, args.color or {0, 1, 1})
		frame_key = args.type.."_"..args.data.npc_id
	elseif args.type == "spell" then
		str = L["技能提示"].." "..T.hex_str(args.preview, args.color or {1, 1, 1})
		frame_key = args.type.."_"..args.data.spellID
	end
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, str, args.enable_tag, args.ficon)
	bu.apply = function()
		G.TextFrames[frame_key]:update_onedit("enable")
	end
	
	if detail_options and #detail_options > 0 then		
		CreateDetailOptionButton(bu, path, str, detail_options, G.TextFrames[frame_key])
	end
end

-- 转阶段
T.Create_Phase_Options = function(option_page, category, args)
	local str
	
	if args.type == "CLEU" then
		str = string.format(L["转阶段技能"], args.phase, string.format(PhaseTriggerEvents[args.sub_event], T.GetIconLink(args.spellID)))..(args.count and string.format("(%d)", args.count) or "")..(args.source and string.format("(%d)", args.source) or "")
	elseif args.type == "UNIT" then
		str = string.format(L["转阶段技能"], args.phase, string.format(L["加入战斗"], T.GetNameFromNpcID(args.npcID)))
	end
	
	local text = CreateGUIDesciption(option_page, str)
	SetGUIPoint(option_page, 1, text, nil, nil, 20, -5)
end

--====================================================--
--[[                -- 控制台选项 --                ]]--
--====================================================--
-- GUI功能
local CreateGUIOpitons = function(parent, OptionCategroy, start_ind, end_ind)
	local start_ = start_ind or 1
	local end_ = end_ind or #G.Options[OptionCategroy]
	
	if not parent.option_y then
		parent.option_y = -10
	end
	
	for i = start_, end_ do
		local info = G.Options[OptionCategroy][i]
		local path = {OptionCategroy, info.key}
		local obj
		
		if (not info.class or info.class[G.myClass]) then
			if info.option_type == "title" then
				obj = CreateGUITitle(parent, info.text)
			elseif info.option_type == "string" then
				obj = CreateGUIDesciption(parent, info.text)				
			elseif info.option_type == "ddmenu" then
				obj = UIDropDownMenuFrame_DB(parent, path)	
			elseif info.option_type == "check" then
				obj = Checkbutton_DB(parent, path)
			elseif info.option_type == "slider" then
				obj = Slider_DB(parent, path)
			elseif info.option_type == "button" then
				obj = ClickButton_DB(parent, path)
			end
			
			if info.rely then
				createDR(parent[info.rely], obj)
			end

			SetGUIPoint(parent, info.width or 1, obj, info.option_type == "title" and 20)
			
			if info.key then
				parent[info.key] = obj
			end
		end
	end
end
T.CreateGUIOpitons = CreateGUIOpitons

-- BOSS设置面板
T.CreateEncounterOptions = function(option_page, encounterName, InstanceID, ENCID)
	local data = G.Encounters[ENCID]
	if not data then return end
	
	option_page.img = option_page:CreateTexture(nil, "OVERLAY")
	option_page.img:SetPoint("TOPLEFT", 5, -5)
	option_page.img:SetTexCoord( 0, 1, 0, .95)
	option_page.img:SetSize(128, 64)
	option_page.img:SetTexture(T.GetEncounterTex(ENCID))
	
	option_page.title = T.createtext(option_page, "OVERLAY", 25, "OUTLINE", "LEFT")
	option_page.title:SetPoint("BOTTOMLEFT", option_page.img, "BOTTOMRIGHT", 0, 0)
	option_page.title:SetText(encounterName)
		
	if type(ENCID) == "number" then
		option_page.tlcopy = T.ClickButton(option_page, 120, {"TOPRIGHT", -10, -10}, L["个人战术板模板"])
		option_page.tlcopy:SetScript("OnClick", function(self)
			T.DisplayCopyString(self, encounterName.."\nJST"..ENCID..L["时间轴"].."\n0:10 xxx\n1:20 xxx\n2:30 xxx\n"..L["战斗结束"], L["个人战术板模板"].." "..L["复制粘贴"])
		end)
		
		option_page.mrtcopy = T.ClickButton(option_page, 120, {"RIGHT", option_page.tlcopy, "LEFT", -5, 0}, L["MRT技能模板"])
		option_page.mrtcopy:SetScript("OnClick", function(self)
			local str = ""
			for section_index, section_data in pairs(data.alerts) do
				for index, args in pairs(section_data.options) do
					if args.category == "PlateAlert" and args.type == "PlateInterrupt" then
						str = str.."\n--------------\n"
						str = str..T.GetInterruptStr(args.mobID, args.spellID, "", args.interrupt).."\n"
					elseif args.category == "BossMod" then
						local frame = G.BossModFrames[args.spellID]
						if frame and frame.copy_mrt then
							str = str.."\n--------------\n"
							str = str..frame:copy_mrt()
						end
					end
				end
			end
			T.DisplayCopyString(self, str)
		end)
		
		option_page.ejtoggle = T.ClickButton(option_page, 120, {"RIGHT", option_page.mrtcopy, "LEFT", -5, 0}, ENCOUNTER_JOURNAL)
		option_page.ejtoggle:SetScript("OnClick", function(self)
			if EncounterJournal.encounterID ~= ENCID then
				if not EncounterJournal:IsShown() then
					ToggleEncounterJournal()
				end
				EncounterJournal_OpenJournal(nIL, InstanceID, ENCID)
				EncounterJournal_SetTab(3)
			else
				ToggleEncounterJournal()
			end
		end)
	end
	
	option_page.InstanceID = InstanceID
	option_page.option_y = 50
	
	option_page:SetScript("OnShow", function() 
		G.current_encounterID = ENCID
	end)
	
	for section_index, section_data in pairs(data.alerts) do
		CreateEncounterSectionTitle(option_page, section_data)
		for index, args in pairs(section_data.options) do
			local category = args.category
			local alert_type = args.type
			if not category then
				T.test_msg(string.format("encounter %s section %d option %d, category missing", ENCID, section_index, index))
			end
			if category == "AlertIcon" then
				if alert_type == "aura" then
					T.CreateAura(ENCID, option_page, category, args)
				elseif alert_type == "com" then
					T.CreateCom(ENCID, option_page, category, args)
				elseif alert_type == "bmsg" then
					T.CreateBossMsg(ENCID, option_page, category, args)
				end
			elseif category == "AlertTimerbar" then
				if alert_type == "cast" then
					T.CreateCastbar(ENCID, option_page, category, args)
				elseif alert_type == "cleu" then
					T.CreateCLEUbar(ENCID, option_page, category, args)
				end
			elseif category == "TextAlert" then
				if alert_type == "hp" then
					T.CreateHealthText(ENCID, option_page, category, args)
				elseif alert_type == "pp" then
					T.CreatePowerText(ENCID, option_page, category, args)
				elseif alert_type == "spell" then
					T.CreateSpellText(ENCID, option_page, category, args)
				end
			elseif category == "PlateAlert" then
				T.CreatePlateAlert(ENCID, option_page, category, args)
			elseif category == "Sound" then	
				T.CreateSoundAlert(ENCID, option_page, category, args)
			elseif category == "RFIcon" then	
				T.CreateRFIconAlert(ENCID, option_page, category, args)
			elseif category == "PhaseChangeData" then
				T.CreatePhase(ENCID, option_page, category, args)
			elseif category == "BossMod" then
				T.CreateBossMod(ENCID, option_page, category, args)
			end
		end	
	end
end

--====================================================--
--[[                  -- Setup --                   ]]--
--====================================================--
local setup_frame = CreateFrame("Frame", nil, UIParent, "SettingsFrameTemplate")
setup_frame:SetSize(370, 180)
setup_frame:SetPoint("CENTER", UIParent, "CENTER")
setup_frame:SetFrameStrata("HIGH")
setup_frame:SetFrameLevel(30)
setup_frame:Hide()

setup_frame:RegisterForDrag("LeftButton")
setup_frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
setup_frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
setup_frame:SetClampedToScreen(true)
setup_frame:SetMovable(true)
setup_frame:EnableMouse(true)

setup_frame.NineSlice.Text:SetText(G.addon_cname)
setup_frame.NineSlice.Text:SetFont(G.Font, 16, "OUTLINE")
setup_frame.NineSlice.Text:SetShadowOffset(0, 0)

setup_frame.description = T.createtext(setup_frame, "OVERLAY", 12, "OUTLINE", "LEFT")
setup_frame.description:SetPoint("TOPLEFT", setup_frame, "TOPLEFT", 20, -30)

do
	local option_table = {
		{"rl", L["指挥"]},
		{"no-rl", L["非指挥"]},
		{"none", L["全部禁用"]},
	}

	local frame = T.UIDropDownMenuFrame(setup_frame, L["加载规则"], {"TOPLEFT", 25, -80})
	frame.dd:SetPoint("LEFT", frame, "LEFT", 130, 0)
	local path = {"LoadOption", "role_enable_tag"}
	
	local function DD_UpdateChecked(self, arg1)
		return (T.ValueFromPath(JST_CDB, path) == arg1)
	end
	
	local function DD_SetChecked(self, arg1, arg2)
		T.ValueToPath(JST_CDB, path, arg1)
		T.UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, arg1)		
	end
	
	UIDropDownMenu_Initialize(frame.dd, function(self, level)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, #option_table do
			dd_info.value = option_table[i][1]
			dd_info.arg1 = option_table[i][1]
			dd_info.text = option_table[i][2]
			dd_info.checked = DD_UpdateChecked
			dd_info.func = DD_SetChecked
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	frame:SetScript("OnShow", function()
		T.UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, T.ValueFromPath(JST_CDB, path))
	end)
end

setup_frame.confirm = ClickButton(setup_frame, 150, {"BOTTOMRIGHT", setup_frame, "BOTTOM", -10, 20}, L["加载设置"])
setup_frame.confirm:SetScript("OnClick", function()
	for category, settings in pairs(JST_CDB) do
		if category ~= "LoadOption" then			
			JST_CDB[category] = nil
		end
	end
	ReloadUI()
end)
		
setup_frame.close = ClickButton(setup_frame, 150, {"BOTTOMLEFT", setup_frame, "BOTTOM", 10, 20}, CLOSE)
setup_frame.close:SetScript("OnClick", function()
	setup_frame:Hide()
end)

T.ToggleSetup = function(new)
	if setup_frame:IsShown() then
		setup_frame:Hide()
	else
		if new then
			setup_frame.description:SetText(L["欢迎"])
			setup_frame.confirm:SetText(L["加载设置"])
			setup_frame.close:Hide()
		else
			setup_frame.description:SetText(L["加载规则说明"])
			setup_frame.confirm:SetText(L["重置所有设置"])
			setup_frame.close:Show()
		end
		setup_frame:Show()
	end
end
