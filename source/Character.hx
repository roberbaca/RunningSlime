package;

import js.html.svg.GradientElement;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxG;

class Character extends FlxSprite
{	
	public static inline var JUMP_VEL = 300;
	public static inline var MOV_VEL = 150;
	public static inline var GRAVITY = 800;

	var nJumps: 		Int = 0; 		// para evitar un numero infinito de saltos dobles
	var jumping:		Bool = false;	// flag
	var coyoteTimer:	Float = 0;		// coyote time

	public function new(X: Float, Y: Float)
	{
		super(X, Y);
		loadGraphic("assets/images/enemies-spritesheet.png", true, 20, 20);
		animation.add("idle", [10, 11], 6, true);
		animation.play("idle");
		
		width = 16;
		offset.x = 2;
		height = 10;
		offset.y = 10;
		y += 4;

		// el personaje tiene velocidad hacia la derecha y gravedad
		velocity.x = MOV_VEL; 
		acceleration.y = GRAVITY;
	}

	public override function update(elapsed: Float)
	{	
		super.update(elapsed);
		var isTouchingFloor = wasTouching & FlxObject.FLOOR != 0; 
		
		if(isTouchingFloor)
		{
			jumping = false;
			coyoteTimer = 0;
			nJumps = 0;			// reseteo el num saltos a cero cuando se toca el suelo
		}
		else
		{
			if(!jumping)
			{
				coyoteTimer += elapsed;
			}
		}
	

		//el personaje debe invertir su velocidad horizontal al chocar con la pared
		if(wasTouching & FlxObject.WALL != 0)
		{
			if(wasTouching & FlxObject.RIGHT != 0)
			{
				velocity.x = -MOV_VEL;
				flipX = true;
			}
			if(wasTouching & FlxObject.LEFT != 0)
			{
				velocity.x = MOV_VEL;
				flipX = false;
			}
		}

	
		if(FlxG.keys.justPressed.W)
		{
			// el personaje puede saltar utilizando la tecla W si se encuentra tocando el suelo
			if (isTouchingFloor || (!jumping && coyoteTimer <= 0.1))
			{
				jump();
			}
			// el personaje puede efectuar un salto doble si se encuentra en la parte más alta de un salto
			if ((wasTouching & FlxObject.FLOOR == 0) && (nJumps == 0) && (Math.abs(velocity.y) < 90))
			{
				jump();
				nJumps++;
			}
		}
	}

	public function animateDeath()
	{
		allowCollisions = FlxObject.NONE;
		velocity.y = -JUMP_VEL;
		velocity.x = velocity.x/5;
		angularVelocity = 200;
	}

	private function jump()
	{
		y--;
		velocity.y = -JUMP_VEL;
		jumping = true;
	}
}
