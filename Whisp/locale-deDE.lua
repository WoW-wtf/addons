local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("Whisp", "deDE")
if not L then return end

-----------------------------------
-----------------------------------
-- Misc

-- Welcome message 
L["Whisp v%s by Anea. Type |cffffffff/whisp|r or right-click the icon for options."] = "Whisp v%s von Anea. Schreibe |cffffffff/whisp|r oder Rechtsklick auf das Symbol für weitere Optionen."

-----------------------------------
-----------------------------------
-- Options

--General
L["General"] = "Allgemeines"
L["General settings"] = "Allgemeine Einstellungen"
L["Options"] = "Optionen"
L["Setup this mod to your needs"] = "Stelle dieses Addon nach deinen Vorlieben ein"

-- Behaviour
L["Behaviour"] = "Verhalten"
L["Setup the behaviour of the pane"] = "Verhalten des Panels einstellen"
L["Lines shown"] = "Sichtbare Zeilen"
L["The number of lines to show in the tooltips"] = "Die Anzahl der Zeilen, die in den Tooltips angezeigt wird"
L["Oldest to newest"] = "Älteste zuerst"
L["Show messages oldest to newest"] = "Zeige die ältesten Nachrichten zuerst"

-- History
L["History"] = "Verlauf"
L["How long should messages be cached (in hours). When set to zero, messages will be saved during the session."] = "Anzahl in Stunden, die Nachrichten gecached werden sollen. Ist dieser Wert 0, werden Nachrichten während der Session gespeichert."
L["Clear"] = "Löschen"
L["Empties the history"] = "Löscht den Verlauf"
L["Are you sure you want to clear the history?"] = "Willst du den Verlauf wirklich löschen?"
L["BattleTags"] = true
L["Save whisper history under BattleTags instead of character names (Should persist between sessions.)"] = "Whisperverlauf unter BattleTags statt den Charakternamen speichern (Sollte persistent sein.)"

-- Appearance options
L["Appearance"] = "Aussehen"
L["Setup the appearance of the panes"] = "Das Aussehen der Panel einstellen"
L["Background color"] = "Hintergrundfarbe"
L["Set the background color of the tooltips"] = "Hintergrundfarbe der Tooltips einstellen"
L["Border color"] = "Umrandungsfarbe"
L["Set the color of the border"] = "Umrandungsfarbe einstellen"
L["Color outgoing"] = "Ausgehende Farbe"
L["Set the color of outgoing messages"] = "Farbe der ausgehenden Nachrichten einstellen"
L["Color incoming"] = "Eingehende Farbe"
L["Set the color of incoming messages"] = "Farbe der eingehenden Nachrichten einstellen"
L["Border style"] = "Umrandungsstil"
L["Change the border style."] = "Umrandungsstil ändern"
L["Background style"] = "Hintergrundstil"
L["Change the background style. Note that for some styles the background color needs to be set to white to show."] = "Hintergrundstil einstellen. Für manche Stile muss die Hintergrundfarbe auf weiß eingestellt sein."
L["Font"] = "Schriftart"
L["What font face to use."] = "Zu verwendende Schriftart"
L["Font size"] = "Schriftgröße"
L["Select the size of the font"] = "Farbe der Schrift auswählen"
L["Colorised player names"] = "Spielernamen einfärben"
L["Colorise the names of players by class"] = "Färb die Spielernamen nach Klasse ein"
							
-----------------------------------
-----------------------------------
-- Modules

L["Modules"] = true
L["Enable "] = true
L["Settings"] = true

-- Broker
L["|c00ffff00Click|r |c001eff00to reply|r. |c00ffff00Control-click|r |c001eff00to open log. |c00ffff00Shift-click|r |c001eff00to delete player history|r"] = "|c00ffff00Klick|r |c001eff00zum Antworten|r. |c00ffff00Strg-Klick|r |c001eff00um den Verlauf zu öffnen. |c00ffff00Shift-Klick|r |c001eff00um Spielerverlauf zu Löschen|r"
L["All"] = "Alle"
L["Allows you to quickly review your message history using your favourite Broker display.\n\nFor use with FuBar: Download the Broker2Fubar addon."] = "Ermöglicht die schnelle Anzeige des Verlaufs mit einem beliebigen Broker display.\n\nFür die Verwendung mit FuBar: Broker2Fubar addon notwendig."
L["Broker Plugin"] = true
L["Broker2FuBar options"] = "Broker2FuBar Optionen"
L["Day"] = "Tag"
L["Hide minimap icon"] = "Minimapicon verstecken"
L["Hour"] = "Stunde"
L["Max frame height"] = "Maximale Framehöhe"
L["Max tooltip width"] = "Maximale Tooltipbreite"
L["Maximum height of tooltip before a scrollframe is used. 0 for automatic."] = "Maximum Tooltiphöhe bevor scrollen möglich ist. 0 für automatisch."
L["Name"] = true
L["Open the Broker2FuBar options panel"] = "Broker2FuBar Optionsfenster öffnen"
L["Session"] = "Sitzung"
L["Show hints"] = "Hinweise anzeigen"
L["Sort by"] = "Sortieren nach"
L["Time"] = "Zeit"
L["Timeframe"] = "Zeitfenster"
L["Timestamp color"] = "Zeitstempelfarbe"
L["Use timestamp coloring for age of message"] = "Zeitstempel nach Alter der Nachricht einfärben"
L["Week"] = "Woche"
				
-- Editbox
L["Editbox Plugin"] = true
L["This plugin will show your current conversation above the editbox when you are sending a whisper to someone."] = "Dieses Plugin zeigt aktuelle Konversationen oberhalb der Editbox wenn Whispers versendet werden."
L["Lock"] = "Sperren"
L["Locks the chatbox tooltip"] = "Sperrt das Chatbox Tooltip"
L["Reset position"] = "Position zurücksetzen"
L["Reset the position of the chatbox tooltip"] = "Setzt die Position des Chatbox Tooltips zurück"
L["Hide in combat"] = "Im Kampf verstecken"
L["Toggle whether the chatbox tooltip should be hidden in combat"] = "Legt fest, ob das Chatbox Tooltip im Kampf versteckt sein soll"
L["Grow up"] = "Nach oben wachsen"
L["Toggle wether the chatbox tooltip should grow up or down"] = "Legt fest, ob das Chatbox Tooltip nach oben oder unten größer werden soll"
L["Snap to chatbox"] = "An Chatbox anheften"
L["Makes the pane stick to the chatbox"] = "Fixiert das Panel an der Chatbox"


-- Chatter Settings  
L["Import Chatter Settings"] = "Chatter Einstellungen importieren"
L["Enables you to synchronise settings with Chatter; e.g. fonts, colors, borders, etc."] = "Ermöglicht Synchronisation mit Chatter Einstellungen; z.B. Schriftarten, Farben, Umrandungen, etc."
L["Reload"] = "Neu Laden"
L["Reload the Chatter settings"] = "Lädt die Chatter Einstellungen neu"
L["Font"] = "Schriftart"
L["Timestamp"] = "Zeitstempel"
L["Background / Border"] = "Hintergrund / Umrandung"
L["Player Names"] = "Spielernamen"