local _, Matts1314 = ...

local FONT_PATH = "Interface\\AddOns\\Matts1314\\Fonts\\Naowh.ttf"
local fontRegistry = {}

local function UseNaowhFont()
  return Matts1314DB and Matts1314DB.useCustomFont ~= false
end

local function SetManagedFont(fontString, size, flags)
  if not fontString or not fontString.SetFont then
    return
  end
  local fontPath = UseNaowhFont() and FONT_PATH or STANDARD_TEXT_FONT
  if not fontString:SetFont(fontPath, size or 14, flags or "") then
    local _, oldSize, oldFlags = fontString:GetFont()
    fontString:SetFont(STANDARD_TEXT_FONT, size or oldSize or 14, flags or oldFlags or "")
  end
end

local function ApplyFont(fontString, size, flags)
  if not fontString or not fontString.SetFont then
    return
  end
  fontRegistry[fontString] = {
    size = size or 14,
    flags = flags or "",
  }
  SetManagedFont(fontString, size, flags)
end

local function RefreshFonts()
  for fontString, info in pairs(fontRegistry) do
    SetManagedFont(fontString, info.size, info.flags)
  end
end

local function StyleFlatButton(btn)
  btn._isActive = false
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
    if self._isActive then
      self:SetBackdropColor(0.10, 0.16, 0.12, 0.98)
      self:SetBackdropBorderColor(0.42, 0.82, 0.59, 1.0)
    else
      self:SetBackdropColor(0.08, 0.13, 0.10, 0.98)
      self:SetBackdropBorderColor(0.36, 0.76, 0.54, 1.0)
    end
  end)
  btn:SetScript("OnLeave", function(self)
    if self._isActive then
      self:SetBackdropColor(0.09, 0.15, 0.11, 0.98)
      self:SetBackdropBorderColor(0.40, 0.80, 0.57, 1.0)
    else
      self:SetBackdropColor(0.05, 0.07, 0.06, 0.95)
      self:SetBackdropBorderColor(0.30, 0.68, 0.47, 0.95)
    end
  end)
end

local panel = CreateFrame("Frame", "Matts1314Options", UIParent, BackdropTemplateMixin and "BackdropTemplate")
panel:SetSize(520, 560)
panel:SetPoint("CENTER")
panel:SetScale(0.72)
panel:SetFrameStrata("DIALOG")
panel:SetFrameLevel(200)
panel:SetToplevel(true)
panel:SetMovable(true)
panel:EnableMouse(true)
panel:RegisterForDrag("LeftButton")
panel:SetClampedToScreen(true)
panel:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  tile = false, edgeSize = 1,
  insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
panel:SetBackdropColor(0.03, 0.04, 0.03, 0.95)
panel:SetBackdropBorderColor(0.30, 0.68, 0.47, 0.90)
panel:Hide()

_G.Matts1314_ToggleOptions = function()
  panel:SetShown(not panel:IsShown())
end

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -14)
title:SetText("Matt's 13/14")
ApplyFont(title, 18, "")
title:SetTextColor(0.36, 0.76, 0.54)

local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
subtitle:SetPoint("TOP", title, "BOTTOM", 0, -6)
subtitle:SetText("Configuration")
ApplyFont(subtitle, 14, "")
subtitle:SetTextColor(0.78, 0.88, 0.80)

local description = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
description:SetPoint("TOP", subtitle, "BOTTOM", 0, -8)
description:SetWidth(460)
description:SetJustifyH("CENTER")
description:SetText("Trinket cooldown tracking, ready effects, and blacklist controls.")
ApplyFont(description, 12, "")
description:SetTextColor(0.68, 0.80, 0.71)

local closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -5, -5)

panel:SetScript("OnDragStart", panel.StartMoving)
panel:SetScript("OnDragStop", panel.StopMovingOrSizing)

local tabBar = CreateFrame("Frame", nil, panel)
tabBar:SetPoint("TOP", panel, "TOP", 0, -102)
tabBar:SetSize(352, 24)

local generalTab = CreateFrame("Button", nil, tabBar, "BackdropTemplate")
generalTab:SetPoint("LEFT", tabBar, "LEFT", 0, 0)
generalTab:SetSize(82, 22)
StyleFlatButton(generalTab)
generalTab.label = generalTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
generalTab.label:SetPoint("CENTER")
generalTab.label:SetText("General")
generalTab.label:SetWidth(78)
ApplyFont(generalTab.label, 13, "")
generalTab.label:SetTextColor(0.90, 0.95, 1.00)

local displayTab = CreateFrame("Button", nil, tabBar, "BackdropTemplate")
displayTab:SetPoint("LEFT", generalTab, "RIGHT", 8, 0)
displayTab:SetSize(82, 22)
StyleFlatButton(displayTab)
displayTab.label = displayTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
displayTab.label:SetPoint("CENTER")
displayTab.label:SetText("Display")
displayTab.label:SetWidth(78)
ApplyFont(displayTab.label, 13, "")
displayTab.label:SetTextColor(0.90, 0.95, 1.00)

