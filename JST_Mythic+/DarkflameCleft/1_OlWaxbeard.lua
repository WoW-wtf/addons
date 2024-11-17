local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1210\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2569] = {
	engage_id = 2829,
	npc_id = {"210149", "210153"},
	alerts = {
		{ -- 驱“烛”外敌
			spells = {
				{421875},
			},
			options = {
				{ -- 图标 粗制武器
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443694,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 卑鄙“轨”术
			spells = {
				{428268},
			},
			options = {
				
			},
		},
		{ -- 鲁莽冲锋
			spells = {
				{422150, "5"},
			},
			options = {
				{ -- 计时条 鲁莽冲锋
					category = "AlertTimerbar",
					type = "cast",
					spellID = 422150,
					color = {.93, .75, .84},
					ficon = "5",
					show_tar = true,
					sound = "[charge]cast",
				},
				{ -- 对我施法图标 鲁莽冲锋
					category = "AlertIcon",
					type = "com",
					spellID = 422150,
					hl = "yel_flash",
					ficon = "5",
					msg = {str_applied = "%name %spell"},
				},
			},
		},
		{ -- 诱引烛焰
			spells = {
				{422162, "2"},
			},
			options = {
				{ -- 计时条 诱引烛焰
					category = "AlertTimerbar",
					type = "cast",
					spellID = 421816,
					color = {1, .06, .04},
					show_tar = true,
				},
				{ -- 对我施法图标 诱引烛焰
					category = "AlertIcon",
					type = "com",
					spellID = 421816,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},
				{ -- 图标 诱引烛焰
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 421816,
					hl = "org_flash",
					tip = L["锁定"],
				},
			},
		},
		{ -- 穿岩凿
			spells = {
				{422245, "0"},
			},
			options = {
				{ -- 对我施法图标 穿岩凿
					category = "AlertIcon",
					type = "com",
					spellID = 422245,
					hl = "yel_flash",
					ficon = "0",
				},
				{ -- 图标 穿岩凿
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 422245,
					hl = "",
					tip = L["易伤"].."25%",
				},
			},
		},
	},
}