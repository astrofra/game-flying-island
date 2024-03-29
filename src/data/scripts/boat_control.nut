//

//---------------------------------
function	PlaceBoulders(boulder)
{
	print("PlaceBoulders() : coroutine invoked !")

	local	_timeout

	_timeout = g_clock
				
	while ((g_clock - _timeout) < SecToTick(Sec(1.5)))
		suspend()

	for (local n = 0; n < 5; n++)
	{			
		//	Physically replace the boulder
		//ItemPhysicResetTransformation(boulder[n].item, ItemGetWorldPosition(boulder[n].initial_position), Vector(0,0,0))
		ItemSetPhysicPosition(boulder[n].item, ItemGetWorldPosition(boulder[n].initial_position))
		ItemPhysicSynchronizeCollision(boulder[n].item)
		boulder[n].instance.Sleep()

		//	Audio feedback
		g_audio.ReloadBoulder()

		print("PlaceBoulders() : ItemSetPhysicPosition(Boulder #" + n + ")") 

		_timeout = g_clock

		while ((g_clock - _timeout) < SecToTick(Sec(0.25)))
			suspend()
	}

}

//-------------
class	Boulder
{
	scene	= 0
	body	= 0
	pos		= 0
	alive	= false

	function	OnSetup(item)
	{
		scene = ItemGetScene(item)
		body = item
		pos = ItemGetWorldPosition(body)
		alive = false
	}

	function	OnUpdate(item)
	{
		if (!alive)
			return

		pos = ItemGetWorldPosition(body)
		if ((pos.y) < Mtr(0.0))
		{
			FxCreateWaterImpact(scene, pos)
			Die()
		}
	}

	function	Live()
	{	alive = true	}

	function	Sleep()
	{	alive = false	}

	function	Die()
	{
		//ItemPhysicResetTransformation(body, Vector(0,-200,0), Vector())
		ItemSetPhysicPosition(body, Vector(0,-200,0))
		Sleep()
	}
}

//----------
class	Boat
{

	scene				= 0
	audio				= 0
	ui					= 0

	boat_body			= 0
	boat_mass			= 0.0
	boat_heading		= 0
	boat_helm			= 0
	boat_speed			= Mtrs(0.0)

	rot_speed 			= 0.0
	laggy_rot_speed		= 0.0

	shoot_pressed		= false
	shoot_pressed_timeout
						= 0.0
	
	boat_is_shooting	= false
	shoot_timeout		= 0.0
	
	boulder				= []
	boulder_left		= -1
	boulder_mass		= 0.0
	reloader_thread		= 0
	
	//	Real physical gameplay position
	real_pos				= 0

	//------------
	constructor	()
	//------------
	{
		boat_heading		= { item = 0, rot = Vector() }
		boat_helm			= { item = 0, rot = Vector(), rot_speed = 0.0 }
		
		real_pos			= Vector(0,0,0)

		boulder = 			[]
	}
	
	function	GetRealPosition()
	{		return real_pos	}
	
	function	GetRealDirection()
	{		
		return ItemGetRotationMatrix(boat_heading.item).GetRow(2)	
	}
	
	//----------------------
	function	UpdateRealPosition()
	//----------------------
	{	
		local	_boat_velocity
		_boat_velocity = GetRealDirection()
		_boat_velocity = _boat_velocity.Normalize()
		_boat_velocity = _boat_velocity.Scale(g_dt_frame * boat_speed)
		
		real_pos += _boat_velocity
	}
	
	function	SetSpeedFactor(_s)
	{
		if (_s > boat_speed)
			boat_speed = Lerp(_s, 0.0, Mtrs(20.0)) // 20 = random value
		else
			boat_speed = Lerp(0.005, boat_speed, Lerp(_s, 0.0, Mtrs(20.0)))
	}

