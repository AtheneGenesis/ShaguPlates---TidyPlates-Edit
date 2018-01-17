-- create frame
pfNameplates = CreateFrame("Frame", nil, UIParent)
pfNameplates:RegisterEvent("PLAYER_TARGET_CHANGED")
pfNameplates:RegisterEvent("UNIT_AURA")

local STANDARD_TEXT_FONT = "Interface\\AddOns\\ShaguPlates\\fonts\\arial.ttf"
local Roster = AceLibrary("RosterLib-2.0")

pfNameplates.mobs = {}
pfNameplates.targets = {}
pfNameplates.players = {}

pfTextCoords = {}
pfTextCoords["0.75;0.25;0.75;0.5"] = 8
pfTextCoords["0.5;0.25;0.5;0.5"] = 7
pfTextCoords["0.25;0.25;0.25;0.5"] = 6
pfTextCoords["0;0.25;0;0.5"] = 5
pfTextCoords["0.75;0;0.75;0.25"] = 4
pfTextCoords["0.5;0;0.5;0.25"] = 3
pfTextCoords["0.25;0;0.25;0.25"] = 2
pfTextCoords["0;0;0;0.25"] = 1
pfTextCoords["0;0;0;1"] = 0

-- catch all nameplates
pfNameplates.scanner = CreateFrame("Frame", "pfNameplateScanner", UIParent)
pfNameplates.scanner.objects = {}
pfNameplates.scanner:SetScript("OnUpdate", function()
  for _, nameplate in ipairs({WorldFrame:GetChildren()}) do
    if not nameplate.done and nameplate:GetObjectType() == "Button" then
      local regions = nameplate:GetRegions()
      if regions and regions:GetObjectType() == "Texture" and regions:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" then
        nameplate:Hide()
        nameplate:SetScript("OnShow", function() pfNameplates:CreateNameplate() end)
        nameplate:SetScript("OnUpdate", function() pfNameplates:UpdateNameplate() end)
        nameplate:SetScript("OnEnter", function() if not IsMouselooking() then this:GetChildren().myglow:Show() end end)
        nameplate:SetScript("OnLeave", function() this:GetChildren().myglow:Hide() end)
        nameplate:Show()
        table.insert(this.objects, nameplate)
        nameplate.done = true
      end
    end
  end
end)

