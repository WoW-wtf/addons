local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1274\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2600] = {
	engage_id = 2905,
	npc_id = {"216320"},
	alerts = {
		{ -- 黏稠黑暗
			spells = {
				{441216, "5"},
			},
			options = {
				{ -- 计时条 黏稠黑暗
					category = "AlertTimerbar",
					type = "cast",
					spellID = 441289,
					spellIDs = {[447146] = true},
					color = {1, .47, .57},
					text = L["击退"],
					sound = "[knockback]cast"
				},
				{ -- 图标 腐化附层
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 442285,
					effect = 1,
					tip = L["吸收治疗"],
					sound = "[move]"
				},
			},
		},
		{ -- 溢流猛击
			spells = {
				{461842, "0"},
			},
			options = {				
				{ -- 对我施法图标 贪食撕咬
					category = "AlertIcon",
					type = "com",
					spellID = 461842,
					spellIDs = {[461989] = true},
					hl = "yel_flash",
					ficon = "0",
				},
				{ -- 图标 溢流猛击
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 461842,
					spellIDs = {[461989] = true},
					tip = L["致死"].."30%",
				},
			},
		},
		{ -- 血之激涌
			spells = {
				{461880},
			},
			options = { 
				{ -- 计时条 血之激涌
					category = "AlertTimerbar",
					type = "cast",
					spellID = 461880,
					color = {.65, .28, .83},
					text = L["远离"],
					sound = "[away]cast"
				},
				{ -- 图标 黑血
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 445435,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 黑暗脉动
			spells = {
				{437533, "2"},
			},
			options = {
				{ -- 能量
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "216320",
						ranges = {
							{ ul = 99, ll = 90, tip = L["全团AE"]..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 黑暗脉动
					category = "AlertTimerbar",
					type = "cast",
					spellID = 441395,
					color = {.68, .38, 1},
					ficon = "2",
					text = L["全团AE"],
					sound = "[aoe]cast"
				},
			},
		},
	},
}