package com.acfun.comment.control.manager
{
	import com.acfun.comment.control.space.ScrollCommentSpaceManager;
	import com.acfun.comment.control.space.base.CommentSpaceManager;
	import com.acfun.comment.display.RGifComment;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.interfaces.IComment;
	
	import flash.display.Sprite;
	
	public class RScrollGifManager extends RScrollCommentManager
	{
		public function RScrollGifManager(clip:Sprite)
		{
			super(clip);
		}
		
		/**
		 * 设置空间管理者
		 **/
		override protected function setSpaceManager():void
		{
			this.space_manager = CommentSpaceManager(new ScrollCommentSpaceManager());
			return;
		}
		
		/**
		 * 获取弹幕对象
		 * @param	data 弹幕数据
		 * @return 弹幕呈现方法对象
		 */
		override public function getComment(data:SingleCommentData):IComment
		{
			return new RGifComment(data);
		}
	}
}