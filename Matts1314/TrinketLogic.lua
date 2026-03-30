local CustomGlow = LibStub("LibCustomGlow-1.0", true)
local LibAnimate = LibStub("LibAnimate", true)
local _, Matts1314 = ...
local READY_GLOW_KEY = "MATTS1314_READY_GLOW"
local EDIT_GLOW_KEY = "MATTS1314_EDIT_GLOW"
local READY_SOUND_PATH = "Interface\\AddOns\\Matts1314\\Media\\t.mp3"
local PREVIEW_ICON_PATH = "Interface\\Icons\\INV_Misc_QuestionMark"
local READY_BOUNCE_AMPLITUDE = 7
local READY_BOUNCE_FREQUENCY = 2.25

local function IsEditModeActive()
  if Matts1314 and Matts1314.IsCustomEditModeActive and Matts1314.IsCustomEditModeActive() then
    return true
  end
  return false
end

local function ApplyEditModePreviewPositions()
  local size = Matts1314DB.iconSize or 44
  if Matts1314DB.separateEditModeIcons then
    local layoutName = Matts1314.activeLayoutName or "default"
    Matts1314DB.iconLayouts = Matts1314DB.iconLayouts or {}
    Matts1314DB.iconLayouts[layoutName] = Matts1314DB.iconLayouts[layoutName] or {
      slot13 = { point = "CENTER", x = 0, y = 0 },
      slot14 = { point = "CENTER", x = 0, y = -(size + 5) },
    }

    local slot13 = Matts1314DB.iconLayouts[layoutName].slot13 or { point = "CENTER", x = 0, y = 0 }
    local slot14 = Matts1314DB.iconLayouts[layoutName].slot14 or { point = "CENTER", x = 0, y = -(size + 5) }

    local p13, x13, y13 = slot13.point or "CENTER", slot13.x or 0, slot13.y or 0
    local p14, x14, y14 = slot14.point or "CENTER", slot14.x or 0, slot14.y or -(size + 5)

    -- Guard against accidental overlap so both icons are always visible in Edit Mode.
    if p13 == p14 and math.abs(x13 - x14) < 2 and math.abs(y13 - y14) < 2 then
      y14 = y13 - (size + 5)
    end

    Matts1314.trinket1:ClearAllPoints()
    Matts1314.trinket1:SetPoint(p13, UIParent, p13, x13, y13)
    Matts1314.trinket2:ClearAllPoints()
    Matts1314.trinket2:SetPoint(p14, UIParent, p14, x14, y14)
  else
    if Matts1314DB.layout == "horizontal" then
      Matts1314.trinket1:ClearAllPoints()
      Matts1314.trinket1:SetPoint("LEFT", Matts1314.container, "LEFT", 5, 0)
      Matts1314.trinket2:ClearAllPoints()
      Matts1314.trinket2:SetPoint("LEFT", Matts1314.trinket1, "RIGHT", 5, 0)
    else
      Matts1314.trinket1:ClearAllPoints()
      Matts1314.trinket1:SetPoint("TOP", Matts1314.container, "TOP", 0, -5)
      Matts1314.trinket2:ClearAllPoints()
      Matts1314.trinket2:SetPoint("TOP", Matts1314.trinket1, "BOTTOM", 0, -5)
    end
  end
end

local function CaptureBounceAnchor(frame)
  local centerX, centerY = frame:GetCenter()
  local parentX, parentY = UIParent:GetCenter()
  if not centerX or not centerY or not parentX or not parentY then
    return false
  end

  frame.m1314BounceAnchor = {
    point = "CENTER",
    relativeTo = UIParent,
    relativePoint = "CENTER",
    xOfs = centerX - parentX,
    yOfs = centerY - parentY,
  }
  return true
end

local function ApplyBounceOffset(frame, yOffset)
  if not frame.m1314BounceAnchor and not CaptureBounceAnchor(frame) then
    return
  end

  local anchor = frame.m1314BounceAnchor
  frame:ClearAllPoints()
  frame:SetPoint(
    anchor.point,
    anchor.relativeTo,
    anchor.relativePoint,
    anchor.xOfs,
    anchor.yOfs + yOffset
  )
end

