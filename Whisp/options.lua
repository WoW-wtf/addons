-----------------------------------
-----------------------------------
-- Whisp by Anea
-----------------------------------
-- options.lua
-- Commandline and FuBar options
-----------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("Whisp")
local AceConfig = LibStub("AceConfig-3.0")
local C = LibStub("AceConfigDialog-3.0")
local optFrame
local backgrounds, borders, fonts = {},{},{}

-- generic options
local options = {
	type = "group",
	name = "Whisp",
	desc = L["Setup this mod to your needs"],
	args = {
		general = {
			type = "group",
			name = L["General"],
			desc = L["General settings"],
			args = {
				behaviour = {
					type = "group",
					name = L["Behaviour"],
					desc = L["Setup the behaviour of the pane"],
					order = 2,
					args = {
						linesShown = {
							type = "range",
							name = L["Lines shown"],
							desc = L["The number of lines to show in the tooltips"],
							min = 1,
							max = 30,
							step = 1,
							set = function(_,v) Whisp.db.char.linesShown=v end,
							get = function() return Whisp.db.char.linesShown end,
						},
						paneSortDown = {
							type = "toggle",
							name = L["Oldest to newest"],
							desc = L["Show messages oldest to newest"],
							set = function(_,v) Whisp.db.char.paneSortDown=v end,
							get = function() return Whisp.db.char.paneSortDown end,
						},
					},
				},
				appearance = {
					type = "group",
					name = L["Appearance"],
					desc = L["Setup the appearance of the panes"],
					order = 3,
					args = {
						color = {
							type = "color",
							name = L["Background color"],
							desc = L["Set the background color of the tooltips"],
							hasAlpha = true,
							get = function()
								local c = Whisp.db.char.paneColor
								return c[1], c[2], c[3], c[4]
							end,
							set = function(_,r, g, b, a)
								Whisp.db.char.paneColor = {r, g, b, a}
								Whisp:SendMessage("WHISP_SKIN")
							end,
						},
						classColor = {
							type = "toggle",
							name = L["Colorised player names"],
							desc = L["Colorise the names of players by class"],
							set = function(_,v) 
								Whisp.db.profile.classColor = v
							end,
							get = function() return Whisp.db.profile.classColor end,
						},
						colorOut = {
							type = "color",
							name = L["Color outgoing"],
							desc = L["Set the color of outgoing messages"],
							hasAlpha = true,
							get = function()
								local c = Whisp.db.char.colorOutgoing
								return c[1], c[2], c[3], c[4]
							end,
							set = function(_,r, g, b, a)
								Whisp.db.char.colorOutgoing = {r, g, b, a}
								Whisp:SendMessage("WHISP_MESSAGE")
								Whisp:SendMessage("WHISP_SKIN")
							end,
						},
						colorIn = {
							type = "color",
							name = L["Color incoming"],
							desc = L["Set the color of incoming messages"],
							hasAlpha = true,
							get = function()
								local c = Whisp.db.char.colorIncoming
								return c[1], c[2], c[3], c[4]
							end,
							set = function(_,r, g, b, a)
								Whisp.db.char.colorIncoming = {r, g, b, a}
								Whisp:SendMessage("WHISP_MESSAGE")
								Whisp:SendMessage("WHISP_SKIN")
							end,
						},
						border = {
							name = L["Border style"],
							desc = L["Change the border style."],
							type = 'select',
							values = borders,
							get = function() return Whisp.db.char.paneBorder end,
							set = function(_,v)
								Whisp.db.char.paneBorder = borders[v]
								Whisp:SendMessage("WHISP_SKIN")
							end,
						},
						borderColor = {
							name = L["Border color"],
							desc = L["Set the color of the border"],
							type = 'color',
							hasAlpha = true,
							get = function()
								local c = Whisp.db.char.paneBorderColor
								return c[1], c[2], c[3], c[4]
							end,
							set = function(_,r, g, b, a)
								Whisp.db.char.paneBorderColor = {r, g, b, a}
								Whisp:SendMessage("WHISP_SKIN")
							end,
						},        
						background = {
							name = L["Background style"],
							desc = L["Change the background style. Note that for some styles the background color needs to be set to white to show."],
							type = 'select',
							values = backgrounds,
							get = function() return Whisp.db.char.paneBackground end,
							set = function(_,v)
								Whisp.db.char.paneBackground = backgrounds[v]
								Whisp:SendMessage("WHISP_SKIN")
							end,
						},
						font = {
							name = L["Font"],
							desc = L["What font face to use."],
							type = 'select',
							values = fonts,
							get = function() return Whisp.db.char.paneFont end,
							set = function(_,v) 
								Whisp.db.char.paneFont = fonts[v]
								Whisp:SendMessage("WHISP_SKIN")
							end,
						},
						fontsize = {
							type = "range",
							name = L["Font size"],
							desc = L["Select the size of the font"],
							min = 6,
							max = 20,
							step = 1,
							get = function() return Whisp.db.char.fontSize end,
							set = function(_,v) 
								Whisp.db.char.fontSize = v 
								Whisp:SendMessage("WHISP_SKIN")
								Whisp:SendMessage("WHISP_MESSAGE")
							end,
						},
					},
				},
				history = {
					type = "group",
					order = 4,
					name = L["History"],
					desc = L["History"],
					args = {
						history = {
							type = "range",
							order = 1,
							name = L["History"],
							desc = L["How long should messages be cached (in hours). When set to zero, messages will be saved during the session."],
							min = 0,
							max = 720,
							step = 1,
							set = function(_,v) Whisp.db.profile.timeout=v end,
							get = function() return Whisp.db.profile.timeout end,
						},
						clear = {
							type = "execute",
							order = 2,
							name = L["Clear"],
							desc = L["Empties the history"],
							confirm = true,
							confirmText = L["Are you sure you want to clear the history?"],
							func = function() Whisp.db.realm.chatHistory = {} end,
						},
						bnetnames = {
							type = "toggle",
							name = L["BattleTags"],
							desc = L["Save whisper history under BattleTags instead of character names (Should persist between sessions.)"],
							set = function(_,v) 
								Whisp.db.profile.bnetnames = v
							end,
							get = function() return Whisp.db.profile.bnetnames end,
						},
					},
				},
			},
		},
		modules = {
			type = "group",
			name = L["Modules"],
			desc = L["Modules"],
			args = {}
		},
	},
}
Whisp.options = options

