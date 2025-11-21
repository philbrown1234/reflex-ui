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

GameMessages =
{
	canPosition = false,
	lastTickSeconds = -1,
};
registerWidget("GameMessages");

local SHOW_TIME = 2;
local FADE_TIME = 0.5;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function drawText(text, secondRow, fontColor, age)
	local x = 0;
	local y = -70;	-- pull it above cursor
	local fontSize = 48;

	if fontColor == nil then
		fontColor = Color(230, 230, 230, 255);
	end

	if age ~= nil then
		fontColor.r = math.min(fontColor.r + 60 * math.max(1-age*2, 0), 255);
		fontColor.g = math.min(fontColor.g + 60 * math.max(1-age*2, 0), 255);
		fontColor.b = math.min(fontColor.b + 60 * math.max(1-age*2, 0), 255);
	end

	if secondRow == true then
		y = y + 40;
		fontSize = 36;
		fontColor.r = 180;
		fontColor.g = 180;
	end

	nvgSave();

	local scale = 1;

	-- this looks gross
	-- if age ~= nil then
	-- 	if age < 1 then
	-- 		scale = lerp(1.1, 1, age);
	-- 	end
	-- end
	
	nvgTranslate(x, y);
	nvgScale(scale, scale);
	
	nvgFontSize(fontSize);
	nvgFontFace(FONT_HUD);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

	-- bg
	nvgFontBlur(2);
	nvgFillColor(Color(0, 0, 0, fontColor.a));
	nvgText(0, 0 + 1, text);

	-- foreground
	nvgFontBlur(0);
	nvgFillColor(fontColor);
	nvgText(0, 0, text);
	nvgRestore();
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function drawCountdown(gameType, visible)
	local timeRemaining = world.gameTimeLimit - world.gameTime;
	local t = FormatTime(timeRemaining);

	-- this flicks to 0 some times, just clamp it to 1
	t.seconds = math.max(1, t.seconds);

	if visible == true then
		local text = gameType .. " begins in " .. t.seconds .. "..";
		drawText(text);
	end

	if GameMessages.lastTickSeconds ~= t.seconds then
		GameMessages.lastTickSeconds = t.seconds;
		playSound("internal/ui/match/match_countdown_tick");
	end

	return visible;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function drawWinner()
	local player = getPlayerAlive();
	if player ~= nil then
		local gameMode = gamemodes[world.gameModeIndex];
		if gameMode.hasTeams then
			local teamName = world.teams[player.team].name;
			drawText(teamName .. " wins the round!");
		else
			drawText(player.name .. " wins the round");
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function getTopTwoPlayers(playersOut)
	local have1 = false;
	local have2 = false;

	for k, player in pairs(players) do 
		if player.state == PLAYER_STATE_INGAME then
			if not have1 then
				playersOut[1] = player;
				have1 = true;
			elseif not have2 then
				playersOut[2] = player;
				have2 = true;
			else
				local minIndex = 1;
				if playersOut[2].score < playersOut[1].score then
					minIndex = 2;
				end

				if playersOut[minIndex].score < player.score then
					playersOut[minIndex] = player;
				end
			end
		end
	end

	return have1 and have2;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function drawPlus2()
	local gameMode = gamemodes[world.gameModeIndex];
	local pointsToWin = gameMode.pointsToWin;

	local scores = { };
	local topName = "";
	scores[1] = 0;
	scores[2] = 0;
	
	if gameMode.hasTeams then
		scores[1] = world.teams[1].score;
		scores[2] = world.teams[2].score;

		if scores[2] > scores[1] then
			topName = world.teams[2].name;
		else
			topName = world.teams[1].name;
		end
	else
		local topPlayers = {};
		if getTopTwoPlayers(topPlayers) then
			scores[1] = topPlayers[1].score;
			scores[2] = topPlayers[2].score;
			if scores[1] > scores[2] then
				topName = topPlayers[1].name;
			else
				topName = topPlayers[2].name;
			end
		end
	end

	local topScore = math.max(scores[1], scores[2]);
	if topScore >= (pointsToWin - 1) then
		if scores[1] == scores[2] then
			drawText("First player to +2 wins", true);
		else
			drawText("Match point " .. topName, true);
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function GameMessages:findLogEvent()
	local logEvent = {};

	-- count log messages
	local logCount = 0;
	for k, v in pairs(log) do
		logCount = logCount + 1;
	end

	-- read log messages
	for i = 1, logCount do
		local logEntry = log[i];

		if logEntry.type == LOG_TYPE_CTFEVENT then
			local teamColor = teamColors[logEntry.ctfTeamIndex];
			local teamName = world.teams[logEntry.ctfTeamIndex].name;	-- grr relative teams will break this!

			if logEntry.ctfEvent == CTF_EVENT_CAPTURE then
				logEvent.message = logEntry.ctfPlayerName .. " Captured the flag!";
				logEvent.color = teamColor;
				logEvent.age = logEntry.age;
				return logEvent;
			end

			if logEntry.ctfEvent == CTF_EVENT_RETURN then
				if string.len(logEntry.ctfPlayerName) > 0 then
					logEvent.message = logEntry.ctfPlayerName .. " returned the flag!";
				else
					logEvent.message = teamName .. " flag returned to base";
				end
				logEvent.color = teamColor;
				logEvent.age = logEntry.age;
				return logEvent;
			end

			if logEntry.ctfEvent == CTF_EVENT_PICKUP then
				logEvent.message = logEntry.ctfPlayerName .. " Picked up the flag!";
				logEvent.color = teamColor;
				logEvent.age = logEntry.age;
				return logEvent;
			end

			if logEntry.ctfEvent == CTF_EVENT_DROPPED then
				logEvent.message = logEntry.ctfPlayerName .. " Dropped the flag!";
				logEvent.color = teamColor;
				logEvent.age = logEntry.age;
				return logEvent;
			end
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function GameMessages:draw()
	-- Game-begins-in-3-2-1
	-- This goes here because otherwise ticks are not heard if shouldShowStatus is false.
	if world.timerActive and world.gameState == GAME_STATE_WARMUP then
		drawCountdown("Match", shouldShowStatus());
	elseif world.timerActive and world.gameState == GAME_STATE_ROUNDPREPARE then
		drawCountdown("Round", shouldShowStatus());
	end
	
	-- Early out if HUD shouldn't be shown.
    if not shouldShowStatus() then return end;

	-- 
	if world.timerActive then

		-- FIGHT! / OVERTIME!
		if world.gameState == GAME_STATE_ACTIVE or world.gameState == GAME_STATE_ROUNDACTIVE then
			if world.gameTime < 2000 then
				local text = "";

				if world.overTimeCount == 0 then
					local gameMode = gamemodes[world.gameModeIndex];
					local introText = "FIGHT";
					if gameMode.shortName == "race" then introText = "RUN"; end
					if gameMode.shortName == "training" then introText = "TRAINING" end
					drawText(introText);
				elseif world.overTimeCount == 1 then
					drawText("OVERTIME!");
				else
					drawText(world.overTimeCount .. "x OVERTIME!");
				end
			end
		end

		-- ROUND DRAW
		if world.gameState == GAME_STATE_ROUNDCOOLDOWN_DRAW then
			drawText("Round Draw");
		end

		-- announce winner
		if world.gameState == GAME_STATE_ROUNDCOOLDOWN_SOMEONEWON then
			drawWinner();
		end

		-- announce +2 to win
		if world.gameState == GAME_STATE_ROUNDPREPARE then
			drawPlus2();
		end
	end

	-- Events:
	-- find first log event we care about
	local logEvent = self:findLogEvent();
	if logEvent ~= nil then
		local alpha = 1 - clamp(logEvent.age - 2, 0, 1);
		local col = Color(logEvent.color.r, logEvent.color.g, logEvent.color.b, alpha*255);
		local age = logEvent.age;
		drawText(logEvent.message, false, col, age);
	end
end
