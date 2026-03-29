Matts1314DB = Matts1314DB or {
  x = 0,
  y = 0,
  onlyShowOnUseTrinkets = true,
  onlyShowInCombat = false,
  onlyShowWhenAvailable = false,
  glowWhenReady = true,
  bounceWhenReady = true,
  playSoundWhenReady = true,
  layout = "vertical",
  iconSize = 44,
  blacklistedTrinkets = {},
  _initialized = false,
}

if not Matts1314DB._initialized then
  Matts1314DB.blacklistedTrinkets = {}
  Matts1314DB._initialized = true
end

if Matts1314DB.iconSize == nil then
  Matts1314DB.iconSize = 44
end
if Matts1314DB.onlyShowOnUseTrinkets == nil then
  Matts1314DB.onlyShowOnUseTrinkets = true
end
if Matts1314DB.onlyShowInCombat == nil then
  Matts1314DB.onlyShowInCombat = false
end
if Matts1314DB.onlyShowWhenAvailable == nil then
  Matts1314DB.onlyShowWhenAvailable = false
end
if Matts1314DB.glowWhenReady == nil then
  Matts1314DB.glowWhenReady = true
end
if Matts1314DB.bounceWhenReady == nil then
  Matts1314DB.bounceWhenReady = true
end
if Matts1314DB.playSoundWhenReady == nil then
  Matts1314DB.playSoundWhenReady = true
end
if Matts1314DB.blacklistedTrinkets == nil then
  Matts1314DB.blacklistedTrinkets = {}
end
if Matts1314DB.minimap == nil then
  Matts1314DB.minimap = { hide = false }
end
if Matts1314DB.separateEditModeIcons == nil then
  Matts1314DB.separateEditModeIcons = false
end
if Matts1314DB.useCustomFont == nil then
  Matts1314DB.useCustomFont = true
end
if Matts1314DB.layout == nil then
  Matts1314DB.layout = "vertical"
end

local _, Matts1314 = ...

-- 13/14 tracker --

local container = CreateFrame("Frame", "Matts1314Container", UIParent)
container:SetSize(110, 110)
container:SetPoint("CENTER", UIParent, "CENTER", Matts1314DB.x, Matts1314DB.y)
container:SetClampedToScreen(true)
Matts1314.container = container

local trinket1 = CreateFrame("Frame", nil, UIParent)
trinket1:SetSize(Matts1314DB.iconSize, Matts1314DB.iconSize)
trinket1:SetPoint("TOP", container, "TOP", 0, 0)
trinket1.icon = trinket1:CreateTexture(nil, "ARTWORK")
trinket1.icon:SetAllPoints()
trinket1.cooldown = CreateFrame("Cooldown", nil, trinket1, "CooldownFrameTemplate")
trinket1.cooldown:SetAllPoints()
trinket1.cooldown:EnableMouse(false)
trinket1.editOutline = CreateFrame("Frame", nil, trinket1, BackdropTemplateMixin and "BackdropTemplate")
trinket1.editOutline:SetPoint("TOPLEFT", trinket1, "TOPLEFT", -2, 2)
trinket1.editOutline:SetPoint("BOTTOMRIGHT", trinket1, "BOTTOMRIGHT", 2, -2)
trinket1.editOutline:SetFrameLevel(trinket1:GetFrameLevel() + 5)
trinket1.editOutline:SetBackdrop({
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  edgeSize = 1,
  insets = { left = 0, right = 0, top = 0, bottom = 0 },
})
trinket1.editOutline:SetBackdropBorderColor(0.20, 1.00, 0.35, 0.98)
trinket1.editOutline:Hide()
Matts1314.trinket1 = trinket1

local trinket2 = CreateFrame("Frame", nil, UIParent)
trinket2:SetSize(Matts1314DB.iconSize, Matts1314DB.iconSize)
trinket2:SetPoint("TOP", trinket1, "BOTTOM", 0, 0)
trinket2.icon = trinket2:CreateTexture(nil, "ARTWORK")
trinket2.icon:SetAllPoints()
trinket2.cooldown = CreateFrame("Cooldown", nil, trinket2, "CooldownFrameTemplate")
trinket2.cooldown:SetAllPoints()
trinket2.cooldown:EnableMouse(false)
trinket2.editOutline = CreateFrame("Frame", nil, trinket2, BackdropTemplateMixin and "BackdropTemplate")
trinket2.editOutline:SetPoint("TOPLEFT", trinket2, "TOPLEFT", -2, 2)
trinket2.editOutline:SetPoint("BOTTOMRIGHT", trinket2, "BOTTOMRIGHT", 2, -2)
trinket2.editOutline:SetFrameLevel(trinket2:GetFrameLevel() + 5)
trinket2.editOutline:SetBackdrop({
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  edgeSize = 1,
  insets = { left = 0, right = 0, top = 0, bottom = 0 },
})
trinket2.editOutline:SetBackdropBorderColor(0.20, 1.00, 0.35, 0.98)
trinket2.editOutline:Hide()
Matts1314.trinket2 = trinket2

