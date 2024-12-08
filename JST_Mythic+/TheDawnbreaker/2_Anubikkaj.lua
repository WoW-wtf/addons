local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1270\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2581] = {
	engage_id = 2838,
	npc_id = {"211089"},
	alerts = {
		{ -- 恐惧猛击
			spells = {
				{427001, "0"},
			},
			options = {
				{ -- 计时条 恐惧猛击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 427001,
					color = {.64, .76, 1},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 晦影腐朽
			spells = {
				{426787, "2"},
			},
			options = {
				{ -- 计时条 晦影腐朽
					category = "AlertTimerbar",
					type = "cast",
					spellID = 426787,
					color = {.55, .38, .69},
					text = L["全团AE"],
					sound = "[aoe]cast",
				},
			},
		},
		{ -- 活化暗影
			spells = {
				{452127},
			},
			options = {
				{ -- 对我施法图标 活化暗影
					category = "AlertIcon",
					type = "com",
					spellID = 452127,
					hl = "yel_flash",
					tip = L["召唤小怪"],
					sound = "[add]cast",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
			},
		},
		{ -- 暗黑法球
			spells = {
				{426860},
			},
			options = {
				{ -- 计时条 暗黑法球
					category = "AlertTimerbar",
					type = "cast",
					spellID = 426860,
					color = {.54, 0, .89},
					text = L["大球"],
					sound = "[ball]cast",
					glow = true,
				},
				{ -- 声音 暗黑法球[音效:注意射线]（✓）
					category = "Sound",
					spellID = 450855,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = "[ray]",
				},
			},
		},
	},
}