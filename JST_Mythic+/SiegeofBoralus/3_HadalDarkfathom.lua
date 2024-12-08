local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1023\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2134] = {
	engage_id = 2099,
	npc_id = {"128651"},
	alerts = {
		{ -- 毁灭之潮
			spells = {
				{261563},
			},
			options = {
				{ -- 计时条 毁灭之潮
					category = "AlertTimerbar",
					type = "cast",
					spellID = 257862,
					color = {.06, .7, .87},
					text = L["头前"],
					sound = "[avoidfront]cast",
				},
				{ -- 图标 盐水池
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 257886,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 激流破奔
			spells = {
				{257882},
			},
			options = {
				{ -- 文字 激流破奔 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.44, .96, 1},
					preview = L["放圈"]..L["倒计时"],
					data = {
						spellID = 257882,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {8, 30, 20, 29, 21, 29, 22, 29, 23, 32},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 257882, L["放圈"], self, event, ...)
					end,
				},
				{ -- 计时条 激流破奔
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 257882,
					dur = 4.6,
					tags = {0.6},
					color = {.44, .96, 1},
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 海潮涌动
			spells = {
				{276068, "5"},
			},
			options = {
				{ -- 能量
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "128651",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(276068)..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 海潮涌动
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 276068,
					dur = 10,
					tags = {7},
					color = {.76, .91, .95},
				},
			},
		},
	},
}