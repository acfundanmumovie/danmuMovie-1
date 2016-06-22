package com.acfun.comment.interfaces
{
	import com.acfun.comment.entity.SingleCommentData;

	public interface IComment
	{
		function start(from:Number=0):void;
		function pause():void;
		function resume():void;
		function doComplete():void;
		function completeHandler():void;
		function set complete(foo:Function):void;
		function get innerText():String;
		function get user():String;
		function get item():SingleCommentData;		
	}
}