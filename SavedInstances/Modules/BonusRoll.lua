local SI, L = unpack((select(2, ...)))
local Module = SI:NewModule("BonusRoll", "AceEvent-3.0")

local BonusFrame -- Frame attached to BonusRollFrame
local MAX_BONUS_ROLL_RECORD_LIMIT = 25 -- the max cap of bonus roll records
local BONUS_ROLL_REQUIRED_CURRENCY = 1580 -- bonus roll currency of current expansion
local ignoreItem = {
  [163827] = true, -- Quartermaster's Coin, obtained when failing a bonus roll in pvp
}

-- Lua functions
local _G = _G
local ipairs, pairs, select, sort, strsplit = ipairs, pairs, select, sort, strsplit
local time, tinsert, tonumber, tostring = time, tinsert, tonumber, tostring

-- WoW API / Variables
local C_Item_GetItemInfoInstant = C_Item.GetItemInfoInstant
local CreateFrame = CreateFrame
local GetDifficultyInfo = GetDifficultyInfo
local GetInstanceInfo = GetInstanceInfo
local GetRealZoneText = GetRealZoneText
local GetSubZoneText = GetSubZoneText

local GetBonusRollEncounterJournalLinkDifficulty = GetBonusRollEncounterJournalLinkDifficulty
local DifficultyUtil_ID_DungeonChallenge = DifficultyUtil.ID.DungeonChallenge

local function BonusRollShow()
  local t = SI.db.Toons[SI.thisToon]
  local BonusRollFrame = BonusRollFrame
  if not t or not BonusRollFrame then
    return
  end
  local bonus = SI:BonusRollCount(SI.thisToon, BonusRollFrame.CurrentCountFrame.currencyID)
  if not bonus or not SI.db.Tooltip.AugmentBonus then
    if BonusFrame then
      BonusFrame:Hide()
    end
    return
  end
  if not BonusFrame then
    BonusFrame = CreateFrame("Button", "SavedInstancesBonusRollFrame", BonusRollFrame, "ButtonFrameTemplate")
    BonusFrame:SetSize(32, 32)
    BonusFrame:SetPoint("LEFT", BonusRollFrame, "RIGHT", 0, 8)
    BonusFrame.text = BonusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    BonusFrame.text:SetPoint("CENTER")
    BonusFrame:SetScript("OnEnter", function()
      SI.hoverTooltip.ShowBonusTooltip(nil, { SI.thisToon, BonusFrame })
    end)
    BonusFrame:SetScript("OnLeave", function()
      if SI.indicatortip then
        SI.indicatortip:Hide()
      end
    end)
    BonusFrame:SetScript("OnClick", nil)
    SI:SkinFrame(BonusFrame, BonusFrame:GetName())
  end
  BonusFrame.text:SetText((bonus > 0 and "+" or "") .. bonus)
  BonusFrame:Show()
end
hooksecurefunc("BonusRollFrame_StartBonusRoll", BonusRollShow)

function Module:OnEnable()
  BonusRollShow() -- catch roll-on-load
  self:RegisterEvent("BONUS_ROLL_RESULT")
  self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
end

function Module:CHAT_MSG_MONSTER_YELL(event, msg, bossname)
  -- cheapest possible outdoor boss detection for players lacking a proper boss mod
  -- should work for sha and nalak, oon and gal report a related mob
  local t = SI.db.Toons[SI.thisToon]
  local now = time()
  if bossname and t then
    bossname = tostring(bossname) -- for safety
    local diff = select(4, GetInstanceInfo())
    if diff and #diff > 0 then
      bossname = bossname .. ": " .. diff
    end
    t.lastbossyell = bossname
    t.lastbossyelltime = now
    -- SI:Debug("CHAT_MSG_MONSTER_YELL: "..tostring(bossname));
  end
end

