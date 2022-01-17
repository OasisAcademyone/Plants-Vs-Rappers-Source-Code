package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.FlxObject;
import lime.utils.Assets;

using StringTools;

class AchievementPVZState extends MusicBeatState
{
	var sunachievementlocked:FlxSprite;
	var sunachievement:FlxSprite;
	var camFollow:FlxObject;
	var deadzone:FlxRect;
	var height:Float = 100;
	var width:Float = 10;

	override function create()
	{
		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		var Dirt:FlxSprite = new FlxSprite(0,-600).loadGraphic(Paths.image('SoilAchievementBg'));
		Dirt.screenCenter(X);
		Dirt.antialiasing = ClientPrefs.globalAntialiasing;
		add(Dirt);

		sunachievement = new FlxSprite().loadGraphic(Paths.image('AchievementSaveData/sundropped'));
		sunachievement.antialiasing = ClientPrefs.globalAntialiasing;

		var sunachievementlocked = new FlxSprite().loadGraphic(Paths.image('AchievementSaveData/sundroppedX'));
		sunachievementlocked.antialiasing = ClientPrefs.globalAntialiasing;

		if(FlxG.save.data.sundropped) {
			add(sunachievement);
		}
		else {
			add(sunachievementlocked);
		}

		
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.DOWN)
		{
			var camspeed:Float = 800 * elapsed;
			camFollow.y += camspeed;
		}

		if (FlxG.keys.pressed.UP)
		{
			var camspeed:Float = 700 * elapsed;
			camFollow.y -= camspeed;
		}

		if (controls.ACCEPT)
		{
			FlxG.switchState(new MainMenuState());
			FlxG.sound.play(Paths.sound('gravebutton'));
			FlxG.sound.playMusic(Paths.music('pvzmusic'));
		}

		super.update(elapsed);
	}
}