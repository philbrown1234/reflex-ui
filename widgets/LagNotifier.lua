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
require "base/internal/ui/gamestrings"

LagNotifier =
{
	canPosition = true,
	lastTickSeconds = -1;
};
registerWidget("LagNotifier");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function drawPlayerText(text, textColor, x, y)
	-- bg
	nvgFontBlur(2);
	nvgFillColor(Color(0, 0, 0, 255));
	nvgText(x, y + 1, text);

	-- foreground
	nvgFontBlur(0);
	nvgFillColor(textColor);
	nvgText(x, y, text);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LagNotifier:draw()
	if showLagIcon then
		local iconX = -32;
		local iconY = 32;
		local iconRadius = 32;
	
		local textX = -iconRadius*2-10;
		local textY = iconRadius;
		local text = "Connection Interrupted";

		-- icon
		nvgFillColor(Color(255,255,255));
		nvgSvg("internal/ui/icons/lag", iconX, iconY, iconRadius);

		-- text	
		nvgFontSize(32);
		nvgFontFace(FONT_HUD);
		nvgTextAlign(NVG_ALIGN_RIGHT, NVG_ALIGN_MIDDLE);
    
		nvgFontBlur(2);
		nvgFillColor(Color(0, 0, 0));
		nvgText(textX, textY, text);

		nvgFontBlur(0);
		nvgFillColor(Color(255, 255, 255));
		nvgText(textX, textY, text);
	end
end
