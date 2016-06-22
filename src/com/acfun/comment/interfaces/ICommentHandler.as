package com.acfun.comment.interfaces
{
	import com.acfun.comment.entity.SingleCommentData;

	public interface ICommentHandler
	{
		function init(commentId:String,vlength:int,isLive:Boolean = false):void;
//		function reset(commentId:String = '0',vlength:int = 500,userId:String = null,userCheckString:String = null,isLive:Boolean = false):void;
		function send(comment:SingleCommentData):void;
		function directSend(comments:Vector.<SingleCommentData>=null):void;
		function remove(comments:Array):void;
		function lock(comments:Array):void;
		function close():void;
		function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
	}
}