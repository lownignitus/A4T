-- Title: A4T (AAAAT or Artifact Alternate Appearance Achievement Tracker)
-- Author: LownIgnitus
-- Version: 1.0.1
-- Desc: Frame for tracking Achievemnets tied to progress unlocking artifact hidden appearance extra recolours.

CF = CreateFrame
local atBarBG = { bgFile = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}}
local addon_name = "A4T"
local y = -15
local ranLast = false
local ranLastQ = false
local count = 0
local countQ = 0
SLASH_A4T1 = '/A4T' or '/a4t' or '/A4t' or 'a4T' or '/aaaat' or '/AAAAT'

local atEvents_table = {}
atEvents_table.eventFrame = CF("Frame");
atEvents_table.eventFrame:RegisterEvent("ADDON_LOADED");
atEvents_table.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
atEvents_table.eventFrame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED");
atEvents_table.eventFrame:RegisterEvent("QUEST_WATCH_LIST_CHANGED");
atEvents_table.eventFrame:SetScript("OnEvent", function(self, event, ...)
	atEvents_table.eventFrame[event](self, ...);
end);

function atEvents_table.eventFrame:ADDON_LOADED(AddOn)
	if AddOn ~= addon_name then
		return
	end

	atEvents_table.eventFrame:UnregisterEvent("ADDON_LOADED")

	atFrame.title.text:SetText(GetAddOnMetadata("A4T", "Title") .. " " .. GetAddOnMetadata("A4T", "Version"))

	local defaults = {
		["options"] = {
			["atScale"] = 1,
			["atAlpha"] = 0,
			["atLock"] = true,
			["atMouseOver"] = false,
			["atHidden"] = false,
			["atDungeon"] = true,
			["atWQ"] = true,
			["atPvP"] = true,
			["atDB"] = {hide = false},
		}
	}

	local function atSVCheck(src, dst)
		if type(src) ~= "table" then return {} end
		if type(dst) ~= "table" then dst = {} end
		for k, v in pairs(src) do
			if type(v) == "table" then
				dst[k] = atSVCheck(v,dst[k])
			elseif type(v) ~= type(dst[k]) then
				dst[k] = v
			end
		end
		return dst
	end

	atSettings = atSVCheck(defaults, atSettings)
	atOptionsInit();
	atInitialize();
end

function atEvents_table.eventFrame:PLAYER_PVP_KILLS_CHANGED()
--	print("Player PvP Kills Changed")
	atUpdateData()
end

function atEvents_table.eventFrame:QUEST_WATCH_LIST_CHANGED()
--	print("Quest watch list changed")
	if ranLastQ == false then
		countQ = countQ+1
		ranLastQ = true
		if not InCombatLockdown() then
			atUpdateData()
		end
	elseif ranLastQ == true and countQ == 1 then
		countQ = countQ+1
		ranLastQ = true
	else
		countQ = 0
		ranLastQ = false
		if not InCombatLockdown() then
			atUpdateData()
		end
	end	
end

function atEvents_table.eventFrame:PLAYER_ENTERING_WORLD()
--	print("Player entering world")
	if ranLast == false then
		count = count+1
		ranLast = true
		if not InCombatLockdown() then
			atUpdateData()
		end
	elseif ranLast == true and count <= 3 then
		count = count+1
		ranLast = true
	elseif ranLast == true and count == 4 then
		count = 0
		ranLast = false
		if not InCombatLockdown() then
			atUpdateData()
		end
	end	
end

