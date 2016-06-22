package com.acfun.comment.skin
{
	import com.acfun.External.ConstValue;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.signal.notify;
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	public class CommentSpecial extends Sprite
	{
		private var _pad:CommentExPad;
		
		private var _commentClip:SCommentClip;
		
		public function CommentSpecial(viewArea:Sprite,getPTime:Function,swidth:Number,sheight:Number)
		{	
			_pad = new CommentExPad(this);			
			_pad.viewArea = viewArea;
			_pad.getPTime = getPTime;
			_pad.display.y = sheight;
//			_pad.display["body"].height = sheight - ConstValue.PLAYER_VIDEO_DEFAULT_HEIGHT;
			
			_commentClip = new SCommentClip(this);
			_commentClip.width++;
			_commentClip.x = swidth;			
			_commentClip.setHeight(ConstValue.SPECIAL_MODE_PLAYER_HEIGHT + _pad.display["body"].height-1);
			_commentClip.addEventListener(MouseEvent.MOUSE_DOWN,stopEvent);
			_commentClip.addEventListener(MouseEvent.CLICK,stopEvent);
		}
		
		protected function stopEvent(event:Event):void
		{
			event.stopImmediatePropagation();
		}
		
		public function addToList(s:SingleCommentData):void
		{
			_commentClip.insertCmtList(s);
		}
		
		public function saveComments():void
		{
			_commentClip.saveComment();
		}
		
		public function modify(s:SingleCommentData):void
		{
			_pad.fixcmt(s,_commentClip.onfixrecall);
		}
		
		public function showData(s:SingleCommentData):void
		{
			_pad.commentObjectRead(s);
		}
		
		public function dispose():void
		{
			hide();
			setTimeout(function():void{				
				notify(SIGNALCONST.SPECIAL_COMMENT_EXPAND,false);
			},1000);
		}
		
		public function show():void
		{
			_pad.display.alpha = 0;			
			addChild(_pad.display);
			TweenLite.to(_pad.display,1,{y:ConstValue.SPECIAL_MODE_PLAYER_HEIGHT,width:ConstValue.SPECIAL_MODE_PLAYER_WIDTH + 1,alpha:1,ease:Cubic.easeIn});
			
			_commentClip.alpha = 0;
			_commentClip.init();
			addChild(_commentClip);
			TweenLite.to(_commentClip,1,{x:ConstValue.SPECIAL_MODE_PLAYER_WIDTH,alpha:1,ease:Cubic.easeIn});
		}
		
		public function hide():void
		{
			TweenLite.to(_pad.display,1,{y:stage.stageHeight,alpha:0,ease:Cubic.easeIn});
			TweenLite.to(_commentClip,1,{x:stage.stageWidth,alpha:0,ease:Cubic.easeIn});
		}
		
		public function openpic():void
		{
			_pad.openadv(true);
		}
		
		public function openurl():void
		{
			_pad.openurl();
		}
		
		public function biu():void
		{
			_pad.biu();
		}
	}
}