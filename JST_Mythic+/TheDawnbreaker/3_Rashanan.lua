local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1270\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2593] = {
	engage_id = 2839,
	npc_id = {"213937"},
	alerts = {
		{ -- 阿拉希炸弹
			spells = {
				{434655, "5"},
			},
			options = {
				{ -- 图标 阿拉希炸弹
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "boss1",					
					spellID = 434655,
				},
			},
		},
		{ -- 酸液翻腾
			spells = {
				{434407},
			},
			options = {
				{ -- 计时条 酸液翻腾
					category = "AlertTimerbar",
					type = "cast",
					spellID = 434407,
					color = {.71, .76, .19},
				},
				{ -- 声音 酸液翻腾
					category = "Sound",
					spellID = 434406,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = "[1273\\439790aura]"
				},
				{ -- 图标 酸液池
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 438957,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 缠网喷吐
			spells = {
				{448213},
			},
			options = {
				{ -- 计时条 缠网喷吐
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448213,
					color = {.82, .79, .7},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 侵蚀喷涌
			spells = {
				{448888, "2"},
			},
			options = {
				{ -- 计时条 侵蚀喷涌
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448888,
					color = {.86, .89, .22},
					text = L["全团AE"],
					sound = "[aoe]cast",
				},
				{ -- 图标 萦绕侵蚀
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 463428,	
					tip = L["DOT"],
				},
			},
		},
		{ -- 光芒四射
			spells = {
				{449042, "5"},
			},
			options = {
				{ -- 图标 光芒四射
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 449042,	
					tip = L["可以飞"],
				},
			},
		},
		{ -- 酸蚀喷发
			spells = {
				{449734, "5,6"},
			},
			options = {
				{ -- 计时条 酸蚀喷发
					category = "AlertTimerbar",
					type = "cast",
					spellID = 449734,
					color = {1, .9, 0},
					ficon = "6",
					sound = "[interrupt_cast]cast",
				},
			},
		},
		{ -- 喷射丝线
			spells = {
				{434089},
			},
			options = {
				{ -- 计时条 喷射丝线
					category = "AlertTimerbar",
					type = "cast",
					spellID = 434089,
					color = {.89, .86, .73},
				},
				{ -- 声音 喷射丝线
					category = "Sound",
					spellID = 434090,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = "[1273\\439783aura]"
				},
			},
		},
		{ -- 粘稠迸发
			spells = {
				{435793, "0"},
			},
			options = {
				{ -- 文字 粘稠迸发 近战位无人提示
					category = "TextAlert",
					ficon = "0",
					type = "spell",
					color = {1, 0, 0},
					preview = T.GetSpellIcon(435793)..L["近战无人"],
					data = {
						spellID = 435793,
						events = {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,	
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 435793 then
								T.Start_Text_Timer(self, 3, T.GetSpellIcon(435793)..L["近战无人"])
							end
						end
					end,
				},
			},
		},
	},
}