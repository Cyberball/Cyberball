package
{
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.PBE;
	import fl.containers.UILoader;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import Cartoon;
	
	/**
	 * ...
	 * @author Omkar
	 */
	public class Game extends MovieClip implements ITickedObject
	{
		public var imgPlayerThree:UILoader;
		public var imgPlayerOne:UILoader;
		public var mcPlayerOne:Cartoon;
		public var mcPlayerThree:Cartoon;
		public var mcPlayerTwo:Cartoon;
		
		public var txtPlayerOneName:TextField;
		public var txtSubjectName:TextField;
		public var txtPlayerThreeName:TextField;
		
		private var totalThrows:int;
		private var numberOfPlayers:int;
		private var speed:Vector.<int>;
		
		private var whosTurn:int;
		private var throwsMade:int;
		
		public var mcBall:MovieClip;
		
		private var playerOneMoves:Array;
		private var playerThreeMoves:Array;
		private var doc:DocumentClass;
		public var txtTime:TextField;
		private var currTimeOut:uint;
		
		public function Game()
		{
			this.whosTurn = 1;
			this.throwsMade = 0;
			mcBall.gotoAndStop("1-3");
			PBE.processManager.addTickedObject(this);
			stage.addEventListener(GameEvent.TURN_BEGINS, onTurnBegins);
			mcPlayerThree.gotoAndStop(2);
			mcPlayerTwo.gotoAndStop(5);
			AddClickListeners();
			mcPlayerOne.From = 1;
			mcPlayerTwo.From = 2;
			mcPlayerThree.From = 3;
			mcPlayerOne.gotoAndStop(1);
			mcPlayerThree.gotoAndStop("wait-3");
			mcPlayerTwo.gotoAndStop("wait-3");
			mcBall.visible = false;
			doc = parent as DocumentClass;
		}
		private function AddClickListeners():void 
		{
			txtPlayerOneName.addEventListener(MouseEvent.CLICK, onPlayerOneClicked);
			txtPlayerThreeName.addEventListener(MouseEvent.CLICK, onPlayerThreeClicked);
			imgPlayerOne.addEventListener(MouseEvent.CLICK, onPlayerOneClicked);
			imgPlayerThree.addEventListener(MouseEvent.CLICK, onPlayerThreeClicked);
			imgPlayerOne.buttonMode = true;
			imgPlayerThree.buttonMode = true;
			mcPlayerOne.addEventListener(MouseEvent.CLICK, onPlayerOneClicked);
			mcPlayerThree.addEventListener(MouseEvent.CLICK, onPlayerThreeClicked);
			mcPlayerOne.buttonMode = true;
			mcPlayerTwo.buttonMode = true;
		}
		
		private function RemoveClickListeners():void 
		{
			txtPlayerOneName.removeEventListener(MouseEvent.CLICK, onPlayerOneClicked);
			txtPlayerThreeName.removeEventListener(MouseEvent.CLICK, onPlayerThreeClicked);
			imgPlayerOne.removeEventListener(MouseEvent.CLICK, onPlayerOneClicked);
			imgPlayerThree.removeEventListener(MouseEvent.CLICK, onPlayerThreeClicked);
			imgPlayerOne.buttonMode = false;
			imgPlayerThree.buttonMode = false;
			mcPlayerOne.removeEventListener(MouseEvent.CLICK, onPlayerOneClicked);
			mcPlayerThree.removeEventListener(MouseEvent.CLICK, onPlayerThreeClicked);
			mcPlayerOne.buttonMode = false;
			mcPlayerTwo.buttonMode = false;
		}
		private function ThrowTo(playerNumber:int):void
		{
			if (throwsMade < totalThrows)
			{
				if (playerNumber == 2)
				{
					Log.Append((doc).UserId, Log.TYPE_CATCH, "player" + whosTurn);
				}
				RemoveClickListeners();
				trace("Throw To - " + playerNumber);
				++throwsMade;
				switch (whosTurn) 
				{
					case 1:
						mcPlayerOne.Throw(playerNumber);
					break;
					case 2:
						mcPlayerTwo.Throw(playerNumber);
					break;
					case 3:
						mcPlayerThree.Throw(playerNumber);
					break;
				}
			}
			else
			{
				trace("Over");
				(doc).SaveLog();
			}
		}
		
		private function onPlayerThreeClicked(e:MouseEvent):void
		{
			if (whosTurn == 2)
			{
				Log.Append((doc).UserId, Log.TYPE_THROW, "player3");
				ThrowTo(3);
			}
		}
		
		private function onPlayerOneClicked(e:MouseEvent):void
		{
			if (whosTurn == 2)
			{
				Log.Append((doc).UserId, Log.TYPE_THROW, "player1");
				ThrowTo(1);
			}
		}
		
		private function SendChat(msg:String):void
		{
			var doc:DocumentClass = doc;
			doc.txtLog.htmlText += "<b>" + txtPlayerOneName.text + ":</b> " + msg + "<br />";
			doc.txtLog.scrollV = doc.txtLog.numLines;
		}
		
		private function onTurnBegins(e:GameEvent):void
		{
			var throwFrom:int = whosTurn;
			whosTurn = e.whosTurn;
			
			if (throwsMade == 0)
			{
				var rand:int = randomBetween(3, 5) * 1000;
				setTimeout(SendChat, rand, "Hey!");
			}
			if (whosTurn == 2)
			{
				if (throwsMade < totalThrows)
				{
					mcPlayerTwo.Catch(throwFrom);
					AddClickListeners();
				}
				else
				{
					(doc).SaveLog();
					(doc).gotoAndStop("ThankYou");
				}
			}
			else
			{
				if (throwsMade < totalThrows)
				{
					var lnth:int = 0;
					var randm:int = 0;
					var throwToNum:int = 0;
					
					if (whosTurn == 1)
					{
						mcPlayerOne.Catch();
						mcPlayerTwo.Wait(3);
						lnth = String(PlayerOneMoves[0]).length;
						randm = randomBetween(0, lnth - 1);
						throwToNum = int(String(PlayerOneMoves[0]).charAt(randm));
						PlayerOneMoves[0] = String(PlayerOneMoves[0]).replace(String(PlayerOneMoves[0]).charAt(randm), "");
						if (String(PlayerOneMoves[0]).length == 0)
						{
							PlayerOneMoves.shift();
						}
					}
					else if (whosTurn == 3)
					{
						mcPlayerThree.Catch();
						mcPlayerTwo.Wait(1);
						lnth = String(PlayerThreeMoves[0]).length;
						randm = randomBetween(0, lnth - 1);
						throwToNum = int(String(PlayerThreeMoves[0]).charAt(randm));
						PlayerThreeMoves[0] = String(PlayerThreeMoves[0]).replace(String(PlayerThreeMoves[0]).charAt(randm), "");
						if (String(PlayerThreeMoves[0]).length == 0)
						{
							PlayerThreeMoves.shift();
						}
					}
					
					//var time:Number = (randomBetween(0, this.Speed[0]) + randomBetween(0, this.Speed[1])) * 1000;
					var time:Number = randomBetween(0,4) * 1000;
					trace("in Here - " + time);
					//(doc).txtLog.scrollV = (doc).txtLog.scrollV+=10;
					//(doc).txtLog.appendText("\n"+time.toString());
					currTimeOut = setTimeout(ThrowTo, time, throwToNum);
				}
				else
				{
					(doc).SaveLog();
					(doc).gotoAndStop("ThankYou");
				}
				
			}
		}
		
		/* INTERFACE com.pblabs.engine.core.ITickedObject */
		public function onTick(deltaTime:Number):void
		{
			if (doc.started && txtTime&& doc.currentFrameLabel!="ThankYou") 
			{
				var remainingTime:Number = Number(txtTime.text);
				txtTime.text = String(remainingTime - deltaTime);
				txtTime.visible = false;
				if (remainingTime<=0) 
				{
					clearTimeout(currTimeOut);
					(doc).SaveLog();
					(doc).gotoAndStop("ThankYou");
				}
			}
		}
		
		public function get TotalThrows():int
		{
			return totalThrows;
		}
		
		public function set TotalThrows(value:int):void
		{
			totalThrows = value;
		}
		
		public function get NumberOfPlayers():int
		{
			return numberOfPlayers;
		}
		
		public function set NumberOfPlayers(value:int):void
		{
			numberOfPlayers = value;
		}
		
		public function get Speed():Vector.<int>
		{
			return speed;
		}
		
		public function set Speed(value:Vector.<int>):void
		{
			speed = value;
		}
		
		public function get PlayerOneMoves():Array
		{
			return playerOneMoves;
		}
		
		public function set PlayerOneMoves(value:Array):void
		{
			playerOneMoves = value;
		}
		
		public function get PlayerThreeMoves():Array
		{
			return playerThreeMoves;
		}
		
		public function set PlayerThreeMoves(value:Array):void
		{
			playerThreeMoves = value;
		}
		
		function randomBetween(min:Number, max:Number):int
		{
			return min + (max - min + 1) * Math.random();
		}
	}

}