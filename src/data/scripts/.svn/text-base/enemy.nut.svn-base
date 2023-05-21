//	Enemy script

Include ("scriptlib/nad.nut")

/*
	Generic class 
	to handle enemies
*/
class	EnemySwarm
{

	scene			=	0

	boat			=	0

	enemy_types		=	0

	enemy_list		=	0
	spawn_area		=	0

	max_enemies		=	20
	
	last_killed_timeout
					=	0.0

	constructor()
	{
		enemy_list		=	[]
		spawn_area		=	[]
		enemy_types		=	[]
	}

	//-------------------------------
	function	Setup(_scene, _boat)
	//-------------------------------
	{
		scene	= _scene
		boat	= _boat

		for (local n = 0; n < 3; n++)
			spawn_area.append(SceneFindItem(scene, "enemy_spawn_" + n))

		enemy_types.append(SceneFindItem(scene, "enemy_boat"))
		enemy_types.append(SceneFindItem(scene, "enemy_big_boat"))
		print("EnemySwarm::Setup() found " + enemy_types.len() + " type(s) of enemy.")
		
		last_killed_timeout = g_clock
	}
	
	function	GetKilledEnemyRatio()
	{
		return (max_enemies - enemy_list.len()).tofloat() / (max_enemies.tofloat())
	}
	
	function	UpdateKillTimeout()
	{
		last_killed_timeout	= g_clock
	}

	//------------------------
	function	SpawnNewEnemy()
	{
		if (enemy_list.len() >= max_enemies)
			return

		local	_pos 	= Vector(),
				v0, v1, v2,
				k1, k2

		RendererDrawCross(g_renderer, ItemGetWorldPosition(spawn_area[0]))
		RendererDrawCross(g_renderer, ItemGetWorldPosition(spawn_area[1]))
		RendererDrawCross(g_renderer, ItemGetWorldPosition(spawn_area[2]))

		k1 = Rand(0.0, 1.0)
		k2 = Rand(0.0, 1.0)

		v0 = ItemGetWorldPosition(spawn_area[0])
		v1 = ItemGetWorldPosition(spawn_area[1]) - ItemGetWorldPosition(spawn_area[0])
		v2 = ItemGetWorldPosition(spawn_area[2]) - ItemGetWorldPosition(spawn_area[1])

		_pos = v0 + v1.Scale(k1) + v2.Scale(k2) 

		local	_enemy
		_enemy = SceneDuplicateItem(scene, enemy_types[Mod(Irand(0,10), 2)])
		ItemSetup(_enemy)
		ItemSetupScript(_enemy)
		_enemy = ItemGetScriptInstance(_enemy)
		_enemy.Setup(boat)
		_enemy.Reset()
		_enemy.SetSpeed(Rand(1.0, 2.0))
		_enemy.SetPosition(_pos)
		_enemy.active = true

		enemy_list.append(_enemy)
	}
	
	function	Update()
	{
		local	_enemy, n
		foreach (n, _enemy in enemy_list)
		{	
			if (_enemy.IsKilled())
			{
				UpdateKillTimeout()
				SceneDeleteObject(scene, ItemCastToObject(_enemy.body))
				enemy_list.remove(n)
				break
			}
		}
	}

}


/*
	Generic class 
	to define an enemy
*/
class	Enemy
{

	body		= 0

	boat		= 0

	type		= "Generic"
	active		= false
	sinking_y_offset
				= 0.0

	pos			= Vector()
	rot			= Vector()

	energy		= 4

	fury		= 1.0

	speed		= 1.0

	clockwise	= false

	/*@Private */
	_origin_to_enemy_vector
				= 0
	_tangent	= 0

	_update_freq
				= Sec(0.5)

	_state		= 0
	_timeout	= 0
	_shake		= 0.0

	function	OnSetup(item)
	{
		body			= item
		print("Enemy::OnSetup() : item type is '" + type + "'.")
		Reset()
	}

	function	Setup(_boat)
	{	boat = _boat	}

	function	Reset()
	{
		_state			= { explode = false,
							killed = false
						}
		_timeout 		= { last_update = 0.0,
							explode = -1.0
						}

		clockwise = (Rand(0.0, 100.0) < 50.0 ? true : false)
		sinking_y_offset	= 0.0
	}

