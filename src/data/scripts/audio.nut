//

class	AudioPlayer
{
	track				= 0
	
	sfx_info			= 0
	sfx_validate		= 0
	sfx_proceed			= 0
	sfx_error			= 0
	
	sfx_cannon_shoot	= 0
	sfx_boulder_reload	= 0
	sfx_load_cannon		= 0
	
	sfx_boat_explosion	= 0
	sfx_boat_hit		= 0
	

	constructor()
	{
		track = {	
					music		= 0,
					boat		= 1,
					creak		= 2,
					enemy		= 3,
					sea			= 4,
					ui			= 5
				} 
				
		sfx_boat_explosion = array(2,0)
	}
	
	function	PlayerLoadSound(_filename)
	{
		local	_filepath = "data/sfx/" + _filename
		if (FileExists(_filepath))
		{
			print("AudioPlayer::PlayerLoadSound() loading '" + _filepath + "'.")
			return EngineLoadSound(g_engine, _filepath)
		}
		else
		{
			print("AudioPlayer::PlayerLoadSound() cannot find '" + _filepath + "' !!!")
			return 0
		}
	}
	
	function	Setup()
	{
		//	Preload sounds
		sfx_validate 	= PlayerLoadSound("sfx_validate.wav")
		sfx_proceed		= PlayerLoadSound("sfx_proceed.wav")
		sfx_error		= PlayerLoadSound("sfx_error.wav")
		sfx_info		= PlayerLoadSound("sfx_info.wav")
		
		sfx_cannon_shoot		= PlayerLoadSound("sfx_cannon_shoot.wav")
		sfx_boulder_reload		= PlayerLoadSound("sfx_boulder_reload.wav")
		sfx_load_cannon			= PlayerLoadSound("sfx_load_cannon.wav")
		
		sfx_boat_explosion[0]	= PlayerLoadSound("sfx_boat_explosion_0.wav")
		sfx_boat_explosion[1]	= PlayerLoadSound("sfx_boat_explosion_1.wav")
		sfx_boat_hit			= PlayerLoadSound("sfx_boat_hit.wav")
		
		//	Allocate channels
		//	Music Channel
		if (!MixerChannelTryLock(g_mixer, track.music))
			print("MusicPlayer::PlayerLoopStream() !! Cannot lock channel " + track.music)
		else
		{			
			MixerChannelSetLoopMode(g_mixer, track.music, LoopRepeat)
			MixerChannelSetGain(g_mixer, track.music, 1.0)
			MixerChannelSetPitch(g_mixer, track.music, 1.0)
		}
		
		//	Boat creaking sfx Channel
		if (!MixerChannelTryLock(g_mixer, track.creak))
			print("MusicPlayer::PlayerLoopStream() !! Cannot lock channel " + track.creak)
	
		//	UI message Channel
		if (!MixerChannelTryLock(g_mixer, track.ui))
			print("MusicPlayer::PlayerLoopStream() !! Cannot lock channel " + track.ui)
		else
		{			
			MixerChannelSetLoopMode(g_mixer, track.ui, LoopNone)
			MixerChannelSetGain(g_mixer, track.ui, 1.0)
			MixerChannelSetPitch(g_mixer, track.ui, 1.0)
		}
		
		//	Sea sfx Channel
		if (!MixerChannelTryLock(g_mixer, track.sea))
			print("MusicPlayer::PlayerLoopStream() !! Cannot lock channel " + track.sea)
	}

	function	PlaySplashScreenSound()
	{
		PlayUIStream("data/sfx/sfx_splash_screen.ogg")
	}

	function	PlayBoatStream(_stream_file)
	{
		//MixerChannelStop(g_mixer, track.boat)
		local _ch = MixerStreamStart(g_mixer, _stream_file) //MixerChannelStartStream(g_mixer, track.boat, _stream_file)
		MixerChannelSetPitch(g_mixer, _ch, Rand(0.7, 1.3))
		MixerChannelSetGain(g_mixer, _ch, Rand(0.9, 1.1))
	}
	
	function	PlayBoatSound(_sound)
	{
		//MixerChannelStop(g_mixer, track.boat)
		local _ch = MixerSoundStart(g_mixer, _sound) //MixerChannelStart(g_mixer, track.boat, _sound)
		MixerChannelSetPitch(g_mixer, _ch, Rand(0.7, 1.3))
		MixerChannelSetGain(g_mixer, _ch, Rand(0.9, 1.1))
	}
	
	function	PlayBoatCreaking()
	{			
		MixerChannelStartStream(g_mixer, track.creak, "data/sfx/sfx_bridge_creak.ogg")
		MixerChannelSetLoopMode(g_mixer, track.creak, LoopRepeat)
		MixerChannelSetGain(g_mixer, track.creak, 0.0)
		MixerChannelSetPitch(g_mixer, track.creak, 1.0)
	}
	
