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

Crosshairs =
{
	canPosition = false;

	time = 0;
	updateTime = 0;
	lastTotalDamageDone = 0;

	-- user data, we'll save this into engine so it's persistent across loads
	userData = {};
};
registerWidget("Crosshairs");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Crosshairs:initialize()
	-- load data stored in engine
	self.userData = loadUserData();
	
	-- ensure it has what we need
	CheckSetDefaultValue(self, "userData", "table", {});
	CheckSetDefaultValue(self.userData, "colorFillByHealth", "boolean", false);
	CheckSetDefaultValue(self.userData, "colorStrokeByHealth", "boolean", false);
	CheckSetDefaultValue(self.userData, "crosshairSize", "number", 16);
	CheckSetDefaultValue(self.userData, "crosshairWeight", "number", 3);
	CheckSetDefaultValue(self.userData, "crosshairStrokeWeight", "number", 3);

	CheckSetDefaultValue(self.userData, "crosshairHit", "boolean", true);
	CheckSetDefaultValue(self.userData, "crosshairHitIntensity", "number", 1.0);
	CheckSetDefaultValue(self.userData, "crosshairHitDuration", "number", 0.2);
	CheckSetDefaultValue(self.userData, "crosshairHitSize", "number", 16);
	CheckSetDefaultValue(self.userData, "crosshairHitSizeEnd", "number", 24);

	widgetCreateConsoleVariable("type", "int", 1);
	widgetCreateConsoleVariable("r", "int", 255);
	widgetCreateConsoleVariable("g", "int", 255);
	widgetCreateConsoleVariable("b", "int", 255);

	widgetCreateConsoleVariable("typeHit", "int", 1);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Crosshairs:finalize()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Crosshairs:draw(forceDraw)
	-- player health, updated if we actually have a player
	local playerHealth = 100;
	
	if not forceDraw then
		-- no player => no crosshair
		local player = getPlayer();
		if player == nil then return end;
		playerHealth = player.health;
		
		-- menu => no crosshair
		if isInMenu() then return end;

		-- editor => no crosshair
		if player.state == PLAYER_STATE_EDITOR then
			return;
		end

		-- spectator => no crosshair
		if player.state == PLAYER_STATE_SPECTATOR then
			return;
		end

		-- dead => no crosshair
		if player.health <= 0 then
			return;
		end
		
		-- menu replay background => no crosshair
		if replayName == "menu" then
			return false;
		end

		if world.gameState == GAME_STATE_GAMEOVER then
			return false;
		end
	end
    
    -- Colors
    local crosshairFillColor = Color(255,255,255,255);
    local crosshairStrokeColor = Color(0,0,0,255);
	crosshairFillColor.r = widgetGetConsoleVariable("r");
	crosshairFillColor.g = widgetGetConsoleVariable("g");
	crosshairFillColor.b = widgetGetConsoleVariable("b");

	local crosshairHitFillColor = Color(255,190,190,255);
    local crosshairHitStrokeColor = Color(0,0,0,255);

	-- pull out of self
    local colorFillByHealth = self.userData.colorFillByHealth;
    local colorStrokeByHealth = self.userData.colorStrokeByHealth;
    local crosshairSize = self.userData.crosshairSize;
    local crosshairWeight = self.userData.crosshairWeight;
    local crosshairStrokeWeight = self.userData.crosshairStrokeWeight;
    local crosshairHitIntensity = self.userData.crosshairHitIntensity;
    local crosshairHitSize = self.userData.crosshairHitSize;
    local crosshairHitSizeEnd = self.userData.crosshairHitSize;

    if colorFillByHealth then
        if playerHealth > 100 then crosshairFillColor = Color(16,116,217, barAlpha) end
        if playerHealth <= 100 then crosshairFillColor = Color(2,167,46, barAlpha) end
        if playerHealth <= 80 then crosshairFillColor = Color(255,176,14, barAlpha) end
        if playerHealth <= 30 then crosshairFillColor = Color(236,0,0, barAlpha) end
    end

    if colorStrokeByHealth then
        if playerHealth > 100 then crosshairStrokeColor = Color(16,116,217, barAlpha) end
        if playerHealth <= 100 then crosshairStrokeColor = Color(2,167,46, barAlpha) end
        if playerHealth <= 80 then crosshairStrokeColor = Color(255,176,14, barAlpha) end
        if playerHealth <= 30 then crosshairStrokeColor = Color(236,0,0, barAlpha) end
    end

    -- Helpers
    local crosshairHalfSize = crosshairSize / 2;
    local crosshairHalfWeight = crosshairWeight / 2;
	local crosshairType = widgetGetConsoleVariable("type");
	local crosshairHitHalfSize = crosshairHitSize / 2;
	local crosshairHitType = widgetGetConsoleVariable("typeHit");

    -- Crosshair 1
    if crosshairType == 1 then
        nvgBeginPath();
        nvgRect(-crosshairHalfSize, -crosshairHalfWeight, crosshairSize, crosshairWeight) -- horizontal
        nvgRect(-crosshairHalfWeight, -crosshairHalfSize, crosshairWeight, crosshairSize) -- vertical
        nvgStrokeColor(crosshairStrokeColor);
        nvgStrokeWidth(crosshairStrokeWeight);
        nvgStroke();
        nvgFillColor(crosshairFillColor); 
        nvgFill();
    end

    -- Crosshair 2
    if crosshairType == 2 then
        local innerSpace = 0.65;
        nvgBeginPath();
        nvgRect(-crosshairHalfSize, -crosshairHalfWeight, crosshairHalfSize * innerSpace, crosshairWeight) -- left
        nvgRect(-crosshairHalfWeight, -crosshairHalfSize, crosshairWeight, crosshairHalfSize * innerSpace) -- top
        nvgRect(crosshairHalfSize, crosshairHalfWeight, -crosshairHalfSize * innerSpace, -crosshairWeight) -- right
        nvgRect(crosshairHalfWeight, crosshairHalfSize, -crosshairWeight, -crosshairHalfSize * innerSpace) -- bottom
        nvgStrokeColor(crosshairStrokeColor);
        nvgStrokeWidth(crosshairStrokeWeight);
        nvgStroke();
        nvgFillColor(crosshairFillColor); 
        nvgFill();
    end

    -- Crosshair 3
    if crosshairType == 3 then
        local innerSpace = 0.65;
        nvgBeginPath();
        nvgRect(-crosshairHalfSize, -crosshairHalfWeight, crosshairHalfSize * innerSpace, crosshairWeight) -- left
        nvgRect(-crosshairHalfWeight, -crosshairHalfSize, crosshairWeight, crosshairHalfSize * innerSpace) -- top
        nvgRect(crosshairHalfSize, crosshairHalfWeight, -crosshairHalfSize * innerSpace, -crosshairWeight) -- right
        nvgRect(crosshairHalfWeight, crosshairHalfSize, -crosshairWeight, -crosshairHalfSize * innerSpace) -- bottom
        nvgRect(-crosshairHalfWeight, -crosshairHalfWeight, crosshairWeight, crosshairWeight) -- dot
        nvgStrokeColor(crosshairStrokeColor);
        nvgStrokeWidth(crosshairStrokeWeight);
        nvgStroke();
        nvgFillColor(crosshairFillColor); 
        nvgFill();
    end

    -- Crosshair 4
    if crosshairType == 4 then
        nvgBeginPath();
        nvgCircle(0, 0, crosshairSize / 8)
        nvgStrokeColor(crosshairStrokeColor);
        nvgStrokeWidth(crosshairStrokeWeight);
        nvgStroke();
        nvgFillColor(crosshairFillColor); 
        nvgFill();
    end

    -- Crosshair 5
    if crosshairType == 5 then
        nvgBeginPath();
        nvgCircle(0, 0, crosshairSize / 4)
        nvgStrokeColor(crosshairFillColor);
        nvgStrokeWidth(crosshairStrokeWeight / 2);
        nvgStroke();
    end

    -- Crosshair 6-16
    if crosshairType >= 6 and crosshairType <= 16 then
        nvgFillColor(crosshairFillColor);
        nvgSvg("internal/ui/crosshairs/crosshair" .. crosshairType, 0, 0, crosshairSize);
    end

    -- ///////////////////////////////////////////////////////////
    -- hit crosshair

    -- Crosshair 1
    local localPlayer = getLocalPlayer();
    local damageDone = localPlayer.stats.totalDamageDone;

	if not localPlayer then return end;

    crosshairHitFillColor.a = crosshairHitIntensity * 255;

	-- damage done is nil when starting, can't compare with nil type
    -- set to 0
    if (localPlayer.stats.totalDamageDone == nil) then
    	damageDone = 0;
    end

    -- scale and fade out over duration
    if (damageDone > self.lastTotalDamageDone) then
    	self.updateTime = self.time + self.userData.crosshairHitDuration;
    end
    self.lastTotalDamageDone = damageDone;

    local lifePercent;
    if (self.updateTime > self.time) then
    	lifePercent = ((self.updateTime - self.time) / self.userData.crosshairHitDuration);
		crosshairHitSize = lerp(self.userData.crosshairHitSizeEnd, self.userData.crosshairHitSize, lifePercent);
	else
		lifePercent = 0
		crosshairHitSize = self.userData.crosshairHitSize;
    end

    crosshairHitFillColor.a = crosshairHitFillColor.a * lifePercent;

    self.time = self.time + deltaTime;

    if (forceDraw == true) then
    	lifePercent = 1
    	crosshairHitFillColor.a = crosshairHitIntensity * 255;
    	crosshairHitSize = self.userData.crosshairHitSize;
    end

    if crosshairHitType >= 1 and crosshairHitType <= 7 then
        nvgFillColor(crosshairHitFillColor);
        nvgSvg("internal/ui/crosshairs/crosshairHit" .. crosshairHitType, 0, 0, crosshairHitSize);
    end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Crosshairs:drawOptions(x, y, intensity)
	local optargs = {};
	optargs.intensity = intensity;

	local sliderWidth = 200;
	local sliderStart = 140;

	ui2Label("Preview:", x, y);

	nvgSave();
	nvgTranslate(x + WIDGET_PROPERTIES_COL_INDENT + 40, y + 40);
	self:draw(true, x + WIDGET_PROPERTIES_COL_INDENT + 40, y + 40);
	nvgRestore();
	y = y + 120;

	local user = self.userData;
	local crosshairType = widgetGetConsoleVariable("type");
	
	user.colorFillByHealth = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Color Fill By Health", user.colorFillByHealth, optargs);
	y = y + 60;
	
	user.colorStrokeByHealth = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Color Stroke By Health", user.colorStrokeByHealth, optargs);
	y = y + 60;
	
	local newType = ui2RowSliderEditBox0Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Type", crosshairType, 1, 16, optargs);
	if newType ~= crosshairType then
		widgetSetConsoleVariable("type", newType);
	end
	y = y + 60;
	
	user.crosshairSize = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Size", user.crosshairSize, 1, 90, optargs);
	y = y + 60;
	
	user.crosshairWeight = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Weight", user.crosshairWeight, 1, 10, optargs);
	y = y + 60;
	
	user.crosshairStrokeWeight = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Stroke Weight", user.crosshairStrokeWeight, 1, 10, optargs);
	y = y + 60;

	y = y + 60;

	local crosshairHitType = widgetGetConsoleVariable("typeHit");

	local newHitType = ui2RowSliderEditBox0Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Hit Type", crosshairHitType, 1, 7, optargs);
	if newHitType ~= crosshairHitType then
		widgetSetConsoleVariable("typeHit", newHitType);
	end
	y = y + 60;

	user.crosshairHitIntensity = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Intensity", user.crosshairHitIntensity, 0, 1.0, optargs);
	y = y + 60;

	user.crosshairHitDuration = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Duration", user.crosshairHitDuration, 0, 1.0, optargs);
	y = y + 60;
	
	user.crosshairHitSize = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Size", user.crosshairHitSize, 1, 90, optargs);
	y = y + 60;

	user.crosshairHitSizeEnd = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Size End", user.crosshairHitSizeEnd, 1, 90, optargs);
	y = y + 60;

	saveUserData(user);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Crosshairs:getOptionsHeight()
	return 840; -- debug with: ui_menu_show_widget_properties_height 1
end
