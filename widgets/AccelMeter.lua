--------------------------------------------------------------------------------
-- This is an official Reflex script. Do not modify. Based off PHGP AccelMeter
--
-- If you wish to customize this widget, please:
--  * clone this file to a new file
--  * rename the widget MyWidget
--  * set this widget to not visible (via options menu)
--  * set your new widget to visible (via options menu)
--
--------------------------------------------------------------------------------
require "base/internal/ui/reflexcore"

AccelMeter =
{
  -- user data, we'll save this into engine so it's persistent across loads
  userData = {}
};
registerWidget("AccelMeter");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AccelMeter:initialize()
  -- load data stored in engine
  self.userData = loadUserData();
  
  -- ensure it has what we need
  CheckSetDefaultValue(self, "userData", "table", {});
  CheckSetDefaultValue(self.userData, "raceModeToggle", "boolean", false);
  CheckSetDefaultValue(self.userData, "trainingModeToggle", "boolean", false);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AccelMeter:drawOptions(x, y, intensity)
  local optargs = {};
  optargs.intensity = intensity;

  local user = self.userData;

  user.raceModeToggle = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Race Mode Only", user.raceModeToggle, optargs);
  y = y + 60;

  user.trainingModeToggle = ui2RowCheckbox(x, y, WIDGET_PROPERTIES_COL_INDENT, "Training Mode Only", user.trainingModeToggle, optargs);
  y = y + 60;

  saveUserData(user);

end
-------------------------------------------------------------------------
-- Vector2D Class --
-------------------------------------------------------------------------

local Vector2D = {}
Vector2D.__index = Vector2D

function ColorA(color, alpha)
	return Color(color.r, color.g, color.b, alpha);
end

function Vector2D.new(x, y)
  local self = setmetatable({}, Vector2D)
  self.x = x or 0
  self.y = y or 0
  return self
end

