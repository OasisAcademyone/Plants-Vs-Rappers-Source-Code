package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['story_mode', 'freeplay', #if ACHIEVEMENTS_ALLOWED 'awards', #end 'options'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var clouds:FlxSprite;
	var quitpopup:FlxSprite;
	var freeplaypopup:FlxSprite;
	var mouse:FlxSprite;
	var dontplay:Bool = false;
	var notice:FlxSprite;
	var clickable:Bool = true;
	var Mouse:Bool = false;
	var waittime:Bool = false;
	var noticeClick:FlxSprite;
	var black:FlxSprite;
	var spr:FlxSprite;
	var menuItem:FlxSprite;
	var bg:FlxSprite;
	var OnSprite:Bool = false;
	var Creditsoption:FlxSprite;
	var Quitoption:FlxSprite;
	var Hitbox1:FlxSprite;
	var Hitbox2:FlxSprite;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Main Menu", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.mouse.visible = true;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];	

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.000125 - (0.02 * (optionShit.length - 0.3)), 0.1);

		var sky:FlxSprite = new FlxSprite().loadGraphic(Paths.image('skybgmenu'));
		sky.setGraphicSize(Std.int(sky.width * 1.02));
		sky.screenCenter();
		sky.scrollFactor.set(0, 0.00);
		sky.antialiasing = ClientPrefs.globalAntialiasing;
		add(sky);

		clouds	= new FlxSprite().loadGraphic(Paths.image('cloudsloop'));
		clouds.setGraphicSize(Std.int(clouds.width * 0.9));
		clouds.scrollFactor.set(0, 0.0);
		clouds.screenCenter();
		clouds.y = -200;
		clouds.antialiasing = ClientPrefs.globalAntialiasing;
		add(clouds);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.setGraphicSize(Std.int(bg.width * 1.02));
		bg.screenCenter();
		bg.scrollFactor.set(0, 0.00);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var yScroll:Float = Math.max(0.15 - (0.05 * (optionShit.length - 8)), 0.1);
		var tomb:FlxSprite = new FlxSprite().loadGraphic(Paths.image('TombOptions'));
		tomb.scrollFactor.set(0, 0);
		tomb.y = -450;
		tomb.setGraphicSize(Std.int(tomb.width * 0.70));
		tomb.screenCenter(X);
		tomb.antialiasing = ClientPrefs.globalAntialiasing;
		add(tomb);

		Creditsoption = new FlxSprite();
		Creditsoption.frames = Paths.getSparrowAtlas('Options/credits');
		Creditsoption.y = 490;
		Creditsoption.x = 160;
		Creditsoption.animation.addByPrefix('idle', "credits basic", 24);
		Creditsoption.animation.addByPrefix('selected', "credits selected", 24);
		Creditsoption.animation.play('idle');
		Creditsoption.setGraphicSize(Std.int(Creditsoption.width * 0.68));
		Creditsoption.scrollFactor.set(0, 0.00);
		Creditsoption.antialiasing = ClientPrefs.globalAntialiasing;
		add(Creditsoption);

		Quitoption = new FlxSprite();
		Quitoption.frames = Paths.getSparrowAtlas('Options/quit');
		Quitoption.y = 490;
		Quitoption.x = 810;
		Quitoption.animation.addByPrefix('idle', "quit basic", 24);
		Quitoption.animation.addByPrefix('selected', "quit selected", 24);
		Quitoption.animation.play('idle');
		Quitoption.setGraphicSize(Std.int(Quitoption.width * 0.68));
		Quitoption.scrollFactor.set(0, 0.00);
		Quitoption.antialiasing = ClientPrefs.globalAntialiasing;
		add(Quitoption);

		Hitbox1 = new FlxSprite(250, 680).makeGraphic(151, 50, FlxColor.WHITE);
		Hitbox1.alpha = 0;
		Hitbox1.scrollFactor.set(0, 0);
		add(Hitbox1);

		Hitbox2 = new FlxSprite(900, 685).makeGraphic(140, 50, FlxColor.WHITE);
		Hitbox2.alpha = 0;
		Hitbox2.scrollFactor.set(0, 0);
		add(Hitbox2);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, 0.0);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 0 - (Math.max(optionShit.length, 5) - 4) * 50;
			menuItem = new FlxSprite(0, (i * 175)  + offset);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " selected", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.75));
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, 0.00);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
		}

		var yScroll:Float = Math.max(0.36 + (0.062 * (optionShit.length - 5)), 0.1);
		var leaves:FlxSprite = new FlxSprite(-40).loadGraphic(Paths.image('Leaves'));
		leaves.scrollFactor.set(0, 0.00);
		leaves.setGraphicSize(Std.int(leaves.width * 0.87));
		leaves.screenCenter(X);
		leaves.y = -20;
		leaves.antialiasing = ClientPrefs.globalAntialiasing;

		quitpopup = new FlxSprite().loadGraphic(Paths.image('QuitBox'));
		quitpopup.scrollFactor.set(0, 0);
		quitpopup.setGraphicSize(Std.int(quitpopup.width * 1));
		quitpopup.antialiasing = ClientPrefs.globalAntialiasing;
		quitpopup.visible = false; 
		quitpopup.screenCenter();
		add(quitpopup);

		freeplaypopup = new FlxSprite().loadGraphic(Paths.image('LockedFreeplayBox'));
		freeplaypopup.scrollFactor.set(0, 0);
		freeplaypopup.setGraphicSize(Std.int(freeplaypopup.width * 1));
		freeplaypopup.antialiasing = ClientPrefs.globalAntialiasing;
		freeplaypopup.visible = false; 
		freeplaypopup.screenCenter();
		add(freeplaypopup);

		FlxG.camera.follow(camFollowPos, null, 20);

		FlxTween.angle(clouds, -360, 360, 1480.0, {type: LOOPING});

		if(!FlxG.save.data.HAVESEEN)
		{
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				black = new FlxSprite().loadGraphic(Paths.image('Blackfade'));
				black.screenCenter();
				black.setGraphicSize(Std.int(black.width * 4));
				black.alpha = 0;
				add(black);

				FlxTween.tween(black, {alpha: 0.6}, 1, {ease: FlxEase.quartInOut});

				new FlxTimer().start(1.1, function(tmr:FlxTimer)
				{
					clickable = false;
					Mouse = true;
					waittime = false;
		
					FlxG.sound.play(Paths.sound('chime'));

					notice = new FlxSprite(0,-280).loadGraphic(Paths.image('notice'));
					notice.screenCenter(X);
					notice.antialiasing = ClientPrefs.globalAntialiasing;
					notice.setGraphicSize(Std.int(notice.width * 1.18));
					add(notice);

					noticeClick = new FlxSprite(0,-280).loadGraphic(Paths.image('noticeclick'));
					noticeClick.screenCenter(X);
					noticeClick.antialiasing = ClientPrefs.globalAntialiasing;
					noticeClick.visible = false;
					noticeClick.setGraphicSize(Std.int(noticeClick.width * 1.18));
					add(noticeClick);

					WaitingTime();
				});
			});
		}

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}
	
	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER && quitpopup.visible)
		{
			if (FlxG.random.bool(70))
				{
					FlxG.switchState(new RareExitState());
				}
				else {
					FlxG.sound.play(Paths.sound('gravebutton'));
					FlxG.sound.music.stop();
					new FlxTimer().start(0.6, function(tmr:FlxTimer)
					{
						Sys.exit(0);
					});
				}
		}

		if (FlxG.keys.justPressed.ESCAPE && quitpopup.visible)
		{
			FlxG.sound.play(Paths.sound('gravebutton'));
			quitpopup.visible = false;
			selectedSomethin = false;
			clickable = true;
			Mouse = false;
		}

		if (FlxG.keys.justPressed.ESCAPE && freeplaypopup.visible)
		{
			FlxG.sound.play(Paths.sound('gravebutton'));
			freeplaypopup.visible = false;
			dontplay = false;
			selectedSomethin = false;
			clickable = true;
			Mouse = false;
		}

		if (FlxG.sound.music.volume < 0.5)
		{
			FlxG.sound.music.volume += 0.2;
		}

		if (waittime && noticeClick.visible && FlxG.mouse.pressed)
		{
			clickable = true;
			Mouse = false;
			remove(noticeClick);
			FlxG.save.data.HAVESEEN = true;
			FlxTween.tween(black, {alpha: 0}, 0.5, {ease: FlxEase.quartInOut});
		}
		//credits option
		if(Mouse)
		{
			if(!FlxG.mouse.overlaps(Hitbox1))
				Creditsoption.animation.play('idle');
		}
		
		if (FlxG.mouse.overlaps(Hitbox1))
		{
			if(clickable)
			{
				Mouse = true;
				Creditsoption.animation.play('selected');
			}
				
			if(FlxG.mouse.pressed && clickable)
			{
				FlxG.switchState(new CreditsState());
			}
		}

		if(Mouse)
		{
			if(!FlxG.mouse.overlaps(Hitbox2))
				Quitoption.animation.play('idle');
		}
		//quit option
		if (FlxG.mouse.overlaps(Hitbox2))
		{
			if(clickable)
			{
				Mouse = true;
				Quitoption.animation.play('selected');
			}
				
			if(FlxG.mouse.pressed && clickable)
			{
				popup();
			}
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		FlxG.camera.zoom = 0.75;

		menuItems.forEach(function(spr)
			{
				if(FlxG.save.data.HAVESEEN)
				{
					if(Mouse)
					{
						if(!FlxG.mouse.overlaps(spr))
							spr.animation.play('idle');
					}
					
					if (FlxG.mouse.overlaps(spr))
					{
						if(clickable)
						{
							curSelected = spr.ID;
							Mouse = true;
							spr.animation.play('selected');
						}
							
						if(FlxG.mouse.pressed && clickable)
						{
							selectSomething();
						}
					}
				}
		
				spr.updateHitbox();
			});
	
			super.update(elapsed);

		menuItems.forEach(function(spr)
		{
			spr.screenCenter(X);
		});
	}

	function stateSelect()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story_mode':
				FlxG.switchState(new StoryMenuState());
			case 'awards':
				FlxG.switchState(new AchievementPVZState());
			case 'options':
				FlxG.switchState(new OptionsState());
			//case 'credits':
				//FlxG.switchState(new CreditsState());
			//case 'quit':
			//	popup();
	
		}
	}

	function WaitingTime()
	{
		new FlxTimer().start(10, function(tmr:FlxTimer)
		{
			waittime = true;
			remove(notice);
			noticeClick.visible = true;
			FlxG.sound.play(Paths.sound('chime'));
		});
	}

	function selectSomething()
	{
		if (optionShit[curSelected] == 'freeplay')
		{
			if (FlxG.save.data.fghnfioghfdhfsdh839ljdsdand)
			{
				FlxG.switchState(new FreeplayState());
			}
			else
			{
				LockedFreeplay();
				dontplay = true;
			}
		}
		else {
			stateSelect();
		}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.x = 0.128 * spr.frameWidth;
				spr.offset.y = 0.128 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}

	function LockedFreeplay()
	{
		freeplaypopup.visible = true;
		clickable = false;
		Mouse = true;

		if(dontplay) {
			
		}
		else {
			FlxG.sound.play(Paths.sound('buzzer'));
		}
	}

	function popup()
	{
		quitpopup.visible = true;
		clickable = false;
		Mouse = true;
	}
}
