local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1271\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2583] = {
	engage_id = 2926,
	npc_id = {"213179"},
	alerts = {
		{ -- 贪得无厌
			spells = {
				{446788},
			},
			options = {
				{ -- 图标 贪得无厌
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "boss1",
					spellID = 446794,
				},
			},
		},
		{ -- 警示尖鸣
			spells = {
				{438476},
			},
			npcs = {
				{28811},
			},
			options = {
				{ -- 文字 警示尖鸣 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.98, .97, .76},
					preview = T.GetIconLink(438476)..L["倒计时"],
					data = {
						spellID = 438476,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {10.1,40.2,38.9},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438476, T.GetIconLink(438476), self, event, ...)
					end,
				},
				{ -- 计时条 警示尖鸣
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438476,
					color = {.98, .97, .76},
					sound = "[add]cast",
				},
				{ -- 图标 饥肠辘辘
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 439070,
					hl = "red",
					tip = L["锁定"],
				},
				
			},
		},
		{ -- 蛛纱强袭
			spells = {
				{438473},
			},
			options = {
				{ -- 文字 蛛纱强袭 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.63, .62, .82},
					preview = T.GetIconLink(438473)..L["倒计时"],
					data = {
						spellID = 438473,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {30.8,38.9,42.6},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438473, T.GetIconLink(438473), self, event, ...)
					end,
				},
				{ -- 计时条 蛛纱强袭
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438473,
					color = {.63, .62, .82},
					sound = "[mindsteps]cast",
				},
				{ -- 图标 邪恶缠网
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 434830,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 贪食撕咬
			spells = {
				{438471, "0"},
			},
			options = {
				{ -- 对我施法图标 贪食撕咬
					category = "AlertIcon",
					type = "com",
					spellID = 438471,
					hl = "yel_flash",
					ficon = "0",
				},
				{ -- 图标 贪食撕咬
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 439200,
					tip = L["易伤"],
					ficon = "0",
				},
			},
		},
	},
}