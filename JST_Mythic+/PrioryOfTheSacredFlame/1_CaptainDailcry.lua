local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1267\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2571] = {
	engage_id = 2847,
	npc_id = {"207946"},
	alerts = {
		{ -- 野蛮重殴
			spells = {
				{447439, "5"},
			},
			options = {
				{ -- 吸收盾 野蛮重殴
					category = "BossMod",
					spellID = 447443,
					enable_tag = "everyone",
					name = string.format(L["NAME吸收盾"], T.GetIconLink(447443)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 300},
					events = {
						["UNIT_ABSORB_AMOUNT_CHANGED"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 447443 -- 野蛮重殴
						frame.aura_type = "HELPFUL"
						frame.effect = 1
						
						T.InitAbsorbBar(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAbsorbBar(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAbsorbBar(frame)		
					end,
				},
			},
		},
		{ -- 战斗狂啸
			spells = {
				{424419, "6,11"},
			},
			options = {
				{ -- 计时条 战斗狂啸
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424419,
					color = {1, .95, .68},
					ficon = "6",
				},
			},
		},
		{ -- 掷矛
			spells = {
				{447272, "13"},
			},
			options = {
				{ -- 对我施法图标 掷矛
					category = "AlertIcon",
					type = "com",
					spellID = 447270,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},
				{ -- 团队框架图标 掷矛
					category = "RFIcon",
					type = "Cast",
					spellID = 447270,
				},
				{ -- 图标 掷矛
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 447272,
					hl = "red",
					ficon = "13",
				},
			},
		},
		{ -- 贯穿护甲
			spells = {
				{424414, "0,13"},
			},
			options = {
				{ -- 对我施法图标 贯穿护甲
					category = "AlertIcon",
					type = "com",
					spellID = 424414,
					hl = "yel_flash",
					ficon = "0,13",
				},
				{ -- 图标 贯穿护甲
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 424414,
					hl = "",
					ficon = "13",
				},
			},
		},
		{ -- 艾蕾娜·安博兰兹
			npcs = {
				{27828},
			},
			options = {
				{ -- 计时条 圣光烁辉
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424431,
					color = {.96, .97, .55},
					ficon = "2",
				},
				{ -- 对我施法图标 神圣审判
					category = "AlertIcon",
					type = "com",
					spellID = 448515,
					hl = "yel_flash",
					ficon = "0",
				},
				{ -- 图标 神圣审判
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 448515,
					hl = "",
					tip = L["易伤"].."25%",
				},
				{ -- 计时条 忏悔
					category = "AlertTimerbar",
					type = "cast",
					spellID = 427583,
					color = {.13, .88, .96},
					ficon = "6",
					sound = "[interrupt_cast]cast"
				},
				{ -- 姓名板施法 忏悔
					category = "PlateAlert",
					type = "PlateSpells",
					spellID = 427583,
					hl_np = true,
				},
			},
		},
		{ -- 歇尼麦尔中士
			npcs = {
				{27825},
			},
			options = {
				{ -- 计时条 蛮力重击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424621,
					color = {.87, .77, .68},
					sound = "[mindstep]cast"
				},
				{ -- 对我施法图标 跃进打击
					category = "AlertIcon",
					type = "com",
					spellID = 424423,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},
				{ -- 团队框架图标 跃进打击
					category = "RFIcon",
					type = "Cast",
					spellID = 424423,
				},
				{ -- 图标 跃进打击
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 424426,
					hl = "red",
					ficon = "13",
				},
			},
		},
		{ -- 泰纳·杜尔玛
			npcs = {
				{27831},
			},
			options = {
				{ -- 计时条 余烬风暴
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424462,
					color = {.85, .42, .11},
					sound = "[mindstep]cast"
				},
				{ -- 计时条 余烬冲击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424420,
					color = {.8, .35, .07},
					ficon = "6",
					sound = "[interrupt_cast]cast"
				},
				{ -- 姓名板施法 余烬冲击
					category = "PlateAlert",
					type = "PlateSpells",
					spellID = 424420,
					hl_np = true,
				},
				{ -- 计时条 火球术
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424421,
					color = {1, .82, .21},
					ficon = "6",
				},
			},
		},
	},
}