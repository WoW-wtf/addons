local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[71\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2617] = {
	engage_id = 1051,
	npc_id = {"39625"},
	alerts = {
		{ -- 命令咆哮
			spells = {
				{448847, "5"},
			},
			npcs = {
				{29581},
			},
			options = {
				{ -- 计时条 命令咆哮
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448847,
					color = {.89, .35, .18},
					ficon = "5",
					text = L["全团AE"],
					sound = "[aoe]cast"
				},
				{ -- 计时条 暗影烈焰吐息
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_SUCCESS",
					spellID = 448847,
					display_spellID = 448566,
					dur = 6,
					tags = {5},
					color = {.34, .24, .95},
					ficon = "5",
					text = L["躲地板"],
					sound = "[mindstep]cast"
				},
			},
		},
		{ -- 突岩尖刺
			spells = {
				{448882},
			},
			options = {
				{ -- 计时条 突岩尖刺
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448877,
					color = {.7, .61, .49},
					text = L["炸弹"],
				},
				{ -- 图标 突岩尖刺
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 448870,
					tip = L["分散"],
					sound = "[spread]",
				},
				{ -- 图标 滚石
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 448953,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 碎颅打击
			spells = {
				{447261, "0,13"},
			},
			options = {
				{ -- 对我施法图标 碎颅打击
					category = "AlertIcon",
					type = "com",
					spellID = 447261,
					hl = "yel_flash",
					ficon = "0,13",
				},
				{ -- 图标 碎颅打击
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 447268,
					tip = L["DOT"],
					ficon = "13",
				},
			},
		},
	},
}