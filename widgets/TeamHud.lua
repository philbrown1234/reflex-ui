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

TeamHud =
{
};
registerWidget("TeamHud");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function TeamHud:initialize()
    -- load data stored in engine
    self.userData = loadUserData();
    
    -- ensure it has what we need
    CheckSetDefaultValue(self, "userData", "table", {});
    CheckSetDefaultValue(self.userData, "showSelf", "boolean", false);
    CheckSetDefaultValue(self.userData, "horizontal", "true", false);
    CheckSetDefaultValue(self.userData, "iconAlpha", "number", 127);
    CheckSetDefaultValue(self.userData, "fontAlpha", "number", 160);
    CheckSetDefaultValue(self.userData, "barAlpha", "number", 160);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function TeamHud:drawOptions(x, y, intensity)
    local optargs = {};
    optargs.intensity = intensity;

    local sliderWidth = 200;
    local sliderStart = 140;
    local user = self.userData;

    user.showSelf = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Show Self", user.showSelf, optargs);
    y = y + 60;

    user.horizontal = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Horizontal", user.horizontal, optargs);
    y = y + 60;

    user.fontAlpha = ui2RowSliderEditBox0Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Font Alpha", user.fontAlpha, 0, 255, optargs);
    y = y + 60;

    user.barAlpha = ui2RowSliderEditBox0Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Bar Alpha", user.barAlpha, 0, 255, optargs);
    y = y + 60;

    user.iconAlpha = ui2RowSliderEditBox0Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Icon Alpha", user.iconAlpha, 0, 255, optargs);
    y = y + 60;
    
    saveUserData(user);
end