function atOptionsInit()
	local atOptions = CF("Frame", nil, InterfaceOptionsFramePanelContainer);
	local panelWidth = InterfaceOptionsFramePanelContainer:GetWidth() -- ~623
	local wideWidth = panelWidth - 40
	atOptions:SetWidth(wideWidth)
	atOptions:Hide();
	atOptions.name = "|cff00ff00A4T|r"
	atOptionsBG = { edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, edgeSize = 16 }

	-- Special thanks to Ro for inspiration for the overall structure of this options panel (and the title/version/description code)
	local function createfont(fontName, r, g, b, anchorPoint, relativeto, relativePoint, cx, cy, xoff, yoff, text)
		local font = atOptions:CreateFontString(nil, "BACKGROUND", fontName)
		font:SetJustifyH("LEFT")
		font:SetJustifyV("TOP")
		if type(r) == "string" then -- r is text, not position
			text = r
		else
			if r then
				font:SetTextColor(r, g, b, 1)
			end
			font:SetSize(cx, cy)
			font:SetPoint(anchorPoint, relativeto, relativePoint, xoff, yoff)
		end
		font:SetText(text)
		return font
	end

	-- Special thanks to Hugh & Simca for checkbox creation 
	local function createcheckbox(text, cx, cy, anchorPoint, relativeto, relativePoint, xoff, yoff, frameName, font)
		local checkbox = CF("CheckButton", frameName, atOptions, "UICheckButtonTemplate")
		checkbox:SetPoint(anchorPoint, relativeto, relativePoint, xoff, yoff)
		checkbox:SetSize(cx, cy)
		local checkfont = font or "GameFontNormal"
		checkbox.text:SetFontObject(checkfont)
		checkbox.text:SetText(" " .. text)
		return checkbox
	end
	--GameFontNormalHuge GameFontNormalLarge 
	local title = createfont("SystemFont_OutlineThick_WTF", GetAddOnMetadata(addon_name, "Title"))
	title:SetPoint("TOPLEFT", 16, -16)
	local ver = createfont("SystemFont_Huge1", GetAddOnMetadata(addon_name, "Version"))
	ver:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 4, 0)
	local date = createfont("GameFontNormalLarge", "Version Date: " .. GetAddOnMetadata(addon_name, "X-Date"))
	date:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	local author = createfont("GameFontNormal", "Author: " .. GetAddOnMetadata(addon_name, "Author"))
	author:SetPoint("TOPLEFT", date, "BOTTOMLEFT", 0, -8)
	local website = createfont("GameFontNormal", "Website: " .. GetAddOnMetadata(addon_name, "X-Website"))
	website:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -8)
	local desc = createfont("GameFontHighlight", GetAddOnMetadata(addon_name, "Notes"))
	desc:SetPoint("TOPLEFT", website, "BOTTOMLEFT", 0, -8)
	local desc2 = createfont("GameFontHighlight", GetAddOnMetadata(addon_name, "X-Notes2"))
	desc2:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -8)

	-- Misc Options Frame
	local atMiscFrame = CF("Frame", ATMiscFrame, atOptions)
	atMiscFrame:SetPoint("TOPLEFT", desc2, "BOTTOMLEFT", 0, -8)
	atMiscFrame:SetBackdrop(atOptionsBG)
	atMiscFrame:SetSize(240, 215)

	local miscTitle = createfont("GameFontNormal", nil, nil, nil, "TOP", atMiscFrame, "TOP", 150, 16, 0, -8, "Miscellaneous Options")

	-- Enable Mouseover
	local atMouseOverOpt = createcheckbox("Enable Mouseover of A4T.", 18, 18, "TOPLEFT", miscTitle, "TOPLEFT", -40, -16, "atMouseOverOpt")

	atMouseOverOpt:SetScript("OnClick", function(self)
		if atMouseOverOpt:GetChecked() == true then
			atSettings.options.atMouseOver = true
			atFrame:SetAlpha(atSettings.options.atAlpha)
			ChatFrame1:AddMessage("Mouseover |cff00ff00enabled|r!")
		else
			atSettings.options.atMouseOver = false
			atFrame:SetAlpha(1)
			ChatFrame1:AddMessage("Mouseover |cffff0000disabled|r!")
		end
	end)

	-- Toggle Dungeon
	local atDungeonOpt = createcheckbox("Hide dungeon progress.", 18, 18, "TOPLEFT", atMouseOverOpt, "BOTTOMLEFT", 0, 0, "atDungeonOpt")

	atDungeonOpt:SetScript("OnClick", function(self) atDungeonToggle() end)

	-- Toggle World Quest
	local atWQOpt = createcheckbox("Hide World Quest progress.", 18, 18, "TOPLEFT", atDungeonOpt, "BOTTOMLEFT", 0, 0, "atWQOpt")

	atWQOpt:SetScript("OnClick", function(self) atWQToggle() end)

	-- Toggle PvP
	local atPvPOpt = createcheckbox("Hide Palyer Kills progress.", 18, 18, "TOPLEFT", atWQOpt, "BOTTOMLEFT", 0, 0, "atPvPOpt")

	atPvPOpt:SetScript("OnClick", function(self) atPvPToggle() end)

	-- Scale Frame
	local atScaleFrame = CF("Frame", "ATScaleFrame", atOptions)
	atScaleFrame:SetPoint("TOPLEFT", atMiscFrame, "TOPRIGHT", 8, 0)
	atScaleFrame:SetBackdrop(atOptionsBG)
	atScaleFrame:SetSize(150, 75)

	-- A4T Scale
	local atScale = CF("Slider", "ATScale", atScaleFrame, "OptionsSliderTemplate")
	atScale:SetSize(120, 16)
	atScale:SetOrientation('HORIZONTAL')
	atScale:SetPoint("TOP", atScaleFrame, "TOP", 0, -25)

	_G[atScale:GetName() .. 'Low']:SetText('0.5') -- Sets left side of slider text [default is "Low"]
	_G[atScale:GetName() .. 'High']:SetText('1.5') -- Sets right side of slider text [default is "High"]
	_G[atScale:GetName() .. 'Text']:SetText('|cffFFCC00Scale|r') -- Sets the title text [top-center of slider]

	atScale:SetMinMaxValues(0.5, 1.5)
	atScale:SetValueStep(0.05);

	-- Scale Display Editbox
	local atScaleDisplay = CF("Editbox", "ATScaleDisplay", atScaleFrame, "InputBoxTemplate")
	atScaleDisplay:SetSize(32, 16)
	atScaleDisplay:ClearAllPoints()
	atScaleDisplay:SetPoint("TOP", atScale, "BOTTOM", 0, -10)
	atScaleDisplay:SetAutoFocus(false)
	atScaleDisplay:SetEnabled(false)
	atScaleDisplay:SetText(atSettings.options.atScale)

	atScale:SetScript("OnValueChanged", function(self, value)
		value = floor(value/0.05)*0.05
		atFrame:SetScale(value)
		atSettings.options.atScale = value
		atScaleDisplay:SetText(atSettings.options.atScale)
	end);

	-- Alpha Frame
	local atAlphaFrame = CF("Frame", "ATAlphaFrame", atOptions)
	atAlphaFrame:SetPoint("TOPLEFT", atScaleFrame, "TOPRIGHT", 8, 0)
	atAlphaFrame:SetBackdrop(atOptionsBG)
	atAlphaFrame:SetSize(150, 75)

	-- Skill Helper Alpha
	local atAlpha = CF("Slider", "ATAlpha", atAlphaFrame, "OptionsSliderTemplate")
	atAlpha:SetSize(120, 16)
	atAlpha:SetOrientation('HORIZONTAL')
	atAlpha:SetPoint("TOP", atAlphaFrame, "TOP", 0, -25)

	_G[atAlpha:GetName() .. 'Low']:SetText('0') -- Sets left side of slider text [default is "Low"]
	_G[atAlpha:GetName() .. 'High']:SetText('1') -- Sets right side of slider text [default is "High"]
	_G[atAlpha:GetName() .. 'Text']:SetText('|cffFFCC00Minimum Alpha|r') -- Sets the title text [top-center of slider]

	atAlpha:SetMinMaxValues(0, 1)
	atAlpha:SetValueStep(0.05);

	-- Alpha Display Editbox
	local atAlphaDisplay = CF("Editbox", "ATScaleDisplay", atAlphaFrame, "InputBoxTemplate")
	atAlphaDisplay:SetSize(32, 16)
	atAlphaDisplay:ClearAllPoints()
	atAlphaDisplay:SetPoint("TOP", atAlpha, "BOTTOM", 0, -10)
	atAlphaDisplay:SetAutoFocus(false)
	atAlphaDisplay:SetEnabled(false)
	atAlphaDisplay:SetText(atSettings.options.atAlpha)

	atAlpha:SetScript("OnValueChanged", function(self, value)
		value = floor(value/0.05)*0.05
		atSettings.options.atAlpha = value
		if atSettings.options.atMouseOver == true then
			atFrame:SetAlpha(atSettings.options.atAlpha)
		end
		atAlphaDisplay:SetText(atSettings.options.atAlpha)
	end);

	atOptions.refresh = function()
		atScale:SetValue(atSettings.options.atScale);
		atAlpha:SetValue(atSettings.options.atAlpha);
	end

	function atOptions.okay()
		atOptions:Hide();
	end

	function atOptions.cancel()
		atOptions:Hide();
	end

	function atOptions.default()
		atReset();
	end

	-- add the Options panel to the Blizzard list
	InterfaceOptions_AddCategory(atOptions);
