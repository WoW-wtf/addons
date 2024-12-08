local T, C, L, G = unpack(JST)

G.Encounter_Order[1269] = {2572, 2579, 2590, 2582, "1269Trash"}

local function soundfile(filename)
	return string.format("[1269\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["1269Trash"] = {
	map_id = 2652,
	alerts = {
		{ -- 震地
			spells = {
				{425974},
				{425027},
			},
			options = {
				{ -- 计时条 震地
					category = "AlertTimerbar",
					type = "cast",
					spellID = 425974,
					color = {.9, .64, .35},
					sound = "[aoe]cast",
					glow = true,
				},
				{ -- 计时条 地震波
					category = "AlertTimerbar",
					type = "cast",
					spellID = 425027,
					color = {.6, .43, .23},
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 恐惧咆哮
			spells = {
				{449455},
			},
			options = {
				{ -- 姓名板自动打断图标 恐惧咆哮
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 449455,
					mobID = "212453",
					spellCD = 30,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 虚空感染
			spells = {
				{426308},
			},
			options = {				
				{ -- 图标 虚空感染
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 426308,
					hl = "pur",
					tip = L["DOT"],
					ficon = "8",
				},
			},
		},
		{ -- 暗影爪击
			spells = {
				{459210, "0"},
			},
			options = {
				{ -- 对我施法图标 暗影爪击
					category = "AlertIcon",
					type = "com",
					spellID = 459210,
					hl = "yel_flash",
					ficon = "0",
				},	
			},
		},
		{ -- 虚空爆发
			spells = {
				{426771},
			},
			options = {				
				{ -- 计时条 虚空爆发
					category = "AlertTimerbar",
					type = "cast",
					spellID = 426771,
					color = {.1, .7, 1},
					dur = 6,
					glow = true,
					sound = "[aoe]cast",
				},
			},
		},
		{ -- 震荡跃击
			spells = {
				{427382, "0"},
			},
			options = {
				{ -- 对我施法图标 震荡跃击
					category = "AlertIcon",
					type = "com",
					spellID = 427382,
					hl = "yel_flash",
					ficon = "0",
				},		
			},
		},
		{ -- 穿透哀嚎
			spells = {
				{445207},
			},
			options = {
				{ -- 姓名板自动打断图标 穿透哀嚎
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 445207,
					mobID = "221979",
					spellCD = 13,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 熔岩迫击炮
			spells = {
				{449154},
			},
			options = {
				{ -- 计时条 熔岩迫击炮
					category = "AlertTimerbar",
					type = "cast",
					spellID = 449154,
					color = {.91, .49, .03},
					text = L["大球"],
					sound = "[ball]cast",
					glow = true,
				},
				{ -- 对我施法图标 熔岩迫击炮
					category = "AlertIcon",
					type = "com",
					spellID = 449154,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"}
				},
				{ -- 团队框架图标 熔岩迫击炮
					category = "RFIcon",
					type = "Cast",
					spellID = 449154,
				},
				{ -- 图标 熔岩迫击炮
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 449154,
					hl = "red",
					tip = L["强力DOT"],
					sound = "[defense]",
				},
			},
		},
		{ -- 熔岩重炮
			spells = {
				{449130},
			},
			options = {
				{ -- 计时条 熔岩重炮
					category = "AlertTimerbar",
					type = "cast",
					spellID = 429114,
					spellIDs = {[449130] = true},
					color = {.78, .09, .09},
					glow = true,
					sound = "[orb]cast",
				},			
				{ -- 图标 熔岩重炮
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 449129,
					tip = L["DOT"],
				},
			},
		},
		{ -- 破裂
			spells = {
				{427361},
			},
			options = {
				{ -- 图标 破裂
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 427361,
					tip = L["易伤"].."%s5%",
				},
				{ -- 图标 破裂
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 427361,
					tip = L["易伤"].."%s5%",
				},
			},
		},
		{ -- 愈合金属
			spells = {
				{429109},
			},
			options = {
				{ -- 姓名板自动打断图标 愈合金属
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 429109,
					mobID = "213338,224962",
					spellCD = 8,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 重盾奔袭
			spells = {
				{448640},
			},
			options = {
				{ -- 计时条 重盾奔袭
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448640,
					color = {.78, .09, .09},
					glow = true,
					sound = "[arrow]cast",
				},
			},
		},
		{ -- 巨岩碾压
			spells = {
				{428879},
			},
			options = {
				{ -- 计时条 巨岩碾压
					category = "AlertTimerbar",
					type = "cast",
					spellID = 428879,
					color = {.96, .5, .14},
					text = L["全团AE"],
					sound = "[aoe]cast",
				},
			},
		},
		{ -- 花岗岩爆发
			spells = {
				{428703},
			},
			options = {
				{ -- 计时条 花岗岩爆发
					category = "AlertTimerbar",
					type = "cast",
					spellID = 428703,
					color = {.76, .56, .32},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 爆地图腾
			spells = {
				{429427},
			},
			options = {
				{ -- 计时条 爆地图腾
					category = "AlertTimerbar",
					type = "cast",
					spellID = 429427,
					color = {.76, .73, .52},
					sound = "[totem]cast",
				},
				{ -- 爆地图腾
					category = "PlateAlert",
					type = "PlateNpcID",
					mobID = "214287",
				},
			},
		},
	},
}