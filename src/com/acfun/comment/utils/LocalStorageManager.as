package com.acfun.comment.utils
{
	import flash.net.SharedObject;

	public class LocalStorageManager
	{
		private static const SO_NAME:String = "ACFUN_SETTIINGS";
		public static function setKV(key:String,value:*):void
		{
			try
			{ 
				var so:SharedObject = SharedObject.getLocal(SO_NAME,"/");
				so.data[key] = value;
				so.flush();
				so.close();
			}
			catch(e:Error)
			{
				;
			}
		}
		public static function getValue(key:String):*
		{
			try
			{ 
				var so:SharedObject = SharedObject.getLocal(SO_NAME,"/");
				return so.data[key];
				so.flush();
				so.close();
			}
			catch(e:Error)
			{
				return null;
			}
		}
	}
}