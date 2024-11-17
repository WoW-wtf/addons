local T, C, L, G = unpack(JST)

G.Encounter_Order[1273] = {2607, 2611, 2599, 2609, 2612, 2601, 2608, 2602, "Trash1273"}

local function soundfile(filename)
	return string.format("[1273\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["Trash1273"] = { -- Test
	map_id = 2657,
	alerts = {
		
	},
}