local function StopReadyBounce(frame)
  if not frame then
    return
  end

  frame.m1314ReadyBounceActive = false

  if LibAnimate and LibAnimate.IsAnimating and LibAnimate:IsAnimating(frame) then
    LibAnimate:Stop(frame)
  end

  if frame.m1314BounceDriver then
    frame.m1314BounceDriver:SetScript("OnUpdate", nil)
    frame.m1314BounceDriver:Hide()
  end

  if frame.m1314BounceAnchor then
    local anchor = frame.m1314BounceAnchor
    frame:ClearAllPoints()
    frame:SetPoint(
      anchor.point,
      anchor.relativeTo,
      anchor.relativePoint,
      anchor.xOfs,
      anchor.yOfs
    )
  end
  frame.m1314BounceAnchor = nil

  if frame and frame.icon then
    frame.icon:SetScale(1)
  end
end

local function PlayReadyBounce(frame)
  if not frame then
    return
  end

  if frame.m1314ReadyBounceActive then
    return
  end
  frame.m1314ReadyBounceActive = true

  if not frame.m1314BounceAnchor and not CaptureBounceAnchor(frame) then
    frame.m1314ReadyBounceActive = false
    return
  end

  frame.m1314BounceTime = 0

  if not frame.m1314BounceDriver then
    frame.m1314BounceDriver = CreateFrame("Frame")
  end

  frame.m1314BounceDriver:SetScript("OnUpdate", function(_, elapsed)
    if not frame or not frame.m1314ReadyBounceActive or not frame:IsShown() then
      return
    end

    frame.m1314BounceTime = (frame.m1314BounceTime or 0) + elapsed
    local radians = frame.m1314BounceTime * READY_BOUNCE_FREQUENCY * (math.pi * 2)
    local yOffset = math.sin(radians) * READY_BOUNCE_AMPLITUDE
    ApplyBounceOffset(frame, yOffset)
  end)
  frame.m1314BounceDriver:Show()
end

local function CancelCooldownRefresh(frame)
  if frame.m1314CooldownTimer then
    frame.m1314CooldownTimer:Cancel()
    frame.m1314CooldownTimer = nil
  end
end

local function ScheduleCooldownRefresh(frame, start, duration)
  CancelCooldownRefresh(frame)
  local remaining = (start + duration) - GetTime()
  if remaining and remaining > 0 then
    frame.m1314CooldownTimer = C_Timer.NewTimer(remaining + 0.05, function()
      frame.m1314CooldownTimer = nil
      UpdateTrinkets()
    end)
  end
end

local function SetReadyGlow(frame, shouldGlow)
  if not CustomGlow then
    return
  end

  if shouldGlow then
    if not frame.m1314ReadyGlowActive then
      CustomGlow.PixelGlow_Start(frame, {0.00, 0.85, 1.00, 1.00}, 8, 0.25, nil, 2, 0, 0, true, READY_GLOW_KEY)
      frame.m1314ReadyGlowActive = true
    end
  elseif frame.m1314ReadyGlowActive then
    CustomGlow.PixelGlow_Stop(frame, READY_GLOW_KEY)
    frame.m1314ReadyGlowActive = false
  end
end

local function SetEditModeGlow(frame, shouldGlow)
  if frame and frame.editOutline then
    frame.editOutline:SetShown(shouldGlow == true)
  end

  if not CustomGlow then
    return
  end

  if shouldGlow then
    if not frame.m1314EditGlowActive then
      CustomGlow.PixelGlow_Start(frame, {0.20, 1.00, 0.35, 0.95}, 8, 0.20, nil, 2, 0, 0, true, EDIT_GLOW_KEY)
      frame.m1314EditGlowActive = true
    end
  elseif frame.m1314EditGlowActive then
    CustomGlow.PixelGlow_Stop(frame, EDIT_GLOW_KEY)
    frame.m1314EditGlowActive = false
  end
end

local function HideTrinketFrame(frame, preserveCooldownState, preserveRefreshTimer)
  if not preserveRefreshTimer then
    CancelCooldownRefresh(frame)
  end
  SetReadyGlow(frame, false)
  SetEditModeGlow(frame, false)
  if not preserveCooldownState then
    frame.m1314PrevOnCooldown = false
  end
  StopReadyBounce(frame)
  if frame.icon then
    frame.icon:SetDesaturated(false)
    frame.icon:SetVertexColor(1, 1, 1, 1)
  end
  frame:SetAlpha(1)
  frame:Hide()
end

function IsOnUseTrinket(slotID)
  local itemID = GetInventoryItemID("player", slotID)
  if not itemID then return false end

  for _, blacklistedID in ipairs(Matts1314DB.blacklistedTrinkets) do
    if itemID == blacklistedID then
      return false
    end
  end

  local spellName, spellID = GetItemSpell(itemID)
  if spellName then
    return true
  end

  return false
