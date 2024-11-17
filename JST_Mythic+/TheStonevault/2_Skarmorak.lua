local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1269\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2579] = {
	engage_id = 2880,
	npc_id = {"210156"},
	alerts = {
		{ -- 加固壳壁
			spells = {
				{423200, "1,5"},
			},
			options = {
				{ -- 计时条 加固壳壁
					category = "AlertTimerbar",
					type = "cast",
					spellID = 423200,
					color = {1, .87, 1},
					glow = true,
				},
				{ -- 吸收盾 加固壳壁
					category = "BossMod",
					spellID = 423228,
					enable_tag = "everyone",
					name = string.format(L["NAME吸收盾"], T.GetIconLink(423228)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 300},
					events = {
						["UNIT_ABSORB_AMOUNT_CHANGED"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 423228 -- 加固壳壁
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
				{ -- 计时条 虚空释能
					category = "AlertTimerbar",
					type = "cast",
					spellID = 423324,
					color = {.66, .1, .8},
					ficon = "2",					
					sound = "[aoe]cast",
					glow = true,
				},
				{ -- 图标 虚空释能
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 423327,
					tip = L["BOSS强化"],
				},
				{ -- 图标 破碎护壳
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 423246,
					tip = L["晕眩"],
				},
			},
		},	
		{ -- 结晶猛击
			spells = {
				{422233, "0"},			
			},
			npcs = {
				{28476},				
			},
			options = {
				{ -- 计时条 结晶猛击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 422233,
					color = {.78, .36, .82},
					sound = "[add]cast",
				},
				{ -- 图标 结晶喷发
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443494,
					tip = L["炸弹"],
				},
			},
		},
		{ -- 无常碾压
			spells = {
				{423538},
			},
			options = {
				{ -- 文字 无常碾压 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.31, .26, 1},
					preview = T.GetIconLink(423538)..L["倒计时"],
					data = {
						spellID = 423538,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {10,20,36,20,33,20},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 423538, T.GetIconLink(423538), self, event, ...)
					end,
				},
				{ -- 计时条 无常碾压
					category = "AlertTimerbar",
					type = "cast",
					spellID = 423538,
					color = {.31, .26, 1},
					sound = "[mindstep]cast",
				},
				{ -- 图标 不稳定的能量
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 423572,
					tip = L["Buff"],
				},
				{ -- 图标 不稳定的能量
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 435813,
					tip = L["DOT"],
				},
			},
		},
	},
}