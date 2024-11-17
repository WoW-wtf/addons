local T, C, L, G = unpack(JST)

G.Encounter_Order[1267] = {2571, 2570, 2573, "1267Trash"}

local function soundfile(filename)
	return string.format("[1267\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["1267Trash"] = {
	map_id = 2649,
	alerts = {
		
	},
}