end

function UpdateTrinket(frame, slotID)
  SetEditModeGlow(frame, false)
  local itemTexture = GetInventoryItemTexture("player", slotID)
  if itemTexture then
    local itemID = GetInventoryItemID("player", slotID)
    if itemID then
      for _, blacklistedID in ipairs(Matts1314DB.blacklistedTrinkets) do
        if itemID == blacklistedID then
          HideTrinketFrame(frame)
          return
        end
      end
    end

    if Matts1314DB.onlyShowOnUseTrinkets then
      if not IsOnUseTrinket(slotID) then
        HideTrinketFrame(frame)
        return
      end
    end

    if Matts1314DB.onlyShowInCombat and not UnitAffectingCombat("player") then
      HideTrinketFrame(frame)
      return
    end

    local start, duration, enable = GetInventoryItemCooldown("player", slotID)
    local onCooldown = (enable == 1) and (start and duration and start > 0 and duration > 1.5)
    local wasOnCooldown = frame.m1314PrevOnCooldown == true
    if Matts1314DB.onlyShowWhenAvailable then
      if onCooldown then
        ScheduleCooldownRefresh(frame, start, duration)
        frame.m1314PrevOnCooldown = true
        HideTrinketFrame(frame, true, true)
        return
      end
    end

    frame.icon:SetTexture(itemTexture)

    if start and duration then
      frame.cooldown:SetCooldown(start, duration)
    end

    if onCooldown then
      ScheduleCooldownRefresh(frame, start, duration)
      frame.icon:SetDesaturated(true)
      frame.icon:SetVertexColor(1, 1, 1, 1)
      frame:SetAlpha(0.5)
      StopReadyBounce(frame)
      frame.m1314PrevOnCooldown = true
    else
      CancelCooldownRefresh(frame)
      frame.icon:SetDesaturated(false)
      frame.icon:SetVertexColor(1, 1, 1, 1)
      frame:SetAlpha(1)
      if not Matts1314DB.bounceWhenReady then
        StopReadyBounce(frame)
      end
      local becameReady = wasOnCooldown
      frame.m1314PrevOnCooldown = false

      SetReadyGlow(frame, Matts1314DB.glowWhenReady and not onCooldown)
      frame:Show()

      if becameReady and Matts1314DB.playSoundWhenReady ~= false then
        PlaySoundFile(READY_SOUND_PATH, "Master")
      end
      if Matts1314DB.bounceWhenReady then
        PlayReadyBounce(frame)
      else
        StopReadyBounce(frame)
      end
      return
    end

    SetReadyGlow(frame, Matts1314DB.glowWhenReady and not onCooldown)
    frame:Show()
  else
    HideTrinketFrame(frame)
  end
end

function UpdateTrinkets()
  if IsEditModeActive() then
    Matts1314.container:Show()

    local t1Texture = GetInventoryItemTexture("player", 13) or PREVIEW_ICON_PATH
    local t2Texture = GetInventoryItemTexture("player", 14) or PREVIEW_ICON_PATH

    Matts1314.trinket1.icon:SetTexture(t1Texture)
    Matts1314.trinket2.icon:SetTexture(t2Texture)
    Matts1314.trinket1.icon:SetDesaturated(false)
    Matts1314.trinket2.icon:SetDesaturated(false)
    Matts1314.trinket1.icon:SetVertexColor(1, 1, 1, 1)
    Matts1314.trinket2.icon:SetVertexColor(1, 1, 1, 1)
    Matts1314.trinket1:SetAlpha(1)
    Matts1314.trinket2:SetAlpha(1)
    Matts1314.trinket1:Show()
    Matts1314.trinket2:Show()

    CancelCooldownRefresh(Matts1314.trinket1)
    CancelCooldownRefresh(Matts1314.trinket2)
    SetReadyGlow(Matts1314.trinket1, false)
    SetReadyGlow(Matts1314.trinket2, false)
    local separateIcons = Matts1314DB.separateEditModeIcons == true
    SetEditModeGlow(Matts1314.trinket1, true)
    SetEditModeGlow(Matts1314.trinket2, separateIcons)
    StopReadyBounce(Matts1314.trinket1)
    StopReadyBounce(Matts1314.trinket2)

    if Matts1314.trinket1.cooldown then
      Matts1314.trinket1.cooldown:SetCooldown(0, 0)
    end
    if Matts1314.trinket2.cooldown then
      Matts1314.trinket2.cooldown:SetCooldown(0, 0)
    end

    ApplyEditModePreviewPositions()
    return
  end

  UpdateTrinket(Matts1314.trinket1, 13)
  UpdateTrinket(Matts1314.trinket2, 14)
  UpdateTrinketLayout()