local blacklistTab = CreateFrame("Button", nil, tabBar, "BackdropTemplate")
blacklistTab:SetPoint("LEFT", displayTab, "RIGHT", 8, 0)
blacklistTab:SetSize(82, 22)
StyleFlatButton(blacklistTab)
blacklistTab.label = blacklistTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
blacklistTab.label:SetPoint("CENTER")
blacklistTab.label:SetText("Blacklist")
blacklistTab.label:SetWidth(78)
ApplyFont(blacklistTab.label, 13, "")
blacklistTab.label:SetTextColor(0.90, 0.95, 1.00)

local editModeTab = CreateFrame("Button", nil, tabBar, "BackdropTemplate")
editModeTab:SetPoint("LEFT", blacklistTab, "RIGHT", 8, 0)
editModeTab:SetSize(82, 22)
StyleFlatButton(editModeTab)
editModeTab.label = editModeTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
editModeTab.label:SetPoint("CENTER")
editModeTab.label:SetText("Edit Mode")
editModeTab.label:SetWidth(78)
ApplyFont(editModeTab.label, 13, "")
editModeTab.label:SetTextColor(0.90, 0.95, 1.00)

local content = CreateFrame("Frame", nil, panel)
content:SetPoint("TOPLEFT", panel, "TOPLEFT", 24, -166)
content:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -24, 24)

local tabsDivider = CreateFrame("Frame", nil, panel, "BackdropTemplate")
tabsDivider:SetPoint("TOPLEFT", panel, "TOPLEFT", 24, -134)
tabsDivider:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -24, -134)
tabsDivider:SetHeight(1)
tabsDivider:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  tile = false,
  edgeSize = 1,
  insets = { left = 0, right = 0, top = 0, bottom = 0 },
})
tabsDivider:SetBackdropColor(0.24, 0.33, 0.46, 0.55)
tabsDivider:SetBackdropBorderColor(0.24, 0.33, 0.46, 0.0)

local generalPage = CreateFrame("Frame", nil, content)
generalPage:SetAllPoints(content)

local displayPage = CreateFrame("Frame", nil, content)
displayPage:SetAllPoints(content)
displayPage:Hide()

local blacklistPage = CreateFrame("Frame", nil, content)
blacklistPage:SetAllPoints(content)
blacklistPage:Hide()

local TAB_COLORS = {
  activeBg = { 0.14, 0.24, 0.18, 1.0 },
  activeBorder = { 0.58, 0.98, 0.73, 1.0 },
  activeText = { 0.96, 1.00, 0.97, 1.0 },
  activeHoverBg = { 0.17, 0.28, 0.21, 1.0 },
  activeHoverBorder = { 0.68, 1.00, 0.80, 1.0 },
  inactiveBg = { 0.03, 0.05, 0.04, 0.95 },
  inactiveBorder = { 0.20, 0.45, 0.32, 0.95 },
  inactiveText = { 0.56, 0.68, 0.60, 1.0 },
  inactiveHoverBg = { 0.06, 0.09, 0.07, 0.98 },
  inactiveHoverBorder = { 0.30, 0.62, 0.46, 1.0 },
}

local function ApplyTabVisual(tab)
  local isActive = tab._isActive == true
  local isHover = tab._isHovered == true

  if isActive then
    if isHover then
      tab:SetBackdropColor(unpack(TAB_COLORS.activeHoverBg))
      tab:SetBackdropBorderColor(unpack(TAB_COLORS.activeHoverBorder))
    else
      tab:SetBackdropColor(unpack(TAB_COLORS.activeBg))
      tab:SetBackdropBorderColor(unpack(TAB_COLORS.activeBorder))
    end
    if tab.label then
      tab.label:SetTextColor(unpack(TAB_COLORS.activeText))
    end
  else
    if isHover then
      tab:SetBackdropColor(unpack(TAB_COLORS.inactiveHoverBg))
      tab:SetBackdropBorderColor(unpack(TAB_COLORS.inactiveHoverBorder))
    else
      tab:SetBackdropColor(unpack(TAB_COLORS.inactiveBg))
      tab:SetBackdropBorderColor(unpack(TAB_COLORS.inactiveBorder))
    end
    if tab.label then
      tab.label:SetTextColor(unpack(TAB_COLORS.inactiveText))
    end
  end
end

local function InitTabVisuals(tab)
  tab._isActive = false
  tab._isHovered = false
  tab:SetScript("OnEnter", function(self)
    self._isHovered = true
    ApplyTabVisual(self)
  end)
  tab:SetScript("OnLeave", function(self)
    self._isHovered = false
    ApplyTabVisual(self)
  end)
  ApplyTabVisual(tab)
end

local function SetTabActive(tab, active)
  tab._isActive = active
  ApplyTabVisual(tab)
end

InitTabVisuals(generalTab)
InitTabVisuals(displayTab)
InitTabVisuals(blacklistTab)
InitTabVisuals(editModeTab)

local selectedSuggestionItemID
local suggestionButtons = {}
local ItemSearch = LibStub("ItemSearch-1.3", true)
local UpdateBlacklistDisplay
local HideSuggestions
local RefreshKnownTrinkets
local layoutMenu
local SetLayoutValue

