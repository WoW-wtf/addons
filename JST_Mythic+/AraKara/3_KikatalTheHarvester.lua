local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1271\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2585] = {
	engage_id = 2901,
	npc_id = {"215407"},
	alerts = {
		{ -- 血工
			npcs = {
				{28411},
			},
			options = {
				 { -- 图标 抓握之血
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 432031,
					hl = "yel",
					tip = L["定身"],
				},
			},
		},
		{ -- 宇宙奇点
			spells = {
				{432117, "4"},
			},
			options = {
				{ -- 能量
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "215407",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(432117)..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 宇宙奇点
					category = "AlertTimerbar",
					type = "cast",
					spellID = 432117,
					color = {0, .49, .95},
					text = L["拉人"],
					sound = "[pull]cast",
				},
			},
		},
		{ -- 毒液箭雨
			spells = {
				{432227},
			},
			options = {
				{ -- 文字 毒液箭雨 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.77, .91, .1},
					preview = T.GetIconLink(432227)..L["倒计时"],
					data = {
						spellID = 432227,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {13.0,29.9,27.9,30.4,24.3,24.3,25.5,26.7,25.5,23.1,24.3,27.9,27.9},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 432227, T.GetIconLink(432227), self, event, ...)
					end,
				},
				{ -- 计时条 毒液箭雨
					category = "AlertTimerbar",
					type = "cast",
					spellID = 432227,
					color = {.77, .91, .1},
					text = L["驱散"],
					sound = "[dispel]cast",
				},
				{ -- 图标 毒液箭雨
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 432227,
					hl = "gre",
					tip = L["强力DOT"],
					ficon = "9",
				},
			},
		},
		{ -- 培植毒药
			spells = {
				{461487, "9"},
			},
			options = {
				{ -- 文字 培植毒药 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.45, .64, .04},
					preview = T.GetIconLink(461487)..L["倒计时"],
					data = {
						spellID = 461487,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {29.6,25.5,35.2,23.2,24.3,26.7,25.5,24.3,25.5,23.0,24.3,32.8,23.1},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 461487, T.GetIconLink(461487), self, event, ...)
					end,
				},
				{ -- 计时条 培植毒药
					category = "AlertTimerbar",
					type = "cast",
					spellID = 461487,
					color = {.45, .64, .04},
					text = L["分散"],
					sound = "[spread]cast",
				},
				{ -- 图标 培植毒药
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 461487,
					hl = "gre",
					tip = L["DOT"],
					ficon = "9",
				},
			},
		},
		{ -- 爆发蛛网
			spells = {
				{432130},
			},
			options = {		
				{ -- 计时条 爆发蛛网
					category = "AlertTimerbar",
					type = "cast",
					spellID = 432130,
					color = {.69, .6, .83},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
	},
}