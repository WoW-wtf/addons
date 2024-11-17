local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1210\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2561] = {
	engage_id = 2788,
	npc_id = {"208747"},
	alerts = {
		{ -- 扼息暗影
			spells = {
				{422806, "5"},
			},
			options = {
				{ -- 图标 扼息暗影
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 422806,
				},
				{ -- 图标 晦幽骤兴
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 426943,
				},
				{ -- 图标 烛光
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 422807,
				},
			},
		},
		{ -- 永恒黑暗
			spells = {
				{428266, "5"},
			},
			options = {
				{ -- 计时条 永恒黑暗
					category = "AlertTimerbar",
					type = "cast",
					spellID = 428266,
					color = {.51, 0, .73},
					ficon = "5",
					text = L["全团AE"],
					sound = "[aoe]cast",
				},
			},
		},
		{ -- 召唤暗嗣
			spells = {
				{427157, "6"},
			},
			options = {
				{ -- 计时条 召唤暗嗣
					category = "AlertTimerbar",
					type = "cast",
					spellID = 427157,
					color = {.89, .71, .89},
					ficon = "6",
				},
			},
		},
		{ -- 幽影斩击
			spells = {
				{427100},
			},
			options = {
				{ -- 计时条 幽影斩击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 427025,
					color = {.48, .11, .93},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 暗影冲击
			spells = {
				{427011},
			},
			options = {
				{ -- 计时条 暗影冲击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 427011,
					color = {.72, .62, 1},
					show_tar = true,
				},
				{ -- 图标 暗影冲击
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 427015,
					hl = "org_flash",
					msg = {str_applied = "%name %spell"},
				},
			},
		},
	},
}