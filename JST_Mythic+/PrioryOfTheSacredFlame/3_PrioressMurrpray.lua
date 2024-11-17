local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1267\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2573] = {
	engage_id = 2848,
	npc_id = {"207940"},
	alerts = {
		{ -- 圣光屏障
			spells = {
				{423588, "5"},
			},
			options = {
				{ -- 吸收盾 圣光屏障
					category = "BossMod",
					spellID = 423588,
					enable_tag = "everyone",
					name = string.format(L["NAME吸收盾"], T.GetIconLink(423588)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 300},
					events = {
						["UNIT_ABSORB_AMOUNT_CHANGED"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 423588 -- 圣光屏障
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
		{ -- 神圣烈焰
			spells = {
				{425544},
			},
			options = {
				{ -- 计时条 神圣烈焰
					category = "AlertTimerbar",
					type = "cast",
					spellID = 425544,
					color = {.98, .98, .71},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
				{ -- 图标 神圣之地
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 425556,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 盲目之光
			spells = {
				{428169},
			},
			options = {
				{ -- 计时条 盲目之光
					category = "AlertTimerbar",
					type = "cast",
					spellID = 428169,
					color = {1, .75, .32},
					text = L["背对BOSS"],
					sound = "[backto]cast",
					glow = true,
				},
			},
		},
		{ -- 心灵之火
			spells = {
				{423539, "2"},
			},
			options = {
				{ -- 计时条 心灵之火
					category = "AlertTimerbar",
					type = "cast",
					spellID = 423539,
					color = {.99, .98, .58},
					text = L["BOSS强化"],
				},
				{ -- 计时条 心灵之火
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 444608,					
					dur = 12,
					tags = {5.2, 10.4},
					color = {.99, .98, .58},
					text = L["BOSS强化"],
				},
			},
		},
		{ -- 神圣烈焰
			spells = {
				{451606, "7"},
			},
			options = {
				{ -- 对我施法图标 神圣烈焰
					category = "AlertIcon",
					type = "com",
					spellID = 451605,
					hl = "yel_flash",
					ficon = "7",
					msg = {str_applied = "%name %spell"},
				},
				{ -- 图标 神圣烈焰
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 451606,
					hl = "blu",
					tip = L["DOT"],
					ficon = "7",
				},
			},
		},
		{ -- 神圣惩击
			spells = {
				{423536, "6"},
			},
			options = {
				{ -- 计时条 神圣惩击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 423536,
					color = {.98, .82, .26},
					ficon = "6",
				},
			},
		},
	},
}