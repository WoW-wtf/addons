local mod = Whisp:NewModule("Editbox Plugin", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Whisp")
mod.modName = L["Editbox Plugin"]

local options = {
	lock = {
		type = "toggle",
		name = L["Lock"],
		desc = L["Locks the chatbox tooltip"],
		set = function(_,v) 
		mod.db.profile.locked = v
		if v == false then mod.db.char.snapToEditbox = false end
		mod.editboxFrame:EnableMouse(not v)
		end,
		get = function() return mod.db.profile.locked end,
	},
	snap = {
		type = "toggle",
		name = L["Snap to chatbox"],
		desc = L["Makes the pane stick to the chatbox"],
		set = function(_,v) 
		mod.db.char.snapToEditbox = v
		end,
		get = function() return mod.db.char.snapToEditbox end,
	},
	reset = {
		type = "execute",
		name = L["Reset position"],
		order = 200,
		desc = L["Reset the position of the chatbox tooltip"],
		func = function() mod:ResetPosition() end,
	},
	combatHide = {
		type = "toggle",
		name = L["Hide in combat"],
		desc = L["Toggle wether the chatbox tooltip should be hidden in combat"],
		set = function(_,v) mod.db.profile.hideInCombat = v end,
		get = function() return mod.db.profile.hideInCombat end,
	},  
	growup = {
		type = "toggle",
		name = L["Grow up"],
		desc = L["Toggle wether the chatbox tooltip should grow up or down"],
		get = function() return mod.db.char.growUp end,
		set = function(_,v) 
		mod.db.char.growUp = v 
		mod:ResetPosition()
		end,
	},  
}

local defaults = {
	profile = {
		hideInCombat = false,              -- Hide the chatbox tooltip when in combat
		locked = true,                     -- Locks the chatbox pane in place
	},
	char = {
		frameWidth = 400,                  -- Set the width and position of the pane
		frameLeft = 10, 
		frameTop = 370, 
		frameBottom = 400,
		growUp = true,                     -- Grow the pane upwards
		snapToEditbox = true,              -- Snap the pane to the editbox
	}
}
local editboxFrame = {}
local tellTarget = nil

function mod:OnInitialize()
	self.db = Whisp.db:RegisterNamespace("Editbox Plugin", defaults)
	editboxFrame = mod:CreateFrame()
	mod.editboxFrame = editboxFrame
end

function mod:OnEnable()
	self:RegisterMessage("WHISP_SKIN", "OnSkinUpdate")
	self:SecureHook("ChatEdit_UpdateHeader", "ChatEdit_Update")
	self:SecureHook("ChatEdit_DeactivateChat", "ChatEdit_Update")
end

function mod:OnDisable()
	editboxFrame:Hide()
	self:UnhookAll()
end

function mod:ChatEdit_Update(self)
	-- Optionally don't show the pane
	local activeWindow = ChatEdit_GetActiveWindow()
	if not activeWindow or (mod.db.profile.hideInCombat and InCombatLockdown()) then editboxFrame:Hide() return end
	local chattype = self:GetAttribute("chatType")
	if ( chattype == "WHISPER" or chattype == "BN_WHISPER") then
		tellTarget = self:GetAttribute("tellTarget")
		
		--making sure bnet whispers are getting saved properly
		if chattype == "BN_WHISPER" and not Whisp.db.profile.bnetnames then
			for i=1,BNGetNumFriends() do acc=C_BattleNet.GetFriendAccountInfo(i);if acc.accountName==tellTarget then tellTarget=acc.gameAccountInfo.characterName;break end end
		end
		
		if chattype == "BN_WHISPER" and Whisp.db.profile.bnetnames then
			for i=1,BNGetNumFriends() do acc=C_BattleNet.GetFriendAccountInfo(i);if acc.accountName==tellTarget then tellTarget=acc.battleTag;break end end
		end
		if Whisp.db.realm.chatHistory[tellTarget] then
			mod:ShowFrame(tellTarget)
		else 
			mod:ChatEdit_OnHide()
		end
	else 
		mod:ChatEdit_OnHide()
	end
end

function mod:ChatEdit_OnHide()
	tellTarget=nil
	editboxFrame:Hide()
end

function mod:OnSkinUpdate()
	Whisp:SkinMyFrame(editboxFrame)
end

function mod:CreateFrame()
	local frame = Whisp:CreateMyFrame("EDITBOX", mod.db.char.frameWidth)
	-- Set position and width first time
	frame:EnableMouse(true)
	-- Set draggable borders
	frame:SetResizable(true)
	frame.dragRight = mod:AddDragFrame(frame, "BOTTOMRIGHT", "BOTTOMRIGHT", "TOPRIGHT", "TOPRIGHT", "RIGHT")
	frame.dragLeft  = mod:AddDragFrame(frame, "BOTTOMLEFT", "BOTTOMLEFT", "TOPLEFT", "TOPLEFT", "LEFT")
	-- Set movement scripts
	frame:SetMovable(true)
	frame:SetScript("OnMouseDown", function(self, arg1) 
		if ((not mod.db.profile.locked) and (arg1 == "LeftButton")) then
			self:StartMoving()
			self.isMoving = true
		end
	end)
	frame:SetScript("OnMouseUp", function(self, arg1) 
		if ((not Whisp.db.profile.locked)  and (arg1 == "LeftButton")) then
			self:StopMovingOrSizing()
			self.isMoving = false
			mod:SavePosition()
		end
	end)
	frame:EnableMouse(not self.db.profile.locked)
	return frame
end

-- Setup draggable borders
function mod:AddDragFrame(parent, anchor1, align1, anchor2, align2, direction)
	frame = CreateFrame("Frame", nil, parent)
	frame:Show()
	frame:SetFrameLevel(parent:GetFrameLevel() + 10)
	frame:SetWidth(16)
	frame:SetPoint(anchor1, parent, align1, 0, 0)
	frame:SetPoint(anchor2, parent, align2, 0, 0)
	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", function(self, arg1) 
		if ((not Whisp.db.profile.locked) and (arg1 == "LeftButton")) then
			self:GetParent().isResizing = true
			self:GetParent():StartSizing(direction)
		end 
	end)
	frame:SetScript("OnMouseUp", function(self, arg1) 
		if self:GetParent().isResizing == true then 
			self:GetParent():StopMovingOrSizing()
			self:GetParent().isResizing = false
			mod:SavePosition()
			Whisp:SendMessage("WHISP_MESSAGE")
		end 
	end)
	return frame
