local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "zhCN")

if not L then return end

L["true"] = "是"
L["false"] = "否"

L["addon_set"] = "插件集"
L["settings_tips"] = "设置"
L["enable_all_tips"] = "启用所有插件"
L["disable_all_tips"] = "禁用所有插件"
L["addon_set_op_tips"] = "将当前启用的插件列表加入/移出插件集"
L["reset_tips"] = "重置"
L["lock_tips"] = "已锁定"
L["cannot_unlock_tips"] = "该插件无法被解除锁定"
L["edit_remark_error_too_long"] = "备注过长"
L["edit_remark_error_name_duplicate"] = "与插件“%s”名称重复"
L["edit_remark_error_title_duplicate"] = "与插件“%s”标题重复"
L["edit_remark_error_remark_duplicate"] = "与插件“%s”备注重复"
L["reload_ui_tips_title"] = "需要重载的插件"

L["settings_dynamic_edit_box_delete_tips"] = "删除"
L["settings_slider_confirm_tips"] = "保存并应用"
L["settings_group_expand_all_tips"] = "展开全部"
L["settings_group_collapse_all_tips"] = "折叠全部"

L["settings_group_general"] = "综合"
L["settings_addon_icon_display_mode"] = "插件图标显示方式"
L["settings_addon_icon_dislay_invisble"] = "从不"
L["settings_addon_icon_dislay_invisble_tooltip"] = "不显示插件图标"
L["settings_addon_icon_display_only_available"] = "有插件图标则显示"
L["settings_addon_icon_display_only_available_tooltip"] = "仅对具有图标的插件显示"
L["settings_addon_icon_display_always"] = "总是"
L["settings_addon_icon_display_always_tooltip"] = "所有插件都显示图标，没有图标的将以问号显示"
L["settings_ui_scale"] = "框体缩放"
L["settings_group_load_indicator"] = "插件加载指示器"
L["settings_load_indicator_display_mode"] = "显示方式"
L["settings_load_indicator_display_mode_tooltip"] = "部分插件名称附带颜色（比如：DBM），这影响了插件加载染色的可读性，此选项用于配置加载指示器的显示方式。"
L["settings_load_indicator_dislay_invisble"] = "从不"
L["settings_load_indicator_dislay_invisble_tooltip"] = "不显示插件指示器，同时移除插件名称附带的颜色"
L["settings_load_indicator_display_only_colorful"] = "仅对彩色插件名显示"
L["settings_load_indicator_display_only_colorful_tooltip"] = "仅对名称附带颜色的插件显示"
L["settings_load_indicator_display_always"] = "总是"
L["settings_load_indicator_display_always_tooltip"] = "所有插件都显示加载指示器，无论其名称是否附带颜色"
L["settings_load_indicator_color_reload"] = "重载颜色"
L["settings_load_indicator_color_reload_description"] = "需重载的插件的色值"
L["settings_load_indicator_color_unloaded"] = "未加载颜色"
L["settings_load_indicator_color_unloaded_description"] = "未加载的插件的色值"
L["settings_load_indicator_color_unloadable"] = "无法加载颜色"
L["settings_load_indicator_color_unloadable_description"] = "无法加载的插件的色值"
L["settings_load_indicator_color_loaded"] = "已加载颜色"
L["settings_load_indicator_color_loaded_description"] = "已加载的插件的色值"
L["settings_load_indicator_color_disabled"] = "未启用颜色"
L["settings_load_indicator_color_disabled_description"] = "未启用的插件的色值"
L["settings_group_addon_set"] = "插件集"
L["settings_addon_set_load_condition_detect"] = "载入条件检测"
L["settings_addon_set_load_condition_detect_tooltip"] = "如果当前场景下有合适的插件集，则弹窗提示。"
L["settings_addon_set_load_condition_prompt_auto_dismiss_time"] = "自动消失时间"
L["settings_addon_set_load_condition_prompt_auto_dismiss_time_tooltip"] = "设置载入条件提示弹窗的自动消失时间。为0，则禁用自动消失。"
L["settings_addon_set_load_condition_prompt_position_save"] = "位置记忆"
L["settings_addon_set_load_condition_prompt_position_save_tooltip"] = "设置是否启用载入条件提示弹窗位置记忆"

