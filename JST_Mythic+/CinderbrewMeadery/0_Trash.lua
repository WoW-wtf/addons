local T, C, L, G = unpack(JST)

G.Encounter_Order[1272] = {2586, 2587, 2588, 2589, "1272Trash"}

local function soundfile(filename)
	return string.format("[1272\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["1272Trash"] = {
	map_id = 2661,
	alerts = {
		
	},
}