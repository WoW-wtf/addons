local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1267\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2570] = {
	engage_id = 2835,
	npc_id = {"207939"},
	alerts = {
		{ -- 报偿之怒
			spells = {
				{422969, "5"},
			},
			options = {				
				{ -- 计时条 报偿之怒
					category = "AlertTimerbar",
					type = "cast",
					spellID = 422969,
					color = {1, .82, .3},
					ficon = "5",
					text = L["BOSS强化"],
				},
				{ -- 计时条 报偿之怒
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 424426,					
					dur = 10,					
					color = {1, .82, .3},
					ficon = "5",
					text = L["BOSS强化"],
				},
			},
		},
		{ -- 谴罚者之盾
			spells = {
				{423015},
			},
			options = {
				{ -- 计时条 谴罚者之盾
					category = "AlertTimerbar",
					type = "cast",
					spellID = 423015,
					color = {.91, .85, .49},
					text = L["分散"],
					sound = "[spread]cast",
				},
				{ -- 图标 谴罚者之盾
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 423015,
					tip = L["减速"],	
					hl = "",
				},
			},
		},
		{ -- 灼烧之光
			spells = {
				{423051, "6"},
			},
			options = {
				{ -- 计时条 灼烧之光
					category = "AlertTimerbar",
					type = "cast",
					spellID = 423051,
					color = {.97, .69, .29},
					ficon = "6",
					sound = "[interrupt_cast]cast"
				},
			},
		},
		{ -- 纯洁之锤
			spells = {
				{423062},
			},
			options = {
				{ -- 计时条 纯洁之锤
					category = "AlertTimerbar",
					type = "cast",
					spellID = 423062,
					color = {.93, .84, .94},
					sound = "[mindstep]cast"
				},
			},
		},
		{ -- 献祭葬火
			spells = {
				{446368},
			},
			options = {
				{ -- 计时条 献祭葬火
					category = "AlertTimerbar",
					type = "cast",
					spellID = 446368,
					color = {1, .9, .13},
				},
				{ -- 图标 献祭葬火
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 446403,
					tip = L["DOT"],	
					hl = "",
				},
			},
		},
	},
}