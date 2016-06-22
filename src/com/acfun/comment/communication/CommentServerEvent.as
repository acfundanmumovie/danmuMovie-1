package com.acfun.comment.communication
{
	import flash.events.Event;
	
	public class CommentServerEvent extends Event
	{
		private var _data:Object;
		public static const ONLINE_NUMBER:String = "online_number";
		public static const ONLINE_LIST:String = "online_list";
		public static const AUTH_DATA:String = "auth_data";
		public static const INSERT_NEW_COMMENT:String = "insert_newcomment";
		public static const PARSE_COMMENT_ERROR:String = "parse_error";
		public static const SEND_ERROR:String = "send_error";
		
		public function CommentServerEvent(type:String,data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_data = data;
			super(type, bubbles, cancelable);
		}
		
		public function get data():Object
		{
			return _data;
		}
	}
}