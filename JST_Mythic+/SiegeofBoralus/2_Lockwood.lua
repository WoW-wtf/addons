local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1023\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2173] = {
	engage_id = 2109,
	npc_id = {"129208"},
	alerts = {
		{ -- 炽烈弹射
			spells = {
				{463182},
			},
			options = {
				{ -- 对我施法图标 炽烈弹射
					category = "AlertIcon",
					type = "com",
					spellID = 463182,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 炽烈弹射
					category = "RFIcon",
					type = "Cast",
					spellID = 463182,
				},
				{ -- 图标 炽烈弹射
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 463182,
					hl = "red",
					tip = L["强力DOT"],
				},
			},
		},
		{ -- 闪避
			spells = {
				{272471, "5"},
				{273470},
			},
			options = {
				{ -- 对我施法图标 一枪毙命
					category = "AlertIcon",
					type = "com",
					spellID = 273470,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 一枪毙命
					category = "RFIcon",
					type = "Cast",
					spellID = 273470,
				},
				{ -- 图标 一枪毙命
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 273470,
					hl = "red",
					tip = L["强力DOT"],
				},
			},
		},
		{ -- 清扫甲板
			spells = {
				{269029},
			},
			options = {
				{ -- 计时条 清扫甲板
					category = "AlertTimerbar",
					type = "cast",
					spellID = 269029,
					color = {1, .85, .09},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 紧急回避
			spells = {
				{268752, "5"},
			},
			options = {
				{ -- 血量
					category = "TextAlert", 
					type = "hp",
					data = {
						npc_id = "129208",
						ranges = {
							{ ul = 72, ll = 67, tip = L["阶段转换"]..string.format(L["血量2"], 66)},
							{ ul = 39, ll = 34, tip = L["阶段转换"]..string.format(L["血量2"], 33)},
						},
					},
				},
			},
		},		
	},
}