end

function UpdateSizes()
  local size = Matts1314DB.iconSize
  Matts1314.trinket1:SetSize(size, size)
  Matts1314.trinket2:SetSize(size, size)
end


function UpdateTrinketLayout()
  if Matts1314DB.separateEditModeIcons then
    local layoutName = Matts1314.activeLayoutName or "default"
    Matts1314DB.iconLayouts = Matts1314DB.iconLayouts or {}
    Matts1314DB.iconLayouts[layoutName] = Matts1314DB.iconLayouts[layoutName] or {
      slot13 = { point = "CENTER", x = 0, y = 0 },
      slot14 = { point = "CENTER", x = 0, y = -49 },
    }

    local slot13 = Matts1314DB.iconLayouts[layoutName].slot13 or { point = "CENTER", x = 0, y = 0 }
    local slot14 = Matts1314DB.iconLayouts[layoutName].slot14 or { point = "CENTER", x = 0, y = -49 }

    if Matts1314.trinket1:IsShown() then
      Matts1314.trinket1:ClearAllPoints()
      Matts1314.trinket1:SetPoint(slot13.point or "CENTER", UIParent, slot13.point or "CENTER", slot13.x or 0, slot13.y or 0)
    end

    if Matts1314.trinket2:IsShown() then
      Matts1314.trinket2:ClearAllPoints()
      Matts1314.trinket2:SetPoint(slot14.point or "CENTER", UIParent, slot14.point or "CENTER", slot14.x or 0, slot14.y or -49)
    end
    return
  end

  local visible1 = Matts1314.trinket1:IsShown()
  local visible2 = Matts1314.trinket2:IsShown()

  if visible1 and not visible2 then
    Matts1314.trinket1:ClearAllPoints()
    if Matts1314DB.layout == "horizontal" then
      Matts1314.trinket1:SetPoint("LEFT", Matts1314.container, "LEFT", 5, 0)
    else
      Matts1314.trinket1:SetPoint("TOP", Matts1314.container, "TOP", 0, -5)
    end
  elseif visible2 and not visible1 then
    Matts1314.trinket2:ClearAllPoints()
    if Matts1314DB.layout == "horizontal" then
      Matts1314.trinket2:SetPoint("LEFT", Matts1314.container, "LEFT", 5, 0)
    else
      Matts1314.trinket2:SetPoint("TOP", Matts1314.container, "TOP", 0, -5)
    end
  elseif visible1 and visible2 then
    if Matts1314DB.layout == "vertical" then
      Matts1314.trinket1:ClearAllPoints()
      Matts1314.trinket1:SetPoint("TOP", Matts1314.container, "TOP", 0, -5)
      Matts1314.trinket2:ClearAllPoints()
      Matts1314.trinket2:SetPoint("TOP", Matts1314.trinket1, "BOTTOM", 0, -5)
    else
      Matts1314.trinket1:ClearAllPoints()
      Matts1314.trinket1:SetPoint("LEFT", Matts1314.container, "LEFT", 5, 0)
      Matts1314.trinket2:ClearAllPoints()
      Matts1314.trinket2:SetPoint("LEFT", Matts1314.trinket1, "RIGHT", 5, 0)
    end
  end
end

function UpdateLayout()
  if Matts1314DB.separateEditModeIcons then
    UpdateSizes()
    UpdateTrinketLayout()
    return
  end

  if Matts1314DB.layout == "vertical" then
    Matts1314.trinket1:ClearAllPoints()
    Matts1314.trinket1:SetPoint("TOP", Matts1314.container, "TOP", 0, -5)
    Matts1314.trinket2:ClearAllPoints()
    Matts1314.trinket2:SetPoint("TOP", Matts1314.trinket1, "BOTTOM", 0, -5)
  else
    Matts1314.trinket1:ClearAllPoints()
    Matts1314.trinket1:SetPoint("LEFT", Matts1314.container, "LEFT", 5, 0)
    Matts1314.trinket2:ClearAllPoints()
    Matts1314.trinket2:SetPoint("LEFT", Matts1314.trinket1, "RIGHT", 5, 0)
  end
  UpdateSizes()
  UpdateTrinketLayout()
end