	//----------------------
	function	Setup(_scene, _ui)
	//----------------------
	{
		//	Store scene handler
		scene = _scene
		ui = _ui

		//	Get boat elements
		boat_body = SceneFindItem(scene, "boat_body")
		boat_mass = ItemGetMass(boat_body)
		boat_heading.item = SceneFindItem(scene, "boat_heading")
		boat_helm.item = SceneFindItem(scene, "boat_helm")

		//	Physic settings
		ItemPhysicSetLinearFactor(boat_body, Vector(0.0,0.0,0.0))

		boat_is_shooting = false

		//	Get boulders
		for (local n = 0; n < 5; n++)
		{
			boulder.append({ item = 0, instance = 0, initial_position = 0, strength = 0.0 })
			boulder[n].item = SceneFindItem(scene, "boulder_" + n)
			if (ObjectIsValid(boulder[n].item))
			{
				boulder[n].initial_position = SceneFindItem(scene, "boulder_position_" + n)
				boulder[n].instance = ItemGetScriptInstance(boulder[n].item)
				if (n == 0)		print("Boat::Setup() : Found boulders at ")
				ItemGetPosition(boulder[n].initial_position).Print()
			}
			else
				print("Boat::Setup() : Cannot find boulder #" + n)
		}

		if (boulder.len() > 0)
			boulder_mass = ItemGetMass(boulder[0].item)
	}

	//------------------
	function	Update(game_started)
	//------------------
	{

		//	Helm rotation
		boat_helm.rot_speed = boat_helm.rot_speed * 0.9 + rot_speed * 0.1
		boat_helm.rot.z += g_dt_frame * Deg(360.0 * boat_helm.rot_speed)
		ItemSetRotation(boat_helm.item, boat_helm.rot)

		//	Boat rotation
		laggy_rot_speed = Lerp(0.99, rot_speed, laggy_rot_speed)
		boat_heading.rot.y += g_dt_frame * Deg(-45.0 * laggy_rot_speed)
		ItemSetRotation(boat_heading.item, boat_heading.rot)
		
		//	Real Position
		UpdateRealPosition()

		rot_speed *= 0.5
		
		//	Rotation audio feedback
		g_audio.SetBoatCreakingVolume(Clamp(Abs(laggy_rot_speed), 0.0, 1.0))

		if (!game_started)
			return

		//	Shoot
		if (boat_is_shooting)
		{
			if (g_clock - shoot_timeout > SecToTick(Sec(0.5)))
				boat_is_shooting = false
		}

		//	Boulder stock
		if (boulder_left <= 0)
		{
			
			// Check if all boulders died
			if (IsAllBouldersDead())
				ReloadBoulders()
		}

		HandleBoulderReload()
	}
	
	//-----------------------------
	function	IsAllBouldersDead()
	//-----------------------------
	{
		// Check if all boulders died
		local n
		for (n = 0; n < 5; n++)
			if (boulder[n].instance.alive)
				return false

		return true
	}

	//------------------------
	function	TurnHelm(left)
	//------------------------
	{
		if (left)
			rot_speed = Max(1.0, rot_speed + g_dt_frame)
		else
			rot_speed = Min(-1.0, rot_speed - g_dt_frame)
	}

	function	PressShoot(_state)
	{
		local	_power = 0.0
		
		if (_state != shoot_pressed)
		{
			if (_state == true)
			{
				shoot_pressed_timeout = g_clock
			}
			else
				Shoot(TickToSec(g_clock - shoot_pressed_timeout))
		}
		
		if (_state == true)
		{
			if ( (g_clock - shoot_pressed_timeout) > SecToTick(Sec(g_shoot_power_delay)) )
			{
				Shoot(TickToSec(g_clock - shoot_pressed_timeout))
				shoot_pressed_timeout = g_clock
			}
			else
			{
				_power = Clamp(TickToSec(g_clock - shoot_pressed_timeout), 0.0, Sec(g_shoot_power_delay))
			}
		}
				
		ui.SetPowerCursor(RangeAdjust(_power, 0.0, g_shoot_power_delay, 0.0, 1.0))
		
		shoot_pressed = _state
	}

