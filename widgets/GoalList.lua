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

GoalList =
{
};
registerWidget("GoalList");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function SortBySortIndex(a, b)
	return a.sortIndex < b.sortIndex;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function GoalList:draw()
	local width = 300;
	local x = 0;
	local y = 0;
	local messageTime = 4;
	local optargs = {};
	local intensity = 1;

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

	-- count goals
	local goalCount = 0;
	for k, v in pairs(goals) do
		goalCount = goalCount + 1;
	end

	-- no goals => nothing to draw
	if goalCount == 0 then return end;

	-- gather tokens
	local tokens = {};
	for k, pickup in pairs(pickupTimers) do
		if pickup.type == PICKUP_TYPE_TRAINING_TOKEN then
			tokens[pickup.tokenIndex] = {};
			tokens[pickup.tokenIndex].achieved = not pickup.isActive;
		end
	end

	-- count tokens
	-- (we do this separately to gather tokens to ensure tokens with same tokenIndex ARE ignored - as that's how the leaderboard recording will work - and this will help visualise to the user there is a problem)
	local tokensTotal = 0;
	for k, v in pairs(tokens) do
		tokensTotal = tokensTotal + 1;
	end

	-- establish height
	local height = 54 + 32 * goalCount;
	
    -- Background
    local frameColor = Color(0,0,0,128);
    nvgBeginPath();
    nvgRoundedRect(x, y, width, height, 5);
    nvgFillColor(frameColor); 
    nvgFill();

	-- Sort
	table.sort(goals, SortBySortIndex);

	-- title
	local ix = x + 10;
	local iy = y + 2;
	nvgFontFace(FONT_TEXT2_BOLD);
	nvgFontSize(26);
	optargs.nofont = true;
	ui2Label(world.mapTitle, ix, iy, optargs);

	-- tokens
	local ir = 13;
	local istride = 32;
	local ix = x + width + 10 - istride * tokensTotal;
	local iy = y + 20;
	for k, token in pairs(tokens) do
		local achieved = token.achieved;
		nvgFillColor(achieved and Color(232,232,232,255) or Color(70,70,70,255));
		nvgSvg("internal/items/training_token/training_token", ix, iy, ir);
		ix = ix + istride;
	end
	
	-- goals
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	nvgFontFace(FONT_TEXT2);
	nvgFontSize(26);
	local ix = x + 10;
	local iy = y + 50;
	local ih = 24;
	for k, goal in ipairs(goals) do
		local hoverAmount = 0;
		local enabled = true;
	
		nvgBeginPath();
		nvgRect(ix, iy, ih, ih);
		nvgFillColor(ui2FormatColor(UI2_COLTYPE_BACKGROUND, intensity, hoverAmount, enabled));
		nvgFill();

		if goal.achieved then
			local ir = 8;
			nvgFillColor(ui2FormatColor(UI2_COLTYPE_TEXT, intensity, hoverAmount, enabled));
			nvgSvg("internal/ui/icons/checkBoxTick", ix+ih/2, iy+ih/2, ir);
		end

		nvgFillColor(ui2FormatColor(UI2_COLTYPE_TEXT, intensity, hoverAmount, enabled));
		nvgText(ix+32, iy + ih*0.5-1, goal.message);
		iy = iy + 32;
	end

	-- -- time to play sound?
	-- if message.timeSinceMessage < self.timeSinceLastMessage and message.timeSinceMessage < 1 then
	-- 	-- todo: proper sound
	-- 	playSound("internal/ui/sounds/notifyDrop");
	-- end
	-- self.timeSinceLastMessage = message.timeSinceMessage;
	-- 
    -- -- Early out if HUD shouldn't be shown.
    -- if not shouldShowHUD() then return end;
	-- 
	-- -- message expired?
	-- if message.timeSinceMessage > messageTime then return end;
	-- 
	-- -- intensity
	-- local intensity = 0;
	-- intensity = LerpWithFunc(EaseIn, message.timeSinceMessage, intensity, 0, .15, 0, 1);
	-- intensity = LerpWithFunc(EaseInOut, message.timeSinceMessage, intensity, 2, 4, 1, 0);
	-- 
	-- nvgFontSize(48);
    -- nvgFontFace("titilliumWeb-regular");
	-- nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
	-- 
	-- local col = Color(232,232,232,255*intensity);
	-- local text = message.text;
	-- 
	-- nvgFontBlur(5);
    -- nvgFillColor(Color(64, 64, 64, 255*intensity));
	-- nvgText(x, y, text);
	-- 
	-- nvgFontBlur(0);
    -- nvgFillColor(Color(232,232,232,255*intensity));
	-- nvgText(x, y, text);
end
