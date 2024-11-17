local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1184\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2405] = {
	engage_id = 2393,
	npc_id = {"164517"},
	alerts = {
		{ -- 凝结毒素
			spells = {
				{463602},
			},
			options = {
				{ -- 计时条 凝结毒素
					category = "AlertTimerbar",
					type = "cast",
					spellID = 463602,
					color = {.78, .86, .24},
					text = L["远离"],
					sound = "[away]cast"
				},
			},
		},
		{ -- 吞噬
			spells = {
				{322450, "6"},
			},
			options = {
				{ -- 吸收盾 暴食护盾
					category = "BossMod",
					spellID = 322527,
					enable_tag = "everyone",
					name = string.format(L["NAME吸收盾"], T.GetIconLink(322527)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 300},
					events = {
						["UNIT_ABSORB_AMOUNT_CHANGED"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 322527 -- 暴食护盾
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
		{ -- 加速孵化
			spells = {
				{322550},
			},
			npcs = {
				{22216},
			},
			options = {
				{ -- 计时条 加速孵化
					category = "AlertTimerbar",
					type = "cast",
					spellID = 322550,
					color = {1, .49, .73},
					text = L["召唤小怪"],
					sound = "[add]cast"
				},
				{ -- 图标 腐烂酸液
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 326309,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 心灵连接
			spells = {
				{322614},
			},
			options = {
				{ -- 计时条 心灵连接
					category = "AlertTimerbar",
					type = "cast",
					spellID = 322614,
					color = {.15, .55, .99},
					text = L["连线"],
					sound = "[chain]cast",
				},
				{ -- 图标 心灵连接
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 331172,
					spellIDs = {[322648] = true,},
					tip = L["连线"],
					sound = "[break]",
				},
			},
		},
		{ -- 被标记的猎物
			spells = {
				{322563},
			},
			options = {				
				{ -- 计时条 被标记的猎物
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 322563,
					dur = 20,
					color = {.93, .09, .01},
					text = L["锁定"],
					show_tar = true,
				},			
				{ -- 图标 被标记的猎物
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 322563,
					tip = L["锁定"],
					sound = "[focus]",
					msg = {str_applied = "%name %spell"},
				},
			},	
		},
		{ -- 酸蚀排放
			spells = {
				{322655},
			},
			options = {
				{ -- 文字 酸蚀排放
					category = "TextAlert",
					type = "spell",
					color = {.78, .87, .91},
					preview = T.GetIconLink(322655).." 1",
					data = {
						spellID = 322655,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local time_stamp, sub_event, _, _, _, _, GUID, _, _, _, _, spellID, _, _, _, amount  = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 322655 then
								if time_stamp - self.time_stamp > 10 then
									self.count = self.count + 1
									self.time_stamp = time_stamp
									T.Start_Text_Timer(self, 3, T.GetSpellIcon(322655).." "..self.count)
								end
							end
						elseif event == "ENCOUNTER_START" then
							self.time_stamp = 0
							self.count = 0
						end
					end,
				},
			},
		},
	},
}