local function CreateCheck(parent, x, y, label, getter, setter)
  local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  check:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  check.text = check:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  check.text:SetPoint("LEFT", check, "RIGHT", 8, 0)
  check.text:SetText(label)
  check:SetScale(0.85)
  ApplyFont(check.text, 13, "")
  check.text:SetTextColor(0.92, 0.96, 1.00, 1.0)
  check:SetChecked(getter())
  check:SetScript("OnClick", function(self)
    setter(self:GetChecked())
    UpdateTrinkets()
  end)
  return check
end

local generalHeading = generalPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
generalHeading:SetPoint("TOPLEFT", 4, -4)
generalHeading:SetText("General Settings")
ApplyFont(generalHeading, 14, "")
generalHeading:SetTextColor(0.85, 0.92, 1.00)

local onUseCheck = CreateCheck(generalPage, 12, -40, "Only show on-use trinkets", function() return Matts1314DB.onlyShowOnUseTrinkets end, function(v) Matts1314DB.onlyShowOnUseTrinkets = v end)
local inCombatCheck = CreateCheck(generalPage, 12, -74, "Only show in combat", function() return Matts1314DB.onlyShowInCombat end, function(v) Matts1314DB.onlyShowInCombat = v end)
local availableCheck = CreateCheck(generalPage, 12, -108, "Only show when ready", function() return Matts1314DB.onlyShowWhenAvailable end, function(v) Matts1314DB.onlyShowWhenAvailable = v end)
local glowReadyCheck = CreateCheck(generalPage, 12, -142, "Glow when ready", function() return Matts1314DB.glowWhenReady end, function(v) Matts1314DB.glowWhenReady = v end)
local bounceReadyCheck = CreateCheck(generalPage, 12, -176, "Bounce when ready", function() return Matts1314DB.bounceWhenReady end, function(v) Matts1314DB.bounceWhenReady = v end)
local soundReadyCheck = CreateCheck(generalPage, 12, -210, "Play sound when ready", function() return Matts1314DB.playSoundWhenReady ~= false end, function(v) Matts1314DB.playSoundWhenReady = v end)
local separateEditIconsCheck = CreateCheck(
  generalPage,
  12,
  -244,
  "Separate 13/14 in Edit Mode",
  function() return Matts1314DB.separateEditModeIcons end,
  function(v)
    Matts1314DB.separateEditModeIcons = v
    if Matts1314 and Matts1314.ApplyEditModeSeparationLock then
      Matts1314.ApplyEditModeSeparationLock()
    end
    UpdateLayout()
  end
)

local fontStyleCheck = CreateCheck(
  displayPage,
  12,
  -228,
  "Use 13/14 font (disable for Blizzard font)",
  function() return Matts1314DB.useCustomFont ~= false end,
  function(v)
    Matts1314DB.useCustomFont = v
    RefreshFonts()
  end
)

local resetEditIconsBtn = CreateFrame("Button", nil, generalPage, "BackdropTemplate")
resetEditIconsBtn:SetPoint("TOPLEFT", 12, -312)
resetEditIconsBtn:SetSize(240, 22)
StyleFlatButton(resetEditIconsBtn)
resetEditIconsBtn.label = resetEditIconsBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
resetEditIconsBtn.label:SetPoint("CENTER", 0, 0)
resetEditIconsBtn.label:SetText("Reset 13/14 EditMode Positions")
ApplyFont(resetEditIconsBtn.label, 12, "")
resetEditIconsBtn.label:SetTextColor(0.90, 0.95, 1.00)
resetEditIconsBtn:SetScript("OnClick", function()
  if Matts1314 and Matts1314.ResetEditModeIconPositions then
    Matts1314.ResetEditModeIconPositions()
    print("|cff00d9ffMatts1314|r reset trinket 13/14 Edit Mode positions.")
  end
end)

local displayHeading = displayPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
displayHeading:SetPoint("TOPLEFT", 4, -4)
displayHeading:SetText("Display Settings")
ApplyFont(displayHeading, 14, "")
displayHeading:SetTextColor(0.85, 0.92, 1.00)

local sizeLabel = displayPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sizeLabel:SetPoint("TOPLEFT", 12, -40)
sizeLabel:SetText("Icon Size: " .. Matts1314DB.iconSize)
ApplyFont(sizeLabel, 14, "")
sizeLabel:SetTextColor(1, 1, 1, 1)

local sizeSlider = CreateFrame("Slider", "Matts1314SizeSlider", displayPage, "OptionsSliderTemplate")
sizeSlider:SetPoint("TOPLEFT", 12, -66)
sizeSlider:SetMinMaxValues(20, 120)
sizeSlider:SetValue(Matts1314DB.iconSize)
sizeSlider:SetValueStep(1)
sizeSlider:SetObeyStepOnDrag(true)
sizeSlider:SetWidth(430)
sizeSlider:SetHeight(14)
_G["Matts1314SizeSliderLow"]:SetText("")
_G["Matts1314SizeSliderHigh"]:SetText("")
_G["Matts1314SizeSliderText"]:SetText("")

