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

Vote =
{
};
registerWidget("Vote");

--------------------------------------------------------------------------------
-- find map, off disk. (yes the map list off disk isn't same as list on server, but we'll assume people are using workshop and distributed maps aren't really messed with)
--------------------------------------------------------------------------------
local function findMap(mapName)
	mapName = string.upper(mapName);
	for k, v in ipairs(maps) do
		if string.upper(v.mapName) == mapName then
			local mapName = string.len(v.title) > 0 and v.title or v.mapName;
			return mapName, v.previewImageName;
		end
	end
	return nil;		
end

--------------------------------------------------------------------------------
-- find map in query results, or start query
--------------------------------------------------------------------------------
local function findWorkshop(id)
	-- already queried it? (it may be in the existing query already done by going to the menu)
	if workshopSpecificMap ~= nil and workshopSpecificMap.id == id then
		return workshopSpecificMap.title, workshopSpecificMap.previewImageName;
	end

	-- not queried..
	if not workshopIsQueryingSpecificMap() then
		-- todo: record it failed so we don't query again..?
		-- do query
		workshopQuerySpecificMap(id);
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Vote:draw()
	local active = true;
	
	-- init
	if self.intensity == nil then
		self.intensity = 0;
	end
	
	-- bail out entirely
	if not vote.active then 
		self.intensity = 0;
		return;
	end;

    -- visible?
	--if not shouldShowHUD() then (we want less restrictive)
	if	loading.loadScreenVisible or consoleGetVariable("cl_show_hud") == 0 or isInMenu() then
		active = false
	end
    
	-- determine time remaining
	local time = vote.timeRemaining;
	local ms = time % 1000;
	time = math.floor(time / 1000);
	local seconds = time % 60;

	-- visible?
	if vote.timeRemaining == 0 and vote.failed then active = false end;

	-- fade in/out
	if active then
		self.intensity = math.min(self.intensity + deltaTimeRaw*5, 1);
	else
		self.intensity = math.max(self.intensity - deltaTimeRaw*5, 0);
	end

	-- early out
	if self.intensity == 0 then
		return;
	end

	-- look up player
	local playerName = "<disconnected>";
	if vote.playerIndex > 0 then
		local p = players[vote.playerIndex];
		if p ~= nil then
			playerName = p.name;
		end
	end

	-- count votes
	local yesCount = 0;
	local noCount = 0;
	for k, v in pairs(vote.votes) do
		if v.votedYes then
			yesCount = yesCount + 1;
		elseif v.voted then
			noCount = noCount + 1;
		end
	end

	-- inspect vote command, for nicer formatting etc
	local centerHeader = vote.command;
	local centerImageName = nil;
	local centerImageText = nil;
	local centerText = "";
	if string.sub(vote.command, 0, 4) == "map " then
		-- lookup
		local mapName = string.sub(vote.command, 5);
		local title, image = findMap(mapName);
		
		-- format
		if title ~= nil and image ~= nil then
			centerHeader = "Map: ";
			centerImageName = image;
			centerText = title;
		end
	elseif vote.command == "shuffle" then
		centerHeader = "Shuffle Teams";
	elseif string.sub(vote.command, 0, 5) == "mode " then
		centerHeader = "Mode: ";
		centerText = string.upper(string.sub(vote.command, 6));
	elseif string.sub(vote.command, 0, 5) == "wmap " then
		-- lookup
		local id = string.upper(string.sub(vote.command, 6));
		local title, image = findWorkshop(id);

		-- format
		centerHeader = "Map: ";
		centerText = title ~= nil and title or id;
		centerImageText = "(Querying)";	
		centerImageName = image;
	elseif string.sub(vote.command, 0, 6) == "match " then
		-- decode
		local s = string.sub(vote.command, 7);
		words = {}
		for word in s:gmatch("%w+") do table.insert(words, word) end
		local mode = words[1];
		local mapName = string.upper(words[2]);
		
		-- lookup
		local title, image = findMap(mapName);
		
		-- format
		if title ~= nil and image ~= nil then
			centerHeader = "Match: ";
			centerImageName = image;
			centerText = string.upper(mode) .. " on " .. title;
		end
	elseif string.sub(vote.command, 0, 7) == "wmatch " then
		-- decode
		local s = string.sub(vote.command, 8);
		words = {}
		for word in s:gmatch("%w+") do table.insert(words, word) end
		local mode = words[1];
		local mapid = words[2];

		-- lookup
		local title, image = findWorkshop(mapid);

		-- format
		centerHeader = "Match: ";
		centerText = id;
		
		centerHeader = "Match: ";
		centerText = string.upper(mode) .. " on " .. (title ~= nil and title or mapid);
		centerImageText = "(Querying)";	
		centerImageName = image;
	end

	local hoverAmount = 0;
	local enabled = true;
	local intensity = self.intensity;
	
	local headerHeight = 45;
	local footerHeight = 45;
	local centerHeight = 100;
	local centerImageHeight = 80;
	local centerImageWidth = 16 / 9 * centerImageHeight;
	local pad = 10;

	local x = 0;
	local y = 0;
	local w = 500;
	local h = headerHeight + centerHeight + footerHeight;

	nvgSave();

	-- background center
	local bgCol = ui2FormatColor(UI2_COLTYPE_BACKGROUND, intensity, hoverAmount, true);

	nvgBeginPath();
	nvgRect(x, y+headerHeight, w, centerHeight, 5);
	nvgFillColor(bgCol);
	nvgFill();

	-- background header
	bgCol = Color(0,0,0,178*intensity);
	nvgBeginPath();
	nvgRect(x, y, w, headerHeight, 5);
	nvgFillColor(bgCol);
	nvgFill();

	-- background footer
	nvgBeginPath();
	nvgRect(x, y+headerHeight + centerHeight, w, footerHeight, 5);
	nvgFillColor(bgCol);
	nvgFill();

	-- clip
	nvgIntersectScissor(x, y, w, h);

	-- header text (right)
	local text = nil;
	local icon = nil;
	if vote.passed then
		text = "Vote Passed!";
		icon = "internal/ui/icons/tick";
		iconColor = Color(16,255,16, 255*intensity);
	elseif vote.failed then
		text = "Vote Failed!";
		icon = "internal/ui/icons/checkBoxTick";
		iconColor = Color(255,16,16, 255*intensity);
	else
		text = string.format("%d second%s remaining", seconds, seconds==1 and "" or "s");
	end
	local ix = x+w-10;
	local iy = y + headerHeight/2;
	if icon ~= nil then
		ix = ix - 20;
		nvgFillColor(iconColor);
		nvgSvg(icon, ix, iy, 10);
		ix = ix - 20;
	end
	nvgFillColor(ui2FormatColor(UI2_COLTYPE_TEXT, intensity, hoverAmount, false));
	nvgFontSize(24);
	nvgTextAlign(NVG_ALIGN_RIGHT, NVG_ALIGN_MIDDLE);
	nvgFontFace("titilliumWeb-regular");
	nvgText(ix, iy, text);
	local headerRightStartX = ix - nvgTextWidth(text)-15;

	-- header text (left)
	nvgFontFace("Oswald-Regular");
	nvgFontSize(28);
	nvgFillColor(ui2FormatColor(UI2_COLTYPE_TEXT, intensity, hoverAmount, enabled));
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	local playerNameShort = playerName;
	local text = string.upper(playerNameShort .. " has called a vote");
	while x + 10 + nvgTextWidth(text) >= headerRightStartX and string.len(playerNameShort) > 0 do
		playerNameShort = string.sub(playerNameShort, 0, string.len(playerNameShort)-1);
		text = string.upper(playerNameShort .. "... has called a vote");
	end
	nvgText(x+10, y + headerHeight/2, text);

	-- center image
	local centerMin = x;
	local centerMax = x + w;
	if centerImageName ~= nil or centerImageText ~= nil then
		local ix = x + pad;
		local iy = y + headerHeight + centerHeight/2 - centerImageHeight/2;
		local iwidth = centerImageWidth;
		local iheight = centerImageHeight;
		
		if centerImageText ~= nil then
			nvgFillColor(ui2FormatColor(UI2_COLTYPE_TEXT, intensity, hoverAmount, false));
			nvgFontSize(24);
			nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
			nvgFontFace("titilliumWeb-regular");
			nvgText(ix+iwidth/2, iy +iheight/2, centerImageText);
		end
		if centerImageName ~= nil then
			nvgBeginPath();
			nvgRect(ix, iy, iwidth, iheight);
			nvgFillColor(Color(0,0,0,0)); -- if not loaded yet we'll just display transparent, so you can see centerImageText
			nvgFillImagePattern(centerImageName, ix-iwidth*.25, iy-iheight*.25, iwidth*1.5, iheight*1.5, 0, 255); -- (center quarter of image)
			nvgFill();
		end
		
		centerMin = ix + iwidth + pad;
	end

	-- center
	nvgFillColor(ui2FormatColor(UI2_COLTYPE_TEXT, intensity, hoverAmount, true));
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	nvgFontSize(36);
	nvgFontFace("titilliumWeb-bold");
	local twHeader = nvgTextWidth(centerHeader);
	nvgFontFace("titilliumWeb-regular");
	local twText = nvgTextWidth(centerText);
	local tw = twHeader + twText;
	local ix = (centerMin+centerMax)/2 - tw/2;
	local iy = y + headerHeight + centerHeight/2;
	nvgFontFace("titilliumWeb-bold");
	nvgText(ix, iy, centerHeader);
	nvgFontFace("titilliumWeb-regular");
	nvgText(ix+twHeader, iy, centerText);

	-- footer
	nvgFontSize(30);
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	nvgFontFace("titilliumWeb-regular");
	local textCol = ui2FormatColor(UI2_COLTYPE_TEXT, intensity, hoverAmount, true);
	local iy = y+headerHeight+centerHeight+footerHeight/2;
	
	-- vote yes
	local yesKey = string.upper(bindReverseLookup("vote_yes", "game"));
	local yesCol = Color(
		textCol.r * (70/255),
		textCol.g * (255/255),
		textCol.b * (70/255),
		textCol.a);

	local yesLen = nvgTextWidth("Vote YES ("..yesKey.."): "..yesCount);
	local ix = x + w/2-100-yesLen/2;
	
	text = "Vote YES ";
	nvgFillColor(textCol);
	nvgText(ix, iy, text);
	ix = ix + nvgTextWidth(text);

	text = "("..yesKey..")";
	nvgFillColor(yesCol);
	nvgText(ix, iy, text);
	ix = ix + nvgTextWidth(text);
	
	text = ": "..yesCount;
	nvgFillColor(textCol);
	nvgText(ix, iy, text);

	-- vote no
	local noKey = string.upper(bindReverseLookup("vote_no", "game"));
	local noCol = Color(
		textCol.r * (255/255),
		textCol.g * (70/255),
		textCol.b * (70/255),
		textCol.a);

	local noLen = nvgTextWidth("Vote NO ("..noKey.."): "..noCount);
	local ix = x + w/2+100-noLen/2;
	
	text = "Vote NO ";
	nvgFillColor(textCol);
	nvgText(ix, iy, text);
	ix = ix + nvgTextWidth(text);

	text = "("..noKey..")";
	nvgFillColor(noCol);
	nvgText(ix, iy, text);
	ix = ix + nvgTextWidth(text);
	
	text = ": "..noCount;
	nvgFillColor(textCol);
	nvgText(ix, iy, text);

	nvgRestore();
end
