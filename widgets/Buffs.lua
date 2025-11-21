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

Buffs =
{
};
registerWidget("Buffs");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function drawBuff(x, y, name, col, time, percent, icon, iconCol)
	local alpha = 255;
	local w = 210;
	local h = 34;

	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	nvgFontSize(32);
	nvgFontFace(FONT_HUD);
		
	-- label bg
	nvgBeginPath()
	nvgRoundedRect(x, y + 1, w, h, 5)
	nvgFillColor(Color(0,0,0,128))
	if time ~= nil then
		nvgCircle(x + w-20, y + h/2+1, 24)
	end
	nvgFill()

	-- icon
	nvgFillColor(iconCol);
	nvgSvg(icon, x+16, y + h/2+1, 10);

	-- label
	local c = col;
	c.a = alpha;
	nvgFontBlur(0);
	nvgFillColor(Color(230,230,230));
	nvgText(x + 32, y + h/2+1, string.upper(name));

	-- time
	if time ~= nil then
		local t = FormatTime(time);
		
		local textTime = t.seconds;
		local colTime = Color(255, 255, 255, 255);
	
		-- pulse red when nearly out
		if time < 3000 then
			-- pulse
			local timeAway = time % 1000;
			local intensity = math.abs(timeAway - 500) / 500;
			--consolePrint(intensity);
			colTime.b = 128 + intensity * 127;
			colTime.g = 128 + intensity * 127;

			-- fade out at end
			if time < 500 then
				colTime.b = 128;
				colTime.g = 128;
				colTime.a = 255 - intensity*255;

				alpha = colTime.a;
			end
		end
		
		-- foreground
		nvgFontSize(32);
		nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
		nvgFillColor(colTime);
		nvgText(x + w-20, y+h/2+1, textTime);
		
		-- arc
		local cx = x + w-20;
		local cy = y + h/2+1;
		local cr = 20;

		local angleStart = -3.1415/2;
		local angleEnd = angleStart + 3.1415*2*percent;

		nvgBeginPath();
		nvgArc(cx, cy, cr-1, angleStart, angleEnd, NVG_CW)
		nvgStrokeWidth(4)
		nvgStrokeColor(Color(232,232,232,alpha))
		nvgStroke()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Buffs:draw()
	
    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;
    
    local x = -64;
	local y = 0;
	
	-- find player
	local player = getPlayer();
	if player == nil then return end;

	-- -- mega
	-- if player.hasMega then
	-- 	drawBuff(x, y, "Megahealth", Color(128,128,255), nil, 1, "internal/ui/icons/health", Color(60,80,255));
	-- 	y = y - 50;
	-- end

	-- carnage
	if player.carnageTimer > 0 then
		drawBuff(x, y, "Carnage", Color(128,128,255), player.carnageTimer, player.carnageTimer / 30000, "internal/ui/icons/carnage", Color(255,120,128));
		y = y - 50;
	end

	-- resist
	if player.resistTimer > 0 then
		drawBuff(x, y, "Resist", Color(128,128,255), player.resistTimer, player.resistTimer / 30000, "internal/ui/icons/resist", Color(255,120,128));
		y = y - 50;
	end

	-- flag
	if player.hasFlag then
		local teamFlagHolding = (player.team == 1) and 2 or 1; -- (other team flag)
		local icon = "internal/ui/icons/CTFflag";
		local iconCol = teamColors[teamFlagHolding];
		drawBuff(x, y, "Carrying Flag", Color(128,128,255), nil, 1, icon, iconCol);
		y = y - 50;
	end
end
