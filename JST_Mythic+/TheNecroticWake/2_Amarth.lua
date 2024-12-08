local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1182\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2391] = {
	engage_id = 2389,
	npc_id = {"163157"},
	alerts = {
		{ -- 亡者领域
			spells = {
				{320655, "5"},
			},
			npcs = {
				{21548},
				{22042},
				{22044},
			},
			options = {
				{ -- 计时条 亡者领域
					category = "AlertTimerbar",
					type = "cast",
					spellID = 321226,
					color = {.89, .13, .07},
					ficon = "5",
					text = L["召唤小怪"],
					sound = "[add]cast",
				},
				{ -- 姓名板自动打断图标 寒冰箭雨
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 328667,
					mobID = "164414",
					spellCD = 30,
					ficon = "6",
					hl_np = true,
				},
				{ -- 图标 冰冻
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 328664,
					tip = L["减速"],
				},
				{ -- 对我施法图标 射击
					category = "AlertIcon",
					type = "com",
					spellID = 333629,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 射击
					category = "RFIcon",
					type = "Cast",
					spellID = 333629,
				},
			},
		},
		{ -- 最终收割
			spells = {
				{321247, "5"},
			},
			options = {
				{ -- 计时条 最终收割
					category = "AlertTimerbar",
					type = "cast",
					spellID = 321247,
					color = {0, .89, .55},
					ficon = "6",
					glow = true,
					sound = "[mindstep]cast"
				},
				{ -- 图标 折磨回响
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 333633,
				},
			},
		},
		{ -- 通灵吐息
			spells = {
				{333493},
			},
			options = { 
				{ -- 计时条 通灵吐息
					category = "AlertTimerbar",
					type = "cast",
					spellID = 333488,
					color = {.02, .5, .4},
					text = L["射线"],
					sound = "[ray]cast",
				},
			},
		},
		{ -- 邪恶狂乱
			spells = {
				{320012, "0,11"},
			},
			options = {
				{ -- 图标 邪恶狂乱
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 320012,
					hl = "red_flash",
					tip = L["BOSS强化"],
					ficon = "11",
				},
			},
		},
		{ -- 通灵箭
			spells = {
				{320170, "6"},
			},
			options = {
				{ -- 姓名板自动打断图标 通灵箭
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 320170,
					mobID = "163157",
					spellCD = 6,
					ficon = "6",
					hl_np = true,
				},
			},
		},
		{ -- 寒冰箭雨
			spells = {
				{328667, "6"},
			},
			options = {
				{ -- 姓名板自动打断图标 寒冰箭雨
					category = "PlateAlert",
					type = "PlateInterruptAuto",
					spellID = 328667,
					mobID = "164414",
					spellCD = 40,
					ficon = "6",
					hl_np = true,
				},
			},
		},
	},
}