-- Create Nameplate
function pfNameplates:CreateNameplate()
  local healthbar = this:GetChildren()
  local border, glow, name, level, levelicon , raidicon = this:GetRegions()

  -- hide default plates
  border:Hide()

  -- remove glowing
  glow:Hide()
  glow:SetAlpha(0)
  glow.Show = function() return end

  if pfNameplates_config.players == "1" then
    if not pfNameplates.players[name:GetText()] or not pfNameplates.players[name:GetText()]["class"] then
      this:Hide()
    end
  end

  -- healthbar
  healthbar:SetStatusBarTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_Bar")
  healthbar:SetFrameStrata("BACKGROUND")
  healthbar:SetFrameLevel(1)
  healthbar:ClearAllPoints()
  healthbar:SetPoint("TOP", this, "TOP", 0, tonumber(pfNameplates_config.vpos))
  healthbar:SetBackdrop({  bgFile = [[Interface\AddOns\ShaguPlates\img\Neon_Bar_Backdrop]],
                           insets = {left = -1, right = -1, top = -1, bottom = -1} })
  healthbar:SetWidth(102)
  healthbar:SetHeight(32)
  healthbar:SetScale(1)

  if healthbar.targethp == nil then
    healthbar.targethp = CreateFrame("StatusBar", nil, healthbar)
    healthbar.targethp:SetFrameStrata("LOW")
    healthbar.targethp:SetFrameLevel(5)
    healthbar.targethp:SetWidth(46)
    healthbar.targethp:SetHeight(14)
	healthbar.targethp:SetScale(1)
	healthbar.targethp:SetMinMaxValues(0,  100)
    healthbar.targethp:SetValue(100)
    healthbar.targethp:SetPoint("CENTER", healthbar, "CENTER", -14, 4)
    healthbar.targethp:SetBackdrop({  bgFile = [[Interface\AddOns\ShaguPlates\img\Neon_Bar_Backdrop]],
                           insets = {left = -1, right = -1, top = -1, bottom = -1} })
    healthbar.targethp:SetStatusBarTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_Bar")
    healthbar.targethp:SetStatusBarColor(.12,.72,1,1)
	healthbar.targethp:Hide()
	
	if healthbar.targethpoverlay == nil then
		healthbar.targethpoverlay = healthbar.targethp:CreateTexture(nil, "OVERLAY")
		healthbar.targethpoverlay:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_HealthOverlay")
		healthbar.targethpoverlay:ClearAllPoints()
		healthbar.targethpoverlay:SetPoint("CENTER", healthbar.targethp, "CENTER", 0, 0)
		healthbar.targethpoverlay:SetWidth(healthbar.targethp:GetWidth() + 13)
		healthbar.targethpoverlay:SetHeight(healthbar.targethp:GetHeight() +10)
		healthbar.targethpoverlay:Hide()
    end
	
	if healthbar.targethp.text == nil then
      healthbar.targethp.text = healthbar.targethp:CreateFontString("Status", "OVERLAY", "GameFontNormal")
      healthbar.targethp.text:SetPoint("RIGHT", healthbar.targethp, "LEFT",0,2)
      healthbar.targethp.text:SetNonSpaceWrap(false)
      healthbar.targethp.text:SetFontObject(GameFontWhite)
      healthbar.targethp.text:SetTextColor(.12,.72,1,1)
      healthbar.targethp.text:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
    end
  end
  
  if healthbar.bg == nil then
    healthbar.bg = healthbar:CreateTexture(nil, "BORDER")
    healthbar.bg:SetTexture(0,0,0,0)
    healthbar.bg:ClearAllPoints()
    healthbar.bg:SetPoint("CENTER", healthbar, "CENTER", 0.1, 0.1)
    healthbar.bg:SetWidth(healthbar:GetWidth() + 26)
    healthbar.bg:SetHeight(healthbar:GetHeight())
  end
  
  if healthbar.overlay == nil then
    healthbar.overlay = healthbar:CreateTexture(nil, "OVERLAY")
    healthbar.overlay:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_HealthOverlay")
    healthbar.overlay:ClearAllPoints()
    healthbar.overlay:SetPoint("CENTER", healthbar, "CENTER", 0, 0)
    healthbar.overlay:SetWidth(healthbar:GetWidth() + 26)
    healthbar.overlay:SetHeight(healthbar:GetHeight() +4)
    healthbar.overlay:SetAlpha(0.9)
  end
  
  if healthbar.target == nil then
    healthbar.target = healthbar:CreateTexture(nil, "ARTWORK")
    healthbar.target:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_Select")
    healthbar.target:ClearAllPoints()
    healthbar.target:SetPoint("CENTER", healthbar, "CENTER", 0, 0)
    healthbar.target:SetWidth(healthbar:GetWidth() + 26)
    healthbar.target:SetHeight(healthbar:GetHeight() +2)
	healthbar.target:SetAlpha(0.7)
	healthbar.target:Hide()
  end
  
  if healthbar.myglow == nil then
  healthbar.myglow = healthbar:CreateTexture(nil, "BACKGROUND")
  healthbar:SetFrameLevel(1)
  healthbar.myglow:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_Highlight")
  healthbar.myglow:SetPoint("CENTER", healthbar, "CENTER", 0.1, 0.1)
  healthbar.myglow:SetWidth(healthbar:GetWidth()+26)
  healthbar.myglow:SetHeight(healthbar:GetHeight()+2)
  healthbar.myglow:Hide()
  end
  
  if healthbar.aggro == nil then
    healthbar.aggro = this:CreateTexture(nil, "BACKGROUND")
    healthbar.aggro:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_AggroOverlayWhite")
    healthbar.aggro:SetVertexColor(1,0,0,1)
    healthbar.aggro:ClearAllPoints()
    healthbar.aggro:SetPoint("CENTER", healthbar, "CENTER", 0, 0)
    healthbar.aggro:SetWidth(256)
    healthbar.aggro:SetHeight(64)
	healthbar.aggro:Hide()
  end
  
  if healthbar.elite == nil then
	healthbar.lowlayer = CreateFrame("Frame", nil, healthbar)
    healthbar.lowlayer:SetFrameStrata("LOW")
    healthbar.lowlayer:SetFrameLevel(8)
    healthbar.lowlayer:SetWidth(102)
    healthbar.lowlayer:SetHeight(32)
	healthbar.lowlayer:SetScale(1)
    healthbar.elite = healthbar.lowlayer:CreateTexture(nil, "OVERLAY")
    healthbar.elite:SetTexture(nil)
    healthbar.elite:ClearAllPoints()
    healthbar.elite:SetPoint("CENTER", healthbar, "CENTER", -42, 5)
    healthbar.elite:SetWidth(13)
    healthbar.elite:SetHeight(13)
	healthbar.elite:Hide()
  end
  
  healthbar.reaction = nil

  -- raidtarget
  raidicon:ClearAllPoints()
  raidicon:SetWidth(pfNameplates_config.raidiconsize)
  raidicon:SetHeight(pfNameplates_config.raidiconsize)
  -- raidicon:SetPoint("TOPLEFT", healthbar, "TOPLEFT", -pfNameplates_config.raidiconsize, pfNameplates_config.raidiconsize/2)	
  raidicon:SetPoint("RIGHT", healthbar, "RIGHT", pfNameplates_config.raidiconsize/2, pfNameplates_config.raidiconsize/2)	

  -- adjust font
  name:SetFont("Interface\\AddOns\\ShaguPlates\\fonts\\bazooka.ttf",10,"OUTLINE")
  name:SetPoint("BOTTOM", healthbar, "CENTER", 0, 8)
  name:SetWidth(100) --name must remain the same
  name:SetHeight(10) --this shorten the name without breaking it
  -- name:SetShadowOffset(0,0)
  level:SetFont("Interface\\AddOns\\ShaguPlates\\fonts\\bazooka.ttf",12, "OUTLINE")
  level:SetShadowOffset(0,0)
  level:ClearAllPoints()
  level:SetPoint("RIGHT", healthbar, "LEFT", -1, 1)
  level:SetDrawLayer("OVERLAY",7)
  levelicon:ClearAllPoints()
  levelicon:SetPoint("CENTER", healthbar.overlay, "CENTER", -30, 0)
  -- levelicon:SetDrawLayer("OVERLAY",100)
  levelicon:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_EliteStar")
  -- levelicon:Show()

  -- show indicator for elite/rare mobs
  if level:GetText() ~= nil and pfNameplates.mobs[name:GetText()] then
    if pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "elite" and not healthbar.elite:IsShown() then
		healthbar.elite:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_EliteStar")
		healthbar.elite:Show()
    elseif pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "rareelite" and not healthbar.elite:IsShown() then
		healthbar.elite:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_EliteIcon")
		healthbar.elite:Show()
    elseif pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "rare" and not healthbar.elite:IsShown() then
		healthbar.elite:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_RareIcon")
		healthbar.elite:Show()
	elseif pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "boss" and not healthbar.elite:IsShown() then
		healthbar.elite:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Skull_Icon_White")
		healthbar.elite:Show()
	elseif not pfNameplates.mobs[name:GetText()] then
		healthbar.elite:Hide()
    end
  elseif healthbar.elite:IsShown() then
	healthbar.elite:Hide()
  end

  pfNameplates:CreateDebuffs(this)
  pfNameplates:CreateCastbar(healthbar)
  pfNameplates:CreateHP(healthbar)

  this.setup = true
