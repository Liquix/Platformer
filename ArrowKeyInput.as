package  
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	public class ArrowKeyInput 
	{
		static var left:Boolean, right:Boolean , up:Boolean, down:Boolean;
		
		public static function init(stage:Stage):void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKey);
			stage.addEventListener(KeyboardEvent.KEY_UP, handleKey);
		}
		
		static private function handleKey(e:KeyboardEvent):void 
		{
			var type:String = e.type;
			var key:int = e.keyCode;
			var value:Boolean;
			
			if (type == KeyboardEvent.KEY_DOWN)
				value = true;
			else
				value = false;
				
			if (key == Keyboard.LEFT)	left = value;
			if (key == Keyboard.RIGHT)	right = value;
			if (key == Keyboard.UP)		up = value;
			if (key == Keyboard.DOWN)	down = value;
		}
	}

}