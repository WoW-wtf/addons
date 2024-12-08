local T, C, L, G = unpack(select(2, ...))

local LCG = LibStub("LibCustomGlow-1.0")

---------------------------------------------
----------  团队框架动画边框模板  -----------
---------------------------------------------
T.ProcGlow_Start = LCG.ProcGlow_Start
T.ProcGlow_Stop = LCG.ProcGlow_Stop

local GlowRaidFramebyUnit_Show = function(glow_type, glow_key, unit, color, dur, offset, th)
	local f = T.GetUnitFrame(unit)
	if f then
		if glow_type == "blz" then
			LCG.ButtonGlow_Start(f, color)
		elseif glow_type == "proc" then
			LCG.ProcGlow_Start(f, {key = glow_key, color = color, xOffset = offset, yOffset = offset})
		elseif glow_type == "pixel" then
			LCG.PixelGlow_Start(f, color, 12, .25, nil, th or 3, offset or 0, offset or 0, true, glow_key)
		end
		if dur then
			C_Timer.After(dur, function()
				if glow_type == "blz" then
					LCG.ButtonGlow_Stop(f)
				elseif glow_type == "proc" then
					LCG.ProcGlow_Stop(f, glow_key)
				elseif glow_type == "pixel" then
					LCG.PixelGlow_Stop(f, glow_key)
				end
			end)
		end
	end
end
T.GlowRaidFramebyUnit_Show = GlowRaidFramebyUnit_Show

local GlowRaidFramebyUnit_Hide = function(glow_type, glow_key, unit)
	local f = T.GetUnitFrame(unit)
	if f then
		if glow_type == "blz" then
			LCG.ButtonGlow_Stop(f)
		elseif glow_type == "proc" then
			LCG.ProcGlow_Stop(f, glow_key)
		elseif glow_type == "pixel" then
			LCG.PixelGlow_Stop(f, glow_key)
		end
	end
end
T.GlowRaidFramebyUnit_Hide = GlowRaidFramebyUnit_Hide

local GlowRaidFrame_HideAll = function(glow_type, glow_key)
	if glow_type == "blz" then
		LCG.ButtonGlowPool:ReleaseAll()		
	elseif glow_type == "proc" then		
		if not glow_key then return end
		local current = LCG.ProcGlowPool:GetNextActive()
		while current do
			local f = current:GetParent()
			if f then
				LCG.ProcGlow_Stop(f, glow_key)
			end
			current = LCG.ProcGlowPool:GetNextActive(current)
		end
	elseif glow_type == "pixel" then
		if not glow_key then return end
		local current = LCG.GlowFramePool:GetNextActive()
		while current do
			local f = current:GetParent()
			if f then
				LCG.PixelGlow_Stop(f, glow_key)
			end
			current = LCG.GlowFramePool:GetNextActive(current)
		end
	end
end
T.GlowRaidFrame_HideAll = GlowRaidFrame_HideAll

---------------------------------------------
--------------  计时圆圈模板  ---------------
---------------------------------------------
local spinnerFunctions = {}

function spinnerFunctions.SetTexture(self, texture)
  for i = 1, 3 do
	self.textures[i]:SetTexture(texture)
  end
end

function spinnerFunctions.Color(self, r, g, b, a)
  for i = 1, 3 do
    self.textures[i]:SetVertexColor(r, g, b, a);
  end
end

function spinnerFunctions.SetProgress(self, region, angle1, angle2)
  self.region = region;
  self.angle1 = angle1;
  self.angle2 = angle2;

  local crop_x = 1.41
  local crop_y = 1.41

  local texRotation = region.effectiveTexRotation or 0
  local mirror_h = region.mirror_h or false;
  if region.mirror then
    mirror_h = not mirror_h
  end
  local mirror_v = region.mirror_v or false;

  local width = region.width + 2 * self.offset;
  local height = region.height + 2 * self.offset;

  if (angle2 - angle1 >= 360) then
    -- SHOW everything
    self.coords[1]:SetFull();
    self.coords[1]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[1]:Show();

    self.coords[2]:Hide();
    self.coords[3]:Hide();
    return;
  end
  if (angle1 == angle2) then
    self.coords[1]:Hide();
    self.coords[2]:Hide();
    self.coords[3]:Hide();
    return;
  end

  local index1 = floor((angle1 + 45) / 90);
  local index2 = floor((angle2 + 45) / 90);

  if (index1 + 1 >= index2) then
    self.coords[1]:SetAngle(width, height, angle1, angle2);
    self.coords[1]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[1]:Show();
    self.coords[2]:Hide();
    self.coords[3]:Hide();
  elseif(index1 + 3 >= index2) then
    local firstEndAngle = (index1 + 1) * 90 + 45;
    self.coords[1]:SetAngle(width, height, angle1, firstEndAngle);
    self.coords[1]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[1]:Show();

    self.coords[2]:SetAngle(width, height, firstEndAngle, angle2);
    self.coords[2]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[2]:Show();

    self.coords[3]:Hide();
  else
    local firstEndAngle = (index1 + 1) * 90 + 45;
    local secondEndAngle = firstEndAngle + 180;

    self.coords[1]:SetAngle(width, height, angle1, firstEndAngle);
    self.coords[1]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[1]:Show();

    self.coords[2]:SetAngle(width, height, firstEndAngle, secondEndAngle);
    self.coords[2]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[2]:Show();

    self.coords[3]:SetAngle(width, height, secondEndAngle, angle2);
    self.coords[3]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[3]:Show();
  end
end

local defaultTexCoord = {ULx = 0,ULy = 0,LLx = 0,LLy = 1,URx = 1,URy = 0,LRx = 1,LRy = 1}

local function createTexCoord(texture)
  local coord = {
	ULx = 0,ULy = 0,LLx = 0,LLy = 1,URy = 0,LRx = 1,LRy = 1,ULvx = 0,
	ULvy = 0,LLvx = 0,LLvy = 0,URvx = 0,LRvx = 0,LRvy = 0,
	texture = texture
  }

  function coord:MoveCorner(width, height, corner, x, y)
    local rx = defaultTexCoord[corner .. "x"] - x
    local ry = defaultTexCoord[corner .. "y"] - y
    coord[corner .. "vx"] = -rx * width
    coord[corner .. "vy"] = ry * height

    coord[corner .. "x"] = x
    coord[corner .. "y"] = y
  end

  function coord:Hide()
    coord.texture:Hide()
  end

  function coord:Show()
    coord:Apply()
    coord.texture:Show()
  end

  function coord:SetFull()
    coord.ULx = 0;
    coord.ULy = 0;
    coord.LLx = 0;
    coord.LLy = 1;
    coord.URx = 1;
    coord.URy = 0;
    coord.LRx = 1;
    coord.LRy = 1;

    coord.ULvx = 0;
    coord.ULvy = 0;
    coord.LLvx = 0;
    coord.LLvy = 0;
    coord.URvx = 0;
    coord.URvy = 0;
    coord.LRvx = 0;
    coord.LRvy = 0;
  end

  function coord:Apply()
    coord.texture:SetVertexOffset(UPPER_RIGHT_VERTEX, coord.URvx, coord.URvy);
    coord.texture:SetVertexOffset(UPPER_LEFT_VERTEX, coord.ULvx, coord.ULvy);
    coord.texture:SetVertexOffset(LOWER_RIGHT_VERTEX, coord.LRvx, coord.LRvy);
    coord.texture:SetVertexOffset(LOWER_LEFT_VERTEX, coord.LLvx, coord.LLvy);

    coord.texture:SetTexCoord(coord.ULx, coord.ULy, coord.LLx, coord.LLy, coord.URx, coord.URy, coord.LRx, coord.LRy);
  end

  local exactAngles = {
    {0.5, 0},  -- 0°
    {1, 0},    -- 45°
    {1, 0.5},  -- 90°
    {1, 1},    -- 135°
    {0.5, 1},  -- 180°
    {0, 1},    -- 225°
    {0, 0.5},  -- 270°
    {0, 0}     -- 315°
  }

  local function angleToCoord(angle)
    angle = angle % 360;

    if (angle % 45 == 0) then
      local index = floor (angle / 45) + 1;
      return exactAngles[index][1], exactAngles[index][2];
    end

    if (angle < 45) then
      return 0.5 + tan(angle) / 2, 0;
    elseif (angle < 135) then
      return 1, 0.5 + tan(angle - 90) / 2 ;
    elseif (angle < 225) then
      return 0.5 - tan(angle) / 2, 1;
    elseif (angle < 315) then
      return 0, 0.5 - tan(angle - 90) / 2;
    elseif (angle < 360) then
      return 0.5 + tan(angle) / 2, 0;
    end
  end

  local pointOrder = { "LL", "UL", "UR", "LR", "LL", "UL", "UR", "LR", "LL", "UL", "UR", "LR" }

  function coord:SetAngle(width, height, angle1, angle2)
	local index = floor((angle1 + 45) / 90);

    local middleCorner = pointOrder[index + 1];
    local startCorner = pointOrder[index + 2];
    local endCorner1 = pointOrder[index + 3];
    local endCorner2 = pointOrder[index + 4];

    -- LL => 32, 32
    -- UL => 32, -32
    self:MoveCorner(width, height, middleCorner, 0.5, 0.5)
    self:MoveCorner(width, height, startCorner, angleToCoord(angle1));

    local edge1 = floor((angle1 - 45) / 90);
    local edge2 = floor((angle2 -45) / 90);

    if (edge1 == edge2) then
      self:MoveCorner(width, height, endCorner1, angleToCoord(angle2));
    else
      self:MoveCorner(width, height, endCorner1, defaultTexCoord[endCorner1 .. "x"], defaultTexCoord[endCorner1 .. "y"])
    end

    self:MoveCorner(width, height, endCorner2, angleToCoord(angle2));
  end

  local function TransformPoint(x, y, scalex, scaley, texRotation, mirror_h, mirror_v, user_x, user_y)
    -- 1) Translate texture-coords to user-defined center
    x = x - 0.5
    y = y - 0.5

    -- 2) Shrink texture by 1/sqrt(2)
    x = x * 1.4142
    y = y * 1.4142

    -- Not yet supported for circular progress
    -- 3) Scale texture by user-defined amount
    x = x / scalex
    y = y / scaley

    -- 4) Apply mirroring if defined
    if mirror_h then
      x = -x
    end
    if mirror_v then
      y = -y
    end

    local cos_rotation = cos(texRotation)
    local sin_rotation = sin(texRotation)

    -- 5) Rotate texture by user-defined value
    x, y = cos_rotation * x - sin_rotation * y, sin_rotation * x + cos_rotation * y

    -- 6) Translate texture-coords back to (0,0)
    x = x + 0.5
    y = y + 0.5

    x = x + (user_x or 0);
    y = y + (user_y or 0);

    return x, y
  end

  function coord:Transform(scalex, scaley, texRotation, mirror_h, mirror_v, user_x, user_y)

      coord.ULx, coord.ULy = TransformPoint(coord.ULx, coord.ULy, scalex, scaley,
                                            texRotation, mirror_h, mirror_v, user_x, user_y)
      coord.LLx, coord.LLy = TransformPoint(coord.LLx, coord.LLy, scalex, scaley,
                                            texRotation, mirror_h, mirror_v, user_x, user_y)
      coord.URx, coord.URy = TransformPoint(coord.URx, coord.URy, scalex, scaley,
                                            texRotation, mirror_h, mirror_v, user_x, user_y)
      coord.LRx, coord.LRy = TransformPoint(coord.LRx, coord.LRy, scalex, scaley,
                                            texRotation, mirror_h, mirror_v, user_x, user_y)
  end

  return coord
end

local function createSpinner(parent, layer, drawlayer)
  local spinner = {}
  spinner.textures = {}
  spinner.coords = {}
  spinner.offset = 0

  for i = 1, 3 do
    local texture = parent:CreateTexture(nil, layer)
    texture:SetSnapToPixelGrid(false)
    texture:SetTexelSnappingBias(0)
    texture:SetDrawLayer(layer, drawlayer)
    texture:SetAllPoints(parent)
    spinner.textures[i] = texture

    spinner.coords[i] = createTexCoord(texture)
  end

  for k, v in pairs(spinnerFunctions) do
    spinner[k] = v
  end

  return spinner
end

local CircularSetValueFunctions = {
  ["CLOCKWISE"] = function(self, progress)
    local startAngle = 0
    local endAngle = 360
    progress = progress or 0
    self.progress = progress

    if (progress < 0) then
      progress = 0
    end

    if (progress > 1) then
      progress = 1
    end

    local pAngle = (endAngle - startAngle) * progress + startAngle;
    self.foregroundSpinner:SetProgress(self, startAngle, pAngle);
  end,
  ["ANTICLOCKWISE"] = function(self, progress)
    local startAngle = 0
    local endAngle = 360
    progress = progress or 0
    self.progress = progress

    if (progress < 0) then
      progress = 0;
    end

    if (progress > 1) then
      progress = 1;
    end
    progress = 1 - progress

    local pAngle = (endAngle - startAngle) * progress + startAngle
    self.foregroundSpinner:SetProgress(self, pAngle, endAngle)
  end
}

local function CreateCircleCD(parent, color, cd_reverse, text)
	local cd = CreateFrame("Frame", parent:GetName().."_JSTCircle", parent)
	
	cd:SetPoint("CENTER", parent, "CENTER")
	cd:Hide()
	
	cd.foregroundSpinner = createSpinner(cd, "ARTWORK", 1)
	cd.foregroundSpinner:SetTexture(G.media.ring)
	
	cd.bg = cd:CreateTexture(nil, "BACKGROUND")
	cd.bg:SetTexture(G.media.circle)
	cd.bg:SetAllPoints()
	
	if text then
		cd.dur_text = T.createtext(cd, "OVERLAY", 20, "OUTLINE", "CENTER")
		cd.dur_text:SetPoint("TOP", cd, "TOP", 0, -20)
	end
	
	cd.orientation = cd_reverse and "CLOCKWISE" or "ANTICLOCKWISE"
	cd.SetValueOnTexture = CircularSetValueFunctions[cd.orientation]
	
	function cd.SetColor(self, R, G, B)
		self.foregroundSpinner:Color(R, G, B)
		self.bg:SetVertexColor(R, G, B, .1)
		if self.dur_text then
			self.dur_text:SetTextColor(R, G, B)
		end
	end
		
	function cd.SetTime(self, duration, expirationTime)
		local progress = 1
		if (duration ~= 0) then
			local remaining = expirationTime - GetTime()
			progress = remaining / duration
			progress = progress > 0.0001 and progress or 0.0001
			
			self:SetValueOnTexture(progress)
		end
	end
	
	function cd.ProgressColor(self, color_mode, color_arg, duration, expirationTime)
		local progress = 1 --  1->0
		if (duration ~= 0) then
			local remaining = expirationTime - GetTime()
			progress = remaining / duration
			progress = progress > 0.0001 and progress or 0.0001
		end
		if color_mode == "fade" then
			if progress <= .5 then
				cd:SetColor(1, progress*2, 0) -- 黄色到红色
			else
				cd:SetColor((1-progress)*2, 1, 0) -- 绿色到黄色
			end
		elseif color_mode == "divide" then
			if progress <= color_arg/duration then
				cd:SetColor(1, 0, 0) -- 红色
			else
				cd:SetColor(0, 1, 0) -- 绿色
			end
		elseif color_mode == "threesections" then
			local v1, v2 = string.split(",", color_arg)
			v1, v2 = tonumber(v1), tonumber(v2)
			if v1 < v2 then -- 越大越绿 "4,6"
				if progress < v1/duration then
					cd:SetColor(1, 0, 0) -- 红色
				elseif progress < v2/duration then
					cd:SetColor(1, 1, 0) -- 黄色
				else
					cd:SetColor(0, 1, 0) -- 绿色
				end
			elseif v1 > v2 then -- 越小越绿 "6,4"
				if progress > v1/duration then
					cd:SetColor(1, 0, 0) -- 红色
				elseif progress > v2/duration then
					cd:SetColor(1, 1, 0) -- 黄色
				else
					cd:SetColor(0, 1, 0) -- 绿色
				end
			end		
		end
	end
	
	cd.t = 0
	function cd.begin(self, exp_time, dur, color_mode, color_arg)	
		local s = parent:GetWidth()
		self.width, self.height = s, s
		self:SetSize(s, s)
		if not color_mode then
			if color then
				cd:SetColor(unpack(color))
			else
				cd:SetColor(1, 1, 1)
			end
		end
		self:SetScript("OnUpdate", function(self, e)
			self.t = self.t + e
			if self.t > 0.02 then
				local remain = exp_time - GetTime()
				if remain > 0 then
					self:SetTime(dur, exp_time)
					if color_mode then
						self:ProgressColor(color_mode, color_arg, dur, exp_time)
					end
					if self.dur_text then
						self.dur_text:SetText(string.format("%.1f", remain))
					end
				else
					self:Hide()
					self:SetScript("OnUpdate", nil)
					if self.dur_text then
						self.dur_text:SetText("")
					end
				end
				self.t = 0
			end
		end)
		self:Show()
	end
	
	function cd.stop(self)
		self:Hide()
		self:SetScript("OnUpdate", nil)
		if self.dur_text then
			self.dur_text:SetText("")
		end
	end
	
	return cd
end
T.CreateCircleCD = CreateCircleCD