end

function pfNameplates:CreateDebuffs(frame)
  if not pfNameplates_config["showdebuffs"] == "1" then return end

  if frame.debuffs == nil then frame.debuffs = {} end
  for j=1, 16, 1 do
    if frame.debuffs[j] == nil then
      frame.debuffs[j] = this:CreateTexture(nil, "BORDER")
	  frame.debuffs[j].border = this:CreateTexture(nil, "ARTWORK")
	  frame.debuffs[j].border:SetPoint("CENTER", frame.debuffs[j], "CENTER", 1, -2)
	  frame.debuffs[j].border:SetWidth(32); frame.debuffs[j].border:SetHeight(32)
	  frame.debuffs[j].border:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\AuraFrameWide")
      frame.debuffs[j]:SetTexture(0,0,0,0)
	  frame.debuffs[j]:SetTexCoord(.07, 1-.07, .23, 1-.23)
      frame.debuffs[j]:ClearAllPoints()
      frame.debuffs[j]:SetWidth(26)
      frame.debuffs[j]:SetHeight(14)
      if j == 1 then
        frame.debuffs[j]:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", -4, -10)
      elseif j <= 4 then
        frame.debuffs[j]:SetPoint("LEFT", frame.debuffs[j-1], "RIGHT", 2, 0)
      elseif j > 4 then
        frame.debuffs[j]:SetPoint("TOPLEFT", frame.debuffs[1], "BOTTOMLEFT", (j-5) * 28, -1)
      end
    end
  end
