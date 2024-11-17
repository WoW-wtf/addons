local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1268\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2568] = {
	engage_id = 2836,
	npc_id = {"207207"},
	alerts = {
		{ -- 虚无颠覆
			spells = {
				{423305, "5"},
			},
			options = {
				{ -- 计时条 虚无颠覆
					category = "AlertTimerbar",
					type = "cast",
					spellID = 423305,
					color = {.23, .05, 1},
					ficon = "5",
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
				{ -- 图标 徘徊虚空
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 433067,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 图标 驭雷者电荷
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 458082,
					sound = "cd3",
					msg = {str_applied = "%name %spell", str_rep = "%dur"},
				},
			},
		},
		{ -- 虚空壳壁
			spells = {
				{445262},
			},
			options = {
				{ -- 计时条 风暴复仇
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424371,
					color = {.52, .89, .94},
				},
				{ -- 计时条 电晕
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 423839,
					dur = 10,
					color = {1, 1, 0},
				},
			},
		},
		{ -- 虚空碎块
			npcs = {
				{30355},
			},
			options = {
				
			},
		},
		{ -- 释放腐蚀
			spells = {
				{429487},
			},
			options = {
				{ -- 计时条 释放腐蚀
					category = "AlertTimerbar",
					type = "cast",
					spellID = 429487,
					color = {.26, .73, .89},
				},
			},
		},
		{ -- 湮灭波
			spells = {
				{445457, "0"},
			},
			options = {
				{ -- 计时条 湮灭波
					category = "AlertTimerbar",
					type = "cast",
					spellID = 445457,
					color = {.53, .51, .87},
				},
			},
		},
		{ -- 熵灭
			spells = {
				{423393},
			},
			options = {
				{ -- 文字 熵灭 近战位无人提示
					category = "TextAlert",
					ficon = "0",
					type = "spell",
					color = {1, 0, 0},
					preview = T.GetSpellIcon(423393)..L["近战无人"],
					data = {
						spellID = 423393,
						events = {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,	
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 423393 then
								T.Start_Text_Timer(self, 3, T.GetSpellIcon(423393)..L["近战无人"])
							end
						end
					end,
				},
			},
		},
	},
}