end

-- Tracking table
local achieves = {}
local bars = {}

function atDrawBar(name, amount, max, y)
--	print("in drawbar " .. name .. " " .. amount .. " " .. max .. " " .. y)
	local bar = bars[name]
	if not bar then
		bar = CF("StatusBar", nil, atDataFrame)
		bar:SetFrameStrata("BACKGROUND")
		bar:SetPoint("TOPLEFT", atDataFrame, "TOPLEFT", 6, y-4)
		bar:SetSize(196,18)
		bar:SetBackdrop(atBarBG)
		bar:SetBackdropColor(0,0.7,0,0.5)
		bar:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
		bar:SetStatusBarColor(0,0.7,0,1)
		bar:SetMinMaxValues(0,1)
		bar:SetValue(amount/max)

		local barTxt = bar:CreateFontString(nil, "ARTWORK");
		isValid = barTxt:SetFont("Fonts\\FRIZQT__.TTF", 10);
		barTxt:SetPoint("CENTER", bar, "CENTER", 0, 1);
		bar.text = barTxt

		bar.text:SetFormattedText("|cFFFFFF00%s: |cFFFFFFFF%s/%s", name, amount, max)

		bars[name] = bar
	else
		bar:ClearAllPoints()
	end

	bar:SetPoint("TOPLEFT", atDataFrame, "TOPLEFT", 6, y-4)
	bar:SetStatusBarColor(0,0.7,0,1)
	bar:SetBackdropColor(0,0.7,0,0.5)
	bar:SetValue(amount/max)
	bar.text:SetFormattedText("|cFFFFFF00%s: |cFFFFFFFF%s/%s", name, amount, max)

	atFrame:SetHeight((y - 27)* -1)
	atDataFrame:SetHeight((y - 27)* -1)