L["addon_detail_basic_info"] = "基本信息"
L["addon_detail_name"] = "名称："
L["addon_detail_title"] = "标题："
L["addon_detail_remark"] = "备注："
L["addon_detail_notes"] = "说明："
L["addon_detail_author"] = "作者："
L["addon_detail_version"] = "版本："
L["addon_detail_dep_info"] = "依赖信息"
L["addon_detail_dependencies"] = "依赖项："
L["addon_detail_optional_deps"] = "可选依赖："
L["addon_detail_status_info"] = "状态信息"
L["addon_detail_load_status"] = "加载状态："
L["addon_detail_unload_reason"] = "未加载原因："
L["addon_detail_enable_status"] = "启用状态："
L["addon_detail_load_on_demand"] = "按需加载："
L["addon_detail_memory_usage"] = "内存占用："
L["addon_detail_no_dependency"] = "此插件不依赖任何插件"
L["addon_detail_in_addon_set"] = "在插件集内："
L["addon_detail_does_not_in_addon_set"] = "否"
L["addon_detail_loaded"] = "已加载"
L["addon_detail_unload"] = "未加载"
L["addon_detail_enabled"] = "已启用"
L["addon_detail_disabled"] = "未启用"
L["addon_detail_version_debug"] = "调试版本"
L["addon_detail_lock_tips_title"] = "插件锁定"
L["addon_detail_lock_tips"] = "插件会保持现在的启用状态，其将无法被启用或禁用。\n启用全部、禁用全部及应用插件集时，会将其忽略，除非解除锁定。\n\n如果你在角色选择界面将该插件启用或禁用，则启用状态会以你设置的为准。"
L["addon_detail_unlock_tips"] = "解除锁定"
L["addon_detail_addon_set_op_tips"] = "加入/移出插件集"

L["addon_set_active_label"] = "当前插件集"
L["addon_set_inactive_tip"] = "未选择插件集"
L["addon_set_list"] = "插件集列表"
L["addon_set_clear_tips"] = "停止使用插件集"
L["addon_set_apply_tips"] = "应用当前选中插件集“%s”"
L["addon_set_apply_alert"] = "插件集“%s”已启用"
L["addon_set_apply_later"] = "稍后"
L["addon_set_apply_error_unsave"] = "插件集“%s”有未保存的改动，请保存后再应用"
L["addon_set_add_tips"] = "添加插件集"
L["addon_set_remove_tips"] = "删除当前选中插件集“%s”"
L["addon_set_new"] = "新建插件集"
L["addon_set_new_label"] = "插件集是若干插件的组合，请为其取名，并确保其名称唯一。"
L["addon_set_name_error_too_long"] = "插件集名称过长"
L["addon_set_name_error_duplicate"] = "插件集名称重复"
L["addon_set_delete_confirm"] = "确认删除插件集\n%s"
L["addon_set_addon_switch"] = "加入/移出插件集"
L["addon_set_save_addon_list_tips"] = "保存当前选中插件到“%s”"
L["addon_set_replace_addons_tips"] = "将当前已启用的插件加入到插件集“%s”，未启用的插件会被移出。"
L["addon_set_enable_all_tips"] = "将所有插件加入“%s”"
L["addon_set_disable_all_tips"] = "将所有插件移出“%s”"
L["addon_set_can_not_find"] = "未找到名为“%s”的插件集"
L["addon_set_not_perfect_match_tips"] = "插件集“%s”未完全匹配。\n左键点击替换：启用插件集内的所有插件并禁用其它所有插件\n右键点击合并：启用插件集内的所有插件，该操作不会禁用目前已启用但不属于当前插件集的插件。\n任何操作都不会修改被锁定的插件的启用状态，无论其是否属于当前插件集"
L["addon_set_not_perfect_match_enabled_but_not_in_addon_set"] = "已启用但不在插件集内（%d）"
L["addon_set_not_perfect_match_disabled_but_in_addon_set"] = "未启用但在插件集内（%d）"
L["addon_set_current"] = "当前插件集\n%s"

