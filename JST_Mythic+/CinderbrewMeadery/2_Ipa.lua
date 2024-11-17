local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1272\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2587] = {
	engage_id = 2929,
	npc_id = {"210267"},
	alerts = {
		{ -- 喷涌佳酿
			spells = {
				{439365, "5"},
			},
			options = {
				{ -- 计时条 喷涌佳酿
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439365,
					color = {1, .85, .29},
					text = L["全团AE"].."+"..L["躲地板"],
					sound = "[mindstep]cast",
				},
				{ -- 图标 泛涌蜂蜜
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 440087,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 燃烧发酵
			spells = {
				{439202 , "2,7"},
			},
			options = {
				{ -- 计时条 燃烧发酵
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439202,
					color = {.8, .52, .09},
					ficon = "2,7",
					text = L["驱散"],
					sound = "[prepare_dispel]cast",
				},
				{ -- 图标 燃烧发酵
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 439325,
					hl = "blu",
					tip = L["DOT"],
					ficon = "7",
				},
			},
		},
		{ -- 干杯勾拳
			spells = {
				{439031 , "0"},
			},
			options = {
				{ -- 对我施法图标 干杯勾拳
					category = "AlertIcon",
					type = "com",
					spellID = 439031,
					hl = "yel_flash",
					tip = L["击退"],
					ficon = "0",
					sound = "[knockback]cast",
				},
			},
		},
	},
}