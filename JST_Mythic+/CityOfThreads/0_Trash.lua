local T, C, L, G = unpack(JST)

G.Encounter_Order[1274] = {2594, 2595, 2600, 2596, "1274Trash"}

local function soundfile(filename)
	return string.format("[1274\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["1274Trash"] = {
	map_id = 2669,
	alerts = {
		{ -- 裂地猛击
			spells = {
				{443500},
			},
			options = {
				{ -- 计时条 裂地猛击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 443500,
					color = {.76, .56, .32},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 贪婪之虫
			spells = {
				{443509},
			},
			options = {
				{ -- 对我施法图标 贪婪之虫
					category = "AlertIcon",
					type = "com",
					spellID = 443507,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 贪婪之虫
					category = "RFIcon",
					type = "Cast",
					spellID = 443507,
				},
				{ -- 图标 贪婪之虫
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443509,
					hl = "red",
					tip = L["强力DOT"],
					sound = "[defense]",
				},				
			},
		},
		{ -- 蛛网箭
			spells = {
				{443427},
			},
			options = {				
				{ -- 图标 蛛网箭
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443427,
					hl = "yel",
					tip = L["减速"],
				},
				{ -- 姓名板自动打断图标 蛛网箭
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 443427,
					mobID = "220195,219984,221102",
					spellCD = 5,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 流丝缠缚
			spells = {
				{443430},
			},
			options = {				
				{ -- 图标 流丝缠缚
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443430,
					hl = "org",
					tip = L["减速"],
				},
				{ -- 姓名板自动打断图标 流丝缠缚
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 443430,
					mobID = "220195",
					spellCD = 20,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 疑之影
			spells = {
				{443437},
			},
			options = {				
				{ -- 图标 疑之影
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443437,					
					tip = L["DOT"],
					hl = "org_flash",
					ficon = "7",
					sound = "[getout]",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
			},
		},
		{ -- 剧毒打击
			spells = {
				{443401},
			},
			options = {				
				{ -- 图标 剧毒打击
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443401,					
					tip = L["DOT"],
				},
			},
		},
		{ -- 香水投掷
			spells = {
				{450784},
			},
			options = {
				{ -- 计时条 香水投掷
					category = "AlertTimerbar",
					type = "cast",
					spellID = 450784,
					color = {.44, .85, .91},
					text = L["躲地板"],
					show_tar = true,
					sound = "[mindstep]cast",
				},
				{ -- 对我施法图标 香水投掷
					category = "AlertIcon",
					type = "com",
					spellID = 450784,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell"},
				},
			},
		},
		{ -- 纱网弹幕
			spells = {
				{451423},
			},
			options = {
				{ -- 计时条 纱网弹幕
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451423,
					color = {.83, .8, .74},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 虚无猛击
			spells = {
				{451543},
			},
			options = {
				{ -- 计时条 虚无猛击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451543,
					color = {.57, .17, 1},
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 虚空奔袭
			spells = {
				{451295},
			},
			options = {				
				{ -- 计时条 虚空奔袭
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451543,
					color = {.75, .07, .4},
					text = L["全团AE"],
				},
				{ -- 图标 虚空奔袭
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 451295,
					tip = L["DOT"],
				},
			},
		},
		{ -- 飞刀投掷
			spells = {
				{448030},
			},
			options = {
				{ -- 对我施法图标 飞刀投掷
					category = "AlertIcon",
					type = "com",
					spellID = 448030,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 飞刀投掷
					category = "RFIcon",
					type = "Cast",
					spellID = 448030,
				},
			},
		},
		{ -- 愈合之网
			spells = {
				{452162},
			},
			options = {
				{ -- 愈合之网
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 452162,
					mobID = "223844",
					spellCD = 30,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 阴织冲击
			spells = {
				{442536},
			},
			options = {
				{ -- 阴织冲击
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 442536,
					mobID = "223844",
					spellCD = 10,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 残暴戳刺
			spells = {
				{442536},
			},
			options = {
				{ -- 图标 残暴戳刺
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 442536,
					tip = L["易伤"].."%s10%",
				},
			},
		},
		{ -- 毒性喷吐
			spells = {
				{434137},
			},
			options = {
				{ -- 计时条 毒性喷吐
					category = "AlertTimerbar",
					type = "cast",
					spellID = 434137,
					color = {.91, .97, .51},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
				{ -- 图标 毒性喷吐
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 461630,
					tip = L["DOT"],
					ficon = "9",
				},
			},
		},
		{ -- 黑暗弹幕
			spells = {
				{445813},
			},
			options = {
				{ -- 计时条 黑暗弹幕
					category = "AlertTimerbar",
					type = "cast",
					spellID = 445813,
					color = {.6, .51, .96},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 凶暴践踏
			spells = {
				{436205},
			},
			options = {
				{ -- 计时条 凶暴践踏
					category = "AlertTimerbar",
					type = "cast",
					spellID = 436205,
					color = {.62, .53, .49},
					text = L["注意自保"],
					sound = "[defense]cast",
				},
			},
		},
		{ -- 虚空之波
			spells = {
				{446086},
			},
			options = {				
				{ -- 姓名板自动打断图标 虚空之波
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 446086,
					mobID = "216339",
					spellCD = 15,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 震颤猛击
			spells = {
				{447271},
			},
			options = {
				{ -- 计时条 震颤猛击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 447271,
					color = {1, .82, .55},
					text = L["注意自保"],
					sound = "[defense]cast",
				},
			},
		},
		{ -- 晦幽纺纱
			spells = {
				{446717},
			},
			options = {
				{ -- 计时条 晦幽纺纱
					category = "AlertTimerbar",
					type = "cast",
					spellID = 446717,
					color = {.73, .51, .93},
					text = L["定身"],
					sound = "[add]cast",
				},
			},
		},
	},
}