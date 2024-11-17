local T, C, L, G = unpack(select(2, ...))

StaticPopupDialogs[G.addon_name.."Reset Positions Confirm"] = {
	text = "",
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1, 
	whileDead = true,
	preferredIndex = 3,
}

StaticPopupDialogs[G.addon_name.."Import Confirm"] = {
	text = L["导入确认"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1, 
	whileDead = true,
	preferredIndex = 3,
}

StaticPopupDialogs[G.addon_name.."Cannot Import"] = {
	text = L["无法导入"],
	button1 = ACCEPT,
	hideOnEscape = 1, 
	whileDead = true,
	preferredIndex = 3,
}