L["addon_set_choice_enable_all_tips"] = "选择所有插件集"
L["addon_set_choice_disable_all_tips"] = "取消选择所有插件集"
L["addon_set_choice_merge_tips"] = "合并到所选插件集\n当前插件列表"
L["addon_set_choice_replace_tips"] = "替换所选插件集\n当前插件列表"
L["addon_set_choice_delete_tips"] = "从所选插件集中删除\n当前插件列表"

L["addon_set_settings_group_basic"] = "基础信息"
L["addon_set_settings_name"] = "名称"
L["addon_set_settings_enabled"] = "启用"
L["addon_set_settings_enabled_tooltip"] = "启用或禁用插件集决定其是否参与载入条件检查"
L["addon_set_settings_group_load_condition"] = "载入条件"
L["addon_set_settings_condition_name_and_realm"] = "玩家名称/服务器"
L["addon_set_settings_condition_name_and_realm_any"] = "(*)任何"
L["addon_set_settings_condition_name_and_realm_name_tooltip"] = "玩家名"
L["addon_set_settings_condition_name_and_realm_realm_tooltip"] = "服务器"
L["addon_set_settings_condition_name_and_realm_tips"] = "过滤格式：“名称”，“名称-服务器”，“-服务器”，可以使用“\\”转义“-”"
L["addon_set_settings_condition_name_and_realm_error_too_much_dash"] = "%s内含有过多的“-”，你可能需要使用\\转义"
L["addon_set_settings_condition_name_and_realm_error_duplicate"] = "已存在相同的角色名称/服务器过滤格式：%s"
L["addon_set_settings_condition_name_and_realm_error_empty"] = "未获取到有效的角色名或服务器"
L["addon_set_settings_condition_warmode_tips"] = "选择是否在战争模式下载入插件集"
L["addon_set_settings_condition_warmode_none"] = "无"
L["addon_set_settings_condition_warmode_enabled"] = "开启"
L["addon_set_settings_condition_warmode_disabled"] = "关闭"
L["addon_set_settings_condition_warmode_choice_none"] = "不参与条件检查"
L["addon_set_settings_condition_warmode_choice_enabled"] = "开启战争模式时"
L["addon_set_settings_condition_warmode_choice_disabled"] = "关闭战争模式时"
L["addon_set_settings_condition_max_level"] = "满级"
L["addon_set_settings_condition_maxlevel_tips"] = "选择是否在满级时载入插件集"
L["addon_set_settings_condition_maxlevel_none"] = "无"
L["addon_set_settings_condition_maxlevel_enabled"] = "是"
L["addon_set_settings_condition_maxlevel_disabled"] = "否"
L["addon_set_settings_condition_maxlevel_choice_none"] = "不参与条件检查"
L["addon_set_settings_condition_maxlevel_choice_enabled"] = "满级"
L["addon_set_settings_condition_maxlevel_choice_disabled"] = "非满级"
L["addon_set_settings_condition_faction"] = "玩家阵营"
L["addon_set_settings_condition_faction_tips"] = "选择载入插件集时的阵营"
L["addon_set_settings_condition_faction_none"] = "无"
L["addon_set_settings_condition_faction_choice_none"] = "不参与条件检查"
L["addon_set_settings_condition_specialization_role"] = "专精职责"
L["addon_set_settings_condition_race"] = "玩家种族"
L["addon_set_settings_condition_specialization"] = "职业和专精"
L["addon_set_settings_condition_instance_type"] = "副本类型"
L["addon_set_settings_condition_instance_type_none"] = "野外"
L["addon_set_settings_condition_instance_type_party"] = "地下城"
L["addon_set_settings_condition_instance_type_raid"] = "团队副本"
L["addon_set_settings_condition_instance_type_arena"] = "竞技场"
L["addon_set_settings_condition_instance_type_pvp"] = "战场"
L["addon_set_settings_condition_instance_type_scenario"] = "场景战役"
L["addon_set_settings_condition_instance_difficulty_type"] = "副本难度类型"
L["addon_set_settings_condition_instance_difficulty_type_dungeon_normal"] = "地下城（普通）"
L["addon_set_settings_condition_instance_difficulty_type_dungeon_heroic"] = "地下城（英雄）"
L["addon_set_settings_condition_instance_difficulty_type_dungeon_mythic"] = "地下城（史诗）"
L["addon_set_settings_condition_instance_difficulty_type_dungeon_timewalking"] = "地下城（时光漫游）"
L["addon_set_settings_condition_instance_difficulty_type_legecy_raid_10_normal"] = "旧版10人团队副本（普通）"
L["addon_set_settings_condition_instance_difficulty_type_legacy_raid_25_normal"] = "旧版25人团队副本（普通）"
L["addon_set_settings_condition_instance_difficulty_type_legecy_raid_10_heroic"] = "旧版10人团队副本（英雄）"
L["addon_set_settings_condition_instance_difficulty_type_legacy_raid_25_heroic"] = "旧版25人团队副本（英雄）"
L["addon_set_settings_condition_instance_difficulty_type_legacy_lfr"] = "旧版团队副本（随机）"
L["addon_set_settings_condition_instance_difficulty_type_legacy_raid_40"] = "旧版40人团队副本"
L["addon_set_settings_condition_instance_difficulty_type_scenario_normal"] = "场景战役（普通）"
L["addon_set_settings_condition_instance_difficulty_type_scenario_heroic"] = "场景战役（英雄）"
L["addon_set_settings_condition_instance_difficulty_type_raid_lfr"] = "团队副本（随机）"
L["addon_set_settings_condition_instance_difficulty_type_raid_normal"] = "团队副本（普通）"
L["addon_set_settings_condition_instance_difficulty_type_raid_heroic"] = "团队副本（英雄）"
L["addon_set_settings_condition_instance_difficulty_type_raid_mythic"] = "团队副本（史诗）"
L["addon_set_settings_condition_instance_difficulty_type_raid_timewalking"] = "团队副本（时光漫游）"
L["addon_set_settings_condition_instance_difficulty_type_island_normal"] = "海岛探险（普通）"
L["addon_set_settings_condition_instance_difficulty_type_island_heroic"] = "海岛探险（英雄）"
L["addon_set_settings_condition_instance_difficulty_type_island_mythic"] = "海岛探险（史诗）"
L["addon_set_settings_condition_instance_difficulty_type_island_pvp"] = "海岛探险（PVP）"
L["addon_set_settings_condition_instance_difficulty_type_warfront_normal"] = "战争前线（普通）"
L["addon_set_settings_condition_instance_difficulty_type_warfront_heroic"] = "战争前线（英雄）"
L["addon_set_settings_condition_instance_difficulty"] = "副本难度"
L["addon_set_settings_condition_mythic_plus_affix"] = "史诗钥石词缀"

L["addon_set_condition_tooltip_label"] = "插件集\n%s\n\n满足以下条件：\n%s"
L["addon_set_condition_met_none"] = "插件集未设置条件"
L["addon_set_switch_tips_dialog_label"] = "检测到当前场景下更适合的插件集"
L["addon_set_condition_met_count"] = "命中%d个条件"

L["load_addon"] = "加载此插件"
L["enable_addon"] = "启用插件"
L["disable_addon"] = "禁用插件"
L["edit_remark"] = "编辑备注"
L["enable_switch"] = "启用/禁用插件"