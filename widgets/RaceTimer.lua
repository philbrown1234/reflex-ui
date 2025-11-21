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

RaceTimer =
{
	alpha = 0;
};
registerWidget("RaceTimer");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function RaceTimer:draw()

    if not shouldShowHUD() then return end;
	if not isRaceMode() then return end;

	local player = getPlayer();
	if not player then return end;

	-- fade in/out
	if player.raceActive then 
		self.alpha = math.min(self.alpha + deltaTime*5, 1);
	else
		self.alpha = math.max(self.alpha - deltaTime*2, 0);
	end;
	if self.alpha <= 0 then return end;

    local frameColor = Color(0,0,0,self.alpha*128);
    local frameWidth = 180;
    local frameHeight = 35;

    nvgBeginPath();
    nvgRoundedRect(-frameWidth/2, -frameHeight/2, frameWidth, frameHeight, 5);
    nvgFillColor(frameColor); 
    nvgFill();

	-- grab either current time or last time (if we've not active -- we finished already!)
	local time = player.raceTimeCurrent;
	if not player.raceActive then
		time = player.raceTimePrevious;
	end

	local text = FormatTimeToDecimalTime(time);
	local fontColor = Color(230, 230, 230, self.alpha*255);
    local fontSize = frameHeight * 1.15;

	-- if we're slower than best time, go red
	if time > player.score and player.score ~= 0 then
		fontColor.g = 0;
		fontColor.b = 0;
	end
	
    nvgFontSize(fontSize);
	nvgFontFace(FONT_TEXT2_BOLD);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

	nvgFontBlur(0);
	nvgFillColor(fontColor);
	nvgText(0, -1, text);
end
