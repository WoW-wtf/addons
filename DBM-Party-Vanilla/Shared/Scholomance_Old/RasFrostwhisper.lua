local mod	= DBM:NewMod("RasFrostwhisper", "DBM-Party-Vanilla", DBM:IsPostCata() and 16 or 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20240316010232")
mod:SetCreatureID(10508)
mod:SetEncounterID(mod:IsClassic() and 2810 or 456)
mod:SetZone(289)

mod:RegisterCombat("combat")
