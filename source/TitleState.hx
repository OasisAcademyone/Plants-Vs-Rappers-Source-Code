package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.math.FlxMath;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var PopSplash:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var logoSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var easterEggEnabled:Bool = true; //Disable this to hide the easter egg
	var easterEggKeyCombination:Array<FlxKey> = [FlxKey.B, FlxKey.B]; //bb stands for bbpanzu cuz he wanted this lmao
	var lastKeysPressed:Array<FlxKey> = [];

	override public function create():Void
	{
		#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}

		//Gonna finish this later, probably
		#end
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.camera.zoom = defaultCamZoom;

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#end

		new FlxTimer().start(1.0, function(tmr:FlxTimer)
		{	
			startIntro();
		});
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var Ground:FlxSprite;
	var PVR:FlxSprite;
	var GroundStart:FlxSprite;
	var clickavaliable:Bool = false;
	var passed:Bool = false;
	var drippedOUT:Bool = false;
	var zombiehead:FlxSprite;
	var swagShader:ColorSwap = null;
	public var defaultCamZoom:Float = 1.05;

	function startIntro()
	{
		if (!initialized)
		{


			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('pvzmusic'));
			// FlxG.sound.list.add(music);
			// music.play();

			if(FlxG.sound.music == null && FlxG.random.bool(90)) {
				FlxG.sound.playMusic(Paths.music('pvzmusic'));

				DiscordClient.changePresence("Growing all Plants...", null);

				FlxG.sound.music.volume = 0.5;

			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
			#end
				
			}
			else if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('trapmusic'));

				DiscordClient.changePresence("Getting the drip...", null);

				FlxG.sound.music.volume = 0.75;
				drippedOUT = true;

			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
			#end

			}
		}

		Conductor.changeBPM(110);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		Ground = new BGSprite('TitleBg', 0, 0, 0, 0);
		Ground.updateHitbox();
		Ground.antialiasing = ClientPrefs.globalAntialiasing;
		Ground.screenCenter();
		add(Ground);

		swagShader = new ColorSwap();
		if(!FlxG.save.data.psykaEasterEgg || !easterEggEnabled) {
			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
			gfDance.frames = Paths.getSparrowAtlas('gf-zombie');
			gfDance.animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}
		else //Psyka easter egg
		{
			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.04);
			gfDance.frames = Paths.getSparrowAtlas('psykaDanceTitle');
			gfDance.animation.addByIndices('danceLeft', 'psykaDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'psykaDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		gfDance.shader = swagShader.shader;
		add(logoBl);
		//logoBl.shader = swagShader.shader;

		PVR = new FlxSprite().loadGraphic(Paths.image('PVRTitleIntro'));
		PVR.screenCenter(X);
		PVR.y = -500;
		PVR.setGraphicSize(Std.int(PVR.width * 0.75));
		PVR.antialiasing = ClientPrefs.globalAntialiasing;
		PVR.shader = swagShader.shader;
		add(PVR);

		GroundStart = new FlxSprite(0,900);
		GroundStart.frames = Paths.getSparrowAtlas('Begin');
		GroundStart.screenCenter(X);
		GroundStart.animation.addByPrefix('gamepress', "Press Game", 24, false);
		add(GroundStart);

		zombiehead = new FlxSprite(710,400);
		zombiehead.frames = Paths.getSparrowAtlas('headbounce');
		zombiehead.animation.addByPrefix('popup', "Bounce", 24, false);
		zombiehead.setGraphicSize(Std.int(zombiehead.width * 0.45));
		zombiehead.visible = false;
		add(zombiehead);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		logoSpr = new FlxSprite(0, FlxG.height * 0.4).loadGraphic(Paths.image('titlelogo'));
		add(logoSpr);
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.55));
		logoSpr.updateHitbox();
		logoSpr.screenCenter(X);
		logoSpr.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	var transitioning:Bool = false;
	
	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	override function update(elapsed:Float)
	{

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		if (clickavaliable) {
			if (FlxG.mouse.pressed && zombiehead.visible && FlxG.mouse.overlaps(GroundStart))
			{
				clickavaliable = false;
				FlxG.sound.play(Paths.sound('gravebutton'));
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{	
					FlxG.switchState(new MainMenuState());
				});
			}
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		// EASTER EGG

		if (!transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
				// FlxG.sound.music.stop();

				if (zombiehead.visible) {
					FlxG.switchState(new MainMenuState());
				}

				closedState = true;

				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
			else if(easterEggEnabled)
			{
				var finalKey:FlxKey = FlxG.keys.firstJustPressed();
				if(finalKey != FlxKey.NONE) {
					lastKeysPressed.push(finalKey); //Convert int to FlxKey
					if(lastKeysPressed.length > easterEggKeyCombination.length)
					{
						lastKeysPressed.shift();
					}
					
					if(lastKeysPressed.length == easterEggKeyCombination.length)
					{
						var isDifferent:Bool = false;
						for (i in 0...lastKeysPressed.length) {
							if(lastKeysPressed[i] != easterEggKeyCombination[i]) {
								isDifferent = true;
								break;
							}
						}

						if(!isDifferent) {
							trace('Easter egg triggered!');
							FlxG.save.data.psykaEasterEgg = !FlxG.save.data.psykaEasterEgg;
							FlxG.sound.play(Paths.sound('secretSound'));

							MusicBeatState.switchState(new TitleState());
														
							lastKeysPressed = [];
							closedState = true;

						}
					}
				}
			}
		}

		if (pressedEnter && !skippedIntro)
		{

		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	function Splash()
	{
		PopSplash = new FlxSprite().loadGraphic(Paths.image('SplashPopCap'));
		PopSplash.screenCenter();
		PopSplash.antialiasing = ClientPrefs.globalAntialiasing;
		PopSplash.visible = true;
		PopSplash.alpha = 1;
		add(PopSplash);

		PopSplash.alpha = 0;

		FlxTween.tween(PopSplash, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut});

		new FlxTimer().start(1.2, function(tmr:FlxTimer)
		{	
			FlxTween.tween(PopSplash, {alpha: 0}, 0.5, {
				ease: FlxEase.quadInOut,
				onComplete: function(twn:FlxTween)
				{
					PopSplash.destroy();
				}
			});
		});
	}

	function alphafade()
	{
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{	
			PopSplash.alpha = 0;
		});
	}

	private static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null) 
			logoBl.animation.play('bump');

		if(gfDance != null) {
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}
		
		if(drippedOUT) {
			bounce();
		}

		if(!passed) {
			if(!closedState) {
				switch (curBeat)
				{
					case 1:
						alphafade();
					case 3:
						Splash();
					case 7:
						skipIntro();
				}
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		remove(logoSpr);

		remove(PopSplash);

		passed = true;

		FlxTween.tween(PVR, {y: -190}, 0.3, {
			ease: FlxEase.quadInOut,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(PVR, {y: -210}, 0.20, {ease: FlxEase.quadOut});
			}
		});

		FlxTween.tween(GroundStart, {y: 475}, 0.3, {
			ease: FlxEase.quadInOut,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(GroundStart, {y: 490}, 0.20, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						GroundStart.animation.play('gamepress');
					}
				});
			}
		});

		new FlxTimer().start(3.7, function(tmr:FlxTimer)
		{	
			zombiehead.visible = true;
			clickavaliable = true;
			zombiehead.animation.play('popup');
			FlxG.sound.play(Paths.sound('ZombieGrunts/zombie6'));
		});

		DiscordClient.changePresence("Title Screen", null);

		remove(credGroup);
		skippedIntro = true;
	}

	function bounce():Void
	{
		FlxG.camera.zoom += 0.15;

		FlxTween.tween(FlxG.camera, {zoom: 1.00}, 0.3, {
			ease: FlxEase.quadOut,
			onComplete: function(twn:FlxTween)
			{
				defaultCamZoom =  1.00;
			}
		});
	}
}
