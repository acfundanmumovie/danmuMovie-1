package com.acfun.External
{
	import com.acfun.Utils.Util;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * 播放器参数类（从页面传入）  
	 * @author sky
	 * 
	 */
	public class PARAM extends EventDispatcher
	{	
		private static var _vid:String;
		private static var _acInfo:ACInfo;
		private static var _fullscreen:Boolean;
		private static var _logLevel:int;
		private static var _autoplay:Boolean;
		private static var _host:String;
		private static var _userInfo:CommentUserInfo;
		private static var _avatar:String;
		private static var _hint:String;
		private static var _type:String;
		
		public static function get vid():String { return _vid; }
		public static function get acInfo():ACInfo { return _acInfo; }
		public static function get fullscreen():Boolean { return _fullscreen; }	
		public static function get logLevel():int { return _logLevel; }
		public static function get autoplay():Boolean { return _autoplay; }
		public static function get host():String { return _host; }
		public static function get avatar():String { return _avatar; }
		public static function get hint():String { return _hint; }
		public static function get userInfo():CommentUserInfo { return _userInfo; }		
		public static function get type():String { return _type; }
		
		public function PARAM()
		{}
		
		public static function init(param:Object,type:String="acfun"):void
		{
			_type = type;
			_vid = (param && param["vid"]) ? param["vid"]:"2323232";
			_logLevel = (param && param["llevel"]) ? param["llevel"]:4;
			_fullscreen = (param && param["fs"] && int(param["fs"]) == 1) ? true:false;
			_autoplay = (param && param["autoplay"] && int(param["autoplay"]) == 1) ? true:false;
			_host = (param && param["host"]) ? param["host"]:ConstValue.CONFIG_HOST_URL;
			_avatar = (param && param["avatar"]) ? param["avatar"]:Util.zeroPad((1+int(Math.random()*54)),2);
			_avatar = ConstValue.AC_PIC_URL.replace("{num}",_avatar);
			_hint = (param && param["hint"]) ? param["hint"]:"天下漫友是一家( ´∀`)";
			_userInfo = new CommentUserInfo();
			_acInfo = new ACInfo(_vid,_type);	
			
		}
	}
}