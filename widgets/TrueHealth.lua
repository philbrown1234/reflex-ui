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

TrueHealth =
{
};
registerWidget("TrueHealth");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function GetStackAfterRocket(h, a, prot)

	local armorProtectionAmount = {};
	armorProtectionAmount[0] = 0.5;
	armorProtectionAmount[1] = 0.66;
	armorProtectionAmount[2] = 0.75;

	local damage = 100;
	
	local playerArmorProtection = armorProtectionAmount[prot];
	local playerArmor = a;
	local playerHealth = h;
	
	--return playerArmorProtection;
	
	local maxProtectAmount = round(100 * playerArmorProtection);
	local damageProtectAmount = math.min(maxProtectAmount, playerArmor);
	
	playerArmor = playerArmor - damageProtectAmount;
	damage = damage - damageProtectAmount;
	playerHealth = playerHealth - damage;
	
	local result = {};
	result["health"] = playerHealth;
	result["armor"] = playerArmor;
	return result;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function GetRocketsUntilDeath(player)
	
	-- save the maths, you cant survive a full rocket, ever
	-- also prevents readout from showing -1 after you die
	if player.health < 20 then 
	return 0;
	end
	
	local h = player.health;
	local a = player.armor;
	local prot = player.armorProtection;
	local rocketCount = -1; -- because we want to know how many we can survive and this tells us how many will kill us
	
	while h > 1 do
		h = GetStackAfterRocket(h, a, prot)["health"];
		a = GetStackAfterRocket(h, a, prot)["armor"];
		rocketCount = rocketCount + 1;
	end
	
	return rocketCount;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function TrueHealth:draw()

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;
	if isRaceMode() then return end;

   	-- Find player 
	local player = getPlayer();

    -- Options
    local showFrame = true;
    local colorNumber = false;
    
    -- Size and spacing
    local frameWidth = 125;
    local frameHeight = 15;
    local framePadding = 4;
    local numberSpacing = 100;
    local iconSpacing = 40;
	
    -- Colors
    local frameColor = Color(0,0,0,128);
    local barAlpha = 160;
    local iconAlpha = 32;

	local weaponIndexSelected = player.weaponIndexSelected;
	local weapon = player.weapons[weaponIndexSelected];
	local ammo = weapon.ammo;

	-- Helpers
    local frameLeft = -frameWidth/2;
    local frameTop = -frameHeight;
    local frameRight = frameLeft + frameWidth;
    local frameBottom = 0;
 
    local barLeft = frameLeft + iconSpacing + numberSpacing
    local barTop = frameTop + framePadding;
    local barRight = frameRight - framePadding;
    local barBottom = frameBottom - framePadding;

    local barWidth = frameWidth - numberSpacing - framePadding - iconSpacing;
    local barHeight = frameHeight - (framePadding * 2);

    local fontX = barRight-2;
    local fontY = -(frameHeight / 2);
    local fontSize = frameHeight * 1.15;

    local segmentX = frameLeft + framePadding;
    local segmentSpacing = 3;
    local segmentWidth = (frameWidth - (framePadding * 2) - (segmentSpacing * 2)) / 3;
    local segmentColor = Color(232,157,12);

    -- Frame
    if showFrame then
        nvgBeginPath();
        nvgRoundedRect(frameRight, frameBottom, -frameWidth, -frameHeight, 5);
        nvgFillColor(frameColor); 
        nvgFill();
    end

    --local rockets = GetRocketsUntilDeath(player);
    for segments = 0, GetRocketsUntilDeath(player) do
              
        if segments ~= 0 then

            -- Bar Segments
            nvgBeginPath();
            nvgRect(segmentX, frameTop + framePadding, segmentWidth, frameHeight - (framePadding * 2));
            nvgFillColor(segmentColor);
            nvgFill();

            -- Shading
            nvgBeginPath();
            nvgRect(segmentX, frameTop + framePadding, segmentWidth, frameHeight - (framePadding * 2));
            nvgFillLinearGradient(frameLeft, frameTop, frameLeft, frameBottom, Color(255,255,255,50), segmentColor);
            nvgFill();

            segmentX = segmentX + segmentWidth + segmentSpacing;

        end
    end

end
