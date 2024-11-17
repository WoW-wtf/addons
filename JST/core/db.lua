local T, C, L, G = unpack(select(2, ...))

local Character_default_Settings = {
	FramePoints = {},
	LoadOption = {
		role_enable_tag = "no-rl",
	},
	GeneralOption = {
		role_enable = true,
		disable_all = false,
		disable_sound = false,
		disable_rf = false,
		disable_plate = false,
		mynickname = "",
		nickname_check = false,
		name_format = "nickname",
		sound_pack = "JST_SoundPackCN",
		sound_file = "",
		sound_channel = "Master",
		tts_speaker = 0,
		disable_rmark = false,
		IconMiniMapLeft = 12,
		IconMiniMapTop = -80,
		hide_minimap = false,
		rm = true,
		tl = true,
		tl_use_self = true,
		tl_use_raid = true,
		tl_advance = 60,
		tl_font_size = 18,		
		tl_show_time = false,
		tl_glowtarget = true,
		tl_bar = true,
		tl_bar_dur = 10,
		tl_sound = true,
		tl_sound_volume = 100,
		tl_sound_dur = 5,
		tl_text = true,
		tl_text_dur = 5,
		tl_text_show_dur = false,
		moving_boss = 0,
		cs = true,
		cs_sound = "speak",
		gui_scale = 100,
		raid_pa = true,
		raid_pa_width = 50,
		raid_pa_height = 20,
		raid_pa_fsize = 14,
		raid_pa_icon_num = 2,
	},	
	IconAlertOption = {		
		test = false,
		show_spelldur = false,
		icon_size = 65,
		icon_space = 5,
		grow_dir = "RIGHT",
		font_size = 18,
		ifont_size = 12,
		enable_pa = true,
		privateaura_icon_size = 65,
		privateaura_icon_alpha = 1,		
	},	
	TimerbarOption = {
		bar_width = 260,
		bar_height = 25,
	},
	TextAlertOption = {
		font_size = 35,
		font_size_big = 50,
	},	
	PlateAlertOption = {
		size = 25,
		y = 20,
		x = 0,
		interrupt_sound = "interrupt",
		interrupt_sound_cast = "interrupt_cast",
		interrupt_only_mine = false,
	},
	RFIconOption = {
		RFIcon_size = 25,
		RFIndex_size = 40,
	},
}

local Character_alert_Settings = {}

local Account_default_Settings = {
	NpcNames = {},
}

local LoadNewSettings = function(enable_tag)
	local role_enable_tag = JST_CDB["LoadOption"]["role_enable_tag"]
	if role_enable_tag == "none" then -- 全部禁用
		return false
	elseif role_enable_tag == "rl" then -- 全部启用
		return true
	elseif enable_tag then -- 有加载标签
		if enable_tag == "everyone" then -- 所有人加载
			return true
		elseif enable_tag == "rl" or enable_tag == "spell" then -- RL加载
			return false
		else -- 其他加载标签（职责）
			return true
		end
	else -- 无标记全部加载
		return true
	end
end

local InitSettings = function(path, enable_tag, ficon, details)	
	local detail_table = details or {}
	detail_table.enable = LoadNewSettings(enable_tag, ficon)
	
	for key, value in pairs(detail_table) do
		local key_path = T.CopyTableInsertElement(path, key)
		local DB_setting = T.ValueFromPath(JST_CDB, key_path)
		if DB_setting == nil then
			T.ValueToPath(JST_CDB, key_path, value)
		end
	end
end
T.InitSettings = InitSettings