for _, region in ipairs({ sizeSlider:GetRegions() }) do
  if region and region.IsObjectType and region:IsObjectType("Texture") then
    region:SetAlpha(0)
  end
end

local sizeSliderTrack = CreateFrame("Frame", nil, sizeSlider, "BackdropTemplate")
sizeSliderTrack:SetPoint("LEFT", sizeSlider, "LEFT", 0, 0)
sizeSliderTrack:SetPoint("RIGHT", sizeSlider, "RIGHT", 0, 0)
sizeSliderTrack:SetHeight(4)
sizeSliderTrack:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  tile = false,
  edgeSize = 1,
  insets = { left = 0, right = 0, top = 0, bottom = 0 },
})
sizeSliderTrack:SetBackdropColor(0.22, 0.25, 0.32, 0.9)
sizeSliderTrack:SetBackdropBorderColor(0.06, 0.08, 0.11, 1)

sizeSlider:SetThumbTexture("Interface\\Buttons\\WHITE8x8")
local thumb = sizeSlider:GetThumbTexture()
if thumb then
  thumb:SetSize(7, 14)
  thumb:SetVertexColor(0.86, 0.93, 1.0, 1)
end

sizeSlider:SetScript("OnValueChanged", function(_, value)
  value = math.floor(value + 0.5)
  Matts1314DB.iconSize = value
  sizeLabel:SetText("Icon Size: " .. value)
  UpdateSizes()
  if Matts1314.MSQ_Group then
    Matts1314.MSQ_Group:ReSkin()
  end
end)

local layoutLabel = displayPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
layoutLabel:SetPoint("TOPLEFT", 12, -118)
layoutLabel:SetText("Layout")
ApplyFont(layoutLabel, 14, "")
layoutLabel:SetTextColor(1, 1, 1, 1)

local layoutSelect = CreateFrame("Button", nil, displayPage, "BackdropTemplate")
layoutSelect:SetPoint("TOPLEFT", 12, -148)
layoutSelect:SetSize(170, 22)
StyleFlatButton(layoutSelect)
layoutSelect.text = layoutSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal")
layoutSelect.text:SetPoint("LEFT", 12, 0)
ApplyFont(layoutSelect.text, 13, "")
layoutSelect.text:SetTextColor(0.90, 0.95, 1.00)
layoutSelect.caret = layoutSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal")
layoutSelect.caret:SetPoint("RIGHT", -10, 0)
layoutSelect.caret:SetText("v")
ApplyFont(layoutSelect.caret, 13, "")
layoutSelect.caret:SetTextColor(0.78, 0.86, 0.96)

layoutMenu = CreateFrame("Frame", nil, panel, "BackdropTemplate")
layoutMenu:SetPoint("TOPLEFT", layoutSelect, "BOTTOMLEFT", 0, -3)
layoutMenu:SetSize(170, 46)
layoutMenu:SetFrameLevel(panel:GetFrameLevel() + 40)
layoutMenu:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  tile = false,
  edgeSize = 1,
  insets = { left = 0, right = 0, top = 0, bottom = 0 },
})
layoutMenu:SetBackdropColor(0.06, 0.09, 0.13, 0.98)
layoutMenu:SetBackdropBorderColor(0.24, 0.33, 0.46, 0.95)
layoutMenu:Hide()

local function GetLayoutLabel(value)
  if value == "horizontal" then
    return "Horizontal"
  end
  return "Vertical"
end

SetLayoutValue = function(value)
  Matts1314DB.layout = value
  layoutSelect.text:SetText(GetLayoutLabel(value))
  UpdateLayout()
end

local function CreateLayoutOption(parent, index, text, value)
  local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
  btn:SetPoint("TOPLEFT", 2, -2 - ((index - 1) * 22))
  btn:SetSize(166, 20)
  btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", tile = false })
  btn:SetBackdropColor(0.10, 0.14, 0.20, 0.95)
  btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  btn.text:SetPoint("LEFT", 8, 0)
  btn.text:SetText(text)
  ApplyFont(btn.text, 13, "")
  btn.text:SetTextColor(0.90, 0.95, 1.00, 1.0)
  btn:SetScript("OnEnter", function(self)
    self:SetBackdropColor(0.14, 0.19, 0.28, 0.98)
  end)
  btn:SetScript("OnLeave", function(self)
    self:SetBackdropColor(0.10, 0.14, 0.20, 0.95)
  end)
  btn:SetScript("OnClick", function()
    SetLayoutValue(value)
    layoutMenu:Hide()
  end)
end

CreateLayoutOption(layoutMenu, 1, "Vertical", "vertical")
CreateLayoutOption(layoutMenu, 2, "Horizontal", "horizontal")

layoutSelect:SetScript("OnClick", function()
  layoutMenu:SetShown(not layoutMenu:IsShown())
end)

local blacklistHeading = blacklistPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
blacklistHeading:SetPoint("TOPLEFT", 4, -4)
blacklistHeading:SetText("Blacklist Trinkets")
ApplyFont(blacklistHeading, 14, "")
blacklistHeading:SetTextColor(0.85, 0.92, 1.00)

