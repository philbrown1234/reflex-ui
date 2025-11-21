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

DownloadProgressBar =
{
	canPosition = false,
	canHide = false,
	isMenu = false,
	downloadingTime = 0,
	downloadingTipIntensity = 0
};
registerWidget("DownloadProgressBar");

local loadingtips = 
{ 
    "Armors respawn after 25 seconds", 
    "The Red Armor is generally the most important item to control in 1v1",
    "Megahealth respawns 30 seconds after the effect is lost",
    "All advanced movement in Reflex is combinations of simple tricks such as circle jump + double jump",
    "Red armor absorbs 75% of incoming damage",
    "Yellow armor absorbs 66% of incoming damage",
    "Green armor absorbs 50% of incoming damage",
    "If you don't have armor, charging at enemies is a bad strategy",
    "Rocket Launcher, Bolt Rifle and Ion Cannon do the most damage",
    "Check out our forums at forums.reflexarena.com",
    "Powerups respawn every 90 seconds",
	"You can vote for a new map by typing 'callvote map' in the console",
	"You can vote for a new game mode with 'callvote mode' in the console",
	"Remember to hit 'Mark Replay' in your matchmaking games, you might be famous!",
	"Matchmaking replays can be found at replays.reflexarena.com"
};

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function tableSize(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

-- this doesn't really work properly. you'll get the same tip for the entire session.
--local tip = loadingtips[math.random(2)];
local tip = nil;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function DownloadProgressBar:draw()

	if loading.loadScreenVisible ~= true then
		self.downloadingTime = 0;
		self.downloadingTipIntensity = 0;
		tip = nil;
		return
	end

    -- Get a new tip if required
    if tip == nil then 
        tip = loadingtips[math.random(tableSize(loadingtips))];
    end

	-- 0,0 is center of screen
	local w = 400;
	local h = 180;
	local x = -w/2;
	local y = (viewport.height / 2) - h;

	-- Background, to avoid showing the sky color all the time.
    nvgBeginPath();
    nvgRect(-(viewport.width/2), -(viewport.height/2), viewport.width, viewport.height);
    nvgFillColor(Color(10,10,10,255));
    nvgFill();
	
    -- Logo
    local svgName = "internal/ui/icons/reflexlogo";
	nvgFillColor(Color(20,20,20,255));
	nvgSvg(svgName, 0, -100, 250);

	nvgFontSize(18);
	nvgFontFace(FONT_TEXT);

	-- server "Downloading" Text
	if loading.isWorkshopMap and not loading.serverDownloadFinished then
		local fontx = 0;
		local fonty = y + h - 20;
		nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
		nvgFillColor(Color(230, 230, 230));

		local text;
		if loading.serverDownloadTotal == 0 then
			text = "Server Querying Steam Workshop..";
		else
			local percent = (loading.serverDownloadAmount / loading.serverDownloadTotal) * 100;
			text = string.format("Server Downloading from Steam Workshop %.0f%% (%d of %d)", percent, loading.serverDownloadAmount, loading.serverDownloadTotal);
		end

		nvgText(fontx, fonty, text);
	end

	-- client "Downloading" Text
    local fontx = 0;
	local fonty = y + h - 40;
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
	nvgFillColor(Color(230, 230, 230));
	local text, progressPercent;
	if loading.gameStateTotal == 0 then
		text = "Loading Map..";
		progressPercent = 0;
	else
		text = "Downloading gamestate..";
		progressPercent = loading.gameStateAmount / loading.gameStateTotal;
	end
	if loading.downloadingGameState == false and loading.isWorkshopMap then
		if loading.clientDownloadFinished then
			text = "Workshop download complete, awaiting server..";
			progressPercent = 0;
		elseif loading.clientDownloadTotal == 0 then
			text = "Querying Steam Workshop..";
			progressPercent = 0;
		else
			text = "Downloading from Steam Workshop.. " .. loading.clientDownloadAmount .. " of " .. loading.clientDownloadTotal;
			progressPercent = loading.clientDownloadAmount / loading.clientDownloadTotal;
		end
	end
	nvgText(fontx, fonty, text);

	-- if stuck downloading, bring up tooltip
	if (loading.isWorkshopMap) then
		self.downloadingTime = self.downloadingTime + deltaTimeRaw;
	end
	if (self.downloadingTime > 10) and (progressPercent == 0) then
		self.downloadingTipIntensity = math.min(self.downloadingTipIntensity + deltaTimeRaw, 1);
	else
		self.downloadingTipIntensity = math.max(self.downloadingTipIntensity - deltaTimeRaw, 0);
	end
	if self.downloadingTipIntensity > 0 then
		local ix = 240;
		local iy = y + h - 60;
		local optags = {};
		optags.intensity = self.downloadingTipIntensity;
		ui2Tooltip("Make sure your steam download queue is empty!", ix, iy, optags);
	end

	-- client progress bar
	local progressx = x + 20;
	local progressy = y + 80;
	local progresswidth = w - 40;
	local percent = 1;
	uiProgressBar(progressx, progressy, progresswidth, UI_DEFAULT_BUTTON_HEIGHT, progressPercent);

    -- Loading tips
    nvgBeginPath();
    nvgFontSize(36);
	nvgFontFace(FONT_HUD);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
    nvgText(0, progressy - 40, tip);
    nvgFillColor(Color(230,230,230,255));
    nvgFill();
    
    -- Number of gamestates download / total.
	--local text = download.amount .. " / " .. download.total;
	--local fontx = x + w - 22;
	--local fonty = y + h - 50;
	--nvgTextAlign(NVG_ALIGN_RIGHT, NVG_ALIGN_BASELINE);
	--nvgFontBlur(2);
	--nvgFillColor(Color(0, 0, 0));
	--nvgText(fontx, fonty + 1, text);
	--nvgFontBlur(0);
	--nvgFillColor(Color(230, 230, 230));
	--nvgText(fontx, fonty, text);
end
