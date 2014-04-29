package
{
	import flash.display.GraphicsPathWinding;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Stevie
	 */
	public dynamic class Game extends MovieClip
	{
		const TILE_SIZE:int = 30;
		const WIN_LEVEL:int = 4;
		
		var map:Array;
		var map1:Array;
		var map2:Array;
		var tileArray:Array;
		var container:Sprite;
		var tileMap:Array;
		var player:MovieClip;
		var playerPos:Array = [4, 6];
		var speed:int = 10;
		var ySpeed:Number = Infinity;
		var gravity:Number = 1;
		var jumpSpeed:Number = -12;
		var playerIsDead:Boolean;
		var switchLevel:Boolean;
		var currentMap:int;
		var numStars:int;
		var loader:MapLoader;
		var loadTime;
		var exitDoor:DoorTile;
		
		public function Game()
		{
		}
		
		public function init():void
		{
			initMaps();
			loadTime = setInterval(realInit, 500);
		}
		
		function cloneArray(source:Object):*
		{
			var myBA:ByteArray = new ByteArray();
			myBA.writeObject(source);
			myBA.position = 0;
			return (myBA.readObject());
		}
		
		private function realInit():void
		{
			map = cloneArray(loader.grid);
			clearInterval(loadTime);
			tileArray = [GrassTile, SkyTile, SpikeTile, DoorTile, StarTile];
			container = new Sprite();
			addChild(container);
			currentMap = 1;
			buildMap();
			initPlayer();
			ArrowKeyInput.init(stage);
			addEventListener(Event.ENTER_FRAME, update);
			addEventListener(Event.EXIT_FRAME, lastUpdate);
		}
		
		private function lastUpdate(e:Event):void
		{
			if (switchLevel)
				levelOver();
		}
		
		private function update(e:Event):void
		{
			movePlayer();
		}
		
		private function movePlayer():void
		{
			var newX:Number = player.x;
			var newY:Number = player.y;
			var playerCol:int;
			var playerRow:int;
			
			if (ArrowKeyInput.left)
			{
				newX -= speed;
				if (!checkCorners(newX, newY))
				{
					playerCol = player.x / TILE_SIZE;
					newX = playerCol * TILE_SIZE;
				}
			}
			if (ArrowKeyInput.right)
			{
				newX += speed;
				if (!checkCorners(newX, newY))
				{
					playerCol = (newX + player.width) / TILE_SIZE;
					newX = (playerCol * TILE_SIZE) - player.width;
				}
			}
			
			checkFalling(newX, newY);
			container.setChildIndex(player, container.numChildren - 1);
		}
		
		private function checkFalling(newX:Number, newY:Number):void
		{
			var playerRow:int;
			
			if (ySpeed == Infinity)
			{
				if (ArrowKeyInput.up)
				{
					ySpeed = jumpSpeed;
				}
				else if (checkCorners(newX, newY))
					ySpeed = 0;
			}
			
			if (ySpeed != Infinity)
			{
				ySpeed += gravity;
				newY += ySpeed;
				if (!checkCorners(newX, newY))
				{
					if (ySpeed >= 0)
					{
						playerRow = (newY + player.width) / TILE_SIZE;
						newY = (playerRow * TILE_SIZE) - player.width;
						ySpeed = Infinity;
					}
					else
					{
						playerRow = player.y / TILE_SIZE;
						newY = playerRow * TILE_SIZE;
						ySpeed = 0;
					}
				}
			}
			
			player.x = newX;
			player.y = newY;
			if (playerIsDead)
				killPlayer();
		}
		
		private function killPlayer():void
		{
			player.x = playerPos[1] * TILE_SIZE;
			player.y = playerPos[0] * TILE_SIZE;
			ySpeed = 0;
			playerIsDead = false;
		}
		
		private function checkCorners(newX:Number, newY:Number):Boolean
		{
			var leftX:int = newX / TILE_SIZE;
			var rightX:int = (newX + player.width - 1) / TILE_SIZE;
			var upY:int = newY / TILE_SIZE;
			var downY:int = (newY + player.height - 1) / TILE_SIZE;
			
			var upLeftTile:Tile = tileMap[upY][leftX];
			var upRightTile:Tile = tileMap[upY][rightX];
			var downLeftTile:Tile = tileMap[downY][leftX];
			var downRightTile:Tile = tileMap[downY][rightX];
			
			if (checkCollision(upLeftTile, upRightTile, downLeftTile, downRightTile))
				return true;
			
			var upLeft:Boolean = upLeftTile.isNotSolid;
			var upRight:Boolean = upRightTile.isNotSolid;
			var downLeft:Boolean = downLeftTile.isNotSolid;
			var downRight:Boolean = downRightTile.isNotSolid;
			
			return upLeft && upRight && downLeft && downRight;
		}
		
		private function checkCollision(upLeftTile:Tile, upRightTile:Tile, downLeftTile:Tile, downRightTile:Tile):Boolean
		{
			if (upLeftTile.isDeadly || upRightTile.isDeadly || downLeftTile.isDeadly || downRightTile.isDeadly)
			{
				playerIsDead = true;
				return true;
			}
			
			if (upLeftTile.isDoor && upRightTile.isDoor && downLeftTile.isDoor && downRightTile.isDoor && ySpeed == Infinity)
			{
				var tmp:DoorTile = upLeftTile as DoorTile;
				if (tmp.isActive)
				{
					switchLevel = true;
					return true;
				}
			}
			
			if (upLeftTile.isCollectible)
			{
				collectStar(upLeftTile);
				return true;
			}
			if (upRightTile.isCollectible)
			{
				collectStar(upRightTile);
				return true;
			}
			if (downLeftTile.isCollectible)
			{
				collectStar(downLeftTile);
				return true;
			}
			if (downRightTile.isCollectible)
			{
				collectStar(downRightTile);
				return true;
			}
			return false;
		}
		
		private function collectStar(starTile:Tile):void
		{
			numStars++;
			exitDoor.isActive = true;
			
			container.removeChild(starTile);
			
			var tmpTile:SkyTile = new SkyTile();
			container.addChild(tmpTile);
			tmpTile.x = starTile.x;
			tmpTile.y = starTile.y;
			tileMap[starTile.y / TILE_SIZE][starTile.x / TILE_SIZE] = tmpTile;
		}
		
		private function levelOver():void
		{
			switchLevel = false;
			if(container.contains(player))	container.removeChild(player);
			removeEventListener(Event.ENTER_FRAME, update);
			removeEventListener(Event.EXIT_FRAME, update);
			
			currentMap++;
			var theMap:String = "map" + currentMap + ".txt";
			
			clearTiles();
			
			/*if ( !loader.mapExists(theMap) )
			{
				winGame();
				return;
			}*/
			
			
			loader.preloadMap( theMap );
			
			loadTime = setInterval(newLevel, 500);
		}
		
		private function newLevel():void 
		{
			if ( loader.error ) {
				winGame();
				return;
			}
			map = cloneArray(loader.grid);
			clearInterval(loadTime);
			buildMap();
			initPlayer();
			addEventListener(Event.ENTER_FRAME, update);
			addEventListener(Event.EXIT_FRAME, lastUpdate);
		}
		
		private function winGame():void
		{
			removeEventListener(Event.ENTER_FRAME, update);
			removeEventListener(Event.EXIT_FRAME, update);
			var winPopup:MovieClip = new WinPopup();
			winPopup.x = stage.stageWidth / 2 - (winPopup.width / 2);
			winPopup.y = stage.stageHeight / 2 - (winPopup.height / 2);
			container.addChild(winPopup);
		}
		
		private function clearTiles():void
		{
			while (tileMap.length > 0)
			{
				while (tileMap[0].length > 0)
				{
					var tmp:Tile = tileMap[0].pop();
					container.removeChild(tmp);
				}
				tileMap.shift();
			}
		}
		
		private function initPlayer():void
		{
			if (!player)
				player = new Player();
			if (container.contains(player))
				container.removeChild(player);
			player.x = playerPos[1] * TILE_SIZE;
			player.y = playerPos[0] * TILE_SIZE;
			
			container.addChild(player);
		}
		
		private function buildMap():void
		{
			tileMap = [];
			
			for (var i:int = 0; i < map.length; i++)
			{
				var row:Array = [];
				
				for (var j:int = 0; j < map[i].length; j++)
				{
					var tileType:int = map[i][j];
					var className:Class = tileArray[tileType];
					var tile:Tile = new className();
					
					if (tileArray[tileType] == DoorTile)
						exitDoor = tile as DoorTile;
					
					container.addChild(tile);
					tile.x = tile.width * j;
					tile.y = tile.height * i;
					row.push(tile);
				}
				tileMap.push(row);
			}
		}
		
		private function initMaps():void
		{

			loader = new MapLoader();
			loader.preloadMap("map1.txt");
			
		}
	
	}

}