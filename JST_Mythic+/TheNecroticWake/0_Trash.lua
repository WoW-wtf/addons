local T, C, L, G = unpack(JST)

G.Encounter_Order[1182] = {2395, 2391, 2392, 2396, "1182Trash"}

local function soundfile(filename)
	return string.format("[1182\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters["1182Trash"] = {
	map_id = 2286,
	alerts = {	
		{ -- 释放的心能
			spells = {
				{328399},
			},
			options = {
				{ -- 图标 释放的心能
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "player",
					spellID = 328399,		
					hl = "gre",
				},
				{ -- 计时条 释放的心能
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 328404,
					dur = 8,
					color = {.69, 1, 1},
					text = L["打断"],
				},
			},
		},
		{ -- 染血长枪
			spells = {
				{328392},
			},
			options = {
				{ -- 图标 染血长枪
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "player",
					spellID = 328392,		
					hl = "gre",
				},
				{ -- 计时条 染血长枪
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 328351,
					dur = 16,
					color = {1, .9, .61},
					text = L["易伤"],
				},
			},
		},
		{ -- 被遗忘的铸锤
			spells = {
				{328126},
			},
			options = {
				{ -- 图标 被遗忘的铸锤
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "player",
					spellID = 328126,		
					hl = "gre",
				},
				{ -- 计时条 被遗忘的铸锤
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 328128,
					dur = 8,
					color = {1, .84, .58},
					text = L["昏迷"],
				},
			},
		},
		{ -- 被遗弃的盾牌
			spells = {
				{325189},
			},
			options = {
				{ -- 图标 被遗弃的盾牌
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "player",
					spellID = 325189,		
					hl = "gre",
				},
				{ -- 计时条 被遗弃的盾牌
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 328050,
					dur = 6,
					color = {.98, 1, .83},
					text = L["减伤"],
				},
			},
		},
		{ -- 排干体液
			spells = {
				{334748},
			},
			options = {
				{ -- 姓名板自动打断图标 排干体液
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 334748,
					mobID = "173016,166302,173044",
					spellCD = 15,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 投掷血肉
			spells = {
				{334747},
			},
			options = {
				{ -- 对我施法图标 投掷血肉
					category = "AlertIcon",
					type = "com",
					spellID = 334747,
					spellIDs = {[338653] = true},
					hl = "yel_flash",
				},
				{ -- 团队框架图标 投掷血肉
					category = "RFIcon",
					type = "Cast",
					spellID = 334747,
					spellIDs = {[338653] = true,}
				},
			},
		},
		{ -- 作呕喷吐
			spells = {
				{321821},
			},
			options = {
				{ -- 图标 作呕喷吐
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 321821,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 切肉飞刀
			spells = {
				{323496},
			},
			options = {
				{ -- 对我施法图标 切肉飞刀
					category = "AlertIcon",
					type = "com",
					spellID = 323496,
					spellIDs = {[338653] = true},
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},				
				{ -- 团队框架图标 切肉飞刀
					category = "RFIcon",
					type = "Cast",
					spellID = 323496,
				},
				{ -- 图标 切肉飞刀
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 323471,
					hl = "org_flash",
					tip = L["箭头"],
				},
			},
		},
		{ -- 修复血肉
			spells = {
				{327127},
			},
			options = {
				{ -- 姓名板自动打断图标 修复血肉
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 327127,
					mobID = "165872",
					spellCD = 16,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 严酷命运
			spells = {
				{327393},
			},
			options = {
				{ -- 对我施法图标 严酷命运
					category = "AlertIcon",
					type = "com",
					spellID = 327393,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},
				{ -- 团队框架图标 严酷命运
					category = "RFIcon",
					type = "Cast",
					spellID = 327393,
				},
				{ -- 图标 严酷命运
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 327396,
					hl = "org",
					tip = L["离开人群"].."+"..L["强力DOT"],
				},
			},
		},
		{ -- 暗影之井
			spells = {
				{320464},
			},
			options = {
				{ -- 计时条 暗影之井
					category = "AlertTimerbar",
					type = "cast",
					spellID = 320464,
					color = {.07, .74, .55},
					sound = "[mindstep]cast"
				},
			},
		},
		{ -- 白骨剥离
			spells = {
				{321807},
			},
			options = {
				{ -- 姓名板NPC高亮 佐尔拉姆斯刻骨者
					category = "PlateAlert",
					type = "PlateNpcID",
					mobID = "163619",
				},
				{ -- 图标 白骨剥离
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 321807,
					hl = "yel",
					tip = L["降低血量"].."%s15%",
				},
			},
		},
		{ -- 刺耳尖啸
			spells = {
				{324293},
			},
			options = {
				{ -- 姓名板自动打断图标 刺耳尖啸
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 324293,
					mobID = "165919",
					spellCD = 30,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 恐怖顺劈
			spells = {
				{324323},
			},
			options = {
				{ -- 计时条 恐怖顺劈
					category = "AlertTimerbar",
					type = "cast",
					spellID = 324323,
					color = {1, .9, .63},
					sound = "[avoidfront]cast"
				},
			},
		},
		{ -- 碎骨之盾
			spells = {
				{343470},
			},
			options = {
				{ -- 计时条 碎骨之盾
					category = "AlertTimerbar",
					type = "cast",
					spellID = 343470,
					color = {.72, .86, .3},
					sound = "[target]cast"
				},
				{ -- 姓名板光环 碎骨之盾
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 343470,
					hl_np = true,
				},
			},
		},
		{ -- 分离血肉
			spells = {
				{338636},
			},
			options = {
				{ -- 对我施法图标 分离血肉
					category = "AlertIcon",
					type = "com",
					spellID = 338636,
					hl = "yel_flash",
					ficon = "0",
				},
			},
		},
		{ -- 病态凝视
			spells = {
				{338606},
			},
			options = {
				{ -- 对我施法图标 病态凝视
					category = "AlertIcon",
					type = "com",
					spellID = 338606,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},
				{ -- 团队框架图标 病态凝视
					category = "RFIcon",
					type = "Cast",
					spellID = 338606,
				},
				{ -- 图标 病态凝视
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 338606,
					hl = "yel_flash",
					tip = L["锁定"],
				},
			},
		},
		{ -- 暴捶
			spells = {
				{338357},
			},
			options = {
				{ -- 对我施法图标 暴捶
					category = "AlertIcon",
					type = "com",
					spellID = 338357,
					hl = "yel_flash",
					ficon = "0",
				},
				{ -- 图标 暴捶
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 338357,
					hl = "",
					tip = L["易伤"].."%s12%",
				},
			},
		},
		{ -- 毁伤
			spells = {
				{338456},
			},
			options = {
				{ -- 对我施法图标 毁伤
					category = "AlertIcon",
					type = "com",
					spellID = 338456,
					hl = "yel_flash",
					ficon = "0",
				},
			},
		},
		{ -- 内脏切割
			spells = {
				{333477},
			},
			options = {
				{ -- 计时条 内脏切割
					category = "AlertTimerbar",
					type = "cast",
					spellID = 333477,
					color = {.76, .2, .16},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 吐疫
			spells = {
				{333479},
				{333485},
			},
			options = {
				{ -- 对我施法图标 吐疫
					category = "AlertIcon",
					type = "com",
					spellID = 333479,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},
				{ -- 图标 疾病之云
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 333485,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
	},
}