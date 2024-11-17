local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1272\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2589] = {
	engage_id = 2930,
	npc_id = {"214661"},
	alerts = {
		{ -- 有酿同享！
			spells = {
				{435567},
			},
			options = {
				{ -- 计时条 有酿同享！
					category = "AlertTimerbar",
					type = "cast",
					spellID = 435567,
					color = {.9, .88, .46},
					text = L["炸弹"],
					sound = "[bomb]cast",
				},
				{ -- 图标 燧火创伤
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 435789,
					tip = L["DOT"],
				},
			},
		},
		{ -- 遮天蔽日！
			spells = {
				{435622, "5"},
			},
			options = {
				{ -- 能量
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "214661",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(435622)..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 遮天蔽日！
					category = "AlertTimerbar",
					type = "cast",
					spellID = 435622,
					color = {.89, .44, .48},
					text = L["全团AE"],
					sound = "[aoe]cast",
				},
			},
		},
		{ -- 燃焰弹射
			spells = {
				{436640, "7"},
			},
			options = {
				{ -- 计时条 燃焰弹射
					category = "AlertTimerbar",
					type = "cast",
					spellID = 436637,
					color = {.8, .49, .19},
					ficon = "7",
				},
				{ -- 图标 燃焰弹射
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 436640,
					hl = "blu_flash",
					tip = L["DOT"],
					ficon = "7",
				},
			},
		},
		{ -- 点钞大炮
			spells = {
				{436592, "0"},
			},
			options = {
				{ -- 计时条 点钞大炮
					category = "AlertTimerbar",
					type = "cast",
					spellID = 436592,
					color = {1, .95, .5},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
	},
}