function Matts1314.ResetEditModeIconPositions()
  Matts1314DB.iconLayouts = nil
  UpdateLayout()
  UpdateTrinkets()
end

local function EnsureIconLayout(layoutName)
  local iconSize = Matts1314DB.iconSize or 44
  Matts1314DB.iconLayouts = Matts1314DB.iconLayouts or {}
  Matts1314DB.iconLayouts[layoutName] = Matts1314DB.iconLayouts[layoutName] or {
    slot13 = { point = "CENTER", x = 0, y = 0 },
    slot14 = { point = "CENTER", x = 0, y = -(iconSize + 5) },
  }
  return Matts1314DB.iconLayouts[layoutName]
end

local function SaveCenterPosition(frame)
  local centerX, centerY = frame:GetCenter()
  local parentX, parentY = UIParent:GetCenter()
  if not centerX or not centerY or not parentX or not parentY then
    return 0, 0
  end
  return centerX - parentX, centerY - parentY
end

local function ApplyCenterPosition(frame, x, y)
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", UIParent, "CENTER", x or 0, y or 0)
end

local function GetPrimaryGroupIcon()
  if Matts1314DB.layout == "horizontal" then
    return trinket2 -- left icon
  end
  return trinket1 -- top icon
end

local function ResolveMoveTarget(clickedFrame)
  local separate = Matts1314DB.separateEditModeIcons == true
  local inEditMode = Matts1314.editModeActive == true

  if not inEditMode then
    return nil
  end

  if separate then
    if clickedFrame == trinket1 or clickedFrame == trinket2 then
      return clickedFrame
    end
    if clickedFrame == container then
      return container
    end
    return nil
  end

  if clickedFrame == container or clickedFrame == trinket1 or clickedFrame == trinket2 then
    return container
  end
  return nil
end

local SaveContainerPosition
local SaveIconPosition

local function SaveMovedFrame(frame)
  if Matts1314DB.separateEditModeIcons then
    if frame == container then
      SaveContainerPosition()
    elseif frame == trinket1 or frame == trinket2 then
      SaveIconPosition(frame)
    end
    return
  end

  if frame == container or frame == trinket1 or frame == trinket2 then
    SaveContainerPosition()
  end
end

local activeDrag

local function StopLiveDrag()
  if not activeDrag then
    return
  end
  SaveMovedFrame(activeDrag.target)
  activeDrag = nil
end

local dragDriver = CreateFrame("Frame")
dragDriver:SetScript("OnUpdate", function()
  if not activeDrag then
    return
  end

  if not IsMouseButtonDown("LeftButton") then
    StopLiveDrag()
    return
  end

  local scale = UIParent:GetEffectiveScale()
  local cursorX, cursorY = GetCursorPosition()
  cursorX = cursorX / scale
  cursorY = cursorY / scale

  local newX = activeDrag.startX + (cursorX - activeDrag.cursorStartX)
  local newY = activeDrag.startY + (cursorY - activeDrag.cursorStartY)
  ApplyCenterPosition(activeDrag.target, newX, newY)
end)

local function InstallMoveHandlers(frame)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:SetClampedToScreen(true)

  frame:HookScript("OnMouseDown", function(self, button)
    if button ~= "LeftButton" or InCombatLockdown() then
      return
    end
    if activeDrag then
      return
    end

    local target = ResolveMoveTarget(self)
    if not target then
      return
    end

    local scale = UIParent:GetEffectiveScale()
    local cursorX, cursorY = GetCursorPosition()
    cursorX = cursorX / scale
    cursorY = cursorY / scale

    local startX, startY = SaveCenterPosition(target)
    activeDrag = {
      owner = self,
      target = target,
      startX = startX,
      startY = startY,
      cursorStartX = cursorX,
      cursorStartY = cursorY,
    }
  end)

  frame:HookScript("OnMouseUp", function(self, button)
    if button and button ~= "LeftButton" then
      return
    end
    if not activeDrag then
      return
    end
    if activeDrag.owner ~= self then
      return
    end
    StopLiveDrag()
  end)
