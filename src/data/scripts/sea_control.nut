//	Sea Control

//-----------------------------------
function	ScrollTextureFromMaterial(_mat, _u, _v)
{
	local	m = TransformationMatrix
		(
			Vector(0.5 + _u, 0.5 + _v, 0.0),			// Position
			Vector(0.0, 0.0, 0.0), 			// Rotation
			Vector(1.0, 1.0, 1.0),			// Scale
			Vector(-0.5, -0.5, 0.0)			// Pivot
		)

	MaterialChannelSetUVMatrix(_mat, ChannelColor, m)
	MaterialUpdate(_mat)
}

//------------------
class	SeaAnimation
//------------------
{
	scene			= 0
	sea_wave		= 0
	
	angle			= 0.0

	wave_fury		= 1.0	// < 1.0 = slows the animation, 1.0 = normal, > 1.0 increases the fury

	constructor()
	{
		sea_wave = []
		for (local n = 0; n < 2; n++)
			sea_wave.append({ item = 0, rot = 0.0, rot_speed = 1.0, material = []})
	}

	function	Setup(_scene)
	{
		scene = _scene

		for (local n = 0; n < 2; n++)
		{
			sea_wave[n].item = SceneFindItem(scene, "sea_wave_" + n)
			sea_wave[n].rot = ItemGetRotation(sea_wave[n].item)
			sea_wave[n].rot_speed = (Mod(n,2) == 0 ? 1.0 : -1.0)

			local	geo = ItemGetGeometry(sea_wave[n].item)
			for(local m = 0; m < 2; m++)
				sea_wave[n].material.append(GeometryGetMaterialFromIndex(geo, m))
		}
	}

	function	Update()
	{

		angle += g_dt_frame * DegreeToRadian(2.0) * 60.0 * Pow(wave_fury, 0.25)

		for (local n = 0; n < 2; n++)
		{
			//	Scroll geometry
			sea_wave[n].rot.y += DegreeToRadian(wave_fury * 0.125 * sea_wave[n].rot_speed * sin(angle))
			ItemSetRotation(sea_wave[n].item, sea_wave[n].rot)

			//	Scroll texture
			for(local m = 0; m < 2; m++)
			{
				local	_u, _v
				
				_u = sea_wave[n].rot.y * -4.0; 
				_v = 0.0

				ScrollTextureFromMaterial(sea_wave[n].material[m], _u, _v)
			}
		}
	}

}