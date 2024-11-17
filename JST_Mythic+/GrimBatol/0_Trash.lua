local T, C, L, G = unpack(JST)

G.Encounter_Order[71] = {2617, 2627, 2618, 2619, "71Trash"}

local function soundfile(filename)
	return string.format("[71\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters["71Trash"] = {
	map_id = 670,
	alerts = {
		{ -- 残忍打击
			spells = {
				{451364},
			},
			options = {
				{ -- 对我施法图标 残忍打击
					category = "AlertIcon",
					type = "com",
					spellID = 451364,
					hl = "yel_flash",
					ficon = "0",
				},
			},
		},
		{ -- 黑曜践踏
			spells = {
				{456696},
			},
			options = {
				{ -- 计时条 黑曜践踏
					category = "AlertTimerbar",
					type = "cast",
					spellID = 456696,
					color = {.89, .76, .59},
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 大地之箭
			spells = {
				{451261},
			},
			options = {
				{ -- 对我施法图标 大地之箭
					category = "AlertIcon",
					type = "com",
					spellID = 451261,
					hl = "yel_flash",	
				},
				{ -- 团队框架图标 大地之箭
					category = "RFIcon",
					type = "Cast",
					spellID = 451261,
				},
			},
		},
		{ -- 剧烈震颤
			spells = {
				{451871},
			},
			options = {
				{ -- 姓名板自动打断图标 剧烈震颤
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 451871,
					mobID = "224219",
					spellCD = 5,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 暮光烈焰
			spells = {
				{451612},
			},
			options = {
				{ -- 对我施法图标 暮光烈焰
					category = "AlertIcon",
					type = "com",
					spellID = 451612,
					hl = "yel_flash",	
					msg = {str_applied = "%name %spell"},
				},
				{ -- 团队框架图标 暮光烈焰
					category = "RFIcon",
					type = "Cast",
					spellID = 451612,
				},
				{ -- 图标 暮光烈焰
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 451613,
					tip = L["DOT"].."+"..L["躲地板"],
					sound = "[mindstep]",
				},
				{ -- 图标 暮光余烬
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 451614,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 晦暗之风
			spells = {
				{451939},
			},
			options = {
				{ -- 计时条 晦暗之风
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451939,
					color = {.56, .32, .71},
					text = L["击退"].."/"..L["卡视野"],
				},
			},
		},
		{ -- 劈裂
			spells = {
				{451378},
			},
			options = {
				{ -- 对我施法图标 劈裂
					category = "AlertIcon",
					type = "com",
					spellID = 451378,
					hl = "yel_flash",
					ficon = "0",
				},
				{ -- 图标 劈裂
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 451378 ,
					hl = "",
					tip = L["易伤"].."%s20%",
				},
			},
		},
		{ -- 熔岩之拳
			spells = {
				{451971},
			},
			options = {
				{ -- 对我施法图标 熔岩之拳
					category = "AlertIcon",
					type = "com",
					spellID = 451971,
					hl = "yel_flash",
					ficon = "0",
				},
			},
		},
		{ -- 熔岩觉醒
			spells = {
				{451965},
			},
			options = {
				{ -- 计时条 熔岩觉醒
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451965,
					color = {.96, .51, .06},
					text = L["全团AE"],
					sound = "[aoe]cast"
				},
				{ -- 图标 熔岩觉醒
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 451965 ,
					hl = "",
					tip = L["易伤"].."%s20%",
				},
			},
		},
		{ -- 暗影烈焰箭
			spells = {
				{76369},
			},
			options = {
				{ -- 对我施法图标 暗影烈焰箭
					category = "AlertIcon",
					type = "com",
					spellID = 76369,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 暗影烈焰箭
					category = "RFIcon",
					type = "Cast",
					spellID = 76369,
				},
			},
		},
		{ -- 灼烧心智
			spells = {
				{76711},
			},
			options = {
				{ -- 姓名板自动打断图标 灼烧心智
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 76711,
					mobID = "40167",
					spellCD = 4,
					ficon = "6",
					hl_np = true,
				},
				{ -- 图标 灼烧心智
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 76711,
					hl = "red",
					tip = L["DOT"].."+"..L["昏迷"],
				},
			},
		},
		{ -- 暗影烈焰斩
			spells = {
				{451241},
			},
			options = {
				{ -- 对我施法图标 暗影烈焰斩
					category = "AlertIcon",
					type = "com",
					spellID = 451241,
					hl = "yel_flash",
					ficon = "0",
				},
				{ -- 图标 暗影烈焰斩
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID =  451241,
					hl = "red",
					tip = L["DOT"],
					ficon = "0",
				},
			},
		},		
		{ -- 炽燃暗影烈焰
			spells = {
				{462216},
			},
			options = {
				{ -- 计时条 炽燃暗影烈焰
					category = "AlertTimerbar",
					type = "cast",
					spellID = 462216,
					color = {1, .71, .18},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 暗影熔岩冲击
			spells = {
				{456711},
			},
			options = {
				{ -- 计时条 暗影熔岩冲击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 456711,
					color = {1, .71, .18},
					text = L["头前"],
					sound = "[avoidfront]cast",
				},
			},
		},
		{ -- 黑暗喷发
			spells = {
				{456713},
			},
			options = {
				{ -- 计时条 黑暗喷发
					category = "AlertTimerbar",
					type = "cast",
					spellID = 456713,
					color = {.69, .06, .58},
					text = L["分散"],
					sound = "[spread]cast",
				},				
			},
		},
		{ -- 扬升
			spells = {
				{451387},
			},
			options = {
				{ -- 计时条 扬升
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451387,
					color = {.62, .83, .81},
					text = L["注意自保"],
					sound = "[defense]cast",
				},				
			},
		},
		{ -- 暗影烈焰笼罩
			spells = {
				{451224},
			},
			options = {
				{ -- 计时条 暗影烈焰笼罩
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451224,
					color = {.66, .08, 1},
					ficon = "8",
				},
				{ -- 图标 暗影烈焰笼罩
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 451224,
					effect = 1,
					hl = "pur",
					tip = L["吸收治疗"],
					ficon = "8",
				},
			},
		},
		{ -- 心智贯透
			spells = {
				{451391},
			},
			options = {
				{ -- 计时条 心智贯透
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451391,
					color = {.77, .29, .79},
					sound = "[mindstep]cast",
				},				
			},
		},
		{ -- 腐蚀
			spells = {
				{451395},
			},
			options = {
				{ -- 对我施法图标 腐蚀
					category = "AlertIcon",
					type = "com",
					spellID = 451391,
					hl = "yel_flash",	
					msg = {str_applied = "%name %spell"},
				},
				{ -- 团队框架图标 腐蚀
					category = "RFIcon",
					type = "Cast",
					spellID = 451391,
				},
				{ -- 图标 腐蚀
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 451395,
					hl = "red",
					tip = L["强力DOT"],
					sound = "[defense]",
				},
			},
		},
		{ -- 暗影之伤
			spells = {
				{456719},
			},
			options = {
				{ -- 图标 暗影之伤
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 456719,
					tip = L["易伤"].."%s5%",
				},
			},
		},
	},
}