function Module:BONUS_ROLL_RESULT(event, rewardType, rewardLink, rewardQuantity, rewardSpecID, _, _, currencyID)
  local t = SI.db.Toons[SI.thisToon]
  SI:Debug(
    "BONUS_ROLL_RESULT:%s:%s:%s:%s (boss=%s|%s)",
    tostring(rewardType),
    tostring(rewardLink),
    tostring(rewardQuantity),
    tostring(rewardSpecID),
    tostring(t and t.lastboss),
    tostring(t and t.lastbossyell)
  )
  if not t then
    return
  end
  if not rewardType then
    return
  end -- sometimes get a bogus message, ignore it
  t.BonusRoll = t.BonusRoll or {}
  local now = time()
  local bossname
  -- Mythic+ Dungeon Roll
  if GetBonusRollEncounterJournalLinkDifficulty() == DifficultyUtil_ID_DungeonChallenge then
    local name, _, difficultyID, difficultyName = GetInstanceInfo()
    if difficultyID == DifficultyUtil_ID_DungeonChallenge then
      bossname = name .. ": " .. difficultyName
    else
      local tmp = {}
      for key, value in pairs(SI.db.History) do
        local _, name, _, diff = strsplit(":", key)
        if tonumber(diff) == DifficultyUtil_ID_DungeonChallenge then
          local tbl = {
            name = name .. ": " .. GetDifficultyInfo(diff),
            last = value.last,
          }
          tinsert(tmp, tbl)
        end
      end
      sort(tmp, function(l, r)
        return l.last > r.last
      end)
      bossname = tmp[1] and tmp[1].name
    end
  end
  if not bossname then
    bossname = t.lastboss
    if now > (t.lastbosstime or 0) + 3 * 60 then
      -- user rolled before lastboss was updated, ignore the stale one. Roll timeout is 3 min.
      bossname = nil
    end
    if not bossname and t.lastbossyell and now < (t.lastbossyelltime or 0) + 10 * 60 then
      bossname = t.lastbossyell -- yell fallback
    end
    if not bossname then
      bossname = GetSubZoneText() or GetRealZoneText() -- zone fallback
    end
  end
  local roll = {
    name = bossname,
    time = now,
    costCurrencyID = BonusRollFrame.CurrentCountFrame.currencyID,
  }
  if rewardType == "money" then
    roll.money = rewardQuantity
  elseif rewardType == "currency" then
    roll.currencyID = currencyID
    roll.money = rewardQuantity
  elseif rewardType == "item" then
    roll.item = rewardLink
  end
  tinsert(t.BonusRoll, 1, roll)
  for i = MAX_BONUS_ROLL_RECORD_LIMIT + 1, #t.BonusRoll do
    t.BonusRoll[i] = nil
  end
end

function SI:BonusRollCount(toon, currencyID)
  local t = SI.db.Toons[toon]
  if not t or not t.BonusRoll or #t.BonusRoll == 0 then
    return
  end
  currencyID = currencyID or BONUS_ROLL_REQUIRED_CURRENCY
  local count = 0
  for _, tbl in ipairs(t.BonusRoll) do
    if not tbl.costCurrencyID then
      break
    end
    if tbl.costCurrencyID == currencyID then
      if not tbl.item then
        count = count + 1
      else
        local itemID = C_Item_GetItemInfoInstant(tbl.item)
        if ignoreItem[itemID] then
          count = count + 1
        else
          break
        end
      end
    end
  end
  return count
end

function SI:BossRecord(toon, bossname, difficultyID, soft)
  local t = SI.db.Toons[toon]
  if not t then
    return
  end
  local now = time()
  -- boss mods can often detect completion before ENCOUNTER_END
  -- also some world bosses never send ENCOUNTER_END
  -- enough timeout to prevent overwriting, but short enough to prevent cross-boss contamination
  if soft and soft == false and (not bossname or now <= (t.lastbosstime or 0) + 120) then
    return
  end
  bossname = tostring(bossname) -- for safety
  local difficultyName = GetDifficultyInfo(difficultyID)
  if difficultyName and #difficultyName > 0 then
    bossname = bossname .. ": " .. difficultyName
  end
  t.lastboss = bossname
  t.lastbosstime = now
end
