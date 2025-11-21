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

RaceRecords =
{
	lastLogIdRead = -1;

	bestTimes = {};
	bestTimeCount = 0;

	mapName = nil;

	playerTracking = nil;
};
registerWidget("RaceRecords");

local RECORD_COUNT_TO_RECORD = 5;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function DrawItem(x, y, text, col) 
    local recordWidth = 160;
    local recordHeight = 30;

    -- background
    nvgBeginPath();
    nvgRect(x, y, recordWidth, recordHeight);
    nvgFillColor(Color(0,0,0,128)); 
    nvgFill();
	
    nvgFontSize(30);
    nvgFontFace(FONT_TEXT2_BOLD);
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);

	nvgFontBlur(0);
	nvgFillColor(col);
	nvgText(x+5, y + recordHeight/2, text);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function RaceRecords:draw()

	if clientGameState ~= STATE_CONNECTED then 
		self.bestTimeCount = 0;
		self.mapName = nil;
	end

    if not shouldShowHUD() then return end;
	if not isRaceMode() then return end;

	local player = getPlayer();
	if not player then return end;

	-- clear times when map ends
	if world.gameState == GAME_STATE_WARMUP then
		self.bestTimeCount = 0;
	end

	-- clear times when map changes
	-- (bit hacky, but it'll do us for now)
	if world.mapName ~= self.mapName then
		self.bestTimeCount = 0;
		self.mapName = world.mapName;
	end

	-- TODO: track table for each player, rather than clearing times if we change who we're watching
	if self.playerTracking ~= playerIndexCameraAttachedTo then
		self.playerTracking = playerIndexCameraAttachedTo;
		self.bestTimeCount = 0;
	end

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
			
			-- race message?
			if logEntry.type == LOG_TYPE_RACEEVENT then

				-- racer we're watching?
				if logEntry.racePlayerIndex == playerIndexCameraAttachedTo then

					-- race finished? record new time
					if (logEntry.raceEvent == RACE_EVENT_FINISH) or (logEntry.raceEvent == RACE_EVENT_FINISHANDWASRECORD) then

						-- record new time player.raceTimePrevious
						self.bestTimeCount = self.bestTimeCount + 1;
						self.bestTimes[self.bestTimeCount] = player.raceTimePrevious;

						-- sort race times
						table.sort(self.bestTimes);

						-- purge oldest (if we had over 5)
						self.bestTimeCount = math.min(self.bestTimeCount, RECORD_COUNT_TO_RECORD);
					end

				end
			end
		end
	end
	
    local recordStride = 35;

	local x = 0;
	local y = 0 - recordStride * (RECORD_COUNT_TO_RECORD + 1)/2;
		
	DrawItem(x, y, "Personal Records", Color(230, 230, 230));

	for i = 1, self.bestTimeCount do
		y = y + recordStride;

		local c = Color(230, 230, 230);
		local t = self.bestTimes[i];

		-- colour the previous time differently
		if t == player.raceTimePrevious then
			c = Color(170, 230, 170);
		end

		DrawItem(x, y, FormatTimeToDecimalTime(t), c);
	end;

	for i = self.bestTimeCount+1, RECORD_COUNT_TO_RECORD do
		y = y + recordStride;
		DrawItem(x, y, "---", Color(170, 170, 170));
	end

	-- ensure previous is at bottom, even if it's slower
	if self.bestTimeCount >= RECORD_COUNT_TO_RECORD and
		player.raceTimePrevious > self.bestTimes[RECORD_COUNT_TO_RECORD] then
		
		y = y + recordStride;
		DrawItem(x, y, FormatTimeToDecimalTime(player.raceTimePrevious), Color(230, 170, 170));
	end
end