function Vector2D:update(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function Vector2D:size()
  return math.sqrt(math.pow(self.x,2) + math.pow(self.y,2))
end

function Vector2D:dotProduct(vec2)
  assert(type(vec2) == "table", "vec2 must be a table")
  assert(type(vec2.x) ~= "nil", "vec2 must have an x value")
  assert(type(vec2.y) ~= "nil", "vec2 must have an y value")
  return (self.x*vec2.x)+(self.y*vec2.y)
end

function Vector2D:angle(vec2)
  assert(type(vec2) == "table", "vec2 must be a table")
  assert(type(vec2.x) ~= "nil", "vec2 must have an x value")
  assert(type(vec2.y) ~= "nil", "vec2 must have an y value")
  return math.acos(self:dotProduct(vec2)/(self:size()*vec2:size()))
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

local function posAngle(angle)
  angle = angle % 360
  if(angle < 0) then angle = angle + 360 end
  return angle
end

local accel, prevAng, timer, timer2, fps
local playerSpeed = Vector2D.new(0,0)
local deltaSpeed = Vector2D.new(0,0)
local playerAccel = Vector2D.new(0,0)
local radius = 100



function AccelMeter:draw()

  local user = self.userData;

  if (user == nil) then return end

  if not shouldShowHUD() then return end

  if not isRaceMode() then
    if (user.raceModeToggle == true) then
      return
    end
  end

  if not isTrainingMode() then
    if (user.trainingModeToggle == true) then
      return
    end
  end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  local xkey = 0
  local ykey = 0
  
  if specPl.buttons.left or specPl.buttons.right then
	xkey = 1
  end
  if specPl.buttons.forward or specPl.buttons.back then
--  if specPl.buttons.forward then
    ykey = 1
  end

  if xkey == 0 or ykey == 0 then
	return
  end
  
  if specPl.velocity.y > -2 and specPl.velocity.y < 2 then
    return
  end
  
  if prevAng == nil then prevAng = specPl.anglesDegrees.x end
  if timer == nil then timer = 0 end
  if timer2 == nil then timer2 = 0 end
  if fps == nil then fps = 240 end
  if accel == nil then accel = 0 end

  if timer2 >= 1/fps then
    timer2 = 0
    deltaSpeed:update(specPl.velocity.x - playerSpeed.x, specPl.velocity.z - playerSpeed.y)
    playerAccel:update(deltaSpeed.x/fps, deltaSpeed.y/fps)
    accel = playerAccel:size()
    if playerAccel.x < 0 and playerAccel.y < 0 then accel = accel * -1 end

    playerSpeed:update(specPl.velocity.x, specPl.velocity.z)
  end

  timer2 = timer2 + deltaTimeRaw

  -- Draw speed
  nvgFontSize(50);
  nvgFontFace("SourceSansPro-Bold");
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

  nvgFillColor(Color(0, 0, 0, 255));
  -- nvgText(0, 1, math.floor(accel))

  nvgFillColor(Color(255, 255, 255, 255));
  -- nvgText(0, 0, math.floor(accel))

  -- Draw angle

  local vec_x = Vector2D.new(1,0)
  local vec_nx = Vector2D.new(-1,0)

  local pl_ang = posAngle(specPl.anglesDegrees.x+90)
  local vel_ang
  if playerSpeed.y >= 0 then vel_ang = playerSpeed:angle(vec_nx)
  else vel_ang = math.pi + playerSpeed:angle(vec_x) end

  if specPl.buttons.back then
    vel_ang = -vel_ang
    pl_ang = -pl_ang + 180
  end  
  
  local min_ang = math.acos(320/playerSpeed:size())
  local opt_ang = math.acos((320-accel)/playerSpeed:size())
  local o = math.atan((accel*math.sqrt(math.pow(playerSpeed:size(), 2) - math.pow(320-accel, 2)))/(math.pow(playerSpeed:size(), 2) + accel*(320-accel)))
  local a = o/2+opt_ang
  local e = a-math.pi/4
  local t_ang_min = vel_ang
  local t_ang_op_m = vel_ang
  local t_ang_op = vel_ang

  if specPl.buttons.right then
    t_ang_op_m = t_ang_op + 1*e
    t_ang_op = t_ang_op + 1.2*e
  elseif specPl.buttons.left then
    t_ang_op_m = t_ang_op - 1*e
    t_ang_op = t_ang_op - 1.2*e
  end

  -- if specPl.anglesDegrees.x-prevAng > 0 then
  --   t_ang_op = t_ang_op + 1.2*e
  -- elseif specPl.anglesDegrees.x-prevAng < 0 then
  --   t_ang_op = t_ang_op - 1.2*e
  -- end

  if timer >= 1/10 then
    timer = 0
    prevAng = specPl.anglesDegrees.x
  end
  timer = timer + deltaTimeRaw

  local ang_diff_min = t_ang_min-math.rad(pl_ang)
  local ang_diff_op_m = t_ang_op_m-math.rad(pl_ang)
  local ang_diff_op = t_ang_op-math.rad(pl_ang)

  local lineSize = radius
  local dir = NVG_CW
  if ang_diff_min < ang_diff_op then dir = NVG_CW else dir = NVG_CCW end

  --nvgBeginPath()
  --nvgArc(0,0, lineSize, ang_diff_min-math.pi/2, ang_diff_op-math.pi/2, dir)
  --nvgStrokeColor(ColorA(PHGPHUD_BLUE_COLOR, 120))
  --nvgStrokeWidth(50)
  --nvgStroke()

  nvgBeginPath()
  nvgArc(0,0, lineSize, ang_diff_op_m-math.pi/2, ang_diff_op-math.pi/2, dir)
  nvgStrokeColor(ColorA(Color(25, 135, 0, 255), 120))
  nvgStrokeWidth(50)
  nvgStroke()


  ----------------------
  -- Lines
  ----------------------
  nvgBeginPath()
  nvgMoveTo(0, 0)
  nvgLineTo(lineSize*math.cos(ang_diff_min-math.pi/2), lineSize*math.sin(ang_diff_min-math.pi/2))
  nvgStrokeWidth(3)
  nvgStrokeColor(Color(195, 171, 0, 255))
  -- nvgStroke()

  nvgBeginPath()
  nvgMoveTo(0, 0)
  nvgLineTo(lineSize*math.cos(ang_diff_op-math.pi/2), lineSize*math.sin(ang_diff_op-math.pi/2))
  nvgStrokeWidth(3)
  nvgStrokeColor(Color(0, 85, 150, 255))
  -- nvgStroke()

  ----------------------
  ----------------------

  nvgFontSize(50);
  nvgFontFace("SourceSansPro-Bold");
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

  nvgFillColor(Color(255, 255, 255, 255));
  -- nvgText(0, 100, pl_ang .. " | " .. math.floor(math.deg(vel_ang)))

end