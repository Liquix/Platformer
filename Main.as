package  
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Stevie
	 */
	public class Main extends MovieClip 
	{
		
		public function Main() 
		{
			var sample:MovieClip;
			sample = new Game();
			addChild(sample);
			sample.init();
		}
		
	}

}