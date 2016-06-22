package com.acfun.PlayerSkin.component
{
	import com.acfun.External.JavascriptAPI;
	import com.acfun.External.PARAM;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.Utils.BlockLoader;
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	import com.acfun.signal.unregister;
	import com.greensock.TweenLite;
	import com.greensock.plugins.ScrollRectPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	public class AcRecommend extends Sprite
	{
		private const RECOMMEND_API:String = "http://search.acfun.tv/like?id=ac";
		private const X_GAP:int = 27;
		private const Y_GAP:int = 16;
		private const BUTTON_GAP:int = 30;
		
		private var apiData:Object;
		
		private var w:Number;
		private var h:Number;
		private var col:int=3;
		private var picWidth:int=0;
		
		private var content:Sprite;
		private var picArea:Sprite;
		private var buttonArea:Sprite;
		private var good:IconButton;
		private var share:IconButton;
		private var love:IconButton;
		private var loop:IconButton;
		
		public function AcRecommend()
		{
			content = new Sprite();
			
			buttonArea = new Sprite();
			
			//点赞
			good = new IconButton("点赞",new Bitmap(new good_up()),new Bitmap(new good_over()));
			good.y = 0;
			good.addEventListener(MouseEvent.CLICK,onGood);			
			buttonArea.addChild(good);
			
			//分享
			share = new IconButton("分享",new Bitmap(new share_up()),new Bitmap(new share_over()));
			share.y = 50;			
			share.addEventListener(MouseEvent.CLICK,function(event:MouseEvent):void{
				event.stopImmediatePropagation();
				JavascriptAPI.callJS(JavascriptAPI.CALL_SHARE);
			});
			buttonArea.addChild(share);
			
			//收藏
			love = new IconButton("收藏",new Bitmap(new love_up()),new Bitmap(new love_over()));
			love.y = 100;
			love.addEventListener(MouseEvent.CLICK,onLove);			
			buttonArea.addChild(love);
			
			//重播
			loop = new IconButton("重播",new Bitmap(new loop_up()),new Bitmap(new loop_over()));
			loop.y = 150;
//			loop.addEventListener(MouseEvent.CLICK,function():void{
//				hide();
//				notify(SIGNALCONST.SET_PLAYSTATUS_CHANGE,true);
//			});
			buttonArea.addChild(loop);
			
			content.addChild(buttonArea);
			
			addChild(content);
			
			this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK,onSpaceClick);
			
			register(SIGNALCONST.SKIN_SHOW_RECOMMEND,show);			
		}
		
		protected function onSpaceClick(event:MouseEvent):void
		{
			hide();
		}
		
		protected function onGood(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			good.setClicked("已点赞");
			JavascriptAPI.callJS(JavascriptAPI.CALL_UP);
		}
		
		protected function onLove(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			love.setClicked("已收藏");
			JavascriptAPI.callJS(JavascriptAPI.CALL_FAVOR);
		}
		
		public function resize(w:Number,h:Number):void
		{
			this.w = w;
			this.h = h;
			
			this.graphics.clear();
			this.graphics.beginFill(0,0.95);
			this.graphics.drawRect(0,0,w,h);
			this.graphics.endFill();
			
			if (picArea == null) return;
			
			var rect:Rectangle;
			if (w < 650)
			{
				rect = new Rectangle(0,0,picWidth-160,picArea.height);
			}
			else
			{
				rect = new Rectangle(0,0,picWidth,picArea.height);
			}
			picArea.scrollRect = rect;
			buttonArea.x = rect.width + BUTTON_GAP;
			content.x = (w - content.width) / 2;
			content.y = (h - content.height) / 2;
		}
		
		public function show(obj:Object):void
		{
			if (apiData == null)
			{
				loadAPI(function():void{
					show(obj);
				});
			}
			else
			{
				if (apiData.status != 200)
				{
					Log.error("[AcRecommend] API出错,status=" + apiData.status);
					Log.error("[AcRecommend] API出错,message=" + apiData.msg);
				}
				
				if (picArea == null)
				{
					picArea = new Sprite();
					for (var row:int=0;row<3;row++)
					{
						for (var col:int=0;col<3;col++)
						{
							var data:Object;
							try{
								data = apiData.data.page.list[row*3+col];
								data ||= {};
							}catch(ex:Error){
								data = {};
							}
							var href:String = data.contentId ? PARAM.host+"/v/"+data.contentId : PARAM.host + "/random.aspx";
							var item:RecommendItem = new RecommendItem(data.title,data.titleImg,href);					
							item.x = (item.width + X_GAP) * col;
							item.y = (item.height + Y_GAP) * row;					
							picArea.addChild(item);
						}
					}
					picWidth = picArea.width;
					content.addChild(picArea);
				}
				
				if (obj.isUped && obj.isUped.toString() == "1")
				{			
					good.setClicked("已点赞");
				}
				
				if (obj.isFavored && obj.isFavored.toString() == "1")
				{
					love.setClicked("已收藏");
				}
				
				visible = true;	
				resize(w,h);
			}
			register(SIGNALCONST.SKIN_HIDE_RECOMMEND,hide);
		}
		
		public function hide():void
		{
			visible = false;			
			unregister(SIGNALCONST.SKIN_HIDE_RECOMMEND,hide);
		}
		
		private function loadAPI(onComplete:Function=null):void
		{
			var loader:BlockLoader = new BlockLoader(RECOMMEND_API + PARAM.acInfo.contentId);
			loader.addEventListener("httploader_error",function():void{
				apiData = {};
				Log.error("[AcRecommend] API出错,ac="+PARAM.acInfo.contentId);
				if (onComplete!=null) onComplete();
			});
			loader.addEventListener(Event.COMPLETE,function():void{
				try{
					apiData = Util.decode(loader.data);	
				}catch(ex:Error){
					apiData = {};
					Log.error("[AcRecommend] API出错,ac="+PARAM.acInfo.contentId);
				}
				if (onComplete!=null) onComplete();
			});
		}
	}
}


