local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1184\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2400] = {
	engage_id = 2397,
	npc_id = {"164567", "164804"},
	alerts = {
		{ -- 灵魂镣铐
			spells = {
				{321005},
			},
			options = {
				{ -- 图标 灵魂镣铐
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss2",
					spellID = 321006,
					tip = L["心控"],
				},
				{ -- 血量
					category = "TextAlert", 
					type = "hp",
					data = {
						npc_id = "164804",
						ranges = {
							{ ul = 30, ll = 21, tip = L["阶段转换"]..string.format(L["血量2"], 20)},
						},
					},
				},
			},
		},
		{ -- 灵魂之箭
			spells = {
				{323057, "6"},
			},
			options = {
				{ -- 姓名板自动打断图标 灵魂之箭
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 323057,
					mobID = "164567",
					spellCD = 5,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 憎恨之容
			spells = {
				{328756, "7"},
			},
			options = {
				{ -- 计时条 憎恨之容
					category = "AlertTimerbar",
					type = "cast",
					spellID = 328756,
					color = {.62, .92, .9},
					text = L["恐惧"],
				},
				{ -- 图标 憎恨之容
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 328756,
					hl = "blu",
					tip = L["恐惧"],
					ficon = "7",
				},
			},
		},
		{ -- 黑暗之拥
			spells = {
				{323149, "2,5"},
			},
			options = {
				{ -- 计时条 黑暗之拥
					category = "AlertTimerbar",
					type = "cast",
					spellID = 323149,
					color = {.96, .44, .97},
					text = L["BOSS减伤"],
				},
				{ -- 图标 死亡之拥
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 323146,
					tip = L["DOT"],
				},
			},
		},
		{ -- 迷乱花粉
			spells = {
				{323137},
			},
			options = {
				{ -- 计时条 迷乱花粉
					category = "AlertTimerbar",
					type = "cast",
					spellID = 323137,
					color = {.8, .24, 1},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 森林之泪
			spells = {
				{323177},
			},
			options = {
				{ -- 计时条 森林之泪
					category = "AlertTimerbar",
					type = "cast",
					spellID = 323177,
					color = {.38, .73, 1},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
				{ -- 图标 心能泥浆
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 323250,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 宗主之怒
			spells = {
				{323059, "1"},
			},
			options = {
				{ -- 计时条 宗主之怒
					category = "AlertTimerbar",
					type = "cast",
					spellID = 323059,
					color = {.67, .92, .08},
					text = L["BOSS易伤"],
					glow = true,
				},
				{ -- 计时条 宗主之怒
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 323059,
					dur = 15,
					color = {.67, .92, .08},
					text = L["BOSS易伤"],
				},
			},
		},
	},
}