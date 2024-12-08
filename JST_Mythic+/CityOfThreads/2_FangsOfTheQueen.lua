local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1274\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2595] = {
	engage_id = 2908,
	npc_id = {"216648", "216649"},
	alerts = {
		{ -- 协同步法
			spells = {
				{439522, "5"},
			},
			options = {
				{ -- 能量
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "216648",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(439522)..string.format(L["能量2"], 100)},
						},
					},	
				},
				{ -- 能量
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "216649",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(439522)..string.format(L["能量2"], 100)},
						},
					},	
				},
				{ -- 计时条 协同步法
					category = "AlertTimerbar",
					type = "cast",
					spellID = 441381,
					color = {.69, .28, .76}, 
				},
				{ -- 计时条 协同步法
					category = "AlertTimerbar",
					type = "cast",
					spellID = 441384,
					color = {.69, .28, .76}, 
				},
			},
		},
		{ -- 恩克斯 邃影斩
			npcs = {
				{28887},
			},
			spells = {
				{439621, "0"},
			},
			options = {
				{ -- 计时条 邃影斩
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439621,
					color = {.55, .68, .9},
					text = L["冲击波"],
					sound = "[dodge]cast", 
				},
			},
		},
		{ -- 恩克斯 暮落
			npcs = {
				{28887},
			},
			spells = {
				{439692},
			},
			options = {
				{ -- 计时条 暮落
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439692,
					color = {.86, .62, .99},
					text = L["躲地板"],
					sound = "[mindstep]cast", 
				},
				{ -- 图标 暮落
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 439692,
					tip = L["DOT"],
					hl = "",
				},
			},
		},
		{ -- 维克斯 寒冰镰刀
			npcs = {
				{28884},
			},
			spells = {
				{440238, "7"},
			},
			options = {
				{ -- 计时条 寒冰镰刀
					category = "AlertTimerbar",
					type = "cast",
					spellID = 440218,
					color = {.1, .72, .98},
					text = L["分散"],
					sound = "[spread]cast", 
				},
				{ -- 图标 寒冰镰刀
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 440238,
					tip = L["减速"].."+"..L["DOT"],
					hl = "blu",
					ficon = "7",
				},
			},
		},		
		{ -- 维克斯 霜凝匕首
			npcs = {
				{28884},
			},
			spells = {
				{440468, "0"},
			},
			options = {
				{ -- 计时条 霜凝匕首
					category = "AlertTimerbar",
					type = "cast",
					spellID = 440468,
					color = {.57, .92, .99},
					text = L["分担伤害"],
					sound = "[sharedmg]cast", 
				},
				{ -- 图标 冰冻之血
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 441298,
					tip = L["DOT"],
				},
			},
		},
		{ -- 飞刀投掷
			spells = {
				{440107},
			},
			options = {
				{ -- 对我施法图标 飞刀投掷
					category = "AlertIcon",
					type = "com",
					spellID = 440107,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 飞刀投掷
					category = "RFIcon",
					type = "Cast",
					spellID = 440107,
				},
				{ -- 图标 飞刀投掷
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 440107,
					tip = L["DOT"],
				},
			},
		},
	},
}