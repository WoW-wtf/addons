local T, C, L, G = unpack(JST)

G.Encounter_Order[1023] = {2132, 2173, 2134, 2140, "1023Trash"}

local function soundfile(filename)
	return string.format("[1023\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters["1023Trash"] = {
	map_id = 1822,
	alerts = {
		{ -- 抽脸者
			spells = {
				{256627},
			},
			options = {
				{ -- 计时条 炽热响嗝
					category = "AlertTimerbar",
					type = "cast",
					spellID = 256627,
					color = {.61, .85, .98},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 碎牙者
			spells = {
				{256616},
			},
			options = {
				{ -- 图标 碎牙者
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 256616,
					tip = L["减急速"],
					ficon = "0",
				},
			},
		},
		{ -- 盐渍飞弹
			spells = {
				{257063},
			},
			options = {
				{ -- 姓名板自动打断图标 盐渍飞弹
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 257063,
					mobID = "129370",
					spellCD = 8,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 防水甲壳
			spells = {
				{256957},
			},
			options = {
				{ -- 姓名板自动打断图标 防水甲壳
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 256957,
					mobID = "129370",
					spellCD = 30,
					ficon = "6",
					hl_np = true,
				},
				{ -- 姓名板光环 防水甲壳
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HARMFUL",
					spellID = 256957,
					hl_np = true,
				},
			},
		},
		{ -- 火焰炸弹
			spells = {
				{256639},
			},
			options = {
				{ -- 对我施法图标 火焰炸弹
					category = "AlertIcon",
					type = "com",
					spellID = 256639,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
				{ -- 团队框架图标 火焰炸弹
					category = "RFIcon",
					type = "Cast",
					spellID = 256639,
				},
			},
		},
		{ -- 燃烧沥青
			spells = {
				{256640},
			},
			options = {
				{ -- 图标 燃烧沥青
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 256640,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 铁钩
			spells = {
				{272662},
			},
			options = {
				{ -- 计时条 铁钩
					category = "AlertTimerbar",
					type = "cast",
					spellID = 272662,
					color = {.59, 1, .94},
					text = L["拉人"],
					sound = "[pull]cast",
					glow = true,
				},
			},
		},
		{ -- 狂野风暴
			spells = {
				{257170},
			},
			options = {
				{ -- 计时条 狂野风暴
					category = "AlertTimerbar",
					type = "cast",
					spellID = 257170,
					color = {1, .68, .17},
					text = L["近战AOE"],
					sound = "[meleeaoe]cast",
				},
			},
		},
		{ -- 钢刃之歌
			spells = {
				{256709},
			},
			options = {
				{ -- 图标 钢刃之歌
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 256709,
					tip = L["DOT"],
					ficon = "13",
				},
			},
		},
		{ -- 强化怒吼
			spells = {
				{275826},
			},
			options = {
				{ -- 姓名板自动打断图标 防水甲壳
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 275826,
					mobID = "128969",
					spellCD = 30,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 艾泽里特炸药
			spells = {
				{454438},
			},
			options = {
				{ -- 对我施法图标 艾泽里特炸药
					category = "AlertIcon",
					type = "com",
					spellID = 454438,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
				{ -- 团队框架图标 艾泽里特炸药
					category = "RFIcon",
					type = "Cast",
					spellID = 454438,
				},
				{ -- 图标 艾泽里特炸药
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 454437,
					hl = "org_flash",
					tip = L["炸弹"],					
				},
				{ -- 图标 艾泽里特炸药
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 454439,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 诅咒挥砍
			spells = {
				{257168},
			},
			options = {
				{ -- 图标 诅咒挥砍
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 257168,
					hl = "pur",
					tip = L["易伤"].."%s15%",
					ficon = "0,8",
				},
			},
		},
		{ -- 炽热弹头
			spells = {
				{257641},
			},
			options = {
				{ -- 对我施法图标 炽热弹头
					category = "AlertIcon",
					type = "com",
					spellID = 257641,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 炽热弹头
					category = "RFIcon",
					type = "Cast",
					spellID = 257641,
				},
			}, 
		},
		{ -- 瞄准火炮
			spells = {
				{272422},
			},
			options = {
				{ -- 对我施法图标 瞄准火炮
					category = "AlertIcon",
					type = "com",
					spellID = 272422,
					hl = "yel_flash",
					sound = "[mindstep]",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
				{ -- 计时条 瞄准火炮
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 272421,
					dur = 10,
					tags = {4,6,8,10},
					target_me = true,
					color = {.92, .07, .04},
				},
				{ -- 图标 瞄准火炮
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 272421,
					hl = "yel_flash",
					tip = L["锁定"]
				},
			},
		},
		{ -- 舷侧攻击
			spells = {
				{268260},
			},
			options = {
				{ -- 计时条 舷侧攻击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 268260,
					color = {.84, .53, .47},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 腥红横扫
			spells = {
				{268230},
			},
			options = {
				{ -- 对我施法图标 腥红横扫
					category = "AlertIcon",
					type = "com",
					spellID = 268230,
					hl = "yel_flash",
					ficon = "0",
				},
				{ -- 图标 腥红横扫
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 268230,
					hl = "",
					tip = L["易伤"].."%s5%",
					ficon = "0",
				},
			},
		},
		{ -- 恐惧咆哮
			spells = {
				{257169},
			},
			options = {
				{ -- 计时条 恐惧咆哮
					category = "AlertTimerbar",
					type = "cast",
					spellID = 257169,
					color = {.78, .63, .55},
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 碾压重击
			spells = {
				{272711},
			},
			options = {
				{ -- 计时条 碾压重击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 272711,
					color = {1, .84, .58},
					text = L["全团AE"],
					sound = "[aoe]cast "
				},
			},
		},
		{ -- 香蕉狂怒
			spells = {
				{272546},
			},
			options = {
				{ -- 计时条 香蕉狂怒
					category = "AlertTimerbar",
					type = "cast",
					spellID = 272546,
					color = {1, .9, .04},
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 恶臭喷吐
			spells = {
				{454440},
			},
			options = {
				{ -- 图标 恶臭喷吐
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss2",
					spellID = 454440,
					hl = "",
					tip = L["DOT"],
					ficon = "10",
				},
			},
		},
		{ -- 致盲冰雨
			spells = {
				{317898},
			},
			options = {
				{ -- 图标 致盲冰雨
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 317898,
					hl = "",
					tip = L["减速"].."50%",
				},
			},
		},
		{ -- 水箭
			spells = {
				{272581},
			},
			options = {
				{ -- 姓名板自动打断图标 水箭
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 272581,
					mobID = "135241",
					spellCD = 5,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 窒息之水
			spells = {
				{272571},
			},
			options = {
				{ -- 姓名板自动打断图标 窒息之水
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 272571,
					mobID = "135241",
					spellCD = 30,
					ficon = "6",
					hl_np = true,
				},
				{ -- 图标 窒息之水
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 272571,
					hl = "",
					tip = L["沉默"].."+"..L["DOT"],
				},
			},
		},
		{ -- 腐烂伤口
			spells = {
				{272588},
			},
			options = {
				{ -- 图标 腐烂伤口
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 272588,
					hl = "",
					tip = L["致死"].."25%",
					ficon = "10",
				},
			},
		},
		{ -- 射击
			spells = {
				{272528},
			},
			options = {
				{ -- 对我施法图标 射击
					category = "AlertIcon",
					type = "com",
					spellID = 272528,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 射击
					category = "RFIcon",
					type = "Cast",
					spellID = 272528,
				},
			},
		},
		{ -- 锯刃
			spells = {
				{272542},
			},
			options = {
				{ -- 对我施法图标 锯刃
					category = "AlertIcon",
					type = "com",
					spellID = 272542,
					hl = "yel_flash",
					sound = "[defense]",
				},
				{ -- 团队框架图标 锯刃
					category = "RFIcon",
					type = "Cast",
					spellID = 272542,
				},
			},
		},
		{ -- 钉刺之毒
			spells = {
				{275836},
			},
			options = {
				{ -- 图标 钉刺之毒
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 275836,
					hl = "gre",
					tip = L["DOT"],
					ficon = "9",
				},
			},
		},
	},
}