import com.acfun.External.PARAM;
import com.acfun.Utils.Log;
import com.greensock.TweenLite;
import com.greensock.easing.Back;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.PerspectiveProjection;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.JPEGLoaderContext;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

class RecommendItem extends Sprite
{
	private static const PIC_WIDTH:int = 128;
	private static const PIC_HEIGHT:int = 72;
	private static const TEXT_FORMAT:TextFormat = new TextFormat(null,null,0xffffff);
	
	private var title:TextField;
	//128x72
	private var pic:Sprite;
	private var picmask:Sprite;	
	private var href:String;
	
	public function RecommendItem(title:String,url:String,href:String)
	{
		this.href = href || PARAM.host;
		
		pic = new Sprite();
		pic.graphics.lineStyle(4,0x222222);
		pic.graphics.beginFill(0x3b9bd8,0.5);
		pic.graphics.drawRect(0,0,PIC_WIDTH+4,PIC_HEIGHT+4);	//所谓边框（lineStyle），是里外各占一半
		pic.graphics.endFill();
		
		//改为中心注册点
		var container:Sprite = new Sprite();		
		pic.x = -pic.width/2;
		pic.y = -pic.height/2;		
		container.addChild(pic);
		container.x = pic.width/2;
		container.y = pic.height/2;
		var pp:PerspectiveProjection = new PerspectiveProjection();
		pp.projectionCenter = new Point(0,0);
		container.transform.perspectiveProjection = pp;
		addChild(container);
		
		if (url)
		{
			var loader:Loader = new Loader();
			var context:JPEGLoaderContext = new JPEGLoaderContext(1.0);			
			loader.load(new URLRequest(url),context);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void{				
				loader.x = loader.y = 2;
				loader.width = PIC_WIDTH;				
				loader.height = PIC_HEIGHT;
				loader.visible = false;
				pic.addChild(loader);

				//.content面临安全限制，已知新浪、腾讯有限制
//				var bitmap:Bitmap = loader.content as Bitmap;
//				bitmap.smoothing = true;
//				bitmap.width = PIC_WIDTH;
//				bitmap.height = PIC_HEIGHT;
//				bitmap.x = bitmap.y = 2;
//				bitmap.visible = false;
//				pic.addChild(bitmap);
//				loader.unload();
				
				TweenLite.from(container,1,{rotationY:180,ease:Back.easeOut,onUpdate:function():void{ if(container.rotationY<90) loader.visible=true; }});
			});
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function():void{
				Log.info("load error:",url);
			});
		}
		
		this.title = new TextField();
		this.title.width = PIC_WIDTH;
		this.title.height = 20;
		this.title.defaultTextFormat = TEXT_FORMAT;
		this.title.text = title || "暂无相关推荐";
		this.title.y = PIC_HEIGHT + 8;
		addChild(this.title);
		
		picmask = new Sprite();
		picmask.graphics.beginFill(0xffffff,0.1);
		picmask.graphics.drawRect(0,0,PIC_WIDTH,PIC_HEIGHT);
		picmask.graphics.endFill();
		picmask.x = picmask.y = 2;		
		picmask.visible = false;
		addChild(picmask);
		
		var cover:Bitmap = new Bitmap(new RecommendCover(),"auto",true);
		cover.x = (PIC_WIDTH - cover.width) / 2;
		cover.y = (PIC_HEIGHT - cover.height) / 2;
		picmask.addChild(cover);
		
		this.buttonMode = true;
		this.addEventListener(MouseEvent.ROLL_OVER,onOver);
		this.addEventListener(MouseEvent.ROLL_OUT,onOut);
		this.addEventListener(MouseEvent.CLICK,onClick);
	}
	
	protected function onOver(event:MouseEvent):void
	{
		picmask.visible = true;		
	}
	
	protected function onOut(event:MouseEvent):void
	{
		picmask.visible = false;
	}
	
	protected function onClick(event:MouseEvent):void
	{
		event.stopImmediatePropagation();
		navigateToURL(new URLRequest(href),"_blank");
	}
}

