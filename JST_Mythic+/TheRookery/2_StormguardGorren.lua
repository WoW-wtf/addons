local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1268\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2567] = {
	engage_id = 2861,
	npc_id = {"207205"},
	alerts = {
		{ -- 混沌腐蚀
			spells = {
				{424737, "5"},
			},
			options = {
				{ -- 对我施法图标 混沌腐蚀
					category = "AlertIcon",
					type = "com",
					spellID = 424737,
					hl = "yel_flash",
				},
				{ -- 图标 混沌腐蚀
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 424739,
					hl = "org_flash",
					msg = {str_applied = "%name %spell", str_rep = "%dur"},
				},
				{ -- 图标 混沌脆弱
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 424797,
					tip = L["易伤"].."100%",
				},
			},
		},
		{ -- 黑暗引力
			spells = {
				{425048, "4"},
			},
			options = {
				{ -- 计时条 黑暗引力
					category = "AlertTimerbar",
					type = "cast",
					spellID = 425048,
					color = {.72, .9, .96},
					ficon = "4",
					text = L["拉人"],
					sound = "[pull]cast",
				},
			},
		},
		{ -- 粉碎现实
			spells = {
				{424958},
			},
			options = {
				{ -- 计时条 粉碎现实
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424958,
					color = {.91, .26, .94},
					sound = "[mindstep]cast",
				},
				{ -- 图标 徘徊虚空
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 424966,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
	},
}