---------------------------------------------
---------------  计时条模板  ----------------
---------------------------------------------
local CreateTimerBar = function(parent, icon, glow, midtext, hide, width, height, rgb, tag)
	local w = width or 160
	local h = height or 16
	local color = rgb or {1, .8, .3}

	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetWidth(w)
	bar:SetHeight(h)
	
	bar:SetStatusBarTexture(G.media.blank)
	bar:SetStatusBarColor(unpack(color))
	T.createborder(bar)
		
	--bar:GetStatusBarTexture():SetHorizTile(false)
	--bar:GetStatusBarTexture():SetVertTile(false)
	--bar:SetOrientation("HORIZONTAL")
	
	if icon then
		bar.icon = bar:CreateTexture(nil, "OVERLAY")
		bar.icon:SetTexCoord( .1, .9, .1, .9)
		bar.icon:SetSize(h, h)
		bar.icon:SetPoint("RIGHT", bar, "LEFT", -2, 0)
		bar.iconbd = T.createbdframe(bar.icon)	
		bar.icon:SetTexture(icon)
		
		bar:HookScript("OnSizeChanged", function(self, width, height)
			self.icon:SetSize(height, height)
		end)
	end
	
	bar.left = T.createtext(bar, "OVERLAY", floor(h*.6), "OUTLINE", "LEFT")
	bar.left:SetPoint("LEFT", bar, "LEFT", 5, 0)
						
	bar.right = T.createtext(bar, "OVERLAY", floor(h*.6), "OUTLINE", "RIGHT")
	bar.right:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
	
	bar:HookScript("OnSizeChanged", function(self, width, height)
		self.left:SetFont(G.Font, floor(height*.6), "OUTLINE")
		self.right:SetFont(G.Font, floor(height*.6), "OUTLINE")
	end)
	
	if midtext then
		bar.mid = T.createtext(bar, "OVERLAY", floor(h*.6), "OUTLINE", "CENTER")
		bar.mid:SetPoint("CENTER", bar, "CENTER", 0, 0)
		bar:HookScript("OnSizeChanged", function(self, width, height)
			self.mid:SetFont(G.Font, floor(height*.6), "OUTLINE")
		end)
	end
	
	if glow then
		bar.glow = CreateFrame("Frame", nil, bar, "BackdropTemplate")
		bar.glow:SetPoint("TOPLEFT", bar, -7, 7)
		bar.glow:SetPoint("BOTTOMRIGHT", bar, 7, -7)
		bar.glow:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\AddOns\\JST\\media\\glow",
			edgeSize = 7,
				insets = { left = 7, right = 7, top = 7, bottom = 7,}
		})
		bar.glow:SetBackdropColor(0, 0, 0, 0)
		bar.glow:SetBackdropBorderColor(unpack(color))
		
		bar.anim = bar:CreateAnimationGroup()
		bar.anim:SetLooping("BOUNCE")
		
		bar.anim:SetScript("OnStop", function(self)
			bar.glow:SetAlpha(1)
		end)
		
		bar.timer = bar.anim:CreateAnimation("Alpha")
		bar.timer:SetChildKey("glow")
		bar.timer:SetDuration(.3)
		bar.timer:SetFromAlpha(1)
		bar.timer:SetToAlpha(.2)
	end
	
	if tag then
		for i = 1, tag do
			bar["tag"..i] = bar:CreateTexture(nil, "OVERLAY")
			bar["tag"..i]:SetTexture(G.media.blank)
			bar["tag"..i]:SetVertexColor(1, 1, 1)
			bar["tag"..i]:SetSize(2, h)
			bar["tag_perc"..i] = 0
		end
		
		bar.pointtag = function(i, perc)
			local tag = bar["tag"..i]
			if tag then
				if perc then
					bar["tag_perc"..i] = perc
					tag:SetPoint("LEFT", bar, "LEFT", perc*bar:GetWidth(), 0)
					tag:Show()
				else
					bar["tag_perc"..i] = 0
					tag:ClearAllPoints()
					tag:Hide()
				end
			end
		end
		
		bar:HookScript("OnSizeChanged", function(self, width, height)
			for i = 1, tag do
				bar["tag"..i]:SetSize(2, height)
				local cur_perc = bar["tag_perc"..i]
				if cur_perc and cur_perc ~= 0 then
					bar.pointtag(i, cur_perc)
				end
			end
		end)
	end
	
	bar.t = 0
	bar.update_rate = .02
	
	if hide then
		bar:Hide()
	end
	
	return bar
end
T.CreateTimerBar = CreateTimerBar

local StartTimerBar = function(bar, dur, show, dur_text, reverse_fill)
	bar:SetMinMaxValues(0, dur)
	bar.exp_time = GetTime() + dur	
	bar:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > self.update_rate then		
			local remain = self.exp_time - GetTime()
			if remain > 0 then
				if dur_text then
					self.right:SetText(T.FormatTime(remain))
				end
				if reverse_fill then
					self:SetValue(remain)
				else
					self:SetValue(dur - remain)
				end
			else
				self:SetScript("OnUpdate", nil)
				if dur_text then
					self.right:SetText("")
				end
				if reverse_fill then
					self:SetValue(0)
				else
					self:SetValue(dur)
				end
				if show then
					self:Hide()
				end
			end
			self.t = 0
		end
	end)
	if show then
		bar:Show()
	end
end
T.StartTimerBar = StartTimerBar

local StartLoopBar = function(bar, dur, loop, show, dur_text, reverse_fill)
	bar:SetMinMaxValues(0, dur)
	bar.loop = loop
	bar.exp_time = GetTime() + dur
	
	if bar.OnStartLoop then
		bar:OnStartLoop()
	end
	
	bar:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > self.update_rate then		
			local remain = self.exp_time - GetTime()
			if remain > 0 then
				if dur_text then
					self.right:SetText(T.FormatTime(remain))
				end
				if reverse_fill then
					self:SetValue(remain)
				else
					self:SetValue(dur - remain)
				end
			else
				if not self.loop then -- 无限循环
					self.exp_time = GetTime() + dur
					if self.OnLoop then
						self:OnLoop()
					end
				else
					self.loop = self.loop - 1
					if self.loop > 0 then -- 有剩余次数
						self.exp_time = GetTime() + dur
						if self.OnLoop then
							self:OnLoop()
						end
					else -- 达到循环次数
						self:SetScript("OnUpdate", nil)
						if dur_text then
							self.right:SetText("")
						end
						if reverse_fill then
							self:SetValue(0)
						else
							self:SetValue(dur)
						end
						if show then
							self:Hide()
						end
					end
				end
			end
			self.t = 0
		end
	end)
	if show then
		bar:Show()
	end
end
T.StartLoopBar = StartLoopBar

local StopTimerBar = function(bar, hide, dur_text, reverse_fill)
	local _, max_v = bar:GetMinMaxValues()
	bar:SetScript("OnUpdate", nil)
	if dur_text then
		bar.right:SetText("")
	end
	if reverse_fill then
		bar:SetValue(0)
	else
		bar:SetValue(max_v)
	end
	if hide then
		bar:Hide()
	end
end
T.StopTimerBar = StopTimerBar

---------------------------------------------
----------------  小圆圈模板  ---------------
---------------------------------------------
local CreateCircle = function(frame, rm, hide)
	local circle = CreateFrame("Frame", nil, frame)
	circle:SetSize(35, 35)
	circle.t = 0
	circle.update_rate = 0.05
	
	circle.tex = circle:CreateTexture(nil, "ARTWORK")
	circle.tex:SetAllPoints()
	circle.tex:SetTexture(G.media.circle)
	
	if rm then
		circle.rt_icon = circle:CreateTexture(nil, "ARTWORK")
		circle.rt_icon:SetPoint("BOTTOM", circle, "TOP", 0, 0)
		circle.rt_icon:SetSize(15, 15)
		circle.rt_icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		SetRaidTargetIconTexture(circle.rt_icon, rm)
	end
	
	circle.text = T.createtext(circle, "OVERLAY", 12, "OUTLINE", "CENTER")
	circle.text:SetPoint("CENTER", circle, "CENTER")
	
	circle.t = 0
	circle.update_rate = .05
	
	if hide then
		circle:Hide()
	end
	
	return circle
end
T.CreateCircle = CreateCircle

---------------------------------------------
-------------  可移动框体模板  --------------
---------------------------------------------
T.CreateMovableFrame = function(parent, tag, width, height, point, name, text)
	if not parent[tag] then
		local frame = CreateFrame("Frame", parent:GetName()..(name or "_SubFrame"), parent)	
		if text then
			frame.movingname = string.format("%s [%s]", parent.movingname, text)
		else
			frame.movingname = parent.movingname
		end		
		frame.movingtag = parent.movingtag
		frame:SetSize(width, height)
		frame.point = { a1 = point.a1, a2 = point.a2, x = point.x, y = point.y}
		frame.enable = true
		
		T.CreateDragFrame(frame)
		T.PlaceFrame(frame)
		
		parent[tag]	= frame
		
		if not parent.sub_frames then
			parent.sub_frames = {}
		end
		table.insert(parent.sub_frames, frame)
	end
end

---------------------------------------------
---------------  动画方向箭头  --------------
---------------------------------------------

local tex_info = {
	left = {rotation = -90, color = {1, 0, 0}},
	right = {rotation = 90, color = {0, 1, 0}},
	up = {rotation = 180, color = {1, 1, 0}},
	down = {rotation = 0, color = {1, 1, 0}},
	
	upleft = {rotation = -120, color = {0, 1, 1}},
	upright = {rotation = 120, color = {0, 1, 1}},
	downleft = {rotation = -60, color = {0, 1, 1}},
	downright = {rotation = 60, color = {0, 1, 1}},
}

T.CreateAnimArrow = function(frame)
	frame:SetSize(64, 44)
	
	frame.front_tex = frame:CreateTexture(nil, "OVERLAY") -- 前景材质
	frame.front_tex:SetAllPoints(frame)
	frame.front_tex:SetAtlas("Azerite-PointingArrow")

	frame.bg_tex = frame:CreateTexture(nil, "BORDER") -- 背景材质
	frame.bg_tex:SetPoint("TOPLEFT", frame, "TOPLEFT", -30, 30)
	frame.bg_tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 30, -30)
	frame.bg_tex:SetAtlas("Azerite-PointingArrow")
	
	frame.anim = frame:CreateAnimationGroup()
	frame.anim:SetLooping("REPEAT")
	
	frame.alpha = frame.anim:CreateAnimation("Alpha")
	frame.alpha:SetChildKey("bg_tex")
	frame.alpha:SetDuration(.6)
	frame.alpha:SetFromAlpha(1)
	frame.alpha:SetToAlpha(0.5)
    frame.alpha:SetSmoothing("IN_OUT")
	
	function frame:SetArrowDirection(dir, r, g, b)
		self.front_tex:SetRotation(tex_info[dir].rotation/180*math.pi)
		self.bg_tex:SetRotation(tex_info[dir].rotation/180*math.pi)
		if r and g and b then
			self.front_tex:SetVertexColor(r, g, b)
			self.bg_tex:SetVertexColor(r, g, b)
		else
			self.front_tex:SetVertexColor(unpack(tex_info[dir].color))
			self.bg_tex:SetVertexColor(unpack(tex_info[dir].color))
		end
	end
	
	frame:HookScript("OnShow", function(self)
		self.anim:Play()
	end)
	
	frame:HookScript("OnHide", function(self)
		self.anim:Stop()
	end)
end

--------------------------------------------------------
-------------------  小地图修改  ---------------------
--------------------------------------------------------
if not C_AddOns.IsAddOnLoaded("Blizzard_TimeManager") then C_AddOns.LoadAddOn("Blizzard_TimeManager") end
local MapData = {}
G.Minimapdata = MapData

T.UpdateMinimap = function(...)
	MapData.updated = true
	
	Minimap:EnableMouse(false)
	MinimapCluster:EnableMouse(false)
	
	--Minimap:SetPlayerTexture("Interface\\MINIMAP\\MiniMap-QuestArrow")
	--MapData.mask_tex = MinimapCluster:GetMaskTexture()
	Minimap:SetMaskTexture(G.media.blank)
	MinimapCluster:SetScale(1.2)
	MinimapCluster:SetAlpha(.7)
	Minimap:SetZoom(0)
	
	MapData.points = {Minimap:GetPoint()}
	Minimap:ClearAllPoints()
	Minimap:SetPoint(...)
	
	--MinimapCompassTexture:SetAlpha(0)
	--local BorderTopTextures = {"Center", "TopEdge", "LeftEdge", "RightEdge", "BottomEdge", "BottomLeftCorner", "BottomRightCorner", "TopLeftCorner", "TopRightCorner"}
	--for i, key in pairs(BorderTopTextures) do
	--	MinimapCluster.BorderTop[key]:SetAlpha(0)
	--end
	
	--GameTimeFrame:Hide()
	--AddonCompartmentFrame:Hide()
	--TimeManagerClockTicker:Hide()
	--MinimapCluster.Tracking:Hide()
	--MinimapCluster.ZoneTextButton:Hide()
	--MinimapCluster.IndicatorFrame.MailFrame:Hide()
	--MinimapCluster.IndicatorFrame.CraftingOrderFrame:Hide()
	--ExpansionLandingPageMinimapButton:Hide()
	--MinimapCluster.InstanceDifficulty:Hide()
end

T.RestoreMinimap = function()
	MapData.updated = false
	
	Minimap:EnableMouse(true)
	MinimapCluster:EnableMouse(true)
	
	--Minimap:SetPlayerTexture("Interface\\WorldMap\\WorldMapArrow")
	MinimapCluster:SetScale(1)
	MinimapCluster:SetAlpha(1)
	
	if MapData.points then
		Minimap:ClearAllPoints()
		Minimap:SetPoint(unpack(MapData.points))
	end
	
	--MinimapCompassTexture:SetAlpha(1)
	--local BorderTopTextures = {"Center", "TopEdge", "LeftEdge", "RightEdge", "BottomEdge", "BottomLeftCorner", "BottomRightCorner", "TopLeftCorner", "TopRightCorner"}
	--for i, key in pairs(BorderTopTextures) do
	--	MinimapCluster.BorderTop[key]:SetAlpha(1)
	--end
	
	--GameTimeFrame:Show()
	--AddonCompartmentFrame:Show()
	--TimeManagerClockTicker:Show()
	--MinimapCluster.Tracking:Show()
	--MinimapCluster.ZoneTextButton:Show()
	--MinimapCluster.IndicatorFrame.MailFrame:Show()
	--MinimapCluster.IndicatorFrame.CraftingOrderFrame:Show()
	--ExpansionLandingPageMinimapButton:Show()
	--MinimapCluster.InstanceDifficulty:Show()
end

---------------------------------------------
-----------------  选项模板  ----------------
---------------------------------------------
local function GetBossModData(frame)	
	local k, j
	for section_index, section_data in pairs(G.Encounters[frame.encounterID].alerts) do
		for index, args in pairs(section_data.options) do
			if args.category == "BossMod" and args.spellID == frame.config_id then
				k = section_index
				j = index
				break
			end
		end
	end
	return {frame.encounterID, "alerts", k, "options", j}
end
T.GetBossModData = GetBossModData

local function GetFrameInfoData(frame, key)
	if frame.info then
		for index, info in pairs(frame.info) do
			if info[key] then
				return true
			end
		end
	end
end