local blacklistHint = blacklistPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
blacklistHint:SetPoint("TOPLEFT", blacklistHeading, "BOTTOMLEFT", 0, -6)
blacklistHint:SetText("Type a trinket name or item ID to blacklist it.")
ApplyFont(blacklistHint, 11, "")
blacklistHint:SetTextColor(0.68, 0.76, 0.86, 1.0)

local blacklistInput = CreateFrame("EditBox", nil, blacklistPage, "InputBoxTemplate")
blacklistInput:SetSize(330, 20)
blacklistInput:SetPoint("TOPLEFT", 12, -58)
blacklistInput:SetAutoFocus(false)
blacklistInput:SetMaxLetters(100)

local addButton = CreateFrame("Button", nil, blacklistPage, "BackdropTemplate")
addButton:SetSize(64, 20)
addButton:SetPoint("LEFT", blacklistInput, "RIGHT", 8, 0)
StyleFlatButton(addButton)
addButton.label = addButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
addButton.label:SetPoint("CENTER", 0, 0)
addButton.label:SetText("Add")
ApplyFont(addButton.label, 13, "")
addButton.label:SetTextColor(0.90, 0.95, 1.00)
addButton:SetScript("OnMouseDown", function(self)
  self:SetBackdropColor(0.06, 0.09, 0.13, 1.0)
end)
addButton:SetScript("OnMouseUp", function(self)
  self:SetBackdropColor(0.11, 0.15, 0.22, 0.98)
end)

local function GetItemNameSafe(itemID)
  return C_Item.GetItemNameByID(itemID) or GetItemInfo(itemID)
end

local function IsTrinketItemID(itemID)
  if not itemID then
    return false
  end
  local _, _, _, equipLoc = GetItemInfoInstant(itemID)
  return equipLoc == "INVTYPE_TRINKET"
end

local function IsItemBlacklisted(itemID)
  for _, id in ipairs(Matts1314DB.blacklistedTrinkets) do
    if id == itemID then
      return true
    end
  end
  return false
end

local function RememberTrinket(itemID)
  if not IsTrinketItemID(itemID) then
    return
  end
  Matts1314DB.knownTrinkets = Matts1314DB.knownTrinkets or {}
  Matts1314DB.knownTrinkets[itemID] = true
end

RefreshKnownTrinkets = function()
  Matts1314DB.knownTrinkets = Matts1314DB.knownTrinkets or {}

  RememberTrinket(GetInventoryItemID("player", 13))
  RememberTrinket(GetInventoryItemID("player", 14))

  if C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemLink then
    for bag = 0, NUM_BAG_SLOTS do
      local numSlots = C_Container.GetContainerNumSlots(bag) or 0
      for slot = 1, numSlots do
        local link = C_Container.GetContainerItemLink(bag, slot)
        if link then
          local itemID = C_Item.GetItemInfoInstant(link)
          RememberTrinket(itemID)
        end
      end
    end
  end

  for _, id in ipairs(Matts1314DB.blacklistedTrinkets) do
    RememberTrinket(id)
  end
end

local suggestionFrame = CreateFrame("Frame", nil, blacklistPage, "BackdropTemplate")
suggestionFrame:SetPoint("TOPLEFT", blacklistInput, "BOTTOMLEFT", 0, -4)
suggestionFrame:SetSize(330, 1)
suggestionFrame:SetFrameLevel(panel:GetFrameLevel() + 30)
suggestionFrame:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  tile = false,
  edgeSize = 1,
  insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
suggestionFrame:SetBackdropColor(0.03, 0.05, 0.08, 0.97)
suggestionFrame:SetBackdropBorderColor(0.20, 0.28, 0.40, 0.95)
suggestionFrame:Hide()

HideSuggestions = function()
  suggestionFrame:Hide()
  for _, btn in ipairs(suggestionButtons) do
    btn:Hide()
  end
end

for i = 1, 6 do
  local btn = CreateFrame("Button", nil, suggestionFrame, "BackdropTemplate")
  btn:SetPoint("TOPLEFT", suggestionFrame, "TOPLEFT", 2, -2 - ((i - 1) * 22))
  btn:SetSize(326, 20)
  btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", tile = false })
  btn:SetBackdropColor(0.06, 0.09, 0.13, 0.90)

  btn.icon = btn:CreateTexture(nil, "ARTWORK")
  btn.icon:SetSize(16, 16)
  btn.icon:SetPoint("LEFT", 4, 0)
  btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

  btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  btn.text:SetPoint("LEFT", btn.icon, "RIGHT", 6, 0)
  btn.text:SetPoint("RIGHT", btn, "RIGHT", -6, 0)
  btn.text:SetJustifyH("LEFT")
  ApplyFont(btn.text, 12, "")

  btn:SetScript("OnEnter", function(self)
    self:SetBackdropColor(0.10, 0.14, 0.20, 0.95)
  end)
  btn:SetScript("OnLeave", function(self)
    self:SetBackdropColor(0.06, 0.09, 0.13, 0.90)
  end)
  btn:SetScript("OnClick", function(self)
    selectedSuggestionItemID = self.itemID
    blacklistInput:SetText(self.itemName or tostring(self.itemID))
    blacklistInput:ClearFocus()
    HideSuggestions()
  end)

  suggestionButtons[i] = btn
