//	Game Scene

Include ("scriptlib/nad.nut")
Include ("data/scripts/controller.nut")
Include ("data/scripts/boat_control.nut")
Include ("data/scripts/sea_control.nut")
Include ("data/scripts/enemy.nut")
Include ("data/scripts/island.nut")

g_shoot_power_delay	<- Sec(2.0)



//---------------
class	GameScene
//---------------
{
	controller			= 0
	
	game_started		= false
	
	game_ui				= 0

	sea					= 0
	boat				= 0
	boat_oscillation	= 0

	enemy_swarm			= 0
	spawn_timeout		= 0
	
	island				= 0
		
	fear_music_played	= false

	//------------------------
	function	OnSetup(scene)
	//------------------------
	{
		print("GameScene::OnSetup()")

		//g_audio.PlayMusicHappy()
		g_audio.PlayWaves()
		g_audio.PlayBoatCreaking()
		
		game_ui = GameUI()

		sea	= SeaAnimation()
		sea.Setup(scene)

		boat = Boat()
		boat.Setup(scene, game_ui)

		boat_oscillation = BoatOscillation()
		boat_oscillation.Setup(scene)

		enemy_swarm = EnemySwarm()
		enemy_swarm.Setup(scene, boat)
		
		island = Island()
		island.Setup(scene, boat)

		controller = SimpleController()
		controller.Setup()
		controller.SetDirectionBounceFilter(false)
		
		game_ui.ShowGameRules()
		g_audio.UIProceed()

		if (EngineGetToolMode(g_engine) == NoTool)
			SceneSetCurrentCamera(scene, ItemCastToCamera(SceneFindItem(scene, "camera_bridge")))
	}

	//-------------------------
	function	OnUpdate(scene)
	//-------------------------
	{
		UpdateController()
		UpdateBoat()
		UpdateEnemies()
		UpdateEnvironment()
		HandleMusic()
		island.Update()
		game_ui.SetCompassHint(island.GetAngleWithBoat(), island.GetVicinityLevel())
		game_ui.SetDistance(island.GetDistanceFromBoat())
		game_ui.Update()
		
		if (island.GetDistanceFromBoat() < Mtr(350.0))
			game_ui.ShowGameEnd()
	}
	
	function	HandleMusic()
	{
		if (fear_music_played)
			return
			
		if ((island.GetVicinityLevel() > 0.85) && (island.GetDistanceFromBoat() < Km(2.0)))
		{
			fear_music_played = true
			g_audio.PlayMusicFear()
		}
	}

	function	UpdateEnvironment()
	{
		sea.Update()
	}

	function	UpdateBoat()
	{
		if (game_started)
		{
			local	_speed = 1.0
			
			if (g_clock - enemy_swarm.last_killed_timeout > SecToTick(Sec(25.0)))
				_speed = 0.0
				
			boat.SetSpeedFactor(_speed)
		}
		boat.Update(game_started)
		boat_oscillation.Update()
	}

	function	UpdateController()
	{
		controller.Update()

		if (game_started)
		{
			if (controller.x < 0.0)
				boat.TurnHelm(true)
			else if (controller.x > 0.0)
				boat.TurnHelm(false)
	
			if (controller.shoot0 == true)
				boat.PressShoot(true)
			else
				boat.PressShoot(false)
		}
			
		if (controller.start == true)
		{
			if (!game_started)
			{
				game_ui.HideGameRules()
				g_audio.UIValidate()
				game_started = true
			}
		}
	}

	function	UpdateEnemies()
	{	
		if (game_started)
		{
			local	_spawn_time_interval	
			_spawn_time_interval = Lerp(Pow(enemy_swarm.GetKilledEnemyRatio(), 0.5), Sec(10.0), Sec(1.0))
		
			if (g_clock - spawn_timeout > SecToTick(Sec(_spawn_time_interval)))
			{
				enemy_swarm.SpawnNewEnemy()
				spawn_timeout = g_clock
			}
		}

		enemy_swarm.Update()
	}
}
