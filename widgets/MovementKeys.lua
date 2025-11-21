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

MovementKeys =
{
};

registerWidget("MovementKeys");

-------------------------------------------------------------------------
-------------------------------------------------------------------------

function MovementKeys:initialize()
	

end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

function MovementKeys:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  local leftArrowIcon = "internal/ui/icons/keyLeft"
  local upArrowIcon = "internal/ui/icons/keyForward"
  local rightArrowIcon = "internal/ui/icons/keyRight"
  local downArrowIcon = "internal/ui/icons/keyBack"
  local jumpIcon = "internal/ui/icons/keyJump"
  local crouchIcon = "internal/ui/icons/keyCrouch"

  local arrowIconSize = 10
  local arrowIconColor = Color(255,255,255,255)

  if specPl.buttons.left then
    nvgFillColor(arrowIconColor);
    nvgSvg(leftArrowIcon, -30, 0, arrowIconSize);
  end
  if specPl.buttons.forward then
    nvgFillColor(arrowIconColor);
    nvgSvg(upArrowIcon, 0, -30, arrowIconSize);
  end
  if specPl.buttons.right then
    nvgFillColor(arrowIconColor);
    nvgSvg(rightArrowIcon, 30, 0, arrowIconSize);
  end
  if specPl.buttons.back then
    nvgFillColor(arrowIconColor);
    nvgSvg(downArrowIcon, 0, 30, arrowIconSize);
  end
  if specPl.buttons.jump then
    nvgFillColor(arrowIconColor);
    nvgSvg(jumpIcon, 30, 30, arrowIconSize);
  end
  if specPl.buttons.crouch then
    nvgFillColor(arrowIconColor);
    nvgSvg(crouchIcon, -30, 30, arrowIconSize);
  end

end
