package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var black:FlxSprite;
	var Hitbox1:FlxSprite;
	var soundplay:Bool = false;

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('CreditsScreen'));
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.lowQuality;
		add(bg);

		black = new FlxSprite().loadGraphic(Paths.image('Blackfade'));
		black.screenCenter();
		add(black);

		Hitbox1 = new FlxSprite(500, 610).makeGraphic(270, 70, FlxColor.WHITE);
		Hitbox1.alpha = 0;
		add(Hitbox1);

		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('paper'));

		FlxTween.tween(black, {alpha: 0}, 1.6, {type: ONESHOT});

		if (soundplay)
		{				
			FlxG.sound.play(Paths.sound('gravebutton'));
		}
	}


	override function update(elapsed:Float)
	{
		if (FlxG.mouse.overlaps(Hitbox1))
		{				
			if(FlxG.mouse.pressed)
			{
				soundplay = true;
				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					FlxG.sound.playMusic(Paths.music('pvzmusic'));
					FlxG.switchState(new MainMenuState());
				});
			}
		}

		super.update(elapsed);
	}
}