local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[71\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2627] = {
	engage_id = 1050,
	npc_id = {"40177"},
	alerts = {
		{ -- 熔岩池
			spells = {
				{449536, "5"},
			},
			options = {
				{ -- 图标 熔岩池
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 449536,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 锻造武器
			spells = {
				{457664},
			},
			options = {
				{ -- 计时条 锻造武器 铸造利剑/铸造利斧/铸造战锤
					category = "AlertTimerbar",
					type = "cast",
					spellID = 456902,
					spellIDs = {[451996] = true, [456900] = true,},
					color = {.62, .59, .77},
					text = L["全团AE"],
					sound = "[aoe]cast",
					glow = true,
				},
			},
		},
		{ -- 熔岩重锤
			spells = {
				{449687},
			},
			options = {
				{ -- 计时条 熔岩重锤
					category = "AlertTimerbar",
					type = "cast",
					spellID = 449687,	
					color = {.75, .18, .09},
					text = L["远离"],
					sound = "[away]cast",
				},
				{ -- 计时条 熔岩重锤
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_SUCCESS",
					spellID = 449687,
					dur = 10,
					color = {.75, .18, .09},
					text = L["远离"],
				},
			},
		},
		{ -- 熔火乱舞
			spells = {
				{449444},
			},
			options = {
				{ -- 计时条 熔火乱舞
					category = "AlertTimerbar",
					type = "cast",
					spellID = 449444,	
					color = {1, .51, .06},
					text = L["炸弹"],
					sound = "[bomb]cast",
				},
				{ -- 图标 熔浆火花
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 449474,
					hl = "org_flash",
					tip = L["炸弹"],
					sound = "[bombonyou]",
				},
			},
		},
		{ -- 烈火斩
			spells = {
				{447395},
			},
			options = {
				{ -- 文字 烈火斩 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.99, .76, .49},
					preview = T.GetSpellIcon(447395)..L["倒计时"],
					data = {
						spellID = 447395,
						events = {
							["UNIT_SPELLCAST_START"] = true,	
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 451996 then -- 铸造利斧
								T.Start_Text_DelayTimer(self, 12, T.GetSpellIcon(447395), true)
							end
						end
					end,
				},
				{ -- 计时条 烈火斩
					category = "AlertTimerbar",
					type = "cast",
					spellID = 447395,	
					color = {.99, .76, .49},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
	},
}