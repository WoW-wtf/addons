local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1182\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2392] = {
	engage_id = 2388,
	npc_id = {"162689"},
	alerts = {		
		{ -- 唤醒造物
			spells = {
				{320358, "5"},
			},
			npcs = {
				{22983},
			},
			options = {
				{ -- 计时条 唤醒造物
					category = "AlertTimerbar",
					type = "cast",
					spellID = 320358,
					color = {.07, .74, .55},
					ficon = "5",
					text = L["召唤小怪"],
					sound = "[add]cast"
				},
				{ -- 计时条 肉钩
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_SUCCESS",					
					spellID = 322681,
					dur = 7,
					tags = {4},
					color = {1, .05, .05},
					ficon = "5",
					show_tar = true,
					sound = "[arrow]",
					glow = true,
				},
				{ -- 图标 肉钩
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 322681,
					hl = "org_flash",
					tip = L["锁定"],
					msg = {str_applied = "%name %spell", str_rep = "%dur"},
				},
				{ -- 对我施法图标 毁伤
					category = "AlertIcon",
					type = "com",
					spellID = 320376,
					hl = "yel_flash",
					ficon = "0",
				},
				{ -- 图标 肉钩
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 322681,
					hl = "org_flash",
					tip = L["锁定"],
					msg = {str_applied = "%name %spell", str_rep = "%dur"},
				},
			},
		},
		{ -- 防腐剂
			spells = {
				{327664},
			},
			options = {
				{ -- 对我施法图标 防腐剂
					category = "AlertIcon",
					type = "com",
					spellID = 327664,
					spellIDs = {[334476] = true,},
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},		
				{ -- 图标 防腐剂
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 320366,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 缝针
			spells = {
				{320200, "13"},
			},
			options = {
				{ -- 对我施法图标 缝针
					category = "AlertIcon",
					type = "com",
					spellID = 320200,
					hl = "yel_flash",
					ficon = "13",
				},
				{ -- 团队框架图标 缝针
					category = "RFIcon",
					type = "Cast",
					spellID = 320200,
				},
				{ -- 图标 缝针
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 320200,
					hl = "",
					tip = L["DOT"],
					ficon = "13",
				},
			},
		},
		{ -- 劈肉
			spells = {
				{334488},
			},
			options = {
				{ -- 对我施法图标 劈肉
					category = "AlertIcon",
					type = "com",
					spellID = 334488,
					hl = "yel_flash",
					ficon = "0",
				},
			},
		},
		{ -- 病态凝视
			spells = {
				{343555},
			},
			options = {
				{ -- 对我施法图标 病态凝视
					category = "AlertIcon",
					type = "com",
					spellID = 343556,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},
				{ -- 团队框架图标 病态凝视
					category = "RFIcon",
					type = "Cast",
					spellID = 343556,
				},
				{ -- 图标 病态凝视
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 343556,
					hl = "yel_flash",
					tip = L["锁定"],
				},
			},
		},
		{ -- 逃脱
			spells = {
				{320359},
			},
			options = {
				{ -- 计时条 逃脱
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_REMOVED",
					spellID = 326629,
					display_spellID = 320359,
					dur = 31,
					color = {1, .88, .03},
					icon_tex = 132307,
					text = L["阶段转换"],
				},
			},
		},
	},
}