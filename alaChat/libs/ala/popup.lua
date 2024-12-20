﻿--[[--
	ALA@163UI
--]]--

local __version = 5;

local _G = _G;
_G.__ala_meta__ = _G.__ala_meta__ or {  };
local __ala_meta__ = _G.__ala_meta__;

-->			versioncheck
	local Popup = _G.alaPopup;
	if Popup ~= nil and Popup.__minor ~= nil and Popup.__minor >= __version then
		return;
	elseif Popup == nil then
		Popup = {  };
		_G.alaPopup = Popup;
	else
		if Popup.menu ~= nil then
			Popup.menu:Hide();
		end
	end
	Popup.__minor = __version;

-->
local uireimp = __ala_meta__.uireimp;
-- local autostyle = __ala_meta__.autostyle;

-->			upvalue
	local type = type;
	local next, unpack = next, unpack;
	local tremove = tremove;
	local _ = nil;

	local DropDownList1 = DropDownList1;

-->			constant
	local TOOLTIP_DEFAULT_BACKGROUND_COLOR = TOOLTIP_DEFAULT_BACKGROUND_COLOR or { r = 0.09, g = 0.09, b = 0.19, };
	local TOOLTIP_DEFAULT_COLOR = TOOLTIP_DEFAULT_COLOR or { r = 1.0, g = 1.0, b = 1.0, };
	local dropMenuBackdrop = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",	-- "Interface\\Buttons\\WHITE8X8";	-- "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",	-- "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	};
	local dropMenuBackdropColor = { TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b, 1.0 };
	local dropMenuBackdropBorderColor = { TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, 1.0};

	local height = 16;
	local interval = 0;
	local v_to_border = 8;
	local h_to_border = 8;