-- 选项模板1 点名模板
T.GetElementsCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end
	
	if frame.element_type == "circle" then
		table.insert(data.custom, {key = "size_sl", text = L["尺寸"], default = 100, min = 80, max = 150, apply = function(value, alert)
			alert:SetScale(value/100)			
		end})
	else
		table.insert(data.custom, {key = "width_sl", text = L["长度"], default = 180, min = 100, max = 300, apply = function(value, alert)
			alert:SetWidth(value)
			for _, bar in pairs(alert.elements) do
				bar:SetWidth(value)
			end
		end})
		table.insert(data.custom, {key = "height_sl", text = L["高度"], default = 20, min = 16, max = 30, apply = function(value, alert)
			alert:SetHeight((value+2)*(alert.info and #alert.info or 6) - 2 + (alert.bar and 22 or 0) + (alert.bar2 and 22 or 0))
			for _, bar in pairs(alert.elements) do
				bar:SetHeight(value)	
			end
		end})
	end
	
	if frame.raid_glow then
		table.insert(data.custom, {key = "raid_glow_bool", text = L["团队框架动画"], default = true})
	end
	if frame.raid_index then
		table.insert(data.custom, {key = "raid_index_bool", text = L["团队序号"], default = true})
	end
	
	if GetFrameInfoData(frame, "msg_applied") or GetFrameInfoData(frame, "msg") then
		table.insert(data.custom, {key = "say_bool", text = L["喊话"], default = true})
	end
	if GetFrameInfoData(frame, "rm") then
		table.insert(data.custom, {key = "mark_bool", text = L["标记"], default = false})
	end

	if frame.pa_icon then
		table.insert(data.custom, {key = "pa_icon_bool", text = L["PA图标提示"], default = true, apply = function(value, alert)
			T.Toggle_Subframe_moving(alert, alert.paicon, value)	
		end})
		table.insert(data.custom, {key = "pa_icon_alpha_sl", text = L["PA图标提示"]..L["透明度"], default = 30, min = 10, max = 100, apply = function(value, alert)
			alert.paicon:SetAlpha(value/100)
		end})
	end
	if frame.macro_button then
		table.insert(data.custom, {key = "macro_button_bool", text = L["交互宏按钮"], default = false, apply = function(value, alert)	
			T.Toggle_Subframe_moving(alert, alert.macrobuttons, value)		
		end})
	end
	if frame.support_spells then
		table.insert(data.custom, {key = "option_list_btn", text = L["支援技能设置"], default = {}})
	end	
	if frame.copy_mrt then
		table.insert(data.custom, {key = "mrt_custom_btn", text = L["粘贴MRT模板"]})
	end
end

-- 选项模板2 计时条组 光环组、小怪血量
T.GetBarsCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end
	
	table.insert(data.custom, {key = "width_sl", text = L["长度"], default = 180, min = 100, max = 300, apply = function(value, alert)
		alert:SetWidth(value)
		if alert.bars then
			for tag, bar in pairs(alert.bars) do
				bar:SetWidth(value)
			end
		end
	end})
	
	table.insert(data.custom, {key = "height_sl", text = L["高度"], default = 20, min = 16, max = 30, apply = function(value, alert)		
		if alert.bar_num then
			alert:SetHeight((value+2)*alert.bar_num-2)
		elseif alert.ficon == "0" then
			alert:SetHeight((value+2)*2-2)
		else
			alert:SetHeight((value+2)*4-2)
		end
		if alert.bars then
			for tag, bar in pairs(alert.bars) do
				bar:SetHeight(value)	
			end
		end
	end})
end

-- 选项模板3 单独计时条 吸收盾 技能轮次安排 计时条
T.GetSingleBarCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end
	
	table.insert(data.custom, {key = "width_sl", text = L["长度"], default = frame.default_bar_width or 200, min = 100, max = 500, apply = function(value, alert)
		alert:SetWidth(value)
		alert.bar:SetWidth(value)	
	end})
	
	table.insert(data.custom, {key = "height_sl", text = L["高度"], default = frame.default_bar_height or 25, min = 20, max = 40, apply = function(value, alert)
		alert:SetHeight(value)
		alert.bar:SetHeight(value)	
	end})
	
	if frame.raid_glow then
		table.insert(data.custom, {key = "raid_glow_bool", text = L["团队框架动画"], default = true})
	end
	
	if frame.send_msg then
		table.insert(data.custom, {key = "say_bool", text = L["喊话"], default = true})
	end
	
	if frame.copy_mrt then
		table.insert(data.custom, {key = "mrt_custom_btn", text = L["粘贴MRT模板"]})
	end	
end

-- 选项模板4 图形大小+显示秒数 圆圈、射线
T.GetFigureCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end

	table.insert(data.custom, {key = "size_sl", text = L["大小"], default = 150, min = 80, max = 200, apply = function(value, alert)
		alert:SetSize(value, value)
	end})
	
	table.insert(data.custom, {key = "text_bool", text = L["显示秒数"], default = true, apply = function(value, alert)
		alert:ToggleText(value)		
	end})	
end

-- 选项模板5 尺寸修改
T.GetScaleCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end
	
	table.insert(data.custom, {key = "scale_sl", text = L["尺寸"], default = 100, min = 80, max = 150, apply = function(value, alert)
		alert:SetScale(value/100)
	end})

	if frame.copy_mrt then
		table.insert(data.custom, {key = "mrt_custom_btn", text = L["粘贴MRT模板"]})
	end
end

-- 选项模板6 字号修改
T.GetFontSizeCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end
	
	table.insert(data.custom, {key = "fontsize_sl", text = L["字体大小"], default = frame.default_fontsize or 25, min = 20, max = 60, apply = function(value, alert)
		alert:SetSize(alert.width or 200, value)
		alert.text:SetFont(G.Font, value, "OUTLINE")
	end})
	
	if frame.copy_mrt then
		table.insert(data.custom, {key = "mrt_custom_btn", text = L["粘贴MRT模板"]})
	end
end

--------------------------------------------------------
--------------  [首领模块]射线指示器  ------------------
--------------------------------------------------------
-- event: COMBAT_LOG_EVENT_UNFILTERED

--		frame.spellIDs = {
--			[8936] = {
--				event = "SPELL_AURA_APPLIED",
--				target_me = true, -- 目标是我
--				delay = 2, -- 延迟显示时间
--				dur = 4.5, -- 持续时间（从显示开始算）
--				color = {0, 1, 0}, -- 颜色，默认白色
--				info = {0, 120, 240},			
--			},
--		}

T.CreateRayFigure = function(frame, color, info)
	local figure = CreateFrame("Frame", nil, frame)
	figure:SetPoint("CENTER", frame, "CENTER", 0, 0)
	figure:SetSize(100, 100)
	figure:Hide()
	figure.t = 0
	
	figure.dur_text = T.createtext(figure, "OVERLAY", 20, "OUTLINE", "LEFT")
	figure.dur_text:SetPoint("BOTTOM", figure, "CENTER", 0, 50)

	for i, r in pairs(info) do
		local texture = figure:CreateTexture(nil, "ARTWORK")
		texture:SetSize(150, 5)
		texture:SetPoint("BOTTOMLEFT", figure, "BOTTOM", 0, 0)
		texture:SetTexture(G.media.blank)
		texture:SetVertexColor(unpack(color))
		texture:SetRotation((r+90)/180*math.pi, CreateVector2D(0, .5))

		if frame.post_update_createtex then
			frame.post_update_createtex(figure, i, r)
		end
	end
	
	function figure:begin(delay, dur)
		figure.exp = GetTime() + delay + dur
		figure:SetScript("OnUpdate", function(self, e)
			self.t = self.t + e
			if self.t > .05 then
				local remain = figure.exp - GetTime()
				if remain > dur then -- 准备显示
					self.dur_text:SetText("")
					self:SetAlpha(0)
				elseif remain > 0 then -- 显示
					self.dur_text:SetText(string.format("%.1f", remain))
					self:SetAlpha(1)	
				else -- 结束
					self:Hide()
					self:SetScript("OnUpdate", nil)
					self.dur_text:SetText("")
				end
				
				self.t = 0
			end
		end)
		
		figure.dur_text:SetText("")
		figure:SetAlpha(0)
		
		if frame.post_update_begin then
			frame.post_update_begin(figure)					
		end
		
		figure:Show()
	end
	
	function figure:stop()
		figure:Hide()
		figure:SetScript("OnUpdate", nil)
		figure.dur_text:SetText("")
		
		if frame.post_update_stop then
			frame.post_update_stop(figure)					
		end
	end
	
	return figure
end

T.InitRayFigures = function(frame)	
	frame.figures = {}
	frame.figures_M = {}
	frame.figures_H = {}
	frame.figures_N = {}
	
	if frame.spellIDs then
		for k, v in pairs(frame.spellIDs) do
			local figure = T.CreateRayFigure(frame, v.color, v.info)
			frame.figures[k] = figure
		end
	end
	
	if frame.spellIDs_M then
		for k, v in pairs(frame.spellIDs_M) do
			local figure = T.CreateRayFigure(frame, v.color, v.info)
			frame.figures_M[k] = figure
		end
	end
	
	if frame.spellIDs_H then
		for k, v in pairs(frame.spellIDs_H) do
			local figure = T.CreateRayFigure(frame, v.color, v.info)
			frame.figures_H[k] = figure
		end
	end
	
	if frame.spellIDs_N then
		for k, v in pairs(frame.spellIDs_N) do
			local figure = T.CreateRayFigure(frame, v.color, v.info)
			frame.figures_N[k] = figure
		end
	end
	
	function frame:ToggleText(value)
		for spell, figure in pairs(self.figures) do
			figure.dur_text:SetShown(value)
		end
		if self.figures_M then
			for spell, figure in pairs(self.figures_M) do
				figure.dur_text:SetShown(value)
			end
		end
		if self.spellIDs_H then
			for spell, figure in pairs(self.spellIDs_H) do
				figure.dur_text:SetShown(value)
			end
		end
		if self.spellIDs_N then
			for spell, figure in pairs(self.spellIDs_N) do
				figure.dur_text:SetShown(value)
			end
		end
	end

	T.GetFigureCustomData(frame)
end

T.UpdateRayFigures = function(frame, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if not frame.dif then
			frame.dif = select(3, GetInstanceInfo())
		end
		if frame.spellIDs_M and frame.dif == 16 and frame.spellIDs_M[spellID] and sub_event == frame.spellIDs_M[spellID]["event"] then -- 开始
			if not frame.spellIDs_M[spellID]["target_me"] or G.PlayerGUID == destGUID then
				local figure = frame.figures_M[spellID]
				figure:begin(frame.spellIDs_M[spellID]["delay"], frame.spellIDs_M[spellID]["dur"])
			end
		elseif frame.spellIDs_H and frame.dif == 15 and frame.spellIDs_H[spellID] and sub_event == frame.spellIDs_H[spellID]["event"] then -- 开始
			if not frame.spellIDs_H[spellID]["target_me"] or G.PlayerGUID == destGUID then
				local figure = frame.figures_H[spellID]
				figure:begin(frame.spellIDs_H[spellID]["delay"], frame.spellIDs_H[spellID]["dur"])
			end
		elseif frame.spellIDs_N and frame.dif == 14 and frame.spellIDs_N[spellID] and sub_event == frame.spellIDs_N[spellID]["event"] then -- 开始
			if not frame.spellIDs_N[spellID]["target_me"] or G.PlayerGUID == destGUID then
				local figure = frame.figures_N[spellID]
				figure:begin(frame.spellIDs_N[spellID]["delay"], frame.spellIDs_N[spellID]["dur"])
			end
		elseif frame.spellIDs and frame.spellIDs[spellID] and sub_event == frame.spellIDs[spellID]["event"] then -- 开始
			if not frame.spellIDs[spellID]["target_me"] or G.PlayerGUID == destGUID then
				local figure = frame.figures[spellID]
				figure:begin(frame.spellIDs[spellID]["delay"], frame.spellIDs[spellID]["dur"])
			end
		end
	elseif event == "ENCOUNTER_START" then
		frame.dif = select(3, ...)
	end
end

T.ResetRayFigures = function(frame)
	for k, figure in pairs(frame.figures) do
		figure:stop()
	end
	for k, figure in pairs(frame.figures_M) do
		figure:stop()
	end
	for k, figure in pairs(frame.figures_H) do
		figure:stop()
	end
	for k, figure in pairs(frame.figures_N) do
		figure:stop()
	end
	frame:Hide()
end

--------------------------------------------------------
---------  [首领模块]法术圆圈计时器模板 CLEU -----------
--------------------------------------------------------
-- event: COMBAT_LOG_EVENT_UNFILTERED

--		frame.spellIDs = {
--			[8936] = {
--				event = "SPELL_AURA_APPLIED",
--				target_me = true, -- 目标是我
--				dur = 4.5, -- 持续时间
--				color = {0, 1, 0}, -- 颜色，默认白色
--				color_mode = "fade", -- [可选]变色方式 "fade"渐变；"divide"双色；"threesections"三色；详见ProgressColor
--				color_value = 2, -- [可选]变色方式参数
--				reverse = true, -- [可选]逆时针
--			},
--		}

T.InitCircleTimers = function(frame)	
	frame.figures = {}	

	if frame.spellIDs then	
		for k, v in pairs(frame.spellIDs) do
			local cd_tex = CreateCircleCD(frame, v.color, v.reverse, true)
			frame.figures[k] = cd_tex
		end
	end
	
	function frame:PreviewShow()
		for k, v in pairs(frame.spellIDs) do
			local circle = frame.figures[k]
			circle:begin(GetTime() + v.dur, v.dur, v.color_mode, v.color_value)
			break
		end
	end
	
	function frame:PreviewHide()
		for k, v in pairs(frame.spellIDs) do
			local circle = frame.figures[k]
			circle:stop()
			break
		end
	end
	
	function frame:ToggleText(value)
		for spell, figure in pairs(self.figures) do
			figure.dur_text:SetShown(value)
		end	
	end

	T.GetFigureCustomData(frame)
end

T.UpdateCircleTimers = function(frame, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if frame.spellIDs and frame.spellIDs[spellID] and sub_event == frame.spellIDs[spellID]["event"] then -- 开始
			if not frame.spellIDs[spellID]["target_me"] or G.PlayerGUID == destGUID then
				local cd_tex = frame.figures[spellID]
				cd_tex:begin(GetTime() + frame.spellIDs[spellID].dur, frame.spellIDs[spellID].dur, frame.spellIDs[spellID].color_mode, frame.spellIDs[spellID].color_value)
			end
		end	
	end
end

T.ResetCircleTimers = function(frame)
	for k, cd_tex in pairs(frame.figures) do
		cd_tex:stop()
	end
	frame:Hide()
end

--------------------------------------------------------
-------  [首领模块]法术圆圈计时器模板 UNIT_AURA -------- 
--------------------------------------------------------
-- event: UNIT_AURA

--		frame.spellIDs = {
--			[8936] = {	
--				unit = "player",
--				aura_type = "HARMFUL", -- 光环类型 默认 "HARMFUL"
--				color = {0, 1, 0}, -- 颜色
--				color_mode = "fade", -- [可选]变色方式 "fade"渐变；"divide"双色；"threesections"三色；详见ProgressColor
--				color_value = 2, -- [可选]变色方式参数
--				reverse = true, -- [可选]逆时针
--			},
--		} 		

T.InitUnitAuraCircleTimers = function(frame)
	frame.figures = {}
	frame.watched_units = {}
	
	for k, v in pairs(frame.spellIDs) do
		if not frame.watched_units[v.unit] then
			frame.watched_units[v.unit] = true
		end
	end
	
	for k, v in pairs(frame.spellIDs) do
		frame.preview_tex = CreateCircleCD(frame, v.color, v.reverse, true)
		break
	end
	
	function frame:PreviewShow()
		for k, v in pairs(frame.spellIDs) do
			frame.preview_tex:begin(GetTime() + 25, 25, v.color_mode, v.color_value)
			break
		end
	end
	
	function frame:PreviewHide()
		frame.preview_tex:stop()
	end
	
	function frame:ToggleText(value)
		for spell, figure in pairs(self.figures) do
			figure.dur_text:SetShown(value)
		end
		frame.preview_tex.dur_text:SetShown(value)
	end
	
	T.GetFigureCustomData(frame)
end

T.UpdateUnitAuraCircleTimers = function(frame, event, ...)
	if event == "UNIT_AURA" then
		local unit, updateInfo = ...
		if not frame.watched_units[unit] then return end
		if updateInfo == nil or updateInfo.isFullUpdate then
			for auraID, cd_tex in pairs(frame.figures) do
				cd_tex:stop()
				frame.figures[auraID] = nil
			end
			
			for spellID, info in pairs(frame.spellIDs) do
				AuraUtil.ForEachAura(unit, info.aura_type or "HARMFUL", nil, function(AuraData)
					if spellID == AuraData.spellId and info.unit == unit then
						local auraID = AuraData.auraInstanceID
						if not frame.figures[auraID] then
							local cd_tex = CreateCircleCD(frame, info.color, info.reverse, true)
							cd_tex:begin(AuraData.expirationTime, AuraData.duration, info.color_mode, info.color_value)
							frame.figures[auraID] = cd_tex
						end
					end
				end, true)
			end
		else
			if updateInfo.addedAuras ~= nil then
				for _, AuraData in pairs(updateInfo.addedAuras) do
					local auraID = AuraData.auraInstanceID
					local spellID = AuraData.spellId
					
					if frame.spellIDs[spellID] and unit == frame.spellIDs[spellID].unit then					
						if not frame.figures[auraID] then
							local cd_tex = CreateCircleCD(frame, frame.spellIDs[spellID].color, frame.spellIDs[spellID].reverse, true)
							cd_tex:begin(AuraData.expirationTime, AuraData.duration, frame.spellIDs[spellID]["color_mode"], frame.spellIDs[spellID]["color_value"])
							
							frame.figures[auraID] = cd_tex
						end
					end
				end
			end
			if updateInfo.updatedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do		
					local cd_tex = frame.figures[auraID]
					if cd_tex then
						local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
						if AuraData then
							local spellID = AuraData.spellId
							cd_tex:begin(AuraData.expirationTime, AuraData.duration, frame.spellIDs[spellID]["color_mode"], frame.spellIDs[spellID]["color_value"])
						else
							cd_tex:stop()
							frame.figures[auraID] = nil
						end
					end
				end
			end
			if updateInfo.removedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
					local cd_tex = frame.figures[auraID]
					if cd_tex then
						cd_tex:stop()
						frame.figures[auraID] = nil
					end				
				end
			end
		end
	end
end

T.ResetUnitAuraCircleTimers = function(frame)
	for k, cd_tex in pairs(frame.figures) do
		cd_tex:stop()
	end
	frame:Hide()
end

--------------------------------------------------------
---------------  [首领模块]自动标记模板  ---------------
--------------------------------------------------------
-- event: NAME_PLATE_UNIT_ADDED
-- event: UNIT_TARGET

--		frame.start_mark = 6 -- 开始标记
--		frame.end_mark = 8 -- 结束标记
--		frame.mob_npcID = "181856" -- NpcID

T.InitRaidTarget = function(frame)
	frame.Get_counter = function()
		if frame.counter < frame.end_mark then
			frame.counter = frame.counter + 1
		else
			frame.counter = frame.start_mark
		end
	end
	
	function frame:Mark(unit, GUID)
		if not frame.trigger or frame.trigger() then
			frame.Get_counter()
			T.SetRaidTarget(unit, frame.counter)
			frame.marked[GUID] = true
			local npcID = select(6, strsplit("-", GUID))
			local mark = T.FormatRaidMark(frame.counter)
			T.msg(string.format(L["已标记%s"], date("%H:%M:%S"), T.GetNameFromNpcID(npcID), mark))
		end
	end

	frame.marked = {}
	frame.counter = frame.start_mark - 1
end

T.UpdateRaidTarget = function(frame, event, ...)
	if event == "NAME_PLATE_UNIT_ADDED" then
		local unit = ...
		local GUID = UnitGUID(unit)
		local npcID = select(6, strsplit("-", GUID))
		if npcID and npcID == frame.mob_npcID and not frame.marked[GUID] then
			frame:Mark(unit, GUID)
		end
	elseif event == "UNIT_TARGET" then
		local unit = ...
		if strfind(unit, "raid") then -- 只看团队						
			local targetUnit = unit.."target"
			local GUID = UnitGUID(targetUnit)
			if GUID and not UnitIsDeadOrGhost(targetUnit) then
				local npcID = select(6, strsplit("-", GUID))
				if npcID and npcID == frame.mob_npcID then -- 确认过眼神
					if not frame.marked[GUID] then
						frame:Mark(targetUnit, GUID)
					end
				end
			end
		end
	end
end

T.ResetRaidTarget = function(frame)
	frame.marked = table.wipe(frame.marked)
	frame.counter = frame.start_mark - 1
end

--------------------------------------------------------
---------------  [首领模块]小怪血量模板  ---------------
--------------------------------------------------------
-- event: NAME_PLATE_UNIT_ADDED
-- event: UNIT_TARGET
-- event: COMBAT_LOG_EVENT_UNFILTERED
-- event: UNIT_NAME_UPDATE(可选)
-- event: UNIT_AURA(可选)

--		frame.post_update_health(bar, unit)
--		frame.post_update_name(bar, unit)

--		frame.npcIDs = {
--			["182822"] = {n = "", color = {0, .3, .1}}, -- NpcID 名字，颜色
--		}
--		frame.auras = {
--			[139] = "HELPFUL", -- 监视的光环
--		}

local code_of_raid_marks = {
    [128] = 8, -- skull
	[64] = 7, -- cross
	[32] = 6, -- square
	[16] = 5, -- moon
	[8] = 4, -- triangle
	[4] = 3, -- diamond
	[2] = 2, -- circle
	[1] = 1, -- star
}

T.GetRaidFlagsMark = function(RaidFlags)
	local check = bit.band(RaidFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK)
	if check and code_of_raid_marks[check] then
		return code_of_raid_marks[check]
	else
		return 0
	end
end
	
local cleu_sub_event_hp = {
	["SWING_DAMAGE"] = function(bar, arg12, arg13, arg14, arg15)
		bar.min = bar.min - arg12
		if bar.min < 0 then
			bar.min = 0
		end
	end,
	["SWING_HEAL"] = function(bar, arg12, arg13, arg14, arg15)
		local amount = arg12
		bar.min = bar.min + amount
		if bar.min > bar.max then
			bar.min = bar.max
		end
	end,
	["RANGE_DAMAGE"] = function(bar, arg12, arg13, arg14, arg15)
		local amount = arg15
		bar.min = bar.min - amount
		if bar.min < 0 then
			bar.min = 0
		end
	end,
	["RANGE_HEAL"] = function(bar, arg12, arg13, arg14, arg15)
		local amount = arg15
		bar.min = bar.min + amount
		if bar.min > bar.max then
			bar.min = bar.max
		end
	end,
	["ENVIRONMENTAL_DAMAGE"] = function(bar, arg12, arg13, arg14, arg15)
		local amount = arg13
		bar.min = bar.min - amount
		if bar.min < 0 then
			bar.min = 0
		end
	end,
	["ENVIRONMENTAL_HEAL"] = function(bar, arg12, arg13, arg14, arg15)
		local amount = arg13
		bar.min = bar.min + amount
		if bar.min > bar.max then
			bar.min = bar.max
		end
	end,
	["SPELL_DAMAGE"] = function(bar, arg12, arg13, arg14, arg15) 
		local amount = arg15
		bar.min = bar.min - amount
		if bar.min < 0 then
			bar.min = 0
		end
	end,
	["SPELL_HEAL"] = function(bar, arg12, arg13, arg14, arg15) 
		local amount = arg15
		bar.min = bar.min + amount
		if bar.min > bar.max then
			bar.min = bar.max
		end
	end,
	["SPELL_PERIODIC_DAMAGE"] = function(bar, arg12, arg13, arg14, arg15) 
		local amount = arg15
		bar.min = bar.min - amount
		if bar.min < 0 then
			bar.min = 0
		end
	end,
	["SPELL_PERIODIC_HEAL"] = function(bar, arg12, arg13, arg14, arg15) 
		local amount = arg15
		bar.min = bar.min + amount
		if bar.min > bar.max then
			bar.min = bar.max
		end
	end,
}

T.InitMobHealth = function(frame)
	frame.bars = {}
	T.GetBarsCustomData(frame)
	
	frame.create_uf_bar = function(unit, GUID)
		if not frame.bars[GUID] then
			local w, h = JST_CDB["BossMod"][frame.config_id]["width_sl"], JST_CDB["BossMod"][frame.config_id]["height_sl"]
			local npcID = select(6, strsplit("-", GUID))
			local info = frame.npcIDs[npcID]
			local bar = CreateTimerBar(frame, nil, false, true, false, w, h, info.color)
			
			bar.rt_icon = bar:CreateTexture(nil, "OVERLAY")
			bar.rt_icon:SetSize(h, h)
			bar.rt_icon:SetPoint("LEFT", bar, "LEFT", 0, 0)
			bar.rt_icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
			bar.rt_icon:Hide()
			
			bar.left:ClearAllPoints()
			bar.left:SetPoint("LEFT", bar.rt_icon, "RIGHT", 5, 0)
			
			bar.icons = {}
			
			bar.npcID = npcID
			bar.min = UnitHealth(unit)
			bar.max = UnitHealthMax(unit)
		
			bar.update_value = function()		
				bar:SetMinMaxValues(0, bar.max)
				bar:SetValue(bar.min)
				bar.mid:SetText(string.format("%d%%",bar.min/bar.max*100))
				bar.right:SetText(T.ShortValue(bar.min))
			end
			
			bar.lineup = function()
				local last_icon
				for auraID, icon in pairs(bar.icons) do
					icon:ClearAllPoints()
					if not last_icon then
						icon:SetPoint("LEFT", bar, "RIGHT", 5, 0)
					else
						icon:SetPoint("LEFT", last_icon, "RIGHT", 3, 0)
					end
					last_icon = icon
				end	
			end
			
			bar.add_auraicon = function(auraID, texture, count, dur, exp_time)
				if not bar.icons[auraID] then
					local icon = CreateFrame("Frame", nil, bar)
					icon:SetSize(JST_CDB["BossMod"][frame.config_id]["height_sl"], JST_CDB["BossMod"][frame.config_id]["height_sl"])
					T.createborder(icon)
					
					icon.tex = icon:CreateTexture(nil, "ARTWORK")
					icon.tex:SetAllPoints()
					icon.tex:SetTexCoord( .1, .9, .1, .9)
					icon.tex:SetTexture(texture)
					
					icon.count = T.createtext(icon, "OVERLAY", 12, "OUTLINE", "RIGHT")
					icon.count:SetPoint("TOPRIGHT", icon, "TOPRIGHT")
					icon.count:SetText(count > 0 and count or "")
					
					icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
					icon.cooldown:SetAllPoints()
					icon.cooldown:SetDrawEdge(false)
					icon.cooldown:SetHideCountdownNumbers(true)
					icon.cooldown:SetReverse(true)
					icon.cooldown:SetCooldown(exp_time - dur, dur)
					
					icon.t = 0
					icon.exp = exp_time
					icon:SetScript("OnUpdate", function(self, e)
						self.t = self.t + e
						if self.t > .05 then	
							local remain = self.exp - GetTime()
							if remain < 0 then
								self:ClearAllPoints()
								self:Hide()
								bar.icons[auraID] = nil
								bar.lineup()
							end
							self.t = 0
						end
					end)
					
					bar.icons[auraID] = icon
					bar.lineup()
				end
			end
			
			bar.update_auraicon = function(auraID, texture, count, dur, exp_time)
				local icon = bar.icons[auraID]
				icon.tex:SetTexture(texture)
				icon.count:SetText(count > 0 and count or "")
				icon.cooldown:SetCooldown(exp_time - dur, dur)
			end
			
			bar.remove_auraicon = function(auraID)
				bar.icons[auraID]:ClearAllPoints()
				bar.icons[auraID]:Hide()
				bar.icons[auraID] = nil
				bar.lineup()
			end
			
			frame.bars[GUID] = bar
			frame.lineup()
		end
	end
		
	frame.update_health = function(bar, unit)
		bar.min, bar.max = UnitHealth(unit), UnitHealthMax(unit)
		bar.update_value()

		if frame.post_update_health then
			frame.post_update_health(bar, unit)
		end
	end
	
	frame.update_mark = function(bar, mark)	
		if mark == 0 then
			bar.rt_icon:Hide()
		else
			SetRaidTargetIconTexture(bar.rt_icon, mark)
			bar.rt_icon:Show()
		end
	end
	
	frame.update_name = function(bar, unit)		
		if frame.npcIDs[bar.npcID]["n"] then
			bar.left:SetText(frame.npcIDs[bar.npcID]["n"])
		elseif UnitName(unit) then
			bar.left:SetText(UnitName(unit))
		end
		
		if frame.post_update_name then
			frame.post_update_name(bar, unit)
		end
	end
	
	frame.lineup = function()
		local lastbar
		for GUID, bar in pairs(frame.bars) do
			bar:ClearAllPoints()
			if not lastbar then
				bar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
			else
				bar:SetPoint("TOPLEFT", lastbar, "BOTTOMLEFT", 0, -2)		
			end
			lastbar = bar
		end
	end
	
	function frame:PreviewShow()
		local num
		if self.bar_num then
			num = self.bar_num
		else
			num = 2
		end
		
		for npcID, info in pairs(frame.npcIDs) do
			for i = 1, num do
				local w, h = JST_CDB["BossMod"][frame.config_id]["width_sl"], JST_CDB["BossMod"][frame.config_id]["height_sl"]
				local bar = CreateTimerBar(frame, nil, false, true, false, w, h, info.color)
				
				bar.rt_icon = bar:CreateTexture(nil, "OVERLAY")
				bar.rt_icon:SetSize(h, h)
				bar.rt_icon:SetPoint("LEFT", bar, "LEFT", 0, 0)
				bar.rt_icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
				SetRaidTargetIconTexture(bar.rt_icon, i)
				
				bar.left:ClearAllPoints()
				bar.left:SetPoint("LEFT", bar.rt_icon, "RIGHT", 5, 0)
				bar.left:SetText(T.GetNameFromNpcID(npcID))
				
				frame.bars[npcID..i] = bar
			end
		end
		
		frame.lineup()
	end
	
	function frame:PreviewHide()
		for tag, bar in pairs(frame.bars) do
			bar:ClearAllPoints()
			bar:Hide()
		end
		frame.bars = table.wipe(frame.bars)
	end
end

T.UpdateMobHealth = function(frame, event, ...)
	if event == "NAME_PLATE_UNIT_ADDED" then
		local unit = ...
		local GUID = UnitGUID(unit)
		local npcID = select(6, strsplit("-", GUID))	
		if npcID and frame.npcIDs[npcID] then
			if not frame.bars[GUID] then
				frame.create_uf_bar(unit, GUID)
			end
			local bar = frame.bars[GUID]
			frame.update_health(bar, unit)
			frame.update_name(bar, unit)
		end
	elseif event == "UNIT_TARGET" then
		local unit = ...
		if strfind(unit, "raid") then -- 只看团队
			local targetUnit = unit.."target"
			local GUID = UnitGUID(targetUnit)
			if GUID then
				local npcID = select(6, strsplit("-", GUID))
				if npcID and frame.npcIDs[npcID] then -- 确认过眼神
					if not frame.bars[GUID] then
						frame.create_uf_bar(targetUnit, GUID)
					end
					local bar = frame.bars[GUID]
					frame.update_health(bar, targetUnit)
					frame.update_name(bar, targetUnit)
				end
			end
		end
	elseif event == "UNIT_NAME_UPDATE" then
		local unit = ...
		local GUID = UnitGUID(unit)
		if frame.bars[GUID] then
			frame.update_name(frame.bars[GUID], unit)
		end
	elseif event == "UNIT_AURA" then
		if not frame.auras then return end
		local unit, updateInfo = ...
		local GUID = UnitGUID(unit)
		local bar = frame.bars[GUID]
		
		if bar then
			if updateInfo == nil or updateInfo.isFullUpdate then	
				for auraID, icon in pairs(bar.icons) do
					bar.remove_auraicon(auraID)
				end
				
				for spellID, aura_type in pairs(frame.auras) do
					AuraUtil.ForEachAura(unit, aura_type, nil, function(AuraData)
						if spellID == AuraData.spellId then
							local auraID = AuraData.auraInstanceID
							bar.add_auraicon(auraID, AuraData.icon, AuraData.applications, AuraData.duration, AuraData.expirationTime)		
						end
					end, true)
				end
			else
				if updateInfo.addedAuras ~= nil then
					for _, AuraData in pairs(updateInfo.addedAuras) do
						if frame.auras[AuraData.spellId] then
							bar.add_auraicon(AuraData.auraInstanceID, AuraData.icon, AuraData.applications, AuraData.duration, AuraData.expirationTime)
						end
					end
				end
				if updateInfo.updatedAuraInstanceIDs ~= nil then
					for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do		
						if bar.icons[auraID] then
							local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
							if AuraData then
								bar.update_auraicon(auraID, AuraData.icon, AuraData.applications, AuraData.duration, AuraData.expirationTime)
							else
								bar.remove_auraicon(auraID)
							end
						end				
					end
				end
				if updateInfo.removedAuraInstanceIDs ~= nil then
					for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
						if bar.icons[auraID] then
							bar.remove_auraicon(auraID)
						end
					end
				end
			end
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, Event_type, _, sourceGUID, sourceName, _, _, DestGUID, DestName, _, destRaidFlags, arg12, arg13, arg14, arg15 = CombatLogGetCurrentEventInfo()
		if Event_type == "UNIT_DIED" and frame.bars[DestGUID] then
			frame.bars[DestGUID]:Hide()
			frame.bars[DestGUID] = nil
			frame.lineup()
		elseif cleu_sub_event_hp[Event_type] and frame.bars[DestGUID] then
			local bar = frame.bars[DestGUID]
			cleu_sub_event_hp[Event_type](bar, arg12, arg13, arg14, arg15)
			bar.update_value(bar)
			if destRaidFlags then
				frame.update_mark(bar, T.GetRaidFlagsMark(destRaidFlags))
			end
		end		
	end
end

T.ResetMobHealth = function(frame)
	for tag, bar in pairs(frame.bars) do
		bar:ClearAllPoints()
		bar:Hide()
	end
	frame.bars = table.wipe(frame.bars)
	frame:Hide()
end

--------------------------------------------------------
---------------  [首领模块]吸收盾模板  -----------------
--------------------------------------------------------
-- event: COMBAT_LOG_EVENT_UNFILTERED
-- event: UNIT_ABSORB_AMOUNT_CHANGED

--		frame.unit = "boss1" -- 监控单位
--		frame.spell_id = 368684 -- 吸收盾光环SpellID
--		frame.aura_type = "HARMFUL" -- 光环类型 默认"HELPFUL"
--		frame.effect = 1 -- 吸收量的序号
--		frame.time_limit = 20 -- 附加计时条时限

T.InitAbsorbBar = function(frame)	
	frame.default_bar_width = frame.default_bar_width or 300
	T.GetSingleBarCustomData(frame)
	
	frame.bar = CreateTimerBar(frame, nil, false, false, true, nil, nil, {1, .8, 0}, 1)
	frame.bar.tag1:SetVertexColor(1, 0, 0)
	frame.bar:SetAllPoints(frame)
	
	frame.absorb = 0
	frame.absorb_max = 0
	
	frame.update_absorb = function(update_max)
		if frame.absorb > 0 and frame.absorb_max > 0 then
			if update_max then
				frame.bar:SetMinMaxValues(0, frame.absorb_max)
			end
			frame.bar:SetValue(frame.absorb)
			frame.bar.right:SetText(string.format("%s |cffFFFF00%d%%|r", T.ShortValue(frame.absorb), frame.absorb/frame.absorb_max*100))
		end
	end
	
	frame.update_time = function()
		if frame.time_limit then
			local exp_time = GetTime() + frame.time_limit
			
			frame.bar.left:SetText("")
			frame.bar.tag1:Show()
			
			frame.bar:SetScript('OnUpdate', function(self, e)
				self.t = self.t + e
				if self.t > 0.05 then
					local remain = exp_time - GetTime()
					if remain > 0 then
						self.left:SetText(T.FormatTime(remain))
						self.pointtag(1, remain/frame.time_limit)
					else
						self:Hide()
						self.tag1:Hide()
						self:SetScript("OnUpdate", nil)
					end
					self.t = 0
				end
			end)
		end
		frame.bar:Show()
	end
	
	frame.stop_bar = function()
		frame.bar:Hide()
		frame.bar.tag1:Hide()
		frame.bar:SetScript("OnUpdate", nil)
	end
	
	function frame:PreviewShow()
		frame.absorb = 1823145
		frame.absorb_max = 2024100		
		frame.update_absorb(true)
		frame.update_time()
	end
	
	function frame:PreviewHide()
		frame.stop_bar()
	end
end

T.UpdateAbsorbBar = function(frame, event, ...)	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if sub_event == "SPELL_AURA_APPLIED" and spellID == frame.spell_id then
			if AuraUtil.FindAuraBySpellID(frame.spell_id, frame.unit, frame.aura_type or "HELPFUL") then
				local value = select(frame.effect+15, AuraUtil.FindAuraBySpellID(frame.spell_id, frame.unit, frame.aura_type or "HELPFUL"))
				frame.absorb = value
				frame.absorb_max = value		
				frame.update_absorb(true)
				frame.update_time()		
			end
		elseif sub_event == "SPELL_AURA_REMOVED" and spellID == frame.spell_id then
			frame.stop_bar()
		end
	elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
		local unit = ...
		if unit and unit == frame.unit then
			if AuraUtil.FindAuraBySpellID(frame.spell_id, frame.unit, frame.aura_type or "HELPFUL") then
				local value = select(frame.effect+15, AuraUtil.FindAuraBySpellID(frame.spell_id, frame.unit, frame.aura_type or "HELPFUL"))
				frame.absorb = value
				frame.update_absorb()
			end
		end	
	elseif event == "ENCOUNTER_START" then
		frame.absorb = 0
		frame.absorb_max = 0
	end
end

T.ResetAbsorbBar = function(frame)
	frame.stop_bar()
	frame:Hide()
end

--------------------------------------------------------
---------------  [首领模块]多人光环模板 ----------------
--------------------------------------------------------
-- event: UNIT_AURA

--		frame.spellIDs = {
--			[774] = {
--				aura_type = "HARMFUL", -- 光环类型 默认 "HARMFUL"
--				color = {0.95, .5, 0}, -- 颜色
--				limit = 5, -- 限制显示数量
--				hl_raid = "pixel", -- 团队框架动画
--				progress_stack = 10, -- 以层数替代时间作为进度
--				effect = 1, -- 获取光环信息
--				progress_value = 50000, -- 以数值替代时间作为进度
--			},
--		}

--		frame.role = true -- 显示被点名人的职责
--		frame:filter(auraID, spellID, GUID) -- 过滤
--		frame:post_create_bar(bar, auraID, spellID, GUID) -- 附加修改

T.InitUnitAuraBars = function(frame)
	frame.bars = {}
	frame.cache = {}
	
	T.GetBarsCustomData(frame)
	
	for spellID, info in pairs(frame.spellIDs) do
		frame.spellIDs[spellID]["icon"] = select(2, T.GetSpellInfo(spellID))
	end
	
	function frame:create_bar(auraID, spellID, name, GUID)
		if not frame.filter or frame:filter(auraID, spellID, GUID) then		
			local bar = CreateTimerBar(self, self.spellIDs[spellID].icon, false, false, false, JST_CDB["BossMod"][self.config_id]["width_sl"], JST_CDB["BossMod"][self.config_id]["height_sl"], self.spellIDs[spellID].color)
			
			-- 用于排序、控制高亮
			bar.spellID = spellID
			bar.auraID = auraID
			
			local info = T.GetGroupInfobyGUID(GUID)
			bar.unit = info.unit
			
			bar.left:SetText(info.format_name)
			
			if frame.spellIDs[spellID].hl_raid then
				GlowRaidFramebyUnit_Show(frame.spellIDs[spellID].hl_raid, "multiauras"..spellID, bar.unit, frame.spellIDs[spellID].color)
			end
			
			if frame.post_create_bar then
				frame:post_create_bar(bar, auraID, spellID, GUID)
			end
			
			self.bars[auraID] = bar
			self:lineup()
		end
	end
	
	function frame:update_bar(auraID, spellID, count, dur, exp_time, effect_value)
		local bar = self.bars[auraID]
		
		if bar then
			if self.spellIDs[spellID]["progress_value"] then
				local total = self.spellIDs[spellID]["progress_value"]
				bar:SetMinMaxValues(0 , total)
				bar:SetValue(min(total, effect_value))
				bar.right:SetText(T.ShortValue(effect_value))
			elseif self.spellIDs[spellID]["progress_stack"] then
				local total = self.spellIDs[spellID]["progress_stack"]
				bar:SetMinMaxValues(0 , total)
				bar:SetValue(min(total, count))
				bar.right:SetText(count)
			elseif exp_time ~= 0 then -- 有持续时间
				bar:SetMinMaxValues(0 , dur)
				bar.exp = exp_time
				bar:SetScript("OnUpdate", function(s, e)
					s.t = s.t + e
					if s.t > s.update_rate then
						local remain = s.exp - GetTime()
						if remain > 0 then
							s.right:SetText((count > 0 and "|cffFFFF00["..count.."]|r " or "")..T.FormatTime(remain))
							s:SetValue(dur - remain)
						else
							self:remove_bar(auraID)
						end
						s.t = 0
					end
				end)
			else -- 无持续时间
				bar:SetMinMaxValues(0 , 1)
				bar:SetValue(1)
				bar.right:SetText((count > 0 and "|cffFFFF00["..count.."]|r " or ""))
			end
		end
	end
	
	function frame:remove_bar(auraID)
		local bar = self.bars[auraID]
		
		if bar then
			bar:Hide()
			bar:SetScript("OnUpdate", nil)
			
			if frame.spellIDs[bar.spellID].hl_raid then
				GlowRaidFramebyUnit_Hide(frame.spellIDs[bar.spellID].hl_raid, "multiauras"..bar.spellID, bar.unit)
			end
			
			self.bars[auraID] = nil
			self:lineup()
		end
	end
	
	function frame:lineup()
		local bar_count = {}
		
		for spellID, info in pairs(self.spellIDs) do
			if info.limit then
				bar_count[spellID] = 0 -- 需要计数
			end
		end
		
		self.cache = table.wipe(self.cache)
		
		for auraID, bar in pairs(self.bars) do
			if bar_count[bar.spellID] then
				bar_count[bar.spellID] = bar_count[bar.spellID] + 1
				if bar_count[bar.spellID] <= self.spellIDs[bar.spellID]["limit"] then
					table.insert(self.cache, bar)
					bar:SetAlpha(1)
				else
					bar:SetAlpha(0)
				end
			else
				table.insert(self.cache, bar)
			end					
		end
		
		if #self.cache > 1 then
			table.sort(self.cache, function(a, b) 
				if a.spellID < b.spellID then
					return true
				elseif a.spellID == b.spellID then	
					return a.auraID < b.auraID
				end
			end)
		end

		local lastbar
		for i, bar in pairs(self.cache) do			
			bar:ClearAllPoints()
			if not lastbar then
				bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			else
				bar:SetPoint("TOPLEFT", lastbar, "BOTTOMLEFT", 0, -2)	
			end
			lastbar = bar
		end
	end
	
	function frame:PreviewShow()
		local num
		if self.bar_num then
			num = self.bar_num
		elseif self.ficon == "0" then
			num = 2
		else
			num = 4
		end
		for spellID, info in pairs(self.spellIDs) do
			local color = info.color or {.7, .2, .1}
			for i = 1, num do
				self.bars[i] = CreateTimerBar(self, info.icon, false, false, false, JST_CDB["BossMod"][self.config_id]["width_sl"], JST_CDB["BossMod"][self.config_id]["height_sl"], color)
				self.bars[i].spellID = spellID				
				self.bars[i].auraID = i
			end
			break
		end
		self:lineup()
	end
	
	function frame:PreviewHide()
		for _, bar in pairs(self.bars) do
			bar:Hide()
			bar:ClearAllPoints()
		end
		self.bars = table.wipe(self.bars)
	end
end

T.UpdateUnitAuraBars = function(frame, event, ...)
	if event == "UNIT_AURA" then
		local unit, updateInfo = ...
		if updateInfo == nil or updateInfo.isFullUpdate then
			for auraID, bar in pairs(frame.bars) do				
				frame:remove_bar(auraID) -- bug 需要区分unit
			end
			
			for spellID, info in pairs(frame.spellIDs) do
				local effect_ind = info.effect
				AuraUtil.ForEachAura(unit, info.aura_type or "HARMFUL", nil, function(AuraData)
					if spellID == AuraData.spellId then
						local auraID = AuraData.auraInstanceID
						local name = UnitName(unit)
						local GUID = UnitGUID(unit)
						local effect_value = AuraData.points and effect_ind and AuraData.points[effect_ind] or 0
						frame:create_bar(auraID, spellID, name, GUID)
						frame:update_bar(auraID, spellID, AuraData.applications, AuraData.duration, AuraData.expirationTime, effect_value)						
					end
				end, true)
			end
			
		else
			if updateInfo.addedAuras ~= nil then
				for _, AuraData in pairs(updateInfo.addedAuras) do
					local spellID = AuraData.spellId
					local info = frame.spellIDs[spellID]
					if info then
						local auraID = AuraData.auraInstanceID
						if not frame.bars[auraID] then
							local name = UnitName(unit)
							local GUID = UnitGUID(unit)
							frame:create_bar(auraID, spellID, name, GUID)
							local effect_ind = info.effect
							local effect_value = 0
							if effect_ind and AuraData.points and AuraData.points[effect_ind] then
								effect_value = AuraData.points[effect_ind]
							end
							frame:update_bar(auraID, spellID, AuraData.applications, AuraData.duration, AuraData.expirationTime, effect_value)
						end
					end
				end
			end
			if updateInfo.updatedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do		
					if frame.bars[auraID] then
						local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
						if AuraData then
							local spellID = AuraData.spellId
							local effect_ind = frame.spellIDs[spellID].effect
							local effect_value = 0
							if effect_ind and AuraData.points and AuraData.points[effect_ind] then
								effect_value = AuraData.points[effect_ind]
							end
							frame:update_bar(auraID, spellID, AuraData.applications, AuraData.duration, AuraData.expirationTime, effect_value)
						else
							local bar = frame.bars[auraID]						
							frame:remove_bar(auraID)
						end
					end
				end
			end
			if updateInfo.removedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
					if frame.bars[auraID] then
						local bar = frame.bars[auraID]						
						frame:remove_bar(auraID)
					end
				end
			end
		end
	end
end

T.ResetUnitAuraBars = function(frame)
	for spellID, info in pairs(frame.spellIDs) do
		GlowRaidFrame_HideAll(info.hl_raid, "multiauras"..spellID)
	end
	for auraID, bar in pairs(frame.bars) do		
		bar:Hide()
		bar:SetScript("OnUpdate", nil)
	end		
	frame.bars = table.wipe(frame.bars)
	frame:Hide()
end

--------------------------------------------------------
------------  [首领模块]点名统计 模板  -----------------
--------------------------------------------------------
-- 共用
--		frame.aura_id = 48438 -- 监控光环
--		frame.element_type = "circle" -- circle/bar 显示样式，默认"bar"
--		frame.send_msg_channel = "YELL" -- 默认为"SAY"
--		frame.color = {.7, .2, .1} -- 计时条颜色/团队框架动画颜色
--		frame.role = true -- 显示职责
--		frame.raid_glow = "pixel" -- 团队框架动画
--		frame.raid_index = true -- 显示团队框架序号
--		frame.disable_copy_mrt = true -- 禁用粘贴模板
--		frame.mrt_copy_custom = true -- 模板里包含指定位置讯息
--		frame.mrt_copy_reverse = true -- 模板里包含反向排列讯息
--		frame.support_spells = 10 -- 给技能提示(技能轮数)
-- 		frame.show_backup = true -- 显示候补人员

-- Atlas:DungeonSkull

--		frame.graph_tex_info = { -- 按表格生成示意图图案
--			line = {layer = "BACKGROUND", tex = G.media.blank, color = {1, 1, 0}, w = 100, h = 10, points = {"TOPLEFT", 0, 0}}, -- 图案
--			star = {layer = "ARTWORK", rm = 1, points = {"TOPLEFT", 0, 0}}, -- 标记
--			boss = {layer = "ARTWORK", displayID = 111794, size = 50, points = {"TOPLEFT", 0, 0}},	-- 首领头像 
--			str = {layer = "ARTWORK", text = L["集合"], fs = 20, color = {1, 1, 1}, points = {"TOPLEFT", 0, 0}},	-- 文字
--		}
--		id, name, description, displayInfo, iconImage, uiModelSceneID = EJ_GetCreatureInfo(i)

--		function frame:filter(GUID) 过滤
--		function frame:pre_update_auras -- 触发时挂载功能 可配合frame.skip 跳过轮次
--		function frame:post_update_auras -- 分配结束时挂载功能 仅适用于整体排序
--		function frame:post_display(element, index, unit, GUID) 队友获得序号时挂载功能
--		function frame:post_remove(element, index, unit, GUID) 队友移除光环时挂载功能

-- 示意图类
--		frame.frame_width = 100 -- 圆圈示意图模式控制框架尺寸
--	 	frame.frame_height = 100 -- 圆圈示意图模式控制框架尺寸
-- 		frame.info = { -- 按表格生成喊话、声音、标记、站位标点讯息
--			{text = T.FormatRaidMark("1"), msg_applied = L["左"].."%name", msg = L["左"].."%dur", sound = "[left]cd3", rm = 1, x = 50, y = 50}, -- 相对于BOTTOMLEFT的绝对位置（xy必需）
--		}

-- 计时条类
-- 		frame.info = { -- 按表格生成喊话、声音、标记、站位标点讯息
--			{text = T.FormatRaidMark("1"), msg_applied = L["右"].."%name", msg = L["右"].."%dur", sound = "[left]cd3", x_offset = -25， y_offset = -25}, -- 相对于上一项的相对位置（x_offset、y_offset可选）
--		}

-- 整体排序根据难度改变点名总数以加快分配，否则直接获取frame.info条目数量
--		frame.diffculty_num = {
--			[14] = 2, -- PT
--			[15] = 3, -- H
--			[16] = 4, -- M
--			[17] = 1, -- LFG
--		}
-- 整体排序根据位置优先级自动排序
--		frame.pos_pro = {
--			["MELEE"] = 1,
--			["HEALER"] = 2,	
--			["RANGED"] = 3,
--			["TANK"] = 4,	
--		}

-- 逐个填坑MRT模板，以便反向排序
--	frame.copy_reverse

-- 光环

-- event: COMBAT_LOG_EVENT_UNFILTERED

--		T.InitAuraMods_ByMrt(frame)
--		T.UpdateAuraMods_ByMrt(frame, event, ...)
--		T.ResetAuraMods_ByMrt(frame)

--		T.InitAuraMods_ByTime(frame)
--		T.UpdateAuraMods_ByTime(frame, event, ...)
--		T.ResetAuraMods_ByTime(frame)

-- 交互宏

-- event: ADDON_MSG
-- event: UNIT_SPELLCAST_START/UNIT_SPELLCAST_SUCCEEDED

--		frame.cast_info = {	-- 轮次事件和法术
--			["UNIT_SPELLCAST_START"] = {[426519] = true,[426519] = true, [426519] = true},
--			["UNIT_SPELLCAST_SUCCEEDED"] = {[426519] = true,[426519] = true, [426519] = true},
--		}
--		frame.dur = 20 -- 轮次持续时间
--		frame.pa_icon = true -- Private Auras 图标
--		frame.macro_button = true -- 宏按钮

--		T.InitMacroMods_ByMRT(frame)
--		T.UpdateMacroMods_ByMRT(frame, event, ...)
--		T.ResetMacroMods_ByMRT(frame)

--		T.InitMacroMods_ByTime(frame)
--		T.UpdateMacroMods_ByTime(frame, event, ...)
--		T.ResetMacroMods_ByTime(frame)
--------------------------------------------------------
------------  [首领模块]点名统计 共用API  --------------
--------------------------------------------------------
local function UpdateTexture(f, data)
	if data.tex or data.atlas or data.displayID then
		if not f.tex then
			f.tex = f:CreateTexture(nil, data.layer)
			f.tex:SetAllPoints(f)
		end
		
		if data.tex then
			f.tex:SetTexture(data.tex)
		elseif data.atlas then
			f.tex:SetAtlas(data.atlas)
		elseif data.displayID then
			SetPortraitTextureFromCreatureDisplayID(f.tex, data.displayID)
		end
		
		if data.fade then
			f.tex:SetDesaturated(true)
		end
		
		if data.color then
			f.tex:SetVertexColor(unpack(data.color))
		end
		
		if data.coords then
			f.tex:SetTexCoord(unpack(data.coords))
		end
		
		if data.rotation then
			f.tex:SetRotation(data.rotation/180*math.pi)
		end
	end
	
	if data.rm then
		if not f.rm_tex then
			f.rm_tex = f:CreateTexture(nil, data.layer)
			f.rm_tex:SetPoint("CENTER")
			f.rm_tex:SetSize(20, 20)
			f.rm_tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		end		
		SetRaidTargetIconTexture(f.rm_tex, data.rm)
	end
	
	if data.tag then
		if not f.tagtext then
			f.tagtext = T.createtext(f, "OVERLAY", 10, "OUTLINE", "CENTER")
			f.tagtext:SetPoint("CENTER", f, "TOP")
			f.tagtext:SetTextColor(1, 1, 0)
		end
		f.tagtext:SetText(data.tag)
	end
end

local function UpdateText(f, data)
	if not f.text then
		f.text = T.createtext(f, data.layer, data.fs, "OUTLINE", "CENTER")
		f.text:SetAllPoints(f)
	end
	
	if data.color then
		f.text:SetTextColor(unpack(data.color))
	end
	
	f.text:SetText(data.text)
end

-- 示意图图案
local UpdateGraphTextures = function(frame, anchor_frame)
	if frame.graph_tex_info then	
		if not frame.graphs then
			frame.graphs = {}
		end
		
		T.createborder(anchor_frame or frame) -- 背景边框
		
		for name, data in pairs(frame.graph_tex_info) do -- 背景图案
			if not frame.graphs[name] then
				frame.graphs[name] = CreateFrame("Frame", nil, anchor_frame or frame)
			end
			
			local f = frame.graphs[name]
			
			if data.w and data.h then
				f:SetSize(data.w, data.h)
			elseif data.fs then
				f:SetSize(data.fs*6, data.fs)
			else
				f:SetSize(data.size or 30, data.size or 30)
			end
			
			f:ClearAllPoints()
			f:SetPoint(unpack(data.points))
			
			if data.tex or data.atlas or data.displayID or data.rm or data.tag then				
				UpdateTexture(f, data)			
			elseif data.text then
				UpdateText(f, data)			
			end
		end
		
		for name, f in pairs(frame.graphs) do -- 去掉已删除标记
			if not frame.graph_tex_info[name] then
				f:Hide()
				frame.graphs[name] = nil
			end
		end
	end
end
T.UpdateGraphTextures = UpdateGraphTextures

-- MRT模板生成
local Copy_Mrt_Raidlist = function(frame, rev, custom)
	local players = {}
	local rev_player = {}
	local custom_players = {}
	local raidlist = ""
	
	local i = 1
	for unit in T.IterateGroupMembers() do
		i = i + 1
		local name = UnitName(unit)
		
		if rev and mod(i, 2) == 0 then
			table.insert(rev_player, T.ColorNameForMrt(name))
		else
			table.insert(players, T.ColorNameForMrt(name))
		end
			
		if i <= 3 then
			table.insert(custom_players, T.ColorNameForMrt(name))
		end
	end
	
	raidlist = table.concat(players, " ")
	
	if rev then
		raidlist = raidlist.."\n"..L["反向"]..":"..table.concat(rev_player, " ")
	end
	
	if custom then
		raidlist = raidlist.."\n"..string.format("%s:%s:%s:%s", L["指定"], L["所有轮次"], string.format(L["%d号位"], 1),  custom_players[1])
		raidlist = raidlist.."\n"..string.format("%s:%s:%s:%s", L["指定"], string.format(L["第%d轮"], 2), string.format(L["%d号位"], 2), custom_players[2] or custom_players[1])
		raidlist = raidlist.."\n"..string.format("%s:%s:%s:%s", L["指定"], string.format(L["第%d轮"], 2), string.format(L["%d号位"], 3), custom_players[3] or custom_players[1])
	end
	
	local spellName = T.GetSpellInfo(frame.config_id)
	raidlist = string.format("#%dstart%s\n%s\nend", frame.config_id, spellName, raidlist).."\n"
	
	return raidlist
end
T.Copy_Mrt_Raidlist = Copy_Mrt_Raidlist

-- 获取/生成团队信息 ByIndex
local function GetAssignmentByIndex(frame)
	frame.assignment = table.wipe(frame.assignment)
	frame.custom_assignment = table.wipe(frame.custom_assignment)

	local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
	local tagmatched
	
	if text then
		local betweenLine
		local tag = string.format("#%dstart", frame.config_id)
		for line in text:gmatch('[^\r\n]+') do
			if line == "end" then
				betweenLine = false
			end
			if betweenLine then
				if string.find(line, L["指定"]..":") then
					local count, index = select(2, string.split(":",line))
					count = string.match(count, "%d") and tonumber(string.match(count, "%d")) or "all"
					index = string.match(index, "%d") and tonumber(string.match(index, "%d"))
					if index then
						if not frame.custom_assignment[count] then
							frame.custom_assignment[count] = {}
						end
						if not frame.custom_assignment[count][index] then
							frame.custom_assignment[count][index] = {}
						end
						for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
							local info = T.GetGroupInfobyName(name)
							if info then
								table.insert(frame.custom_assignment[count][index], info.GUID)
							else
								T.msg(string.format(L["昵称错误"], name))
							end
						end
					end				
				else
					for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
						local info = T.GetGroupInfobyName(name)
						if info then		
							table.insert(frame.assignment, info.GUID)
						else
							T.msg(string.format(L["昵称错误"], name))
						end
					end
				end
			end
			if line:match(tag) then
				betweenLine = true
				tagmatched = true
			end
		end
	end
	
	
	if frame.pos_pro then	
		frame.pos_order_cache = table.wipe(frame.pos_order_cache)
		for unit in T.IterateGroupMembers() do
			local GUID = UnitGUID(unit)
			if not T.IsInTable(frame.assignment, GUID) then
				local info = T.GetGroupInfobyGUID(GUID)
				table.insert(frame.pos_order_cache, {GUID = info.GUID, pos = info.pos})
			end
		end
		if #frame.pos_order_cache > 1 then
			table.sort(frame.pos_order_cache, function(a, b)
				if frame.pos_pro[a.pos] and frame.pos_pro[b.pos] and frame.pos_pro[a.pos] < frame.pos_pro[b.pos] then
					return true
				elseif frame.pos_pro[a.pos] and frame.pos_pro[b.pos] and frame.pos_pro[a.pos] == frame.pos_pro[b.pos] and a.GUID < b.GUID then
					return true
				end
			end)
		end
		for i, info in pairs(frame.pos_order_cache) do
			table.insert(frame.assignment, info.GUID)
		end
	else
		for unit in T.IterateGroupMembers() do
			local GUID = UnitGUID(unit)
			if not T.IsInTable(frame.assignment, GUID) then
				table.insert(frame.assignment, GUID)
			end
		end
	end
end

-- 获取/生成团队信息 ByName
local function GetAssignmentByName(frame)
	frame.positive_assignment = table.wipe(frame.positive_assignment)
	frame.reverse_assignment = table.wipe(frame.reverse_assignment)

	local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
	local tagmatched
	
	if text then
		local betweenLine
		local tag = string.format("#%dstart", frame.config_id)
		for line in text:gmatch('[^\r\n]+') do
			if line == "end" then
				betweenLine = false
			end
			if betweenLine then
				if string.find(line, L["反向"]..":") then
					for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
						local info = T.GetGroupInfobyName(name)
						if info then					
							frame.reverse_assignment[info.GUID] = true
						else
							T.msg(string.format(L["昵称错误"], name))
						end
					end
				else
					for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
						local info = T.GetGroupInfobyName(name)
						if info then
							frame.positive_assignment[info.GUID] = true
						else
							T.msg(string.format(L["昵称错误"], name))
						end
					end
				end
			end
			if line:match(tag) then
				betweenLine = true
				tagmatched = true
			end
		end
	end
	
	for unit in T.IterateGroupMembers() do
		local GUID = UnitGUID(unit)
		if not (frame.positive_assignment[GUID] or frame.reverse_assignment[GUID]) then
			frame.positive_assignment[GUID] = true
		end
	end
end

-- 候补功能
local CreateBackupText = function(frame, anchor_frame)
	frame.backups = {}
	
	frame.backup_text = T.createtext(anchor_frame, "OVERLAY", 16, "OUTLINE", "LEFT")
	frame.backup_text:SetPoint("TOPLEFT", anchor_frame, "BOTTOMLEFT")
	frame.backup_text:SetWidth(200)
	
	if not frame.show_backup then
		frame.backup_text:Hide()
	end
	
	function frame:UpdateBackupInfo()
		local t = ""
		for GUID in pairs(self.backups) do
			t = t.." "..T.ColorNickNameByGUID(GUID)
		end
		self.backup_text:SetText(t)
	end
	
	function frame:AddBackup(GUID)
		if not self.backups[GUID] then
			self.backups[GUID] = true
			self:UpdateBackupInfo()
		end
	end
	
	function frame:RemoveBackup(GUID)
		if self.backups[GUID] then
			self.backups[GUID] = nil
			self:UpdateBackupInfo()
		end
	end
	
	function frame:RemoveAllBackups()
		table.wipe(self.backups)
		self:UpdateBackupInfo()
	end
end

-- 获取下一个可用项
local GetNextElementAvailable = function(frame, rev)
	if rev then
		for i = #frame.elements, 1, -1 do
			if frame.elements[i].available then
				return frame.elements[i]
			end
		end
	else
		for i = 1, #frame.elements, 1 do
			if frame.elements[i].available then
				return frame.elements[i]
			end
		end
	end
end
T.GetNextElementAvailable = GetNextElementAvailable

-- 玩家获得光环动作（喊话和声音）
local AuraAction = function(frame, my_index)
	if JST_CDB["BossMod"][frame.config_id]["say_bool"] or JST_CDB["BossMod"][frame.config_id]["sound_bool"] then
		local info = frame.info[my_index]
		local tag = info.rm and string.format("{rt%d}", info.rm) or my_index
		
		local count, exp_time, remain
		if C_UnitAuras.AuraIsPrivate(frame.aura_id) then
			count = 0
			exp_time = frame.last_exp
		else
			count = select(3, AuraUtil.FindAuraBySpellID(frame.aura_id, "player", G.TestMod and "HELPFUL" or "HARMFUL"))
			exp_time = select(6, AuraUtil.FindAuraBySpellID(frame.aura_id, "player", G.TestMod and "HELPFUL" or "HARMFUL"))
		end
		remain = exp_time - GetTime()
		
		if info.msg_applied then
			T.SendAuraMsg(info.msg_applied, frame.send_msg_channel or "SAY", frame.aura_name, count, remain, tag)
		end
		
		if info.msg then
			frame.msg_countdown = floor(remain)
		end
		
		if info.sound then
			local sound_file = string.match(info["sound"], "%[(.+)%]")
			if sound_file then
				T.PlaySound(sound_file)
			end
			local cd = string.match(info["sound"], "cd(%d+)")
			if cd then
				frame.voi_countdown = tonumber(cd)
			end
		end
		
		if frame.msg_countdown or frame.voi_countdown then
			frame:SetScript("OnUpdate", function(self, e)
				self.t = self.t + e
				if self.t > .05 then
					local remain = exp_time - GetTime()
					if remain > 0 then
						local second = ceil(remain)
						
						if self.msg_countdown and second < self.msg_countdown then -- 发言频率1秒		
							T.SendAuraMsg(info.msg, self.send_msg_channel or "SAY", self.aura_name, count, remain, tag)
							self.msg_countdown = self.msg_countdown - 1
						end
						
						if self.voi_countdown and second == self.voi_countdown then -- 倒数频率1秒
							T.PlaySound("count\\"..second)
							self.voi_countdown = self.voi_countdown - 1
						end
					else
						self:SetScript("OnUpdate", nil) -- 停止刷新
					end				
					self.t = 0
				end
			end)
		end
	end
end

local Raidrole_tags = {
	["HEALER"] = L["治疗颜色"],
	["MELEE"] = L["近战颜色"],
	["RANGED"] = L["远程颜色"],
	["TANK"] = L["坦克颜色"],
}

local UpdateRoleTag = function(role, pos)
	if not role then
		return ""
	elseif role == "HEALER" or role == "TANK" then
		return Raidrole_tags[role]
	else
		return Raidrole_tags[pos]
	end
end

-- 点名出现
local function OnElementDisplayed(frame, self, text, i, GUID)
	self.GUID = GUID
	self.available = false
	
	local info = T.GetGroupInfobyGUID(GUID)
	local role_tag = frame.role and UpdateRoleTag(info.role, info.pos) or ""
	local mark = frame.info[i]["rm"] and T.FormatRaidMark(frame.info[i]["rm"]) or ""
	local tag = frame.info[i]["text"] or ""

	text:SetText(string.format("%s%s%s %s", role_tag, mark, tag, info.format_name))
	
	if T.IsInPreview() then
		self:SetMinMaxValues(0, 1)
		self:SetValue(1)
	else
		frame.actives[GUID] = self
	
		-- 输出讯息
		T.msg(string.format("%s"..L["第%d轮"]..L["%d号位"].."%s%s %s %s", T.GetIconLink(frame.aura_id), frame.count, i, mark, tag, info.format_name, self.custom and L["优先级高"] or ""))
	
		-- 框架高亮
		if frame.raid_glow and JST_CDB["BossMod"][frame.config_id]["raid_glow_bool"] then
			if frame.color then
				GlowRaidFramebyUnit_Show(frame.raid_glow, "debuff"..frame.config_id, info.unit, frame.color)
			else
				GlowRaidFramebyUnit_Show(frame.raid_glow, "debuff"..frame.config_id, info.unit, {.7, .2, .1})
			end
		end
	
		-- 框架序号
		if frame.raid_index and JST_CDB["BossMod"][frame.config_id]["raid_index_bool"] then
			local unit_frame = T.GetUnitFrame(info.unit)
			if unit_frame then					
				T.CreateRFIndex(unit_frame, i)
			end
		end
	
		-- 上标记
		if frame.info[i].rm and JST_CDB["BossMod"][frame.config_id]["mark_bool"] then
			T.SetRaidTarget(info.unit, frame.info[i].rm)
		end
	
		-- 喊话和声音
		if UnitIsUnit(info.unit, "player") then
			AuraAction(frame, i)		
		end
	
		if frame.support_spells then
			for _, v in pairs(JST_CDB["BossMod"][frame.config_id]["option_list_btn"]) do
				if v.spell_count == frame.count and v.spell_ind == i then				
					if v.all_spec then
						T.FormatAskedSpell(GUID, v.support_spellID, 4)
						T.msg(string.format(L["需要给技能%s"], T.GetIconLink(frame.aura_id), frame.count, i, info.format_name, T.GetIconLink(v.support_spellID)))
					else
						if info.spec_id and v.spec_info[info.spec_id] then
							T.FormatAskedSpell(GUID, v.support_spellID, 4)
							T.msg(string.format(L["需要给技能%s"], T.GetIconLink(frame.aura_id), frame.count, i, info.format_name, T.GetIconLink(v.support_spellID)))
						end
					end
				end
			end
		end
		
		-- 其他
		if frame.post_display then
			frame:post_display(self, i, info.unit, GUID)
		end
	end
end

-- 点名取消
local function OnElementRemoved(frame, self, text, i)
	if self.GUID then
		local info = T.GetGroupInfobyGUID(self.GUID)
		
		if frame.actives[info.GUID] then
			frame.actives[info.GUID] = nil
			
			-- 框架高亮
			if frame.raid_glow and JST_CDB["BossMod"][frame.config_id]["raid_glow_bool"] then
				GlowRaidFramebyUnit_Hide(frame.raid_glow, "debuff"..frame.config_id, info.unit)
			end
			
			-- 团队框架序号
			if frame.raid_index and JST_CDB["BossMod"][frame.config_id]["raid_index_bool"] then
				local unit_frame = T.GetUnitFrame(info.unit)
				if unit_frame then	
					T.HideRFIndexbyParent(unit_frame)
				end
			end
			
			-- 喊话和声音
			if UnitIsUnit(info.unit, "player") then
				frame:SetScript("OnUpdate", nil)
			end
			
			-- 其他
			if frame.post_remove then
				frame:post_remove(self, i, info.unit, info.GUID)
			end
		end	
	end
	
	self.GUID = nil
	self.available = true
	
	text:SetText(i)
end

-- 计时条
local function CreateElementBar(frame, i)
	local icon = select(2, T.GetSpellInfo(frame.aura_id))
	
	local bar = CreateTimerBar(frame.graph_bg, icon, false, true)
	
	bar.index = i
	
	bar.mid:ClearAllPoints()
	bar.mid:SetPoint("RIGHT", bar.right, "LEFT", 0, 0)
	
	if i == 1 then
		bar:SetPoint("TOPLEFT", frame.graph_bg, "TOPLEFT", frame.info[i].x_offset or 0, frame.info[i].y_offset or 0)
	else
		bar:SetPoint("TOPLEFT", frame.elements[i-1], "BOTTOMLEFT", frame.info[i].x_offset or 0, frame.info[i].y_offset or -2)
	end
	
	if frame.color then
		bar:SetStatusBarColor(unpack(frame.color))
	else
		bar:SetStatusBarColor( .7, .2, .1) 
	end
	
	bar:SetAlpha(0)
	bar.left:SetText(i)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	bar.available = true
	
	function bar:display(GUID, custom)
		self.custom = custom
		self:SetAlpha(1)
		
		OnElementDisplayed(frame, self, self.left, i, GUID)
	end
	
	function bar:remove()
		self:SetAlpha(0)
		
		self:SetScript("OnUpdate", nil)
		
		self.mid:SetText("")
		self.right:SetText("")
		self:SetMinMaxValues(0, 1)
		self:SetValue(0)
			
		OnElementRemoved(frame, self, self.left, i)
	end
	
	table.insert(frame.elements, bar)
	
	return bar
end

-- 圆圈
local function CreateElementCircle(frame, i)
	local circle = CreateCircle(frame.graph_bg, frame.info[i].rm)
	circle:SetPoint("BOTTOMLEFT", frame.graph_bg, "BOTTOMLEFT", frame.info[i].x, frame.info[i].y)
	
	circle.index = i
	
	circle.tex:SetVertexColor(.5, .5, .5)
	circle.text:SetText(i)
	circle.available = true
	
	function circle:display(GUID, custom)	
		self.custom = custom
		
		if GUID == G.PlayerGUID then
			self.tex:SetVertexColor(1, .3, 0)
		else
			self.tex:SetVertexColor(0, .6, .6)
		end
		
		OnElementDisplayed(frame, self, self.text, i, GUID)
	end
	
	function circle:remove()	
		self.tex:SetVertexColor(.5, .5, .5)
		
		self:SetScript("OnUpdate", nil)
			
		OnElementRemoved(frame, self, self.text, i)
	end
	
	table.insert(frame.elements, circle)
	
	return circle
end

-- 整体排序初始化
local function InitModsByMrt(frame)
	frame.graphs = {}
	frame.elements = {}
	frame.actives = {}
	frame.assignment = {}
	frame.custom_assignment = {}
	frame.pos_order_cache = {}
	
	frame.aura_name = T.GetSpellInfo(frame.aura_id)
	
	frame.count = 0
	frame.aura_num = 0
	
	if not frame.disable_copy_mrt then
		function frame:copy_mrt()
			return Copy_Mrt_Raidlist(self, false, self.mrt_copy_custom)
		end
	end
	T.GetElementsCustomData(frame)
	
	if frame.frame_width and frame.frame_height then
		frame:SetSize(frame.frame_width, frame.frame_height)
	end
	
	frame.graph_bg = CreateFrame("Frame", nil, frame)
	frame.graph_bg:SetAllPoints(frame)
	frame.graph_bg:Hide()
	
	CreateBackupText(frame, frame.graph_bg)
	UpdateGraphTextures(frame, frame.graph_bg)
end

-- 逐个填坑初始化
local function InitModByTime(frame)
	frame.graphs = {}
	frame.elements = {}
	frame.actives = {}
	frame.positive_assignment = {}
	frame.reverse_assignment = {}
	
	frame.aura_name = T.GetSpellInfo(frame.aura_id)
	
	frame.count = 0
	
	if frame.copy_reverse then
		function frame:copy_mrt()
			return Copy_Mrt_Raidlist(self, self.mrt_copy_reverse)
		end
	end
	T.GetElementsCustomData(frame)
	
	if frame.frame_width and frame.frame_height then
		frame:SetSize(frame.frame_width, frame.frame_height)
	end
	
	frame.graph_bg = CreateFrame("Frame", nil, frame)
	frame.graph_bg:SetAllPoints(frame)
	frame.graph_bg:Hide()
	
	CreateBackupText(frame, frame.graph_bg)
	UpdateGraphTextures(frame, frame.graph_bg)
end

-- 难度检测
local function GetTotalAuraNumber(frame)
	if frame.total_aura_num then
		return frame.total_aura_num
	elseif frame.diffculty_num and frame.difficultyID and frame.diffculty_num[frame.difficultyID] then
		return frame.diffculty_num[frame.difficultyID]
	else
		return #frame.info
	end
end
--------------------------------------------------------
------------  [首领模块]光环统计 共用API  --------------
--------------------------------------------------------
-- 光环计时条
local CreateAuraBar = function(frame, i)	
	local bar = CreateElementBar(frame, i)
	
	function bar:update(count, dur, exp_time)
		self.mid:SetText((count and count > 0 and string.format("|cffFFFF00[%d]|r ", count) or ""))
		
		self.dur = dur
		self.exp_time = exp_time
		
		if exp_time ~= 0 then
			if not self:GetScript("OnUpdate") then
				self:SetMinMaxValues(0, self.dur)
				self:SetValue(0)
				self:SetScript("OnUpdate", function(s, e)
					s.t = s.t + e
					if s.t > s.update_rate then
						s.remain = s.exp_time - GetTime()
						if s.remain > 0 then
							s.right:SetText(T.FormatTime(s.remain))
							s:SetValue(s.dur - s.remain)
						else
							s:remove()
						end
						s.t = 0
					end
				end)
			end
		else
			self.right:SetText("")
			self:SetMinMaxValues(0, 1)
			self:SetValue(1)		
		end
	end
end

-- 光环圆圈
local CreateAuraCircle = function(frame, i)
	local circle = CreateElementCircle(frame, i)
	
	function circle:update(count, dur, exp_time)
		self.exp_time = exp_time
		
		if exp_time ~= 0 then
			if not self:GetScript("OnUpdate") then
				self:SetScript("OnUpdate", function(s, e)
					s.t = s.t + e
					if s.t > s.update_rate then
						s.remain = s.exp_time - GetTime()
						if s.remain < 0 then
							s:remove()
						end
						s.t = 0
					end
				end)
			end
		end
	end
end

--------------------------------------------------------
------------  [首领模块]光环统计 整体排序  -------------
--------------------------------------------------------

T.InitAuraMods_ByMrt = function(frame)
	InitModsByMrt(frame)
	
	frame.last_update_time = 0

	for i in pairs(frame.info) do
		if frame.element_type == "circle" then
			CreateAuraCircle(frame, i)
		else
			CreateAuraBar(frame, i)
		end
	end
	
	function frame:Prepare()
		self.count = self.count + 1
		
		if self.pre_update_auras then
			self:pre_update_auras()
		end
		
		-- 跳过这一轮
		if self.skip then return end
		
		self.graph_bg:Show()
		
		C_Timer.After(2, function() -- 强制刷新
			if GetTime() - self.last_update_time >= 5 then
				self:Display()
				self.last_update_time = GetTime() -- 刷新时间
				if self.post_update_auras then
					local total = T.GetTableNum(self.actives)
					self:post_update_auras(total)
				end
			end
		end)
	end
	
	function frame:Update(GUID)
		if self.actives[GUID] then
			local unit_id = T.GetGroupInfobyGUID(GUID)["unit"]
			local count, _, dur, exp_time = select(3, AuraUtil.FindAuraBySpellID(self.aura_id, unit_id, G.TestMod and "HELPFUL" or "HARMFUL"))
			self.actives[GUID]:update(count, dur, exp_time)
		end
	end
	
	function frame:Display()	
		-- 第一轮排序：指定位置
		local custom_count_key
		if self.custom_assignment[self.count] then
			custom_count_key = self.count
		elseif self.custom_assignment["all"] then
			custom_count_key = "all"
		end
		if custom_count_key then
			for index, players in pairs(self.custom_assignment[custom_count_key]) do
				for _, GUID in pairs(players) do
					if self.backups[GUID] then					
						local element = self.elements[index]
						if element.available then
							element:display(GUID, true)						
							self:Update(GUID)
							self:RemoveBackup(GUID)
							break
						end
					end
				end
			end
		end
		
		-- 第二轮排序：常规排序
		for _, GUID in pairs(self.assignment) do
			if self.backups[GUID] then
				local element = GetNextElementAvailable(self)
				if element then
					element:display(GUID)
					self:Update(GUID)
					self:RemoveBackup(GUID)
				end
			end
		end
	end
	
	function frame:Remove(GUID)
		local element = self.actives[GUID]
		if element then
			element:remove()
			self:Display()
			self:UpdateBackupInfo()
		end
		self:RemoveBackup(GUID)
	end
	
	function frame:PreviewShow()
		for i, element in pairs(self.elements) do
			element:display(G.PlayerGUID)
		end
		self.graph_bg:Show()
	end
	
	function frame:PreviewHide()
		for i, element in pairs(self.elements) do
			element:remove()
		end
		self.graph_bg:Hide()
	end
end

T.UpdateAuraMods_ByMrt = function(frame, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, sub_event, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if sub_event == "SPELL_AURA_APPLIED" and spellID == frame.aura_id then
			frame.aura_num = frame.aura_num + 1
			
			if frame.aura_num == 1 then -- 点出第一个
				frame:Prepare()
			end
			
			if T.IsInTable(frame.assignment, destGUID) and (not frame.filter or frame:filter(destGUID)) then
				frame:AddBackup(destGUID)
				if frame.aura_num == GetTotalAuraNumber(frame) then
					frame:Display()
					frame.last_update_time = GetTime() -- 刷新时间
					if frame.post_update_auras then
						local total = T.GetTableNum(frame.actives)
						frame:post_update_auras(total)
					end
				end
			end
		elseif (sub_event == "SPELL_AURA_APPLIED_DOSE" or sub_event == "SPELL_AURA_REMOVED_DOSE" or sub_event == "SPELL_AURA_REFRESH") and spellID == frame.aura_id and destGUID then
			frame:Update(destGUID)
		elseif sub_event == "SPELL_AURA_REMOVED" and spellID == frame.aura_id then
			frame.aura_num = frame.aura_num - 1
			
			if frame.aura_num == 0 then -- 全部消除
				frame.graph_bg:Hide()
			end
			
			frame:Remove(destGUID)
		end
	elseif event == "ENCOUNTER_START" then
		frame.aura_num = 0
		frame.count = 0
		frame.last_update_time = 0
		frame.difficultyID = select(3, ...)
		
		-- 获取分组数据	
		GetAssignmentByIndex(frame)
	end
end

T.ResetAuraMods_ByMrt = function(frame)
	for _, element in pairs(frame.actives) do
		element:remove()
	end
	if frame.raid_index then
		T.HideAllRFIndex()
	end
	frame:RemoveAllBackups()
	frame.graph_bg:Hide()
	frame:Hide()
end

--------------------------------------------------------
------------  [首领模块]光环统计 逐个填坑  -------------
--------------------------------------------------------

T.InitAuraMods_ByTime = function(frame)
	InitModByTime(frame)
	
	frame.aura_num = 0
	
	for i, data in pairs(frame.info) do		
		if frame.element_type == "circle" then
			CreateAuraCircle(frame, i)
		else
			CreateAuraBar(frame, i)
		end
	end
	
	function frame:Prepare()
		self.count = self.count + 1
		
		if self.pre_update_auras then
			self:pre_update_auras()
		end
		
		-- 跳过这一轮
		if self.skip then return end
		
		self.graph_bg:Show()
	end
	
	function frame:Update(GUID)
		if self.actives[GUID] then
			local unit_id = T.GetGroupInfobyGUID(GUID)["unit"]
			local count, _, dur, exp_time = select(3, AuraUtil.FindAuraBySpellID(self.aura_id, unit_id, G.TestMod and "HELPFUL" or "HARMFUL"))
			self.actives[GUID]:update(count, dur, exp_time)
		end
	end
	
	function frame:Display(GUID)		
		if self.positive_assignment[GUID] then
			local element = GetNextElementAvailable(self)
			if element then
				element:display(GUID)
				self:RemoveBackup(GUID)
				self:Update(GUID)
			end
		elseif self.reverse_assignment[GUID] then
			local element = GetNextElementAvailable(self, true)
			if element then
				element:display(GUID)
				self:RemoveBackup(GUID)
				self:Update(GUID)
			end	
		end
	end
	
	function frame:Remove(GUID)
		local element = self.actives[GUID]
		if element then
			element:remove()
			for GUID in pairs(self.backups) do -- 从候补中补充
				self:Display(GUID)
			end
			self:UpdateBackupInfo()
		end
		self:RemoveBackup(GUID)
	end
	
	function frame:PreviewShow()
		for _, element in pairs(self.elements) do
			element:display(G.PlayerGUID)
		end
		self.graph_bg:Show()
	end
	
	function frame:PreviewHide()
		for _, element in pairs(self.elements) do
			element:remove()
		end
		self.graph_bg:Hide()
	end
end

T.UpdateAuraMods_ByTime = function(frame, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, sub_event, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if sub_event == "SPELL_AURA_APPLIED" and spellID == frame.aura_id then
			frame.aura_num = frame.aura_num + 1
			
			if frame.aura_num == 1 then -- 点出第一个
				frame:Prepare()
			end
			
			if (frame.positive_assignment[destGUID] or frame.reverse_assignment[destGUID]) and (not frame.filter or frame:filter(destGUID)) then
				frame:AddBackup(destGUID)
				frame:Display(destGUID)
			end
		elseif (sub_event == "SPELL_AURA_APPLIED_DOSE" or sub_event == "SPELL_AURA_REMOVED_DOSE" or sub_event == "SPELL_AURA_REFRESH") and spellID == frame.aura_id and destGUID then
			frame:Update(destGUID)
		elseif sub_event == "SPELL_AURA_REMOVED" and spellID == frame.aura_id then
			frame.aura_num = frame.aura_num - 1
			
			if frame.aura_num == 0 then -- 全部消除
				frame.graph_bg:Hide()
			end
			
			frame:Remove(destGUID)
		end
	elseif event == "ENCOUNTER_START" then
		frame.aura_num = 0
		frame.count = 0
		
		-- 获取分组数据
		GetAssignmentByName(frame)
	end
end

T.ResetAuraMods_ByTime = function(frame)
	for _, element in pairs(frame.actives) do
		element:remove()
	end
	if frame.raid_index then
		T.HideAllRFIndex()
	end
	frame.graph_bg:Hide()
	frame:Hide()
end

--------------------------------------------------------
---------------  [首领模块]交互统计 API  ---------------
--------------------------------------------------------
-- 交互计时条
local CreateMacroBar = function(frame, i)	
	local bar = CreateElementBar(frame, i)
	
	function bar:update()	
		self:SetMinMaxValues(0, frame.dur)
		self:SetScript("OnUpdate", function(s, e)
			s.t = s.t + e
			if s.t > s.update_rate then
				local remain = frame.last_exp - GetTime()
				if remain > 0 then
					s.right:SetText(T.FormatTime(remain))
					s:SetValue(frame.dur - remain)						
				else
					s:remove()
				end
				s.t = 0
			end
		end)
	end
end

-- 交互圆圈
local CreateMacroCircle = function(frame, i)
	local circle = CreateElementCircle(frame, i)
	
	function circle:update()
		self:SetScript("OnUpdate", function(s, e)
			s.t = s.t + e
			if s.t > s.update_rate then
				local remain = frame.last_exp - GetTime()
				if remain <= 0 then
					s:remove()
				end
				s.t = 0
			end
		end)
	end
end

-- Private Aura 图标
local CreatePaIcon = function(frame)
	if frame.pa_icon then	
		T.CreateMovableFrame(frame, "paicon", 150, 150, {a1 = "CENTER", a2 = "CENTER", x = 0, y = 100}, "_PrivateIcon", L["PA图标提示"]) -- 有选项
		frame.paicon:SetAlpha(.3)
		frame.paicon:Hide()
	end
	
	function frame:ShowPrivateAuraIcon()
		if frame.paicon and JST_CDB["BossMod"][frame.config_id]["pa_icon_bool"] and not frame.auraAnchorID then
			frame.auraAnchorID = C_UnitAuras.AddPrivateAuraAnchor({
				unitToken = "player",
				auraIndex = 1,
				parent = frame.paicon,
				showCountdownFrame = true,
				showCountdownNumbers = true,
				iconInfo = {
					iconWidth = 150,
					iconHeight = 150,
					iconAnchor = {
						point = "CENTER",
						relativeTo = frame.paicon,
						relativePoint = "CENTER",
						offsetX = 0,
						offsetY = 0,
					},
				},
				durationAnchor = {
					point = "TOP",
					relativeTo = frame.paicon,
					relativePoint = "BOTTOM",
					offsetX = 0,
					offsetY = -1,
				},
			})
			frame.paicon:Show()			
		end
	end
	
	function frame:HidePrivateAuraIcon()
		if frame.paicon and frame.auraAnchorID then
			C_UnitAuras.RemovePrivateAuraAnchor(frame.auraAnchorID)
			frame.auraAnchorID = nil
			frame.paicon:Hide()			
		end
	end
end

-- 交互宏按钮
local CreateMacroButton = function(frame)
	if frame.macro_button then	
		T.CreateMovableFrame(frame, "macrobuttons", #frame.msg_info*50, 50, {a1 = "BOTTOMRIGHT", a2 =  "BOTTOMRIGHT", x = -200, y = 100}, "_MacroButton", L["交互宏按钮"]) -- 有选项
		
		frame.macrobuttons:Hide()
		frame.macrobuttons.buttons = {}
				
		for i, data in pairs(frame.msg_info) do
			local button = CreateFrame("Button", nil, frame.macrobuttons)
			button:SetSize(40, 40)
			button:SetPoint("LEFT", frame.macrobuttons, "LEFT", 5+50*(i-1), 0)
			
			T.createborder(button)
			
			button.text = T.createtext(button, "OVERLAY", 15, "OUTLINE", "LEFT")
			button.text:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT")
			button.text:SetText("/jst add"..data.msg)
			
			button.tex = button:CreateTexture(nil, "ARTWORK")
			button.tex:SetAllPoints()
			button.tex:SetTexture(select(2, T.GetSpellInfo(data.spellID)))
			button.tex:SetTexCoord( .1, .9, .1, .9)
			
			button:RegisterForClicks("LeftButtonDown", "RightButtonDown", "LeftButtonUp", "RightButtonUp")
			button:SetScript("OnMouseDown", function(self, button)
				if button == "LeftButton" then
					T.addon_msg("TargetMe"..data.msg..","..G.PlayerGUID, "GROUP")
					self.sd:SetBackdropBorderColor(0, 1, 0)
				else
					T.addon_msg("RemoveMe"..data.msg..","..G.PlayerGUID, "GROUP")
					self.sd:SetBackdropBorderColor(1, 0, 0)
				end
			end)
			button:SetScript("OnMouseUp", function(self, button)
				self.sd:SetBackdropBorderColor(0, 0, 0)
			end)
			
			table.insert(frame.macrobuttons.buttons, button)
		end
	end
	
	function frame:ShowMacroButton()
		if self.macrobuttons and JST_CDB["BossMod"][self.config_id]["macro_button_bool"] then
			self.macrobuttons:Show()
		end
	end
	
	function frame:HideMacroButton()
		if self.macrobuttons and JST_CDB["BossMod"][frame.config_id]["macro_button_bool"] then
			self.macrobuttons:Hide()
		end
	end
end
T.CreateMacroButton = CreateMacroButton

--------------------------------------------------------
------------  [首领模块]交互统计 整体排序  -------------
--------------------------------------------------------

T.InitMacroMods_ByMRT = function(frame)
	InitModsByMrt(frame)
	
	frame.last_exp = 0
	
	frame.msg_info = {
		{spellID = frame.config_id, msg = ""},
	}
	
	CreateMacroButton(frame)
	CreatePaIcon(frame)
	
	for i in pairs(frame.info) do
		if frame.element_type == "circle" then
			CreateMacroCircle(frame, i)
		else
			CreateMacroBar(frame, i)
		end
	end
	
	function frame:Prepare()
		self.count = self.count + 1
		
		if self.pre_update_auras then
			self:pre_update_auras()
		end
		
		-- 跳过这一轮
		if self.skip then return end
		
		self.last_exp = GetTime() + self.dur
		
		self.aura_num = 0
		self.graph_bg:Show()
		self:ShowPrivateAuraIcon()
		self:ShowMacroButton()
		
		if G.TestMod then
			C_Timer.After(.5, function()
				T.addon_msg("TargetMe"..","..G.PlayerGUID, "GROUP")
			end)
		end
		
		C_Timer.After(self.dur, function()
			self:RemoveAll()
		end)
	end
	
	function frame:Display()
		-- 第一轮排序：指定位置
		local custom_count_key
		if self.custom_assignment[self.count] then
			custom_count_key = self.count
		elseif self.custom_assignment["all"] then
			custom_count_key = "all"
		end
		if custom_count_key then
			for index, players in pairs(self.custom_assignment[custom_count_key]) do
				for _, GUID in pairs(players) do
					if self.backups[GUID] then
						local element = self.elements[index]
						if element.available then
							element:display(GUID, true)
							element:update()
							self:RemoveBackup(GUID)
							break
						end
					end
				end
			end
		end
		
		-- 第二轮排序：常规排序
		for _, GUID in pairs(self.assignment) do
			if self.backups[GUID] then
				local element = GetNextElementAvailable(self)
				if element then
					element:display(GUID)
					element:update()
					self:RemoveBackup(GUID)
				end
			end
		end
	end
	
	function frame:Remove(GUID)
		local element = self.actives[GUID]
		if element then
			element:remove()
			self:Display()
			self:UpdateBackupInfo()
		end
		self:RemoveBackup(GUID)
	end
	
	function frame:RemoveAll()
		self.graph_bg:Hide()
		for i, element in pairs(self.elements) do
			element:remove()
		end
		self:RemoveAllBackups()
		self:HidePrivateAuraIcon()
		self:HideMacroButton()
	end
	
	function frame:PreviewShow()
		self.graph_bg:Show()
		self:ShowMacroButton()
	end
	
	function frame:PreviewHide()
		self.graph_bg:Hide()
		self:HideMacroButton()
	end
end

T.UpdateMacroMods_ByMRT = function(frame, event, ...)
	if frame.cast_info[event] then
		local unit, _, spellID = ...
		if (G.TestMod and unit == "raid1" or string.find(unit, "boss")) and frame.cast_info[event][spellID] then
			frame:Prepare()
		end
	elseif event == "ADDON_MSG" then
		local channel, sender, message, GUID = ...
		if message == "TargetMe"..frame.msg_info[1].msg then				
			local info = T.GetGroupInfobyGUID(GUID)
			if T.IsInTable(frame.assignment, GUID) and frame.last_exp - GetTime() <= frame.dur and frame.last_exp - GetTime() > 0 and (not frame.filter or frame:filter(GUID)) then
				if not (frame.actives[GUID] or frame.backups[GUID]) then
					T.msg(string.format(L["收到点名讯息"], info.format_name, T.GetIconLink(frame.config_id)))
					frame:AddBackup(GUID)
					frame.aura_num = frame.aura_num + 1
					if frame.aura_num == GetTotalAuraNumber(frame) then
						frame:Display()
						if frame.post_update_auras then
							local total = T.GetTableNum(frame.actives)
							frame:post_update_auras(total)
						end
					end
					if G.PlayerGUID == GUID then
						frame:HidePrivateAuraIcon()
					end
				end
			end
		elseif message == "RemoveMe"..frame.msg_info[1].msg then
			local info = T.GetGroupInfobyGUID(GUID)
			T.msg(string.format(L["收到移除讯息"], info.format_name, T.GetIconLink(frame.config_id)))			
			frame:Remove(GUID)
		end
	elseif event == "ENCOUNTER_START" then
		frame.aura_num = 0
		frame.count = 0
		frame.last_exp = 0
		frame.difficultyID = select(3, ...)

		-- 获取分组数据	
		GetAssignmentByIndex(frame)
	end
end

T.ResetMacroMods_ByMRT = function(frame)
	if frame.raid_index then
		T.HideAllRFIndex()
	end
	frame:RemoveAll()
	frame:Hide()
end

--------------------------------------------------------
-------------  [首领模块]交互统计 逐个填坑  ------------
--------------------------------------------------------
T.InitMacroMods_ByTime = function(frame)
	InitModByTime(frame)
	
	frame.last_exp = 0

	frame.msg_info = {
		{spellID = frame.config_id, msg = ""},
	}
	
	CreateMacroButton(frame)
	CreatePaIcon(frame)

	for i in pairs(frame.info) do
		if frame.element_type == "circle" then
			CreateMacroCircle(frame, i)
		else
			CreateMacroBar(frame, i)
		end
	end
	
	function frame:Prepare()
		self.count = self.count + 1
		
		if self.pre_update_auras then
			self:pre_update_auras()
		end
		
		-- 跳过这一轮
		if self.skip then return end
		
		self.last_exp = GetTime() + self.dur
		
		self.graph_bg:Show()
		self:ShowPrivateAuraIcon()
		self:ShowMacroButton()
		
		if G.TestMod then
			C_Timer.After(.5, function()
				T.addon_msg("TargetMe"..","..G.PlayerGUID, "GROUP")
			end)
		end
		
		C_Timer.After(self.dur, function()
			self:RemoveAll()
		end)
	end
	
	function frame:Display(GUID)		
		if self.positive_assignment[GUID] then
			local element = GetNextElementAvailable(self)
			if element then
				element:display(GUID)
				element:update()
				self:RemoveBackup(GUID)
			end
		elseif self.reverse_assignment[GUID] then
			local element = GetNextElementAvailable(self, true)
			if element then
				element:display(GUID)
				element:update()
				self:RemoveBackup(GUID)
			end	
		end
	end
	
	function frame:Remove(GUID)
		local element = self.actives[GUID]
		if element then
			element:remove()
			for GUID in pairs(self.backups) do -- 从候补中补充
				self:Display(GUID)
			end
			self:UpdateBackupInfo()
		end
		self:RemoveBackup(GUID)
	end
	
	function frame:RemoveAll()
		self.graph_bg:Hide()
		for i, element in pairs(self.elements) do
			element:remove()
		end
		self:RemoveAllBackups()
		self:HidePrivateAuraIcon()
		self:HideMacroButton()
	end
	
	function frame:PreviewShow()
		self.graph_bg:Show()
		self:ShowMacroButton()
	end
	
	function frame:PreviewHide()
		self.graph_bg:Hide()
		self:HideMacroButton()
	end
end

T.UpdateMacroMods_ByTime = function(frame, event, ...)
	if frame.cast_info[event] then
		local unit, _, spellID = ...
		if (G.TestMod and unit == "raid1" or string.find(unit, "boss")) and frame.cast_info[event][spellID] then
			frame:Prepare()
		end
	elseif event == "ADDON_MSG" then
		local channel, sender, message, GUID = ...
		if message == "TargetMe"..frame.msg_info[1].msg then
			local info = T.GetGroupInfobyGUID(GUID)
			if (frame.positive_assignment[GUID] or frame.reverse_assignment[GUID]) and frame.last_exp - GetTime() <= frame.dur and frame.last_exp - GetTime() > 0 and (not frame.filter or frame:filter(GUID)) then
				if not (frame.actives[GUID] or frame.backups[GUID]) then
					T.msg(string.format(L["收到点名讯息"], info.format_name, T.GetIconLink(frame.config_id)))
					frame:AddBackup(GUID)
					frame:Display(GUID)
					if G.PlayerGUID == GUID then
						frame:HidePrivateAuraIcon()
					end
				end
			end
		elseif message == "RemoveMe"..frame.msg_info[1].msg then
			local info = T.GetGroupInfobyGUID(GUID)
			T.msg(string.format(L["收到移除讯息"], info.format_name, T.GetIconLink(frame.config_id)))
			frame:Remove(GUID)			
		end
	elseif event == "ENCOUNTER_START" then
		frame.count = 0
		frame.last_exp = 0
		
		-- 获取分组数据
		GetAssignmentByName(frame)
	end
end

T.ResetMacroMods_ByTime = function(frame)
	if frame.raid_index then
		T.HideAllRFIndex()
	end
	frame:RemoveAll()
	frame:Hide()
end

--------------------------------------------------------
----------  [首领模块]技能轮次安排模板  ----------------
--------------------------------------------------------
-- CLEU
-- event: COMBAT_LOG_EVENT_UNFILTERED

--		frame.sub_event = "SPELL_CAST_SUCCESS" -- 轮次锚点事件
--		frame.cast_id = 404732 -- 轮次刷新法术

-- 时间轴
-- event: COMBAT_LOG_EVENT_UNFILTERED
-- event: TIMELINE_PASSED
-- event: ENCOUNTER_PHASE

-- 自定义事件
-- event: JST_SPELL_ASSIGN

--		frame.tl_trigger = true -- 时间轴触发
--		frame.tl_tag = L["接圈"] -- 触发标记 默认法术名称

--		frame.custom_trigger = true -- 自定义事件触发

--		frame.encounter_start_init = true -- 战斗开始时初始化
--		frame.loop = false -- 循环使用人员安排
--		frame.assign_count = 4 -- mrt模板轮次 默认为4

--		frame.cast_dur = 5 -- 默认为5
--		frame.update_delay = 5 -- 刷新延迟，默认为5

--		frame.color = {.2, .4, 1} -- 颜色/团队框架动画颜色

--		frame.display_text = L["快去接圈"] -- 中间文字 默认 法术名称+快去
--		frame.show_dur_text = true -- 显示倒计时秒数

--		frame.sound = "sharedmg" -- 声音 默认 sound_boxing

--		frame.send_msg = "%name [%count]" -- 到我的轮次喊话
--		frame.send_msg_num = 5 -- 默认为5 喊话重复次数(每秒1次)
--		frame.send_msg_channel = "YELL" -- 默认为"SAY"

--		frame.raid_glow = "pixel" -- 团队框架动画

--		frame.update_id = 404732 -- 易伤光环 需要添加 frame:override_player_text(GUID, index)

--		frame:filter(count, GUID) -- 覆盖过滤
--		frame:override_action(count, index) -- 覆盖动作 中央文字、声音、喊话
--		frame:pre_update_count_up() -- 计数前刷新
--		frame:post_update_count_up() -- 计数后刷新
--		frame:start() -- 开始轮次计数
--		frame:stop() -- 停止轮次计数

local function GetPrefix(frame, ind)
	if frame.tl_trigger then
		return string.format('\n[%s%d]', frame.tl_tag, ind)
	else
		return string.format('\n[%d]', ind)
	end
end

local function GetTimelineMRT(frame, ind)
	return string.format('\n%d:00 [%s%d]', ind, frame.tl_tag, ind) -- 换行
end

local function Copy_Mrt_Spelllist(frame)
	local str, tlstr, raidlist, tllist = "", "", "", ""
	local loop_type = frame.loop and L["循环"] or L["不循环"]
	local count = frame.assign_count or 4
	
	for ind = 1, count do
		raidlist = raidlist..GetPrefix(frame, ind) -- 换行
		local i = 0
		for unit in T.IterateGroupMembers() do
			i = i + 1
			if i <= 3 then
				local name = UnitName(unit)
				raidlist = raidlist.." "..T.ColorNameForMrt(name)
			end
		end
		
		tllist = tllist..GetTimelineMRT(frame, ind)
	end
	
	str = string.format("#%sstart%s[%s]%s\nend\n", frame.config_id, frame.spell, loop_type, raidlist)
	tlstr = string.format("\n\n%s\n%s\nJST%s%s%s\n%s", L["加入时间轴"], T.GetEncounterName(frame.encounterID), frame.encounterID, L["时间轴"], tllist, L["战斗结束"])
	
	if frame.tl_trigger then
		return str..tlstr
	else
		return str
	end
end
T.Copy_Mrt_Spelllist = Copy_Mrt_Spelllist

local function GetSpellAssignment(frame)
	if C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1 then
		local tag = string.format("#%dstart", frame.config_id)
		local text = _G.VExRT.Note.Text1
		
		local betweenLine = false
		local tagmatched = false
		local count = 0
		
		for line in text:gmatch('[^\r\n]+') do
			if line == "end" then
				betweenLine = false
			end
			if betweenLine then
				count = count + 1
				frame.assignment[count] = {}
				local idx = 0
				for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
					local info = T.GetGroupInfobyName(name)
					if info then
						idx = idx + 1
						frame.assignment[count][idx] = info.GUID
					else
						T.msg(string.format(L["昵称错误"], name))
					end				
				end
				if frame.tl_trigger then
					frame.assignment_tag[count] = string.match(line, "%[[^|]+%]")
				end
			end
			if line:match(tag) then
				betweenLine = true
				tagmatched = true
			end
		end
		
		if not tagmatched then -- 完全没写
			T.msg(string.format(L["MRT数据全部未找到"], T.GetIconLink(frame.config_id), tag))
		end
	end
end

local function GetAssignNames(frame, count)
	local str = ""
	for index, GUID in pairs(frame.assignment[count]) do
		local name = ""
		if frame.override_player_text then
			name = frame:override_player_text(GUID, index)
		else
			name = T.ColorNickNameByGUID(GUID)
		end
		local unit = T.GetGroupInfobyGUID(GUID)["unit"]
		if UnitIsDeadOrGhost(unit) then
			name = "|cff969696[D]|r"..name
		end
		str = str.." "..name
	end
	return str
end

local function Update_AssignText(frame)
	local assign_count
	if frame.loop and #frame.assignment > 0 then
		assign_count = mod(frame.display_count-1, #frame.assignment)+1
	else
		assign_count = frame.display_count
	end
	if frame.assignment[assign_count] then
		frame.bar.left:SetText(string.format("[%d] %s", frame.display_count, GetAssignNames(frame, assign_count)))
	else
		frame.bar.left:SetText(string.format("[%d] %s", frame.display_count, L["无"]))
	end
end

local function Update_ExpTime(frame)
	if frame.tl_trigger then
		local tl_tag = frame.assignment_tag[frame.display_count]:gsub("%[", "%%["):gsub("%]", "%%]")
		for i, info in pairs(G.Timeline.assignment_cd) do
			if string.find(info.cd_str, tl_tag) then
				frame.bar.trigger_time = info.row_time
				break
			end
		end
		if frame.bar.trigger_time then
			frame.bar.exp_time = G.Timeline.start + frame.bar.trigger_time - G.Timeline.time_offset
			frame.bar.dur = frame.bar.exp_time - GetTime()
		end
	elseif frame.next_dur then
		frame.bar.exp_time = GetTime() + frame.next_dur
		frame.bar.dur = frame.next_dur
	end

	if frame.bar.dur and frame.bar.dur > 0 then			
		frame.bar:SetMinMaxValues(0, frame.bar.dur)
		frame.bar:SetScript("OnUpdate", function(self, e)
			self.t = self.t + e
			if self.t > self.update_rate then
				self.remain = self.exp_time - GetTime()
				if self.remain > 0 then
					self:SetValue(self.dur - self.remain)
					self.right:SetText(string.format("%d", self.remain))
				else
					self:SetScript("OnUpdate", nil)
					self:SetMinMaxValues(0, 1)
					self:SetValue(1)
					self.right:SetText("")
				end
				self.t = 0
			end
		end)
	else
		frame.bar:SetScript("OnUpdate", nil)
		frame.bar:SetMinMaxValues(0, 1)
		frame.bar:SetValue(1)
		frame.bar.right:SetText("")
	end
	
	frame.bar:Show()
end

local function SpellAction(frame, my_index)
	if frame.override_action then
		frame:override_action(frame.count, my_index)
	else
		-- 声音
		T.PlaySound(frame.sound or "sound_boxing")
		
		-- 文字
		T.Start_Text_Timer(frame.text_frame, frame.cast_dur or 5, gsub(frame.display_text, "%%count", frame.count), frame.show_dur_text)
	
		-- 喊话
		if frame.send_msg then
			local msg = frame.send_msg:gsub("%%name", G.PlayerName):gsub("%%count", frame.count)			
			local channel = frame.send_msg_channel or "SAY"
			T.SendChatMsg(msg, frame.send_msg_num or 5, channel)
		end
	end
end

local function CountUpSpell(frame)
	frame.count = frame.count + 1
		
	if frame.pre_update_count_up then
		frame:pre_update_count_up(frame.count)
	end
	
	LCG.PixelGlow_Start(frame.bar, frame.color, 12, .25, nil, 3, 0, 0, true, "spellbar"..frame.config_id)
	
	local assign_count
	if frame.loop and #frame.assignment > 0 then
		assign_count = mod(frame.count-1, #frame.assignment)+1
	else
		assign_count = frame.count
	end
	
	-- 检查这一轮有没有分配数据
	if frame.assignment[assign_count] then
		T.msg(string.format(L["MRT轮次分配"], T.GetIconLink(frame.config_id), frame.count, GetAssignNames(frame, assign_count)))
		
		for index, GUID in pairs(frame.assignment[assign_count]) do
			if frame.raid_glow and JST_CDB["BossMod"][frame.config_id]["raid_glow_bool"] then
				local unit_id = T.GetGroupInfobyGUID(GUID)["unit"]
				GlowRaidFramebyUnit_Show(frame.raid_glow, "debuff"..frame.config_id, unit_id, frame.color, frame.cast_dur or 5) -- 团队框架动画
			end
			
			-- 这轮有我
			if not frame.filter then
				if GUID == G.PlayerGUID then
					SpellAction(frame, index)
				end
			else
				if frame:filter(frame.count, GUID) then
					SpellAction(frame, index)
				end
			end
		end
	else
		T.msg(string.format(L["MRT该轮次数据未找到"], T.GetIconLink(frame.config_id), frame.count))
	end
	
	-- 检查下一轮有没有分配数据
	C_Timer.After(frame.update_delay or 5, function()
		LCG.PixelGlow_Stop(frame.bar, "spellbar"..frame.config_id)
		
		frame.display_count = frame.count + 1

		Update_AssignText(frame)
		Update_ExpTime(frame)		
	end)
	
	if frame.post_update_count_up then
		frame:post_update_count_up(frame.count)
	end
end

T.InitSpellBars = function(frame)
	frame.default_bar_width = frame.default_bar_width or 300
	frame.default_bar_height = 20	
	frame.spell, frame.icon = T.GetSpellInfo(frame.config_id)
	
	if not frame.tl_tag then
		frame.tl_tag = frame.spell
	end
	
	if not frame.color then
		frame.color = {.2, .4, 1}
	end
	
	if not frame.display_text then
		frame.display_text = frame.spell
	end
	
	function frame:copy_mrt()
		return Copy_Mrt_Spelllist(self)
	end

	T.GetSingleBarCustomData(frame)
	
	frame.assignment = {}
	frame.assignment_tag = {}
	frame.count = 0
	frame.display_count = 0
	
	frame.bar = CreateTimerBar(frame, frame.icon, false, false, true, nil, nil, frame.color)
	frame.bar:SetAllPoints(frame)
	
	frame.text_frame = T.CreateAlertText("bossmod"..frame.config_id, 2)

	function frame:start()
		self.count = 0 -- 刷新第一次	
		self.display_count = self.count + 1
		
		Update_AssignText(self)
		Update_ExpTime(self)
		self.bar:Show()
	end
	
	function frame:stop()
		LCG.PixelGlow_Stop(self.bar, "spellbar"..frame.config_id)
		self.bar:SetScript("OnUpdate", nil)
		self.bar:Hide()
		
		T.Stop_Text_Timer(self.text_frame)
	end
	
	function frame:PreviewShow()		
		self.bar:Show()
	end
	
	function frame:PreviewHide()
		self.bar:Hide()
	end
end

T.UpdateSpellBars = function(frame, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if sub_event == frame.sub_event and spellID == frame.cast_id then
			CountUpSpell(frame)
		elseif sub_event == "UNIT_DIED" or sub_event == "UNIT_RESURRECT" then
			Update_AssignText(frame)
		elseif string.find(sub_event, "SPELL_AURA") and spellID == frame.update_id then
			Update_AssignText(frame)
		end
	elseif frame.tl_trigger and event == "TIMELINE_PASSED" then
		local passed = ...
		if frame.bar.trigger_time and passed == frame.bar.trigger_time then
			CountUpSpell(frame)
		end
	elseif frame.custom_trigger and event == "JST_SPELL_ASSIGN" then
		local spellID = ...
		if spellID == frame.cast_id then
			CountUpSpell(frame)
		end
	elseif frame.tl_trigger and event == "ENCOUNTER_PHASE" then
		Update_ExpTime(frame)
	elseif event == "ENCOUNTER_START" then
		frame.assignment = table.wipe(frame.assignment)
		frame.assignment_tag = table.wipe(frame.assignment_tag)
		
		frame.count = 0
		frame.display_count = 1
		
		GetSpellAssignment(frame)
		
		if frame.encounter_start_init then
			C_Timer.After(1, function()
				frame:start()
			end)
		end
	end
end

T.ResetSpellBars = function(frame)
	if frame.raid_glow and JST_CDB["BossMod"][frame.config_id]["raid_glow_bool"] then
		GlowRaidFrame_HideAll(frame.raid_glow, "debuff"..frame.config_id)
	end
	frame:stop()	
	frame:Hide()
end

--------------------------------------------------------
---------------  [首领模块]计时条模板 ---------------
--------------------------------------------------------
-- event: COMBAT_LOG_EVENT_UNFILTERED

--		frame.spell_info = {
--			["SPELL_CAST_START"] = {
--				[404732] = {
--					dur = 10, -- 时间
--					wait_dur = 30, -- 等待时间
--					hide_icon = true, -- 隐藏图标
--					color = {1, 1, 0}, -- 默认黄色
--					reverse_fill = true, -- 反向
--					count = true, -- 计数
--					sound = "aoe", -- 开始声音
--					count_down = 3, -- 倒数
--					divide_info = {
--						dur = {4, 4.8, 5.6, 6.4}, -- 分段讯息
--						black_tag = true, -- 黑色分割线
--						time = true, -- 分段时间
--						sound = "sound_dd", -- 分段声音 "sound_dd"/"count"
--					},
--				},
--			},
--		}

--		function frame:filter(sub_event, spellID) -- 过滤条件
--		function frame:progress_update(sub_event, spellID, remain) -- 过程中伴随效果
--		function frame:post_update_show(sub_event, spellID) -- 出现时伴随效果
--		function frame.post_update_hide() -- 消失时伴随效果

local function InitTags(frame, info)
	for i = 1, frame.tag_num do
		local tag = frame.bar["tag"..i]
		
		if info.divide_info.black_tag then
			tag:SetVertexColor(0, 0, 0)
		else
			tag:SetVertexColor(1, 1, 1)
		end
		
		if i > #info.divide_info.dur then
			tag:Hide()
		else
			frame.bar.pointtag(i, info.divide_info.dur[i]/info.dur)
			tag:Show()
		end
		
		local timer = frame.bar["timer"..i]
		
		if info.divide_info.time and i == 1 then
			timer:Show()
		else
			timer:Hide()
		end
	end
end

local function UpdateCountDown(frame)
	local second = ceil(frame.remain)
	if frame.voi_countdown and second == frame.voi_countdown and second > 0 then -- 倒数频率1秒
		T.PlaySound("count\\"..second)
		frame.voi_countdown = frame.voi_countdown - 1
	end
end

local function ShowSpellCastBar(frame, sub_event, spellID)
	if not frame.bar:IsShown() then
		frame.bar:Show()
		if frame.spell_info[sub_event][spellID].sound then
			T.PlaySound(frame.spell_info[sub_event][spellID].sound)
		end
		if frame.post_update_show then
			frame:post_update_show(sub_event, spellID)
		end
	end
end

local function HideSpellCastBar(frame)
	if frame.bar:IsShown() then
		frame:stop_glow()
		frame.bar:Hide()
		if frame.post_update_hide then
			frame:post_update_hide()
		end
	end
end

local function UpdateDivInfo(frame, info)
	if info.divide_info.dur[frame.index] and frame.passed > info.divide_info.dur[frame.index] then
		if info.divide_info.sound then
			if info.divide_info.sound == "count" then
				T.PlaySound("count\\"..(frame.total + 1 - frame.index))
			else
				T.PlaySound(info.divide_info.sound)
			end
		end
			
		if info.divide_info.time then
			frame.bar["timer"..frame.index]:Hide()
			if frame.bar["timer"..frame.index+1] then
				frame.bar["timer"..frame.index+1]:Show()
			end
		end
		frame.index = frame.index + 1
	end
	
	if info.divide_info.time then
		for i = 1, frame.tag_num do
			timer = frame.bar["timer"..i]
			if timer:IsShown() then
				timer:SetText(T.FormatTime(frame.remain - (info.dur - info.divide_info.dur[i]), true))
			end
		end
	else
		frame.bar.right:SetText(T.FormatTime(frame.remain, true))
	end
end

local function StartSpellCastBar(frame, info, sub_event, spellID)	
	frame:SetScript("OnUpdate", function(self, e) 
		self.t = self.t + e
		if self.t > 0.02 then		
			self.remain = self.exp_time - GetTime()
			self.passed = info.dur - self.remain
			
			if self.remain > 0 then
				if self.remain <= info.dur then
					UpdateCountDown(self)
					ShowSpellCastBar(self, sub_event, spellID)
					
					self.bar:SetValue(info.reverse_fill and self.remain or self.passed)
					
					if info.divide_info then
						UpdateDivInfo(self, info)
					else
						frame.bar.right:SetText(T.FormatTime(frame.remain, true))
					end
					
					if self.progress_update then
						self:progress_update(sub_event, spellID, self.remain)
					end
				else
					HideSpellCastBar(self)
				end
			else
				self:SetScript("OnUpdate", nil)
				if info.divide_info then
					UpdateDivInfo(self, info)
				end
				HideSpellCastBar(self)				
			end
			self.t = 0
		end
	end)
end

local function Reset_Spell_Count(frame)
	for sub_event, data in pairs(frame.spell_counts) do
		for spell, count in pairs(data) do
			frame.spell_counts[sub_event][spell] = 0
		end
	end
end

T.InitSpellCastBar = function(frame)
	frame.default_bar_width = frame.default_bar_width or 300
	T.GetSingleBarCustomData(frame)
	
	frame.spell_counts = {}
	frame.count = 0
	frame.tag_num = 0
	frame.t = 0
	
	for sub_event, data in pairs(frame.spell_info) do
		frame.spell_counts[sub_event] = {}
		
		for spellID, info in pairs(data) do
			frame.spell_counts[sub_event][spellID] = 0
			
			info.icon = select(2, T.GetSpellInfo(spellID))			
			
			if not info.color then -- 默认颜色
				info.color = {0.19, 0.56, 0.9}
			end
			
			if info.divide_info then
				frame.tag_num = max(frame.tag_num, #info.divide_info.dur)
			end
		end
	end
	
	frame.bar = CreateTimerBar(frame, G.media.blank, false, true, true, nil, nil, nil, frame.tag_num)
	frame.bar:SetAllPoints(frame)
	
	for i = 1, frame.tag_num do
		frame.bar["timer"..i] = T.createtext(frame.bar, "OVERLAY", 12, "OUTLINE", "LEFT")
		frame.bar["timer"..i]:SetPoint("BOTTOM", frame.bar["tag"..i], "TOP", 0, 2)
	end
	
	function frame:start(sub_event, spellID)
		local info = self.spell_info[sub_event][spellID]
		
		self.count = self.count + 1
		
		self.bar:SetStatusBarColor(unpack(info.color))
		self.bar:SetMinMaxValues(0, info.dur)
		self.bar:SetReverseFill(info.reverse_fill or false)
		
		self.bar.icon:SetTexture(info.icon)
		self.bar.left:SetText(info.count and string.format("[%d]", self.count) or "")
		
		if info.hide_icon then
			self.bar.icon:Hide()
			self.bar.iconbd:Hide()
		else
			self.bar.icon:Show()
			self.bar.iconbd:Show()
		end
		
		if info.divide_info then
			InitTags(self, info)
			self.bar.right:SetShown(not info.divide_info.time)
			
			self.index = 1
			self.total = #info.divide_info.dur
		else
			self.bar.right:Show()
		end
		
		self.exp_time = GetTime() + (info.wait_dur or 0) + info.dur
		self.voi_countdown = info.count_down
	
		StartSpellCastBar(self, info, sub_event, spellID)
	end
	
	function frame:stop()
		self:SetScript("OnUpdate", nil)
		HideSpellCastBar(self)
	end
	
	function frame:start_glow()
		if not self.glowing then
			local num_line = floor(self.bar:GetWidth()/20)
			LCG.PixelGlow_Start(self.bar, self.glow_color, num_line, .15, 10, 3, 0, 0, nil, "castbar"..self.config_id)							
			self.glowing = true
		end
	end
	
	function frame:stop_glow()
		if self.glowing then
			LCG.PixelGlow_Stop(self.bar, "castbar"..self.config_id)
			self.glowing = false
		end
	end
	
	function frame:PreviewShow()
		for sub_event, data in pairs(self.spell_info) do
			for spellID, info in pairs(data) do
				self:start(sub_event, spellID)
				break
			end
		end
	end
	
	function frame:PreviewHide()
		self:stop()
	end
end

T.UpdateSpellCastBar = function(frame, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if frame.spell_info[sub_event] and frame.spell_info[sub_event][spellID] then
			frame.spell_counts[sub_event][spellID] = frame.spell_counts[sub_event][spellID] + 1
			if not frame.filter or frame:filter(sub_event, spellID) then
				frame:start(sub_event, spellID)
			end
		end
	elseif event == "ENCOUNTER_START" then
		frame.count = 0		
	end
end

T.ResetSpellCastBar = function(frame)
	Reset_Spell_Count(frame)
	frame:stop()
	frame:Hide()
end
