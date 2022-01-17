package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.system.FlxSound;
import lime.utils.Assets;

class VanquishedSubState extends MusicBeatSubstate
{
	var bf:FlxSprite;
	var colorTween:FlxTween;
	var black:FlxSprite;
	var isboxup:Bool = false;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;

	override function create()
	{
		persistentUpdate = true;
		persistentDraw = true;

		bf = new FlxSprite();
		bf.frames = Paths.getSparrowAtlas('ZombieBfCollapses');
		bf.animation.addByPrefix('dead', 'BF dies', 24, false);
		bf.antialiasing = ClientPrefs.globalAntialiasing;
		bf.screenCenter(X);
		bf.setGraphicSize(Std.int(bf.width * 1.10));
		add(bf);

		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.screenCenter();
		add(camFollowPos);

		FlxG.sound.playMusic(Paths.music('GameOver'));
		bf.animation.play('dead', false);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);

		new FlxTimer().start(5.5, function(tmr:FlxTimer)
		{
			isboxup = true;
		});
	}

	override function update(elapsed:Float)
	{
		if(isboxup) {
			if (controls.ACCEPT)
			{
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					FlxG.resetState();
					isboxup = false;
				});
				FlxG.sound.play(Paths.sound('gravebutton'));
			}
		}

		super.update(elapsed);
	}
}