local function sortBySelf(a, b)
    local ascore = 1;
    local bscore = 1;

    -- just bias a number for ourselves and be done with it
    local localplayer = getPlayer();
    if (a.name == localplayer.name) then
        ascore = ascore * 9999999;
    end
    if (b.name == localplayer.name) then
        bscore = bscore * 9999999;
    end

    -- sort by "score"
    if ascore ~= bscore then
        return ascore > bscore;
    end

    -- otherwise, sort by name (so we don't get random sorting if two players have same score)
    return a.name < b.name;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function TeamHud:draw()
 
    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;
	if isRaceMode() then return end;

    local gameMode = gamemodes[world.gameModeIndex];

    -- in teamplay, take team colour
    if (gameMode.hasTeams == false) then
        return
    end

    -- discover connected players
    local connectedPlayerCount = 0;
    local connectedPlayers = {};
    for k, v in pairs(players) do
        if v.connected then
            connectedPlayerCount = connectedPlayerCount + 1;
            connectedPlayers[connectedPlayerCount] = v;
        end
    end

    -- discover real players (aka players actually playing)
    local realPlayerCount = 0;
    local realPlayers = {};
    for index = 1, connectedPlayerCount do
        local player = connectedPlayers[index];
        if player.state == PLAYER_STATE_INGAME then
            realPlayerCount = realPlayerCount + 1;
            realPlayers[realPlayerCount] = player;
        end
    end
    table.sort(realPlayers, sortBySelf);

    local localplayer = getPlayer();

    local fontAlpha = self.userData.fontAlpha;
    local iconAlpha = self.userData.iconAlpha;
    local barAlpha = self.userData.barAlpha;
    
    local fontColor = Color(255, 255, 255, fontAlpha);
    local iconGreyedOut = Color(255, 255, 255, barAlpha/4);
    local iconColorMega = Color(25, 120, 255, iconAlpha);
    local barColor = Color(255, 255, 255, barAlpha);
    local fontX = 0;
    local fontY = 0;
    local teamHud_scale = 2;
    local fontSize = 20*teamHud_scale;
    local teamHud_x = fontX;
    local teamHud_y = fontY;
    local teamHud_stepSize = 10*teamHud_scale;
    local teamHud_lineSize = fontSize;
    local teamHud_iconSize = 6.0 * teamHud_scale;
    local teamHud_iconSpacing = 8.0 * teamHud_scale;
    local teamHud_elementSpacing = 2.0 * teamHud_scale;
    local teamHud_colSize = 80 * teamHud_scale;
    local teamHud_barHeight = 5.0 * teamHud_scale;
    local teamHud_plateWidth = 180 * teamHud_scale;
    local teamHud_plateHeight = ((fontSize/2)+teamHud_barHeight+teamHud_barHeight-teamHud_elementSpacing) * teamHud_scale;

    local horizontalOffsetX = 0;

    for index = 1, realPlayerCount do
        local player = realPlayers[index];
        if player.state == PLAYER_STATE_INGAME then
            local t = player.team;

            if (t == localplayer.team) then
                if (player.name ~= localplayer.name) or (self.userData.showSelf) then

                    barColor = iconGreyedOut;

                    if (self.userData.horizontal) then
                        teamHud_x = teamHud_x + fontX + horizontalOffsetX;
                        teamHud_y = fontY;
                    else
                        teamHud_x = fontX;
                        teamHud_y = teamHud_y + teamHud_elementSpacing;
                    end

                    local teamHud_elementYTop = teamHud_y;

                    -- main backplate
                    if (player.name == localplayer.name) then
                        nvgFillColor(Color(64,64,64, barAlpha));
                    else
                        nvgFillColor(Color(0, 0, 0, barAlpha));
                    end

                    nvgBeginPath();
                    nvgRect(teamHud_x, teamHud_y+teamHud_plateHeight, teamHud_plateWidth, -teamHud_plateHeight);
                    nvgFill();

                    -- score backplate
                    barWidth = (fontSize*2.5);
                    nvgBeginPath();
                    nvgTextAlign(NVG_ALIGN_RIGHT, NVG_ALIGN_TOP);
                    nvgRect(teamHud_x+teamHud_plateWidth-barWidth, teamHud_elementYTop, barWidth, teamHud_plateHeight);
                    nvgFillColor(Color(0,0,0, barAlpha/2));
                    nvgFill();

                    -- score
                    nvgFontBlur(0);
                    nvgFillColor(fontColor);
                    nvgFontSize(fontSize*2);
                    nvgFontFace(FONT_HUD);
                    nvgTextAlign(NVG_ALIGN_RIGHT, NVG_ALIGN_MIDDLE);
                    nvgText(teamHud_x+teamHud_plateWidth-(teamHud_elementSpacing*2), teamHud_elementYTop+(teamHud_plateHeight/2), player.score);

                    teamHud_x = teamHud_x + (teamHud_elementSpacing*2);

                    nvgFontSize(fontSize);
                    nvgFontFace(FONT_HUD);
                    nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_TOP);
                    
                    nvgFontBlur(0);
                    nvgFillColor(fontColor);
                    nvgText(teamHud_x, teamHud_y, player.name);
                    --teamHud_y = teamHud_y + teamHud_lineSize;
                    --teamHud_x = teamHud_x + 80;

                    if (player.hasMega) then
                        nvgFillColor(iconColorMega);
                    else
                        nvgFillColor(iconGreyedOut);
                    end
                    nvgSvg("internal/ui/icons/health", teamHud_x+teamHud_colSize+teamHud_iconSize+teamHud_iconSpacing, teamHud_y+(teamHud_plateHeight/2)-teamHud_iconSize-teamHud_elementSpacing, teamHud_iconSize);

                    if (player.carnageTimer > 0) then
                        nvgFillColor(Color(255,120,128, iconAlpha));
                    else
                        nvgFillColor(iconGreyedOut);
                    end
                    nvgSvg("internal/ui/icons/carnage", teamHud_x+teamHud_colSize+teamHud_iconSize+teamHud_iconSize+(teamHud_iconSpacing*2.5), teamHud_y+(teamHud_plateHeight/2)-teamHud_iconSize-teamHud_elementSpacing, teamHud_iconSize);

                    if (player.hasFlag) then
                        local teamFlagHolding = (player.team == 1) and 2 or 1; -- (other team flag)
                        local iconCol = teamColors[teamFlagHolding];
                        iconCol.a = iconAlpha;
                        nvgFillColor(iconCol);
                    else
                        nvgFillColor(iconGreyedOut);
                    end
                    nvgSvg("internal/ui/icons/CTFflag", teamHud_x+teamHud_colSize+teamHud_iconSize+teamHud_iconSpacing, teamHud_y+(teamHud_plateHeight/2)+teamHud_iconSize+teamHud_elementSpacing, teamHud_iconSize);

                    if (player.resistTimer > 0) then
                        nvgFillColor(Color(255,120,128, iconAlpha));
                    else
                        nvgFillColor(iconGreyedOut);
                    end
                    nvgSvg("internal/ui/icons/resist", teamHud_x+teamHud_colSize+teamHud_iconSize+teamHud_iconSize+(teamHud_iconSpacing*2.5), teamHud_y+(teamHud_plateHeight/2)+teamHud_iconSize+teamHud_elementSpacing, teamHud_iconSize);


                    teamHud_y = teamHud_y + teamHud_lineSize;

                    local barWidth;
                    if player.health > 100 then
                        barWidth = (teamHud_colSize / 100) * (player.health - 100);
                    else
                        barWidth = (teamHud_colSize / 100) * player.health;
                    end

                    local playerHealthBar = clamp(player.health, 0, 200);
                    --local barWidth = lerp(0, teamHud_colSize, playerHealthBar / 100);

                    local barBackgroundColor;    
                    if player.health > 100 then barBackgroundColor = Color(10,68,127, barAlpha) end
                    if player.health <= 100 then barBackgroundColor = Color(14,53,9, barAlpha) end
                    if player.health <= 80 then barBackgroundColor = Color(105,67,4, barAlpha) end
                    if player.health <= 30 then barBackgroundColor = Color(141,30,10, barAlpha) end    

                    -- greyed out filler background bar for >100
                    nvgBeginPath();
                    nvgRect(teamHud_x, teamHud_y+teamHud_barHeight, teamHud_colSize, -teamHud_barHeight);
                    nvgFillColor(barBackgroundColor); 
                    nvgFill();

                    -- health bar
                    if player.health > 100 then barColor = Color(16,116,217, barAlpha) end
                    if player.health <= 100 then barColor = Color(2,167,46, barAlpha) end
                    if player.health <= 80 then barColor = Color(255,176,14, barAlpha) end
                    if player.health <= 30 then barColor = Color(236,0,0, barAlpha) end

                    if (player.hasMega) then
                        barColor = Color(16,116,217, barAlpha);
                    end

                    nvgBeginPath();
                    nvgRect(teamHud_x, teamHud_y+teamHud_barHeight, barWidth, -teamHud_barHeight);
                    nvgFillColor(barColor); 
                    nvgFill();

                    teamHud_y = teamHud_y + teamHud_barHeight;

                    teamHud_y = teamHud_y + teamHud_elementSpacing;

                    -- armor bar
                    if player.armorProtection == 0 then barColor = Color(2,167,46, barAlpha) end
                    if player.armorProtection == 1 then barColor = Color(245,215,50, barAlpha) end
                    if player.armorProtection == 2 then barColor = Color(236,0,0, barAlpha) end

                    local playerArmorBar = clamp(player.armor, 0, 200);
                    barWidth = lerp(0, teamHud_colSize, playerArmorBar / 200);

                     -- greyed out filler background bar for >100
                    nvgBeginPath();
                    nvgRect(teamHud_x, teamHud_y+teamHud_barHeight, teamHud_colSize, -teamHud_barHeight);
                    nvgFillColor(Color(iconGreyedOut.r, iconGreyedOut.g, iconGreyedOut.b, barAlpha/4)); 
                    nvgFill();

                    nvgBeginPath();
                    nvgRect(teamHud_x, teamHud_y+teamHud_barHeight, barWidth, -teamHud_barHeight);
                    nvgFillColor(barColor); 
                    nvgFill();

                    if (self.userData.horizontal == false) then
                        teamHud_y = teamHud_y + teamHud_stepSize;
                    else
                        horizontalOffsetX = teamHud_plateWidth + ((index-1) % teamHud_plateWidth);
                    end
                end
            end
        end
    end
end
