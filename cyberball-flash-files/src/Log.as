package  
{
	/**
	 * ...
	 * @author Omkar
	 */
	public class Log 
	{
		public static const TYPE_CHAT:String = "chat";
		public static const TYPE_THROW:String = "throw";
		public static const TYPE_CATCH:String = "catch";
		
		private static var _log:String = "userid,timestamp,behavior type,v1,v2\r\n";
		
		public function Log() 
		{
			
		}
		
		static public function get LogFile():String 
		{
			return _log;
		}
		
		static public function Append(userId:String,type:String,value:String):void 
		{
			if (type==TYPE_CHAT) 
			{
				_log += userId + "," + (new Date()) +"," + type + "," + value + "\r\n";
			}
			else 
			{
				_log += userId + "," + (new Date()) +"," + type + "(" +value + ")" + "\r\n";
			}
			trace(_log);
		}
		
	}

}