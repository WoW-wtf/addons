local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("Whisp", "zhTW")
if not L then return end

-----------------------------------
-----------------------------------
-- Misc

-- Welcome message 
L["Whisp v%s by Anea. Type |cffffffff/whisp|r or right-click the icon for options."] = "Whisp v%s 作者 Anea. 請鍵入|cffffffff/whisp|r 或右擊圖示來設定."

-----------------------------------
-----------------------------------
-- Options

--General
L["General"] = true
L["General settings"] = true
L["Options"] = "選項"
L["Setup this mod to your needs"] = "跟據你的需要來設定插件"

-- Behaviour
L["Behaviour"] = true
L["Setup the behaviour of the pane"] = true
L["Lines shown"] = "顯示行數"
L["The number of lines to show in the tooltips"] = "設定顯示多少行數"
L["Oldest to newest"] = "舊到新"
L["Show messages oldest to newest"] = "訊息顯示由最舊的到最新的"

-- History
L["History"] = "歷史"
L["How long should messages be cached (in hours). When set to zero, messages will be saved during the session."] = "訊息應緩存多久(以小時計). 當設置為零時, 訊息將被儲存在節錄內."
L["Clear"] = "清除"
L["Empties the history"] = "清除歷史"
L["Are you sure you want to clear the history?"] = "您確定要清除歷史?"

-- Appearance options
L["Appearance"] = "外觀"
L["Setup the appearance of the panes"] = "設定方格外觀"
L["Background color"] = "背景顏色"
L["Set the background color of the tooltips"] = "設定提示框的背景顏色"
L["Border color"] = "邊框顏色"
L["Set the color of the border"] = "設定提示框的邊框顏色"
L["Color outgoing"] = "送出顏色"
L["Set the color of outgoing messages"] = "設定送出訊息的顏色"
L["Color incoming"] = "傳入顏色"
L["Set the color of incoming messages"] = "設定傳入訊息的顏色"
L["Border style"] = "邊框風格"
L["Change the border style."] = "改變邊框風格"
L["Background style"] = "背景風格"
L["Change the background style. Note that for some styles the background color needs to be set to white to show."] = "改變背景風格. 請注意,對於一些背景風格的顏色需要設置為白色來顯示"
L["Font"] = "字型"
L["What font face to use."] = "選用字型"
L["Font size"] = "字型大少"
L["Select the size of the font"] = "選用字型的大少"
L["Colorised player names"] = true
L["Colorise the names of players by class"] = true


-----------------------------------
-----------------------------------
-- Modules

L["Modules"] = true
L["Enable "] = true
L["Settings"] = true

-- Broker
L["Broker Plugin"] = true
L["Allows you to quickly review your message history using your favourite Broker display.\n\nFor use with FuBar: Download the Broker2Fubar addon."] = true
L["Click to reply\nControl-click to open log"] = "點擊來回覆\nCTRL-點擊來開啟紀錄"
L["Timeframe"] = "時間標記"
L["Hour"] = "小時"
L["Session"] = "節錄"
L["Day"] = "日"
L["Week"] = "星期"
L["All"] = "全部"
L["Sort by"] = "分類"
L["Time"] = "時間"
L["Name"] = "名字"
L["Broker2FuBar options"] = true
L["Open the Broker2FuBar options panel"] = true
  
-- Editbox
L["Editbox Plugin"] = true
L["This plugin will show your current conversation above the editbox when you are sending a whisper to someone."] = true
L["Lock"] = "鎖定"
L["Locks the chatbox tooltip"] = "鎖定聊天窗"
L["Reset"] = "重置"
L["Reset the position of the chatbox tooltip"] = "重置聊天窗位置"
L["Hide in combat"] = "戰鬥中隱藏"
L["Toggle wether the chatbox tooltip should be hidden in combat"] = "切換聊天窗在戰鬥中隱藏"
L["Grow up"] = "向上展開"
L["Toggle wether the chatbox tooltip should grow up or down"] = "切換聊天窗向上或向下展開"
L["Snap to chatbox"] = true
L["Makes the pane stick to the chatbox"] = true

-- Chatter Settings
L["Import Chatter Settings"] = "Chatter 設定"
L["Enables you to synchronise settings with Chatter; e.g. fonts, colors, borders, etc."] = true
L["Reload"] = "重載"
L["Reload the Chatter settings"] = "重新載入Chatter設置"
L["Font"] = "字型"
L["Timestamp"] = "時間標記"
L["Background / Border"] = "背景 / 邊框"
L["Player Names"] = "玩家名字"