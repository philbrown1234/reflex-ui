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

Announcer =
{
	canHide = false,		-- removes it from widget list, if you want to disable announcer use s_announcer_volume
	canPosition = false,
	canMove = false,

	lastMinutesRemaining = 100,
	relativeScoreSign = 0,
	lastLogId = nil
};
registerWidget("Announcer");


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function IsMatchPoint()
	local gameMode = gamemodes[world.gameModeIndex];
	local pointsToWin = gameMode.pointsToWin;

	local scores = { };
	local topName = "";
	scores[1] = 0;
	scores[2] = 0;
	
	if gameMode.hasTeams then
		scores[1] = world.teams[1].score;
		scores[2] = world.teams[2].score;
	else
		local topPlayers = {};
		if getTopTwoPlayers(topPlayers) then
			scores[1] = topPlayers[1].score;
			scores[2] = topPlayers[2].score;
		end
	end

	local topScore = math.max(scores[1], scores[2]);
	if topScore >= (pointsToWin - 1) then
		if scores[1] == scores[2] then
			return false
		else
			return true
		end
	end

	return false;
end

--------------------------------------------------------------------------------
-- individual game: MY SCORE, BEST ENEMY SCORE
-- team game: MY TEAM SCORE, ENEMY TEAM SCORE
--------------------------------------------------------------------------------
local function GetScores()
	local localPlayer = getLocalPlayer()
	if localPlayer ~= nil and localPlayer.state == PLAYER_STATE_INGAME then

		-- team?
		local gameMode = gamemodes[world.gameModeIndex];
		if gameMode.hasTeams then
			local myTeam = localPlayer.team
			local enemyTeam = myTeam == 1 and 2 or 1
			local myTeamScore = world.teams[myTeam].score
			local enemyTeamScore = world.teams[enemyTeam].score

			return myTeamScore, enemyTeamScore
		else
			-- solo..
			local myScore = localPlayer.score
	
			local bestEnemyScore = -10000
			for k, v in ipairs(players) do
				if k ~= playerIndexLocalPlayer and v.connected then
					bestEnemyScore = math.max(bestEnemyScore, v.score)
				end
			end

			return myScore, bestEnemyScore
		end
	end

	-- unknown / not relevant (i.e. we're spectating)
	return 0, 0
end

--------------------------------------------------------------------------------
-- this allows to easily call playAnnouncerUnique() for multiple frames in a 
-- row, yet only actually play the sound the first time
--------------------------------------------------------------------------------
function Announcer:playAnnouncerUnique(sound, group, interrupt)
	if self.announcerCache == nil then
		self.announcerCache = {}
	end

	if self.announcerCache[group] == nil then
		self.announcerCache[group] = {}
	end		

	local shouldPlay = self.announcerCache[group].sound ~= sound
	self.announcerCache[group].playedThisFrame = true
	self.announcerCache[group].sound = sound
	
	if shouldPlay and sound ~= nil then
		playAnnouncer(sound, interrupt)
	end
end

--------------------------------------------------------------------------------
-- if any groups wern't utilized this frame, clear them out
--------------------------------------------------------------------------------
function Announcer:postUpdateAnnouncerUnique()
	if self.announcerCache == nil then 
		return
	end

	for k, v in pairs(self.announcerCache) do
		if v.playedThisFrame == false then
			self.announcerCache[k] = nil
		end
		v.playedThisFrame = false
	end
end

--------------------------------------------------------------------------------
-- Countdown
--------------------------------------------------------------------------------
function Announcer:countdown(gameType, visible)
	if world.timerActive then
		if world.gameState == GAME_STATE_WARMUP or world.gameState == GAME_STATE_ROUNDPREPARE then

			local timeRemaining = world.gameTimeLimit - world.gameTime;
			local t = FormatTime(timeRemaining);

			-- this flicks to 0 some times, just clamp it to 1
			t.seconds = math.max(1, t.seconds);
	
			if self.lastTickSeconds ~= t.seconds then
				self.lastTickSeconds = t.seconds;
				if t.seconds == 7 then
					if world.gameState == GAME_STATE_ROUNDPREPARE then
						playAnnouncer("Match_RoundBeginsIn", true);
					else
						playAnnouncer("Match_BeginsIn", true);
					end
				end
				if t.seconds <= 5 then
					playAnnouncer("Match_Countdown_" .. tostring(t.seconds), true);
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
-- FIGHT! / OVERTIME!
--------------------------------------------------------------------------------
function Announcer:fightOvertime()
	if world.timerActive then
		if world.gameState == GAME_STATE_ACTIVE or world.gameState == GAME_STATE_ROUNDACTIVE then
			if world.gameTime < 2000 then
				if world.overTimeCount == 0 then
					local gameMode = gamemodes[world.gameModeIndex];
					local introSound = "Match_CountDown_Fight";

					if world.gameState == GAME_STATE_ROUNDACTIVE and IsMatchPoint() then
						introSound = "Match_MatchPoint";
					end

					if gameMode.shortName == "race" then introSound = nil end;			-- don't use Match_Countdown_Go, as there is no countdown
					if gameMode.shortName == "training" then introSound = nil end;		-- don't use Match_Countdown_Go, as there is no countdown

					self:playAnnouncerUnique(introSound, "ot", true)
				elseif world.overTimeCount == 1 then
					self:playAnnouncerUnique("Match_Overtime", "ot", true)
				elseif world.overTimeCount == 2 then
					self:playAnnouncerUnique("Match_Overtime_2", "ot", true)
				elseif world.overTimeCount == 3 then
					self:playAnnouncerUnique("Match_Overtime_3", "ot", true)
				else
					self:playAnnouncerUnique("Match_Overtime", "ot", true)
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
-- TIME REMAINING
--------------------------------------------------------------------------------
function Announcer:timeRemaining()
	if world.timerActive and world.gameState == GAME_STATE_ACTIVE then
		local timeRemaining = world.gameTimeLimit - world.gameTime;
		local t = FormatTime(math.max(timeRemaining - 2000, 0));
		local minutesRemaining = t.minutes + 1;

		if self.lastMinutesRemaining > minutesRemaining then
			self.lastMinutesRemaining = minutesRemaining
			if minutesRemaining <= 5 and minutesRemaining > 0 then
				-- don't play time remaining for first 30seconds of match.. (i.e. don't play 5seconds remaining as casual duel starts..)
				if world.gameTime > 30 * 1000 then
					self:playAnnouncerUnique("Match_CountDown_Time_" .. minutesRemaining, "timeLeft")
				end
			end
		end
	else
		self.lastMinutesRemaining = 100
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Announcer:whoHasLeads()
	-- only play when game active (yes, excludes round-based modes)
	if world.gameState ~= GAME_STATE_ACTIVE then
		self.relativeScoreSign = 0
		return
	end
	
	-- no leads etc in these modes
	local gameMode = gamemodes[world.gameModeIndex];
	if gameMode.shortName == "race" then return end;
	if gameMode.shortName == "training" then return end;

	local localPlayer = getLocalPlayer()
	if localPlayer ~= nil and localPlayer.state == PLAYER_STATE_INGAME then
		-- relative (ie: you / your team)
		local myScore, enemyScore = GetScores()
		local relativeScoreNewSign = sign(myScore - enemyScore)
	
		if self.relativeScoreSign ~= relativeScoreNewSign then
			self.relativeScoreSign = relativeScoreNewSign

			if gameMode.hasTeams then
				-- teams
				local interrupt = false
				if self.relativeScoreSign > 0 then
					playAnnouncer("Match_Team_YourTeamHasTakenTheLead", interrupt)
				elseif self.relativeScoreSign == 0 then
					playAnnouncer("Match_Team_TeamsAreTied", interrupt)
				else
					playAnnouncer("Match_Team_YourTeamHasLostTheLead", interrupt)
				end

			else
				-- relative
				local interrupt = false
				if self.relativeScoreSign > 0 then
					playAnnouncer("Match_YouHaveTakenTheLead", interrupt)
				elseif self.relativeScoreSign == 0 then
					playAnnouncer("Match_YouAreTiedForTheLead", interrupt)
				else
					playAnnouncer("Match_YouHaveLostTheLead", interrupt)
				end
			end
		end
	else
		-- absolute (ie: alpha team)
		if gameMode.hasTeams then
			-- teams
			local relativeScoreNewSign = sign(world.teams[1].score - world.teams[2].score)
			if self.relativeScoreSign ~= relativeScoreNewSign then
				self.relativeScoreSign = relativeScoreNewSign

				local interrupt = false
				if self.relativeScoreSign > 0 then
					playAnnouncer("Match_Team_AlphaLeads", interrupt)
				elseif self.relativeScoreSign == 0 then
					playAnnouncer("Match_Team_TeamsAreTied", interrupt)
				else
					playAnnouncer("Match_Team_ZetaLeads", interrupt)
				end
			end
		else
			-- individual
			-- (no solution here, we can't pronounce all player names)
			self.relativeScoreSign = 0
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Announcer:roundOverRelative()
	local localPlayer = getLocalPlayer()

	-- draw?
	if world.gameState == GAME_STATE_ROUNDCOOLDOWN_DRAW and world.gameTime < 2000 then
		if self.playedRoundOver ~= true then
			self.playedRoundOver = true

			-- kill off any queued notifications / messages, round has ended
			local clearAnnouncerQueue = true
			stopAnnouncer(clearAnnouncerQueue)

			-- round over
			local interrupt = true
			playAnnouncer("Match_RoundOver", interrupt)
		end
	end

	-- someone won?
	if world.gameState == GAME_STATE_ROUNDCOOLDOWN_SOMEONEWON and world.gameTime < 2000 then
		if self.playedRoundWinner ~= true then
			self.playedRoundWinner = true
			local gameMode = gamemodes[world.gameModeIndex];
			local alivePlayer = getPlayerAlive();

			-- kill off any queued notifications / messages, round has ended
			local clearAnnouncerQueue = true
			stopAnnouncer(clearAnnouncerQueue)

			if gameMode.hasTeams then
				local weWon = alivePlayer ~= nil and alivePlayer.team == localPlayer.team
				if weWon then
					local interrupt = true
					playAnnouncer("Match_Team_YourTeamHasWonTheRound", interrupt)
				else
					local interrupt = true
					playAnnouncer("Match_EnemyTeam_HasWonTheRound", interrupt)
				end
			else
				local weWon = alivePlayer == localPlayer
				if weWon then
					local interrupt = true
					playAnnouncer("Match_YouHaveWonTheRound", interrupt)
				else
					local interrupt = true
					playAnnouncer("Match_Enemy_HasWonTheRound", interrupt)
				end		
			end
		end
	end
		
	-- reset
	if world.gameState ~= GAME_STATE_ROUNDCOOLDOWN_DRAW and world.gameState ~= GAME_STATE_ROUNDCOOLDOWN_SOMEONEWON then
		self.playedRoundOver = false
		self.playedRoundWinner = false
	end	
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Announcer:roundOver()
	local localPlayer = getLocalPlayer()
	if localPlayer ~= nil and localPlayer.state == PLAYER_STATE_INGAME then
		self:roundOverRelative()
	else
		-- relative draw
		local roundOver = world.gameState == GAME_STATE_ROUNDCOOLDOWN_DRAW or world.gameState == GAME_STATE_ROUNDCOOLDOWN_SOMEONEWON
		if roundOver and world.gameTime < 2000 then
			if self.playedRoundOver ~= true then
				self.playedRoundOver = true

				-- kill off any queued notifications / messages, round has ended
				local clearAnnouncerQueue = true
				stopAnnouncer(clearAnnouncerQueue)

				local interrupt = true
				playAnnouncer("Match_RoundOver", interrupt)
			end
		else
			self.playedRoundOver = false
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Announcer:gameOver()
	if world.gameState == GAME_STATE_GAMEOVER and world.gameTime < 2000 then
		if self.playedGameOver ~= true then
			local myScore, enemyScore = GetScores()
			local gameMode = gamemodes[world.gameModeIndex];
			local relativeScoreSign = sign(myScore - enemyScore)

			-- kill off any queued notifications / messages, game has ended
			local clearAnnouncerQueue = true
			stopAnnouncer(clearAnnouncerQueue)

			-- play final announcer message
			local interrupt = true
			if gameMode.hasTeams then
				if relativeScoreSign > 0 then
					playAnnouncer("Match_Team_YourTeamWon", interrupt)
				elseif relativeScoreSign == 0 then
					playAnnouncer("Match_GameOver", interrupt)
				else
					playAnnouncer("Match_Team_YourTeamLost", interrupt)
				end
			else
				if relativeScoreSign > 0 then
					playAnnouncer("Match_YouWin", interrupt)
				elseif relativeScoreSign == 0 then
					playAnnouncer("Match_GameOver", interrupt)
				else
					playAnnouncer("Match_YouLose", interrupt)
				end			
			end

			self.playedGameOver = true
		end
	else
		self.playedGameOver = false
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Announcer:ctfNotification()
	-- only play when game active (yes, excludes round-based modes)
	if world.gameState ~= GAME_STATE_ACTIVE then
		self.lastLogId = nil
		return
	end

	--
	local logCount = 0
	for k, v in pairs(log) do
		logCount = logCount + 1;
	end

	-- history
	for i = 1, logCount do
		local logEntry = log[i];

		if logEntry.type == LOG_TYPE_CTFEVENT then
			local id = logEntry.id;
			if self.lastLogId == nil or id > self.lastLogId then
				self.lastLogId = id;

				-- display message
				-- 1,2: alpha/zeta
				-- 3: me
				-- 4,5: myteam/enemyteam

				-- select sounds
				local sounds = {}
				if logEntry.ctfEvent == CTF_EVENT_CAPTURE then
					sounds[1] = "Match_Mode_CTF_AlphaTeamHaveCapturedTheFlag"
					sounds[2] = "Match_Mode_CTF_ZetaTeamHaveCapturedTheFlag"
					sounds[3] = "Match_Mode_CTF_YouHaveCapturedTheFlag"
					sounds[4] = "Match_Mode_CTF_YourTeamHasCapturedTheEnemyFlag"
					sounds[5] = "Match_Mode_CTF_TheEnemyHasCapturedYourFlag"
				elseif logEntry.ctfEvent == CTF_EVENT_RETURN then
					sounds[1] = "Match_Mode_CTF_AlphaTeamHasReturnedTheirFlag"
					sounds[2] = "Match_Mode_CTF_ZetaTeamHasReturnedTheirFlag"
					sounds[3] = "Match_Mode_CTF_YouHaveReturnedTheFlag"
					sounds[4] = "Match_Mode_CTF_YourTeamHasReturnedTheirFlag"
					sounds[5] = "Match_Mode_CTF_TheEnemyHasReturnedTheirFlag"
				elseif logEntry.ctfEvent == CTF_EVENT_PICKUP then
					sounds[1] = "Match_Mode_CTF_AlphaTeamHasTheEnemyFlag"
					sounds[2] = "Match_Mode_CTF_ZetaTeamHasTheEnemyFlag"
					sounds[3] = "Match_Mode_CTF_YouHaveTheEnemyFlag"
					sounds[4] = "Match_Mode_CTF_YourTeamHasTheEnemyFlag"
					sounds[5] = "Match_Mode_CTF_TheEnemyHasYourFlag"
				elseif logEntry.ctfEvent == CTF_EVENT_DROPPED then
					sounds[1] = "Match_Mode_CTF_AlphaHasDroppedTheFlag"
					sounds[2] = "Match_Mode_CTF_ZetaHasDroppedTheFlag"
					sounds[3] = "Match_Mode_CTF_YouHaveDroppedTheEnemyFlag"
					sounds[4] = "Match_Mode_CTF_YourTeamHasDroppedTheEnemyFlag"
					sounds[5] = "Match_Mode_CTF_TheEnemyTeamHasDroppedYourFlag"
				end

				-- determine tense
				if sounds[1] ~= nil then
					local tense = 1

					local localPlayer = getLocalPlayer()
					if localPlayer ~= nil and localPlayer.state == PLAYER_STATE_INGAME then
						if logEntry.ctfPlayerName == localPlayer.name then
							-- 3 => self
							tense = 3
						else
							if localPlayer.team == logEntry.ctfTeamIndex then
								-- 4 => "your team"
								tense = 4
							else
								-- 5 => "enemy team"
								tense = 5
							end								
						end
					else
						-- absolute
						-- 1 => alpha
						-- 2 => zeta
						tense = logEntry.ctfTeamIndex
					end
					
					-- play it
					local interrupt = true
					playAnnouncer(sounds[tense], interrupt)
				end
			end	
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Announcer:draw()
	-- no announcer on intro / kill announcer when we DC
	if (world.state == STATE_DISCONNECTED) or (replayName == "menu") then
		self.lastLogId = nil
		self.lastMinutesRemaining = 100
		self.relativeScoreSign = 0
		local clearAnnouncerQueue = true
		stopAnnouncer(clearAnnouncerQueue)
		return
	else
		-- announcer logic
		self:countdown()
		self:fightOvertime()
		self:timeRemaining()
		self:ctfNotification()
		self:whoHasLeads()
		self:roundOver()
		self:gameOver()
	end

	-- announcer, update group caches
	self:postUpdateAnnouncerUnique()
end
