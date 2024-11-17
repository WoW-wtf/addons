local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1184\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2402] = {
	engage_id = 2392,
	npc_id = {"164501"},
	alerts = {
		{ -- 猜谜游戏
			spells = {
				{321471},
			},
			options = {
				{ -- 文字 猜谜游戏 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.98, .97, .76},
					preview = T.GetIconLink(321471)..L["倒计时"],
					data = {
						spellID = 321471,
						events =  {
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {{47},{60},{60},{60},{60}},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 321471, T.GetIconLink(321471), self, event, ...)
					end,
				},
				{ -- 文字 猜谜游戏 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.3, 1, .73},
					preview = L["阶段转换"]..L["倒计时"],
					data = {
						spellID = 321471,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {7.6, 31.7, 30.1, 29.8},
						sound = "[spread]",
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 438343 then
								self.count = self.count + 1
								if self.data.info[self.count] then
									T.Start_Text_DelayTimer(self, self.data.info[self.count], L["分散"], true)
								end
							end
						elseif event == "ENCOUNTER_START" then
							self.count  = 1
							T.Start_Text_DelayTimer(self, self.data.info[self.count], L["分散"], true)
							if not self.timer_init then
								self.round = true
								self.prepare_sound = string.match(self.data.sound, "%[(.+)%]")
								
								self.timer_init = true
							end
						end
					end,
				},
				{ -- 计时条 猜谜游戏
					category = "AlertTimerbar",
					type = "cast",
					spellID = 336499,
					color = {.3, 1, .73},
					text = L["阶段转换"],
					sound = "[phase]cast",
				},
				{ -- 图标 猜谜游戏
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 336499,
					tip = L["BOSS免疫"],
				},
				{ -- 文字 险恶滋长
					category = "TextAlert",
					type = "spell",
					color = {.78, .87, .91},
					preview = T.GetIconLink(321669).." 115%",
					data = {
						spellID = 321725,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, GUID, _, _, _, _, spellID, _, _, _, amount  = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 321725 then								
								T.Start_Text_Timer(self, 3, T.GetSpellIcon(321669).." 115%")
							elseif sub_event == "SPELL_AURA_APPLIED_DOSE" and spellID == 321725 then
								local perc = string.format(" %d%%", 100 + 15*amount)
								T.Start_Text_Timer(self, 3, T.GetSpellIcon(321669)..perc)
							end
						end
					end,
				},
			},
		},
		{ -- 闪避球
			spells = {
				{321834},
			},
			options = {
				{ -- 计时条 闪避球
					category = "AlertTimerbar",
					type = "cast",
					spellID = 321834,
					color = {.75, .98, .96},
					text = L["箭头"],
					sound = "[arrow]cast",
				},
			},
		},
		{ -- 拍手手
			spells = {
				{321828},
			},
			options = {
				{ -- 对我施法图标 拍手手
					category = "AlertIcon",
					type = "com",
					spellID = 321828,
					hl = "yel_flash",
					tip = L["打断"],
					ficon = "6",
					sound = "[interrupt_cast]",
				},
			},
		},
		{ -- 鬼抓人
			spells = {
				{321873},
			},
			options = {
				{ -- 计时条 鬼抓人
					category = "AlertTimerbar",
					type = "cast",
					spellID = 341709,
					color = {.18, .86, .93},
					text = L["召唤小怪"],
					sound = "[add]cast",
				},
				{ -- 对我施法图标 鬼抓人锁定
					category = "AlertIcon",
					type = "com",
					spellID = 321891,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},
				{ -- 团队框架图标 鬼抓人锁定
					category = "RFIcon",
					type = "Cast",
					spellID = 321891,
				},
			},
		},
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "CLEU",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 336499,
				},
				{
					category = "PhaseChangeData",
					phase = 1,					
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 336499,
				},
			},
		},
	},
}