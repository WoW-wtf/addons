local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1271\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2584] = {
	engage_id = 2906,
	npc_id = {"215405"},
	alerts = {
		{ -- 虫群之眼
			spells = {
				{433766, "5"},
			},
			options = {
				{ -- 能量
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "215405",
						ranges = {
							{ ul = 99, ll = 90, tip = L["靠近"]..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 虫群之眼
					category = "AlertTimerbar",
					type = "cast",
					spellID = 433766,
					color = {.87, .78, .89},
					glow = true,
					sound = "[getnear]cast",
				},
			},
		},
		{ -- 沾血的网法师
			npcs = {
				{28975},
			},
			options = {
				{ -- 姓名板自动打断图标 流丝束缚
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 442210,
					mobID = "220599",
					spellCD = 7,
					ficon = "6",
					hl_np = true,
				},
				{ -- 图标 流丝束缚
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 442210,
					hl = "",
					tip = L["连线"],					
				},
			},
		},
		{ -- 感染
			spells = {
				{433740, "2"},
				{433747},
			},
			options = {
				{ -- 图标 感染
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 433740,
					hl = "gre",
					tip = L["强力DOT"],
					sound = "[defense]cd3",
				},
				{ -- 图标 无休虫群
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 433781,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 钻地冲击
			spells = {
				{433677},
			},
			options = {
				{ -- 计时条 钻地冲击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439506,
					color = {.5, .75, .34},
					show_tar = true,
					sound = "[charge]cast",
				},
				{ -- 对我施法图标 钻地冲击
					category = "AlertIcon",
					type = "com",
					spellID = 439506,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},				
			},
		},
		{ -- 穿刺
			spells = {
				{433425, "0"},
			},
			options = {
				{ -- 计时条 穿刺
					category = "AlertTimerbar",
					type = "cast",
					spellID = 435012,
					color = {1, .3, 0},
					text = L["冲击波"],		
				},
			},
		},
	},
}