end

function mod:ShowFrame(plr)
	if not plr then return end
	if self.db.char.snapToEditbox then
		mod:ResetPosition()
	else
		mod:SetPosition()
	end
	Whisp:UpdateMyFrame(editboxFrame, plr)
	editboxFrame:Show()
end

function mod:ResetPosition()
	local ChatFrameEditBox = ChatEdit_GetActiveWindow()
	if not ChatFrameEditBox then return end
	mod.db.char.frameWidth = ChatFrameEditBox:GetRight() - ChatFrameEditBox:GetLeft()
	mod.db.char.frameLeft = ChatFrameEditBox:GetLeft()
	mod.db.char.frameTop = ChatFrameEditBox:GetBottom()
	mod.db.char.frameBottom = ChatFrameEditBox:GetTop()
	mod:SetPosition()
end

function mod:SavePosition()
	mod.db.char.frameWidth = editboxFrame:GetRight() - editboxFrame:GetLeft()
	mod.db.char.frameLeft = editboxFrame:GetLeft()
	mod.db.char.frameTop = editboxFrame:GetTop()
	mod.db.char.frameBottom = editboxFrame:GetBottom()
end

function mod:SetPosition()
	editboxFrame:ClearAllPoints()
	if self.db.char.growUp then
		editboxFrame:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT", mod.db.char.frameLeft, mod.db.char.frameBottom)
	else
		editboxFrame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT", mod.db.char.frameLeft, mod.db.char.frameTop)
	end
	editboxFrame:SetWidth(mod.db.char.frameWidth)
end

function mod:GetOptions()
	return options
end

function mod:Info()
	return L["This plugin will show your current conversation above the editbox when you are sending a whisper to someone."]
end