end

local function RefreshMoveMouseRouting()
  local separate = Matts1314DB.separateEditModeIcons == true

  if separate then
    container:EnableMouse(true)
    trinket1:EnableMouse(true)
    trinket2:EnableMouse(true)
  else
    container:EnableMouse(true)
    trinket1:EnableMouse(true)
    trinket2:EnableMouse(true)
  end
end

SaveContainerPosition = function()
  local x, y = SaveCenterPosition(container)
  Matts1314DB.x = x
  Matts1314DB.y = y
  ApplyCenterPosition(container, x, y)
  UpdateLayout()
  UpdateTrinkets()
end

SaveIconPosition = function(frame)
  local layoutName = "default"
  local layout = EnsureIconLayout(layoutName)
  local key = (frame == trinket1) and "slot13" or "slot14"
  local x, y = SaveCenterPosition(frame)
  layout[key].point = "CENTER"
  layout[key].x = x
  layout[key].y = y
  ApplyCenterPosition(frame, x, y)
  UpdateTrinketLayout()
  UpdateTrinkets()
end

local editOverlay = CreateFrame("Frame", "Matts1314EditOverlay", UIParent, BackdropTemplateMixin and "BackdropTemplate")
editOverlay:SetSize(380, 208)
editOverlay:SetPoint("TOP", UIParent, "TOP", 0, -140)
editOverlay:SetFrameStrata("DIALOG")
editOverlay:SetFrameLevel(400)
editOverlay:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  tile = false,
  edgeSize = 1,
  insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
editOverlay:SetBackdropColor(0.03, 0.04, 0.03, 0.95)
editOverlay:SetBackdropBorderColor(0.30, 0.68, 0.47, 0.95)
editOverlay:Hide()

local editOverlayText = editOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
editOverlayText:SetPoint("TOP", 0, -14)
editOverlayText:SetText("Matts1314 Edit Mode")
editOverlayText:SetTextColor(0.36, 0.76, 0.54)

local editOverlayHint = editOverlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
editOverlayHint:SetPoint("TOP", editOverlayText, "BOTTOM", 0, -4)
editOverlayHint:SetWidth(340)
editOverlayHint:SetJustifyH("CENTER")
editOverlayHint:SetText("Drag enabled frames, then press Done.")
editOverlayHint:SetTextColor(0.78, 0.88, 0.80)

local editOutlineNote = editOverlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
editOutlineNote:SetPoint("TOP", editOverlayHint, "BOTTOM", 0, -2)
editOutlineNote:SetWidth(340)
editOutlineNote:SetJustifyH("CENTER")
editOutlineNote:SetText("Green outline = primary anchor icon.")
editOutlineNote:SetTextColor(0.40, 1.00, 0.55)

local editScaleLabel = editOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
editScaleLabel:SetPoint("TOPLEFT", editOverlay, "TOPLEFT", 20, -100)
editScaleLabel:SetTextColor(0.78, 0.88, 0.80)

local editScaleSlider = CreateFrame("Slider", "Matts1314EditScaleSlider", editOverlay, "OptionsSliderTemplate")
editScaleSlider:SetPoint("TOPLEFT", editScaleLabel, "BOTTOMLEFT", 0, -6)
editScaleSlider:SetWidth(340)
editScaleSlider:SetHeight(14)
editScaleSlider:SetMinMaxValues(20, 120)
editScaleSlider:SetValueStep(1)
editScaleSlider:SetObeyStepOnDrag(true)
_G["Matts1314EditScaleSliderLow"]:SetText("")
_G["Matts1314EditScaleSliderHigh"]:SetText("")
_G["Matts1314EditScaleSliderText"]:SetText("")

for _, region in ipairs({ editScaleSlider:GetRegions() }) do
  if region and region.IsObjectType and region:IsObjectType("Texture") then
    region:SetAlpha(0)
  end
end

local editScaleTrack = CreateFrame("Frame", nil, editScaleSlider, "BackdropTemplate")
editScaleTrack:SetPoint("LEFT", editScaleSlider, "LEFT", 0, 0)
editScaleTrack:SetPoint("RIGHT", editScaleSlider, "RIGHT", 0, 0)
editScaleTrack:SetHeight(4)
editScaleTrack:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  tile = false,
  edgeSize = 1,
  insets = { left = 0, right = 0, top = 0, bottom = 0 },
})
editScaleTrack:SetBackdropColor(0.08, 0.11, 0.09, 0.90)
editScaleTrack:SetBackdropBorderColor(0.30, 0.68, 0.47, 1)