class IconButton extends Sprite
{
	private static const BUTTON_WIDTH:int = 100;
	private static const BUTTON_HEIGHT:int = 32;
	
	private var up:DisplayObject;
	private var over:DisplayObject;
	private var buttonTextField:TextField;
	
	public function IconButton(text:String,up:DisplayObject,over:DisplayObject)
	{
		this.up = up;
		this.over = over;
		
		this.graphics.beginFill(0x111111);
		this.graphics.drawRect(0,0,BUTTON_WIDTH,BUTTON_HEIGHT);
		this.graphics.endFill();
		
		up.x = over.x = 18;
		up.y = (BUTTON_HEIGHT - up.height) / 2;
		over.y = (BUTTON_HEIGHT - over.height) / 2;
		up.visible = true;
		over.visible = false;
		addChild(up);
		addChild(over);
		
		buttonTextField = new TextField();
		buttonTextField.mouseEnabled = false;
		buttonTextField.defaultTextFormat = new TextFormat(null,13,0xffffff);
		buttonTextField.autoSize = TextFieldAutoSize.LEFT;
		buttonTextField.text = text;		
		buttonTextField.x = 45;
		buttonTextField.y = up.y;
		addChild(buttonTextField);
		
		this.buttonMode = true;
		this.addEventListener(MouseEvent.ROLL_OVER,onOver);
		this.addEventListener(MouseEvent.ROLL_OUT,onOut);
	}
	
	public function setText(text:String):void
	{
		buttonTextField.text = text;
	}
	
	public function setClicked(text:String):void
	{
		buttonTextField.text = text;
		onOver(null);
		this.removeEventListener(MouseEvent.ROLL_OVER,onOver);
		this.removeEventListener(MouseEvent.ROLL_OUT,onOut);
	}
	
	protected function onOver(event:MouseEvent):void
	{
		up.visible = false;
		over.visible = true;
		transform.colorTransform = new ColorTransform(1,0.5);
	}
	
	protected function onOut(event:MouseEvent):void
	{
		up.visible = true;
		over.visible = false;
		transform.colorTransform = new ColorTransform();
	}
}