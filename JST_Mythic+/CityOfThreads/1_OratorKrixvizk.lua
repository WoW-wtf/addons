local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1274\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2594] = {
	engage_id = 2907,
	npc_id = {"216619"},
	alerts = {
		{ -- 压迫之链
			spells = {
				{434710},
			},
			options = {
				{ -- 图标 压迫之链
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 440310,					
					tip = L["靠近"],
					hl = "yel",
					sound = "[getnear]",
				},
			},
		},
		{ -- 压制
			spells = {
				{434722, "0"},
			},
			options = {
				{ -- 计时条 压制
					category = "AlertTimerbar",
					type = "cast",
					spellID = 434722,
					color = {.88, .77, 1},
				},
				{ -- 图标 压制
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 434722,					
					tip = L["减速"],
					hl = "",
				},
			},
		},
		{ -- 惊魂恫吓
			spells = {
				{434779},
			},
			options = {
				{ -- 惊魂恫吓
					category = "AlertTimerbar",
					type = "cast",
					spellID = 434779,
					color = {.87, .56, .95},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 疑之影
			spells = {
				{448561, "7"},
			},			
			options = {
				{ -- 文字 疑之影 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.91, .47, .88},
					preview = T.GetIconLink(448560)..L["倒计时"],
					data = {
						spellID = 448560,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {32,32,32,32,32,32},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 448560, T.GetIconLink(448560), self, event, ...)
					end,
				},
				{ -- 计时条 疑之影
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448560,
					color = {.91, .47, .88},
				},
				{ -- 图标 疑之影
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 448561,					
					tip = L["DOT"],
					hl = "org_flash",
					ficon = "7",
					sound = "[getout]",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
			},
		},
		{ -- 喧神教化
			spells = {
				{434829, "5,2"},
			},
			options = {
				{ -- 能量
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "216619",
						ranges = {
							{ ul = 99, ll = 90, tip = L["全团AE"]..string.format(L["能量2"], 100)},
						},
					},	
				},
				{ -- 计时条 喧神教化
					category = "AlertTimerbar",
					type = "cast",
					spellID = 434829,
					color = {.44, .56, .93},
					ficon = "5,2",
					sound = "[aoe]cast",
				},
				{ -- 图标 残存影响
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 434926,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
	},
}