local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("Whisp", "enUS", true)
if not L then return end

-----------------------------------
-----------------------------------
-- Misc

-- Welcome message 
L["Whisp v%s by Anea. Type |cffffffff/whisp|r or right-click the icon for options."] = true

-----------------------------------
-----------------------------------
-- Options

--General
L["General"] = true
L["General settings"] = true
L["Options"] = true
L["Setup this mod to your needs"] = true

-- Behaviour
L["Behaviour"] = true
L["Setup the behaviour of the pane"] = true
L["Lines shown"] = true
L["The number of lines to show in the tooltips"] = true
L["Oldest to newest"] = true
L["Show messages oldest to newest"] = true

-- History
L["History"] = true
L["How long should messages be cached (in hours). When set to zero, messages will be saved during the session."] = true
L["Clear"] = true
L["Empties the history"] = true
L["Are you sure you want to clear the history?"] = true
L["BattleTags"] = true
L["Save whisper history under BattleTags instead of character names (Should persist between sessions.)"] = true

-- Appearance options
L["Appearance"] = true
L["Setup the appearance of the panes"] = true
L["Background color"] = true
L["Set the background color of the tooltips"] = true
L["Border color"] = true
L["Set the color of the border"] = true
L["Color outgoing"] = true
L["Set the color of outgoing messages"] = true
L["Color incoming"] = true
L["Set the color of incoming messages"] = true
L["Border style"] = true
L["Change the border style."] = true
L["Background style"] = true
L["Change the background style. Note that for some styles the background color needs to be set to white to show."] = true
L["Font"] = true
L["What font face to use."] = true
L["Font size"] = true
L["Select the size of the font"] = true
L["Colorised player names"] = true
L["Colorise the names of players by class"] = true
							
-----------------------------------
-----------------------------------
-- Modules

L["Modules"] = true
L["Enable "] = true
L["Settings"] = true

-- Broker
L["|c00ffff00Click|r |c001eff00to reply|r. |c00ffff00Control-click|r |c001eff00to open log. |c00ffff00Shift-click|r |c001eff00to delete player history|r"] = true
L["All"] = true
L["Allows you to quickly review your message history using your favourite Broker display.\n\nFor use with FuBar: Download the Broker2Fubar addon."] = true
L["Broker Plugin"] = true
L["Broker2FuBar options"] = true
L["Day"] = true
L["Hide minimap icon"] = true
L["Hour"] = true
L["Max frame height"] = true
L["Max tooltip width"] = true
L["Maximum height of tooltip before a scrollframe is used. 0 for automatic."] = true
L["Name"] = true
L["Open the Broker2FuBar options panel"] = true
L["Session"] = true
L["Show hints"] = true
L["Sort by"] = true
L["Time"] = true
L["Timeframe"] = true
L["Timestamp color"] = true
L["Use timestamp coloring for age of message"] = true
L["Week"] = true
				
-- Editbox
L["Editbox Plugin"] = true
L["This plugin will show your current conversation above the editbox when you are sending a whisper to someone."] = true
L["Lock"] = true
L["Locks the chatbox tooltip"] = true
L["Reset position"] = true
L["Reset the position of the chatbox tooltip"] = true
L["Hide in combat"] = true
L["Toggle wether the chatbox tooltip should be hidden in combat"] = true
L["Grow up"] = true
L["Toggle wether the chatbox tooltip should grow up or down"] = true
L["Snap to chatbox"] = true
L["Makes the pane stick to the chatbox"] = true


-- Chatter Settings  
L["Import Chatter Settings"] = true
L["Enables you to synchronise settings with Chatter; e.g. fonts, colors, borders, etc."] = true
L["Reload"] = true
L["Reload the Chatter settings"] = true
L["Font"] = true
L["Timestamp"] = true
L["Background / Border"] = true
L["Player Names"] = true