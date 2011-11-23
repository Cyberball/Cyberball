package
{
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.PBE;
	import ConnectingClip;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import Game;
	import stubs.URL;
	
	/**
	 * ...
	 * @author Omkar
	 */
	public class DocumentClass extends MovieClip implements ITickedObject
	{
		public var txtLog:TextField;
		public var txtChat:TextField;
		public var game:Game;
		public var btnSend:SimpleButton;
		
		private var URLVars:Dictionary;
		private var URLkeys:Vector.<String>;
		private var generateLogFile:Boolean = false;
		private var _userId:String;
		
		private const USERID:String = "userid";
		private const SETTINGS:String = "settings";
		private const PICS:String = "pics";
		private const PIC1:String = "pic1";
		private const PIC3:String = "pic3";
		private const CHAT:String = "chat";
		private const P1NAME:String = "p1name";
		private const P3NAME:String = "p3name";
		
		private const SETTING_3PLOS:String = "3plos";
		private const SETTING_3PLALL:String = "3pall";
		
		private var domain:String;
		private var AppURL:String;
		
		private var settings:Array;
		private var connecting:ConnectingClip;
		private var connectingTime:int;
		public var started:Boolean = false;
		
		public function DocumentClass()
		{
			PBE.startup(this);
			PBE.processManager.addTickedObject(this);
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		function randomBetween(min:Number, max:Number):int
		{
			return min + (max - min + 1) * Math.random();
		}
		private function onAddedToStage(e:Event):void
		{
			AppURL = GetURL();
			connectingTime = randomBetween(5, 7);
			connecting = addChild(new ConnectingClip) as ConnectingClip;
			game.txtTime.text = String(2 * 60);
			setTimeout(Connected, connectingTime * 1000);
			connecting.x = stage.stageWidth / 2;
			connecting.y = stage.stageHeight / 2;
			URLkeys = new Vector.<String>();
			URLkeys.push(USERID);
			URLkeys.push(SETTINGS);
			URLkeys.push(PICS);
			URLkeys.push(PIC1);
			URLkeys.push(PIC3);
			URLkeys.push(CHAT);
			URLkeys.push(P1NAME);
			URLkeys.push(P3NAME);
			
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			URLVars = GetURLVars(AppURL);
			ShowHide();
			btnSend.addEventListener(MouseEvent.CLICK, onChatMessage);
			txtChat.addEventListener(KeyboardEvent.KEY_UP, onKeyPress);
			txtLog.text = "";
			txtLog.htmlText = "";
			//stage.addChild(new Blocker);
		}
		
		private function Connected():void 
		{
			removeChild(connecting);
			stage.dispatchEvent(new GameEvent(1));
			started = true;
		}
		
		private function onKeyPress(e:KeyboardEvent):void
		{
			if (e.keyCode == 13)
				onChatMessage(null);
		}
		
		private function onChatMessage(e:MouseEvent):void
		{
			//txtLog.appendText("<strong>Me:</strong> " + txtChat.text + "\n");
			txtLog.htmlText += "<b>" + game.txtSubjectName.text + ":</b> " + txtChat.text + "<br />";
			Log.Append(UserId, Log.TYPE_CHAT, "\"" + txtChat.text + "\"");
			txtChat.text = "";
			txtLog.scrollV = txtLog.numLines;
		}
		
		private function ShowHide():void
		{
			game.imgPlayerOne.buttonMode = true;
			game.imgPlayerThree.buttonMode = true;
			game.mcPlayerOne.buttonMode = true;
			game.mcPlayerThree.buttonMode = true;
			
			if (String(URLVars[PICS]).toLocaleLowerCase() == "true")
			{
				game.imgPlayerOne.visible = true;
				game.imgPlayerOne.source = URLVars[PIC1];
				
				game.imgPlayerThree.visible = true;
				game.imgPlayerThree.source = URLVars[PIC3];
			}
			else
			{
				game.imgPlayerOne.visible = false;
				game.imgPlayerThree.visible = false;
				
				game.txtPlayerOneName.x = game.mcPlayerOne.x - game.mcPlayerOne.width / 2;
				game.txtPlayerThreeName.x = game.mcPlayerThree.x - game.mcPlayerThree.width / 2;
			}
			trace("Pics: " + (String(URLVars[PICS]).toLocaleLowerCase() == "true"));
			
			if (String(URLVars[CHAT]).toLocaleLowerCase() == "true")
			{
				ShowChatWindow(true);
			}
			else
			{
				ShowChatWindow(false);
			}
			trace("Chatting: " + (String(URLVars[CHAT]).toLocaleLowerCase() == "true"));
			
			generateLogFile = (URLVars[USERID] != null && URLVars[USERID] != "");
			_userId = URLVars[USERID];
			game.txtSubjectName.text = URLVars[USERID];
			game.txtPlayerOneName.text = URLVars[P1NAME];
			game.txtPlayerThreeName.text = URLVars[P3NAME];
			
			trace("Logging: " + generateLogFile);
			
			LoadSettings(String(URLVars[SETTINGS]).toLocaleLowerCase());
			trace("Settings: " + String(URLVars[SETTINGS]).toLocaleLowerCase());
		}
		
		private function ShowChatWindow(b:Boolean = true):void
		{
			txtChat.visible = b;
			txtLog.visible = b;
			btnSend.visible = b;
			//scrollBar.visible = b;
		}
		
		private function LoadSettings(settings:String = ""):void
		{
			var settingsFileURL:String = "";
			
			switch (String(URLVars[SETTINGS]).toLocaleLowerCase())
			{
				case SETTING_3PLALL: 
					settingsFileURL = "3pl - all include.txt";
					break;
				case SETTING_3PLOS: 
					settingsFileURL = "3pl - ostracize subject.txt";
					break;
				default: 
					settingsFileURL = "3pl - all include.txt";
					break;
			}
			
			var req:URLRequest = new URLRequest("settings/" + settingsFileURL);
			req.method = "GET";
			var urll:URLLoader = new URLLoader(req);
			urll.addEventListener(Event.COMPLETE, onSettingsLoaded);
			urll.load(req);
			//Test();
		}
		
	
		private function onSettingsLoaded(e:Event):void
		{
			settings = String((e.currentTarget as URLLoader).data).split("\n");
			//txtLog.appendText("\n" + settings.length);
			trace(settings);
			for (var i:int = 0; i < settings.length; i++)
			{
				var sett:String = settings[i];
				if (sett.indexOf("total throws") >= 0)
				{
					game.TotalThrows = int(sett.split(",")[1]);
					trace("throws - " + game.TotalThrows);
				}
				if (sett.indexOf("game speed") >= 0)
				{
					game.Speed = new Vector.<int>();
					game.Speed.push(int(sett.split(",")[1]));
					game.Speed.push(int(sett.split(",")[2]));
					trace("Speed - " + game.Speed);
				}
				if (sett.indexOf("players") >= 0)
				{
					game.NumberOfPlayers = int(sett.split(",")[1]);
					trace("NUM - " + game.NumberOfPlayers);
				}
				if (sett.indexOf("name1") >= 0)
				{
					var name1:String = trim(sett.split(",")[1]);
					if (name1 != "none")
					{
						//game.txtPlayerOneName.text = name1;
						//game.txtPlayerOneName.text = "Player 3";
					}
				}
				if (sett.indexOf("name2") >= 0)
				{
					var name2:String = trim(sett.split(",")[1]);
					if (name2 != "none")
					{
						game.txtSubjectName.text = name2;
					}
				}
				game.txtSubjectName.text = "You"; //TODO: As requested by mc0920
				if (sett.indexOf("name3") >= 0)
				{
					var name3:String = trim(sett.split(",")[1]);
					if (name3 != "none")
					{
						//game.txtPlayerThreeName.text = name3;
						//game.txtPlayerThreeName.text = "Player 7";
					}
				}
				if (sett.indexOf("schedule") >= 0)
				{
					var scheduleFileName:String = trim(sett.split(",")[1]);
					trace("SCHED --" + scheduleFileName);
					var req:URLRequest = new URLRequest("schedules/" + scheduleFileName);
					req.method = "GET";
					var urll:URLLoader = new URLLoader(req);
					urll.addEventListener(Event.COMPLETE, onScheduleLoaded);
					urll.load(req);
				}
			}
		}
		
		private function onScheduleLoaded(e:Event):void
		{
			var schedules:Array = String((e.currentTarget as URLLoader).data).split("\n");
			for (var i:int = 0; i < schedules.length; i++)
			{
				var schedule:String = schedules[i];
				if (schedule.indexOf("1,") == 0)
				{
					game.PlayerOneMoves = schedule.split(",").reverse();
					game.PlayerOneMoves.pop();
					game.PlayerOneMoves = game.PlayerOneMoves.reverse();
						//txtLog.text = "P1M - " + game.PlayerOneMoves;
				}
				if (schedule.indexOf("3,") == 0)
				{
					game.PlayerThreeMoves = schedule.split(",").reverse();
					game.PlayerThreeMoves.pop();
					game.PlayerThreeMoves = game.PlayerThreeMoves.reverse();
						//txtLog.appendText("\n" + "P3M - " + game.PlayerThreeMoves);
				}
			}
			trace((e.currentTarget as URLLoader).data);
			//stage.dispatchEvent(new GameEvent(1));
		}
		
		private function GetDomain(Url:String):String
		{
			var url:String = Url.substring(Url.indexOf("://") + 3);
			return url.substring(0, url.indexOf("/"));
			return url;
		}
		
		private function GetURL():String
		{
			try
			{
				var URL:String = ExternalInterface.call('function () { return window.location.href; }');
				if (URL == null || URL == "")
				{
					//gotoAndStop("enableJavascript");
					return "";
				}
			}
			catch (err:Error)
			{
				//gotoAndStop("enableJavascript");
			}
			return URL;
		}
		
		private function GetURLVars(Url:String):Dictionary
		{
			var queryString:String = unescape(Url.substring(Url.indexOf("?") + 1));
			var array:Array = queryString.split("&");
			var vars:Dictionary = new Dictionary();
			
			for (var i:int = 0; i < array.length; i++)
			{
				var keyValue:String = array[i];
				var key:String = keyValue.split("=")[0];
				if (URLkeys.indexOf(key) >= 0)
				{
					var value:String = keyValue.split("=")[1];
					vars[key] = value;
				}
				else
				{
					trace("Ignoring invalid key : " + key);
				}
			}
			return vars;
		}
		
		public function SaveLog():void
		{
			if (generateLogFile)
			{
				var variables:URLVariables = new URLVariables();
				variables.userId = UserId;
				variables.log = Log.LogFile;
				
				var varSend:URLRequest = new URLRequest("saveLog.php");
				var varLoader:URLLoader = new URLLoader(varSend);
				varSend.method = URLRequestMethod.POST;
				varSend.data = variables;
				varLoader.load(varSend);
			}
			gotoAndStop("ThankYou");
		}
		
		public function onTick(deltaTime:Number):void
		{
			//Logger.print(this, deltaTime.toString());
			//txtLog.scrollV = txtLog.numLines;
			//scrollBar.update();
		}
		
		function trim(s:String):String
		{
			return s.replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");
		}
		
		public function get UserId():String
		{
			return _userId;
		}
	}
}