---@diagnostic disable: duplicate-set-field
ItemUpgradeTipMythicPlusRowMixin = CreateFromMixins(ItemUpgradeTipResultsRowTemplateMixin)

ItemUpgradeTipMythicPlusRowMixin.Populate = ItemUpgradeTipTableResultsRowMixin.Populate
ItemUpgradeTipMythicPlusRowMixin.OnClick = ItemUpgradeTipTableResultsRowMixin.OnClick

function ItemUpgradeTipMythicPlusRowMixin:OnHide()
end
