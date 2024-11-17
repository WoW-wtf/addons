local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1210\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2559] = {
	engage_id = 2826,
	npc_id = {"208743"},
	alerts = {
		{ -- 燃焰地狱火
			spells = {
				{423099, "5"},
			},
			options = {
				{ -- 计时条 点芯弹幕
					category = "AlertTimerbar",
					type = "cast",
					spellID = 423109,
					color = {1, .67, .11},
					ficon = "5",
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 点芯弹幕
			spells = {
				{421638},
			},
			options = {
				{ -- 计时条 点芯弹幕
					category = "AlertTimerbar",
					type = "cast",
					spellID = 421817,
					color = {.97, .82, .45},
					ficon = "5",
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 灭火强风
			spells = {
				{422700},
			},
			options = {
				{ -- 计时条 灭火强风
					category = "AlertTimerbar",
					type = "cast",
					spellID = 429113,
					color = {.76, .72, .58},
				},
			},
		},
		{ -- 点燃
			spells = {
				{424223},
			},
			options = {
				{ -- 计时条 点燃
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424212,
					color = {1, .58, .13},
				},
				{ -- 图标 点燃
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 424223,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 吹灭之息
			spells = {
				{425394, "2"},
			},
			options = {
				{ -- 计时条 吹灭之息
					category = "AlertTimerbar",
					type = "cast",
					spellID = 425394,
					color = {.68, .83, .89},
					text = L["全团AE"],
				},
			},
		},
		{ -- 炽烈风暴
			spells = {
				{443835, "0"},
			},
			options = {
				{ -- 文字 炽烈风暴 近战位无人提示
					category = "TextAlert",
					ficon = "0",
					type = "spell",
					color = {1, 0, 0},
					preview = T.GetSpellIcon(443835)..L["近战无人"],
					data = {
						spellID = 443835,
						events = {
							["UNIT_SPELLCAST_START"] = true,	
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 443835 then
								T.Start_Text_Timer(self, 3, T.GetSpellIcon(443835)..L["近战无人"])
							end
						end
					end,
				},
			},
		},
	},
}