	//-----------------
	function	Shoot(_delay)
	//-----------------
	{
		print("Shoot() invoked !")

		if (boat_is_shooting)
			return

		//	Count boulders left
		boulder_left--

		if (boulder_left >= 0)
		{
			//	Throw boulder
			local	_cannon = ItemGetWorldPosition(SceneFindItem(scene, "cannon_mouth"))
			ItemPhysicResetTransformation(boulder[boulder_left].item, _cannon, Vector())
			ItemPhysicSynchronizeCollision(boulder[boulder_left].item)
			
			local	impulse_origin = ItemGetWorldPosition(SceneFindItem(scene, "cannon_mouth"))
			local	impulse_direction = impulse_origin - ItemGetWorldPosition(boat_body)
			impulse_direction.y = Mtr(0.0)

			local	_cannon_strength = RangeAdjust(_delay, 0.0, g_shoot_power_delay, 1.0, 50.0)

			boulder[boulder_left].strength = Clamp(RangeAdjust(_delay, 0.0, g_shoot_power_delay, 0.0, 1.0), 0.0, 1.0)

			impulse_direction = impulse_origin + impulse_direction.Normalize().MulReal(_cannon_strength * boulder_mass)
			impulse_direction.y *= 0.5
			
			ItemApplyImpulse(boulder[boulder_left].item, impulse_origin, impulse_direction)

			boulder[boulder_left].instance.Live()

			//	Physic feedback
			shoot_timeout = g_clock

			local	impulse_origin = ItemGetWorldPosition(SceneFindItem(scene, "boat_front"))
			local	impulse_direction = impulse_origin - ItemGetWorldPosition(boat_body)
			impulse_direction = impulse_direction.Normalize().MulReal(2.0 * boat_mass)

			if (g_debug)
			{
				RendererDrawCross(g_renderer, impulse_origin)
				RendererDrawLine(g_renderer, impulse_origin, impulse_origin + impulse_direction)
			}

			ItemApplyImpulse(boat_body, impulse_origin, impulse_direction)

			//	Audio feedback
			g_audio.Shoot()

			boat_is_shooting = true
		}
		else
			g_audio.NoBoulderLeft()
	}

	//--------------------------
	function	ReloadBoulders()
	//--------------------------
	{
		if (reloader_thread == 0)
		{
			reloader_thread = newthread(PlaceBoulders)
			reloader_thread.call(boulder)
		}
	}

	//-------------------------------
	function	HandleBoulderReload()
	//-------------------------------
	{
		if (reloader_thread == 0)
			return

		if (reloader_thread.getstatus() == "suspended")
			reloader_thread.wakeup()
		else
		{
			reloader_thread = 0
			boulder_left = 5
			print("HandleBoulderReload() : Done !")
		}
	}

}

//---------------------
class	BoatOscillation
//---------------------
{

	item		= 0

	pos			= Vector()
	rot			= Vector()

	pos_angle	= 0.0
	rot_angle	= 0.0

	wave_freq	= 1.0

	helm		= 0

	constructor	()
	{	}

	//----------------------
	function	Setup(scene)
	//----------------------
	{
		item = SceneFindItem(scene, "boat_wave_fx")

		pos = ItemGetPosition(item)
		rot = ItemGetRotation(item)
		print("BoatOscillation::ItemGetPosition()")
		pos.Print();
	}

	//------------------
	function	Update()
	//------------------
	{
		local	new_pos, new_rot,
				pos_offset, rot_offset

		pos_angle += g_dt_frame * Deg(5.0) * 60.0
		pos_offset = Mtr(1.0) + Mtr(3.0) * sin(pos_angle * wave_freq * 0.15) + Mtr(0.5) * sin(pos_angle * wave_freq * 0.15 * 1.75 + Deg(45.0))
		new_pos = pos + Vector(0, pos_offset, 0)

		rot_angle += g_dt_frame * Deg(5.0) * 60.0
		rot_offset = Deg(10.0) + Deg(5.0) * sin(pos_angle * wave_freq * 0.15 + 180.0)
		new_rot = rot + Vector(rot_offset, 0, 0)
		
		ItemSetPosition(item, new_pos)
		ItemSetRotation(item, new_rot)
	}

	function	SetFrequency(_freq)
	{	wave_freq = _freq	}

}