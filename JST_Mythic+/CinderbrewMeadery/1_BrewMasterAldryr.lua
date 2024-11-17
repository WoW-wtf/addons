local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1272\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2586] = {
	engage_id = 2900,
	npc_id = {"210271"},
	alerts = {
		{ -- 欢乐时光
			spells = {
				{442525, "5"},
			},
			options = {
				{ -- 能量
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "214502",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(442525)..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 图标 不屑一顾
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",					
					spellID = 442611,	
					tip = L["BOSS免疫"],
				},
			},
		},
		{ -- 投掷燧酿
			spells = {
				{432182, "2"},
			},
			options = {
				{ -- 计时条 投掷燧酿
					category = "AlertTimerbar",
					type = "cast",
					spellID = 432182,
					color = {.93, .6, .17},
				},
				{ -- 图标 投掷燧酿
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 432182,	
					tip = L["DOT"],
				},
				{ -- 图标 滚烫蜜糖
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 432196,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 炽热响嗝
			spells = {
				{432198},
			},
			options = {
				{ -- 计时条 炽热响嗝
					category = "AlertTimerbar",
					type = "cast",
					spellID = 432198,
					color = {.84, .19, .03},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 醉酿投
			spells = {
				{432229, "0"},
			},
			options = {
				{ -- 对我施法图标 醉酿投
					category = "AlertIcon",
					type = "com",
					spellID = 432229,
					hl = "yel_flash",
					tip = L["击退"],
					ficon = "0",
					sound = "[knockback]cast",
				},
			},
		},
	},
}