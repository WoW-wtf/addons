local T, C, L, G = unpack(JST)

G.Encounter_Order[1184] = {2400, 2402, 2405, "1184Trash"}

local function soundfile(filename)
	return string.format("[1184\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters["1184Trash"] = {
	map_id = 2290,
	alerts = {
		{ -- 放血
			spells = {
				{323043},
			},
			options = {				
				{ -- 图标 放血
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 323043,
					hl = "",
					tip = L["DOT"],
					ficon = "13",
				},
			},
		},
		{ -- 濒死之息
			spells = {
				{322968},
			},
			options = {				
				{ -- 图标 濒死之息
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 322968,
					hl = "",
					tip = L["易伤"].."%s10%",
					ficon = "8",
				},
			},
		},
		{ -- 收割精魄
			spells = {
				{322938},
			},
			options = {
				{ -- 姓名板自动打断图标 收割精魄
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 322938,
					mobID = "164921",
					spellCD = 17,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 迷乱花粉
			spells = {
				{321968},
			},
			options = {
				{ -- 计时条 迷乱花粉
					category = "AlertTimerbar",
					type = "cast",
					spellID = 321968,
					color = {.8, .24, 1},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 过度生长
			spells = {
				{322486},
			},
			options = {
				{ -- 对我施法图标 过度生长
					category = "AlertIcon",
					type = "com",
					spellID = 322486,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 过度生长
					category = "RFIcon",
					type = "Cast",
					spellID = 322486,
				},
				{ -- 图标 过度生长
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 322486,
					hl = "red",
					tip = L["强力DOT"].."+"..L["减速"],
				},
				{ -- 图标 过度生长
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 322487,
					hl = "red",
					tip = L["昏迷"],
				},
			},
		},
		{ -- 灵魂分裂
			spells = {
				{322557},
			},
			options = {
				{ -- 对我施法图标 灵魂分裂
					category = "AlertIcon",
					type = "com",
					spellID = 322557,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 灵魂分裂
					category = "RFIcon",
					type = "Cast",
					spellID = 322557,
				},
				{ -- 图标 灵魂分裂
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 322557,
					hl = "blu",
					tip = L["易伤"].."20%",
					fion = "7",
				},
			},
		},
		{ -- 兹洛斯之手
			spells = {
				{322569},
			},
			options = {
				{ -- 姓名板光环 兹洛斯之手
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 322569,
					hl_np = true,
				},
			},
		},
		{ -- 荆棘爆发
			spells = {
				{324923},
			},
			options = {
				{ -- 计时条 荆棘爆发
					category = "AlertTimerbar",
					type = "cast",
					spellID = 324923,
					color = {.67, .92, .08},
					text = L["躲地板"],
					sound = "[mindstep]cast",
					glow = true, 
				},
			},
		},
		{ -- 愤怒鞭笞
			spells = {
				{324909},
			},
			options = {
				{ -- 计时条 愤怒鞭笞
					category = "AlertTimerbar",
					type = "cast",
					spellID = 324909,
					color = {.91, .67, .33},
					text = L["注意自保"],
					sound = "[defense]cast",
				},
			},
		},
		{ -- 迷雾结界
			spells = {
				{463256},
			},
			options = {
				{ -- 计时条 迷雾结界
					category = "AlertTimerbar",
					type = "cast",
					spellID = 463256,
					color = {.06, .64, 1},
					text = L["减伤"],
				},
				{ -- 姓名板光环 迷雾结界
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 463236,
				},
			},
		},
		{ -- 排斥
			spells = {
				{463248},
			},
			options = {
				{ -- 对我施法图标 排斥
					category = "AlertIcon",
					type = "com",
					spellID = 463248,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 排斥
					category = "RFIcon",
					type = "Cast",
					spellID = 463248,
				},
			},
		},
		{ -- 心能挥砍
			spells = {
				{463217},
			},
			options = {
				{ -- 图标 心能挥砍
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 463217,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 木棘外壳
			spells = {
				{324776},
			},
			options = {
				{ -- 姓名板自动打断图标 木棘外壳
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 324776,
					mobID = "166275",
					spellCD = 23,
					ficon = "6",
					hl_np = true,
				},
				{ -- 姓名板光环 木棘外壳
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 324776,
					hl_np = true,
				},
				{ -- 图标 木棘缠绕
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 324859,
					hl = "blu",
					tip = L["定身"].."+"..L["DOT"],
					ficon = "7",
				},
			},
		},
		{ -- 滋养森林
			spells = {
				{324914},
			},
			options = {
				{ -- 姓名板自动打断图标 滋养森林
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 324914,
					mobID = "166299",
					spellCD = 16,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 纱雾噬咬
			spells = {
				{324986},
			},
			options = {
				{ -- 对我施法图标 纱雾噬咬
					category = "AlertIcon",
					type = "com",
					spellID = 324986,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 纱雾噬咬
					category = "RFIcon",
					type = "Cast",
					spellID = 324986,
				},
				{ -- 图标 纱雾噬咬
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 325021,
					hl = "red",
					tip = L["强力DOT"],
					ficon = "13",
				},
			},
		},
		{ -- 心能注入
			spells = {
				{325223},
			},
			options = {
				{ -- 对我施法图标 心能注入
					category = "AlertIcon",
					type = "com",
					spellID = 325223,
					hl = "yel_flash",
					ficon = "7",
				},
				{ -- 团队框架图标 心能注入
					category = "RFIcon",
					type = "Cast",
					spellID = 325223,
				},
				{ -- 图标 心能注入
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 325224,
					hl = "blu",
					tip = L["炸弹"],
					ficon = "7",
				},
			},
		},
		{ -- 毒舌鞭笞
			spells = {
				{340300},
			},
			options = {
				{ -- 计时条 毒舌鞭笞
					category = "AlertTimerbar",
					type = "cast",
					spellID = 340300,
					color = {1, .84, .84},
					text = L["头前"],
					sound = "[avoidfront]cast",
				},
			},
		},
		{ -- 剧毒分泌物
			spells = {
				{340304},
			},
			options = {
				{ -- 计时条 剧毒分泌物
					category = "AlertTimerbar",
					type = "cast",
					spellID = 340304,
					color = {.8, .94, .08},
					text = L["远离"],
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 重压跳跃
			spells = {
				{340305},
			},
			options = {
				{ -- 计时条 重压跳跃
					category = "AlertTimerbar",
					type = "cast",
					spellID = 340305,
					color = {.95, .6, .56},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 三重撕咬
			spells = {
				{340289},
			},
			options = {
				{ -- 对我施法图标 三重撕咬
					category = "AlertIcon",
					type = "com",
					spellID = 340289,
					hl = "yel_flash",
					ficon = "0",
				},
			},
		},
		{ -- 释放剧毒
			spells = {
				{340279},
			},
			options = {
				{ -- 计时条 释放剧毒
					category = "AlertTimerbar",
					type = "cast",
					spellID = 340279,
					color = {.61, .93, .27},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 辐光之池
			spells = {
				{340189},
			},
			options = {
				{ -- 计时条 辐光之池
					category = "AlertTimerbar",
					type = "cast",
					spellID = 340189,
					color = {.19, .69, .98},
					text = L["回血"],
				},
			},
		},
		{ -- 辐光之息
			spells = {
				{340160},
			},
			options = {
				{ -- 计时条 辐光之息
					category = "AlertTimerbar",
					type = "cast",
					spellID = 340160,
					color = {0, .48, 1},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 碎甲
			spells = {
				{340208},
			},
			options = {
				{ -- 对我施法图标 碎甲
					category = "AlertIcon",
					type = "com",
					spellID = 340208,
					hl = "yel_flash",
					ficon = "0",
				},
				{ -- 图标 碎甲
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 340208,
					hl = "",
					tip = L["易伤"].."20%",
				},
			},
		},
		{ -- 模拟抗性
			spells = {
				{326046},
			},
			options = {
				{ -- 姓名板自动打断图标 模拟抗性
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 326046,
					mobID = "167111",
					spellCD = 20,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 再生鼓舞
			spells = {
				{340544},
			},
			options = {
				{ -- 姓名板自动打断图标 再生鼓舞
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 340544,
					mobID = "167111",
					spellCD = 24,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 酸性新星
			spells = {
				{460092},
			},
			options = {
				{ -- 计时条 酸性新星
					category = "AlertTimerbar",
					type = "cast",
					spellID = 460092,
					color = {.75, 1, .98},
					text = L["注意自保"],
					sound = "[defense]cast",
				},
			},
		},
		{ -- 不稳定的酸液
			spells = {
				{325413},
			},
			options = {
				{ -- 对我施法图标 不稳定的酸液
					category = "AlertIcon",
					type = "com",
					spellID = 325413,
					hl = "yel_flash",
					tip = L["分散"],
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
				{ -- 团队框架图标 不稳定的酸液
					category = "RFIcon",
					type = "Cast",
					spellID = 325413,
				},
			},
		},
		{ -- 腐烂酸液
			spells = {
				{326017},
			},
			options = {
				{ -- 图标 腐烂酸液
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 326017,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 衰弱毒药
			spells = {
				{326092},
			},
			options = {
				{ -- 图标 衰弱毒药
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 326092,
					tip = L["DOT"],
					ficon = "9",
				},
			},
		},
	},
}