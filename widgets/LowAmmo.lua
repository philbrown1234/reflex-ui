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

LowAmmo =
{
	intensity = 0;
	timer = 0;
};
registerWidget("LowAmmo");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LowAmmo:draw()
	local x = 0;
	local y = 0;

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

	local player = getPlayer();
	if not player then return end;

	local weaponIndexSelected = player.weaponIndexSelected;
	if weaponDefinitions[weaponIndexSelected] == nil then return end;

	local lowAmmoWarning = weaponDefinitions[weaponIndexSelected].lowAmmoWarning;
	local ammo = player.weapons[weaponIndexSelected].ammo;

	local showLowAmmoWarning = (ammo <= lowAmmoWarning);
	if showLowAmmoWarning then
		self.intensity = math.min(self.intensity + deltaTime * 4, 1);
	else
		self.intensity = math.max(self.intensity - deltaTime * 4, 0);
	end

	-- early out if nothing to do
	if self.intensity <= 0 then 
		self.timer = 0;
		return;
	end

	self.timer = self.timer + deltaTime*8;

	nvgFontSize(32);
    nvgFontFace("titilliumWeb-regular");
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
	
	local intensity = self.intensity;
	local col = Color(232,232,232,255*intensity);
	local text = "LOW AMMO WARNING";

	if (ammo <= 0) then
		nvgSave();
		
		nvgFontSize(40);
   	 	nvgFontFace("titilliumWeb-bold");
		nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

		text = "> NO AMMO <";
	end
	
	nvgFontBlur(5);
    nvgFillColor(Color(200, 64, 64, 255*intensity));
	nvgText(x, y, text);
	
	local r = 245 + math.sin(self.timer)*10;
	nvgFontBlur(0);
    nvgFillColor(Color(r,r-20,r-20,255*intensity));
	nvgText(x, y, text);

	if (ammo <= 0) then
		nvgRestore();
	end
end
