local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1269\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2572] = {
	engage_id = 2854,
	npc_id = {"210108"},
	alerts = {
		{ -- 不稳定尖刺
			spells = {
				{424903},
			},
			options = {
				{ -- 计时条 不稳定尖刺
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424903,
					color = {.96, .5, .14},
					sound = "[mindstep]cast",
				},
				{ -- 图标 不稳定的爆炸
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 424913,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 折光射线
			spells = {
				{424805},
			},
			options = {
				{ -- 图标 折光射线
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 424795,
					hl = "red",
					tip = L["射线"],
				},
			},
		},
		{ -- 大地破裂
			spells = {
				{424879},
			},
			options = {
				{ -- 能量 大地破裂 倒计时
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "210108",
						ranges = {
							{ ul = 99, ll = 90, tip = L["全团AE"]..string.format(L["能量2"], 100)},
						},
					},	
				},
				{ -- 计时条 大地破裂
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424879,
					color = {.91, .69, .35},
					sound = "[aoe]cast",
				},
			
			},
		},
		{ -- 震地猛击
			spells = {
				{424888, "0"},
			},
			options = {
				{ -- 计时条 震地猛击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424888,
					color = {1, .3, .2},
					ficon = "2,7",
					sound = "[prepare_dispel]cast",
				},
				{ -- 对我施法图标 震地猛击
					category = "AlertIcon",
					type = "com",
					spellID = 424888,
					hl = "yel_flash",
					ficon = "0",
				},
				{ -- 图标 震地回响
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 424889,
					tip = L["DOT"],
					ficon = "7",
				},
				{ -- 图标 石盾
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 424893,
					tip = L["减伤"],
				},
			},
		},
	},
}