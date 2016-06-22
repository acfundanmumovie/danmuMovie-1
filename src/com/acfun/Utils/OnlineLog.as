package com.acfun.Utils
{
	import com.acfun.External.PARAM;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.sendToURL;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class OnlineLog
	{
		private const LOG_API:String = PARAM.host + "";
		
		/** 主站api时间 **/
		public static const TIME_GET_VIDEO:String = "getvideo";
		/** 解析接口时间 **/
		public static const TIME_JIEXI:String = "jiexi";
		/** 视频缓冲时间 **/
		public static const TIME_BUFFER:String = "bufferFull";
		
		private var dict:Object = {};
		
		public var uid:String;
		public var ac:String;
		public var vtype:String;
		public var getvideo:int;
		public var jiexi:int;
		public var bufferFull:int;
		public var hasError:Boolean;
		public var extend:Array = [];
		
		private static var _instance:OnlineLog;
		
		public function OnlineLog()
		{}
		
		public static function get instance():OnlineLog
		{
			if (_instance == null)
				_instance = new OnlineLog();
			return _instance;
		}
		
		public function send():void
		{
			var request:URLRequest = new URLRequest(LOG_API);
			request.method = URLRequestMethod.POST;
			var data:URLVariables = new URLVariables();
			data["uid"] = uid;
			request.data = data;
			sendToURL(request);
		}
		
		public function detailSend():void
		{
			
		}
		
		public function start(flag:String):void
		{
			dict[flag] = getTimer();
		}
		
		public function end(flag:String):void
		{
			if (dict[flag] != null)
			{
				this[flag] = getTimer() - dict[flag];
				dict[flag] = null;
				delete dict[flag];
			}
		}
	}
}