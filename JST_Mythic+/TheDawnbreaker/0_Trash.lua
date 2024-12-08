local T, C, L, G = unpack(JST)

G.Encounter_Order[1270] = {2580, 2581, 2593, "1270Trash"}

local function soundfile(filename)
	return string.format("[1270\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["1270Trash"] = {
	map_id = 2662,
	alerts = {
		{ -- 折磨光束
			spells = {
				{431365},
			},
			options = {				
				{ -- 图标 折磨光束
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 431365,
					hl = "red",
					tip = L["DOT"],
				},
			},
		},
		{ -- 冥河之种
			spells = {
				{432448},
			},
			options = {
				{ -- 对我施法图标 冥河之种
					category = "AlertIcon",
					type = "com",
					spellID = 432448,
					hl = "yel_flash",
					ficon = "7",
				},
				{ -- 图标 冥河之种
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 432448,
					hl = "org_flash",
					tip = L["离开人群"],
					ficon = "7",
					sound = "[getout]",
					msg = {str_applied = "%name %spell"},
				},
			},
		},
		{ -- 诱捕暗影
			spells = {
				{431309},
			},
			options = {				
				{ -- 姓名板自动打断图标 诱捕暗影
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 431309,
					mobID = "213892",
					spellCD = 30,
					ficon = "6",
					hl_np = true,
				},
				{ -- 图标 诱捕暗影
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 431309,
					hl = "pur",
					tip = L["减速"].."+"..L["DOT"],
					ficon = "8",
				},
			},
		},
		{ -- 污邪斩击
			spells = {
				{431491},
			},
			options = {				
				{ -- 图标 污邪斩击
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 431491,
					tip = L["DOT"],
					ficon = "13",
				},
			},
		},
		{ -- 深渊嗥叫
			spells = {
				{450756},
			},
			options = {				
				{ -- 姓名板自动打断图标 深渊嗥叫
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 450756,
					mobID = "214762",
					spellCD = 25,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 迸发虫茧
			spells = {
				{451107},
			},
			options = {				
				{ -- 对我施法图标 迸发虫茧
					category = "AlertIcon",
					type = "com",
					spellID = 451107,
					hl = "yel_flash",
				},
				{ -- 图标 迸发虫茧
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 451107,
					hl = "org_flash",
					tip = L["注意自保"],
					sound = "[defense]",
					msg = {str_applied = "%name %spell"},
				},
			},
		},
		{ -- 深渊朽烂
			spells = {
				{453345},
			},
			options = {				
				{ -- 团队框架图标
					category = "RFIcon",
					type = "Cast",
					spellID = 453345,
				},
				{ -- 图标 深渊朽烂
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 453345,
					tip = L["强力DOT"],
					hl = "red",
					sound = "[defense]",
				},
			},
		},
		{ -- 黑暗之霰
			spells = {
				{432565},
			},
			options = {				
				{ -- 计时条 黑暗之霰
					category = "AlertTimerbar",
					type = "cast",
					spellID = 432565,
					color = {.2, .4, 1},
					sound = "[mindstep]cast",
				},
				{ -- 对我施法图标 黑暗之霰
					category = "AlertIcon",
					type = "com",
					spellID = 432565,
					hl = "yel_flash",
					sound = "[mindstep]cast",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
			},
		},
		{ -- 黑暗潮涌
			spells = {
				{431304},
			},
			options = {				
				{ -- 计时条 黑暗潮涌
					category = "AlertTimerbar",
					type = "cast",
					spellID = 431304,
					color = {.32, .64, 1},
					sound = "[aoe]cast",
					glow = true,
				},
			},
		},
		{ -- 战略家之怒
			spells = {
				{451112},
			},
			options = {
				{ -- 姓名板施法 战略家之怒
					category = "PlateAlert",
					type = "PlateSpells",
					spellID = 451112,
				},
				{ -- 姓名板光环 战略家之怒
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 451112,
					hl_np = true,
				},
			},
		},
		{ -- 折磨射线
			spells = {
				{431333},
			},
			options = {				
				{ -- 姓名板自动打断图标 折磨射线
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 431333,
					mobID = "213893",
					spellCD = 6,
					ficon = "6",
					hl_np = true,
				},
				{ -- 图标 诱捕暗影
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 431333,
					hl = "org",
					sound = "[defense]"
				},
			},
		},
		{ -- 深渊轰击
			spells = {
				{451119},
			},
			options = {				
				{ -- 对我施法图标 深渊轰击
					category = "AlertIcon",
					type = "com",
					spellID = 451119,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 深渊轰击
					category = "RFIcon",
					type = "Cast",
					spellID = 451119,
				},
				{ -- 图标 深渊轰击
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 451119,
					tip = L["强力DOT"],	
					hl = "red",
					sound = "[defense]"
				},
			},
		},
		{ -- 恐惧猛击
			spells = {
				{451117},
			},
			options = {				
				{ -- 计时条 恐惧猛击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451117,
					color = {.64, .76, 1},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 晦影腐朽
			spells = {
				{451102},
			},
			options = {				
				{ -- 计时条 晦影腐朽
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451102,
					color = {.55, .38, .69},
					text = L["全团AE"],
					sound = "[aoe]cast",
				},
			},
		},
		{ -- 折磨喷发
			spells = {
				{431350},
			},
			options = {
				{ -- 计时条 折磨喷发
					category = "AlertTimerbar",
					type = "cast",
					spellID = 431349,
					color = {.54, 0, .89},
					text = L["分散"],
					sound = "[spread]cast",
					glow = true,
				},
				{ -- 图标 折磨喷发
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 431350,
					hl = "red",
					tip = L["分散"],
				},
			},
		},
		{ -- 暗黑法球
			spells = {
				{450854},
			},
			options = {
				{ -- 计时条 暗黑法球
					category = "AlertTimerbar",
					type = "cast",
					spellID = 450854,
					color = {.54, 0, .89},
					text = L["大球"],
					sound = "[ball]cast",
					glow = true,
				},
				{ -- 声音 暗黑法球[音效:注意射线]（✓）
					category = "Sound",
					spellID = 450855,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = "[ray]",
				},
			},
		},
	},
}