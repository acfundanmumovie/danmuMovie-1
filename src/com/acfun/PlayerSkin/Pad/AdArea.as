package com.acfun.PlayerSkin.Pad
{
	import com.acfun.Utils.Util;
	
	import fl.controls.DataGrid;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.JPEGLoaderContext;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	public class AdArea extends Sprite
	{
		//private 
		public var _alphaBG:Boolean = false;
		private var adSprite:Sprite;
		private var currentAd:Array;
		private var closeSprite:Sprite;
		public function AdArea()
		{
			super();			
			//加载广告
			this.visible = false;
			var adUrl:String = 'http://static.acfun.com/json/addata.json?xs=' + new Date().hours;
			var adRequest:URLRequest = new URLRequest(adUrl);
			var adLoader:URLLoader = new URLLoader(adRequest);
			adLoader.addEventListener(Event.COMPLETE,onAdloadSuccess);
			adLoader.addEventListener(IOErrorEvent.IO_ERROR,onAdLoadError);
			adLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onAdLoadError);
			adLoader.load(adRequest);
		}
		
		public function show():void
		{
			this.visible = true;
			setTimeout(closeAd,20000);
		}
		
		private function onAdloadSuccess(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE,onAdloadSuccess);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR,onAdLoadError);
			e.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onAdLoadError);
			var data:String = e.target.data;
			//加载广告
			var adArray:Array = Util.decode(data);
			if(adArray && adArray.length > 0)
			{
				var currentAd:Array = adArray[0];
				if(currentAd[0])
				{
					//loadAd();
					this.currentAd = currentAd;
					loadAd();
				}
			}
		}
		private function loadAd():void
		{
			//
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
			loader.load(new URLRequest(currentAd[0]),new LoaderContext(true));
			//
		}
		private function errorHandler(e:IOErrorEvent):void
		{
			e.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			e.target.removeEventListener(Event.COMPLETE,completeHandler);
		}
		private function completeHandler(e:Event):void
		{
			e.target.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			e.target.removeEventListener(Event.COMPLETE,completeHandler);
			//居中广告
			adSprite = new Sprite();
			adSprite.addChild(e.target.content);
			//居中显示
			/*
			adSprite.x = (this.width - adSprite.width) /2;
			adSprite.y = (this.height - adSprite.height) /2;
			*/			
			adSprite.scrollRect = new Rectangle(0,0,250,200);
			this.addChild(adSprite);
			adSprite.buttonMode = true;
			closeSprite = new Sprite();
			var closeTip:TextField = new TextField();
			closeTip.mouseEnabled = false;
			closeTip.defaultTextFormat = new TextFormat('黑体',12,0xff0000,true);
			closeTip.autoSize = 'left';
			closeTip.type = flash.text.TextFieldType.DYNAMIC;
			closeTip.selectable = false;
			closeTip.text = '关闭广告';
			closeSprite.buttonMode = true;
			closeSprite.mouseChildren = false;

			closeSprite.addEventListener(MouseEvent.CLICK,onCloseBtnClicked);
			closeSprite.addChild(closeTip);
			closeSprite.x = adSprite.x + 250 - closeSprite.width;
			closeSprite.y = adSprite.y - closeSprite.height;
			this.addChild(closeSprite);
			adSprite.addEventListener(MouseEvent.CLICK,onAdClicked);			
			//data = e.target.content;
			//this.dispatchEvent(new Event(Event.COMPLETE));
		}
		private function closeAd():void
		{
			this.visible = false;
//			adSprite.visible = false;
//			closeSprite.visible = false;
		}
		private function onCloseBtnClicked(e:MouseEvent):void
		{
			this.visible = false;
//			adSprite.visible = false;
//			closeSprite.visible = false;
		}
		private function onAdClicked(e:MouseEvent):void
		{
			this.visible = false;
//			adSprite.visible = false;
//			closeSprite.visible = false;
			if(currentAd[1])
			{
				var url:String = currentAd[1];
				navigateToURL(new URLRequest(url),"_blank");
//				$.openWindow(url, "_blank");
			}
		}
		private function onAdLoadError(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE,onAdloadSuccess);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR,onAdLoadError);
			e.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onAdLoadError);
		}
	}
}