--------------------------------------------------------------------------------
-- This is an official Reflex script. Do not modify.
--
-- If you wish to customize this widget, please:
--  * clone this file to a new file
--  * rename the widget MyWidget
--  * set this widget to not visible (via options menu)
--  * set your new widget to visible (via options menu)
--
--------------------------------------------------------------------------------

require "base/internal/ui/reflexcore"

ArmorBar =
{
};
registerWidget("ArmorBar");

-- smoothedHealth += (currentHealth - oldHealth) * deltaTime

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ArmorBar:initialize()
	-- load data stored in engine
	self.userData = loadUserData();
	
	-- ensure it has what we need
	CheckSetDefaultValue(self, "userData", "table", {});
	CheckSetDefaultValue(self.userData, "showFrame", "boolean", true);
	CheckSetDefaultValue(self.userData, "showIcon", "boolean", true);
	CheckSetDefaultValue(self.userData, "flatBar", "boolean", false);
    CheckSetDefaultValue(self.userData, "showBar", "boolean", true);
	CheckSetDefaultValue(self.userData, "colorNumber", "boolean", false);
	CheckSetDefaultValue(self.userData, "colorIcon", "boolean", false);
    CheckSetDefaultValue(self.userData, "centerNumber", "boolean", true);

	CheckSetDefaultValue(self.userData, "barAlpha", "number", 160);
	CheckSetDefaultValue(self.userData, "iconAlpha", "number", 32);	
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ArmorBar:drawOptions(x, y, intensity)
	local optargs = {};
	optargs.intensity = intensity;

	local sliderWidth = 200;
	local sliderStart = 140;
	local user = self.userData;

    user.barAlpha = ui2RowSliderEditBox0Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Bar Alpha", user.barAlpha, 0, 255, optargs);
    y = y + 60;
    
    user.iconAlpha = ui2RowSliderEditBox0Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Icon Alpha", user.iconAlpha, 0, 255, optargs);
    y = y + 60;
	
	user.showFrame = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Show frame", user.showFrame, optargs);
	y = y + 60;
	
	user.showIcon = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Show icon", user.showIcon, optargs);
	y = y + 60;
	
	user.flatBar = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Flat bar style", user.flatBar, optargs);
	y = y + 60;

    user.showBar = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Show bar", user.showBar, optargs);
    y = y + 60;

    user.centerNumber = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Center Number", user.centerNumber, optargs);
    y = y + 60;
	
	user.colorNumber = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Color numbers by armor", user.colorNumber, optargs);
	y = y + 60;
	
	user.colorIcon = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Color icon by armor", user.colorIcon, optargs);
	y = y + 60;
	
	saveUserData(user);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ArmorBar:getOptionsHeight()
	return 9*60 - 20; -- debug with: ui_menu_show_widget_properties_height 1
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ArmorBar:draw()

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;
	if isRaceMode() then return end;

	local player = getPlayer();

    -- Options
    local showFrame = self.userData.showFrame;
    local showIcon = self.userData.showIcon;
    local flatBar = self.userData.flatBar;
    local colorNumber = self.userData.colorNumber;
    local centerNumber = self.userData.centerNumber;
    local colorIcon = self.userData.colorIcon;
    local showBar = self.userData.showBar;
    
    -- Size and spacing
    local frameWidth = 460;
    local frameHeight = 55;
    local framePadding = 5;
    local numberSpacing = 100;
    local iconSpacing;

    if showIcon then iconSpacing = 40
    else iconSpacing = 0;
    end
	
    -- Colors
    local frameColor = Color(0,0,0,128);
    local barAlpha = self.userData.barAlpha
    local iconAlpha = self.userData.iconAlpha

    local barColor;
    if player.armorProtection == 0 then barColor = Color(2,167,46, barAlpha) end
    if player.armorProtection == 1 then barColor = Color(245,215,50, barAlpha) end
    if player.armorProtection == 2 then barColor = Color(236,0,0, barAlpha) end

    local barBackgroundColor;    
    if player.armorProtection == 0 then barBackgroundColor = Color(14,53,9, barAlpha) end
    if player.armorProtection == 1 then barBackgroundColor = Color(122,111,50, barAlpha) end
    if player.armorProtection == 2 then barBackgroundColor = Color(141,30,10, barAlpha) end    

    if showBar == false then
        frameWidth = 130
    end

    -- Helpers
    local frameLeft = 0;
    local frameTop = -frameHeight;
    local frameRight = frameWidth;
    local frameBottom = 0;
 
    local barLeft = frameLeft + iconSpacing + numberSpacing

    --if centerNumber == false then
    --    barLeft = barLeft
    --end

    local barTop = frameTop + framePadding;
    local barRight = frameRight - framePadding;
    local barBottom = frameBottom - framePadding;

    local barWidth = frameWidth - numberSpacing - framePadding - iconSpacing;
    local barHeight = frameHeight - (framePadding * 2);

    local fontX = frameLeft + iconSpacing + (framePadding*2);

    if centerNumber then
        local fontCenterX = (barLeft - fontX) / 2;
        fontX = fontX + fontCenterX - framePadding;
    end

    local fontY = -(frameHeight / 2);
    local fontSize = frameHeight * 1.15;
 
    if player.armorProtection == 0 then fillWidth = math.min((barWidth / 100) * player.armor, barWidth);
    elseif player.armorProtection == 1 then fillWidth = math.min((barWidth / 150) * player.armor, barWidth);
    elseif player.armorProtection == 2 then fillWidth = (barWidth / 200) * player.armor;
    end

    -- Frame
    if showFrame then

        nvgBeginPath();
        nvgRoundedRect(frameRight, frameBottom, -frameWidth, -frameHeight, 5);
        nvgFillColor(frameColor); 
        nvgFill();
    end

     -- Show Bar
    if showBar then

        -- Background
        nvgBeginPath();
        nvgRect(barRight, barBottom , -barWidth, -barHeight);
        nvgFillColor(barBackgroundColor); 
        nvgFill();
        
        -- Bar
        nvgBeginPath();
        nvgRect(barLeft, barBottom, fillWidth, -barHeight);
    	nvgFillColor(barColor); 
    	nvgFill();
        
        -- Shading
        if flatBar == false then
        
            nvgBeginPath();
            nvgRect(barLeft, barTop, barWidth, barHeight);
            nvgFillLinearGradient(barLeft, barTop, barLeft, barBottom, Color(255,255,255,30), Color(255,255,255,0))
            nvgFill();
        
            nvgBeginPath();
            nvgMoveTo(barLeft, barTop);
            nvgLineTo(barRight, barTop);
            nvgStrokeWidth(1)
            nvgStrokeColor(Color(255,255,255,60));
            nvgStroke();
        
        end
    end
          
    -- Draw numbers
    local fontColor;
    
    if colorNumber then fontColor = barColor
    else fontColor = Color(230,230,230);
    end
    
    nvgFontSize(fontSize);
	nvgFontFace(FONT_HUD);
    if centerNumber then
        nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
    else
        nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
    end
    
    if not colorNumber then -- Don't glow if the numbers are colored (looks crappy)
    
	    if player.armor <= 30 then
        nvgFontBlur(5);
        nvgFillColor(Color(64, 64, 200));
	    nvgText(fontX, fontY, player.armor);
        end
	       
    end
    
	nvgFontBlur(0);
	nvgFillColor(fontColor);
	nvgText(fontX, fontY, player.armor);
    
    -- Draw icon
    
    if showIcon then
        local iconX = (iconSpacing / 2) + framePadding;
        local iconY = -(frameHeight / 2);
        local iconSize = (barHeight / 2) * 0.9;
        local iconColor;
    
        if colorIcon then iconColor = barColor
        else iconColor = Color(230,230,230, iconAlpha);
        end
    
		nvgFillColor(iconColor);
        nvgSvg("internal/ui/icons/armor", iconX, iconY, iconSize);
    end

end
