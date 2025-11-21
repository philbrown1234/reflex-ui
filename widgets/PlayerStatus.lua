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

PlayerStatus =
{
	canPosition = false,
	lastTickSeconds = -1;
	readyTimer = 0;
};
registerWidget("PlayerStatus");

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
function PlayerStatus:draw()
	-- localPlayer status:
	--
	-- mode: Free for all / 1v1 / tdm / .....
	-- state:	Queud for match, in position %d of %d
	--
	-- camera: Freecam / Following: newborn
	-- caminfo: use < and > to cycle players, use / to cycle modes
	--

    -- Early out if HUD shouldn't be shown.
    if not shouldShowStatus() then return end;
	if world.isMatchmakingLobby then return end;

   	-- localPlayer = player who owns this client
	-- player = player we're watching
	local localPlayer = getLocalPlayer();
	if localPlayer == nil then return end;
	local player = getPlayer();
	if player == nil then return end;
	
	local gamemode = gamemodes[world.gameModeIndex];
	local modename = gamemode.name;
	local showCameraState = false;
	local showPressToReadyUp = false;

	-- show matchmaking playerlist name instead of mode name
	if world.matchmakingPlaylistKey ~= "" then
		for k,v in pairs(matchmaking.playlists) do
			if v.key == world.matchmakingPlaylistKey then
				modename = string.upper(v.name)
			end
		end
	end
	
	-- first, gather state
	local state = nul;
	if localPlayer.state == PLAYER_STATE_QUEUED then
	
		state = string.format(GAMESTRING_status_Queued, localPlayer.queuePosition, world.playerQueueLength);
		showCameraState = true;
	
	elseif (localPlayer.state == PLAYER_STATE_INGAME) and (localPlayer.health <= 0) and (world.gameState == GAME_STATE_ACTIVE or world.gameState == GAME_STATE_ROUNDACTIVE or world.gameState == GAME_STATE_ROUNDCOOLDOWN_SOMEONEWON or world.gameState == GAME_STATE_ROUNDCOOLDOWN_DRAW) then

		local canRespawn = gamemodes[world.gameModeIndex].canRespawn;
		if string.find(string.lower(world.mutators), "arena") ~= nil then
			canRespawn = false;
		end

		if not canRespawn then
			state = "You died, waiting for next round..";
			showCameraState = true;
		end

	elseif localPlayer.state == PLAYER_STATE_SPECTATOR then

		if world.gameState == GAME_STATE_WARMUP then
			state = "Spectating (in warmup)..";
		else
			state = "Spectating..";
		end
		showCameraState = true;
	
	elseif world.gameState == GAME_STATE_WARMUP then

		if world.matchmakingPlaylistKey ~= "" then
			-- matchmaking game			
			if not world.timerActive then
				state = "Waiting for opponent(s) to connect.."
			end
		else
			-- ready up information..

			-- warmup
			-- (when timer starts, game is preparing, don't display state box)
			--if not world.timerActive then
				local numReady = 0;
				local numPlaying = 0;

				for k, v in pairs(players) do 
					if v.connected and v.state == PLAYER_STATE_INGAME then
						numPlaying = numPlaying + 1;
						if v.ready then
							numReady = numReady + 1;
						end
					end
				end

				if gamemode.playersRequired ~= nil and numPlaying >= gamemode.playersRequired then
					state = string.format(GAMESTRING_warmup_players_ready, world.ruleset, numReady, numPlaying);
					if localPlayer == player and not localPlayer.ready and gamemode.requiresReadyUp then
						showPressToReadyUp = true;
					end
				else
					state = string.format(GAMESTRING_warmup_need_2_players, world.ruleset);
				end
			--else
			--	state = "Ruleset: " .. world.ruleset;
			--end
		end

	end

	-- gather camera state if required
	local camera = "";
	local cameraInfo = "";
	if showCameraState then
		-- todo: cache these rather than looking up frame?
		local keyPrevCamera = bindReverseLookup("cl_camera_prev_player");
		local keyNextCamera = bindReverseLookup("cl_camera_next_player");
		local keyFreeCamera = bindReverseLookup("cl_camera_freecam");
		
		cameraInfo = "Use "..keyPrevCamera.." and "..keyNextCamera.." to cycle players, use "..keyFreeCamera.." for freecam";

		if (playerIndexCameraAttachedTo == playerIndexLocalPlayer) or (playerIndexCameraAttachedTo == 0) then 
			camera = "Free Camera";
		else
			camera = string.format("Following: %s", player.name);
		end
	end
		
	local x = 0;
	local y = -viewport.height/2 + 60;
	local vpad = 5;
	local hpad = 5;
	local lineHeight = 40;
	local iy = y + vpad + lineHeight/2;

	if state ~= nil then
	
		-- mode
		nvgFontSize(60);
		nvgFontFace("titilliumWeb-bold");
		nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

		drawPlayerText(modename, Color(245, 245, 245), x, iy);
		iy = iy + lineHeight;

		-- state
		nvgFontSize(35);
		nvgFontFace("titilliumWeb-regular");
		drawPlayerText(state, Color(240, 240, 240), x, iy);
		iy = iy + lineHeight;
	end

	if showPressToReadyUp == true then
		local alpha = 215 + 40 * math.sin(self.readyTimer);
		self.readyTimer = self.readyTimer + deltaTimeRaw*4;

		local textStart = "Press (";
		local textKey = string.upper(bindReverseLookup("ready", "game"));
		local textEnd = ") to ready up!";
		local text = textStart .. textKey .. textEnd;
		
		nvgFontSize(35);
		nvgFontFace("titilliumWeb-regular");
		nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
		
		local twStart = nvgTextWidth(textStart);
		local twKey = nvgTextWidth(textKey);
		local twEnd = nvgTextWidth(textEnd);
		local tw = twStart + twKey + twEnd;
		
		local ix = x - tw/2;
		
		nvgFontBlur(2);
		nvgFillColor(Color(0, 0, 0, alpha));
		nvgText(ix, iy + 1, textStart);
		nvgFontBlur(0);
		nvgFillColor(Color(255, 255, 240, alpha));
		nvgText(ix, iy, textStart);
		ix = ix + twStart;
		
		nvgFontBlur(2);
		nvgFillColor(Color(0, 0, 0, alpha));
		nvgText(ix, iy + 1, textKey);
		nvgFontBlur(0);
		nvgFillColor(Color(255, 80, 80, alpha));
		nvgText(ix, iy, textKey);
		ix = ix + twKey;
		
		nvgFontBlur(2);
		nvgFillColor(Color(0, 0, 0, alpha));
		nvgText(ix, iy + 1, textEnd);
		nvgFontBlur(0);
		nvgFillColor(Color(255, 255, 240, alpha));
		nvgText(ix, iy, textEnd);
		ix = ix + twEnd;

	end

	if showCameraState then
		iy = 260;
		-- spacer
		--iy = iy + lineHeight;

		-- camera
		nvgFontFace("titilliumWeb-bold");
        nvgFontSize(35);
		drawPlayerText(camera, Color(255, 255, 255), x, iy);
		iy = iy + (lineHeight / 2)+10;

		-- camera info
		nvgFontFace("titilliumWeb-regular");
        nvgFontSize(25);
		drawPlayerText(cameraInfo, Color(255, 255, 255), x, iy);
		iy = iy + (lineHeight / 2);
	end
end
