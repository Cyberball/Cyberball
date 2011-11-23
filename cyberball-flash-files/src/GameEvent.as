package  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Omkar
	 */
	public class GameEvent extends Event 
	{
		public static const TURN_BEGINS:String = "turnbegins"
		
		public var whosTurn:int;
		
		public function GameEvent(whosTurn:int, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(GameEvent.TURN_BEGINS, bubbles, cancelable);
			this.whosTurn = whosTurn;
		}
	}
}