end

local function BuildTrinketSuggestions(query)
  local results = {}
  if not query or query == "" then
    return results
  end

  local needle = string.lower(query)
  local matcher
  if ItemSearch then
    local ok, compiled = pcall(ItemSearch.Compile, ItemSearch, query)
    if ok and type(compiled) == "function" then
      matcher = compiled
    end
  end

  local ranked = {}
  for itemID in pairs(Matts1314DB.knownTrinkets or {}) do
    if not IsItemBlacklisted(itemID) then
      local itemName = GetItemNameSafe(itemID)
      if itemName then
        local matchedByLib = false
        if matcher then
          local itemLink = C_Item.GetItemLinkByID and C_Item.GetItemLinkByID(itemID) or select(2, GetItemInfo(itemID))
          if itemLink then
            local ok, matched = pcall(matcher, itemLink)
            matchedByLib = ok and matched or false
          end
        end

        local lowerName = string.lower(itemName)
        local prefixMatch = lowerName:find(needle, 1, true) == 1
        local containsMatch = lowerName:find(needle, 1, true) ~= nil
        if matchedByLib or prefixMatch or containsMatch then
          ranked[#ranked + 1] = {
            itemID = itemID,
            itemName = itemName,
            score = prefixMatch and 0 or (containsMatch and 1 or 2),
          }
        end
      end
    end
  end

  table.sort(ranked, function(a, b)
    if a.score ~= b.score then
      return a.score < b.score
    end
    if a.itemName ~= b.itemName then
      return a.itemName < b.itemName
    end
    return a.itemID < b.itemID
  end)

  for i = 1, math.min(6, #ranked) do
    results[#results + 1] = ranked[i]
  end

  return results
end

local function ShowSuggestions(results)
  if #results == 0 then
    HideSuggestions()
    return
  end

  suggestionFrame:SetHeight((#results * 22) + 4)
  suggestionFrame:Show()

  for i, btn in ipairs(suggestionButtons) do
    local row = results[i]
    if row then
      btn.itemID = row.itemID
      btn.itemName = row.itemName
      btn.text:SetText(row.itemName .. " |cff7f8a96(ID: " .. row.itemID .. ")|r")
      local _, _, _, _, icon = GetItemInfoInstant(row.itemID)
      btn.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
      btn:Show()
    else
      btn:Hide()
    end
  end
end

local function AddItemToBlacklist(itemID)
  if IsItemBlacklisted(itemID) then
    local itemName = GetItemNameSafe(itemID) or "Unknown"
    print("|cffFFFFFF" .. itemName .. " (ID: " .. itemID .. ") already blacklisted|r")
    return
  end

  table.insert(Matts1314DB.blacklistedTrinkets, itemID)
  blacklistInput:SetText("")
  selectedSuggestionItemID = nil
  HideSuggestions()
  UpdateTrinkets()
  UpdateBlacklistDisplay()

  local itemName = GetItemNameSafe(itemID) or "Item"
  print("|cff00FFFF[Matts1314]|r Added " .. itemName .. " (ID: " .. itemID .. ")!")
end

local function ResolveInputToTrinketID(input)
  if selectedSuggestionItemID then
    return selectedSuggestionItemID
  end

  local itemID = tonumber(input)
  if itemID then
    if IsTrinketItemID(itemID) then
      return itemID
    end
    return nil, "That item is not a trinket."
  end

  local parsedID = C_Item.GetItemInfoInstant(input)
  if parsedID then
    if IsTrinketItemID(parsedID) then
      return parsedID
    end
    return nil, "That item is not a trinket."
  end

  local lowerInput = string.lower(input)
  for knownID in pairs(Matts1314DB.knownTrinkets or {}) do
    local knownName = GetItemNameSafe(knownID)
    if knownName and string.lower(knownName) == lowerInput then
      return knownID
    end
  end

  return nil, "No trinket match found."
end

addButton:SetScript("OnClick", function()
  local input = blacklistInput:GetText()
  if not input or input == "" then
    print("|cff9B77F7[Matts1314]|r Enter a trinket name or item ID.")
    return
  end

  RefreshKnownTrinkets()
  local itemID, err = ResolveInputToTrinketID(input)
  if not itemID then
    print("|cff9B77F7[Matts1314]|r " .. err)
    return
  end

  AddItemToBlacklist(itemID)
end)

blacklistInput:SetScript("OnTextChanged", function(self, userInput)
  if not userInput then
    return
  end

  selectedSuggestionItemID = nil
  local text = self:GetText() or ""
  if text == "" then
    HideSuggestions()
    return
  end

  RefreshKnownTrinkets()
  ShowSuggestions(BuildTrinketSuggestions(text))
end)

blacklistInput:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  addButton:Click()
end)

blacklistInput:SetScript("OnEscapePressed", function(self)
  self:ClearFocus()
  HideSuggestions()
end)

local scrollFrame = CreateFrame("ScrollFrame", nil, blacklistPage)
scrollFrame:SetSize(410, 280)
scrollFrame:SetPoint("TOPLEFT", 12, -102)
scrollFrame:EnableMouseWheel(true)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(408, 1)
scrollFrame:SetScrollChild(scrollChild)

local scrollBg = CreateFrame("Frame", nil, scrollFrame, "BackdropTemplate")
scrollBg:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
scrollBg:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 0)
scrollBg:SetFrameLevel(scrollFrame:GetFrameLevel() - 1)
scrollBg:SetBackdrop({
  bgFile = "Interface\\Buttons\\White8x8",
  edgeFile = "Interface\\Buttons\\White8x8",
  tile = false,
  edgeSize = 1,
  insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
scrollBg:SetBackdropColor(0.01, 0.02, 0.04, 0.80)
scrollBg:SetBackdropBorderColor(0.20, 0.28, 0.40, 0.70)

local scrollUp = CreateFrame("Button", nil, blacklistPage, "BackdropTemplate")
scrollUp:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 6, 0)
scrollUp:SetSize(14, 14)
StyleFlatButton(scrollUp)
scrollUp.text = scrollUp:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
scrollUp.text:SetPoint("CENTER", 0, 0)
scrollUp.text:SetText("^")
ApplyFont(scrollUp.text, 11, "")
scrollUp.text:SetTextColor(0.90, 0.95, 1.00, 1.0)

local scrollDown = CreateFrame("Button", nil, blacklistPage, "BackdropTemplate")
scrollDown:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 6, 0)
scrollDown:SetSize(14, 14)
StyleFlatButton(scrollDown)
scrollDown.text = scrollDown:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
scrollDown.text:SetPoint("CENTER", 0, 0)
scrollDown.text:SetText("v")
ApplyFont(scrollDown.text, 11, "")
scrollDown.text:SetTextColor(0.90, 0.95, 1.00, 1.0)

local scrollTrack = CreateFrame("Frame", nil, blacklistPage, "BackdropTemplate")
scrollTrack:SetPoint("TOPLEFT", scrollUp, "BOTTOMLEFT", 0, -3)
scrollTrack:SetPoint("BOTTOMRIGHT", scrollDown, "TOPRIGHT", 0, 3)
scrollTrack:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
scrollTrack:SetBackdropColor(0.05, 0.07, 0.11, 0.95)
scrollTrack:SetBackdropBorderColor(0.20, 0.28, 0.40, 0.90)

local scrollBar = CreateFrame("Slider", nil, blacklistPage)
scrollBar:SetOrientation("VERTICAL")
scrollBar:SetPoint("TOPLEFT", scrollTrack, "TOPLEFT", 1, -1)
scrollBar:SetPoint("BOTTOMRIGHT", scrollTrack, "BOTTOMRIGHT", -1, 1)
scrollBar:SetMinMaxValues(0, 0)
scrollBar:SetValue(0)
scrollBar:SetValueStep(12)
scrollBar:SetObeyStepOnDrag(false)
scrollBar:SetThumbTexture("Interface\\Buttons\\WHITE8x8")
local scrollThumb = scrollBar:GetThumbTexture()
if scrollThumb then
  scrollThumb:SetSize(10, 22)
  scrollThumb:SetVertexColor(0.75, 0.84, 0.95, 1.0)
end

local function UpdateBlacklistScrollBar()
  local range = scrollFrame:GetVerticalScrollRange() or 0
  if range <= 0 then
    scrollBar:SetMinMaxValues(0, 0)
    scrollBar:SetValue(0)
    scrollFrame:SetVerticalScroll(0)
    scrollTrack:Hide()
    scrollUp:Hide()
    scrollDown:Hide()
    return
  end

  local current = scrollFrame:GetVerticalScroll() or 0
  if current > range then
    current = range
  end

  scrollBar:SetMinMaxValues(0, range)
  scrollBar:SetValue(current)
  scrollTrack:Show()
  scrollUp:Show()
  scrollDown:Show()
end

scrollBar:SetScript("OnValueChanged", function(_, value)
  scrollFrame:SetVerticalScroll(value)
end)

scrollFrame:SetScript("OnMouseWheel", function(_, delta)
  local minVal, maxVal = scrollBar:GetMinMaxValues()
  local nextValue = scrollBar:GetValue() - (delta * 24)
  if nextValue < minVal then
    nextValue = minVal
  elseif nextValue > maxVal then
    nextValue = maxVal
  end
  scrollBar:SetValue(nextValue)
end)

scrollUp:SetScript("OnClick", function()
  scrollBar:SetValue(math.max(0, scrollBar:GetValue() - 24))
end)

scrollDown:SetScript("OnClick", function()
  local _, maxVal = scrollBar:GetMinMaxValues()
  scrollBar:SetValue(math.min(maxVal, scrollBar:GetValue() + 24))
end)

UpdateBlacklistDisplay = function()
  for _, child in pairs({scrollChild:GetChildren()}) do
    child:Hide()
    child:SetParent(nil)
  end

  for _, region in pairs({scrollChild:GetRegions()}) do
    if region:IsObjectType("FontString") then
      region:Hide()
      region:SetText("")
    end
  end

  if #Matts1314DB.blacklistedTrinkets == 0 then
    local label = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 10, -10)
    label:SetText("No trinkets blacklisted")
    ApplyFont(label, 13, "")
    label:SetTextColor(1, 1, 1, 1)
    scrollChild:SetHeight(200)
  else
    local yOffset = -8
    for i, itemID in ipairs(Matts1314DB.blacklistedTrinkets) do
      local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
      itemName = itemName or "Loading..."
      itemTexture = itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark"

      local entry = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
      entry:SetSize(398, 30)
      entry:SetPoint("TOPLEFT", 6, yOffset)
      entry:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
      })
      entry:SetBackdropColor(0.04, 0.04, 0.05, 0.8)
      entry:SetBackdropBorderColor(0.91, 0.91, 0.91, 1)

      local icon = entry:CreateTexture(nil, "ARTWORK")
      icon:SetSize(20, 20)
      icon:SetPoint("LEFT", 4, 0)
      icon:SetTexture(itemTexture)
      icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

      local text = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      text:SetPoint("LEFT", icon, "RIGHT", 8, 0)
      text:SetText(itemName .. " |cff888888(ID: " .. itemID .. ")|r")
      ApplyFont(text, 12, "")
      text:SetTextColor(1, 1, 1, 1)

      local removeBtn = CreateFrame("Button", nil, entry, "BackdropTemplate")
      removeBtn:SetSize(72, 22)
      removeBtn:SetPoint("RIGHT", -4, 0)
      StyleFlatButton(removeBtn)
      removeBtn.text = removeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      removeBtn.text:SetPoint("CENTER", 0, 0)
      removeBtn.text:SetText("Remove")
      ApplyFont(removeBtn.text, 12, "")
      removeBtn.text:SetTextColor(0.90, 0.95, 1.00, 1.0)
      removeBtn:SetScript("OnClick", function()
        table.remove(Matts1314DB.blacklistedTrinkets, i)
        UpdateTrinkets()
        UpdateBlacklistDisplay()
        print("|cff9B77F7[Matts1314]|r Removed " .. itemName)
      end)

      yOffset = yOffset - 32
    end
    scrollChild:SetHeight(math.max(200, #Matts1314DB.blacklistedTrinkets * 32 + 14))
  end

  C_Timer.After(0, UpdateBlacklistScrollBar)
end

local function ShowPage(page)
  generalPage:SetShown(page == "general")
  displayPage:SetShown(page == "display")
  blacklistPage:SetShown(page == "blacklist")
  SetTabActive(generalTab, page == "general")
  SetTabActive(displayTab, page == "display")
  SetTabActive(blacklistTab, page == "blacklist")
  SetTabActive(editModeTab, false)
  Matts1314DB.optionsTab = page

  layoutMenu:Hide()
  HideSuggestions()

  if page == "blacklist" then
    RefreshKnownTrinkets()
    UpdateBlacklistDisplay()
  end
end

generalTab:SetScript("OnClick", function()
  ShowPage("general")
end)

displayTab:SetScript("OnClick", function()
  ShowPage("display")
end)

blacklistTab:SetScript("OnClick", function()
  ShowPage("blacklist")
end)

editModeTab:SetScript("OnClick", function()
  if Matts1314 and Matts1314.EnterCustomEditMode then
    Matts1314.EnterCustomEditMode(panel)
  else
    print("|cff9B77F7[Matts1314]|r Edit Mode UI not available.")
  end
end)

UpdateBlacklistDisplay()
SLASH_MATTS13141 = "/m1314"
SLASH_MATTS13143 = "/matts1314"
SlashCmdList["MATTS1314"] = function()
  _G.Matts1314_ToggleOptions()
end

panel:SetScript("OnShow", function()
  panel:SetFrameStrata("DIALOG")
  panel:SetFrameLevel(200)
  panel:Raise()
  generalTab.label:SetText("General")
  displayTab.label:SetText("Display")
  blacklistTab.label:SetText("Blacklist")
  editModeTab.label:SetText("Edit Mode")
  onUseCheck:SetChecked(Matts1314DB.onlyShowOnUseTrinkets)
  inCombatCheck:SetChecked(Matts1314DB.onlyShowInCombat)
  availableCheck:SetChecked(Matts1314DB.onlyShowWhenAvailable)
  glowReadyCheck:SetChecked(Matts1314DB.glowWhenReady)
  bounceReadyCheck:SetChecked(Matts1314DB.bounceWhenReady)
  soundReadyCheck:SetChecked(Matts1314DB.playSoundWhenReady ~= false)
  separateEditIconsCheck:SetChecked(Matts1314DB.separateEditModeIcons)
  fontStyleCheck:SetChecked(Matts1314DB.useCustomFont ~= false)
  sizeSlider:SetValue(Matts1314DB.iconSize)
  SetLayoutValue(Matts1314DB.layout or "vertical")
  RefreshFonts()

  selectedSuggestionItemID = nil
  ShowPage(Matts1314DB.optionsTab or "general")
end)
