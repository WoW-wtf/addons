local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1023\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2140] = {
	engage_id = 2100,
	npc_id = {"128652"},
	alerts = {
		{ -- 腐败之水
			spells = {
				{274991, "7"},
			},
			options = {
				{ -- 图标 腐败之水
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 274991,
					hl = "blu",
					tip = L["强力DOT"],
					ficon = "7",
				},
			},
		},
		{ -- 深渊恐惧
			spells = {
				{279897, "5"},
			},
			options = {
				{ -- 图标 窒息勒压
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 270624,
					hl = "red",
					tip = L["强力DOT"],
				},
			},
		},
		{ -- 深渊的呼唤
			spells = {
				{270185},
			},
			options = {
				{ -- 文字提示 深渊的呼唤 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.8, 1, .87},
					preview = L["躲地板"]..L["倒计时"],
					data = {
						spellID = 270183,
						events =  {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 270183 then
								T.Start_Text_Timer(self, 4, L["躲地板"], true)
							end
						end
					end,
				},
			},
		},
		{ -- 攻城恐魔
			npcs = {
				{18340, "0"},
			},
			options = {
				{ -- 计时条 猛击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 269266,
					color = {1, .73, .29},
					text = L["击退"].."+"..L["全团AE"],
					sound = "[knockback]cast"
				},
			},
		},
		{ -- 灭杀
			spells = {
				{269484, "4"},
			},
			options = {
				{ -- 计时条 灭杀
					category = "AlertTimerbar",
					type = "cast",
					spellID = 269456,
					color = {.37, .85, .84},
					ficon = "4",
					text = L["近战AOE"],
					sound = "[meleeaoe]cast",
				},
			},
		},
	},
}