editScaleSlider:SetThumbTexture("Interface\\Buttons\\WHITE8x8")
local editThumb = editScaleSlider:GetThumbTexture()
if editThumb then
  editThumb:SetSize(7, 14)
  editThumb:SetVertexColor(0.86, 0.93, 1.0, 1)
end

local editFlipCheck = CreateFrame("CheckButton", nil, editOverlay, "UICheckButtonTemplate")
editFlipCheck:SetPoint("BOTTOMLEFT", editOverlay, "BOTTOMLEFT", 18, 58)
editFlipCheck:SetScale(0.85)
editFlipCheck.text = editFlipCheck:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
editFlipCheck.text:SetPoint("LEFT", editFlipCheck, "RIGHT", 6, 0)
editFlipCheck.text:SetText("Flip Horizontal")
editFlipCheck.text:SetTextColor(0.90, 0.95, 1.00)

local function StyleEditFlatButton(btn)
  btn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
  })
  btn:SetBackdropColor(0.05, 0.07, 0.06, 0.95)
  btn:SetBackdropBorderColor(0.30, 0.68, 0.47, 0.95)
  btn:SetScript("OnEnter", function(self)
    self:SetBackdropColor(0.08, 0.13, 0.10, 0.98)
    self:SetBackdropBorderColor(0.36, 0.76, 0.54, 1.0)
  end)
  btn:SetScript("OnLeave", function(self)
    self:SetBackdropColor(0.05, 0.07, 0.06, 0.95)
    self:SetBackdropBorderColor(0.30, 0.68, 0.47, 0.95)
  end)
  btn:SetScript("OnMouseDown", function(self)
    self:SetBackdropColor(0.03, 0.05, 0.04, 1.0)
  end)
  btn:SetScript("OnMouseUp", function(self)
    self:SetBackdropColor(0.08, 0.13, 0.10, 0.98)
  end)
end

local editDoneButton = CreateFrame("Button", nil, editOverlay, "BackdropTemplate")
editDoneButton:SetSize(108, 26)
editDoneButton:SetPoint("BOTTOMRIGHT", -16, 16)
StyleEditFlatButton(editDoneButton)
editDoneButton.label = editDoneButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
editDoneButton.label:SetPoint("CENTER")
editDoneButton.label:SetText("Done")
editDoneButton.label:SetTextColor(0.90, 0.95, 1.00)

local editResetButton = CreateFrame("Button", nil, editOverlay, "BackdropTemplate")
editResetButton:SetSize(108, 26)
editResetButton:SetPoint("RIGHT", editDoneButton, "LEFT", -12, 0)
StyleEditFlatButton(editResetButton)
editResetButton.label = editResetButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
editResetButton.label:SetPoint("CENTER")
editResetButton.label:SetText("Reset")
editResetButton.label:SetTextColor(0.90, 0.95, 1.00)

Matts1314.editModeActive = false
Matts1314.editModeSourcePanel = nil

function Matts1314.IsCustomEditModeActive()
  return Matts1314.editModeActive == true
end

function Matts1314.ApplyEditModeSeparationLock()
  RefreshMoveMouseRouting()
  if not Matts1314.editModeActive then
    return
  end

  if Matts1314DB.separateEditModeIcons then
    editOverlayHint:SetText("Drag icon 13 or 14, then press Done.")
    editOutlineNote:SetText("Green outlines = movable icons.")
  else
    editOutlineNote:SetText("Green outline = primary anchor icon.")
    if Matts1314DB.layout == "horizontal" then
      editOverlayHint:SetText("Drag the LEFT icon to move the group, then press Done.")
    else
      editOverlayHint:SetText("Drag the TOP icon to move the group, then press Done.")
    end
  end
end

editScaleSlider:SetScript("OnValueChanged", function(_, value)
  value = math.floor(value + 0.5)
  Matts1314DB.iconSize = value
  editScaleLabel:SetText("Icon Scale: " .. value)
  UpdateSizes()
  UpdateLayout()
  UpdateTrinkets()
  if Matts1314.MSQ_Group then
    Matts1314.MSQ_Group:ReSkin()
  end
end)

editFlipCheck:SetScript("OnClick", function(self)
  Matts1314DB.layout = self:GetChecked() and "horizontal" or "vertical"
  UpdateLayout()
  UpdateTrinkets()
  Matts1314.ApplyEditModeSeparationLock()
end)