end

-- /script pfCastbar:Action(UnitName("target"), "Hearthstone")

function pfNameplates:CreateCastbar(healthbar)
  -- create frames
  if healthbar.castbar == nil then
    healthbar.castbar = CreateFrame("StatusBar", nil, healthbar)
    healthbar.castbar:Hide()
    healthbar.castbar:SetFrameStrata("BACKGROUND")
    healthbar.castbar:SetFrameLevel(1)
    healthbar.castbar:SetWidth(100)
    healthbar.castbar:SetHeight(26)
	healthbar.castbar:SetScale(1)
    healthbar.castbar:SetPoint("BOTTOMLEFT", healthbar, "BOTTOMLEFT", 2, -9)
    -- healthbar.castbar:SetBackdrop({  bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
                                     -- insets = {left = -1, right = -1, top = -1, bottom = -1} })
    -- healthbar.castbar:SetBackdropColor(0,0,0,1)
    healthbar.castbar:SetStatusBarTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_Bar")
    healthbar.castbar:SetStatusBarColor(.98,.54,0,1)

    if healthbar.castbar.bg == nil then
      healthbar.castbar.bg = healthbar.castbar:CreateTexture(nil, "ARTWORK")
      healthbar.castbar.bg:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_CastOverlay")
      healthbar.castbar.bg:ClearAllPoints()
      healthbar.castbar.bg:SetPoint("CENTER", healthbar.castbar, "CENTER", 12, 5)
      healthbar.castbar.bg:SetWidth(128)
      healthbar.castbar.bg:SetHeight(32)
    end

    if healthbar.castbar.text == nil then
      healthbar.castbar.text = healthbar.castbar:CreateFontString("Status", "OVERLAY", "GameFontNormal")
      healthbar.castbar.text:SetPoint("RIGHT", healthbar.castbar, "LEFT",0,1)
      healthbar.castbar.text:SetNonSpaceWrap(false)
      healthbar.castbar.text:SetFontObject(GameFontWhite)
      healthbar.castbar.text:SetTextColor(1,1,1,.5)
      healthbar.castbar.text:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    end

    if healthbar.castbar.spell == nil then
      healthbar.castbar.spell = healthbar.castbar:CreateFontString("Status", "HIGH", "GameFontNormal")
      healthbar.castbar.spell:SetPoint("CENTER", healthbar.castbar, "CENTER")
	  -- healthbar.castbar.spell:SetFrameLevel(100)
      healthbar.castbar.spell:SetNonSpaceWrap(false)
      healthbar.castbar.spell:SetFontObject(GameFontWhite)
      healthbar.castbar.spell:SetTextColor(1,1,1,1)
      healthbar.castbar.spell:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    end

    if healthbar.castbar.icon == nil then
      healthbar.castbar.icon = healthbar.castbar:CreateTexture(nil, "BORDER")
      healthbar.castbar.icon:ClearAllPoints()
      healthbar.castbar.icon:SetPoint("RIGHT", healthbar.castbar.bg, "RIGHT", -5, -1.5)
      healthbar.castbar.icon:SetWidth(17.5)
      healthbar.castbar.icon:SetHeight(17.5)
    end
  end
end

