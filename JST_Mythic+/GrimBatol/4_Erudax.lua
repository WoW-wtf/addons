local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[71\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2619] = {
	engage_id = 1049,
	npc_id = {"40484"},
	alerts = {
		{ -- 暗影飓风
			spells = {
				{449939, "5"},
			},
			options = {
				{ -- 计时条 暗影飓风
					category = "AlertTimerbar",
					type = "cast",
					spellID = 449939,
					color = {.29, .09, 1},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
				{ -- 图标 暗影飓风
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 461513,
					spellIDs = {[449985] = true,},
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 深渊腐蚀
			spells = {
				{448064},
			},
			options = {
				{ -- 计时条 深渊腐蚀
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448057,
					color = {.76, .18, .97},
					text = L["分散"],
					sound = "[spread]cast",
				},
				{ -- 图标 深渊腐蚀
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 448057,
					hl = "org_flash",
					tip = L["炸弹"],
					sound = "[defense]",
					msg = {str_applied = "%name %spell", str_rep = "%dur"},
				},
			},
		},
		{ -- 虚空涌动
			spells = {
				{450077},
			},
			npcs = {
				{29619},
			},
			options = {
				{ -- 计时条 虚空涌动
					category = "AlertTimerbar",
					type = "cast",
					spellID = 450077,
					color = {.22, .73, .85},
					text = L["全团AE"],
					sound = "[aoe]cast",
				},
			},
		},
		{ -- 虚空灌输
			spells = {
				{450088},
			},
			npcs = {
				{29623},
			},
			options = {
				{ -- 计时条 虚空涌动
					category = "AlertTimerbar",
					type = "cast",
					spellID = 450088,
					color = {.71, .17, .67},
					text = L["召唤小怪"],
					sound = "[add]cast",
				},
				{ -- 图标 暗影之伤
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 456719,
					hl = "",
					tip = L["易伤"].."%s5%",
					sound = "[defense]",
				},
			},
		},
		{ -- 碾碎
			spells = {
				{450100, "0"},
			},
			options = {
				{ -- 对我施法图标 碾碎
					category = "AlertIcon",
					type = "com",
					spellID = 450100,
					hl = "yel_flash",
					tip = L["击退"],
					ficon = "0",
					sound = "[knockback]cast",
				},
			},
		},
	},
}
 