	function	SetSpeed(_speed)
	{	speed = _speed	}

	function	SetPosition(_pos)
	{	
		pos = _pos
		ItemSetPosition(body, pos)
	}

	function	SetRotation(_rot)
	{	
		rot = _rot
		ItemSetRotation(body, rot)
	}
	
	function	ComputeTangentVector()
	{
		_origin_to_enemy_vector = pos.Normalize()
		_tangent = _origin_to_enemy_vector.Cross(Vector(0.0, 1.0, 0.0))
		if (clockwise)
			_tangent = _tangent.Reverse()
	}
	
	function	GetNormalizedClosenessFromPlayer()
	{
		local	_d = Vector(0,0,0).Dist(pos)
		_d = RangeAdjust(_d, Mtr(100.0), Mtr(300.0), 1.0, 0.0)
		return _d
	}

	function	OnUpdate(item)
	{
		if (!active)
			return
			
		//if (_state.killed)
			//active = false

		if (_state.explode)
		{
			speed *= 0.65
			sinking_y_offset += Mtr(0.5) * g_dt_frame
			sinking_y_offset *= 1.05
		}
	
		ComputeTangentVector()
		rot	= EulerFromDirection(_tangent)

		local	_d = _tangent.Normalize().Scale(Mtrs(20.0) * speed * g_dt_frame)
		_d.y -= sinking_y_offset
		pos += _d
		
		_shake *= 0.95
		
		local	_pos = pos
		if (_shake > 0.001)
		{
			local	_shake_clock = Mod((TickToSec(g_clock) * 360.0 * 7.0), 720.0)
			_shake_clock = DegreeToRadian(_shake_clock)
			local	_shake_sin_y = Lerp(0.5, sin(_shake_clock), sin(_shake_clock) < 0.0 ? -1.0 : 1.0)
			_pos += Vector(0 ,Mtr(4 * Clamp(_shake, 0.0, 1.0)) * _shake_sin_y, 0)
		}

		ItemSetRotation(body, rot)
		ItemSetPosition(body, _pos)

		if (_state.explode)
		{
			if (sinking_y_offset > Mtr(200.0))
			{
				_state.explode = false
				Kill()
			}
		}
	}
	
	function	OnCollisionEx(item, with_item, contact, direction)
	{
		if (_state.explode)
			return

		local	_col_item_name	= ItemGetName(with_item)	
		for(local n = 0; n < 5; n++)
		{
			if (_col_item_name == ("boulder_" + n))
			{
				local	boulder_strength = boat.boulder[n].strength
				Hit(contact.p[0], boulder_strength)
				ItemGetScriptInstance(with_item).Die()
			}
		}
	}

	function	Hit(contact_pos, contact_strength)
	{
		if (_state.explode || _state.killed)
			return
			
		energy -= (1.0 + ((contact_strength + 0.5) * 2.0).tointeger()).tointeger()
		
		print("Enemy::Hit() energy = " + energy)
		
		if (energy > 0)
		{
			FxCreateHitCount(ItemGetScene(body), body, clockwise, energy)
			FxCreateExplosion(ItemGetScene(body), contact_pos, 5)
			Shake()
			g_audio.PlayEnemyHit(GetNormalizedClosenessFromPlayer())
		}
		else
		{
			FxCreateHitCount(ItemGetScene(body), body, clockwise, 0)
			FxCreateExplosion(ItemGetScene(body), contact_pos, 10 + Irand(10,20))
			SuperShake()
			Explode()
			g_audio.PlayEnemyExplosion(GetNormalizedClosenessFromPlayer())
		}
	}
	
	function	Shake()
	{
		_shake = 1.0
	}
	
	function	SuperShake()
	{
		_shake = 100.0
	}

	function	Explode()
	{
		if (_state.explode)
			return
			
		print("Enemy::Explode()")

		_state.explode = true
		_timeout.explode = g_clock
	}
	
	function	Kill()
	{
		_state.killed = true
	}
	
	function	IsKilled()
	{
		return _state.killed
	}

}