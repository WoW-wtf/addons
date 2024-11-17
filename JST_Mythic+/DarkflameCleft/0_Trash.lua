local T, C, L, G = unpack(JST)

G.Encounter_Order[1210] = {2569, 2559, 2560, 2561, "1210Trash"}

local function soundfile(filename)
	return string.format("[1210\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["1210Trash"] = {
	map_id = 2651,
	alerts = {
		
	},
}