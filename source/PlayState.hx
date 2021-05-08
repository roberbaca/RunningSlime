package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxObject;


class PlayState extends FlxState
{
	override public function create():Void
	{
		//FlxG.debugger.visible = true; // para debug visible por codigo
	
		super.create();
		trace("Loading assets/data/level"+Global.levelNum+".tmx");
		level = new FlxTilemap();
		
		var tiledMap = new TiledMap("assets/data/level"+Global.levelNum+".tmx");
		var layer = cast(tiledMap.getLayer("solid"), TiledTileLayer);
		level.loadMapFromArray(layer.tileArray, layer.width, layer.height, "assets/images/tileset.png", 16, 16, FlxTilemapAutoTiling.OFF, 1);
		
		var background = new FlxTilemap();
		var backgroundLayer = cast(tiledMap.getLayer("background"), TiledTileLayer);
		background.loadMapFromArray(backgroundLayer.tileArray, layer.width, layer.height, "assets/images/tileset.png", 16, 16, FlxTilemapAutoTiling.OFF, 1);

		var props = new FlxTilemap();
		var propsLayer = cast(tiledMap.getLayer("props"), TiledTileLayer);
		props.loadMapFromArray(propsLayer.tileArray, layer.width, layer.height, "assets/images/tileset.png", 16, 16, FlxTilemapAutoTiling.OFF, 1);
	

		// configurar los tiles para que sean one-sided platforms
		level.setTileProperties(21, FlxObject.CEILING);
		level.setTileProperties(27, FlxObject.CEILING);
		level.setTileProperties(33, FlxObject.CEILING);
		level.setTileProperties(34, FlxObject.CEILING);
		level.setTileProperties(35, FlxObject.CEILING);
		level.setTileProperties(40, FlxObject.CEILING);


		// create groups
		spikes = new FlxGroup();
		coins = new FlxGroup();
		buttons = new FlxGroup();
		doors = new FlxGroup();
		characterCollideables = new FlxGroup();
		characterCollideables.add(level);
		characterCollideables.add(spikes);
		characterCollideables.add(doors);
		characterCollideables.add(coins);
		characterCollideables.add(buttons);

		// load objects
		var objectLayer = cast(tiledMap.getLayer("objects"), TiledObjectLayer);
		for(i in 0...objectLayer.objects.length)
		{
        	loadObject(objectLayer.objects[i]);
        }

		// scrolling
		FlxG.camera.follow(char);
		FlxG.camera.setScrollBoundsRect(0, 0, tiledMap.fullWidth, tiledMap.fullHeight, true);

		// add objects to scene
		add(background);
		add(doors);
		add(level);
		add(spikes);
		add(char);
		add(props);
		add(coins);
		add(buttons);
	}



	override public function update(elapsed: Float)
	{
		super.update(elapsed);
		if(FlxG.keys.justPressed.R)
		{
			FlxG.resetState();
		}
		
		// comprobar colisiones:
		FlxG.overlap(characterCollideables, char, onCharCollision); 

		// after the dead animation, restart when character falls from the screen
		if(char.y > FlxG.camera.maxScrollY)
		{
			FlxG.resetState();
		}
		
	}


	function nextLevel()
	{
		Global.levelNum = ((Global.levelNum + 1) % 4); // agrego 1 nivel adicional
		char.allowCollisions = FlxObject.NONE;
		FlxG.resetState();
	}



	function loadObject(obj: TiledObject)
	{
        var type = obj.type;
		if(type == "Spikes")
		{
            var orientation = obj.properties.get("orientation");
            var spike = new Spikes(obj.x, obj.y-16, orientation);
            spikes.add(spike);
		}
		else if(type == "Player")
		{
			char = new Character(obj.x, obj.y-16);
		}
		else if(type == "Coin")
		{
			coins.add(new Coin(obj.x, obj.y-16));
		}
		else if(type == "Button")
		{
			var button_id = Std.parseInt(obj.properties.get("button_id")); 
			buttons.add(new Button(obj.x, obj.y-16, button_id));
		}
		else if(type == "Door")
		{
			var door_id = Std.parseInt(obj.properties.get("door_id")); 
			doors.add(new Door(obj.x, obj.y, door_id));
		}
		else if(type == "Exit")
		{
			buttons.add(new Exit(obj.x, obj.y-16));
		}
		else
		{
            trace("ERROR: no reconozco el tipo "+ obj.type);
        }
    }


	function onCharCollision(object: FlxObject, char:Character)
	{
		// manejo todas las colisiones del personaje con una unica funcion
		
		switch (Type.getClass(object))
		{
			case FlxTilemap:
			{
				FlxObject.separate(object, char);
			}
			
			case Spikes:
			{
				char.animateDeath();
				if (char.animation.finished)
				{
					FlxG.resetState(); // se reinicia el nivel
				}
			}
			
			case Coin:
			{
				var moneda: Coin = cast(object, Coin);
				moneda.kill(); // desaparece
			}
			
			case Button:
			{				
				FlxObject.separate(object, char); 
			}

			case Exit:
			{
				// pasamos de nivel si alcanzamos la salida
				nextLevel();
			}

			case Door:
			{
				FlxObject.separate(object, char);
			}

		}
	}


	private var char: 					Character;
	private var level: 					FlxTilemap;
	private var spikes: 				FlxGroup;
	private var coins: 					FlxGroup;
	private var buttons: 				FlxGroup;
	private var doors: 					FlxGroup;
	private var characterCollideables: 	FlxGroup;
}
