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

RaceMessages =
{
	canPosition = false,
	lastLogIdRead = -1,

	showTime = -1,
};
registerWidget("RaceMessages");

local SHOW_TIME = 2;
local FADE_TIME = 0.5;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function RaceMessages:processEvent(logEntry)
	-- RACE FINISHED
	--  00:02:532
	-- new record!! (or show split)
	
	local player = getPlayer();
	if player == nil then return end;

	self.showTime = SHOW_TIME + FADE_TIME;
	
	if logEntry.raceEvent == RACE_EVENT_FINISHANDWASRECORD then
		self.showMessages = {};
		self.showMessages[1] = {};
		self.showMessages[1].message = "RACE FINISHED";
		self.showMessages[2] = {};
		self.showMessages[2].message = FormatTimeToDecimalTime(logEntry.raceTime);
		self.showMessages[3] = {};
		self.showMessages[3].message = "New Personal Record!";

		-- play record sound
		playSound("internal/effects/race/race_finish_record");

	elseif logEntry.raceEvent == RACE_EVENT_FINISH then

		local splitTime = logEntry.raceTime - player.score;
		self.showMessages = {};
		self.showMessages[1] = {};
		self.showMessages[1].message = "RACE FINISHED";
		self.showMessages[2] = {};
		self.showMessages[2].message = FormatTimeToDecimalTime(logEntry.raceTime);
		self.showMessages[3] = {};
		self.showMessages[3].message = "Split: +"..FormatTimeToDecimalTime(splitTime);

		-- play finish sound
		playSound("internal/effects/race/race_finish");
	
	elseif logEntry.raceEvent == RACE_EVENT_START then

		-- only show briefly
		self.showTime = FADE_TIME;
	
		self.showMessages = {};
		self.showMessages[1] = {};
		self.showMessages[1].message = "RACE STARTED";
		
		-- play start sound
		playSound("internal/effects/race/race_start");
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function RaceMessages:draw()
	if not isRaceMode() then return end;

	-- count log messages
	local logCount = 0;
	for k, v in pairs(log) do
		logCount = logCount + 1;
	end
	
	-- read log messages
	for i = 1, logCount do
		local logEntry = log[i];

		-- only read newer entries
		if self.lastLogIdRead < logEntry.id then
			self.lastLogIdRead = logEntry.id;

			-- is race entry?
			if logEntry.type == LOG_TYPE_RACEEVENT then

				-- is this event for the player we're watching?
				local isLocal = logEntry.racePlayerIndex == playerIndexCameraAttachedTo;
				if isLocal then
					-- then yep, we want it
					self:processEvent(logEntry);
				end	
			end
		end
	end

	-- actually draw
    if not shouldShowHUD() then return end;
	if world.gameState ~= GAME_STATE_ACTIVE then return end;
	
	self.showTime = self.showTime - deltaTime;
	if self.showTime > 0 then
	
		local x = 0;
		local y = -140;	-- pull it above cursor
		local alpha = 255;

		if self.showTime < FADE_TIME then
			local f = self.showTime / FADE_TIME;
			alpha = alpha * f;
		end
		
		local fontColor = Color(230, 230, 230, alpha);
		local fontSize = 48;

		for i = 1, 3 do
			if self.showMessages == nil then break end;
			if self.showMessages[i] == nil then break end;

			local text = self.showMessages[i].message;

			nvgFontSize(fontSize);
			nvgFontFace(FONT_HUD);
			nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

			-- bg
			nvgFontBlur(2);
			nvgFillColor(Color(0, 0, 0, alpha));
			nvgText(x, y + 1, text);

			-- foreground
			nvgFontBlur(0);
			nvgFillColor(fontColor);
			nvgText(x, y, text);

			-- adjust for next rows
			y = y + 40;
			fontSize = 36;
			if i == 1 then
				fontColor.r = 180;
				fontColor.g = 180;
				fontColor.b = 230;
			elseif i == 2 then
				fontColor.r = 230;
				fontColor.g = 180;
				fontColor.b = 180;
			end
		end
	end
end
