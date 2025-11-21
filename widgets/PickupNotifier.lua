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

PickupNotifier =
{
    color = Color(0, 0, 0, 0),
    pickupNotifierTime = 0,
    updateTime = 0,
    lastPlayerPositionX = 0,
    lastPlayerPositionZ = 0,
    lastPlayerAmmoCount = 0,
    lastPlayerHealth = 0,
    lastPlayerArmor = 0,
    lastPlayerWeaponCount = 0
};
registerWidget("PickupNotifier");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function PickupNotifier:initialize()
    -- load data stored in engine
    self.userData = loadUserData();
    
    -- ensure it has what we need
    CheckSetDefaultValue(self, "userData", "table", {});
    CheckSetDefaultValue(self.userData, "pickupNotifierIntensity", "number", 127);
    CheckSetDefaultValue(self.userData, "pickupNotifierSize", "number", 3.0);
    CheckSetDefaultValue(self.userData, "pickupNotifierDuration", "number", 0.15);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function PickupNotifier:drawOptions(x, y, intensity)
    local optargs = {};
    optargs.intensity = intensity;

    local sliderWidth = 200;
    local sliderStart = 140;
    local user = self.userData;
    
    user.pickupNotifierIntensity = ui2RowSliderEditBox0Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Intensity", user.pickupNotifierIntensity, 0, 255, optargs);
    y = y + 60;

    user.pickupNotifierSize = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Size", user.pickupNotifierSize, 2.0, 5.0, optargs);
    y = y + 60;

    user.pickupNotifierDuration = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Duration", user.pickupNotifierDuration, 0.1, 1.0, optargs);
    y = y + 60;
    
    saveUserData(user);
end

function distance(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function PickupNotifier:draw()
    if not shouldShowHUD() then return end;

    -- Find player 
    local player = getPlayer();

    if (player.health <= 0) then return end;

    -- Options
    local intensity = self.userData.pickupNotifierIntensity;
    local size      = self.userData.pickupNotifierSize;
    local duration  = self.userData.pickupNotifierDuration;

    local frameLeft = 0 - viewport.width/2;
    local frameTop = 0 - viewport.height/2;

    -- Colors
    local clearColor = Color(0, 0, 0, 0);
    local ammoColor = Color(255,200,50,intensity);
    local weaponColor = Color(255,200,150,intensity);
    local healthColor = Color(255,200,150,intensity);
    local armorColor = Color(255,200,150,intensity);

    -- detect any changes, set color based on type
    local weaponCount = 0;
    for k, v in ipairs(weaponDefinitions) do
        weaponCount = weaponCount + 1;
    end

    local currentWeaponCount = 0;
    local currentAmmoCount = 0;
    for weaponIndex = 1, weaponCount do
        local weapon = player.weapons[weaponIndex];
        local weaponDef = weaponDefinitions[weaponIndex];
        local ammo = weapon.ammo;

        if weapon.pickedup then
            currentWeaponCount = currentWeaponCount + 1
        end

        currentAmmoCount = currentAmmoCount + ammo
    end

    if (currentWeaponCount ~= self.lastPlayerWeaponCount) then
        self.updateTime = self.pickupNotifierTime + duration
        self.color = weaponColor
    end
    self.lastPlayerWeaponCount = currentWeaponCount

    if (currentAmmoCount > self.lastPlayerAmmoCount) then
        self.updateTime = self.pickupNotifierTime + duration
        self.color = ammoColor
    end
    self.lastPlayerAmmoCount = currentAmmoCount

    currentHealth = player.health
    if (currentHealth > self.lastPlayerHealth) then
        self.updateTime = self.pickupNotifierTime + duration
        self.color = healthColor
    end
    self.lastPlayerHealth = currentHealth

    currentArmor = player.armor
    if (currentArmor > self.lastPlayerArmor) then
        self.updateTime = self.pickupNotifierTime + duration
        self.color = armorColor
    end
    self.lastPlayerArmor = currentArmor

    -- note: this will still trigger (no flash notification)
    -- if you die really close to a pickup, it respawns while you're dead, and you respawn on it
    -- moved really far
    local distance = distance(player.position.x, player.position.z, self.lastPlayerPositionX, self.lastPlayerPositionZ);
    if (distance > 64) then
        -- no velocity
        local velocity = math.ceil(player.speed)
        if (velocity <= 0) then
            -- have health 100 now
            if (currentHealth == 100) and (currentHealth > self.lastPlayerHealth) then
                self.updateTime = 0
            end
        end
    end

    self.lastPlayerPositionX = player.position.x;
    self.lastPlayerPositionZ = player.position.z;

    self.pickupNotifierTime = self.pickupNotifierTime + deltaTime

    local intensityFade = 0;
    -- if time expired, show no notifcation
    if (self.updateTime > self.pickupNotifierTime) then
        local timeRemaining = (self.updateTime - self.pickupNotifierTime) / duration;
        intensityFade = lerp(0, intensity, timeRemaining);
    end

    local colorFinal = Color(self.color.r, self.color.g, self.color.b, intensityFade);

    -- if time expired, show no notifcation
    --if (self.updateTime < self.pickupNotifierTime) then
    --    self.color = clearColor;
    --end

    -- fullscreen effect
    nvgBeginPath();
    nvgRect(frameLeft, frameTop, viewport.width, viewport.height);
    nvgFillColor(self.color); 
    nvgFillRadialGradient(
                0, 0, viewport.width/size, viewport.width, 
                Color(0, 0, 0, 0),
                colorFinal);
    nvgFill();
end
