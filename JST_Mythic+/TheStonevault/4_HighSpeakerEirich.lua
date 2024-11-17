local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1269\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2582] = {
	engage_id = 2883,
	npc_id = {"213119"},
	alerts = {
		{ -- 虚空腐蚀
			spells = {
				{427329},
			},
			options = {
				{ -- 图标 虚空腐蚀
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 427329,
					tip = L["DOT"],
				},
			},
		},
		{ -- 熵能清算
			spells = {
				{427854},
			},
			options = {
				{ -- 计时条 熵能清算
					category = "AlertTimerbar",
					type = "cast",
					spellID = 427852,
					color = {.31, .26, 1},
				},
				{ -- 图标 熵灭
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 457465,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 无拘虚空
			spells = {
				{427869},
			},
			options = {
				{ -- 计时条 无拘虚空
					category = "AlertTimerbar",
					type = "cast",
					spellID = 427869,
					color = {.81, .44, .81},
					sound = "[dodge]cast",
				},
			},
		},
	},
}