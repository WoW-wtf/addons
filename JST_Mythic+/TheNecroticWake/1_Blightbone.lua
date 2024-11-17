local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1182\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2395] = {
	engage_id = 2387,
	npc_id = {"162691"},
	alerts = {
		{ -- 深重呕吐 食腐蛆虫
			spells = {
				{320596},
			},
			options = {
				{ -- 对我施法图标 深重呕吐
					category = "AlertIcon",
					type = "com",
					spellID = 320596,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},
				{ -- 团队框架图标 深重呕吐
					category = "RFIcon",
					type = "Cast",
					spellID = 320596,
				},
				{ -- 图标 深重呕吐
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 320596,
					hl = "red",
					tip = L["强力DOT"],
				},
				{ -- 姓名板光环 血肉饕餮
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HARMFUL",
					spellID = 320630,
				},
				{ -- 图标 腐肉爆发
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 320631,
					hl = "red",
					tip = L["强力DOT"],
				},				
			},
		},
		{ -- 恶臭气体
			spells = {
				{328146},
			},
			options = {
				{ -- 图标 恶臭气体
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 320646,
					tip = L["快走开"],
					sound = "[sound_dd]",
				}
			},
		},
		{ -- 嚼碎
			spells = {
				{320655, "0"},
			},
			options = {
				{ -- 对我施法图标 嚼碎
					category = "AlertIcon",
					type = "com",
					spellID = 320655,
					hl = "yel_flash",
					ficon = "0",
				},
			},
		},
	},
}