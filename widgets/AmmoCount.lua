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

AmmoCount =
{
};
registerWidget("AmmoCount");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AmmoCount:draw()

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

	local player = getPlayer();

    -- Options
    local showFrame = true;
    local colorNumber = false;
    
    -- Size and spacing
    local frameWidth = 125;
    local frameHeight = 35;
    local framePadding = 5;
    local numberSpacing = 100;
    local iconSpacing = 40;
	
    -- Colors
    local frameColor = Color(0,0,0,128);

	local weaponIndexSelected = player.weaponIndexSelected;
	local weapon = player.weapons[weaponIndexSelected];
	local ammo = weapon.ammo;

	-- Helpers
    local frameLeft = -frameWidth/2;
    local frameTop = -frameHeight;
    local frameRight = frameLeft + frameWidth;
    local frameBottom = 0;
 
    local fontX = (frameRight - framePadding) - 2;
    local fontY = -(frameHeight / 2);
    local fontSize = frameHeight * 1.15;

    -- Frame
    if showFrame then
        nvgBeginPath();
        nvgRoundedRect(frameRight, frameBottom, -frameWidth, -frameHeight, 5);
        nvgFillColor(frameColor); 
        nvgFill();
    end
          
    -- colour changes when low on ammo
	local fontColor = Color(230,230,230);
	local glow = false;
	if ammo == 0 then
		fontColor = Color(230, 0, 0);
		glow = true;
	elseif ammo < weapon.lowAmmoWarning then
		fontColor = Color(230, 230, 0);
		glow = true;
	end

    nvgFontSize(fontSize);
	nvgFontFace(FONT_HUD);
	nvgTextAlign(NVG_ALIGN_RIGHT, NVG_ALIGN_MIDDLE);
    
	-- unlimited ammo if melee, in race mode, or in warmup mode
    if weaponIndexSelected == 1 then ammo = "-" end 
	if isRaceMode() then ammo = "-" end
	if world.gameState == GAME_STATE_WARMUP then ammo = "-" end
    
    if glow then
	    nvgFontBlur(5);
        nvgFillColor(Color(64, 64, 200));
	    nvgText(fontX, fontY, ammo);
    end
    
	nvgFontBlur(0);
	nvgFillColor(fontColor);
	nvgText(fontX, fontY, ammo);
    
    -- Draw icon    
	local iconX = frameLeft + (iconSpacing / 2) + framePadding;
	local iconY = -(frameHeight / 2);
	local iconSize = (frameHeight / 2) * 0.75;
	local svgName = "internal/ui/icons/weapon" .. weaponIndexSelected;
	if (weaponIndexSelected == 1) and (player.inventoryMelee ~= nil) then
		local def = inventoryDefinitions[player.inventoryMelee];
		if def ~= nil then
			svgName = def.asset;
		end
	end
	local iconColor = player.weapons[weaponIndexSelected].color;
	nvgFillColor(iconColor);
	nvgSvg(svgName, iconX, iconY, iconSize);
end
