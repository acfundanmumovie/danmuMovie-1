package com.acfun.Utils
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	//import fl.controls.Button;

	/**
	 * 在线调试输出Log系统 
	 * @author sky
	 * 
	 */
	public class Log
	{
		private static var _s:Sprite;
		
		private static var _tf:TextField;
		
		//日志输出级别，数字越大级别越高，输出信息越多
		private static var _level:int = 0;
		
		private static const LEVEL_STRING:Array = ["[ERROR]","[WARN ]","[DEBUG]","[INFO ]"];
		private static const LEVEL_FORMAT:Array = [new TextFormat(null,null,0xff0000),null,null,null];
		
		public function Log()
		{}
		
		public static function init(main:DisplayObjectContainer,width:Number=500,height:Number=400):void
		{
			_s = new Sprite();			
			_s.graphics.lineStyle(2,0x3a9bd9);
			_s.graphics.beginFill(0x0,0.8);
			_s.graphics.drawRect(0,0,width,height);
			_s.graphics.endFill();
			_s.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void{e.stopPropagation();});
			
			_tf = new TextField();
			_tf.width = width - 2;
			_tf.height = height - 35;
			_tf.x = 1;
			_tf.y = 1;
			_tf.defaultTextFormat = new TextFormat("Courier New",null,0x00ff99);
			_tf.alpha = 1;		
			_tf.appendText("Acfun Logsystem Link Start......\n\n");
			if (ExternalInterface.available)
			{
				//检测了available还是可能发生SecurityError，要捕捉一下
				try
				{
					_tf.appendText("浏览器标识："+ExternalInterface.call("function(){ return navigator.userAgent; }")+"\n");	
				}
				catch(error:Error)
				{
					_tf.appendText("Error: " + error.message);
				}
			}
			_tf.appendText("Flash Player 运行时："+Capabilities.manufacturer+"\n");
			_tf.appendText("Flash Player 版本："+Capabilities.version+"\n");			
			_tf.appendText("Flash Player 是否调试版："+Capabilities.isDebugger+"\n");
			_tf.appendText("操作系统："+Capabilities.os+"\n");
			_tf.appendText("桌面分辨率："+Capabilities.screenResolutionX+"x"+Capabilities.screenResolutionY+"\n");
			_tf.appendText("桌面DPI："+Capabilities.screenDPI+"\n\n");				
			_s.addChild(_tf);
			
			var copyB:Sprite = new Sprite();			
			//copyB.label = "复制";
			copyB.width = 60;
			copyB.x = 10;
			copyB.y = height - 30;
			copyB.addEventListener(MouseEvent.CLICK,function():void{ System.setClipboard(_tf.text);	});
			_s.addChild(copyB);
			
			var closeB:Sprite = new Sprite();			
			//closeB.label = "关闭";
			closeB.width = 60;
			closeB.x = width - 70;
			closeB.y = height - 30;
			closeB.addEventListener(MouseEvent.CLICK,function():void{ toggleShow(false); });
			_s.addChild(closeB);
			
			_s.visible = false;
			_s.x = 2;
			_s.y = 2;
			main.addChild(_s);
		}
		
		public static function toggleShow(isShow:Boolean):void
		{
			if (_s)
			{
				_s.visible = isShow;
			}	
		}
		
		public static function setLevel(level:int):void
		{
			_level = level;
			debug("Log level = ",_level);			
		}
		
		public static function info(...param):void
		{
			append(3,param);				
		}
		
		public static function debug(...param):void
		{
			append(2,param);
		}
		
		public static function warn(...param):void
		{
			append(1,param);			
		}
		
		public static function error(...param):void
		{	
			append(0,param);
		}
		
		public static function getText():String
		{
			return _tf.text;
		}
		
		private static var isConsoleSupported:Boolean = true;
		private static function append(type:int,param:Array):void
		{
			var text:String = Util.covertToTime(getTimer()) + " " + LEVEL_STRING[type] + "  ----  " + param.join(" ") + "\n";
			trace(text);
			if(ExternalInterface.available)
			{
				try
				{
					isConsoleSupported&&ExternalInterface.call("console.log",text);
				}catch(e:Error){
					isConsoleSupported = false;
				}
			}else{
				if (_tf && _level >= type)
				{
					if (_tf.length > 100000)
					{
						_tf.text = "";
						_tf.appendText("too many log > 100000,clear!\n");					
					}
					var start:int = _tf.length;
					_tf.appendText(text);
					var end:int = _tf.length;
					if (LEVEL_FORMAT[type])
						_tf.setTextFormat(LEVEL_FORMAT[type],start,end);				
					_tf.scrollV = _tf.bottomScrollV;
				}
			}
		}
	}
}