/* UI
*/

Include("data/scripts/locale/" + g_current_language + ".nut")

g_overscan_pad			<- 20.0

function	UICommonSetup()
{
		UILoadFont ("data/ui/blindfold.ttf")
		UILoadFont ("data/ui/aqua.ttf")
		UILoadFont ("data/ui/garamond.ttf")
		
	    UISetSkin    (
                        g_ui, "data/ui/skin/t.tga", "data/ui/skin/l.tga", "data/ui/skin/r.tga", "data/ui/skin/b.tga",
                        "data/ui/skin/tl.tga", "data/ui/skin/tr.tga", "data/ui/skin/bl.tga", "data/ui/skin/br.tga", 0xff9ebc24,
                        0xffffffff, 30, 20, 10, font.name
                    )
}

//------------------
class	LevelIntroUI
//------------------
{
	_window		= 0
	_widget		= 0
	
	constructor()
	{
		UICommonSetup()
		
		//	Start menu window
		_window = UIAddWindow(g_ui, -1, 1280.0 / 2.0, 960.0 / 2.0, 800.0, 300.0)
		WindowSetStyle(_window, StyleMovable)
		WindowSetTitle(_window, "")
		WindowCenterPivot(_window)		
		WindowSetCommandList(_window, "hide;")
		
		//	Start menu widget
		local	hsizer = UIAddHorizontalSizerWidget(g_ui, -1);
		WindowSetBaseWidget(_window, hsizer);
		
		local	_title_name = g_script().GetCurrentLevelIntroTitle()
		_widget = UIAddStaticTextWidget(g_ui, -1, _title_name, font.name)
		TextSetParameters(_widget, { size = 80, align = "center", color = 0xffffffff })
		SizerAddWidget(hsizer, _widget)
	}
	
	function	FadeIn()
	{
		WindowSetCommandList(_window, "toalpha 0,0;show;toalpha 0.75,1;nop 2.0;toalpha 0.75,0;")
	}
}

//-------------
class	TitleUI
//-------------
{
	
	start_menu_window		= 0
	start_menu_widget		= 0
	
	constructor()
	{
		UICommonSetup()
		
		//	Start menu window
		start_menu_window = UIAddWindow(g_ui, -1, 700.0, 960.0 - 150.0 - g_overscan_pad, 600.0, 200.0)
		WindowSetStyle(start_menu_window, StyleMovable)
		WindowSetTitle(start_menu_window, "")
		WindowCenterPivot(start_menu_window)
		
		WindowSetCommandList(start_menu_window, "loop;toalpha 2.0,0.5;nop 0.5;toalpha 2.0,1.0;nop 0.5;next;")
		
		//	Start menu widget
		local	hsizer = UIAddHorizontalSizerWidget(g_ui, -1);
		WindowSetBaseWidget(start_menu_window, hsizer);
		
		start_menu_widget = UIAddStaticTextWidget(g_ui, -1, locale.press_space, font.name)
		TextSetParameters(start_menu_widget, { size = 80, align = "center", color = 0xffffffff })
		SizerAddWidget(hsizer, start_menu_widget)
	}
	
	function	Update()
	{
		local	_sin = sin(DegreeToRadian(TickToSec(g_clock) * 360.0) * 0.25)
		local	_cos = cos(DegreeToRadian(TickToSec(g_clock) * 360.0) * 0.125)
		local	_scale = 0.75 + 0.125 * _sin
		local	_rot = DegreeToRadian(5.0 * _cos)
		WindowSetScale(start_menu_window , _scale, _scale)
		WindowSetRotation(start_menu_window , _rot)
	}
	
	function	FadeOut()
	{
		UISetCommandList(g_ui, "nop 0.25;globalfade 1,0;nop 0.25;")
	}
}

//-------------------------
class	LanguageSelectionUI
//-------------------------
{
	flag_fr		=	0
	flag_jp		=	0
	flag_uk		=	0
	
	flag_sel	=	0	
	
	constructor()
	{
		flag_uk = UIAddBitmapWindow(g_ui, 1, "data/ui/flag_uk.jpg", 640.0 - 250.0, 480.0, 200.0, 120.0)
		WindowCenterPivot(flag_uk)
		
		flag_jp = UIAddBitmapWindow(g_ui, 1, "data/ui/flag_jp.jpg", 640.0, 480.0, 200.0, 120.0)
		WindowCenterPivot(flag_jp)
		
		flag_fr = UIAddBitmapWindow(g_ui, 1, "data/ui/flag_fr.jpg", 640.0 + 250.0, 480.0, 200.0, 120.0)
		WindowCenterPivot(flag_fr)
		
		flag_sel = UIAddBitmapWindow(g_ui, 1, "data/ui/flag_selector.tga", 640.0 - 250.0, 480.0, 250.0, 150.0)
		WindowCenterPivot(flag_sel)
		
		AnimateSelector()
	}
	
	function	AnimateSelector()
	{
		WindowSetOpacity(flag_sel, 1.0)
		WindowResetCommandList(flag_sel)
		WindowSetCommandList(flag_sel, "loop;toalpha 1,0;nop 0.25;toalpha 1,1;nop 0.25;next;")
	}
	
	function	SetCurrentLanguage(current_language)
	{
		WindowSetPosition(flag_sel, 640.0 + (current_language - 1.0) * 250.0, 480.0)
		AnimateSelector()
	}
}

