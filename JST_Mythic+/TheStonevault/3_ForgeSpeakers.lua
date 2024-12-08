local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1269\\%s]", filename)
end

--------------------------------Locals--------------------------------
L["离开中场"] = "离开中场"

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2590] = {
	engage_id = 2888,
	npc_id = {"213217", "213216"},
	alerts = {
		{ -- 排放口
			spells = {
				{443954},
			},
			options = {				
				{ -- 文字 排放口 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.85, .41, .07},
					preview = T.GetIconLink(445541)..L["倒计时"],
					data = {
						spellID = 445541,
						events =  {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {35,27,28,24,28,24,28},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss2", 445541, T.GetIconLink(445541), self, event, ...)
					end,
				},
				{ -- 计时条 排放口
					category = "AlertTimerbar",
					type = "cast",
					spellID = 445541,
					dur = 3,
					color = {.85, .41, .07},	
					text = L["全团AE"],
					sound = "[aoe]cast",
				},
				{ -- 图标 排放口
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443954,
					tip = L["DOT"],
				},
				{ -- 图标 烈焰废料
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 429999,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 废料颂
			spells = {
				{428202, "5"},
			},
			options = {
				{ -- 文字 废料颂 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.62, .65, .61},
					preview = T.GetIconLink(428202)..L["倒计时"],
					data = {
						spellID = 428202,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {17,55},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 428202, T.GetIconLink(428202), self, event, ...)
					end,
				},
				{ -- 计时条 废料颂
					category = "AlertTimerbar",
					type = "cast",
					spellID = 428202,
					color = {.62, .65, .61},
					ficon = "5",
					text = L["离开中场"],
					sound = "[nocenter]cast",
				},
			},
		},
		{ -- 熔铁之水
			spells = {
				{428161, "6,7"},
			},
			options = {
				{ -- 姓名板自动打断图标 熔铁之水
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 430097,
					mobID = "213217",
					spellCD = 8,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 炽焰波峰
			spells = {
				{428508, "5"},
			},
			options = {
				{ -- 计时条 炽焰波峰
					category = "AlertTimerbar",
					type = "cast",
					spellID = 428508,
					color = {.79, .03, .09},
					sound = "[defense]channel"
				},
			},
		},
		{ -- 火成岩锤
			spells = {
				{428711, "0"},
			},
			options = {
				{ -- 对我施法图标 火成岩锤
					category = "AlertIcon",
					type = "com",
					spellID = 428711,
					hl = "yel_flash",
					ficon = "0",
				},
			},
		},
		{ -- 熔岩重炮
			spells = {
				{428120},
			},
			options = {
				{ -- 计时条 熔岩重炮
					category = "AlertTimerbar",
					type = "cast",
					spellID = 428120,
					color = {.91, .49, .03},
					text = L["大球"],
					sound = "[ball]cast",
					glow = true,
				},
			},
		},
	},
}