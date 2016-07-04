package com.acfun
{
	import com.acfun.External.ConstValue;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.PlayerCore.events.PlayerCoreStatusEvent;
	import com.acfun.PlayerCore.newcore.DayinVideo;
	import com.acfun.Utils.Log;
	import com.acfun.comment.CommentPlugin;
	import com.acfun.comment.communication.CommentHandler;
	import com.acfun.comment.control.CommentTime;
	import com.acfun.comment.control.manager.base.CommentManager;
	import com.acfun.comment.control.space.base.CommentSpaceManager;
	import com.acfun.comment.display.RGifComment;
	import com.acfun.comment.entity.CommentConfig;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.interfaces.ICommentPlugin;
	import com.acfun.comment.utils.CommentUtils;
	import com.acfun.net.PtoP;
	import com.acfun.net.analysis.AnalysisUtil;
	import com.acfun.net.analysis.errors.ACError;
	import com.acfun.net.analysis.errors.ErrorType;
	import com.acfun.signal.register;
	import com.acfun.test.CommentBox;
	import com.acfun.test.LocalFileLoader;
	import com.greensock.TweenMax;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	
	//[SWF(width="800",height="600",frameRate="24",backgroundColor="#000000")]
//	[SWF(width="800",height="600",frameRate="24",backgroundColor="#5DD452")]
//	[SWF(width="800",height="600",frameRate="24")]
	/*com.acfun.comment.entity.CommentConfig //修改speed速度
	com.acfun.comment.communication.CommentHandler //修改conn弹幕服务器ip
	com.acfun.comment.communication.CommentHandler //修改webSocket,其中handleWebSocketMessage()方法接收服务器消息
	com.acfun.comment.display.RGifComment //修改弹幕表情地址
	com.acfun.comment.display.RGifComment //修改弹幕表情缩放（在加载完成方法中）
	com.acfun.comment.display.RGifComment 中//get height()//修改弹幕表情高度
	com.acfun.comment.display.base.SimpleCommentEngine中 textLine //修改弹幕文字及文字属性
	com.acfun.comment.display.base.SimpleCommentEngine中 useBitmap = true; bmp.scaleX //缩放弹幕文字
	com.acfun.comment.display.RGifComment中 start()控制gif表情移动
	com.acfun.comment.display.ScrollComment中start()控制弹幕文字移动
	*/  
	//com.acfun.comment.control.space.base.CommentSpaceManager中transformY()方法修改弹幕显示Y坐标
	//com.acfun.comment.entity.CommentConfig //设置弹幕字体,字体加粗等
	//com.acfun.comment.display.base.Comment //构造函数中 text 设置字体首尾显示顺序
	//打印log：
		//com.acfun.Utils.Log中_s.visible=true打开显示log
		//com.acfun.comment.control.manager.base.CommentManager中start()添加和移除弹幕,设置内置弹幕和用户弹幕
		//com.acfun.comment.control.manager.base.CommentManager 中mm.z设置弹幕3D感
		//本类中：Log.setLevel(10);
	///////////////air修改
	//com.acfun.comment.CommentPlugin中和DanmuMovie中注销了flash.system.Security.allowDomain("*");和//flash.system.Security.allowInsecureDomain("*");
	//com.adobe.utils.StringUtil中rtrim()方法下添加if(input && input !="")
	
	//rtmfp://p2p.rtmfp.net/7143ea177792d3f6b95f0006-3b233c02b7da/    //p2p服务器地址
	//https://github.com/theturtle32/AS3WebSocket  webSocket文档  
	public class DanmuMovie extends Sprite
	{
		private static const VERSION:String = "DanmuMovie beta 1.0.4";
		
		private var _playerLayer:Sprite = new Sprite();
		private var _commentLayer:Sprite = new Sprite();
		private var _logPlayer:Sprite = new Sprite();
		private var _player:DayinVideo;
		private var _comment:ICommentPlugin;
		//private var _videoArea:Rectangle;
		private var currentIndex:int = 0;
		
		private var widthPercent:Number = 1;
		private var heightPercent:Number = 1;
		public static var maxSize:int = 50;
		private var baseWidth:int = 0;
		private var baseHeight:int = 0;
		
		private var cursorPoints:Vector.<Number> = new <Number>[0,8, 16,8, 16,0, 24,12, 16,24, 16,16, 0,16, 0,8];
		private var cursorDrawCommands:Vector.<int> = new <int>[1,2,2,2,2,2,2,2];
		////////////////
		private var _drowBg:Sprite;
		private var _playLocalVideo:Boolean =false;//是否播放本地视频,false为播放网络视频
		private var _localVideoUrl:Array = [];//本地视频播发列表
		//////////////
		private var _lianMengCount:uint = 0;
		private var _buLuoCount:uint = 0;
		private var _baseBarX:Number = 0;
		private var _dmAbs:int = 100;//双方弹幕差值上限
		private var _openCamera:Boolean = false;//是否启动本地摄像头
		private var _livePlayer:Boolean = false;//是否开启直播播放器
		private var _liveServer:String = null;//直播服务器
		private var _liveStream:String = null;//直播流 
		private var _flightText:TextField;//发光字
		private var _interClearOut:uint;
		
		//后台:http://dm.aixifan.com/admin
        //账号 密码 :admin、acfundanmuyingyuan
		//H5页面:http://dm.aixifan.com/sendDM

		//播放页添加几个参数，可以即时控制播放器属性：

		//http://cj.acfun.tv/play/[数字]?show=l&expressionScale=0.8&maxSize=50&speed1=0.5&speed2=1
		//说明：
		//show：弹幕从左或从右出现，可选值：l或r，默认l
		//expressionScale：表情缩放比例，数字型，0.8表示图片缩放为原来的80%
		//maxSize：字体大小，数字型，默认50
		//speede：弹幕移动速度，0.5表示默认速度的50%
		//speed1=0.3 普通弹幕移动速度
		//speed2=0.3 测试弹幕移动速度
		//offY=50 弹幕显示位置偏移
		//textOrder 文字是否反转
		//showInDanMu 是否显示内置弹幕//内置弹幕有屏幕最多显示弹幕条数限制
		//http://help.adobe.com/zh_CN/FlashPlatform/reference/actionscript/3/package-summary.html //在线文档
		
		public function DanmuMovie()
		{
			stage.nativeWindow.activate();//至于最上一级;
			//stage.nativeWindow.alwaysInFront =true;
			//stage.nativeWindow.title="弹幕影院";
			//stage.nativeWindow.maximize();//全屏
			//flash.system.Security.allowDomain("*");
			//flash.system.Security.allowInsecureDomain("*");
			//var testSprite:Sprite = new Sprite()
			//TweenLite.to(testSprite,0.1,{alpha:0,delay:2,onComplete:function(){trace("showStart")}});
			
			msBox.visible = false;
			addEventListener(Event.ENTER_FRAME,onStage);
			//resetEage()
			var mouseCursor:MouseCursorData = new MouseCursorData();
			mouseCursor.data = makeCursorImages();
			Mouse.registerCursor("spinningArrow",mouseCursor);
			Mouse.cursor = "spinningArrow";
			TweenMax.to(this,0,{});
		}
		
		/*private function resetEage(boxScaleX:Number=.5):void
		{
			msBox.jdLine.bar.x =_baseBarX;
			msBox.jdLine.jdRed.scaleX =boxScaleX;
			msBox.jdLine.bar.x = msBox.jdLine.jdRed.width - msBox.jdLine.bar.width;
			if(msBox.jdLine.bar.x<=0)msBox.jdLine.bar.x=0;
		}*/
		
		
		private function makeCursorImages():Vector.<BitmapData>
		{
			var cursorData:Vector.<BitmapData> = new Vector.<BitmapData>();
			
			var cursorShape:Shape = new Shape();
			cursorShape.graphics.beginFill( 0xff5555, 0 );
			cursorShape.graphics.lineStyle( 1 );
			cursorShape.graphics.drawPath( cursorDrawCommands, cursorPoints );
			cursorShape.graphics.endFill();
			var transformer:Matrix = new Matrix();
			
			//Rotate and draw the arrow shape to a BitmapData object for each of 8 frames 
			for( var i:int = 0; i < 8; i++ )
			{
				var cursorFrame:BitmapData = new BitmapData( 32, 32, true, 0 );
				cursorFrame.draw( cursorShape, transformer );
				cursorData.push( cursorFrame );
				
				transformer.translate(-15,-15);
				transformer.rotate( 0.785398163 );
				transformer.translate(15,15);
			}
			return cursorData;
		}
		
		private function click(e:MouseEvent):void{
			//trace(e.type)
			videoScreen();
		}

		public function get isFullscreen():Boolean
		{
			return stage.displayState == StageDisplayState.FULL_SCREEN || stage.displayState == "fullScreenInteractive";			
		}
		
		/*public function get videoArea():Rectangle
		{	
			return new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
		}*/
		
		private function onStage(event:Event):void
		{
			if (stage && stage.stageWidth > 0)
			{
				//trace("--A")
				trace("--screenResolutionX:"+flash.system.Capabilities.screenResolutionX+";screenResolutionY:"+flash.system.Capabilities.screenResolutionY);//用户设备的水平分辨率
				
				stage.addEventListener(Event.RESIZE,onResize);
				removeEventListener(Event.ENTER_FRAME,onStage);
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				stage.stageFocusRect = false;
				stage.frameRate = 24;
				
				videoScreen();//全屏
			}
			
			//getPcId();
			/////////////////////////
			var _URLld:URLLoader=new URLLoader();
			_URLld.load(new URLRequest("vars.txt"));
			_URLld.addEventListener(Event.COMPLETE,urlLdComplete);
			_URLld.addEventListener(IOErrorEvent.IO_ERROR,jsonIO_ERROR);
			_URLld.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			//////////////////////////
		
		}
		
		private function ptopMessageHandle(e:Event):void
		{
			trace("messageType:"+e.type+";state:"+e.currentTarget._viewState+";"+e.currentTarget._getOrderScreen)
			if(e.currentTarget._getOrderScreen =="all" || e.currentTarget._getOrderScreen == ConstValue.SCREEN){
				var getViewState:int = e.currentTarget._viewState;//获取p2p操控显示
				setView(getViewState)
			}
		}
		
		private function getPcId():void 
		{
			var pcId:SharedObject = SharedObject.getLocal("dmMoviePcId","/");//不给第二个参数则存储为随机位置，给"/"则为固定路径

			if ( pcId.data.userPcId ) {
				trace("pcId.data.userPcId:"+pcId.data.userPcId)
			} else {
				trace("pcId.data.userPcId:"+null)
				var userPcId:String = Math.random()+"&"+ Math.random();
				pcId.data.userPcId = userPcId;
				pcId.flush( );
			}
		}
		
		private function doDrawRect(getBgColor:uint=0x000000):Sprite 
		{
            var child:Sprite = new Sprite();
            child.graphics.beginFill(getBgColor);
            //child.graphics.lineStyle(_borderSize, _borderColor);
            child.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            child.graphics.endFill();
            //addChild(child);
			return child;
        }
		
		////////////////////////////
		private function setWindow(getShow:String="l",getMaxSize:Number=50,getExpressionScale:Number=0.8,getSpeed1:Number=0.7,getSpeed2:Number=0.9,getOffY:Number=0,getScreen:Number=1,getBgColor:uint=0x000000,getBgVisible:Boolean=false,getTextOrder:Boolean=false,getInDanMu:Boolean=false,getTopShow:Boolean=false,getLocalGif:Boolean=true,getAddBgJpg:Boolean=false,getBgJpgUrl:String=null,getZ:Number=0,getRectWidth:Number=0,getRectHeight:Number=0,getMyJson:Boolean=false):void
		{
			//trace("getBgColor:"+getBgColor)
			if(getBgVisible)
			{
				//trace("--addBg")
				_drowBg = doDrawRect(getBgColor)
				this.addChild(_drowBg);
				this.setChildIndex(_drowBg,0);
			}
			/////////////////
			//var param:Object =stage.loaderInfo.parameters;
			//var param:Object ="?show="+getShow+"&expressionScale="+getExpressionScale+"&maxSize="+getMaxSize+"&speed1="+getSpeed1+"&speed2="+getSpeed2;
				/*if(param && param.hasOwnProperty("widthPercent")){
					this.widthPercent = param.widthPercent;
				}
				if(param && param.hasOwnProperty("heightPercent")){
					this.heightPercent = param.heightPercent;
				}*/
				
			//trace("--CommentConfig.instance.speede:"+CommentConfig.instance.speede+";CommentConfig.instance.speede2:"+CommentConfig.instance.speede2)
			if(getMyJson){//SINGALDANMUZ  getZ
					ConstValue.SCREEN = getScreen;
					
					ConstValue.SINGALDANMU_Z = getZ;
				
					ConstValue.MAX_SIZE = getMaxSize;
				
					ConstValue.DIRECT = getShow;
				
					ConstValue.EMTION_SCALE = getExpressionScale;
				
					ConstValue._getTextOrder = getTextOrder;
				
					ConstValue.RECT_WIDTH = getRectWidth;
					
					ConstValue.RECT_HEIGHT = getRectHeight;
				
					CommentConfig.instance.speede = getSpeed1;
				
					CommentConfig.instance.speede2 = getSpeed2;
				
					_commentLayer.y = getOffY;
				
					CommentManager._inDanMu = getInDanMu;//是否显示预制弹幕
				
					RGifComment.LOCAL_GIF = getLocalGif;
					
					CommentSpaceManager.topShow = getTopShow;
					
					////////////////////
					if(getAddBgJpg){
						logoMiddle.visible = false;
						LocalFileLoader.instance.browseFileSystem(getBgJpgUrl,stage.stageWidth,stage.stageHeight);
						this.addChild(LocalFileLoader.instance._loader)
						LocalFileLoader.instance.addEventListener(LocalFileLoader.ERROR,loadBgError);
					}
			}
				//trace("_commentLayer.y:"+_commentLayer.y)
				//_commentLayer.rotationY = 30
				ConstValue.STAGE = stage;
				
				
				reg();
				
				addChild(_playerLayer);
				addChild(_commentLayer);
				CommentBox._dmBox = _commentLayer;//添加测试新版弹幕RichTextField
				trace("--this.numChildren:"+this.numChildren)
				//_commentLayer.y=120;
				//addChild(_logPlayer);
				
				//Log.init(_logPlayer);
				//Log.setLevel(10);
				//Log.info("页面参数：",Util.encode(param));
				
				//socket connect...
				_comment = new CommentPlugin();
				_comment.init("0",10000,false);
				_comment.add2stage(_commentLayer,0,0,false);
			
				this._playerLayer.mouseEnabled = false;
				this._playerLayer.mouseChildren = false;
				//stage.doubleClickEnabled = true;
				//stage.addEventListener(MouseEvent.DOUBLE_CLICK,click);
				stage.addEventListener(MouseEvent.CLICK,click);
				Mouse.hide();
				
				//////////////////////
				var _ptop:PtoP =new PtoP()
				_ptop.addEventListener(PtoP.MESSAGE,ptopMessageHandle)
					
				CommentHandler._onSignal.add(onSignalHandler);
				//onSignalHandler("")
				//////////////////////
				onResize();	
				
				var timer1:Timer = new Timer(1500);
				timer1.addEventListener(TimerEvent.TIMER,time2);
				//timer1.start();
				
				var my_cm:ContextMenu = new ContextMenu();
				my_cm.hideBuiltInItems();
				var menuItem_cmi:ContextMenuItem = new ContextMenuItem(VERSION,false);
				my_cm.customItems =[];

				this.setChildIndex(msBox,this.numChildren-1);
				
		}
		
		///////////////
		private function onSignalHandler(info:String):void
		{
			//trace("--info:"+info)
		
			//if(info=='LIANMENG'){
			//	_lianMengCount ++;
			//	msBox.txt1.text = _lianMengCount+"攻击"
			//}
			//if(info=='BULUO'){
			//	_buLuoCount++;
			//	msBox.txt2.text = _buLuoCount+"攻击"
			//}
			//
			//var currentAbs:int = _lianMengCount - _buLuoCount;//双方弹幕实时差值
			//var redLineScaleX:Number = 0.5+ (_lianMengCount - _buLuoCount)/_dmAbs *.5;//0.01为分为100份
			//if(redLineScaleX>=1)redLineScaleX=1;
			//if(redLineScaleX<=0)redLineScaleX=0;
			//resetEage(redLineScaleX);
			//if(currentAbs>=_dmAbs)
			//{
			//	//trace("联盟获胜")//boxMc
			//	msBox.msMiddleBox.boxMc.buluoPhoto.visible = false;
			//	msBox.msMiddleBox.boxMc.lianmengPhoto.visible = true;
			//	resetEage()
			//	msBox.msMiddleBox.play();
			//	dmReset0()
			//}
			//if(currentAbs<=_dmAbs * -1)
			//{
			//	//trace("部落获胜")
			//	msBox.msMiddleBox.boxMc.buluoPhoto.visible = true;
			//	msBox.msMiddleBox.boxMc.lianmengPhoto.visible = false;
			//	resetEage();
			//	msBox.msMiddleBox.play();
			//	dmReset0()
			//}
			///////////////////////
			
			if(info=='FLIGHTTEXT')
			{
				//if(CommentHandler.instance._flightTxtOrder ==0)//开
				//{
					if(_interClearOut){
						clearTimeout(_interClearOut)
					}
					//trace("__CommentHandler.instance._flighTxtColor:"+CommentHandler.instance._flighTxtColor)
					_flightText = FlightTxt(CommentHandler.instance._flighTxtColor,CommentHandler.instance._flighTxtStr);
					if(ggTxt.ligntBox.numChildren >0) ggTxt.ligntBox.removeChildAt(0) 
					ggTxt.ligntBox.addChild(_flightText)
					ggTxt.gotoAndStop(25)
					resetFlightBox()
					ggTxt.gotoAndPlay(1)
					ggTxt.visible =true;
					_interClearOut =setTimeout(endFlightTxt, 8000);
				//}
				//else if(CommentHandler.instance._flightTxtOrder ==1)//关
				//{
					//ggTxt.visible =false;
					//ggTxt.stop()
				//}
			}
		}
		
		private function endFlightTxt():void
		{
			//trace("__endFlightTxt")
			ggTxt.visible =false;
			ggTxt.stop()
			//clearTimeout(_interClearOut)
		}
		//
		//private function dmReset0():void
		//{
		//	_lianMengCount = 0;
		//	_buLuoCount =0;
		//	msBox.txt1.text = _lianMengCount+"攻击"
		//	msBox.txt2.text = _buLuoCount+"攻击"
		//}
		
		
		////////////////
		private function loadBgError(e:Event):void
		{
			logoMiddle.visible = true;
		}
		
		//////////////
		 private function urlLdComplete(e:Event):void
		{
			var getJson = JSON.parse(URLLoader(e.target).data);
			var show_:String = "l";//弹幕进入方向
			var expressionScale_:Number = 0.8;//表情缩放
			var maxSize_:Number = 50;//字体大小
			//var speede_:Number = 0.5;
			var speed1_:Number = 0.7;//普通弹幕速度
			var speed2_:Number = 0.9;//测试弹幕速度
			var offY_:Number = 0;//弹幕显示区域Y坐标
			var screen_:Number =0;//屏幕ID
			var bgColor_:uint = 0x000000;//背景颜色
			var bgVisible_:Boolean =true;//背景是否透明
			var textOrder_:Boolean =false;//字体是否反转显示
			var showInDanMu_:Boolean = false;//是否显示预制弹幕
			var topShow_:Boolean = false;//是否顶部先显示弹幕
			var localGif_:Boolean = true;//是否使用内置表情包
			var addBgJpg_:Boolean = false;//是否添加背景图片
			var bgJpgUrl_:String = null;//背景图片url
			var setZ_:Number = 0;//设置单条弹幕Z坐标
			var addRectWidth_:Number = 0;//增加弹幕显示区域宽度
			var addRectHeight_:Number = 0;//增加弹幕显示区域高度
			//playScreen是否是游戏屏,游戏屏只显示表情，不飘弹幕，慎用
			//valueAbs  双方点赞数的最大差值
			
			if(getJson.playScreen !=null) ConstValue.PLAY_SCREEN = getJson.playScreen;
			
			if(getJson.show !=null)
			{
				show_ = getJson.show;
			}
			
			if(getJson.expressionScale !=null)
			{
				expressionScale_ = getJson.expressionScale;
			}
			
			if(getJson.maxSize !=null)
			{
				maxSize_ =getJson.maxSize;
			}
			
			if(getJson.screen !=null)
			{
				screen_ = getJson.screen;
			}
			
			if(getJson.speed1 !=null)
			{
				speed1_ = getJson.speed1;
			}
			
			if(getJson.speed2 !=null)
			{
				speed2_ = getJson.speed2;
			}
			
			if(getJson.offY !=null)
			{
				offY_ = getJson.offY;
			}
			
			if(getJson.bgColor !=null)
			{
				bgColor_ = getJson.bgColor;
			}
			
			if(getJson.bgVisible !=null)
			{
				bgVisible_ = getJson.bgVisible;
			}
			
			if(getJson.textOrder !=null)
			{
				textOrder_ = getJson.textOrder;
			}
			
			if(getJson.showInDanMu !=null)
			{
				showInDanMu_ = getJson.showInDanMu;
			}
			
			////////////
			if(getJson.localVideo !=null)
			{
				_playLocalVideo = getJson.localVideo;
			}
			
			if(getJson.localVideoUrl !=null)
			{
				_localVideoUrl = getJson.localVideoUrl;
			}//topShow_
			
			if(getJson.topShow !=null)
			{
				topShow_ = getJson.topShow;
			}
			
			if(getJson.localGif !=null)
			{
				localGif_ = getJson.localGif;
			}
			
			if(getJson.addBgJpg !=null)
			{
				addBgJpg_ = getJson.addBgJpg;
			}
			
			if(getJson.bgJpgUrl !=null)
			{
				bgJpgUrl_ = getJson.bgJpgUrl; 
			}
			
			if(getJson.setZ !=null)
			{
				setZ_ = getJson.setZ; 
			}
			
			if(getJson.addRectWidth !=null)
			{
				addRectWidth_ = getJson.addRectWidth; 
			}
			
			if(getJson.addRectHeight !=null)
			{
				addRectHeight_ = getJson.addRectHeight; 
			}
			if(getJson.valueAbs !=null) _dmAbs =getJson.valueAbs;
			
			if(getJson.camera !=null) _openCamera = getJson.camera; //_livePlayer _liveServer _liveStream
			
			if(getJson.livePlayer !=null) _livePlayer = getJson.livePlayer; 
			if(getJson.liveServer !=null) _liveServer = getJson.liveServer;
			if(getJson.liveStream !=null) _liveStream = getJson.liveStream;
			////////////
			
			setWindow(show_,maxSize_,expressionScale_,speed1_,speed2_,offY_,screen_,bgColor_,bgVisible_,textOrder_,showInDanMu_,topShow_,localGif_,addBgJpg_,bgJpgUrl_,setZ_,addRectWidth_,addRectHeight_,true)
			trace("loadJson Complete:"+show_);
			
		}
		
		private function jsonIO_ERROR(e:IOErrorEvent):void
		{
			trace("加载json数据error:"+e.type);
			setWindow()
		}
		
		private function errorHandler(e:SecurityErrorEvent):void
		{
			trace("json数据安全域error:"+e.type);
			setWindow()
		}
		////////////////////////////
		private var i:Number = 0;
		private function time2(e:TimerEvent):void{
			///////////测试文字弹幕
			/*var dat:Object = {"msg":i.toString()};
			var cmtData:SingleCommentData = CommentUtils.createNewComment2(dat,false);
			CommentTime.instance.start(cmtData);
			i++;*/
			//////////////////////测试gif表情弹幕
			
			var obj:Object = {"msg":"2.gif"};
			var cmtData:SingleCommentData = CommentUtils.createNewComment2(obj,false);
			CommentTime.instance.start1(cmtData);
		}
		
		public function isShowComment(bool:Boolean):void{
			this._commentLayer.visible = bool;
		}
		
		public function isShowVideo(bool:Boolean):void{
			this._player.isShow(bool);
		}
		
		private function socketInit():void{
			_player = new DayinVideo();
			_player["addEventListener"]("PLAYERCORE_STATUS",onPlayStatus);	
			_playerLayer.addChild(_player as DisplayObject);
			/////////////////是否启动本地摄像头
			if(_openCamera){
				_player.locolVideo(stage.stageWidth,stage.stageHeight)
				return;
			}
			
			////////////////播放直播
			if(_livePlayer && _liveServer!=null && _liveStream!=null)
			{
				_player.livePlay(_liveServer,_liveStream)
				return;
			}
			
			////////////////播本地视频还是网络视频
			playLoaclVideos();
			////////////////
			
		}
		
		private function playLoaclVideos():void
		{
			_player._playLocalVideo = _playLocalVideo;
			if(_playLocalVideo)//播放本地视频
			{
				if(_localVideoUrl.length>0){
					_player._localVideos = _localVideoUrl;
					_player.start();	
				}
			}
			else//播放网络视频
			{
				_player.start(CommentHandler.instance.source.toString());
			}
		}
		
		public function changeView():void{
			//Log.info("改变状态：",CommentHandler.instance.player_status);
			//trace("---status:"+CommentHandler.instance.player_status)
			
			var currentViewId:uint = CommentHandler.instance.player_status;
			setView(currentViewId)
		}
		
		public function setView(viewId:uint=1):void//
		{
			if(viewId == 0){//关闭
				_commentLayer.visible = false;//弹幕层
				_playerLayer.visible = false;//播放器
				logoMiddle.visible = true;//背景层
				if(_player){
					_player.isShow(false);
				}
			}else if(viewId == 1){//显示视频和弹幕
				_commentLayer.visible = true;
				_playerLayer.visible = true;
				logoMiddle.visible = false;
				if(_player){
					_player.isShow(true);
				}
			}else if(viewId == 2){//显示弹幕
				_commentLayer.visible = true;
				_playerLayer.visible = false;
				logoMiddle.visible = true;
				if(_player){
					_player.isShow(false);
				}
			}else if(viewId == 3){//显示摄像头和弹幕
				_commentLayer.visible = true;
				_playerLayer.visible = true;
				logoMiddle.visible = false;
				if(_player){
					_player.isShow(true);
					_player.locolVideo(stage.stageWidth,stage.stageHeight)
				}
			}else if(viewId == 4){//显示直播和弹幕
				_commentLayer.visible = true;
				_playerLayer.visible = true;
				logoMiddle.visible = false;
				if(_player){
					_player.isShow(true);
					if(_liveServer!=null && _liveStream!=null)
					{
						_player.livePlay(_liveServer,_liveStream)
					}
				}
			}else if(viewId == 5){//显示点播和弹幕
				playLoaclVideos();
				_commentLayer.visible = true;
				_playerLayer.visible = true;
				logoMiddle.visible = false;
				if(_player){
					_player.isShow(true);
					//playLoaclVideos();
				}
			}
		}
		
		private function onPlayStatus(event:PlayerCoreStatusEvent):void
		{	
			switch(event.status)				
			{
				case PlayerCoreStatusEvent.PLAYERCORE_STATUS_INIT:
					_player.playing = true;
					onResize();	
					changeView();
					break;
				case PlayerCoreStatusEvent.PLAYERCORE_STATUS_BUFFERING:
					//正在缓冲
					break;
				case PlayerCoreStatusEvent.PLAYERCORE_STATUS_BUFFER_END:
					//缓冲完成
					break;
				case PlayerCoreStatusEvent.PLAYERCORE_MEDIA_TIMER:
					//循环调用
							
					break;
				case PlayerCoreStatusEvent.PLAYERCORE_MEDIA_END:
					//播放完成
					
					
					
					//					onResize();
					
					break;
				case PlayerCoreStatusEvent.PLAYERCORE_STATUS_ERROR:
					//出错	
					Log.error("播放器出错：",event.data);				
					
					AnalysisUtil.send(ACError.create({info:"乐视播放器内部错误反馈"},ErrorType.LETV_PLAYSTATUS_ERROR));
					break;
				case PlayerCoreStatusEvent.PLAYERCORE_UNKNOWN_STATUS:
					Log.warn("乐视返回未处理消息：",event.status,event.data);
					break;
				default:
					Log.error("无法识别的播放器事件类型：",event.status,event.data);
					break;
			}
		}
		
		private function reg():void
		{
			register(SIGNALCONST.VIDEO_PAUSE,videoPause);
			register(SIGNALCONST.CHANGE_VIEW,changeView);
			register(SIGNALCONST.SOCKET_INIT,socketInit);
			register(SIGNALCONST.CHANGE_LOGO,changeLogo);
			register(SIGNALCONST.SEND_COMMENT,sendComment);
			register(SIGNALCONST.SEND_GIF,sendGif);
		}
		
		private function sendComment(data:SingleCommentData):void{
			CommentHandler.instance.sendNextComment(data);
		}
		
		private function sendGif(data:SingleCommentData):void{
			CommentHandler.instance.sendNextGif(data);
		}
		
		private function changeLogo():void{
			onResize();
		}
		
		private function videoPause():void{
			_player.playing = CommentHandler.instance.pauseState;
		}
		
		private function videoScreen():void{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			Mouse.hide();
		}
		
		private function onResize(e:Event=null):void
		{	
			//trace("--Resize")//ConstValue.RECT_WIDTH
			//var width:int = videoArea.width;
			//var height:int = videoArea.height;
			 var dmRectWidth:int = stage.stageWidth +ConstValue.RECT_WIDTH;
			 var dmRectHeight:int = stage.stageHeight +ConstValue.RECT_HEIGHT;
			//trace("--ConstValue.RECT_WIDTH:"+ConstValue.RECT_WIDTH)
			
			if(_drowBg){
				_drowBg.width = stage.stageWidth;
				_drowBg.height = stage.stageHeight;
			}
			
			if(LocalFileLoader.instance._loader){
				LocalFileLoader.instance.setLoaderY(stage.stageWidth,stage.stageHeight)
			}
			////////
			logoTop.x = logoTop.y=50;
			logoDown.x = stage.stageWidth - 50;
			logoDown.y = stage.stageHeight - logoDown.height -50;
			logoMiddle.x= stage.stageWidth *.5;
			logoMiddle.y = stage.stageHeight *.5;
			//logoMiddle.y = stage.stageHeight -logoMiddle.height *.5;
			logoMiddle.height = stage.stageHeight *.8;
			logoMiddle.scaleX = logoMiddle.scaleY;
			if(logoMiddle.width >stage.stageWidth)
			{
				//trace("--SetWidth")
				logoMiddle.width =stage.stageWidth *.8;
				logoMiddle.scaleY = logoMiddle.scaleX;
			}
			//logoMiddle.width =stage.stageWidth;
			//logoMiddle.scaleY = logoMiddle.scaleX;
			
			//logoMiddle.height =stage.stageHeight;
			//logoMiddle.scaleX = logoMiddle.scaleY;
			////////
			msBox.width = stage.stageWidth;
			msBox.scaleY = msBox.scaleX 
			msBox.x=0;
			msBox.y = stage.stageHeight- msBox.height;
			////////
			CommentManager._getStageHeight = dmRectHeight;
			//////////////
			if (_player)
				_player.resize(stage.stageWidth,stage.stageHeight);
			if (_comment)
				_comment.resize(dmRectWidth,dmRectHeight);
			Mouse.hide();
			///////////////
			
		}
		
		//发光字
		private function FlightTxt(color:Object=0xffffff,str:String="哎呦不错哦耶耶耶",font:String="微软雅黑",size:uint=260):TextField
		{
			var debText:TextField = new TextField();
			//debText.maxChars =3
			debText.selectable = false;
			debText.mouseEnabled = false;
			debText.multiline = false;
			debText.type = TextFieldType.DYNAMIC;
			debText.autoSize = TextFieldAutoSize.LEFT;
			var debTextFormat:TextFormat = new TextFormat(font,size,color,true);
			debTextFormat.letterSpacing =50;
			debText.defaultTextFormat = debTextFormat;
			if(str.length>5) str = str.slice(0,5)
			debText.text = str;
			//debText.filters = filter;
			debText.x = -debText.width*.5;
			debText.y = -debText.height*.5;
			return debText;
		}
		
		//重置发光字显示
		private function resetFlightBox():void
		{
			if(ggTxt.width > stage.stageWidth * .6){
				ggTxt.width = stage.stageWidth * .6;
				ggTxt.scaleY = ggTxt.scaleX;
			}
			ggTxt.x = stage.stageWidth* .5;
			ggTxt.y = stage.stageHeight-ggTxt.height*.6;
			this.setChildIndex(ggTxt,this.numChildren-1)
		}
	}
}