local T, C, L, G = unpack(JST)

G.Encounter_Order[1268] = {2566, 2567, 2568, "1268Trash"}

local function soundfile(filename)
	return string.format("[1268\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["1268Trash"] = {
	map_id = 2662,
	alerts = {
		
	},
}