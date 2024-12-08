local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1268\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2566] = {
	engage_id = 2816,
	npc_id = {"209230"},
	alerts = {
		{ -- 不稳定电荷
			spells = {
				{420739, "5"},
			},
			options = {
				{ -- 对我施法图标 不稳定电荷
					category = "AlertIcon",
					type = "com",
					spellID = 420739,
					hl = "yel_flash",
					ficon = "5",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
				{ -- 图标 不稳定电荷
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 420739,
					hl = "org_flash",
				},
			},
		},
		{ -- 闪电涌流
			spells = {
				{444250, "4,7"},
			},
			options = {
				{ -- 能量
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "209230",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(444250)..string.format(L["能量2"], 100)},
						},
					},	
				},
			},
		},
		{ -- 闪电疾冲
			spells = {
				{419871},
			},
			options = {
				{ -- 对我施法图标 闪电疾冲
					category = "AlertIcon",
					type = "com",
					spellID = 419870,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
			},
		},
		{ -- 闪电链
			spells = {
				{424148},
			},
			options = {
				{ -- 计时条 闪电链
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424148,
					color = {.02, .27, .67},
				},
			},
		},
		{ -- 风暴之心
			spells = {
				{444324},
			},
			options = {
				{ -- 计时条 风暴之心
					category = "AlertTimerbar",
					type = "cast",
					spellID = 444324,
					color = {.53, .77, 1},
				},
			},
		},
	},
}