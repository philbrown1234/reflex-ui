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

HealthBar =
{
	megaTime = 0,
	megaIntensity = 0
};
registerWidget("HealthBar");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function HealthBar:initialize()
    -- load data stored in engine
    self.userData = loadUserData();
    
    -- ensure it has what we need
    CheckSetDefaultValue(self, "userData", "table", {});
    CheckSetDefaultValue(self.userData, "showFrame", "boolean", true);
    CheckSetDefaultValue(self.userData, "showIcon", "boolean", true);
    CheckSetDefaultValue(self.userData, "flatBar", "boolean", false);
    CheckSetDefaultValue(self.userData, "showBar", "boolean", true);
    CheckSetDefaultValue(self.userData, "barAlpha", "number", 160);
    CheckSetDefaultValue(self.userData, "iconAlpha", "number", 32); 
    CheckSetDefaultValue(self.userData, "centerNumber", "boolean", true);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function HealthBar:drawOptions(x, y, intensity)
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

    user.colorNumber = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Color numbers by health", user.colorNumber, optargs);
    y = y + 60;
    
    user.colorIcon = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Color icon by health", user.colorIcon, optargs);
    y = y + 60;

    saveUserData(user);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function HealthBar:getOptionsHeight()
    return 9*60 - 20; -- debug with: ui_menu_show_widget_properties_height 1
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function HealthBar:draw()
 
    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;
	if isRaceMode() then return end;

    -- Find player 
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
    if player.health > 100 then barColor = Color(16,116,217, barAlpha) end
    if player.health <= 100 then barColor = Color(2,167,46, barAlpha) end
    if player.health <= 80 then barColor = Color(255,176,14, barAlpha) end
    if player.health <= 30 then barColor = Color(236,0,0, barAlpha) end

    local barBackgroundColor;    
    if player.health > 100 then barBackgroundColor = Color(10,68,127, barAlpha) end
    if player.health <= 100 then barBackgroundColor = Color(14,53,9, barAlpha) end
    if player.health <= 80 then barBackgroundColor = Color(105,67,4, barAlpha) end
    if player.health <= 30 then barBackgroundColor = Color(141,30,10, barAlpha) end    

    if showBar == false then
        frameWidth = 130
    end

    -- Helpers
    local frameLeft = -frameWidth;
    local frameTop = -frameHeight;
    local frameRight = 0;
    local frameBottom = 0;
 
    local barLeft = frameLeft + framePadding;
    local barTop = frameTop + framePadding;
    local barRight = frameRight - numberSpacing - iconSpacing;

    local barBottom = frameBottom - framePadding;

    local barWidth = frameWidth - numberSpacing - framePadding - iconSpacing;
    local barHeight = frameHeight - (framePadding * 2);

    local fontX = frameRight - iconSpacing - (framePadding*2);

    if centerNumber then
        local fontCenterX = (barRight - fontX) / 2;
        fontX = fontX + fontCenterX + framePadding;
    end

    local fontY = -(frameHeight / 2);
    local fontSize = frameHeight * 1.15;

    local fillWidth;
    if player.health > 100 then fillWidth = (barWidth / 100) * (player.health - 100);
    else fillWidth = (barWidth / 100) * player.health; end

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
        nvgRect(barRight, barBottom, -fillWidth, -barHeight);
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
        nvgTextAlign(NVG_ALIGN_RIGHT, NVG_ALIGN_MIDDLE);
    end
    
    if not colorNumber then -- Don't glow if the numbers are colored (looks crappy)
		if player.health > 100 then
			nvgFontBlur(5);
			nvgFillColor(Color(64, 64, 200));
			nvgText(fontX, fontY, player.health);
		elseif player.health <= 30 then
			nvgFontBlur(10);
			nvgFillColor(Color(200, 64, 64));
			nvgText(fontX, fontY, player.health);
		end
    end
    
    nvgFontBlur(0);
    nvgFillColor(fontColor);
    nvgText(fontX, fontY, player.health);

    -- Draw icon
    if showIcon then
        local iconX = -(iconSpacing / 2) - framePadding;
        local iconY = -(frameHeight / 2);
        local iconSize = (barHeight / 2) * 0.9;
        local iconColor;

        if colorIcon then iconColor = barColor
        else iconColor = Color(230,230,230, iconAlpha);
        end

		nvgFillColor(iconColor);
        nvgSvg("internal/ui/icons/health", iconX, iconY, iconSize)

		-- mega glow behind health icon
		if player.hasMega then
			self.megaIntensity = math.min(self.megaIntensity + deltaTime*2, 1);
		else
			self.megaIntensity = math.max(self.megaIntensity - deltaTime, 0);
		end
		if self.megaIntensity > 0 then
			self.megaTime = self.megaTime + deltaTime*6;

			local intensity = 210 + math.sin(self.megaTime) * 45;
			intensity = intensity * self.megaIntensity;
			
			nvgBeginPath();
			nvgCircle(iconX, iconY, 31);
			nvgFillRadialGradient(
				iconX, iconY, 16, 29, 
				Color(25, 120, 255, intensity), 
				Color(0, 0, 0, 0));
			nvgFill();
			nvgBeginPath();
			nvgCircle(iconX, iconY, 20);
			nvgFillRadialGradient(
				iconX, iconY, 0, 20, 
				Color(25, 220, 255, intensity), 
				Color(25, 120, 255, intensity));
			nvgFill();

			nvgBeginPath();
			nvgRoundedRect(iconX-13, iconY-4, 26, 8, 1);
			nvgRoundedRect(iconX-4, iconY-13, 8, 26, 1);
			nvgFillColor(Color(232,232,232, 255*self.megaIntensity));
			nvgFill();
		end

		-- -- mega pulse on HP
		-- local barLeftMoving = barRight - ((self.megaTime/(3.1415*2)) % 1) * barWidth;
		-- 
		-- nvgSave();
		-- nvgIntersectScissor(barRight - fillWidth, barTop, fillWidth, barHeight);
        -- nvgBeginPath();
	    -- nvgRect(barLeftMoving, barTop, barWidth, barHeight);
        -- nvgFillLinearGradient(barLeftMoving, barTop, barLeftMoving+barWidth, barBottom, Color(25, 120, 255, 255), Color(25, 120, 255,0));
        -- nvgFill();
		-- nvgRestore();
    end
end
