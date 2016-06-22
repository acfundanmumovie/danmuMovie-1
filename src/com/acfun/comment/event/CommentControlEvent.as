package com.acfun.comment.event
{
	import flash.events.Event;
	
	public class CommentControlEvent extends Event
	{
		/** 弹幕播放 **/
		public static const COMMENT_PLAYING:String = "commentPlaying";
		/** 弹幕暂停 **/
		public static const COMMENT_STOP:String = "commentStop";
		/** 弹幕到指定位置 **/
		public static const COMMENT_SEEK_POSITION:String = "commentSeekPosition";
		/** 弹幕显示 **/
		public static const COMMENT_SHOW:String = "commentShow";
		/** 弹幕隐藏 **/
		public static const COMMENT_HIDE:String = "commentHide";
		
		
		public var position:Number = 0;
		
		public var state:String = "";
		
		public function CommentControlEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}