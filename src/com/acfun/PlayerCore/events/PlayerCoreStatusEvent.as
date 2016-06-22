package com.acfun.PlayerCore.events
{
	import flash.events.Event;
	
	public class PlayerCoreStatusEvent extends Event
	{
		/**状态字符串,注册监听器用**/
		public static const LISTEN_TYPE:String = "PLAYERCORE_STATUS"
		
		/**播放器播放结束 **/
		public static const PLAYERCORE_MEDIA_END:String = "end";
		/**缓冲时间 **/
		public static const PLAYERCORE_MEDIA_BUFFERTIMER:String = "buffertimer";
		/**播放器时间 **/
		public static const PLAYERCORE_MEDIA_TIMER:String = "timer";
		/** 播放器初始化完毕 **/
		public static const PLAYERCORE_STATUS_INIT:String = "init";
		/** 播放器正在缓冲 **/
		public static const PLAYERCORE_STATUS_BUFFERING:String = "buffering";
		/** 播放器缓冲完成 **/
		public static const PLAYERCORE_STATUS_BUFFER_END:String = "buffer_end";
		/** 播放器出错 **/
		public static const PLAYERCORE_STATUS_ERROR:String = "error";
		/**
		 * 未知播放状态 
		 */		
		public static const PLAYERCORE_UNKNOWN_STATUS:String = "playerCoreUnknownStatus";
		
		/** 状态  **/
		public var status:String;
		
		
		/** 携带数据 **/
		public var data:Object;
		
		public function PlayerCoreStatusEvent(type:String,status:String,data:Object=null,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.status = status;
			this.data = data;
			super(type, bubbles, cancelable);
		}
	}
}