local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1272\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2588] = {
	engage_id = 2931,
	npc_id = {"218002"},
	alerts = {
		{ -- 点心时间
			spells = {
				{438025},
			},
			npcs = {
				{28853},
			},
			options = {
				{ -- 计时条 点心时间
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438025,
					color = {.87, .67, .56},
				},
				{ -- 图标 碎肉针刺
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 438975,
					tip = L["DOT"],
					ficon = "13",
				},
			},
		},
		{ -- 蜂蜜料汁
			spells = {
				{440134},
			},
			options = {
				{ -- 对我施法图标 蜂蜜料汁
					category = "AlertIcon",
					type = "com",
					spellID = 440134,
					hl = "yel_flash",
					sound = "[mindstep]cast",					
					msg = {str_applied = "%name %spell"},
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
		{ -- 振翼之风
			spells = {
				{439524, "2"},
			},
			options = {
				{ -- 计时条 振翼之风
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439524,
					color = {.54, .99, .9},
					text = L["推人"],
					sound = "[push]cast",
				},
			},
		},
	},
}