	function	SetBoatCreakingVolume(v)
	{	MixerChannelSetGain(g_mixer, track.creak, v) }
	
	function	PlayWaves()
	{			
		MixerChannelStartStream(g_mixer, track.sea, "data/sfx/sfx_waves.ogg")
		MixerChannelSetLoopMode(g_mixer, track.sea, LoopRepeat)
		MixerChannelSetGain(g_mixer, track.sea, 0.25)
		MixerChannelSetPitch(g_mixer, track.sea, 0.5)
	}
	
	function	PlayEnemyStream(_stream_file)
	{
		//MixerChannelStop(g_mixer, track.enemy)
		local	_ch = MixerStartStream(g_mixer, _stream_file) // MixerChannelStartStream(g_mixer, track.enemy, _stream_file)
		MixerChannelSetPitch(g_mixer, _ch, 1.0)
		MixerChannelSetGain(g_mixer, _ch, 0.25)
	}

	function	PlayEnemySound(_sound)
	{
		//MixerChannelStop(g_mixer, track.enemy)
		local	_ch = MixerSoundStart(g_mixer, _sound) // MixerChannelStart(g_mixer, track.enemy, _sound)
		MixerChannelSetPitch(g_mixer, _ch, 1.0)
		MixerChannelSetGain(g_mixer, _ch, 0.5)
		
		return _ch
	}
	
	function	PlayUIStream(_stream_file)
	{
		MixerChannelStop(g_mixer, track.ui)
		MixerChannelStartStream(g_mixer, track.ui, _stream_file)
		MixerChannelSetPitch(g_mixer, track.ui, 1.0)
		MixerChannelSetGain(g_mixer, track.ui, 0.25)
	}
	
	function	PlayUISound(_sound)
	{
		MixerChannelStop(g_mixer, track.ui)
		MixerChannelStart(g_mixer, track.ui, _sound)
		MixerChannelSetPitch(g_mixer, track.ui, 1.0)
		MixerChannelSetGain(g_mixer, track.ui, 0.25)
	}

	function	PlayEnemyExplosion(_closeness)
	{
		local	_s = (Rand(0.0, 100.0) > 50.0 ? sfx_boat_explosion[0] : sfx_boat_explosion[1])
		local	_ch = PlayEnemySound(_s)
		MixerChannelSetGain(g_mixer, _ch, 1.0)
		//MixerChannelSetGain(g_mixer, track.enemy, Lerp(_closeness, 0.25, 0.75))
	}
	
	function	PlayEnemyHit(_closeness)
	{
		PlayEnemySound(sfx_boat_hit)
		//MixerChannelSetGain(g_mixer, track.enemy, Lerp(_closeness, 0.25, 0.75))
	}
	function	PlayMusicFear()
	{
		MixerChannelStop(g_mixer, track.music)
		MixerChannelStartStream(g_mixer, track.music, "data/sfx/track_fear.ogg")
		MixerChannelSetLoopMode(g_mixer, track.music, LoopRepeat)
		MixerChannelSetPitch(g_mixer, track.music, 1.0)
		MixerChannelSetGain(g_mixer, track.music, 0.75)
	}
	
	function	PlayMusicHappy()
	{
		MixerChannelStop(g_mixer, track.music)
		MixerChannelStartStream(g_mixer, track.music, "data/sfx/track_happy.ogg")
		MixerChannelSetLoopMode(g_mixer, track.music, LoopRepeat)
		MixerChannelSetPitch(g_mixer, track.music, 1.0)
		MixerChannelSetGain(g_mixer, track.music, 0.5)
	}

	function	StopMusic()
	{	MixerChannelStop(g_mixer, track.music)	}

	function	Shoot()
	{
		PlayBoatSound(sfx_cannon_shoot)		
	}
	
	function	LoadCannon()
	{
		PlayBoatSound(sfx_load_cannon)
	}

	function	ReloadBoulder()
	{
		PlayBoatSound(sfx_boulder_reload)
		//MixerChannelSetGain(g_mixer, track.boat, Rand(0.5, 0.6))
	}
	
	function	NoBoulderLeft()
	{
		PlayUISound(sfx_error)	
	}
	
	function	UIInfo()
	{
		PlayUISound(sfx_info)
	}
	
	
	function	UIValidate()
	{
		PlayUISound(sfx_validate)
	}
	
	function	UIProceed()
	{
		PlayUISound(sfx_proceed)
	}
	
	function	UIWarn()
	{
		PlayUISound(sfx_proceed)
	}
}