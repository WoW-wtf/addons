local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1274\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------
-- TO DO:球移动倒计时

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2596] = {
	engage_id = 2909,
	npc_id = {"216658"},
	alerts = {
		{ -- 变易异常
			spells = {
				{439401},
			},
			options = {
				{ -- 计时条 变易异常
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439401,
					color = {0, .77, .99},
					text = L["躲球"],
					sound = "[orb]cast"
				},
			},
		},
		{ -- 捻接
			spells = {
				{439341, "2"},
			},
			options = {
				{ -- 计时条 捻接
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439341,
					color = {.91, .55, 1},
					text = L["DOT"],
				},
				{ -- 图标 捻接
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 439341,
					tip = L["DOT"],
				},	
			},
		},
		{ -- 震颤猛击
			spells = {
				{437700, "1"},
			},
			options = {
				{ -- 计时条 震颤猛击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 437700,
					color = {1, .82, .55},
					text = L["注意自保"],
					sound = "[defense]cast",
				},
			},
		},
		{ -- 晦幽纺纱
			spells = {
				{438860, "1"},
			},
			options = {
				{ -- 计时条 晦幽纺纱
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438860,
					color = {.73, .51, .93},
					text = L["定身"],
					sound = "[add]cast",
				},
			},
		},
		{ -- 汰劣程序
			spells = {
				{439646 , "0"},
			},
			options = {
				{ -- 计时条 汰劣程序
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439646,
					color = {.25, .85, .92},
					text = L["远离"],
					sound = "[away]cast",
				},
			},
		},
	},
}