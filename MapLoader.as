package  
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class MapLoader 
	{
		var grid:Array;
		var error:Boolean;

		public function MapLoader() 
		{
			grid = [];
		}
		
		public function preloadMap(fileName:String):void {
			var file:URLRequest = new URLRequest(fileName);
			var loader:URLLoader = new URLLoader();
			loader.load(file);
			loader.addEventListener(Event.COMPLETE, loadMap);
			loader.addEventListener(IOErrorEvent.IO_ERROR, setError);
		}
		
		private function setError(e:IOErrorEvent):void 
		{
			error = true;
		}
		
		private function loadMap(e:Event):void
		{
			var rowStrings:Array = String(e.target.data).split('\n');
			var rows:Array = [];
			for (var i:int = 0; i < rowStrings.length; i++) 
			{
				var tmpRow:Array = [];
				for (var j:int = 0; j < rowStrings[i].length; j++) 
				{
					if(j % 2 == 0)
						tmpRow.push(parseInt(rowStrings[i].charAt(j)));
				}
				rows.push(tmpRow);
			}
			grid = rows;
		}
	}

}