//------------
class	GameUI
//------------
{
	scene_2d				= 0
	
	game_rules_window		= 0
	game_rules_window_py	= 0.0
	game_rules_shown		= false
	
	game_end_window			= 0
	game_end_shown			= false
	
	distance_text_shadow	= 0
	distance_text		 	= 0
	distance_str			= "Distance"
	
	update_every			= 0
	
	power_gauge_window		= 0
	power_cursor_window		= 0
	power_cursor_y			= 0.0
	compass_window			= 0
	beacon_window			= 0
	beacon_angle			= DegreeToRadian(0.0)
	target_angle			= DegreeToRadian(0.0)
	beacon_opacity			= 0.0
	
	constructor()
	{		
		print("GameUI::Setup()")
		
		UICommonSetup()
		
		CreatePowerGauge()
		CreateCompass()
		CreateDistanceWindow()
		CreateGameRulesWindow()
		CreateGameEndWindow()
	}
	
	function	CreateDistanceWindow()
	{
		print("GameUI::CreateDistanceWindow()")
		//	 Shadow
		local	distance_window
		local	_sx = 700.0, _sy = 200.0
		distance_window = UIAddWindow(g_ui, -1, 0.0, 0.0, _sx, _sy)
		WindowSetStyle(distance_window, StyleNonSkinned)
		WindowSetPosition(distance_window, g_overscan_pad + 2.5, g_overscan_pad / 2.0 + 6.0 - 10.0)

		//	Start menu widget
		local	hsizer = UIAddHorizontalSizerWidget(g_ui, -1);
		WindowSetBaseWidget(distance_window, hsizer);
		
		distance_text_shadow = UIAddStaticTextWidget(g_ui, -1, distance_str, font.name)
		TextSetParameters(distance_text_shadow, {size = 80, align = "left", color = 0x00000080 })
		SizerAddWidget(hsizer, distance_text_shadow)

		//	Text
		print("GameUI::CreateDistanceWindow()")
		//	 window
		local	_sx = 700.0, _sy = 200.0
		distance_window = UIAddWindow(g_ui, -1, 0.0, 0.0, _sx, _sy)
		WindowSetStyle(distance_window, StyleNonSkinned)
		WindowSetPosition(distance_window, g_overscan_pad, g_overscan_pad / 2.0 - 10.0)

		//	Start menu widget
		local	hsizer = UIAddHorizontalSizerWidget(g_ui, -1);
		WindowSetBaseWidget(distance_window, hsizer);
		
		distance_text = UIAddStaticTextWidget(g_ui, -1, distance_str, font.name)
		TextSetParameters(distance_text, {size = 80, align = "left", color = 0xffffffff })
		SizerAddWidget(hsizer, distance_text)
	}
	
	function	CreatePowerGauge()
	{
		print("GameUI::CreatePowerGauge()")
		power_gauge_window = UIAddBitmapWindow(g_ui, 1, "data/ui/cannon_gauge.tga", 640.0 - 400.0, 480.0 + 180.0, 80.0, 245.0)
		WindowCenterPivot(power_gauge_window)
		power_cursor_window = UIAddBitmapWindow(g_ui, 2, "data/ui/cannon_gauge_cursor.tga", 40.0, 245.0 - 35.0, 80.0, 80.0)
		WindowCenterPivot(power_cursor_window)
		WindowSetParent(power_cursor_window, power_gauge_window)
		//WindowSetScale(power_cursor_window, 1.25, 1.25)
		//WindowSetScale(power_gauge_window, 0.95, 0.95)
	}
	
	function	CreateCompass()
	{
		print("GameUI::CreateCompass()")
		compass_window = UIAddBitmapWindow(g_ui, 1, "data/ui/compass.tga", 640.0 - 400.0 - 150.0, 480.0 + 180.0, 245.0, 245.0)
		WindowCenterPivot(compass_window)

		beacon_window = UIAddBitmapWindow(g_ui, 2, "data/ui/beacon_arrow.tga", 0.0, 0.0, 245.0, 245.0)
		WindowCenterPivot(beacon_window)
		WindowSetParent(beacon_window, compass_window)
		WindowSetPosition(beacon_window, 245.0 / 2.0, 245.0 / 2.0)
		
		local _boat = UIAddBitmapWindow(g_ui, 2, "data/ui/cannon_gauge_cursor.tga", 0.0, 0.0, 80.0, 80.0)
		WindowCenterPivot(_boat)
		WindowSetParent(_boat, compass_window)
		WindowSetPosition(_boat, 245.0 / 2.0, 245.0 / 2.0)
		
		local _spec = UIAddBitmapWindow(g_ui, 2, "data/ui/compass_specular.tga", 0.0, 0.0, 245.0, 245.0)
		WindowSetParent(_spec, compass_window)
	}
	
	function	CreateGameRulesWindow()
	{
		print("GameUI::CreateGameRulesWindow()")
		//	Start menu window
		local	_sx = 1000.0, _sy = 800.0
		game_rules_window_py = 960.0 - _sy * 0.5 - g_overscan_pad + 80.0
		game_rules_window = UIAddWindow(g_ui, -1, 640.0, game_rules_window_py, _sx, _sy)
		WindowSetStyle(game_rules_window, StyleMovable)
		WindowSetTitle(game_rules_window, "")
		WindowCenterPivot(game_rules_window)
		
		WindowSetCommandList(game_rules_window, "toalpha 0,0;hide;")
		
		//	Start menu widget
		local	hsizer = UIAddHorizontalSizerWidget(g_ui, -1);
		WindowSetBaseWidget(game_rules_window, hsizer);
		
		local	str = "~~Size(100)" + locale.game_rules + "\n"
		str += "~~Size(60)" + locale.rule_0 + "\n"
		str += locale.rule_1 + "\n"
		str += locale.rule_2 + "\n...\n"
		str += "~~Size(80)" + locale.press_space
		
		local	text_widget = UIAddStaticTextWidget(g_ui, -1, str, font.name)
		TextSetParameters(text_widget, { align = "center", color = 0xffffffff })
		SizerAddWidget(hsizer, text_widget)
		
		//ShowGameRules()
	}
	
	function	CreateGameEndWindow()
	{
		print("GameUI::CreateGameEndWindow()")
		//	Game end window
		local	_sx = 1000.0, _sy = 500.0
		local	game_end_window_py = 480.0
		game_end_window = UIAddWindow(g_ui, -1, 640.0, game_end_window_py, _sx, _sy)
		WindowSetStyle(game_end_window, StyleMovable)
		WindowSetTitle(game_end_window, "")
		WindowCenterPivot(game_end_window)
		
		WindowSetCommandList(game_end_window, "toalpha 0,0;hide;")
		
		//	Start menu widget
		local	hsizer = UIAddHorizontalSizerWidget(g_ui, -1);
		WindowSetBaseWidget(game_end_window, hsizer);
		
		local	str = "~~Size(80)" + locale.ending
		
		local	text_widget = UIAddStaticTextWidget(g_ui, -1, str, font.name)
		TextSetParameters(text_widget, { align = "center", color = 0xffffffff })
		SizerAddWidget(hsizer, text_widget)
		
		//ShowGameRules()
	}
	
	function	ShowGameEnd()
	{
		if (game_end_shown)
			return
			
		WindowSetCommandList(game_end_window, "toalpha 0,0;nop 0.125;show;toalpha 0.25,1;")
		game_end_shown = true
	}
	
	function	ShowGameRules()
	{
		if (game_rules_shown)
			return
			
		WindowSetCommandList(game_rules_window, "toalpha 0,0;nop 0.125;show;toalpha 0.25,1+toposition 0.25,640," + (game_rules_window_py - 100.0) + ";")
		game_rules_shown = true
	}
	
	function	HideGameRules()
	{
		if (!game_rules_shown)
			return
			
		WindowSetCommandList(game_rules_window, "toalpha 0,1;toalpha 0.25,0+toposition 0.25,640," + game_rules_window_py + ";hide;")
		game_rules_shown = false
	}

	function	Update()
	{
		update_every++
		
		if (update_every > 7)
			update_every = 0
		
		if (Mod(update_every, 2) == 0)
			WindowSetPosition(power_cursor_window, 40.0, power_cursor_y)
		
		if (Mod(update_every, 4) == 0)
		{
		if ((target_angle > Deg(-90.0)) && (target_angle < Deg(90.0)))
			beacon_angle = Lerp(0.05, beacon_angle, target_angle)
		else
			beacon_angle = target_angle
			
		WindowSetOpacity(beacon_window, beacon_opacity)
		WindowSetRotation(beacon_window, beacon_angle)
		}
		
		if (update_every == 0)
		{
			TextSetText(distance_text_shadow, distance_str)
			TextSetText(distance_text, distance_str)
		}
	}
	
	function	SetPowerCursor(strength)
	{
		local _threshold = 0.6
		local _y = RangeAdjust(Clamp(strength, 0.0, _threshold), 0.0, _threshold, 245.0 - 35.0, 0.0 + 35.0)
		local _s = 1.0

		if (strength > _threshold)
			_s = (sin(g_clock * 0.5) < 0.0 ? 1.55 : 1.0)

		//WindowSetPosition(power_cursor_window, 40.0, power_cursor_y)
		power_cursor_y = Lerp(0.25, power_cursor_y, _y)
		WindowSetScale(power_cursor_window, _s, _s)
	}
	
	function	SetCompassHint(_angle, _opacity)
	{
		target_angle = _angle
		beacon_opacity = _opacity
	}
	
	function	SetDistance(_dist)
	{
		distance_str = locale.distance + " : " + (_dist.tointeger()).tostring()
	}
}