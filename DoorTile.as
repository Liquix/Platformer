package  
{
	public class DoorTile extends Tile 
	{
		public var isActive:Boolean = false;
		
		public function DoorTile() 
		{
			isNotSolid = true;
			isDoor = true;
		}
		
	}

}