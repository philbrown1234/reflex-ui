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

ScreenEffects =
{
    time = 0;
    lastPlayerHealth = 0;
    hurtTime = 0;
    hasBeenHurt = false;
};
registerWidget("ScreenEffects");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ScreenEffects:draw()
 
    -- Find player
    local player = getPlayer();

    -- Early out if possible
    if player == nil or
       player.state == PLAYER_STATE_EDITOR or 
       player.state == PLAYER_STATE_SPECTATOR or
	   player.state == PLAYER_STATE_QUEUED or 
       world.gameState == GAME_STATE_GAMEOVER or
	   --(not showScores and world.gameState ~= GAME_STATE_GAMEOVER) or [pb] why? want to see mega health when in warmup..
       isInMenu() 
       then return false end;

    if not player.connected then return end;
    
    local x = -(viewport.width / 2);
    local y = -(viewport.height / 2);
    local width = viewport.width;
    local height = viewport.height;
    local innerRadius = width / 3;
    local textY = (height / 2) - 110;
    
    local deathInnerColor = Color(0,0,0,150);
    local deathOuterColor = Color(0,0,0,255);

    if (player.health < self.lastPlayerHealth) then
        local hurtDuration = 1.0;
        local hurtAmount = self.lastPlayerHealth - player.health;
        -- prevent mega tick down triggering hurt
        if (hurtAmount > 1) then
            self.hurtTime = self.time + hurtDuration;
            self.hasBeenHurt = 1;
        end
    end
    self.lastPlayerHealth = player.health

    if (self.hurtTime > self.time) then
        local innerRadius = width / 3/(self.hurtTime - self.time);
        local hurtOuterColor = Color(138,7,7,255);
        local hurtInnerColor = Color(0,0,0,0);
        nvgBeginPath();
        nvgRect(x, y, width, height);
        nvgFillRadialGradient(0, 0, innerRadius, width, hurtInnerColor, hurtOuterColor);
        nvgFill();
    end

    self.time = self.time + deltaTime

    if player.health > 0 and player.health <= 30 then
		local bloodOuterColor = Color(138,7,7);
		local bloodInnerColor = Color(0,0,0,0);
        nvgBeginPath();
        nvgRect(x, y, width, height);
        nvgFillRadialGradient(0, 0, innerRadius, width, bloodInnerColor, bloodOuterColor);
        nvgFill();
	elseif player.hasMega then

		local megaInnerColor = Color(0,0,0,0);
		local megaOuterColor = Color(25, 120, 255, 64);
        nvgBeginPath();
        nvgRect(x, y, width, height);
        nvgFillRadialGradient(0, 0, innerRadius, width, megaInnerColor, megaOuterColor);
        nvgFill();
    end

	local canRespawn = gamemodes[world.gameModeIndex].canRespawn;
	if string.find(string.lower(world.mutators), "arena") ~= nil then
		canRespawn = false;
	end

    if player.health <= 0 and canRespawn then
        nvgBeginPath();
        nvgRect(x, y, width, height);
        nvgFillRadialGradient(0, 0, innerRadius, width, deathInnerColor, deathOuterColor);
        nvgFill();

        nvgFontSize(80);
	    nvgFontFace(FONT_HUD);
	    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

        nvgFontBlur(10);
        nvgFillColor(Color(180,0,0,255));
        nvgText(0, textY, "FRAGGED");

        nvgFontBlur(0);
        nvgFillColor(Color(230,0,0,255));
        nvgText(0, textY, "FRAGGED");

        nvgFontSize(26);
	    nvgFontFace("titilliumWeb-regular");
	    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
        nvgFillColor(Color(230,230,230,255));
        nvgText(0, textY + 50, "Press jump or attack to respawn");

        --nvgFontSize(20);
	    --nvgFontFace("titilliumWeb-regular");
	    --nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
        --nvgFillColor(Color(230,230,230,255));
        --nvgText(0, textY + 70, "Forced respawn in X");
    end

    -- -- Team color hint
	-- if gamemodes[world.gameModeIndex].hasTeams then
	-- 	local colTeam = teamColors[player.team];
	-- 	local colTop = Color(colTeam.r, colTeam.g, colTeam.b, 0);
	-- 	local colBottom = Color(colTeam.r, colTeam.g, colTeam.b, 64);
	-- 
    --     nvgBeginPath();
    --     nvgRect(x, viewport.height/2 - 100, width, 100);
    --     nvgFillLinearGradient(0, viewport.height/2 - 100, 0, viewport.height/2, colTop, colBottom);
    --     nvgFill();
    -- end

    if player.health <= 0 and gamemodes[world.gameModeIndex].canRespawn == false then

        nvgFontSize(80);
	    nvgFontFace(FONT_HUD);
	    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

        nvgFontBlur(10);
        nvgFillColor(Color(180,0,0,255));
        nvgText(0, textY, "FRAGGED");

        nvgFontBlur(0);
        nvgFillColor(Color(230,0,0,255));
        nvgText(0, textY, "FRAGGED");

        nvgFontSize(26);
	    nvgFontFace("titilliumWeb-regular");
	    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
        nvgFillColor(Color(230,230,230,255));
        nvgText(0, textY + 50, "Waiting for next round..");

        --nvgFontSize(20);
	    --nvgFontFace("titilliumWeb-regular");
	    --nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
        --nvgFillColor(Color(230,230,230,255));
        --nvgText(0, textY + 70, "Forced respawn in X");
    end
end
