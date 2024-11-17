local mod = Whisp:NewModule("Import Chatter Settings", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Whisp")
mod.modName = L["Import Chatter Settings"]

local options = {
	reload = {
		type = "execute",
		name = L["Reload"],
		desc = L["Reload the Chatter settings"],
		order = 99,
		func = function() mod:LoadChatterSettings() end,
	},  
	fonts = {
		type = "toggle",
		name = L["Font"],
		desc = L["Font"],
		set = function(_,v) 
			mod.db.profile.font = v
			mod:LoadChatterSettings()
		end,
		get = function() return mod.db.profile.font end,
	},
	timestamp = {
		type = "toggle",
		name = L["Timestamp"],
		desc = L["Timestamp"],
		set = function(_,v) 
			mod.db.profile.timestamp = v
			mod:LoadChatterSettings()
		end,
		get = function() return mod.db.profile.timestamp end,
	},
	background = {
		type = "toggle",
		name = L["Background / Border"],
		desc = L["Background / Border"],
		set = function(_,v) 
			mod.db.profile.background = v
			mod:LoadChatterSettings()
		end,
		get = function() return mod.db.profile.background end,
	},
}

local defaults = {
	profile = {
		font = true,         -- Font face/size
		timestamp = true,    -- Timestamp format/color
		background = true,   -- Background and borders
		playername = true,   -- Playername format/color
	}
}

function mod:OnInitialize()
	self.db = Whisp.db:RegisterNamespace("Import Chatter Settings", defaults)
end

function mod:OnEnable()
	mod:LoadChatterSettings()
end

function mod:OnDisable()
	Whisp.options.args.general.args.appearance.args.font.disabled = false
	Whisp.options.args.general.args.appearance.args.fontsize.disabled = false
	Whisp.options.args.general.args.appearance.args.color.disabled = false
	Whisp.options.args.general.args.appearance.args.borderColor.disabled = false
	Whisp.options.args.general.args.appearance.args.border.disabled = false
	Whisp.options.args.general.args.appearance.args.background.disabled = false
	mod:UnhookAll()
end

function mod:LoadChatterSettings()
	if not C_AddOns.IsAddOnLoaded("Chatter") then mod:Disable() return end
	local Chatter = LibStub("AceAddon-3.0"):GetAddon("Chatter")
	
	local c = {}
	mod:OnDisable() -- reset all settings
	
	if self.db.profile.font and Chatter:GetModule("Chat Font", true) and Chatter:GetModule("Chat Font"):IsEnabled() then
		Whisp.db.char.paneFont = Chatter.db.children.ChatFont.profile.font
		Whisp.db.char.fontSize = Chatter.db.children.ChatFont.profile.fontsize
		Whisp.options.args.general.args.appearance.args.font.disabled = true
		Whisp.options.args.general.args.appearance.args.fontsize.disabled = true
	end
	if self.db.profile.timestamp and Chatter:GetModule("Timestamps", true) and Chatter:GetModule("Timestamps"):IsEnabled() then
		Whisp.db.char.timeFormat = Chatter.db.children.Timestamps.profile.customFormat or ("[" .. Chatter.db.children.Timestamps.profile.format .. "]")
		c = Chatter.db.children.Timestamps.profile.color
		Whisp.db.char.timeColor = {c.r, c.g, c.b}
		Whisp.db.char.timeColorByChannel = Chatter.db.children.Timestamps.profile.colorByChannel
	end
	if self.db.profile.background and Chatter:GetModule("Borders/Background", true) and Chatter:GetModule("Borders/Background"):IsEnabled() then
		Whisp.db.char.paneBackground = Chatter.db.children.ChatFrameBorders.profile.frames["FRAME_1"].background
		c = Chatter.db.children.ChatFrameBorders.profile.frames["FRAME_1"].backgroundColor
		Whisp.db.char.paneColor = {c.r, c.g, c.b, c.a}
		Whisp.db.char.paneBorder =  Chatter.db.children.ChatFrameBorders.profile.frames["FRAME_1"].border
		c = Chatter.db.children.ChatFrameBorders.profile.frames["FRAME_1"].borderColor
		Whisp.db.char.paneBorderColor = {c.r, c.g, c.b, c.a}
		Whisp.options.args.general.args.appearance.args.color.disabled = true
		Whisp.options.args.general.args.appearance.args.borderColor.disabled = true
		Whisp.options.args.general.args.appearance.args.border.disabled = true
		Whisp.options.args.general.args.appearance.args.background.disabled = true
	end
end

function mod:GetOptions()
	return options
end

function mod:OnSkinUpdate()
	
end

function mod:Info()
	return L["Enables you to synchronise settings with Chatter; e.g. fonts, colors, borders, etc."]
end
