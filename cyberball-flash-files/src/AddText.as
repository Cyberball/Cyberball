package  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Omkar
	 */
	public class AddText extends Event 
	{
		public static const ADD:String = "addtextevent";
		public var text:String;
		
		public function AddText(text:String ,bubbles:Boolean=true, cancelable:Boolean=true) 
		{
			super(AddText.ADD, bubbles, cancelable);
			this.text = text;
			trace(this.text);
		}
		
	}

}