package com.acfun.PlayerSkin.Pad
{
	import com.acfun.External.JavascriptAPI;
	import com.adobe.crypto.SHA1;
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	//从播放器内移除分享及其占用的资源
	//public class SharePad extends sharePad
	public class SharePad extends Sprite
	{
		public var title:Sprite = new Sprite();
		
		public static var fold_state:Boolean = true;
		private const WEIGHT:Number = 310
		public var mymask:Shape
		public function SharePad()
		{
			super();
			init();
		}
		private function init():void {
//			mymask = new Shape();
//			mymask.graphics.lineStyle(1, 0x000000);
//			mymask.graphics.beginFill(0x000000); 
//			mymask.graphics.drawRect(0, 0, body.width, body.height);
//			mymask.graphics.endFill();
//			mymask.y = body.y - body.height;
//			
//			sina.buttonMode = true;
//			sina.addEventListener(MouseEvent.CLICK, onClickSina);
//			tx.buttonMode = true;
//			tx.addEventListener(MouseEvent.CLICK, onClickQQ);
//			renren.buttonMode = true;
//			renren.addEventListener(MouseEvent.CLICK, onClickRR);
//			qzone.buttonMode = true;
//			qzone.addEventListener(MouseEvent.CLICK, onClickQZ);
//			sohu.buttonMode = true;
//			sohu.addEventListener(MouseEvent.CLICK, onClickSohu);
//			tianya.buttonMode = true;
//			tianya.addEventListener(MouseEvent.CLICK, onClickTianya);
//			kaixin.buttonMode = true;
//			kaixin.addEventListener(MouseEvent.CLICK, onClickKaixin);
//			share.addEventListener(MouseEvent.CLICK, onClickShare);
		}
		
		protected function onClickShare(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			JavascriptAPI.callJS(JavascriptAPI.SHARE_VIDEO, {type:"shareButton"});
		}
		
		protected function onClickKaixin(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			JavascriptAPI.callJS(JavascriptAPI.SHARE_VIDEO, {type:"Kaixin"});
		}
		
		protected function onClickTianya(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			JavascriptAPI.callJS(JavascriptAPI.SHARE_VIDEO, {type:"Tianya"});
		}
		
		protected function onClickSohu(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			JavascriptAPI.callJS(JavascriptAPI.SHARE_VIDEO, {type:"Sohu"});
		}
		
		protected function onClickQZ(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			JavascriptAPI.callJS(JavascriptAPI.SHARE_VIDEO, {type:"Qzone"});
		}
		
		protected function onClickRR(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			JavascriptAPI.callJS(JavascriptAPI.SHARE_VIDEO, {type:"Renren"});
		}
		
		protected function onClickQQ(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			JavascriptAPI.callJS(JavascriptAPI.SHARE_VIDEO, {type:"QQ"});
		}
		
		protected function onClickSina(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			JavascriptAPI.callJS(JavascriptAPI.SHARE_VIDEO, {type:"Sina"});
		}
		private function foldHandler(e:MouseEvent):void {
			if (fold_state) {
				unfold();
			} else {
				fold();
			}
			fold_state = !fold_state;
		}
		public function fold(... args):void {
//			TweenLite.to(this, 0.5, {y: (y + body.height)});
//			for(var i:Number=0; i<args.length; i++) {
//				TweenLite.to(args[i], 0.5, {y: (args[i].y + body.height)});
//			}
		}
		public function unfold(... args):void {
//			TweenLite.to(this, 0.5, {y: (y - body.height)});
//			for(var i:Number=0; i<args.length; i++) {
//				TweenLite.to(args[i], 0.5, {y: (args[i].y - body.height)});
//			}
		}
	}
}