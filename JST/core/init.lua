
-- local T, C, L, G = unpack(select(2, ...))

local addon, ns = ...
ns[1] = {} -- T, functions, constants, variables
ns[2] = {} -- C, config
ns[3] = {} -- L, localization
ns[4] = {} -- G, globals (Optionnal)

JST = ns

local T, C, L, G = unpack(select(2, ...))

--====================================================--
--[[                 -- Globals --                  ]]--
--====================================================--
G.addon_name = addon
G.addon_cname = select(2, C_AddOns.GetAddOnInfo(addon))
G.Client = GetLocale()
G.Version = C_AddOns.GetAddOnMetadata(addon, "Version")

G.PlayerName = UnitName("player")
G.PlayerGUID = UnitGUID("player")
G.myClass = select(2, UnitClass("player"))

G.link = "https://legacy.curseforge.com/wow/addons/jingsi-tools"
G.Contacts = "Bilibili 开船船的纪老师 QQ群 493691777"
--====================================================--
--[[                  -- Media --                   ]]--
--====================================================--
G.Font = "Interface\\AddOns\\JST\\media\\font.ttf"

G.media = {
	blank = "Interface\\Buttons\\WHITE8x8",
	logo = "Interface\\AddOns\\JST\\media\\logo.png",
	ring = "Interface\\AddOns\\JST\\media\\ring",
	circle = "Interface\\AddOns\\JST\\media\\circle",
	red_arrow = "Interface\\AddOns\\JST\\media\\arrow",
}

--====================================================--
--[[                  -- Color --                   ]]--
--====================================================--
G.Ccolors = {}
if C_AddOns.IsAddOnLoaded('!ClassColors') and CUSTOM_CLASS_COLORS then
	G.Ccolors = CUSTOM_CLASS_COLORS
else
	G.Ccolors = RAID_CLASS_COLORS
end

G.addon_color = {1, 0, 0}
G.addon_colorStr = "|cffFF0000"
--====================================================--
--[[                  -- Init --                    ]]--
--====================================================--
G.SoundPacks = {}
G.ttsSpeakers = {}
G.Encounters = {}
G.Encounter_Order = {}

local RegisterAddonMessageResults = {
	--[0] = "成功 Success",
	[1] = "注册插件讯息失败，注册前缀重复 Duplicate Prefix",
	[2] = "注册插件讯息失败，注册前缀无效 Invalid Prefix",	
	[3] = "注册插件讯息失败，注册前缀数量达到上限 Max Prefixes",	
}

if not C_ChatInfo.IsAddonMessagePrefixRegistered("jstpaopao") then
	local succeed, reason = C_ChatInfo.RegisterAddonMessagePrefix("jstpaopao")
end

if reason and RegisterAddonMessageResults[reason] then
	T.msg(RegisterAddonMessageResults[reason])
end

--====================================================--
--[[                -- Callbacks --                 ]]--
--====================================================--
G.Init_callbacks = {}
T.RegisterInitCallback = function(func)
	table.insert(G.Init_callbacks, func)
end

G.EnteringWorld_callbacks = {}
T.RegisterEnteringWorldCallback = function(func)
	table.insert(G.EnteringWorld_callbacks, func)
end