function pfNameplates:CreateHP(healthbar)
  if pfNameplates_config.showhp == "1" and not healthbar.hptext then
    healthbar.hptext = healthbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
    healthbar.hptext:SetPoint("RIGHT", healthbar, "RIGHT",-2,2)
    healthbar.hptext:SetNonSpaceWrap(false)
    healthbar.hptext:SetFontObject(GameFontWhite)
    healthbar.hptext:SetTextColor(1,1,1,1)
    healthbar.hptext:SetFont("Interface\\AddOns\\ShaguPlates\\fonts\\visitor2.ttf", 10, "MONOCHROME OUTLINE")
  end
end

function shortstring(text, size)
	if text then
		if (string.len(text)-3) > (size or 10) then 
			return strsub(text, 1, (size-1 or 9)).."..."
		else
			return text
		end
	else
		return ""
	end
end

-- Update Nameplate
function pfNameplates:UpdateNameplate()
  if not this.setup then pfNameplates:CreateNameplate() return end

  local healthbar = this:GetChildren()
  local border, glow, name, level, levelicon , raidicon = this:GetRegions()
  local raidiconindex = false
  if raidicon:IsVisible() then
	local a,b,c,d = raidicon:GetTexCoord()
	raidiconindex =  pfTextCoords[a..";"..b..";"..c..";"..d]
	healthbar.saveraidicon = raidiconindex
  end
  
  -- if not raidicon:IsVisible() and healthbar.saveraidicon and healthbar.myglow:IsVisible() and not GetRaidTargetIndex("mouseover") then
	-- SetRaidTarget("mouseover", healthbar.saveraidicon);
	-- Print("marquage de "..healthbar.saveraidicon)
  -- end

  if pfNameplates_config.players == "1" then
    if not pfNameplates.players[name:GetText()] or not pfNameplates.players[name:GetText()]["class"] then
      this:Hide()
    end
  end
  
  healthbar.target:Hide()
  healthbar.aggro:Hide()
  healthbar.targethp:Hide()
  healthbar.targethpoverlay:Hide()
  
  if healthbar:GetAlpha() == 1 and UnitName("target") == name:GetText() then
	-- Print("1")
	healthbar.target:Show()
	if UnitName("targettarget") == UnitName("player") and not UnitIsFriend("player", "target") then
		healthbar.aggro:Show()
		healthbar.targethp:Hide()
		healthbar.targethpoverlay:Hide()
	elseif UnitName("targettarget") == nil then
		healthbar.aggro:Hide()
		healthbar.targethp:Hide()
		healthbar.targethpoverlay:Hide()
	else
		healthbar.targethp:Show()
		healthbar.targethpoverlay:Show()
		healthbar.targethp:SetMinMaxValues(0,  UnitHealthMax("targettarget"))
		healthbar.targethp:SetValue(UnitHealth("targettarget"))
		healthbar.targethp.text:SetText(shortstring(UnitName("targettarget"), 10))
	end
  elseif UnitName("mouseovertarget") == UnitName("player") and (GetRaidTargetIndex("mouseover") == raidiconindex or healthbar.myglow:IsShown()) and not UnitIsFriend("player", "mouseover") and UnitExists("mouseovertarget") then
		healthbar.aggro:Show()
		healthbar.targethp:Hide()
		healthbar.targethpoverlay:Hide()
  elseif UnitName("mouseover") == name:GetText() and UnitExists("mouseovertarget") and healthbar.myglow:IsShown() then
		healthbar.targethp:Show()
		healthbar.targethpoverlay:Show()
		healthbar.targethp:SetMinMaxValues(0,  UnitHealthMax("mouseovertarget"))
		healthbar.targethp:SetValue(UnitHealth("mouseovertarget"))
		healthbar.targethp.text:SetText(shortstring(UnitName("mouseovertarget"), 10))
  elseif Roster:GetUnitIDFromName(name:GetText()) and UnitName(Roster:GetUnitIDFromName(name:GetText()).."target") then
	-- Print("2")
	local unitid = Roster:GetUnitIDFromName(name:GetText())
	healthbar.targethp:Show()
	healthbar.targethpoverlay:Show()
	healthbar.targethp:SetMinMaxValues(0,  UnitHealthMax(unitid.."target"))
	healthbar.targethp:SetValue(UnitHealth(unitid.."target"))
	healthbar.targethp.text:SetText(shortstring(UnitName(unitid.."target"), 10))
  else
	-- Print("3")
	for unit in Roster:IterateRoster(false) do
		if UnitName(unit.unitid.."target") == name:GetText() and UnitPlayerControlled(unit.unitid.."target") then
			if UnitName(unit.unitid.."targettarget") == UnitName("player") and not UnitIsFriend("player", unit.unitid.."targettarget") then
				healthbar.aggro:Show()
			else
				healthbar.targethp:Show()
				healthbar.targethpoverlay:Show()
				healthbar.targethp:SetMinMaxValues(0,  UnitHealthMax(unit.unitid.."targettarget"))
				healthbar.targethp:SetValue(UnitHealth(unit.unitid.."targettarget"))
				healthbar.targethp.text:SetText(shortstring(UnitName(unit.unitid.."targettarget"), 10))
			end
		elseif UnitName(unit.unitid.."target") == name:GetText() and raidicon:IsVisible() and GetRaidTargetIndex(unit.unitid.."target") == raidiconindex then
			if UnitName(unit.unitid.."targettarget") == UnitName("player") and healthbar.reaction and healthbar.reaction <= 1 then
				healthbar.aggro:Show()
			else
				healthbar.targethp:Show()
				healthbar.targethpoverlay:Show()
				healthbar.targethp:SetMinMaxValues(0,  UnitHealthMax(unit.unitid.."targettarget"))
				healthbar.targethp:SetValue(UnitHealth(unit.unitid.."targettarget"))
				healthbar.targethp.text:SetText(shortstring(UnitName(unit.unitid.."targettarget"), 10))
			end
		end
	end
  end
  
  if level:GetText() ~= nil and pfNameplates.mobs[name:GetText()] then
	healthbar.elite:SetAlpha(healthbar:GetAlpha())
    if pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "elite" and not healthbar.elite:IsShown() then
		healthbar.elite:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_EliteStar")
		healthbar.elite:Show()
    elseif pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "rareelite" and not healthbar.elite:IsShown() then
		healthbar.elite:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_EliteIcon")
		healthbar.elite:Show()
    elseif pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "rare" and not healthbar.elite:IsShown() then
		healthbar.elite:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Neon_RareIcon")
		healthbar.elite:Show()
	elseif pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "boss" and not healthbar.elite:IsShown() then
		healthbar.elite:SetTexture("Interface\\AddOns\\ShaguPlates\\img\\Skull_Icon_White")
		healthbar.elite:Show()
    end
  elseif healthbar.elite:IsShown() then
	healthbar.elite:Hide()
  end

  pfNameplates:UpdatePlayer(name)
  pfNameplates:UpdateColors(name, level, healthbar)
  pfNameplates:UpdateCastbar(this, name, healthbar)
  pfNameplates:UpdateDebuffs(this, healthbar)
  pfNameplates:UpdateHP(healthbar)
  pfNameplates:UpdateClickHandler(this)
