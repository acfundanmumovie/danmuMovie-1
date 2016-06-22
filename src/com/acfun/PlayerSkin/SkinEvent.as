package com.acfun.PlayerSkin
{
	import flash.events.Event;
	import flash.sampler.Sample;
	
	public class SkinEvent extends Event
	{
		public static const PLAY:String = "PALY";
		public static const PAUSE:String = "PAUSE";
		public static const FULL_SCREEN:String = "PALY";
		public static const NORMAL_SCREEN:String = "NORMAL_SCREEN";
		public static const VOLUME_ON:String = "VOLUME_ON";
		public static const VOLUME_OFF:String = "VOLUME_OFF";
		
		public static const SEEK:String = "SEEK";
		public static const VOLUME_CHANGE:String = "VOLUME_CHANGE";
		
		private var _data:Object;
		public function SkinEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
		}
	}
}