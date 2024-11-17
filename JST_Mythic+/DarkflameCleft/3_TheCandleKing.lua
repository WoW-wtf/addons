local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1210\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2560] = {
	engage_id = 2787,
	npc_id = {"208745"},
	alerts = {
		{ -- 诡谀铸模
			spells = {
				{420659},
			},
			options = {
				{ -- 计时条 诡谀铸模
					category = "AlertTimerbar",
					type = "cast",
					spellID = 420659,
					color = {1, .74, .4},
					text = L["召唤小怪"],
					sound = "[add]cast",
				},
			},
		},
		{ -- 暗焰之锄
			spells = {
				{421277, "5"},
			},
			options = {
				{ -- 计时条 暗焰之锄
					category = "AlertTimerbar",
					type = "cast",
					spellID = 421277,
					color = {.94, 0, .99},
					show_tar = true,
				},
				{ -- 对我施法图标 暗焰之锄
					category = "AlertIcon",
					type = "com",
					spellID = 421277,
					hl = "yel_flash",	
					msg = {str_applied = "%name %spell"},
				},
			},
		},
		{ -- 偏执失心
			spells = {
				{426145, "6,7"},
			},
			options = {
				{ -- 计时条 偏执失心
					category = "AlertTimerbar",
					type = "cast",
					spellID = 426145,
					color = {.95, .6, .83},
					ficon = "6",
				},
				{ -- 图标 偏执失心
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 426145,
					hl = "blu",
					tip = L["恐惧"],
					ficon = "7",
				},
			},
		},
		{ -- 投掷暗焰
			spells = {
				{420696},
			},
			options = {
				{ -- 计时条 投掷暗焰
					category = "AlertTimerbar",
					type = "cast",
					spellID = 426145,
					color = {.56, 0, .89},
				},
				{ -- 图标 投掷暗焰
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 421146,
					effect = 2,
					tip = L["吸收治疗"],
				},
				{ -- 图标 熔化蜡油
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 421067,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
	},
}