end

function pfNameplates:UpdatePlayer(name)
  local name = name:GetText()

  -- target
  if not pfNameplates.players[name] and pfNameplates.targets[name] == nil and UnitName("target") == nil then
    TargetByName(name, true)
	if UnitName("target") == name then
		if UnitIsPlayer("target") then
		  local _, class = UnitClass("target")
		  pfNameplates.players[name] = {}
		  pfNameplates.players[name]["class"] = class
		elseif UnitClassification("target") ~= "normal" then
		  local elite = UnitClassification("target")
		  pfNameplates.mobs[name] = elite
		end
		pfNameplates.targets[name] = "OK"
		ClearTarget()
	end
  end

  -- mouseover
  if not pfNameplates.players[name] and pfNameplates.targets[name] == nil and UnitName("mouseover") == name then
    if UnitIsPlayer("mouseover") then
      local _, class = UnitClass("mouseover")
      pfNameplates.players[name] = {}
      pfNameplates.players[name]["class"] = class
    elseif UnitClassification("mouseover") ~= "normal" then
      local elite = UnitClassification("mouseover")
      pfNameplates.mobs[name] = elite
    end
    pfNameplates.targets[name] = "OK"
  end
end

function pfNameplates:UpdateColors(name, level, healthbar)
  -- name color
  local red, green, blue, _ = name:GetTextColor()
  if red > 0.99 and green == 0 and blue == 0 then
    name:SetTextColor(1,0.4,0.2,0.85)
  elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
    name:SetTextColor(1,1,1,0.85)
  end

  -- level colors
  local red, green, blue, _ = level:GetTextColor()
  if red > 0.99 and green == 0 and blue == 0 then
    level:SetTextColor(1,0.4,0.2,0.85)
  elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
    level:SetTextColor(1,1,1,0.85)
  end

  -- healthbar color
  -- reaction: 0 enemy ; 1 neutral ; 2 player ; 3 npc
  local red, green, blue, _ = healthbar:GetStatusBarColor()
  if red > 0.9 and green < 0.2 and blue < 0.2 then
    healthbar.reaction = 0
    healthbar:SetStatusBarColor(1,0,0,1)
  elseif red > 0.9 and green > 0.9 and blue < 0.2 then
    healthbar.reaction = 1
    healthbar:SetStatusBarColor(1,1,0,1)
  elseif ( blue > 0.9 and red == 0 and green == 0 ) then
    healthbar.reaction = 2
    healthbar:SetStatusBarColor(0.2,0.6,1,1)
  elseif red == 0 and green > 0.99 and blue == 0 then
    healthbar.reaction = 3
    healthbar:SetStatusBarColor(0,1,0,1)
  end

  local name = name:GetText()

  if healthbar.reaction == 0 then
    if pfNameplates_config["enemyclassc"] == "1"
    and pfNameplates.players[name]
    and pfNameplates.players[name]["class"]
    and RAID_CLASS_COLORS[pfNameplates.players[name]["class"]]
    then
      healthbar:SetStatusBarColor(
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].r,
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].g,
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].b,
        1)
    end
  elseif healthbar.reaction == 2 then
    if pfNameplates_config["friendclassc"] == "1"
    and pfNameplates.players[name]
    and pfNameplates.players[name]["class"]
    and RAID_CLASS_COLORS[pfNameplates.players[name]["class"]]
    then
      healthbar:SetStatusBarColor(
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].r,
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].g,
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].b,
        1)
    end
  end
