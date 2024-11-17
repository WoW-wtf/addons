local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[71\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2618] = {
	engage_id = 1048,
	npc_id = {"40319", "40320"},
	alerts = {
		{ -- 暗影烈焰祈祷
			spells = {
				{448013, "5"},
			},
			options = {
				{ -- 计时条 暗影烈焰祈祷
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448013,
					color = {1, .34, .33},
					ficon = "5",
					sound = "[add]cast",
				},
				{ -- 姓名板法术来源图标 烈焰凝视
					category = "PlateAlert",
					type = "PlayerAuraSource",
					aura_type = "HARMFUL",
					spellID = 82850,
					hl_np = true,
				},
			},
		},
		{ -- 熵能诅咒
			spells = {
				{450095, "8"},
			},
			options = {
				{ -- 计时条 熵能诅咒
					category = "AlertTimerbar",
					type = "cast",
					spellID = 450095,
					color = {.93, .55, .98},
					ficon = "8",
				},
				{ -- 图标 熵能诅咒
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 450095,
					effect = 1,
					hl = "pur",
					tip = L["吸收治疗"],
					ficon = "8",
				},
			},
		},
		{ -- 暗影烈焰箭
			spells = {
				{447966},
			},
			options = {
				{ -- 姓名板自动打断图标 暗影烈焰箭
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 447966,
					mobID = "40319",
					spellCD = 5,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 暮光打击
			spells = {
				{456751},
			},
			options = {
				{ -- 计时条 暮光打击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 456751,
					color = {.49, .75, .85},
					text = L["全团AE"].."+"..L["击退"],
					sound = "[knockback]cast",
				},
				{ -- 图标 暮光之风
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 456773,
					hl = "",
					tip = L["减速"].."20%",
				},
			},
		},
		{ -- 噬体烈焰
			spells = {
				{448105},
			},
			options = {
				{ -- 计时条 噬体烈焰
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448105,
					color = {.63, .07, 1},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
	},
}