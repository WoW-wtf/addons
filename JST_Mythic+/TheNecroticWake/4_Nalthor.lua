local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1182\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2396] = {
	engage_id = 2390,
	npc_id = {"162693"},
	alerts = {
		{ -- 彗星风暴
			spells = {
				{320784},
			},
			options = {
				{ -- 计时条 彗星风暴
					category = "AlertTimerbar",
					type = "cast",
					spellID = 320772,
					color = {.52, .83, .92},
				},
				{ -- 图标 彗星风暴
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 320784,
					spellIDs = {[321956] = true},
					hl = "blu",
					tip = L["易伤"].."%s25%",				
				},
			},
		},
		{ -- 冰缚之盾
			spells = {
				{321754},
			},
			options = {
				{ -- 吸收盾 冰缚之盾
					category = "BossMod",
					spellID = 321754,
					enable_tag = "everyone",
					name = string.format(L["NAME吸收盾"], T.GetIconLink(321754)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 300},
					events = {
						["UNIT_ABSORB_AMOUNT_CHANGED"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 321754 -- 冰缚之盾
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
		{ -- 冻结之缚
			spells = {
				{320788, "7"},
			},
			options = {
				{ -- 对我施法图标 冻结之缚
					category = "AlertIcon",
					type = "com",
					spellID = 320788,
					hl = "yel_flash",
					ficon = "7",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
				{ -- 团队框架图标 冻结之缚
					category = "RFIcon",
					type = "Cast",
					spellID = 320788,
				},
				{ -- 图标 冻结之缚
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 320788,
					tip = L["离开人群"],
					ficon = "7",
					sound = "[getout]",
				},
			},
		},
		{ -- 寒冰碎片
			spells = {
				{320771},
			},
			options = {
				{ -- 对我施法图标 寒冰碎片
					category = "AlertIcon",
					type = "com",
					spellID = 320771,
					hl = "yel_flash",
					ficon = "0",
				},
			},
		},
		{ -- 黑暗放逐
			spells = {
				{321894},
			},
			npcs = {
				{21730},
				{22841},
			},
			options = {
				{ -- 对我施法图标 黑暗放逐
					category = "AlertIcon",
					type = "com",
					spellID = 321894,
					hl = "yel_flash",
				},
				{ -- 图标 冷冽之寒
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 328181,
					tip = L["减速"].."%s2%",
				},
				{ -- 图标 冰峰碎片
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 328212,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 图标 衰弱
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 322274,
					hl = "yel",
					tip = L["DOT"].."+"..L["减速"],
				},
				{ -- 图标 勇士之赐
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 345323,
					hl = "gre",
				},
			},
		},
	},
}




