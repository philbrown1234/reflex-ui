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

WeaponName =
{
};
registerWidget("WeaponName");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function WeaponName:draw()
	local x = 0;
	local y = 0;
	
   	-- Find player and early out if possible
	local player = getPlayer();
	if player == nil or player.health <= 0 or isInMenu() then return end;

	local alpha = 255 * player.weaponSelectionIntensity;

	nvgFontSize(36);
	nvgFontFace(FONT_HUD);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);

	local weapon = player.weapons[player.weaponIndexSelected];
		
	-- bg
	nvgFontBlur(2);
	nvgFillColor(Color(0, 0, 0, alpha));
	nvgText(x, y + 1, weapon.name);

	-- foreground
	local col = {};
	col.r = weapon.color.r;
	col.g = weapon.color.g;
	col.b = weapon.color.b;
	col.a = alpha;
	nvgFontBlur(0);
	nvgFillColor(col);
	nvgText(x, y, weapon.name);
end