-->
	local ElvUILoaded = C_AddOns.IsAddOnLoaded("ElvUI");
	local function SetElvUIButton(button)
		local ElvUI = _G.ElvUI;
		if ElvUI ~= nil then
			local highlight = button:GetHighlightTexture();
			if highlight ~= nil then
				local E = ElvUI[1];
				highlight:SetTexture(E.Media.Textures.Highlight);
				-- highlight:SetBlendMode('BLEND');
				-- highlight:SetDrawLayer('BACKGROUND');
				local r, g, b = unpack(E.media.rgbvaluecolor);
				highlight:SetVertexColor(r, g, b);
			end
		end
	end
	local menu = CreateFrame('BUTTON', nil, DropDownList1);
	menu:SetFrameStrata("FULLSCREEN_DIALOG");
	menu:SetClampedToScreen(false);
	menu:Show();
	menu:SetPoint("TOPLEFT", DropDownList1, "TOPRIGHT");
	menu:SetWidth(120);
	uireimp._SetBackdrop(menu, dropMenuBackdrop);
	uireimp._SetBackdropColor(menu, dropMenuBackdropColor[1], dropMenuBackdropColor[2], dropMenuBackdropColor[3], dropMenuBackdropColor[4]);
	uireimp._SetBackdropBorderColor(menu, dropMenuBackdropBorderColor[1], dropMenuBackdropBorderColor[2], dropMenuBackdropBorderColor[3], dropMenuBackdropBorderColor[4]);
	menu:SetScript("OnClick", function(self, button)
		DropDownList1:Hide();
	end);
	DropDownList1:HookScript("OnShow", function()
		if DropDownList1.dropdown.which then
			menu:Show();
		else
			menu:Hide();
		end
	end);

	local func = {  };
	local buttons = {  };
	local meta = Popup.meta or {  };
	local list = Popup.list or {  };
	local target = nil;
	local which = nil;
	local function dropMenuButtonOnClick(self)
		DropDownList1:Hide();
		if not target or not which then
			target = nil;
			which = nil;
			return;
		end
		local values = list[which] or list["*"];
		local id = self.id;
		if values and values[id] then
			meta[values[id]][2](which, target);
		end
		target = nil;
		which = nil;
	end
	function func.create(menu, id, x, y)
		local button = CreateFrame('BUTTON', nil, menu);
		--button:SetFrameStrata("FULLSCREEN_DIALOG");
		button:SetHeight(height);
		--button:SetNormalTexture([[Interface\Buttons\UI-StopButton]]);
		--button:SetPushedTexture([[Interface\Buttons\UI-StopButton]]);
		button:SetHighlightTexture([[Interface\TargetingFrame\UI-StatusBar]]);
		button:GetHighlightTexture():SetVertexColor(0.5, 0.5, 0.0, 0.5);
		button:SetPoint("TOP", menu, x, y);
		button:SetWidth(menu:GetWidth() - 2 * h_to_border);

		local text = button:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		text:SetPoint("LEFT", 2, 0);
		text:SetTextColor(1.0, 1.0, 1.0, 1.0);
		button.text = text;
		
		button:SetScript("OnClick", dropMenuButtonOnClick);
		button.id = id;

		-- autostyle:AddReskinObject(button);
		if ElvUILoaded then
			SetElvUIButton(button);
		end

		return button;
	end
	function func.set_num(num)
		if #buttons < num then
			for i = #buttons + 1, num do
				buttons[i] = func.create(menu, i, 0, -((i - 1) * (height + interval) + v_to_border));
			end
		elseif #buttons > num then
			for i = num + 1, #buttons do
				buttons[i]:Hide();
			end
		end
		for i = 1, num do
			buttons[i]:Show();
		end
		if num > 0 then
			menu:SetHeight(2 * v_to_border + interval * (num - 1) + height * num);
			menu:Show();
		else
			menu:Hide();
		end
	end
	function func.set(which)
		if which and (list[which] or list["*"]) then
			local values = list[which] or list["*"];
			local num = #values;
			func.set_num(num);
			for i = 1, num do
				buttons[i].text:SetText(meta[values[i]][1]);
			end
		else
			func.set_num(0);
		end
	end

	local function hook(level, value, frame, ...)
		if level == 1 and DropDownList1:IsShown() then
			-- bnetIDAccount
			if frame and frame.which then
				target = frame;
				which = frame.which;
				func.set(frame.which);
			else
				func.set(nil);
			end
		end
	end
	hooksecurefunc("ToggleDropDownMenu", hook)

	if false then
		local function hook1(self)
			print(self:GetName())
		end
		local function hook2(level, value, meta, ...)
			if level == 1 and DropDownList1:IsShown() then
				_G.aladrop = meta;
				print(meta.name, meta.server == nil and "nil" or (meta.server == "" and "empty" or meta.server), meta.which, meta.unit);
				-- bnetIDAccount
			end
		end
		local function hook3(meta, initFunction, displayMode, level, menuList)
			if level == 1 then
				-- print(meta, initFunction, displayMode, level, menuList)
			end
		end

		hooksecurefunc(DropDownList1, "Show", hook1)
		-- hooksecurefunc(DropDownList2, "Show", hook1)
		hooksecurefunc("ToggleDropDownMenu", hook2)
		hooksecurefunc("UIDropDownMenu_Initialize", hook3);
	end

	local function tinsert_unique(meta, value)
		for i = 1, #meta do
			if value == meta[i] then
				return;
			end
		end
		meta[#meta + 1] = value;
	end
	local function tremove_value(meta, value)
		for i = #meta, 1, -1 do
			if meta[i] == value then
				tremove(meta, i);
			end
		end
	end
	local function add_meta(key, value)
		if type(key) == 'table' then
			local k = #meta + 1;
			meta[k] = key;
			return k;
		elseif (not key or type(key) == 'string') and type(value) == 'table' then
			key = key or #meta + 1;
			meta[key] = value;
			return key;
		end
	end
	local function sub_meta(key)
		if type(key) == 'table' then
			for k, v in next, meta do
				if v == key then
					meta[k] = nil;
					return k;
				end
			end
		elseif type(key) == 'string' or type(key) == 'number' then
			meta[key] = nil;
			return key;
		end
	end
	local function exist_meta(key)
		return meta[key] ~= nil;
	end
	local function find_meta(value)
		if type(value) ~= 'table' then
			return nil;
		end
		for k, v in next, meta do
			if v == value then
				return k;
			end
		end
	end
	local function add_list(which, key)
		list[which] = list[which] or {  };
		if (type(key) == 'string' or type(key) == 'number') and exist_meta(key) then
			tinsert_unique(list[which], key);
		elseif type(key) == 'table' then
			tinsert_unique(list[which], add_meta(nil, key));
		end
	end
	local function sub_list(which, key)
		if list[which] then
			if type(key) == 'string' or type(key) == 'number' then
				tremove_value(list[which], key);
			else
				local k = find_meta(key);
				if k then
					tremove_value(list[which], k);
				end
			end
		end
	end

-->

Popup.add_meta = add_meta;
Popup.sub_meta = sub_meta;
Popup.add_list = add_list;
Popup.sub_list = sub_list;
_G["ALAPOPUP"] = showMenu;
Popup.func = func;
Popup.menu = menu;
Popup.meta = meta;
Popup.list = list;

-- autostyle:AddReskinObject(menu);

local flat = {
	bgFile = "Interface\\Buttons\\WHITE8X8",
	edgeFile = "Interface\\Buttons\\WHITE8X8",
	tile = false,
	tileSize = 16,
	edgeSize = 1,
	insets = { left = 1, right = 1, top = 1, bottom = 1, },	
};
if C_AddOns.IsAddOnLoaded("ElvUI") or C_AddOns.IsAddOnLoaded("TuKUI") or C_AddOns.IsAddOnLoaded("NDUI") then
	uireimp._SetBackdrop(menu, flat);
	uireimp._SetBackdropColor(menu, 0, 0, 0, 0.75);
	uireimp._SetBackdropBorderColor(menu, 0, 0, 0, 0.9);
else
	menu:RegisterEvent("ADDON_LOADED");
	menu:SetScript("OnEvent", function(self, event, addon)
		addon = addon:lower();
		if addon == "elvui" then
			ElvUILoaded = true;
			for i = 1, #buttons do
				SetElvUIButton(buttons[i]);
			end
		end
		if addon == "elvui" or addon == "tukui" or addon == "ndui" then
			uireimp._SetBackdrop(menu, flat);
			uireimp._SetBackdropColor(menu, 0, 0, 0, 0.5);
			uireimp._SetBackdropBorderColor(menu, 0, 0, 0, 0.9);
		end
	end);
end