local Update_default_Settings = function()
	Character_alert_Settings = table.wipe(Character_alert_Settings)
	for ENCID, info in pairs(G.Encounters) do
		if info.alerts then
			for section_index, data in pairs(info.alerts) do
				for index, args in pairs(data.options) do
					local category = args.category
					local alert_type = args.type
					if not Character_alert_Settings[category] then
						Character_alert_Settings[category] = {}
					end
					if alert_type and not Character_alert_Settings[category][alert_type] then
						Character_alert_Settings[category][alert_type] = {}
					end
					if category == "BossMod" then
						Character_alert_Settings[category][args.spellID] = {
							enable = LoadNewSettings(args.enable_tag, args.ficon)
						}
						if args.custom then
							for i, t in pairs(args.custom) do -- 细节选项
								Character_alert_Settings[category][args.spellID][t.key] = t.default
							end
						end
					elseif category == "AlertIcon" then
						Character_alert_Settings[category][alert_type][args.spellID] = {
							enable = LoadNewSettings(args.enable_tag, args.ficon)
						}
						if args.sound then
							Character_alert_Settings[category][alert_type][args.spellID].sound_bool = true
						end
						if args.msg then
							Character_alert_Settings[category][alert_type][args.spellID].msg_bool = true		
						end
					elseif category == "AlertTimerbar" then
						Character_alert_Settings[category][alert_type][args.spellID] = {
							enable = LoadNewSettings(args.enable_tag, args.ficon)
						}
						if args.sound then
							Character_alert_Settings[category][alert_type][args.spellID].sound_bool = true
						end
					elseif category == "TextAlert" then	
						if alert_type == "hp" or alert_type == "pp" then
							Character_alert_Settings[category][alert_type][args.data.npc_id] = {
								enable = LoadNewSettings(args.enable_tag, args.ficon)
							}
						else
							Character_alert_Settings[category][alert_type][args.data.spellID] = {
								enable = LoadNewSettings(args.enable_tag, args.ficon)
							}
							if args.data.sound then
								Character_alert_Settings[category][alert_type][args.data.spellID].sound_bool = true
							end
						end
					elseif category == "PlateAlert" then
						if alert_type == "PlatePower" or alert_type == "PlateNpcID" then
							Character_alert_Settings[category][alert_type][args.mobID] = {
								enable = LoadNewSettings(args.enable_tag, args.ficon)
							}
						else
							Character_alert_Settings[category][alert_type][args.spellID] = {
								enable = LoadNewSettings(args.enable_tag, args.ficon)
							}
							if alert_type == "PlateInterrupt" then
								Character_alert_Settings[category][alert_type][args.spellID].interrupt_sl = args.interrupt
								Character_alert_Settings[category][alert_type][args.spellID].auto_assign_bool = args.auto_assign
							end
						end
					elseif category == "Sound" then
						local sound_type = G.sound_suffix[args.sub_event][1]
						if not Character_alert_Settings[category][sound_type] then
							Character_alert_Settings[category][sound_type] = {}
						end
						Character_alert_Settings[category][sound_type][args.spellID] = {
							enable = LoadNewSettings(args.enable_tag, args.ficon)
						}
					elseif category == "RFIcon" then
						Character_alert_Settings[category][alert_type][args.spellID] = {
							enable = LoadNewSettings(args.enable_tag, args.ficon)
						}
					end
				end
			end
		end	
	end
end

local LoadSettings
do
	LoadSettings = function(DB, t)
		for k, v in pairs(t) do
			if type(v) ~= "table" then
				if DB[k] == nil then
					DB[k] = v
				end
			else
				if DB[k] == nil then
					DB[k] = {}
				end
				LoadSettings(DB[k], v)
			end
		end
	end
end

local LoadVariables = function()
	local show_setup
	
	if JST_CDB == nil then
		JST_CDB = {}
		show_setup = true
	end
	
	LoadSettings(JST_CDB, Character_default_Settings)
	
	if show_setup then
		T.ToggleSetup(true)
	end
end
T.LoadVariables = LoadVariables

local LoadAccountVariables = function()
	if JST_DB == nil then
		JST_DB = {}
	end
	
	LoadSettings(JST_DB, Account_default_Settings)
end
T.LoadAccountVariables = LoadAccountVariables

local ValueToString = function(value)
	local valuetext
	if value == false then
		return "false"
	elseif value == true then
		return "true"
	elseif type(value) == "number" then
		return string.format("num:%d", value)
	else
		return value
	end
end

