// Title Screen

Include("scriptlib/nad.nut")

class	TitleScreen
{
	title_ui		= 0

	title_item		= 0
	title_rot		= 0

	boat_item		= 0
	boat_rot		= 0

	title_angle		= 0.0
	boat_angle		= 0.0

	anim_ease		= 0.0

	sea				= 0

	controller		= 0

	function	OnSetup(scene)
	{
		title_ui = TitleUI()
		
		title_item		= SceneFindItem(scene, "title")
		title_rot		= ItemGetRotation(title_item)

		boat_item		= SceneFindItem(scene, "title_boat_body")
		boat_rot		= ItemGetRotation(boat_item)
 
		sea	= SeaAnimation()
		sea.Setup(scene)

		g_audio.PlayMusicHappy()

		controller = SimpleController()
		controller.Setup()
	}

	function	OnUpdate(scene)
	{
		sea.Update()
		controller.Update()
		title_ui.Update()
		
		if (controller.start == true)
		{
			g_audio.StopMusic()
			g_script().GoToNextLevel()
		}

		anim_ease = Min(1.0, anim_ease + g_dt_frame * 0.5)

		title_angle += g_dt_frame * Deg(45.0)
		title_rot.z = Deg(3.0) * sin(title_angle * anim_ease)
		ItemSetRotation(title_item, title_rot)

		boat_angle += g_dt_frame * Deg(65.0)
		boat_rot.x = Deg(10.0) * cos(boat_angle * anim_ease)
		ItemSetRotation(boat_item, boat_rot)
		ItemSetPosition(boat_item, Vector(0,Mtr(3.0) * cos((boat_angle + Deg(45.0)) * anim_ease)))
	}

}