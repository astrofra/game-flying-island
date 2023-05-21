

//------------
class	Island
//------------
{
	pos		= 0
	size	= 0
	scene	= 0
	boat	= 0
	
	item	= 0
	
	constructor()
	{
		pos		= Vector()
	}
	
	function	Setup(_scene, _boat)
	{
		scene = _scene
		boat = _boat
		
		local	_obj = SceneAddObject(scene, "island")
		item = ObjectGetItem(_obj)
		ObjectSetGeometry(_obj, EngineLoadGeometry(g_engine, "data/meshes/island.nmg"))
		ItemSetRotation(item, Vector(0,DegreeToRadian(-90.0),0))
		
		local	_pos = Vector()
		local	_r_seed = Mod(TickToSec(g_clock) * 1000.0, 234)
		
		print("Island::Setup() _r_seed = " + _r_seed)
		
		for (local n = 0; n < _r_seed; n++)
			_pos += Vector(Rand(-1, 1), 0, Rand(-1, 1))
			 
		_pos = _pos.Normalize()
		pos = _pos.Scale(Km(5.0))
		
		ItemSetTargetOffsetRotation(item, Vector(0,Deg(180.0),0))
		
		print("Island::OnSetup()")
	}
	
	//------------------
	function	Update()
	//------------------
	{
		local	_visual_dist
		local	_d = GetDistanceFromBoat()
				
		local	_min = Km(2.0)
		local	_max = Km(4.0)
		
		local	_y = RangeAdjust(Clamp(_d, _min, _max), _min, _max, 0.0, Mtr(-350.0))
		local	_f = RangeAdjust(Clamp(_d, Km(1.0), _max), Km(1.0), _max, Km(2.0), Km(5.0))
		
		local	_pos = ((pos - boat.GetRealPosition()).Normalize()).Scale(_f)
		_pos.y = _y
		ItemSetPosition(item, _pos)		

		local	_min = Mtr(150.0)
		local	_max = Km(2.0)
		
		size = 2.0 * RangeAdjust(Clamp(_d, _min, _max), _min, _max, 5.0, 2.0)
		
		ItemSetScale(item, Vector(size,size,size))
		
		ItemSetTarget(item, Vector(0,0,0))
	}
	
	//------------------------------
	function	GetDistanceFromBoat()
	//------------------------------
	{
		return (boat.GetRealPosition()).Dist(pos)
	}
	
	//----------------------------
	function	GetVicinityLevel()
	//----------------------------
	{
		local	_island_pos = ItemGetPosition(item).Normalize()
		local	_boat_dir = boat.GetRealDirection().Normalize()
		
		local	_v = _island_pos.Dot(_boat_dir)
		
		_v = RangeAdjust(Clamp(_v, 0.7, 0.95), 0.7, 0.95, 0.5, 1.0)
		
		return _v
	}
	
	//----------------------------
	function	GetAngleWithBoat()
	//----------------------------
	{

		local	_island_pos = ItemGetPosition(item).Normalize()
		local	_boat_dir = boat.GetRealDirection().Normalize()
		
		local	_d = _island_pos.AngleWithVector(_boat_dir)
		local	_c = _island_pos.Cross(_boat_dir)

		if (_c.y > 0.0)
			_d = -_d
		
		return _d	
	}
		
}