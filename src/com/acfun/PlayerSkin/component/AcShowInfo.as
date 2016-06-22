package com.acfun.PlayerSkin.component
{
	import com.acfun.External.AcConfig;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.signal.register;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.plugins.AutoAlphaPlugin;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class AcShowInfo extends Sprite
	{
		public static const INFO_HEIGHT:Number = 28;
		
		private var info:TextField;
		private var close:CloseButton;
		
		//回调函数集合
		private var callbacks:Object = {};
		
		public function AcShowInfo()
		{
			var tf:TextFormat = new TextFormat(AcConfig.getInstance().comment_font_name,13,0xffffff);
			info = new TextField();
			info.defaultTextFormat = tf;
			info.autoSize = TextFieldAutoSize.LEFT;
			info.y = 3;
			info.addEventListener(TextEvent.LINK,onTextLink);
			addChild(info);
			
			close = new CloseButton();
			close.y = 6;
			close.addEventListener(MouseEvent.CLICK,onClose);
			addChild(close);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN,stopEvent);
			this.addEventListener(MouseEvent.CLICK,stopEvent);
			
			register(SIGNALCONST.SKIN_SHOW_INFO,show);
		}
		
		protected function onTextLink(event:TextEvent):void
		{
			var text:String = event.text;
			if (callbacks[text])
			{
				callbacks[text]();
			}
		}
		
		protected function stopEvent(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
		}
		
		protected function onClose(event:MouseEvent):void
		{
			TweenMax.to(this,0.5,{autoAlpha:0});
		}
		
		public function resize(w:Number,h:Number):void
		{
			graphics.clear();
			graphics.beginFill(0x3A9BD9,0.5);			
			graphics.drawRect(0,0,w,INFO_HEIGHT);
			graphics.endFill();
			
			close.x = w - 25;
		}
		
		private var _seed:uint;
		public function show(infoString:String,callback:Object = null,duration:int = 10000):void
		{
			clearTimeout(_seed);
			
			info.htmlText = infoString;
			
			for (var key:String in callback)
			{
				callbacks[key] = callback[key];
			}
			
			TweenMax.to(this,0.5,{autoAlpha:1});
			
			if (duration > 0)
			{
				_seed = setTimeout(onClose,duration,null);
			}
		}
	}
}