end

function atUpdateData()
	local dungeon = "Dungeons"
	local wq = "World Quests"
	local pvp = "Player Kills"
	local ach = {}
	local a = 0
	local b = 0
	local x = 0
	for i = 1,11 do
		_,_,_,x,b = GetAchievementCriteriaInfo(11152,i)
		a = a+x
	end
--	print(a .. " " .. b)
	local _,_,_,c,d = GetAchievementCriteriaInfo(11153,1)
--	print(c .. " " .. d)
	local _,_,_,e,f = GetAchievementCriteriaInfo(11154,1)
--	print(e .. " " .. f)

	if atSettings.options.atDungeon == true then
--[[		atDrawBar(dungeon, a, b, y)
		y = y - 18
		tinsert(achieves, dungeon)]]

		tinsert(ach, dungeon)
	end
	if atSettings.options.atWQ == true then
--[[		atDrawBar(wq, c, d, y)
		y = y - 18
		tinsert(achieves, wq)]]

		tinsert(ach, wq)
	end
	if atSettings.options.atPvP == true then
--[[		atDrawBar(pvp, e, f, y)
		y = y - 18
		tinsert(achieves, pvp)]]

		tinsert(ach, pvp)
	end

	for k, v in pairs(ach) do
		if v == dungeon then
			atDrawBar(dungeon, a, b, y)
		elseif v == wq then
			atDrawBar(wq, c, d, y)
		elseif v == pvp then
			atDrawBar(pvp, e, f, y)
		end
		y = y - 18

		tinsert(achieves, v)
	end
	atCleanUp()

	y = -15
end

