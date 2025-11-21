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

MapAutoSave =
{
	-- Settings
	timeAccumulated = 0;
	nextIndex = 1
};
registerWidget("MapAutoSave");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function MapAutoSave:initialize()
	-- load data stored in engine
	self.userData = loadUserData();
	
	-- ensure it has what we need
	CheckSetDefaultValue(self, "userData", "table", {});
	CheckSetDefaultValue(self.userData, "saveInterval", "number", 5);
	CheckSetDefaultValue(self.userData, "saveIncrements", "number", 5);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function MapAutoSave:drawOptions(x, y, intensity)
	local optargs = {};
	optargs.intensity = intensity;

	local user = self.userData;

    user.saveInterval = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Save Interval", user.saveInterval, 1, 10, optargs);
    ui2Tooltip("Minutes between auto-saves.", x+WIDGET_PROPERTIES_COL_WIDTH, y, optargs);
    y = y + 60;

    user.saveIncrements = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Number of Increments", user.saveIncrements, 1, 10, optargs);
    y = y + 60;

	saveUserData(user);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function MapAutoSave:draw()

    local player = getPlayer();


    if player.state ~= PLAYER_STATE_EDITOR then
    	return
    end

    -- Options
    local saveInterval = self.userData.saveInterval;
    local saveIncrements = self.userData.saveIncrements;
    	

    -- Log save countdown

	local countdown = ((saveInterval * 60) - self.timeAccumulated) * 1000;

	nvgFontSize(30);
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	nvgFontBlur(0);
	nvgFontFace(FONT_HUD);
    nvgFillColor(Color(255,255,255,255));
    if ((countdown) <= 5000) then
		nvgText(viewport.width/2 - 225, viewport.height/2 - 50, "Auto-save in " .. FormatTimeToDecimalTime(countdown));
	end

	-- Save at X Increments

    self.timeAccumulated = self.timeAccumulated + deltaTimeRaw

	if self.timeAccumulated >= saveInterval * 60 then
		consolePerformCommand("savemap " .. world.mapName .. "_" .. self.nextIndex);
		consolePerformCommand("say Map Auto-saved: " .. world.mapName .. "_" .. self.nextIndex.. ".map");
		self.timeAccumulated = 0
		self.nextIndex = self.nextIndex + 1
		if self.nextIndex > saveIncrements then
			self.nextIndex = 1
		end
	end

end