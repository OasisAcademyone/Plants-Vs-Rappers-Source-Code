package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

class RareExitState extends MusicBeatState
{

	public function new():Void
	{
		super();
	}

	override function create()
	{
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('rare_screentone'));

		var exitfunniness:FlxSprite = new FlxSprite().loadGraphic(Paths.image('secrets/exit1'));
		exitfunniness.antialiasing = ClientPrefs.globalAntialiasing;
		exitfunniness.screenCenter();
		add(exitfunniness);

		super.create();
	}

	override function update(elapsed:Float)
	{
		new FlxTimer().start(5.5, function(tmr:FlxTimer)
		{
			Sys.exit(0);
		});

		super.update(elapsed);
	}
}