end

function pfNameplates:UpdateCastbar(frame, name, healthbar)
  if not healthbar.castbar then return end
  -- show castbar
  if pfNameplates_config["showcastbar"] == "1" and pfCastbar.casterDB[name:GetText()] ~= nil and pfCastbar.casterDB[name:GetText()]["cast"] ~= nil then
    if pfCastbar.casterDB[name:GetText()]["starttime"] + pfCastbar.casterDB[name:GetText()]["casttime"] <= GetTime() then
      pfCastbar.casterDB[name:GetText()] = nil
      healthbar.castbar:Hide()
    else
      healthbar.castbar:SetMinMaxValues(0,  pfCastbar.casterDB[name:GetText()]["casttime"])
      healthbar.castbar:SetValue(GetTime() -  pfCastbar.casterDB[name:GetText()]["starttime"])
      healthbar.castbar.text:SetText(round( pfCastbar.casterDB[name:GetText()]["starttime"] +  pfCastbar.casterDB[name:GetText()]["casttime"] - GetTime(),1))
      if pfNameplates_config.spellname == "1" and healthbar.castbar.spell then
        healthbar.castbar.spell:SetText(pfCastbar.casterDB[name:GetText()]["cast"])
      else
        healthbar.castbar.spell:SetText("")
      end
      healthbar.castbar:Show()
      frame.debuffs[1]:SetPoint("TOPLEFT", healthbar.castbar, "BOTTOMLEFT", 0, 3)

      if pfCastbar.casterDB[name:GetText()]["icon"] then
        healthbar.castbar.icon:SetTexture("Interface\\Icons\\" ..  pfCastbar.casterDB[name:GetText()]["icon"])
        healthbar.castbar.icon:SetTexCoord(.1,.9,.1,.9)
      end
    end
  else
    healthbar.castbar:Hide()
    frame.debuffs[1]:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, 3)
  end
