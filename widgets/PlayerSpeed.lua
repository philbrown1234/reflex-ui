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

PlayerSpeed =
{
};
registerWidget("PlayerSpeed");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function PlayerSpeed:draw()

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

    -- Find player 
    local player = getPlayer()
    local speed = math.ceil(player.speed)

	local fontSize = 42;
    local frameX = 0;
	local frameY = 0;
    local frameWidth = 140
    local frameHeight = fontSize

    -- Colors
    local frameColor = Color(0,0,0,0);
    local textColor = Color(255,255,255,255);

    -- Background
    nvgBeginPath();
    nvgRect(-frameWidth/2, 0, frameWidth, frameHeight);
    nvgFillColor(frameColor);
    nvgFill();

	-- Text
    nvgFontSize(fontSize);
	nvgFontFace("TitilliumWeb-Bold");
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);
	nvgFontBlur(0);
	nvgFillColor(textColor);
	nvgText(0, 0, speed .. "ups");

end
