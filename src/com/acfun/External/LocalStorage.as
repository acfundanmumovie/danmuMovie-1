package com.acfun.External
{
	import com.acfun.Utils.Log;
	
	import flash.net.SharedObject;

	public class LocalStorage
	{
		public static const PLAYER_VERSION:String = "player_version";
		
		public static const PLAYER_OUT_VERSION:String = "player_out_version";
		
		public static const PLAYER_CONFIG:String = "player_config";
		
		public static const COMMENT_SEND_PARAM:String = "comment_send_param";
		
		public static const COMMENT_SPECIAL_SAVE:String = "comment_special_save";
		
		public static const PLAYER_VOLUME:String = "volume";
		
		/**
		 * 观看时间记录(最近16个)
		 *  {vid:xxx,time:13}
		 */		
		public static const VIDEO_TIME_RECORD:String = "video_time_record";
		
		private static var _so:SharedObject = SharedObject.getLocal("acfunflashplayer","/");
		//设置单独出来，以免被覆盖
		private static var _so_config:SharedObject = SharedObject.getLocal("acfunflashplayer_config","/");
		
		public function LocalStorage()
		{}
		
		private static function getSo(key:String):SharedObject
		{
			switch(key)
			{
				case PLAYER_CONFIG:
				{
					return _so_config;
				}					
				default:
				{
					return _so;
				}
			}
		}
		
		public static function getValue(key:String,defaultValue:* = null):*
		{
			if (getSo(key).data[key] != null)
				return getSo(key).data[key];
			else
				return defaultValue;
		}
		
		public static function setValue(key:String,value:*,flush:Boolean=true):void
		{
			try
			{
				getSo(key).data[key] = value;
				if (flush)
					getSo(key).flush();	//flush会卡一下啊，纠结
			}
			catch(e:Error)
			{
				Log.error("LocalStorage:",e.message);
			}
		}
		
//		public static function flush():void
//		{
//			_so.flush();
//		}
	}
}