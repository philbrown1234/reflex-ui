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

AwardNotifier =
{
	canPosition = true,

	upToId = 0,

	awards = {},
	awardCount = 0,

	announcer = "internal/announcer/electro";

	-- user data, we'll save this into engine so it's persistent across loads
	userData = {};
};
registerWidget("AwardNotifier");

local function InOutQuadBlend(t)
	if t <= 0.5 then
		return 2 * t * t;
	end
	t = t - 0.5;
	return 2.0 * t * (1.0 - t) + 0.5;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function LerpLinear(time, value, timeA, timeB, valueA, valueB)
	if time < timeA then
		return value;
	elseif time > timeB then
		return valueB;
	else
		local percent = (time - timeA) / (timeB - timeA);
		return lerp(valueA, valueB, percent);
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function LerpEaseInEaseOut(time, value, timeA, timeB, valueA, valueB)
	if time < timeA then
		return value;
	elseif time > timeB then
		return valueB;
	else
		local percent = (time - timeA) / (timeB - timeA);
		percent = InOutQuadBlend(percent);
		return lerp(valueA, valueB, percent);
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function LerpEaseIn(time, value, timeA, timeB, valueA, valueB)
	if time < timeA then
		return value;
	elseif time > timeB then
		return valueB;
	else
		local percent = (time - timeA) / (timeB - timeA);
		percent = percent * percent;
		return lerp(valueA, valueB, percent);
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AwardNotifier:initialize()
	-- load data stored in engine
	self.userData = loadUserData();
	
	-- ensure it has what we need
	CheckSetDefaultValue(self, "userData", "table", {});
	CheckSetDefaultValue(self.userData, "playAwardSound", "boolean", true);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AwardNotifier:finalize()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AwardNotifier:drawAward(time, awardName, awardAmount, iconName, iconScale)
	local iconCol = Color(212, 16, 8);
	local awardCol = Color(232, 232, 232);
	local experience = awardAmount;
	local experienceCol = Color(232, 232, 232);

	local ix = 0;
	local iy = 0;

	-- hackish, push it down in spectator mode
	if playerIndexCameraAttachedTo ~= playerIndexLocalPlayer then
		iy = iy + 40;
	end

	-- icon
	-- show icon white, fade away
	-- show bg dark red, don't fade
	local iconIntensity = .8;
	local iconOffsetY = iy;
	--iconIntensity = LerpEaseInEaseOut(time, iconIntensity, 0.0, 0.1, 0, .8);
	iconIntensity = LerpEaseInEaseOut(time, iconIntensity, 1.0, 2.0, .8, 0);
	--iconOffsetY = LerpEaseIn(time, iconOffsetY, 1.0, 2.0, 0, -40);
	nvgSave();
	nvgTranslate(0, iconOffsetY);
	nvgScale(iconScale, iconScale);
	nvgFillColor(Color(0, 0, 0, 80 * iconIntensity));
	nvgSvg(iconName, ix, 0, 30, 4);
	nvgFillColor(Color(iconCol.r, iconCol.g, iconCol.b, iconCol.a * iconIntensity));
	nvgSvg(iconName, ix, 0, 30);
	nvgRestore();

	-- -- +30 experience
	local experienceScale = 1;
	local experienceIntensity = 1;
	local experienceOffsetY = 20;
	experienceIntensity = LerpEaseInEaseOut(time, experienceIntensity, 1.0, 2.0, 1, 0);
	experienceOffsetY = LerpEaseIn(time, experienceOffsetY, 1.0, 2.0, 20, 30);
	nvgSave();
	nvgTranslate(ix, iy+50+experienceOffsetY);
	nvgScale(experienceScale, experienceScale);
	nvgFontSize(40);
	nvgFontFace("titilliumWeb-regular");
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
	nvgFontBlur(4);
	nvgFillColor(Color(0, 0, 0, 64 * experienceIntensity));
	nvgText(0, 0, "+"..experience);
	nvgFillColor(Color(experienceCol.r, experienceCol.g, experienceCol.b, experienceCol.a * experienceIntensity));
	nvgFontBlur(0);
	nvgText(0, 0, "+"..experience);
	nvgRestore();
	
	-- -- +CHAIN KILL
	local awardScale = 1;
	local awardIntensity = 1;
	local awardOffsetY = -90;
	awardIntensity = LerpEaseInEaseOut(time, awardIntensity, 1.0, 2.0, 1, 0);
	awardOffsetY = LerpEaseIn(time, awardOffsetY, 1.0, 2, -90, -100);
	nvgSave();
	nvgTranslate(ix, iy+10+awardOffsetY);
	nvgScale(awardScale, awardScale);
	nvgFontSize(50);
	nvgFontFace("titilliumWeb-bold");
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
	nvgFontBlur(4);
	nvgFillColor(Color(0, 0, 0, 64 * awardIntensity));
	nvgText(0, 0, awardName);
	nvgFontBlur(0);
	nvgFillColor(Color(awardCol.r, awardCol.g, awardCol.b, awardCol.a * awardIntensity));
	nvgText(0, 0, awardName);
	nvgRestore();
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AwardNotifier:addAward(name, amount, icon, iconScale, sound)
	self.awardCount = self.awardCount + 1;
	self.awards[self.awardCount] = {};
	self.awards[self.awardCount].name = name;
	self.awards[self.awardCount].icon = icon;
	self.awards[self.awardCount].iconScale = iconScale;
	self.awards[self.awardCount].age = 0;
	self.awards[self.awardCount].sound = sound;
	self.awards[self.awardCount].amount = amount;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AwardNotifier:draw()
	local logCount = 0;
	for k, v in pairs(log) do
		logCount = logCount + 1;
	end
	
	-- if we change player following, clear award queue (or on post-game screen)
	if (self.playerIndexAttachedTo ~= playerIndexCameraAttachedTo) or (world.gameState == GAME_STATE_GAMEOVER) then
		self.playerIndexAttachedTo = playerIndexCameraAttachedTo;
		self.awardCount = 0;

		-- ignore old awards (set self.upToId)
		self.upToId = 0;
		for i = 1, logCount do
			local logEvent = log[i];
			if (logEvent.type == LOG_TYPE_AWARD and logEvent.awardPlayerIndex == playerIndexCameraAttachedTo) then
				self.upToId = math.max(self.upToId, logEvent.id);
			end
		end
	end

    -- Early out if HUD shouldn't be shown.
	local optargs = {};
	optargs.showWhenDead = true;
    if not shouldShowHUD(optargs) then return end;

	-- read new awards
	local upToId = self.upToId;
	for i = logCount, 1, -1 do	-- iterate in reverse, seems they're delivered in reverse order (for chat iirc)
		local logEvent = log[i];
		if (logEvent.type == LOG_TYPE_AWARD and logEvent.awardPlayerIndex == playerIndexCameraAttachedTo) then

			local t = awardDefinitions[logEvent.awardType];
			local amount = logEvent.awardAmount;
			if t ~= nil and t.name ~= nil and amount ~= nil then
				-- new award?
				if upToId < logEvent.id then
					self.upToId = math.max(self.upToId, logEvent.id);

					-- record awards in our own queue, so we can see them after
					self:addAward(t.name, amount, t.icon, t.iconScale, t.sound);
				end
			end
		end
	end

	-- update award queue
	if self.awardCount > 0 then
		local a = self.awards[1];

		-- new award? play sound
		if (a.age == 0) and (self.userData.playAwardSound) then
			playSound("internal/ui/awards/notifyAward");
			playSound("internal/ui/awards/notifyAward");

			-- don't play VO post game (things like hatrick / flawless fire - we don't want them to interrupt the end of game announcer)
			if world.gameState == GAME_STATE_ACTIVE or world.gameState == GAME_STATE_WARMUP then
				if a.sound ~= nil then
					local interrupt = true
					playAnnouncer("award_"..a.sound, interrupt)
				end
			end
		end

		-- age it
		a.age = a.age + deltaTime;

		-- speed up if there are more coming
		if self.awardCount > 1 and a.age > 1 then
			a.age = a.age + deltaTime;
		end

		-- award finished?
		-- => take it out, and pull others down
		if a.age > 2 then
			for i = 1, self.awardCount-1 do
				self.awards[i] = self.awards[i+1];
			end
			self.awardCount = self.awardCount - 1;
		end
	end

	-- draw active award
	if self.awardCount > 0 then
		local a = self.awards[1];
		self:drawAward(a.age, a.name, a.amount, a.icon, a.iconScale);
	end

	--[[ testin..
	if self.time == nil then
		self.time = 0;
	end
	if self.award == nil then
		self.award = AWARD_SAVIOUR;
	end
	-- self.award = AWARD_HATTRICK;
	self:drawAward(self.time, awardDefinitions[self.award].name, 0, awardDefinitions[self.award].icon, awardDefinitions[self.award].iconScale);
	self.time = self.time + deltaTimeRaw;
	if self.time > 1 then
		self.time = self.time + deltaTimeRaw;
	end
	if self.time > 2 then
		self.time = 0;
		self.award = self.award + 1;
		
		if self.award == AWARD_PINEAPPLE+1 then
			self.award = AWARD_FIRSTBLOOD;
		end

		playSound("internal/ui/awards/notifyAward");
		playSound("internal/ui/awards/notifyAward");
	end
	--]]
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AwardNotifier:drawOptions(x, y, intensity)
	local optargs = {};
	optargs.intensity = intensity;

	local user = self.userData;
	
	user.playAwardSound = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Award Sound", user.playAwardSound, optargs);
	y = y + 60;

	saveUserData(user);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AwardNotifier:getOptionsHeight()
	return 60; -- debug with: ui_menu_show_widget_properties_height 1
end
