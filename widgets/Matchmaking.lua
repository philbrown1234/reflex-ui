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

Matchmaking =
{
	zIndex = -10
};

require "base/internal/ui/menus/Menu"

registerWidget("Matchmaking");

-------------------------------------------------------------------------
-------------------------------------------------------------------------
local function DrawMatchmakingHeader(x, y, w, h, header, desc)
	local t = FormatTime(matchmakingTimeSearching * 1000)
	local textHeader = string.format(header .. " - %d:%02d", t.minutes, t.seconds)

	nvgSave()

	nvgFontSize(32);
	nvgFontFace(FONT_TEXT2_BOLD);
	local widthHeader = nvgTextWidth(textHeader)
	
	nvgFontSize(26);
	nvgFontFace(FONT_TEXT2);
	local widthDesc = nvgTextWidth(desc)
	local calcWidth = math.max(widthHeader, widthDesc) + 70 + 30
	x = x + w - calcWidth
	w = calcWidth

	local intensity = 1.0
	local hoverAmount = 0
	local colText = ui2FormatColor(UI2_COLTYPE_TEXT, intensity, hoverAmount, true);

	local bgIntensity = 0
	local st = matchmakingTimeSearching * 8
	if st < 3*math.pi then
		bgIntensity = math.abs(math.sin(st))
		bgIntensity = bgIntensity * bgIntensity
	end
	local bc = bgIntensity * 255

	nvgBeginPath();
	nvgRoundedRect(x, y, w, h, 0);
	nvgFillColor(Color(bc,bc,bc,65));
	nvgFill();

	uiDrawMatchmakingIcon(x + 35, y + h/2, colText)

	nvgIntersectScissor(x, y, w, h)
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	
	nvgFontBlur(0);
	nvgFontSize(32);
	nvgFontFace(FONT_TEXT2_BOLD);
	nvgFillColor(colText);
	nvgText(x + 70, y + h/4 + 3, textHeader)

	nvgFontSize(26);
	nvgFontFace(FONT_TEXT2);
	nvgFillColor(colText);
	nvgText(x + 70, y + h*3/4 -3, desc);

	nvgRestore();
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function Matchmaking:initialize()
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function Matchmaking:draw()	
	local w = 340
	local x = -w
	local y = 0
	local h = 60
	local pad = 10
	local ix = x + pad
	local iy = y + pad

    -- Early out if HUD shouldn't be shown.
	local optargs = {};
	optargs.showWhenDead = true;
	optargs.showWhenSpec = true;
	optargs.showInGameOver = true;
    if not shouldShowHUD(optargs) then return end;

	-- hide?
    if	loading.loadScreenVisible or
		consoleGetVariable("cl_show_hud") == 0 then
		return;
	end

	if matchmaking.state == MATCHMAKING_SEARCHINGFOROPPONENTS then

		local text = "In warmup server, prepare yourself!"
		if not world.isMatchmakingLobby then
			text = "Searching, Prepare yourself!"
		end
		
		DrawMatchmakingHeader(x, y, w, h, "FINDING MATCH", text)
		
	elseif matchmaking.state == MATCHMAKING_FOUNDOPPONENTS then
		
		DrawMatchmakingHeader(x, y, w, h, "FOUND MATCH", "Awaiting confirmation")
		
	elseif matchmaking.state == MATCHMAKING_VOTINGMAP then
		
		DrawMatchmakingHeader(x, y, w, h, "FOUND MATCH", "Performing Map Selection")
		
	elseif matchmaking.state == MATCHMAKING_FINDINGSERVER then
		
		DrawMatchmakingHeader(x, y, w, h, "FOUND MATCH", "Preparing Server")

	elseif matchmaking.state == MATCHMAKING_LOSTCONNECTIONATTEMPTINGRECONNECT then
		
		DrawMatchmakingHeader(x, y, w, h, "LOST CONNECTION", "Attemping to reconnect")

	elseif matchmaking.state == MATCHMAKING_BANNED then
		
		DrawMatchmakingHeader(x, y, w, h, "FINDING MATCH", string.format("Waiting ~%d minute%s due to time penalty", matchmaking.bannedMinutes, matchmaking.bannedMinutes ~= 1 and "s" or ""))

	end
end
