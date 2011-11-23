package
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Omkar
	 */
	public class Cartoon extends MovieClip 
	{
		private var _from:int;
		private var to:int;
		
		public function Cartoon() 
		{
			super();
			
		}
		
		public function Throw(throwTo:int):void 
		{
			(parent as Game).mcBall.visible = false;
			to = throwTo;
			if (From!=2) 
			{
				gotoAndPlay(From + "-" + (throwTo!=3?"1":throwTo.toString()));
			}
			else 
			{
				if (throwTo==1) 
				{
					gotoAndPlay("3-1");
				}
				else 
				{
					gotoAndPlay("1-3");
				}
			}
		}
		
		public function get From():int 
		{
			return _from;
		}
		
		public function set From(value:int):void 
		{
			_from = value;
		}
		public function Catch(throwFrom:int = 0 ):void 
		{
			if (throwFrom==0) 
			{
				gotoAndStop("catch-" + From);
			}
			else 
			{
				if (throwFrom==1) 
				{
					gotoAndStop("catch-3");
				}
				else 
				{
					gotoAndStop("catch-1");
				}
			}
			(parent as Game).mcBall.visible = false;
		}
		public function Wait(waitFor:int=0):void 
		{
			if (From==2 && waitFor==0) 
			{
				waitFor = 4 -to;
			}
			gotoAndStop("wait-" + (waitFor==0?From:waitFor));
		}
	}

}