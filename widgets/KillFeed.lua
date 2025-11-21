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

KillFeed =
{
	canPosition = true,

	-- user data, we'll save this into engine so it's persistent across loads
	userData = {}
};
registerWidget("KillFeed");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function KillFeed:initialize()
	-- load data stored in engine
	self.userData = loadUserData();
	
	-- ensure it has what we need
	CheckSetDefaultValue(self, "userData", "table", {});
	CheckSetDefaultValue(self.userData, "rightAlign", "boolean", true);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function KillFeed:drawKill(x, y, windowWidth, h, teamA, nameA, nameB, iconSvg, iconCol, age)
	local iconRadius = 12;
	local iconPad = 14;
	local pad = 10;
	local color = Color(0, 0, 0, 255);

	local player = getLocalPlayer();

	local gameMode = gamemodes[world.gameModeIndex];

	-- in teamplay, take team colour
	if (gameMode.hasTeams) then
		color.r = teamColors[teamA].r;
		color.g = teamColors[teamA].g;
		color.b = teamColors[teamA].b;

		-- if it's us AND teamplay, make a bit brighter
		if (player.name == nameA) then
			color.r = color.r + 127;
			color.g = color.g + 127;
			color.b = color.b + 127;
		end
	else
		-- otherwise, use players primary colour
		if (player.name == nameA) then
			color = extendedColors[player.colorIndices[1]+1];
		end
	end
	
	local intensity = clamp(1 - (age - 9), 0, 1); -- fade out from 9->10 seconds
	
	nvgSave();
	nvgTranslate(x, y);
	nvgScale(1, 1);
	y = 0;
	
    nvgFontSize(30);
    nvgFontBlur(0);
	nvgFontFace("TitilliumWeb-Regular");
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);

	-- determine width
	local w = pad + nvgTextWidth(nameA) + iconPad + iconRadius + iconPad;
	if nameB ~= nil and string.len(nameB) > 0 then
		w = w + nvgTextWidth(nameB) + pad;
	end
	local ix = 0;

	-- right align?
	if self.userData.rightAlign then
		ix = ix + windowWidth;
		ix = ix - w;		
	end

	-- bg
	local outlineSize = 2;
	nvgBeginPath();
	nvgRoundedRect(ix-outlineSize, y-outlineSize, w+outlineSize*2, h+outlineSize*2, 5+outlineSize);
	nvgFillColor(Color(color.r, color.g, color.b, 128*intensity));
	nvgFill();
	nvgBeginPath();
	nvgRoundedRect(ix, y, w, h, 5);
	nvgFillColor(Color(0,0,0,128*intensity));
	nvgFill();
	ix = ix + pad;

	-- playerA
	nvgFillColor(Color(255, 255, 255, 255*intensity));
	nvgText(ix, y+h/2, nameA);
	ix = ix + nvgTextWidth(nameA) + iconPad;

	-- icon
	local killWeapon = 6;
	nvgFillColor(Color(iconCol.r, iconCol.g, iconCol.b, iconCol.a*intensity));
	nvgSvg(iconSvg, ix+6, y+h/2+2, iconRadius);
	ix = ix + iconRadius + iconPad;

	-- playerB
	if nameB ~= nil then
		nvgFillColor(Color(255, 255, 255, 255*intensity));
		nvgText(ix, y+h/2, nameB);
		ix = ix + nvgTextWidth(nameB) + pad;
	end

	nvgRestore();
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function KillFeed:gatherKills()

	local kills = {};
	local killCount = 0;

	-- find one (any) player just to get weapon colours :S
	local player = nil;
	for k, v in pairs(players) do
		if v.connected then
			player = v;
			break;
		end
	end
	if player == nil then
		return kills;
	end
	
	local deathIcons = {};
	deathIcons[DAMAGE_TYPE_MELEE] = { ["color"] = player.weapons[1].color, ["icon"] = "internal/ui/icons/weapon1" };
	deathIcons[DAMAGE_TYPE_BURST] = { ["color"] = player.weapons[2].color, ["icon"] = "internal/ui/icons/weapon2" };
	deathIcons[DAMAGE_TYPE_SHELL] = { ["color"] = player.weapons[3].color, ["icon"] = "internal/ui/icons/weapon3" };
	deathIcons[DAMAGE_TYPE_GRENADE] = { ["color"] = player.weapons[4].color, ["icon"] = "internal/ui/icons/weapon4" };
	deathIcons[DAMAGE_TYPE_PLASMA] = { ["color"] = player.weapons[5].color, ["icon"] = "internal/ui/icons/weapon5" };
	deathIcons[DAMAGE_TYPE_ROCKET] = { ["color"] = player.weapons[6].color, ["icon"] = "internal/ui/icons/weapon6" };
	deathIcons[DAMAGE_TYPE_BEAM] = { ["color"] = player.weapons[7].color, ["icon"] = "internal/ui/icons/weapon7" };
	deathIcons[DAMAGE_TYPE_BOLT] = { ["color"] = player.weapons[8].color, ["icon"] = "internal/ui/icons/weapon8" };
	deathIcons[DAMAGE_TYPE_STAKE] = { ["color"] = player.weapons[9].color, ["icon"] = "internal/ui/icons/weapon9" };
	deathIcons[DAMAGE_TYPE_TELEFRAG] = { ["color"] = Color(255, 255, 255), ["icon"] = "internal/ui/icons/teleporter" };

	local suicideIcons = {};
	suicideIcons[DAMAGE_TYPE_GRENADE] = { ["color"] = player.weapons[4].color, ["icon"] = "internal/ui/icons/weapon4" };
	suicideIcons[DAMAGE_TYPE_PLASMA] = { ["color"] = player.weapons[5].color, ["icon"] = "internal/ui/icons/weapon5" };
	suicideIcons[DAMAGE_TYPE_ROCKET] = { ["color"] = player.weapons[6].color, ["icon"] = "internal/ui/icons/weapon6" };
	suicideIcons[DAMAGE_TYPE_LAVA] = { ["color"] = Color(255, 255, 255), ["icon"] = "internal/ui/icons/lava" };
	suicideIcons[DAMAGE_TYPE_DROWN] = { ["color"] = Color(255, 255, 255), ["icon"] = "internal/ui/icons/drown" };
	suicideIcons[DAMAGE_TYPE_OUTOFWORLD] = { ["color"] = Color(255, 255, 255), ["icon"] = "internal/ui/icons/falling" };
	suicideIcons[DAMAGE_TYPE_OVERTIME] = { ["color"] = Color(255, 255, 255), ["icon"] = "internal/ui/icons/skull" };
	suicideIcons[DAMAGE_TYPE_SUICIDE] = { ["color"] = Color(255, 255, 255), ["icon"] = "internal/ui/icons/skull" };

	local turretIcons = {}
	turretIcons[DAMAGE_TYPE_GRENADE] = { ["color"] = player.weapons[4].color, ["icon"] = "internal/ui/icons/turret" };
	turretIcons[DAMAGE_TYPE_PLASMA] = { ["color"] = player.weapons[5].color, ["icon"] = "internal/ui/icons/turret" };
	turretIcons[DAMAGE_TYPE_ROCKET] = { ["color"] = player.weapons[6].color, ["icon"] = "internal/ui/icons/turret" };
	turretIcons[DAMAGE_TYPE_BOLT] = { ["color"] = player.weapons[8].color, ["icon"] = "internal/ui/icons/turret" };
	turretIcons[DAMAGE_TYPE_BEAM] = { ["color"] = player.weapons[7].color, ["icon"] = "internal/ui/icons/turret" };

	-- parse log
	local logCount = 0;
	for k, v in pairs(log) do
		logCount = logCount + 1;
	end
	for i = 1, logCount do
		local logEntry = log[i];
		if logEntry.type == LOG_TYPE_DEATHMESSAGE then
			local intensity = clamp(1 - (logEntry.age - 9), 0, 1); -- fade out from 9->10 seconds

			killCount = killCount + 1;
			kills[killCount] = {};

			local team = 0;
			local gameMode = gamemodes[world.gameModeIndex];
			if (gameMode.hasTeams) then
				kills[killCount].teamA = logEntry.deathTeamIndexKiller;
			end

			kills[killCount].age = logEntry.age;
			if logEntry.deathTurret then
				kills[killCount].nameA = logEntry.deathKilled;
				kills[killCount].iconCol = turretIcons[logEntry.deathDamageType].color;
				kills[killCount].iconSvg = turretIcons[logEntry.deathDamageType].icon;
			elseif logEntry.deathSuicide then
				kills[killCount].nameA = logEntry.deathKilled;
				kills[killCount].iconCol = suicideIcons[logEntry.deathDamageType].color;
				kills[killCount].iconSvg = suicideIcons[logEntry.deathDamageType].icon;
			else
				kills[killCount].nameA = logEntry.deathKiller;
				kills[killCount].nameB = logEntry.deathKilled;
				kills[killCount].iconCol = deathIcons[logEntry.deathDamageType].color;
				kills[killCount].iconSvg = deathIcons[logEntry.deathDamageType].icon;

				-- use svg asset for weapon
				if logEntry.deathDamageType == DAMAGE_TYPE_MELEE then
					if logEntry.deathMeleeDefId ~= nil then
						local def = inventoryDefinitions[logEntry.deathMeleeDefId];
						if def ~= nil then
							kills[killCount].iconCol = Color(255, 255, 255);
							kills[killCount].iconSvg = def.asset;
						end
					end
				end
			end
		end
	end

	-- sort by age (should be sorted already but just incase)
	local function sortByAge(a, b)
		return a.age < b.age;
	end
	table.sort(kills, sortByAge);

	-- when we have excessive kills, clamp to upper limit
	local maxElements = 5;
	for i = maxElements, killCount do
		kills[i+1] = nil;
	end
	killCount = math.min(killCount, maxElements);

	return kills, killCount, team;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function KillFeed:draw()
    -- Early out if HUD shouldn't be shown.
	local optargs = {};
	optargs.showWhenDead = true;
    if not shouldShowHUD(optargs) then return end;
	
	local widget = 300;
	local height = 200;
	local itemHeight = 40;
	
	local ix = -widget/2;
	local iy = -height/2;
	
	-- when MM active, we push down under it
	if matchmaking.state == MATCHMAKING_SEARCHINGFOROPPONENTS or
	   matchmaking.state == MATCHMAKING_FOUNDOPPONENTS or
	   matchmaking.state == MATCHMAKING_VOTINGMAP or 
	   matchmaking.state == MATCHMAKING_FINDINGSERVER or
	   matchmaking.state == MATCHMAKING_LOSTCONNECTIONATTEMPTINGRECONNECT then
		iy = iy + 50
	end

	local kills, killCount = self:gatherKills();
	for i = killCount, 1, -1 do
		local kill = kills[i];
		self:drawKill(ix, iy, widget, itemHeight, kill.teamA, kill.nameA, kill.nameB, kill.iconSvg, kill.iconCol, kill.age);
		iy = iy + itemHeight + 10;
	end
	
	-- testin..
	--self:drawKill(ix, iy, widget, itemHeight, "Shooter", "ElectricBalls", "internal/weapons/melee/industrial/melee_crowbar/melee_crowbar", Color(255,255,255), 0);
	--iy = iy + itemHeight + 10;
	--self:drawKill(ix, iy, widget, itemHeight, "Alfred", "ElectricBalls", "internal/ui/icons/weapon" .. 6, player.weapons[6].color);
	--iy = iy + itemHeight + 10;
	--self:drawKill(ix, iy, widget, itemHeight, "Shooter", "Jonny", "internal/ui/icons/weapon" .. 3, player.weapons[3].color);
	--iy = iy + itemHeight + 10;
	--self:drawKill(ix, iy, widget, itemHeight, "Sam", "ElectricBalls", "internal/ui/icons/weapon" .. 1, player.weapons[1].color);
	--iy = iy + itemHeight + 10;
	--self:drawKill(ix, iy, widget, itemHeight, "Derpman", "", "internal/ui/icons/weapon" .. 6, player.weapons[6].color);
	--iy = iy + itemHeight + 10;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function KillFeed:drawOptions(x, y, intensity)
	local optargs = {};
	optargs.intensity = intensity;

	local user = self.userData;

	user.rightAlign = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Right Align", user.rightAlign, optargs);
	y = y + 60;

	saveUserData(user);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function KillFeed:getOptionsHeight()
	return 60; -- debug with: ui_menu_show_widget_properties_height 1
end
