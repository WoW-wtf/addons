local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1023\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2132] = {
	engage_id = 2098,
	npc_id = {"128650"},
	alerts = {
		{ -- 上钩了
			spells = {
				{257459, "5"},
			},
			options = {
				{ -- 文字 上钩了 倒计时
					category = "TextAlert",
					type = "spell",
					color = {1, 0, 0},
					preview = L["锁定"]..L["倒计时"],
					data = {
						spellID = 257459,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {1, 31, 21, 24, 33, 19},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 257459, L["锁定"], self, event, ...)
					end,
				},
				{ -- 上钩了
					category = "AlertIcon",
					type = "com",
					spellID = 257459,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
				{ -- 团队框架图标 上钩了
					category = "RFIcon",
					type = "Cast",
					spellID = 257459,
				},
				{ -- 图标 上钩了
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 257459,
					hl = "org_flash",
					tip = L["锁定"],
				},
				{ -- 图标 沸腾之怒
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 257650,
					hl = "",
					tip = L["加速"].."%s2%",
				},
			},
		},
		{ -- 铁钩
			spells = {
				{272662, "5"},
			},
			options = {
				{ -- 计时条 铁钩
					category = "AlertTimerbar",
					type = "cast",
					spellID = 272662,
					color = {.53, .93, .87},
					text = L["拉人"],
					sound = "[pull]cast",
				},
				{ -- 计时条 血腥冲撞
					category = "AlertTimerbar",
					type = "cast",
					spellID = 257326,
					color = {.81, 0, .9},
					text = L["AOE"],
				},
			},
		},
		{ -- 火炮弹幕
			spells = {
				{257585},
			},
			options = {
				{ -- 文字 重型军火 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.67, .92, .08},
					preview = L["炸弹"]..L["倒计时"],
					data = {
						spellID = 273721,
						events =  {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if spellID == 257540 then
								T.Start_Text_DelayTimer(self, 52.5, L["炸弹"])
							end
						end
					end,
				},
				{ -- 计时条 重型军火
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 273721,
					dur = 10,
					color = {.67, .92, .08},
					text = L["BOSS易伤"].."50%",
				},
				{ -- 文字提示 重型军火剩余数量
					category = "TextAlert", 
					type = "spell",
					preview = T.GetIconLink(257540).." 3",
					data = {
						spellID = 257540,
						events = {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 257540 then
								self.count = 3
								self.text:SetText(T.GetIconLink(257540).." "..self.count)
								self:Show()
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 273721 then -- 重型军火
								self.count = self.count - 1
								self.text:SetText(T.GetIconLink(257540).." "..self.count)
								if self.count == 0 then
									self:Hide()
								end
							elseif sub_event == "SPELL_DAMAGE" and (spellID == 273720 or spellID == 280934) then -- 重型军火 damage to player, damage to add
								self.count = self.count - 1
								self.text:SetText(T.GetIconLink(257540).." "..self.count)
								if self.count == 0 then
									self:Hide()
								end
							elseif sub_event == "SPELL_MISSED" and spellID == 273720 then -- 重型军火 missed player
								self.count = self.count - 1
								self.text:SetText(T.GetIconLink(257540).." "..self.count)
								if self.count == 0 then
									self:Hide()
								end
							end
						elseif event == "ENCOUNTER_START" then
							self.count = 0
						end
					end,
				},
			},
		},
		{ -- 铁潮斩杀者
			npcs = {
				{30441, "0"},
			},
			options = {
				{ -- 计时条 沉重挥砍
					category = "AlertTimerbar",
					type = "cast",
					spellID = 257288,
					color = {.69, .73, .73},
					text = L["头前"],
					sound = "[avoidfront]cast",
				},
			},
		},
		{ -- 铁潮斩杀者
			npcs = {
				{30443},
			},
			options = {
				{ -- 团队框架图标 炽热弹头
					category = "RFIcon",
					type = "Cast",
					spellID = 257641,
				},
			},
		},		
	},
}