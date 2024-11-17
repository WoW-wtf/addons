local T, C, L, G = unpack(select(2, ...))

G.Options = {
	GeneralOption = {
		{ -- 标题:通用
			option_type = "title",
			text = L["通用"],
		},
		{ -- 隐藏小地图图标
			key = "hide_minimap",
			option_type = "check",
			width = .5,
			text = L["隐藏小地图图标"],
			apply = function()
				T.ToggleMinimapButton()
			end,
		},
		{ -- 控制台缩放
			key = "gui_scale",
			option_type = "ddmenu",
			width = .5,
			text = L["控制台缩放"],
			option_table = {
				{60, "60%"},
				{70, "70%"},
				{80, "80%"},
				{90, "90%"},
				{100, "100%"},
				{110, "110%"},
				{120, "120%"},
			},
			apply = function()
				T.UpdateGUIScale()
			end,
		},
		{ -- 语音包
			key = "sound_pack",
			option_type = "ddmenu",
			width = .5,
			text = L["语音包"],
			option_table = G.SoundPacks,
			apply = function()
				T.apply_sound_pack()
			end,
		},
		{ -- 5 声道
			key = "sound_channel",
			option_type = "ddmenu",
			width = .5,
			text = L["声道"],
			option_table = {
				{"Master", L["主声道"]},
				{"Dialog", L["对话"]},
				{"SFX", L["音效"]},
			},
		},
		{ -- TTS选项
			key = "tts_speaker",
			option_type = "ddmenu",
			width = .5,
			text = L["文本转语音"],
			option_table = G.ttsSpeakers,
		},
		{ -- TTS测试
			key = "tts_speaker_test",
			option_type = "button",
			width = .5,
			text = L["文本转语音测试"],
			apply = function()
				T.SpeakText(L["文本转语音测试"])
			end,
		},
		{ -- 按职责加载
			key = "role_enable",
			option_type = "check",
			width = .5,
			text = string.format(L["按职责加载%s"], T.GetFlagIconStr("0,1,2")),
			apply = function()
				T.UpdateAll()
			end,
		},
		{ -- 昵称检测
			key = "nickname_check",
			option_type = "check",
			width = .5,
			text = L["昵称实时检测"],
			apply = function()
				T.ToggleNicknameCheck()
			end,
		},
		{ -- 10 名字显示方式
			key = "name_format",
			option_type = "ddmenu",
			width = .5,
			text = L["名字显示方式"],
			option_table = {
				{"realname", L["总是显示角色名"]},
				{"nickname", L["优先显示昵称"]},
			},
		},
		{ -- 标题:全局禁用
			option_type = "title",
			text = L["全局禁用"],
		},
		{ -- 禁用插件
			key = "disable_all",
			option_type = "check",
			width = .5,
			text = L["禁用插件"],
			apply = function()
				T.UpdateAll()
			end,
		},
		{ -- 禁用团队标记
			key = "disable_rmark",
			option_type = "check",
			width = .5,
			text = L["禁用团队标记"],
		},
		{ -- 静音
			key = "disable_sound",
			option_type = "check",
			width = .5,
			text = MUTE,
			apply = function()
				T.EditSoundAlert("enable")
			end,
		},
		{ -- 15 禁发聊天讯息
			key = "disbale_msg",
			option_type = "check",
			width = .5,
			text = L["禁发聊天讯息"],
			apply = function()
				
			end,
		},
		{ -- 禁用团队框架提示
			key = "disable_rf",
			option_type = "check",
			width = .5,
			text = L["禁用团队框架提示"],
			apply = function()
				T.EditRFIconAlert("enable")
			end,
		},
		{ -- 禁用姓名板提示
			key = "disable_plate",
			option_type = "check",
			width = .5,
			text = L["禁用姓名板提示"],
			apply = function()
				T.UpdateAll()
			end,
		},
		{ -- 团队标记提示
			option_type = "title",
			text = L["团队标记提示"],
		},
		{ -- 启用
			key = "rm",
			option_type = "check",
			width = 1,
			text = L["启用"],
			apply = function()
				T.EditRMFrame("enable")
			end,
		},
		{ -- 20 动态战术板
			option_type = "title",
			text = L["动态战术板"],
		},
		{ -- 启用
			key = "tl",
			option_type = "check",
			width = 1,
			text = L["启用"],
			apply = function()
				T.EditTimeline("enable") 
			end,
		},
		{ -- 团队战术板
			key = "tl_use_raid",
			option_type = "check",
			width = .5,
			text = L["团队战术板"],
			rely = "tl",
		},
		{ -- 个人战术板
			key = "tl_use_self",
			option_type = "check",
			width = .5,
			text = L["个人战术板"],
			rely = "tl",
		},
		{ -- 字体大小
			key = "tl_font_size",
			option_type = "slider",
			width = .5,
			text = L["字体大小"],
			min = 10,
			max = 30,
			step = 1,
			apply = function()
				T.EditTimeline("font_size")
			end,
			rely = "tl",
		},
		{ -- 25 提前时间
			key = "tl_advance",
			option_type = "slider",
			width = .5,
			text = L["提前时间"],
			min = 2,
			max = 120,
			step = 1,
			rely = "tl",
		},
		{ -- 显示战术板时间
			key = "tl_show_time",
			option_type = "check",
			width = .5,
			text = L["显示战术板时间"],
			apply = function()
				T.EditTimeline("format")
			end,
			rely = "tl",
		},
		{ -- 高亮我的技能目标
			key = "tl_glowtarget",
			option_type = "check",
			width = .5,
			text = L["高亮我的技能目标"],
			rely = "tl",
		},	
		{ -- 显示计时条
			key = "tl_bar",
			option_type = "check",
			width = 1,
			text = L["显示计时条"],
			apply = function()
				T.EditTimeline("bar")
			end,
			rely = "tl",
		},
		{ -- 计时条时间
			key = "tl_bar_dur",
			option_type = "slider",
			width = .5,
			text = L["计时条时间"],
			min = 3,
			max = 15,
			step = 1,
			rely = "tl_bar",
		},
		{ -- 30 朗读与我相关的内容
			key = "tl_sound",
			option_type = "check",
			width = 1,
			text = L["朗读与我相关的内容"],
			rely = "tl",
		},
		{ -- 语音提示时间
			key = "tl_sound_dur",
			option_type = "slider",
			width = .5,
			text = L["语音提示时间"],
			min = 2,
			max = 10,
			step = 1,
			rely = "tl_sound",
		},
		{ -- 语音提示音量
			key = "tl_sound_volume",
			option_type = "slider",
			width = .5,
			text = L["语音提示音量"],
			min = 0,
			max = 100,
			step = 10,
			rely = "tl_sound",
		},
		{ -- 文字提示与我相关的内容
			key = "tl_text",
			option_type = "check",
			width = 1,
			text = L["文字提示与我相关的内容"],
			apply = function()
				T.EditTimeline("text")
			end,
			rely = "tl",
		},
		{ -- 文字提示时间
			key = "tl_text_dur",
			option_type = "slider",
			width = .5,
			text = L["文字提示时间"],
			min = 2,
			max = 10,
			step = 1,
			rely = "tl_text",
		},
		{ -- 35 显示秒数
			key = "tl_text_show_dur",
			option_type = "check",
			width = .5,
			text = L["显示秒数"],
			rely = "tl_text",
		},		
		{ -- 标题:请求技能
			option_type = "title",
			text = L["请求技能"],
		},
		{ -- 接收法术请求
			key = "cs",
			option_type = "check",
			width = 1,
			text = L["接收法术请求"],
			apply = function()
				T.EditASFrame("enable")
			end,
		},
		{ -- 提示音
			key = "cs_sound",
			option_type = "ddmenu",
			width = .5,
			text = L["提示音"],
			option_table = {
				{"sound_phone", L["音效电话"]},
				{"sound_water", L["音效水滴"]},
				{"sound_bell", L["音效铃声"]},
				{"speak", L["朗读请求内容"]},
				{"none", L["无"]},
			},
			apply = function()
				local test_spell_name = T.GetSpellInfo(10060)
				T.Play_askspell_sound(G.PlayerName, test_spell_name)
			end,
			rely = "cs",
		},
		{ -- 请求技能提示
			option_type = "string",
			width = 2,
			text = L["请求技能提示"],
		},
		{ -- 40 团队PA光环
			option_type = "title",
			text = L["团队PA光环"],
		},
		{ -- 启用
			key = "raid_pa",
			option_type = "check",
			width = 1,
			text = L["启用"],
			apply = function()
				T.EditRaidPAFrame("enable")
			end,
		},
		{ -- 单个框架宽度
			key = "raid_pa_width",
			option_type = "slider",
			width = .5,
			text = L["单个框架宽度"],
			min = 40,
			max = 120,
			step = 5,
			apply = function()
				T.EditRaidPAFrame("size")
			end,
			rely = "raid_pa",
		},
		{ -- 单个框架高度
			key = "raid_pa_height",
			option_type = "slider",
			width = .5,
			text = L["单个框架高度"],
			min = 15,
			max = 30,
			step = 1,
			apply = function()
				T.EditRaidPAFrame("size")
			end,
			rely = "raid_pa",
		},
		{ -- 字体大小
			key = "raid_pa_fsize",
			option_type = "slider",
			width = .5,
			text = L["字体大小"],
			min = 12,
			max = 30,
			step = 1,
			apply = function()
				T.EditRaidPAFrame("size")
			end,
			rely = "raid_pa",
		},
		{ -- 45 图标个数
			key = "raid_pa_icon_num",
			option_type = "slider",
			width = .5,
			text = L["图标个数"],
			min = 1,
			max = 4,
			step = 1,
			apply = function()
				T.EditRaidPAFrame("size")
			end,
			rely = "raid_pa",
		},
		{ -- 粘贴MRT模板
			key = "pa_copy_mrt",
			option_type = "button",
			width = .5,
			text = L["粘贴MRT模板"],
			apply = function()
				T.GetMrtForPrivateAuraRaidFrame()
			end,
			rely = "raid_pa",
		},
	},
	IconAlertOption = {
		{ -- 1 标题:图标提示
			option_type = "title",
			text = L["图标提示"],
		},
		{ -- 2 图标大小
			key = "icon_size",
			option_type = "slider",
			width = .5,
			text = L["图标大小"],
			min = 40,
			max = 100,
			step = 1,
			apply = function()
				T.EditAlertFrame("icon_size")
			end,		
		},
		{ -- 3 图标间距
			key = "icon_space",
			option_type = "slider",
			width = .5,
			text = L["图标间距"],
			min = 0,
			max = 20,
			step = 1,
			apply = function()
				T.EditAlertFrame("icon_space")
			end,		
		},
		{ -- 4 大字体大小
			key = "font_size",
			option_type = "slider",
			width = .5,
			text = L["大字体大小"],
			min = 15,
			max = 30,
			step = 1,
			apply = function()
				T.EditAlertFrame("font_size")
			end,		
		},
		{ -- 5 小字体大小
			key = "ifont_size",
			option_type = "slider",
			width = .5,
			text = L["小字体大小"],
			min = 10,
			max = 20,
			step = 1,
			apply = function()
				T.EditAlertFrame("ifont_size")
			end,
		},
		{ -- 6 排列方向
			key = "grow_dir",
			option_type = "ddmenu",
			width = .5,
			text = L["排列方向"],
			option_table = {
				{"RIGHT", L["向左延申"]},
				{"LEFT", L["向右延申"]},
				{"BOTTOM", L["向上延申"]},
				{"TOP", L["向下延申"]},
			},
			apply = function()
				T.EditAlertFrame("grow_dir")
			end,
		},
		{ -- 7 显示法术时间
			key = "show_spelldur",
			option_type = "check",
			width = .5,
			text = L["显示法术时间"],
			apply = function()
				T.EditAlertFrame("spelldur")
			end,
		},
		{ -- 8 启用
			key = "enable_pa",
			option_type = "check",
			width = 1,
			text = L["启用"].."Private Aura",
			apply = function()
				T.EditAlertFrame("enable")
			end,
		},
		{ -- 9 Private Aura 图标大小
			key = "privateaura_icon_size",
			option_type = "slider",
			width = .5,
			text = "Private Aura"..L["图标大小"],
			min = 40,
			max = 300,
			step = 1,
			apply = function()
				T.EditAlertFrame("icon_size")
			end,		
			rely = "enable_pa",
		},
		{ -- 10 Private Aura 图标透明度
			key = "privateaura_icon_alpha",
			option_type = "slider",
			width = .5,
			text = "Private Aura"..L["透明度"],
			min = .05,
			max = 1,
			step = .05,
			apply = function()
				T.EditAlertFrame("alpha")
			end,		
			rely = "enable_pa",
		},		
	},
	TimerbarOption = {
		{ -- 1 标题:计时条提示
			option_type = "title",
			text = L["计时条提示"],
		},
		{ -- 2 长度
			key = "bar_width",
			option_type = "slider",
			width = .5,
			text = L["长度"],
			min = 160,
			max = 500,
			step = 5,
			apply = function()
				T.EditTimerbarFrame("bar_size")
			end,
		},
		{ -- 3 高度
			key = "bar_height",
			option_type = "slider",
			width = .5,
			text = L["高度"],
			min = 16,
			max = 30,
			step = 1,
			apply = function()
				T.EditTimerbarFrame("bar_size")
			end,
		},
	},
	PlateAlertOption = {
		{ -- 1 标题:姓名板提示
			option_type = "title",
			text = L["姓名板提示"],
		},
		{ -- 3 图标大小
			key = "size",
			option_type = "slider",
			width = 1,
			text = L["图标大小"],
			min = 20,
			max = 50,
			step = 1,
			apply = function()
				T.EditPlateIcons("icon_size")
			end,
		},
		{ -- 4 垂直距离
			key = "y",
			option_type = "slider",
			width = .5,
			text = L["垂直距离"],
			min = -100,
			max = 100,
			step = 1,
			apply = function()
				T.EditPlateIcons("y")
			end,
		},
		{ -- 5 水平距离
			key = "x",
			option_type = "slider",
			width = .5,
			text = L["水平距离"],
			min = -100,
			max = 100,
			step = 1,
			apply = function()
				T.EditPlateIcons("x")
			end,
		},
		{ -- 6 预备打断音效
			key = "interrupt_sound",
			option_type = "ddmenu",
			width = .5,
			text = L["预备打断音效"],
			option_table = {
				{"interrupt", L["打断音效语音"].."1"},
				{"interrupt_cast", L["打断音效语音"].."2"},
				{"interrupt_prepare", L["打断音效语音"].."3"},
				{"sound_phone", L["音效电话"]},
				{"none", L["无"]},
			},
			apply = function()
				T.Play_interrupt_sound()
			end,
		},
		{ -- 7 打断音效
			key = "interrupt_sound_cast",
			option_type = "ddmenu",
			width = .5,
			text = L["打断音效"],
			option_table = {
				{"interrupt", L["打断音效语音"].."1"},
				{"interrupt_cast", L["打断音效语音"].."2"},
				{"interrupt_prepare", L["打断音效语音"].."3"},
				{"sound_phone", L["音效电话"]},
				{"none", L["无"]},
			},
			apply = function()
				T.Play_interrupt_sound_cast()
			end,
		},
		{ -- 8 只显示我负责的打断
			key = "interrupt_only_mine",
			option_type = "check",
			width = 1,
			text = L["只显示我负责的打断"],
			apply = function()
				 T.EditPlateIcons("interrupt")
			end,
		},
		{ -- 9 姓名板打断图标提示
			option_type = "string",
			width = 3,
			text = L["姓名板打断图标提示"],
		},
	},
	RFIconOption = {
		{ -- 1 标题:团队框架提示
			option_type = "title",
			text = L["团队框架提示"],
		},
		{ -- 2 法术图标尺寸
			key = "RFIcon_size",
			option_type = "slider",
			width = .5,
			text = L["法术图标"]..L["尺寸"],
			min = 20,
			max = 40,
			step = 1,
			apply = function()
				T.EditRFIconAlert("icon_size")
			end,
		},
		{ -- 3 团队序号尺寸
			key = "RFIndex_size",
			option_type = "slider",
			width = .5,
			text = L["团队序号"]..L["尺寸"],
			min = 30,
			max = 60,
			step = 1,
			apply = function()
				T.EditRFIconAlert("index_size")
			end,
		},
	},
	TextAlertOption = {
		{ -- 1 标题:文字提示
			option_type = "title",
			text = L["文字提示"],
		},	
		{ -- 2 字体大小
			key = "font_size",
			option_type = "slider",
			width = .5,
			text = L["文字提示"]..L["字体大小"],
			min = 20,
			max = 50,
			step = 1,
			apply = function()
				T.EditTextFrame("font_size")
			end,
		},
		{ -- 3 字体大小2
			key = "font_size_big",
			option_type = "slider",
			width = .5,
			text = L["文字提示2"]..L["字体大小"],
			min = 40,
			max = 70,
			step = 1,
			apply = function()
				T.EditTextFrame("font_size")
			end,
		},
	},
	RaidInfo = {
		{ -- 1 标题:团队信息
			option_type = "title",
			text = L["团队信息"],
		},
	},
}

function T.GetOptionInfo(path)
	local OptionCategroy = path[1]
	local key = path[2]
	for _, info in pairs(G.Options[OptionCategroy]) do
		if info.key == key then
			return info
		end
	end
end
