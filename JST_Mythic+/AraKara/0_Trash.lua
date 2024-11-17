local T, C, L, G = unpack(JST)

G.Encounter_Order[1271] = {2583, 2584, 2585, "1271Trash"}

local function soundfile(filename)
	return string.format("[1271\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["1271Trash"] = {
	map_id = 2660,
	alerts = {
		{ -- 伏击
			spells = {
				{434083},
			},
			options = {				
				{ -- 图标 伏击
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 434083,
					hl = "org",
					tip = L["减速"],
				},
			},
		},
		{ -- 放血戳刺
			spells = {
				{438599},
			},
			options = {				
				{ -- 图标 放血戳刺
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 438599,
					hl = "",
					tip = L["DOT"],
				},
				
			},
		},
		{ -- 毒性喷吐
			spells = {
				{438618},
			},
			options = {				
				{ -- 图标 毒性喷吐
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 438618,
					hl = "gre",
					tip = L["DOT"],
					ficon = "9",
				},
			},
		},
		{ -- 共振弹幕
			spells = {
				{434793},
			},
			options = {
				{ -- 姓名板自动打断图标 共振弹幕
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 434793,
					mobID = "216293",
					spellCD = 18,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 惊惧尖鸣
			spells = {
				{434802},
			},
			options = {
				{ -- 计时条 惊惧尖鸣
					category = "AlertTimerbar",
					type = "cast",
					spellID = 434802,
					color = {.98, .94, .7},
					glow = true,
					sound = "[interrupt_cast]cast",
				},
				{ -- 姓名板自动打断图标 惊惧尖鸣
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 434802,
					mobID = "217531",
					spellCD = 24,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 巢穴的召唤
			spells = {
				{438877},
			},
			options = {
				{ -- 计时条 巢穴的召唤
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438877,
					color = {.78, .87, .91},
					sound = "[defense]cast",
				},
				{ -- 文字 巢穴的召唤 倒计时(待修改)
					category = "TextAlert",
					type = "spell",
					color = {.78, .87, .91},
					preview = L["注意自保"]..L["倒计时"],
					data = {
						spellID = 438877,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, GUID, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 438877 then
								T.Start_Text_DelayTimer(self, 30, L["注意自保"], true)
							elseif sub_event == "UNIT_DIED" and GUID then
								local npc_id = select(6, strsplit("-", GUID))
								if npc_id == "218324" then
									T.Stop_Text_Timer(self.text_frame)
								end
							end
						end
					end,
				},
			},
		},
		{ -- 野蛮猛击
			spells = {
				{434252},
			},
			options = {
				{ -- 计时条 野蛮猛击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 434252,
					color = {.99, .64, .25},
					sound = "[defense]cast",
				},
			},
		},
		{ -- 恶臭齐射
			spells = {
				{448248},
			},
			options = {
				{ -- 姓名板NPC高亮 沾血的网法师
					category = "PlateAlert",
					type = "PlateNpcID",
					mobID = "223253",
				},
				{ -- 计时条 恶臭齐射
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448248,
					color = {.57, .94, .78},
					glow = true,
					sound = "[interrupt_cast]cast",
				},
				{ -- 姓名板自动打断图标 恶臭齐射
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 448248,
					mobID = "223253",
					spellCD = 20,
					ficon = "6",
					hl_np = true,
				},
				{ -- 图标 恶臭齐射
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 448248,
					effect = 2,
					hl = "gre",
					tip = L["吸收治疗"],
					ficon = "9",
				},
			},
		},
		{ -- 预警尖鸣
			spells = {
				{432967},
			},
			options = {
				{ -- 计时条 预警尖鸣
					category = "AlertTimerbar",
					type = "cast",
					spellID = 432967,
					color = {.76, .67, .56},
					glow = true,
					sound = "[interrupt_cast]cast",
				},
				{ -- 姓名板自动打断图标 预警尖鸣
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 432967,
					mobID = "216340",
					spellCD = 10,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 爆发蛛网 毒液箭雨
			spells = {
				{433845},
				{433841},
			},
			options = {
				{ -- 计时条 爆发蛛网
					category = "AlertTimerbar",
					type = "cast",
					spellID = 433845,
					color = {.78, .75, .94},
					glow = true,
					sound = "[mindstep]cast",
				},
				{ -- 计时条 毒液箭雨
					category = "AlertTimerbar",
					type = "cast",
					spellID = 433841,
					color = {.61, 1, .13},
					glow = true,
					sound = "[interrupt_cast]cast",
				},
				{ -- 姓名板自动打断图标 毒液箭雨
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 433841,
					mobID = "216364",
					spellCD = 20,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 勒握斩击
			spells = {
				{433785},
			},
			options = {
				{ -- 图标 勒握斩击
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 433785,
					hl = "",
					tip = L["减速"].."%s30%",
				},
			},
		},
	},
}