function atCleanUp()
	local match = false
	local clnBar

	for k, d in pairs(bars) do
		for i, v in pairs(achieves) do
			if k == v then
				match = true
				break
			else
				match = false
			end
		end

		clnBar = bars[k]

		if match == false then
			clnBar:Hide()
			match = false
		elseif match == true then
			clnBar:Show()
		end
	end

	while ((# achieves) > 0) do
		tremove( achieves, 1)
	end
end

function atInitialize()
	if atAutohide == nil then
		atAutohide = false
	end

	atFrame:SetScale(atSettings.options.atScale)

	if atSettings.options.atLock == true then
		atFrame:EnableMouse(true)
		atFrame.buttonLock:SetChecked(true)
	else
		atFrame:EnableMouse(false)
		atFrame.buttonLock:SetChecked(false)
	end

	if atSettings.options.atHidden == false then
		atFrame:Show()
	else
		atFrame:Hide()
	end

	if atSettings.options.atMouseOver == true then
		atMouseOverOpt:GetChecked(true)
		atFrame:SetAlpha(atSettings.options.atAlpha)
	else
		atMouseOverOpt:GetChecked(false)
	end

	if atSettings.options.atDungeon == true then
		atDungeonOpt:SetChecked(false)
	else
		atDungeonOpt:SetChecked(true)
	end

	if atSettings.options.atWQ == true then
		atWQOpt:SetChecked(false)
	else
		atWQOpt:SetChecked(true)
	end

	if atSettings.options.atPvP == true then
		atPvPOpt:SetChecked(false)
	else
		atPvPOpt:SetChecked(true)
	end

	atUpdateData()
end

function atMouseOverEnter()
	if atSettings.options.atMouseOver == true then
		atFrame:SetAlpha(1);
	end
end

function atMouseOverLeave()
	if atSettings.options.atMouseOver == true then
		atFrame:SetAlpha(atSettings.options.atAlpha);
	end
end

function atToggle()
	if atSettings.options.atHidden == false then
		atFrame:Hide()
		ChatFrame1:AddMessage("A4T is |cFFFF0000hidden|r!")
		atSettings.options.atHidden = true
	elseif atSettings.options.atHidden == true then
		atFrame:Show()
		ChatFrame1:AddMessage("A4T is |cFF00FF00visible|r!")
		atSettings.options.atHidden = false
	end
end

function atDungeonToggle()
	if atSettings.options.atDungeon == true then
		atSettings.options.atDungeon = false
		ChatFrame1:AddMessage("Dungeons have been |cFFFF0000hidden|r!")
		atDungeonOpt:SetChecked(true)
		atUpdateData();
	elseif atSettings.options.atDungeon == false then
		atSettings.options.atDungeon = true
		ChatFrame1:AddMessage("Dungeons are now |cFF00FF00visible|r!")
		atDungeonOpt:SetChecked(false)
		atUpdateData();
	end
end

function atWQToggle()
	if atSettings.options.atWQ == true then
		atSettings.options.atWQ = false
		ChatFrame1:AddMessage("World Quests have been |cFFFF0000hidden|r!")
		atWQOpt:SetChecked(true)
		atUpdateData();
	elseif atSettings.options.atWQ == false then
		atSettings.options.atWQ = true
		ChatFrame1:AddMessage("World Quests are now |cFF00FF00visible|r!")
		atWQOpt:SetChecked(false)
		atUpdateData();
	end
end

function atPvPToggle()
	if atSettings.options.atPvP == true then
		atSettings.options.atPvP = false
		ChatFrame1:AddMessage("Player Kills have been |cFFFF0000hidden|r!")
		atPvPOpt:SetChecked(true)
		atUpdateData();
	elseif atSettings.options.atPvP == false then
		atSettings.options.atPvP = true
		ChatFrame1:AddMessage("Player Kills are now |cFF00FF00visible|r!")
		atPvPOpt:SetChecked(false)
		atUpdateData();
	end
end

function atOption()
	InterfaceOptionsFrame_OpenToCategory("|cff00ff00A4T|r");
	InterfaceOptionsFrame_OpenToCategory("|cff00ff00A4T|r");
end

function atInfo()
	ChatFrame1:AddMessage(GetAddOnMetadata("A4T", "Title") .. " " .. GetAddOnMetadata("A4T", "Version"))
	ChatFrame1:AddMessage("Author: " .. GetAddOnMetadata("A4T", "Author"))
	ChatFrame1:AddMessage(GetAddOnMetadata("A4T", "Notes"))
	ChatFrame1:AddMessage(GetAddOnMetadata("A4T", "X-Notes2"))
end

function atLocker()
	if atSettings.options.atLock == true then
		atSettings.options.atLock = false
		atFrame.buttonLock:SetChecked(false)
		atFrame:EnableMouse(atSettings.options.atLock)
		ChatFrame1:AddMessage("A4T is |cFFFF0000locked|r!")
	elseif atSettings.options.atLock == false then
		atSettings.options.atLock = true
		atFrame.buttonLock:SetChecked(true)
		atFrame:EnableMouse(atSettings.options.atLock)
		ChatFrame1:AddMessage("A4T is |cFF00FF00unlocked|r!")
	end
end

function SlashCmdList.A4T(msg)
	if msg == "toggle" then
		atToggle()
	elseif msg == "lock" then
		atLocker()
	elseif msg == "reset" then
		atReset()
	elseif msg == "options" then
		atOptions()
	elseif msg == "info" then
		atInfo()
	elseif msg == "update" then
		atUpdateData()
	else
		ChatFrame1:AddMessage("|cff71C671A4T Slash Commands|r")
		ChatFrame1:AddMessage("|cFF71C671type /A4T followed by:|r")
		ChatFrame1:AddMessage("|cFF71C671  -- toggle to toggle hidden state.|r")
		ChatFrame1:AddMessage("|cFF71C671  -- lock to toggle locking.|r")
		ChatFrame1:AddMessage("|cFF71C671  -- reset to reset settings.|r")
		ChatFrame1:AddMessage("|cFF71C671  -- option to open to the options menu.|r")
		ChatFrame1:AddMessage("|cFF71C671  -- info to get current addon info.|r")
	end
end