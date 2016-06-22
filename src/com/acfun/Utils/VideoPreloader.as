package com.acfun.Utils
{
	import com.acfun.External.ConstValue;
	import com.acfun.External.PARAM;
	import com.acfun.PlayerSkin.LoadingBar;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.system.JPEGLoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/**
	 * 进度条到达100% 
	 */	
	[Event(name="complete", type="flash.events.Event")]
	
	public class VideoPreloader extends Sprite
	{
		private var _splash:Loading;
		private var _tip:TextField;
//		private var _tipAnimate:TweenMax;
		
		private var _progress:Number = 0;
		
		private var _lastFrameTime:int;
		private var _thisFrameTime:int;
		private var _deltaTime:int;
		
		private var _timer:Timer;
		private var _fakeTime:int;
		
		/**
		 * loading 样式 0为原始ac娘，1为炸弹 
		 */		
		private var loadingType:uint = 0;
		/**
		 * ac娘loading样式常量 
		 */		
		private const LOADING_AC:uint = 0;
		/**
		 * 炸弹loading样式常量 
		 */		
		private const LOADING_BOMB:uint = 1;
		/**
		 * 出炸弹样式的几率 
		 */		
		private const RATIO:Number = 0//0.2;
		
		private const BOMB_WHITE_URL:String = "bomb.swf";
		private const BOMB_BLACK_URL:String = "circleBomb.swf";

		private var loadingBar:LoadingBar;
		
		
		public function VideoPreloader()
		{
			super();
			
			/*graphics.beginFill(0xffffff,0);
			graphics.drawRect(0,0,4096,2160);
			graphics.endFill();
			opaqueBackground = 0;*/
			
			_splash = new Loading();
			addChild(_splash);
			
			_timer = new Timer(20);
			_timer.addEventListener(TimerEvent.TIMER,onTimer);
			_timer.start();
			_fakeTime = int(Math.random() * 20 + 10); 
			
			var tf:TextFormat = new TextFormat("微软雅黑",14,0xdddddd,true);
			tf.align = TextFormatAlign.CENTER;
			_tip = new TextField();
			_tip.defaultTextFormat = tf;
			_tip.autoSize = TextFieldAutoSize.CENTER;
			_tip.text = PARAM.hint;
			_tip.filters = [new GlowFilter(0xffffff,0.2,2,2)];
			addChild(_tip);
			
			//文字信息变化效果
//			_tipAnimate = TweenMax.to(_tip,0.7,{alpha:0.8,repeat:-1,yoyo:true});
			if(Math.random() < RATIO)
			{
				loadBombPreBar();
				return;	
			}
			//读取ac娘头像
			var loader:Loader = new Loader();			
			var context:JPEGLoaderContext = new JPEGLoaderContext(1.0,true);
			loader.load(new URLRequest(PARAM.avatar),context);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void{
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,arguments.callee);
				
				var pic:Bitmap = loader.content as Bitmap;
				pic.smoothing = true;				
				pic.x = 13;
				pic.y = 12;
				pic.width = 100;
				pic.height = 78;
				_splash.pic.addChild(pic);
				loader.unload();
				loader = null;
			});
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function():void{
				Log.info("读取ac娘头像失败！",PARAM.avatar);
				loader.unload();
				loader = null;
			});
			
			_lastFrameTime = getTimer();
		}
		
		private var _bombURL:String;
		/**
		 * 加载炸弹进度条 
		 */		
		private function loadBombPreBar():void
		{
			loadingType = LOADING_BOMB;
			//this.removeChild(this._splash);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onProgressBarReady);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioHandler);
			const URL:String = ConstValue.AC_BOMB_FOLDER + ((Math.random()>.5)?BOMB_WHITE_URL:BOMB_BLACK_URL);
			_bombURL = URL;
			//trace("加载炸弹进度条",_bombURL);
			loader.load(new URLRequest(URL));
		}
		
		protected function ioHandler(event:IOErrorEvent):void
		{
			Log.error("加载炸弹进度条失败",_bombURL);
			var info:LoaderInfo = event.currentTarget as LoaderInfo;
			info&&clearBombListeners(info);
		}
		
		protected function onProgressBarReady(event:Event):void
		{
			//trace("load sucess!");
			var info:LoaderInfo = event.currentTarget as LoaderInfo;
			info&&clearBombListeners(info);
			var loadUI:DisplayObject = event.target.content as DisplayObject;
			
			if(loadUI)
			{
				loadingBar = new LoadingBar(info.width,info.height);
				loadingBar.skin = loadUI as MovieClip;
				var min:Number = Math.max(120/info.width,92/info.height);
				loadingBar.scaleX = loadingBar.scaleY = min;
				loadingBar.x = -10;
				loadingBar.y = -10;
				loadingBar.opaqueBackground = 0xff0000;
				_splash.pic.addChild(loadingBar);
			}
		}
		
		private function clearBombListeners(lis:LoaderInfo):void
		{
			lis.removeEventListener(Event.COMPLETE,onProgressBarReady);
			lis.removeEventListener(IOErrorEvent.IO_ERROR,ioHandler);
		}
		
		public function resize(w:Number,h:Number):void
		{
			_splash.x = w/2;
			_splash.y = h/2 - 20;
			_tip.x = (w - _tip.textWidth)/2;
			_tip.y = _splash.y + 75;
		}
		
		public function setProgress(value:Number):void
		{
			value = Math.round(value * 100);
			if (value < 0) value = 0;
			if (value > _progress)
				_progress = value > 100 ? 100 : value;
			
			if(loadingBar&&this.loadingType == LOADING_BOMB)
				loadingBar.progress = _progress;
		}
		
		protected function onTimer(event:TimerEvent):void
		{
			if (_progress < _fakeTime)
				_progress += _timer.delay / 50;
			
			_thisFrameTime = getTimer();				
			_deltaTime = (_thisFrameTime - _lastFrameTime);
			_lastFrameTime = _thisFrameTime;
			
			var n:int = Math.round(_deltaTime / 20);
			var newFrame:int = _splash.progress.currentFrame + n;
			if (newFrame > _progress || _progress >= 100)
				_splash.progress.gotoAndStop(Math.round(_progress));
			else
				_splash.progress.gotoAndStop(newFrame);
			
			//文字透明度随动画变化			
			_tip.alpha = (0.8 + (_splash.animate.getChildAt(0).scaleX - 0.624)/0.125*0.8);
			
			if (_splash.progress.currentFrame >= 100)
			{
				_timer.reset();
				_timer.removeEventListener(TimerEvent.TIMER,onTimer);
				setTimeout(function():void{
					dispatchEvent(new Event(Event.COMPLETE));
				},200);
			}
		}
	}
}