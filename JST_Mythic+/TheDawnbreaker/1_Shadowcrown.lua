local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1270\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2580] = {
	engage_id = 2837,
	npc_id = {"211087"},
	alerts = {
		{ -- 黑暗降临
			spells = {
				{451026, "4,5"},
			},
			options = {
				{ -- 计时条 黑暗降临
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451026,
					color = {1, 0, 0},
					ficon = "4",
					text = L["远离"],
					sound = "[away]cast",
				},
			},
		},
		{ -- 黑曜光束
			spells = {
				{453212},
			},
			options = {
				{ -- 计时条 黑曜光束
					category = "AlertTimerbar",
					type = "cast",
					spellID = 453212,
					color = {.44, .28, .98},
					text = L["射线"],
					sound = "[ray]cast",
				},
			},
		},
		{ -- 塌缩之夜
			spells = {
				{453140},
			},
			options = {
				{ -- 能量
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "211087",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(453140)..string.format(L["能量2"], 100)},
						},
					},	
				},
				{ -- 计时条 塌缩之夜
					category = "AlertTimerbar",
					type = "cast",
					spellID = 453140,
					color = {.87, .72, .96},
					sound = "[away]cast",
				},
				{ -- 图标 塌缩之夜
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 453173,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 燃烧之影
			spells = {
				{426734, "2,7"},
			},
			options = {
				{ -- 对我施法图标 燃烧之影
					category = "AlertIcon",
					type = "com",
					spellID = 426734,
					hl = "yel_flash",
					ficon = "7",
				},
				{ -- 团队框架图标 燃烧之影
					category = "RFIcon",
					type = "Cast",
					spellID = 426734,
				},
				{ -- 图标 燃烧之影
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 426735,
					hl = "blu",
					tip = L["减速"].."+"..L["DOT"],
					ficon = "7",
				},
				{ -- 图标 暗影之幕
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 426736,
					effect = 1,
					tip = L["吸收治疗"],
				},
			},
		},
		{ -- 暗影箭
			spells = {
				{428086, "6"},
			},
			options = {
				{ -- 姓名板自动打断图标 暗影箭
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 428086,
					mobID = "211087",
					spellCD = 5,
					ficon = "6",
				},
			},
		},
	},
}