function Matts1314.ExitCustomEditMode()
  if not Matts1314.editModeActive then
    return
  end

  Matts1314.editModeActive = false
  editOverlay:Hide()
  if trinket1.editOutline then trinket1.editOutline:Hide() end
  if trinket2.editOutline then trinket2.editOutline:Hide() end
  RefreshMoveMouseRouting()

  UpdateLayout()
  UpdateTrinkets()

  if Matts1314.editModeSourcePanel and Matts1314.editModeSourcePanel.Show then
    Matts1314.editModeSourcePanel:Show()
  end
  Matts1314.editModeSourcePanel = nil
end

function Matts1314.EnterCustomEditMode(sourcePanel)
  if InCombatLockdown() then
    print("|cff9B77F7[Matts1314]|r Can't open Edit Mode during combat.")
    return
  end
  if Matts1314.editModeActive then
    return
  end

  EnsureIconLayout("default")
  Matts1314.editModeActive = true
  Matts1314.editModeSourcePanel = sourcePanel
  if sourcePanel and sourcePanel.Hide then
    sourcePanel:Hide()
  end

  editOverlay:Show()
  if trinket1.editOutline then trinket1.editOutline:Show() end
  if trinket2.editOutline then trinket2.editOutline:SetShown(Matts1314DB.separateEditModeIcons == true) end
  editScaleSlider:SetValue(Matts1314DB.iconSize or 44)
  editScaleLabel:SetText("Icon Scale: " .. (Matts1314DB.iconSize or 44))
  editFlipCheck:SetChecked((Matts1314DB.layout or "vertical") == "horizontal")
  UpdateTrinkets()
  Matts1314.ApplyEditModeSeparationLock()
end

editDoneButton:SetScript("OnClick", function()
  Matts1314.ExitCustomEditMode()
end)

editResetButton:SetScript("OnClick", function()
  if Matts1314DB.separateEditModeIcons then
    Matts1314.ResetEditModeIconPositions()
  else
    Matts1314DB.x = 0
    Matts1314DB.y = 0
    ApplyCenterPosition(container, 0, 0)
    UpdateLayout()
    UpdateTrinkets()
  end
end)
InstallMoveHandlers(container)
InstallMoveHandlers(trinket1)
InstallMoveHandlers(trinket2)
RefreshMoveMouseRouting()

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_LOGIN" then
    EnsureIconLayout("default")
    UpdateLayout()
    UpdateSizes()
    RefreshMoveMouseRouting()
    C_Timer.After(0.5, UpdateTrinkets)
  elseif event == "PLAYER_REGEN_DISABLED" and Matts1314.editModeActive then
    Matts1314.ExitCustomEditMode()
  end
  UpdateTrinkets()
end)

-- Added Masque Support --

local function GetMasqueData(button)
  return {
    Icon = button.icon,
    Cooldown = button.cooldown,
    Border = button.border,
    Count = button.count,
  }
end

local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)
if LDB and LDBIcon then
  Matts1314.LDB = LDB:NewDataObject("Matts1314", {
    type = "launcher",
    text = "Matts1314",
    icon = "Interface\\AddOns\\Matts1314\\Media\\MATT1314.png",
    OnClick = function(_, button)
      if button == "LeftButton" then
        if _G.Matts1314_ToggleOptions then
          _G.Matts1314_ToggleOptions()
        elseif SlashCmdList and SlashCmdList["MATTS1314"] then
          SlashCmdList["MATTS1314"]()
        end
      elseif button == "RightButton" then
        if _G.Matts1314_ToggleOptions then
          _G.Matts1314_ToggleOptions()
        end
      end
    end,
    OnTooltipShow = function(tooltip)
      tooltip:AddLine("Matts1314")
      tooltip:AddLine("Left-click: Toggle options", 1, 1, 1)
      tooltip:AddLine("Right-click: Toggle options", 1, 1, 1)
    end,
  })

  LDBIcon:Register("Matts1314", Matts1314.LDB, Matts1314DB.minimap)
end

local Masque = LibStub("Masque", true)
if Masque then
  Matts1314.MSQ_Group = Masque:Group("Matts1314")
  Matts1314.MSQ_Group:AddButton(trinket1, GetMasqueData(trinket1))
  Matts1314.MSQ_Group:AddButton(trinket2, GetMasqueData(trinket2))
  Matts1314.MSQ_Group:RegisterCallback(function()
    local size = Matts1314DB.iconSize
    if size then
      trinket1:SetSize(size, size)
      trinket2:SetSize(size, size)
    end
  end)
end

C_Timer.After(1, function()
  print("|cff00d9ffMatts1314 loaded!|r|cffFFFFFF Type /m1314 for options|r")
end)