function Whisp:SetupOptions()
	-- Load module options (code from Chatter)
	for k, v in self:IterateModules() do
		options.args.modules.args[k:gsub(" ", "_")] = {
			type = "group",
			name = (v.modName or k),
			args = nil
		}
		local t
		if v.GetOptions then
			t = v:GetOptions()
			t.settingsHeader = {
				type = "header",
				name = L["Settings"],
				order = 12
			}   
		end
		t = t or {}
		t.toggle = {
			type = "toggle", 
			name = v.toggleLabel or (L["Enable "] .. (v.modName or k)), 
			desc = v.Info and v:Info() or (L["Enable "] .. (v.modName or k)), 
			order = 11,
			get = function()
				return Whisp.db.profile.modules[k] ~= false or false
			end,
			set = function(info, v)
				Whisp.db.profile.modules[k] = v
				if v then
					Whisp:EnableModule(k)
				else
					Whisp:DisableModule(k)
				end
			end
		}
		t.header = {
			type = "header",
			name = v.modName or k,
			order = 9
		}
		if v.Info then
			t.description = {
				type = "description",
				name = v:Info() .. "\n\n",
				order = 10
			}
		end
		options.args.modules.args[k:gsub(" ", "_")].args = t
	end 
	-- End of loading module options

	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	
	optFrame = C:AddToBlizOptions("Whisp", "Whisp")
	AceConfig:RegisterOptionsTable("Whisp", options)
	self:RegisterChatCommand("whisp", Whisp.OpenConfig)
	
	Whisp.media.RegisterCallback(Whisp, "LibSharedMedia_Registered")
	self:LibSharedMedia_Registered()
end

-- Code from Chatter
function Whisp:OpenConfig(input)
	if not C.OpenFrames["Whisp"] then C:Open("Whisp") 
	else C:Close("Whisp") end
end

function Whisp:LibSharedMedia_Registered()
	for k,v in pairs(Whisp.media:List("background")) do
		backgrounds[v] = v
	end
	for k,v in pairs(Whisp.media:List("border")) do
		borders[v] = v
	end
	for k,v in pairs(Whisp.media:List("font")) do
		fonts[v] = v
	end
end