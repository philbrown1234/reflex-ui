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

Intro =
{
	canPosition = false,
	canHide = false,
	isMenu = false,
	time = 0,
};
registerWidget("Intro");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Intro:draw()
	self.time = self.time + deltaTimeRaw;

	-- display intro message
	local consideredDisconnected = (clientGameState == STATE_DISCONNECTED) or (replayName == "menu");
	if consideredDisconnected and not isInMenu() then

		local intensity = 1 - Menu.menuBarIntensity;

		nvgSave();

		-- letterbox
		local letterboxHeight = 187;
		nvgBeginPath();
		nvgRect(-viewport.width / 2, -viewport.height / 2, viewport.width, letterboxHeight);
		nvgFillColor(Color(0, 0, 0, 255*intensity));
		nvgFill();
		nvgBeginPath();
		nvgRect(-viewport.width / 2, (viewport.height / 2.05) - letterboxHeight/2, viewport.width, letterboxHeight);
		nvgFill();
		
		-- "reflex" text
		local x = -200;
		local y = -viewport.height / 2+136;
		local fontx = x;
		local fonty = y;
		nvgFontSize(152);
		nvgFontFace("Oswald-BoldItalic");
		nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_BASELINE);
		nvgFillColor(Color(255, 255, 255, 255*intensity));
		local fontw = nvgTextWidth("REFLEX")
		nvgText(fontx, fonty, "REFLEX");
		
		-- reflex logo
		local logorad = 40;
		local logox = x + fontw + logorad+5;
		local svgName = "internal/ui/icons/reflexlogo";
		nvgFillColor(Color(192, 32, 31, 255 * intensity));
		nvgSvg(svgName, logox, y - 45, logorad);
		
		-- "arena" text
		local fontx = fontx + fontw;
		local fonty = y;
		nvgSave();
		nvgFontFace("Oswald-Medium");
		nvgFontSize(32);
		nvgFillColor(Color(255, 255, 255, 255*intensity));
		nvgTextAlign(NVG_ALIGN_RIGHT, NVG_ALIGN_TOP);
		nvgTextLetterSpacing(8)
		nvgText(fontx, fonty, "ARENA");
		nvgRestore();

		-- message
		local c = 200 + 55 * math.sin(self.time*4);		
		local x = 0;
		local y = viewport.height / 2 - 52;
		nvgFontSize(40);
		nvgFontFace("oswald-light");
		nvgFillColor(Color(c, c, c, 255*intensity));
		nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
		nvgText(x, y, "PRESS ESCAPE TO CONTINUE");
		
		local x = viewport.width / 2;
		local y = viewport.height / 2 - 40;
	
		-- display logos over bg menu
		--nvgFillColor(Color(232,232,232, 255*intensity));
		--nvgSvg("internal/ui/logos/nvidiagameworks", -380, y, 100);
		--nvgSvg("internal/ui/logos/turbopixelstudios", 0, y, 105);
		--nvgSvg("internal/ui/logos/filmvic", 380, y, 110);

		nvgRestore();
	end
end