local StringToValue = function(str_value)
	if str_value == "true" then
		return true	
	elseif str_value == "false" then
		return false	
	elseif string.match(str_value, "num:(%d+)") then
		return tonumber(string.match(str_value, "num:(%d+)"))
	else
		return str_value
	end
end

T.ExportSettings = function()
	local str = G.addon_name.." Export".."~"..G.Version
	
	for OptionCategroy, OptionTable in pairs(Character_default_Settings) do
		if string.find(OptionCategroy, "Option") then
			for setting, value in pairs(OptionTable) do
				local db_value = JST_CDB[OptionCategroy][setting]
				if db_value ~= value then
					str = str.."^"..OptionCategroy.."~"..setting.."~"..ValueToString(db_value)
				end
			end
		end	
	end
	
	for frame_name, info in pairs(JST_CDB["FramePoints"]) do
		local frame = _G[frame_name]
		if frame and frame.point then
			for key, value in pairs(info) do
				if value ~= frame.point[key] then
					str = str.."^FramePoints~"..frame_name.."~"..key.."~"..value
				end
			end
		end
	end
	
	Update_default_Settings()
	
	for OptionCategroy, OptionTable in pairs(Character_alert_Settings) do
		if OptionCategroy == "BossMod" then -- no sub type
			for frame_key, info in pairs(OptionTable) do
				for setting, value in pairs(info) do
					local db_value = JST_CDB[OptionCategroy][frame_key][setting]
					if db_value ~= value then
						if setting == "option_list_btn" then
							for index, data in pairs(db_value) do
								for key, v in pairs(data) do
									if key == "spec_info" then
										for specID, a in pairs(v) do
											str = str.."^"..OptionCategroy.."~"..ValueToString(frame_key).."~"..setting.."~"..ValueToString(index).."~"..key.."~"..ValueToString(specID).."~"..ValueToString(a)
										end
									else
										str = str.."^"..OptionCategroy.."~"..ValueToString(frame_key).."~"..setting.."~"..ValueToString(index).."~"..key.."~"..ValueToString(v)
									end
								end
							end
						else
							str = str.."^"..OptionCategroy.."~"..ValueToString(frame_key).."~"..setting.."~"..ValueToString(db_value)
						end
					end
				end
			end
		else -- with sub type
			for subCategroy, data in pairs(OptionTable) do
				for frame_key, info in pairs(data) do
					for setting, value in pairs(info) do
						local db_value = JST_CDB[OptionCategroy][subCategroy][frame_key][setting]
						if db_value ~= value then		
							str = str.."^"..OptionCategroy.."~"..subCategroy.."~"..ValueToString(frame_key).."~"..setting.."~"..ValueToString(db_value)
						end
					end
				end
			end
		end
	end
	
	return str
end

T.ImportSettings = function(str)
	local optionlines = strsplittable("^", str)
	local addon_name, version = string.split("~", optionlines[1])
	local sameversion
	
	if addon_name ~= G.addon_name.." Export" then
		StaticPopup_Show(G.addon_name.."Cannot Import")
	else
		local import_str = ""
		if version ~= G.Version then
			import_str = import_str..format(L["版本不符合"], version, G.Version)
		else
			sameversion = true
		end
		
		if not sameversion then
			import_str = import_str..L["不完整导入"]
		end
		
		StaticPopupDialogs[G.addon_name.."Import Confirm"].text = format(L["导入确认"]..import_str, G.addon_name)
		StaticPopupDialogs[G.addon_name.."Import Confirm"].OnAccept = function()
			JST_CDB = table.wipe(JST_CDB)
			LoadSettings(JST_CDB, Character_default_Settings)	
			Update_default_Settings()
			LoadSettings(JST_CDB, Character_alert_Settings)
			
			for index, v in pairs(optionlines) do
				if index ~= 1 then
					local path = strsplittable("~", v)
					for i, key in pairs(path) do
						path[i] = StringToValue(key)
					end
					local value = table.remove(path)
					if path[1] ~= "Account_Settings" then
						T.ValueToPath(JST_CDB, path, value)
					end
				end
			end
			
			ReloadUI()
		end
		StaticPopup_Show(G.addon_name.."Import Confirm")
	end
end