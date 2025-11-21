--------------------------------------------------------------------------------
-- This is an official Reflex script. Do not modify.
--
-- If you wish to customize this widget, please:
--  * clone this file to a new file
--  * rename the widget MyWidget
--  * set this widget to not visible (via options menu)
--  * set your new widget to visible (via options menu)
--
-- Thanks to Kered for KeredFragMessages
-- Thanks to Qualx for DuelFragMessages
--
--------------------------------------------------------------------------------

require "base/internal/ui/reflexcore"

FragNotifier =
{
	-- Settings
	fontSize = 50;
	fontFace = FONT_HUD;
	defaultFontColor = Color(255,255,255);
	defaultShadowColor = Color(0,0,0,255);
};
registerWidget("FragNotifier");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function FragNotifier:initialize()
	-- load data stored in engine
	self.userData = loadUserData();
	
	-- ensure it has what we need
	CheckSetDefaultValue(self, "userData", "table", {});
	CheckSetDefaultValue(self.userData, "useYou", "boolean", true);
	CheckSetDefaultValue(self.userData, "messageDisplayTime", "number", 2.5);
	CheckSetDefaultValue(self.userData, "messageFadeIn", "number", 0.1);
	CheckSetDefaultValue(self.userData, "messageFadeOut", "number", 0.5);
	CheckSetDefaultValue(self.userData, "message", "string", "You fragged $victim");
	
	self.optionsHeight = 0;
	self.lastLogEntryId = 0;
end

------------------------------------------
------------------------------------------
function FragNotifier:drawOptions(x, y)
	saveUserData(user);

	local optargs = {};
    optargs.intensity = intensity;

    local sliderWidth = 200;
    local sliderStart = 140;
    local user = self.userData;

    user.useYou = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Use You", user.useYou, optargs);
    y = y + 60;

    ui2Label("Frag Message", x, y, optargs);
    user.message = ui2EditBox(user.message, x+WIDGET_PROPERTIES_COL_INDENT, y, WIDGET_PROPERTIES_COL_WIDTH-WIDGET_PROPERTIES_COL_INDENT,  optargs);
    ui2Tooltip("Use $killer for the killer's name, and $victim for the victim's name.", x+WIDGET_PROPERTIES_COL_WIDTH, y, optargs);
    y = y + 60;
    
    user.messageDisplayTime = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Message Display Time", user.messageDisplayTime, 0, 5.0, optargs);
    y = y + 60;

    user.messageFadeIn = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Message Fade In", user.messageFadeIn, 0, 1.0, optargs);
    y = y + 60;

    user.messageFadeOut = ui2RowSliderEditBox2Decimals(x, y, WIDGET_PROPERTIES_COL_INDENT, WIDGET_PROPERTIES_COL_WIDTH, 80, "Message Fade Out", user.messageFadeOut, 0, 5.0, optargs);
    y = y + 60;

    saveUserData(user);
end


------------------------------------------
------------------------------------------
local lastScore = {};
local lastFragMessage = "";
local displayFor = 0;

function FragNotifier:setFragMessage(killerName, victimName)
	local user = self.userData;
	local message = user.message;
	
	if user.useYou and killerName == getLocalPlayer().name then
		killerName = "You";
	end
	
	message = string.gsub(message, "$killer", killerName);
	message = string.gsub(message, "$victim", victimName);
	
	lastFragMessage = message;
	displayFor = user.messageFadeIn + user.messageDisplayTime + user.messageFadeOut;
end

function FragNotifier:printLastFragMessage()
	local user = self.userData;
	local fontAlpha = 255;
	local fontShadowAlpha = 255;

	local fontColor = self.defaultFontColor;
	local shadowColor = self.defaultShadowColor;

	-- total time a message can be shown for
	local messageTimeTotal = user.messageFadeIn + user.messageDisplayTime + user.messageFadeOut;

	local fadeInPeriod = messageTimeTotal - user.messageFadeIn;
	local fadeOutPeriod = user.messageFadeOut;

	local posY = 0;

	-- fade in
	-- displaying for less time than fadein period
	if displayFor > fadeInPeriod then
		fontAlpha = fontColor.a * lerp(0, 1, fadeInPeriod / displayFor);
		fontShadowAlpha = shadowColor.a * lerp(0, 1, fadeInPeriod / displayFor);

		-- start low and slide in a little bit
		-- just relative to the size of the font
		posY = lerp(self.fontSize*1.5, 0, fadeInPeriod / displayFor);
	end

	-- fade out
	-- fadeOutPeriod is longer than display time left
	if displayFor < fadeOutPeriod then
		fontAlpha = fontColor.a * lerp(0, 1, displayFor / fadeOutPeriod);
		fontShadowAlpha = shadowColor.a * lerp(0, 1, displayFor / fadeOutPeriod);
	end

	nvgBeginPath();
	nvgFontSize(self.fontSize);
	nvgFontFace(self.fontFace);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
	nvgFontBlur(2);
	nvgFillColor(Color(shadowColor.r, shadowColor.g, shadowColor.b, fontShadowAlpha));
	nvgText(0,posY,lastFragMessage);
	nvgFontBlur(0);
	nvgFillColor(Color(fontColor.r, fontColor.g, fontColor.b, fontAlpha));
	nvgText(0,posY,lastFragMessage);
end

function FragNotifier:draw()
	if getPlayer() == nil
		or getPlayer().state == PLAYER_STATE_EDITOR
		or consoleGetVariable("cl_show_hud") == 0
		or isInMenu() then
		--or not getPlayer().connected then -- removed this check so you get the messages when spectating others
			if displayFor > 0 then displayFor = displayFor - deltaTimeRaw;
			elseif next(lastScore) then lastScore = {}; displayFor = 0; lastFragMessage = ""; end;
			return;
	else
		local player = getPlayer();
		local newLogEntry = log[1];
		if newLogEntry ~= nil and newLogEntry.id ~= self.lastLogEntryId then
			self.lastLogEntryId = newLogEntry.id;
			if newLogEntry.type == LOG_TYPE_DEATHMESSAGE and not newLogEntry.deathSuicide and
			   newLogEntry.deathKiller == player.name then
				self:setFragMessage(player.name, newLogEntry.deathKilled);
			end
		end
		if displayFor > 0 then
			displayFor = displayFor - deltaTimeRaw;
			self:printLastFragMessage();
		end
	end
end