end

function pfNameplates:UpdateDebuffs(frame, healthbar)
  if not frame.debuffs or not pfNameplates_config["showdebuffs"] == "1" then return end

  if UnitExists("target") and healthbar:GetAlpha() == 1 then
  local j = 1
    local k = 1
    for j, e in ipairs(pfNameplates.debuffs) do
      frame.debuffs[j]:SetTexture(pfNameplates.debuffs[j])
      frame.debuffs[j]:SetTexCoord(.07, 1-.07, .23, 1-.23)
      frame.debuffs[j]:SetAlpha(0.9)
      frame.debuffs[j].border:SetAlpha(1)
      k = k + 1
    end
    for j = k, 16, 1 do
      frame.debuffs[j]:SetTexture(nil)
      frame.debuffs[j].border:SetAlpha(0)
    end
  elseif frame.debuffs then
    for j = 1, 16, 1 do
      frame.debuffs[j].border:SetAlpha(0)
      frame.debuffs[j]:SetTexture(nil)
    end
  end
end

function pfNameplates:UpdateHP(healthbar)
  if pfNameplates_config.showhp == "1" and healthbar.hptext then
    local min, max = healthbar:GetMinMaxValues()
    local cur = healthbar:GetValue()
	if max == 100 then
		healthbar.hptext:SetText(cur .."%")
	else
		healthbar.hptext:SetText(cur)
	end
  end
end

function pfNameplates:UpdateClickHandler(frame)
  -- enable clickthrough
  if pfNameplates_config["clickthrough"] == "0" then
    frame:EnableMouse(true)
    if pfNameplates_config["rightclick"] == "1" then
      frame:SetScript("OnMouseDown", function()
        if arg1 and arg1 == "RightButton" then
          MouselookStart()

          -- start detection of the rightclick emulation
          pfNameplates.emulateRightClick.time = GetTime()
          pfNameplates.emulateRightClick.frame = this
          pfNameplates.emulateRightClick:Show()
        end
      end)
    end
  else
    frame:EnableMouse(false)
  end
end

-- debuff detection
pfNameplates:RegisterEvent("PLAYER_TARGET_CHANGED")
pfNameplates:RegisterEvent("UNIT_AURA")
pfNameplates:SetScript("OnEvent", function()
  pfNameplates.debuffs = {}
  local i = 1
  local debuff = UnitDebuff("target", i)
  while debuff do
    pfNameplates.debuffs[i] = debuff
    i = i + 1
    debuff = UnitDebuff("target", i)
  end
end)

-- combat tracker
pfNameplates.combat = CreateFrame("Frame")
pfNameplates.combat:RegisterEvent("PLAYER_ENTER_COMBAT")
pfNameplates.combat:RegisterEvent("PLAYER_LEAVE_COMBAT")
pfNameplates.combat:SetScript("OnEvent", function()
  if event == "PLAYER_ENTER_COMBAT" then
    this.inCombat = 1
  elseif event == "PLAYER_LEAVE_COMBAT" then
    this.inCombat = nil
  end
end)

-- emulate fake rightclick
pfNameplates.emulateRightClick = CreateFrame("Frame", nil, UIParent)
pfNameplates.emulateRightClick.time = nil
pfNameplates.emulateRightClick.frame = nil
pfNameplates.emulateRightClick:SetScript("OnUpdate", function()
  -- break here if nothing to do
  if not pfNameplates.emulateRightClick.time or not pfNameplates.emulateRightClick.frame then
    this:Hide()
    return
  end

  -- if threshold is reached (0.5 second) no click action will follow
  if not IsMouselooking() and pfNameplates.emulateRightClick.time + tonumber(pfNameplates_config["clickthreshold"]) < GetTime() then
    pfNameplates.emulateRightClick:Hide()
    return
  end

  -- run a usual nameplate rightclick action
  if not IsMouselooking() then
    pfNameplates.emulateRightClick.frame:Click("LeftButton")
    if UnitCanAttack("player", "target") and not pfNameplates.combat.inCombat then AttackTarget() end
    pfNameplates.emulateRightClick:Hide()
    return
  end
end)
