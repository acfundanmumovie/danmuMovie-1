package com.acfun.PlayerSkin
{
	import com.acfun.External.AcConfig;
	import com.acfun.External.ConstValue;
	import com.acfun.External.JavascriptAPI;
	import com.acfun.External.PARAM;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.PlayerSkin.component.AcFullscreenBox;
	import com.acfun.PlayerSkin.component.AcModeSelect;
	import com.acfun.PlayerSkin.component.AcRatePanel;
	import com.acfun.PlayerSkin.component.AcRecommend;
	import com.acfun.PlayerSkin.component.AcShowInfo;
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	import com.acfun.face.FaceText;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	import com.adobe.utils.StringUtil;
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class SkinControl extends Sprite implements ISkin
	{
		private static var _play_state:Boolean 	 = false;
		private static var _screen_state:Boolean = false;
		private static var _webscreen_state:Boolean = false;
		private static var _volume_state:Boolean = false;
		private static var _buffer_state:Boolean = false;
		private static var _loop_state:Boolean = false;		
		private static var _comment_state:Boolean = true;
		
		internal var totalLength:Number = 0;
		internal var bufferedPos:Number  = 0;
		internal var playedPos:Number = 0;
		private var _skin:Skin;
		private var buffAnimate:BuffAnimate;
		private var pauseAnimate:PauseAnimate;
		private var pauseAnimate2:PauseAnimate2;
		private var miniPause:PauseImage;
		private var miniPause2:PauseImage2;
		private var progDragFlag:Boolean = false;
		private var alert:Alert;
		private var modeSelect:AcModeSelect;
		private var face:FaceText;
//		private var commentFilterBox:AcCommentFilterBox = new AcCommentFilterBox();
		private var requireLogin:Boolean = false;
		private var fullscreenBox:AcFullscreenBox;
		private var info:AcShowInfo = new AcShowInfo();
		//加入弹幕发送cd
		private var inputCD:int = 0;
		private var inputLock:Boolean = false;
		private var miniMode:Boolean = false;
		private var recommend:AcRecommend = new AcRecommend();
		
		/**
		 * 发灰滤镜 
		 */		
		private const GRAY_FILTER:ColorMatrixFilter = new ColorMatrixFilter(
			[
				0.3086, 0.6094, 0.082, 0, 0, 
				0.3086, 0.6094, 0.082, 0, 0, 
				0.3086, 0.6094, 0.082, 0, 0,
				0, 0, 0, 1, 0, 
				0, 0, 0, 0, 1]);
			
		public function SkinControl()
		{
			super();
			visible = false;
			buffAnimate = new BuffAnimate();
			buffAnimate.visible = false;
			pauseAnimate = new PauseAnimate();
			pauseAnimate.visible = pauseAnimate.mouseEnabled = pauseAnimate.mouseChildren = false;			
			pauseAnimate2 = new PauseAnimate2();
			pauseAnimate2.visible = pauseAnimate2.mouseEnabled = pauseAnimate2.mouseChildren = false;
			miniPause = new PauseImage();
			miniPause.visible = miniPause.mouseEnabled = miniPause.mouseChildren = false;
			miniPause2 = new PauseImage2();
			miniPause2.visible = miniPause2.mouseEnabled = miniPause2.mouseChildren = false;
			alert = new Alert();
			alert.text.wordWrap = false;
			alert.text.autoSize = TextFieldAutoSize.LEFT;			
			alert.alpha = 0.95;			
			alert.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void{ e.stopImmediatePropagation(); });			
			
			_skin = new Skin(this);
//			_skin.controlBar.progress.mouseEnabled = true;			
			info.visible = false;
			recommend.visible = false;
			
			addChild(buffAnimate);			
			addChild(recommend);
			addChild(_skin);
			addChild(info);
			addChild(pauseAnimate);
			addChild(pauseAnimate2);
			addChild(miniPause);
			addChild(miniPause2);
			
			_skin.addEventListener(MouseEvent.CLICK,stopEvent);
			alert.addEventListener(MouseEvent.CLICK,stopEvent);
			
			reg();
			addEventListener(Event.ENTER_FRAME, onStage);
			init();
		}
		private function reg():void 
		{
			register(SIGNALCONST.SET_LOOP_CHANGE,loopChange);
			register(SIGNALCONST.SET_SILENT_CHANGE,onSilent);
			register(SIGNALCONST.SET_COMMENTSTATUS_CHANGE,commentShow);
			register(SIGNALCONST.SKIN_BUFF_PROG, bufferedSecond);
			register(SIGNALCONST.SKIN_PLAY_PROG, playedSecond);
			register(SIGNALCONST.SKIN_VEDIO_LENGHT, vLength);
			register(SIGNALCONST.SKIN_SREEN_STATUS, toggleFullscreen);
			register(SIGNALCONST.SKIN_BUFF_STATUS, toggleBuffering);
			register(SIGNALCONST.SKIN_PLAY_STATUS, togglePlaying);
			register(SIGNALCONST.SKIN_VOLUME_LENGHT, setVolumeBar);			
			register(SIGNALCONST.SKIN_SHOW_MESSAGE,showMessage);
			register(SIGNALCONST.SET_WEB_FULLSCREEN_CHANGE,setWebFullResponse);
			register(SIGNALCONST.COMMENT_SERVER_CONNECTED,onCommentConnected);
			register(SIGNALCONST.SET_CONFIG,onRightSwitch);
			register(SIGNALCONST.UPDATE_REMAIN_SENDS,function(value:String):void
			{
				Log.info("发送成功返回：",value);
				if(value!=null)
				{
					leftNum = Number(value);
				}
			});
		}
		
		private const GUEST:int = -1;
		private const REAL_MEMBER:int = 1;
		private const REGISTER_MEMBER:int = 0;
		/**
		 * -1游客 0 注册会员 1为正式会员 
		 */		
		private var _uLevel:int = GUEST;
		private var _leftNum:int = -1;
		
		private var _rightPadClosed:Boolean = true;
		/**
		 * 输入框默认文本 
		 */		
		private var _inTxtDefault:String = "";
		
		private function onCommentConnected(auth:*):void
		{
			//auth["danmu_remaining_num"] = 10;
			//auth["user_group_level"] = 0;
			_uLevel = auth["user_group_level"] == null ? GUEST:auth["user_group_level"];
			
			//游客或者错误用户类型数据null
			if(_uLevel == GUEST)
			{
				requireLogin = true;
				_inTextFiled.type = TextFieldType.DYNAMIC;
				_skin.controlBar.sendText.mouseEnabled = false;
				_inTextFiled.htmlText = _inTxtDefault = ConstValue.REQUIRE_LOGIN_TIP;
				//游客
				inputCD = ConstValue.INPUT_CD_GUEST;
				if (PARAM.acInfo.isLive)
					_inTextFiled.maxChars = 25;
				else
					_inTextFiled.maxChars = 54;
			}else{
				this._inTextFiled.type = TextFieldType.INPUT;
				_skin.controlBar.sendText.mouseEnabled = true;
				//会员
				inputCD = ConstValue.INPUT_CD_USER;
				if (PARAM.acInfo.isLive)
					_inTextFiled.maxChars = 35;
				leftNum = auth["danmu_remaining_num"];
			}
			Log.info("登录返回信息：",Util.encode(auth));
		}
		/**
		 * 弹幕列表设置消息处理
		 * @param value
		 */		
		private function onRightSwitch(value:Object):void
		{
			Log.debug("开关列表：",value["auto_widescreen"],"用户等级：",_uLevel);
			//处理开关
			if(value&&value.hasOwnProperty("auto_widescreen"))
			{
				_rightPadClosed = value["auto_widescreen"];
				leftNum = _leftNum;
			}
		}
		
		private var _inTextFiled:TextField;
		private var beforeFousWord:String = "";
		private function set inText(value:String):void
		{
			_inTextFiled.htmlText = value;
			this._inTxtDefault = value;
		}
		
		private function set leftNum(value:int):void
		{
			var remains:int = _leftNum = value || -1;
			var str:String = "";
			switch(_uLevel)
			{
				case REGISTER_MEMBER:
					if(value>5)
					{
						str = (!_rightPadClosed?ConstValue.MEMBER_MORE_FIVE_CLOSE:ConstValue.MEMBER_MORE_FIVE).replace("%s",value);
					}
					else if(value>0)
					{
						str = (!_rightPadClosed?ConstValue.MEMBER_LESS_FIVE_CLOSE:ConstValue.MEMBER_LESS_FIVE).replace("%s",value);
					}
					else
					{
						str = (!_rightPadClosed?ConstValue.MEMBER_ZERO_CLOSE:ConstValue.MEMBER_ZERO).replace("%s",0);
						_inTextFiled.type = TextFieldType.DYNAMIC;
						_skin.controlBar.sendText.filters = [this.GRAY_FILTER];
					}
					break;
				case REAL_MEMBER:
					break;
				default:
					str = ConstValue.REQUIRE_LOGIN_TIP;
					_inTextFiled.type = TextFieldType.DYNAMIC;
					break;
			}
			
			beforeFousWord = str;
			if(stage.focus != _inTextFiled||_inTextFiled.type == TextFieldType.DYNAMIC)
			{
				this.inText = beforeFousWord;
			}
		}
		
		private function stopEvent(e:Event):void
		{
			e.stopPropagation();
		}
		
		private function loopChange(isLoop:Boolean):void
		{
			_skin.controlBar.loopOn.visible = isLoop;
			_skin.controlBar.loopOff.visible = !isLoop;
		}
		
		private function onSilent(isSilent:Boolean):void
		{
			_skin.controlBar.volumeOn.visible = !isSilent;
			_skin.controlBar.volumeOff.visible = isSilent;
		}
		
		private function commentShow(isShow:Boolean):void
		{
			_comment_state = isShow;
			_skin.controlBar.cmtOn.visible = _comment_state;
			_skin.controlBar.cmtOff.visible = !_comment_state;
//			commentFilterBox.blockAll = !_comment_state;
		}
		
		public function bufferedSecond(value:Number):void
		{
			value = value - PARAM.acInfo.startTime;
			bufferedPos = value;
			if(totalLength != 0) {
				/* 已缓冲  */
//				var t:Number = bufferedPos / totalLength*skin.controlBar.progress.back.width;
//				if(t > 3) {
//					skin.controlBar.progress.buffered.width = t-3;					
//				} else {
//					skin.controlBar.progress.buffered.width = 0;					
//				}
				_skin.progBar.buffer = bufferedPos / totalLength;
			}
		}
		
		public function playedSecond(value:Number):void
		{
			playedPos = value;
			value = value - PARAM.acInfo.startTime;			
			skin.controlBar.timer.now.text = Util.digits(value);
			if(totalLength != 0 && !progDragFlag) {
				_skin.progBar.position = value / totalLength;
			}
		}
		
//		public function onMouseDown(e:MouseEvent):void
//		{
//			progDragFlag = true;
//			skin.controlBar.progress.spot2.startDrag(false, new Rectangle(0,2,skin.controlBar.progress.back.width, 0));
//			skin.controlBar.progress.progressed.width = skin.controlBar.progress.spot.x;
//			skin.controlBar.progress.spot2.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
//			stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
//		}
//		public function onMouseUp(e:MouseEvent):void
//		{
//			progDragFlag = false;
//			skin.controlBar.progress.spot2.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
//			stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
//			skin.controlBar.progress.spot2.stopDrag();
//			skin.controlBar.progress.spot2.x = skin.controlBar.progress.mouseX;
//			skin.controlBar.progress.progressed.width = skin.controlBar.progress.mouseX;
//			var pos:Number = skin.controlBar.progress.mouseX / skin.controlBar.progress.back.width*totalLength;
//			notify(SIGNALCONST.SET_POSITION_CHANGE, pos+PARAM.acInfo.startTime);
//		}
		
		private var _vlength:Number = -1;
		public function vLength(value:Number):void
		{
			if (_vlength != value)
			{
				_vlength = value;
				value = value - PARAM.acInfo.startTime;
				totalLength = value;
				if (PARAM.acInfo.isLive)
					_skin.controlBar.timer.total.text = " 直播中";
				else
					_skin.controlBar.timer.total.text = "/ " + Util.digits(value);
				_skin.progBar.totalTime = value;	
			}
		}
		
		public function setVolumeBar(value:Number,showTip:Boolean=false):void
		{
			if (value < 0  ) value = 0;
			
			if (showTip)
				skin.volBar.showTip((value>ConstValue.PLAYER_VOLUME_MAX?ConstValue.PLAYER_VOLUME_MAX:value)+"%",true);
			
			if (value > 100) value = 100;
			
			skin.volBar.position = value/100;
			
			if (value == 0)
			{
				//自动静音
				onSilent(true);
			}
			else
			{
				//自动恢复
				onSilent(false);
			}
		}
		
		
		public function toggleFullscreen(isFullscreen:Boolean):void
		{
			if (isFullscreen)
				fullScreen(null);
			else
				normalScreen(null);
		}
		
		public function toggleBuffering(isBuffering:Boolean):void
		{
			if (_buffer_state != isBuffering)
			{
				_buffer_state = isBuffering;
				buffAnimate.visible = _buffer_state;	
			}
		}
		
		public function togglePlaying(playing:Boolean):void
		{	
			_skin.playBtn.visible = !playing;
			_skin.pauseBtn.visible = playing;
			
			if(buffAnimate.visible) {
				pauseAnimate.visible = false;
				pauseAnimate2.visible = false;
				miniPause.visible = false;
				miniPause2.visible = false;
			} else {
				if(playing) {
					if (miniMode)
					{
						miniPause.visible = false;
						miniPause2.visible = true;
						miniPause2.gotoAndPlay(1);
					}
					else
					{
						pauseAnimate.visible = false;
						pauseAnimate2.visible = true;
						pauseAnimate2.gotoAndPlay(1);	
					}
				} else {
					if (miniMode)
					{
						miniPause2.visible = false;
						miniPause.visible = true;
						miniPause.gotoAndPlay(1);
					}
					else
					{
						pauseAnimate2.visible = false;
						pauseAnimate.visible = true;
						pauseAnimate.gotoAndPlay(1);	
					}						
				}
			}
		}
		
		public function showMessage(message:String, pic:String="", canClose:Boolean=true, onClose:Function=null):void
		{	
			if (message == null) return;
			
			alert.text.htmlText = message;
			alert.text.x = 20;
			alert.text.y = 30;
			
			if (alert)
				closeAlert(null);
			
			//清除之前的ac娘
			while (alert.ac.numChildren > 0)
				alert.ac.removeChildAt(0);
			//添加ac娘头像
			if (pic != "" && int(pic) > 0)
			{
				var ac:String = ConstValue.AC_PIC_URL.replace("{num}",Util.zeroPad(pic,2));
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void{
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,arguments.callee);
					var bmp:Bitmap = loader.content as Bitmap;					
					bmp.scaleX = bmp.scaleY = 0.5;					
					alert.ac.addChild(bmp);					
					alert.text.x += bmp.width;
					alertResize();
					alert.ac.x = 20;
					alert.ac.y = (alert.bg.height - bmp.height) / 2;
				});
				loader.load(new URLRequest(ac),new LoaderContext(true));
			}
			alertResize();
			
			if(canClose) {
				alert.ok.visible = true;
				alert.close.visible = true;
				alert.ok.addEventListener(MouseEvent.CLICK, closeAlert);
				alert.close.addEventListener(MouseEvent.CLICK, closeAlert);
			}else{
				alert.ok.visible = false;
				alert.close.visible = false;
			}
			if(onClose!=null) {
				onClose();
			}
		
			if (stage)
				stage.addChild(alert);
			
			function alertResize():void
			{
				alert.bg.width = alert.ac.width + alert.text.textWidth + 70;			
				alert.bg.height = alert.text.textHeight + (canClose?75:55);
				if (alert.bg.height < 90) alert.bg.height = 90;
				alert.close.x = alert.bg.width - 30;
				alert.ok.x = (alert.bg.width - alert.ok.width)/2;
				alert.ok.y = alert.bg.height - 30;
				alert.x = (_w - alert.width) / 2;
				alert.y = (_h - alert.height) / 2;
			}
		}
		
		private function closeAlert(e:MouseEvent):void
		{
			alert.ok.removeEventListener(MouseEvent.CLICK, closeAlert);
			if (stage && stage.contains(alert))
				stage.removeChild(alert);			
		}
		
		private function onStage(ee:Event):void
		{
			if (stage && stage.stageWidth > 0)
			{
				removeEventListener(Event.ENTER_FRAME,onStage);
				resize(stage.stageWidth,stage.stageHeight);
				visible = false;
				stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreenChange2);
				stage.addEventListener(KeyboardEvent.KEY_UP,hotKey);
				
				//alert可拖动
				Util.dragEnable(alert,alert.bg,new Rectangle(0,0,stage.fullScreenWidth,stage.fullScreenHeight),stage);
			}
		}
		
		protected function hotKey(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ENTER)	//回车自动定位到输入框
			{
				if (event.target is TextField && (event.target as TextField).type == TextFieldType.INPUT)
					return;
				stage.focus = _inTextFiled;
			}
		}
		
		private var _w:Number;
		private var _h:Number;
		public function resize(w:Number, h:Number):void
		{
			_skin.resize(w, h);
			buffAnimate.x = w / 2;
			buffAnimate.y = h / 2;
			pauseAnimate.x = pauseAnimate2.x = w - SkinConfig.PAUSE_ANIMATION_WIDTH/2 - SkinConfig.PAUSE_ANIMATION_GAP;
			pauseAnimate.y = pauseAnimate2.y = h - ConstValue.PLAYER_SKIN_DEFAULT_HEIGHT - SkinConfig.PAUSE_ANIMATION_HEIGHT/2 - SkinConfig.PAUSE_ANIMATION_GAP;			
			alert.x = (w - alert.width) / 2;
			alert.y = (h - alert.height) / 2;
			miniPause.x = w / 2;
			miniPause.y = h / 2;
			miniPause2.x = w / 2;
			miniPause2.y = h / 2;
			info.resize(w,h);
			info.y = h - ConstValue.PLAYER_SKIN_DEFAULT_HEIGHT - AcShowInfo.INFO_HEIGHT;
			recommend.resize(w,h);	//只需要宽度，高度可自行计算
			
			_w = w;
			_h = h;
		}
		private function init():void
		{
			_skin.controlBar.playBtn.addEventListener(MouseEvent.CLICK, play);
			_skin.controlBar.pauseBtn.addEventListener(MouseEvent.CLICK, pause);
			_skin.controlBar.volumeOn.addEventListener(MouseEvent.CLICK, volumeOn);
			_skin.controlBar.volumeOff.addEventListener(MouseEvent.CLICK, volumeOff);
			_skin.cmtOn.addEventListener(MouseEvent.CLICK, commentOn);
			_skin.cmtOff.addEventListener(MouseEvent.CLICK, commentOff);			
			_skin.controlBar.loopOff.addEventListener(MouseEvent.CLICK, loopOn);
			_skin.controlBar.loopOn.addEventListener(MouseEvent.CLICK, loopOff);
			_skin.controlBar.fullScreen.addEventListener(MouseEvent.CLICK, fullScreen);
			_skin.controlBar.normalScreen.addEventListener(MouseEvent.CLICK, normalScreen);
			_skin.controlBar.addEventListener(MouseEvent.ROLL_OVER, showBar);
			_skin.controlBar.addEventListener(MouseEvent.ROLL_OUT, hideBar);			
			_skin.controlBar.sendText.addEventListener(MouseEvent.CLICK,sendComment);
			
			this._inTextFiled = _skin.controlBar.input.inputText;
			this._inTextFiled.type = TextFieldType.DYNAMIC;
			_skin.controlBar.sendText.mouseEnabled = false;
			
			_inTextFiled.addEventListener(KeyboardEvent.KEY_UP,onInputKeyup);
			_inTextFiled.addEventListener(FocusEvent.FOCUS_IN,onInputFocusIn);
			_inTextFiled.addEventListener(FocusEvent.FOCUS_OUT,onInputFocusOut);
			_inTextFiled.addEventListener(Event.CHANGE,function(e:Event):void
			{
				inText = _inTextFiled.text;
			});
			_inTextFiled.addEventListener(TextEvent.LINK,onTextLink);
			
			_skin.progBar.addEventListener(Event.COMPLETE,onProgressAdjustComplete);
			_skin.controlBar.config.addEventListener(MouseEvent.CLICK,onConfig);
			
			initModeSelectBox();
			initFaceBox();
//			initCommentFilterBox();
			initFullscreenBox();
			initRateSelect();
			
			//_skin.controlBar.sendText.filters = [GRAY_FILTER];
			//_skin.controlBar.fullScreen.addEventListener(MouseEvent.MOUSE_OVER, showWebFullBubble);
			//_skin.controlBar.fullScreen.addEventListener(MouseEvent.ROLL_OUT, hideWebFullBubble);
			//_skin.webFull.addEventListener(MouseEvent.MOUSE_OVER, showWebFullBubble);
			//_skin.webFullBubble.addEventListener(MouseEvent.ROLL_OUT, hideWebFullBubble);
//			_skin.webFull.addEventListener(MouseEvent.CLICK, setWebFull);
//			_skin.webNormal.addEventListener(MouseEvent.CLICK, setWebFull);
		}
		
		protected function onConfig(event:MouseEvent):void
		{
			notify(SIGNALCONST.SKIN_SHOW_MORE_CONFIG);
		}
		
		private var focusTime:int = -1;
		protected function onInputFocusIn(event:FocusEvent):void
		{
			if(this._inTextFiled.type == TextFieldType.INPUT)
			{
				focusTime = playedPos;
				_skin.controlBar.input.timeAnchor.text = "@" + Util.digits(focusTime);
				_skin.controlBar.input.timeAnchor.visible = AcConfig.getInstance().time_anchor;
				
				if(this._inTxtDefault == this.beforeFousWord)
				{
					_inTextFiled.text = "";
				}
			}
		}
		
		protected function onInputFocusOut(event:FocusEvent):void
		{
			if(this._inTextFiled.type == TextFieldType.INPUT)
			{
				focusTime = -1;
				_skin.controlBar.input.timeAnchor.visible = false;
				if(_inTextFiled.text == "")
				{
					this.inText = this.beforeFousWord;
				}
			}
		}
		
		protected function onTextLink(event:TextEvent):void
		{
			if (event.text == "login")
			{
				Log.info("call:登录",JavascriptAPI.CALL_ACTION,"action:login");
				JavascriptAPI.callJS(JavascriptAPI.CALL_ACTION,{action:"login"});
			}else if(event.text == "gotoExa"){
				//去答题
				Log.info("call:打开答题界面",JavascriptAPI.CALL_ACTION,"action:answer");
				//JavascriptAPI.callJS(JavascriptAPI.CALL_ANSWER);
				JavascriptAPI.callJS(JavascriptAPI.CALL_ACTION,{"action":"answer"});
			}
		}
		
		protected function onInputKeyup(event:KeyboardEvent):void
		{
			event.stopImmediatePropagation();
			
			if (inputFocusTimeout >= 0 && _inTextFiled.text.length > 0)
			{
				clearTimeout(inputFocusTimeout);
				inputFocusTimeout = -1;
			}
			
			if (event.keyCode == Keyboard.ENTER)
			{
				if (StringUtil.trim(_inTextFiled.text) == "")
				{
					stage.focus = null;
					this.inText = beforeFousWord;
				}
				else
				{
					sendComment(null);
				}
			}
			
			if (event.keyCode == Keyboard.ESCAPE)
			{
				stage.focus = null;
				this.inText = beforeFousWord;
			}
		}
		
		protected function onProgressAdjustComplete(event:Event):void
		{
			var time:Number = _skin.progBar.position * totalLength + PARAM.acInfo.startTime;
			notify(SIGNALCONST.SET_POSITION_CHANGE, time);
		}
		
//		private function initCommentFilterBox():void
//		{
//			commentFilterBox.visible = false;
//			commentFilterBox.addEventListener(Event.CHANGE,onChange);
//			commentFilterBox.blockGuest = !PARAM.acInfo.allowDanmaku;
//			addChild(commentFilterBox);
//			
//			_skin.cmtOn.addEventListener(MouseEvent.ROLL_OVER, commentMouseOver);
//			_skin.cmtOff.addEventListener(MouseEvent.ROLL_OVER, commentMouseOver);
//			_skin.cmtOn.addEventListener(MouseEvent.ROLL_OUT, commentMouseOut);
//			_skin.cmtOff.addEventListener(MouseEvent.ROLL_OUT, commentMouseOut);
//			
//			function commentMouseOut(event:MouseEvent):void
//			{
//				if (event.localX <=0 ||
//					event.localX >= event.currentTarget.width ||
//					event.localY >= event.currentTarget.height)
//					commentFilterBox.visible = false;
//			}
//			
//			var me:SkinControl = this;
//			function commentMouseOver(event:MouseEvent):void
//			{
//				var target:DisplayObject = event.currentTarget as DisplayObject;
//				var rect:Rectangle = target.getRect(me);
//				commentFilterBox.x = rect.x + target.width/2;
//				commentFilterBox.y = rect.y - 5;
//				commentFilterBox.visible = true;
//			}
//			
//			function onChange(event:Event):void
//			{
//				commentFilterBox.blockAll ? commentOn(null):commentOff(null);
//				var a:Array = [];
//				a[5] = !commentFilterBox.blockGuest;
//				notify(SIGNALCONST.SET_COMMENT_FILTER,a);
//			}
//		}
		
		private function initFullscreenBox():void
		{
			fullscreenBox = new AcFullscreenBox();
			fullscreenBox.visible = false;
			fullscreenBox.addEventListener(Event.CHANGE,onChange);			
			addChild(fullscreenBox);
			
			_skin.normalScreen.addEventListener(MouseEvent.ROLL_OVER, MouseOver);
			_skin.fullsBtn.addEventListener(MouseEvent.ROLL_OVER, MouseOver);
			_skin.normalScreen.addEventListener(MouseEvent.ROLL_OUT, MouseOut);
			_skin.fullsBtn.addEventListener(MouseEvent.ROLL_OUT, MouseOut);
			
			function MouseOut(event:MouseEvent):void
			{
				if (event.localX <=0 ||
					event.localX >= event.currentTarget.width ||
					event.localY >= event.currentTarget.height)
					fullscreenBox.visible = false;
			}
			
			var me:SkinControl = this;
			function MouseOver(event:MouseEvent):void
			{
				var target:DisplayObject = event.currentTarget as DisplayObject;
				var rect:Rectangle = target.getRect(me);
				fullscreenBox.x = rect.x + target.width/2;
				fullscreenBox.y = rect.y - 5;
				fullscreenBox.visible = true;
			}
			
			function onChange(event:Event):void
			{
				
			}
		}
		
		private function initFaceBox():void
		{
			face = new FaceText();
			face.visible = false;
			addChild(face);
			
			_skin.controlBar.face.addEventListener(MouseEvent.CLICK,faceClick);
			_skin.controlBar.face.addEventListener(MouseEvent.ROLL_OUT,mouseOut);
			register(SIGNALCONST.SET_FACE_TEXT,setFaceText);
			
			function setFaceText(value:String):void{
				if(_inTxtDefault == beforeFousWord)
				{
					_inTextFiled.text = "";
				}
				_inTextFiled.appendText(value);
				_inTxtDefault = _inTextFiled.text;
			}
			var me:SkinControl = this;
			function faceClick(e:MouseEvent):void{
				if (face.visible)
				{
					face.visible = false;
				}
				else
				{
					var target:DisplayObject = e.currentTarget as DisplayObject;
					var rect:Rectangle = target.getRect(me);
					face.x = rect.x + target.width/2 - face.width/2 + 21;
					face.y = rect.y - 10 - 170;
					face.visible = true;	
				}
			}
			
			function mouseOut(e:MouseEvent):void{
				if (e.localX <=1 ||
					e.localX >= e.currentTarget.width ||
					e.localY >= e.currentTarget.height)
					face.visible = false;
			}
		}
		
		private function initModeSelectBox():void
		{
			modeSelect = new AcModeSelect();
			modeSelect.visible = false;
			addChild(modeSelect);
			
			_skin.controlBar.mode.addEventListener(MouseEvent.CLICK,modeOpen);
			_skin.controlBar.mode.addEventListener(MouseEvent.ROLL_OUT, MouseOut);
			
			function MouseOut(event:MouseEvent):void
			{
				if (event.localX <=1 ||
					event.localX >= event.currentTarget.width ||
					event.localY >= event.currentTarget.height)
					modeSelect.visible = false;
			}
			
			var me:SkinControl = this;
			function modeOpen(event:MouseEvent):void
			{
				if(_uLevel == REGISTER_MEMBER)
				{
					//弹出权限提示
					Log.info("call:打开答题界面",JavascriptAPI.CALL_ACTION);
					JavascriptAPI.callJS(JavascriptAPI.CALL_ACTION,{"action":"answer"});					
					return;
				}
				if (modeSelect.visible)
				{
					modeSelect.visible = false;
				}
				else
				{
					var target:DisplayObject = event.currentTarget as DisplayObject;
					var rect:Rectangle = target.getRect(me);
					modeSelect.x = rect.x + target.width/2;
					modeSelect.y = rect.y - 5;
					modeSelect.visible = true;	
				}
			}				
		}
		
		private function initRateSelect():void
		{
			var panel:AcRatePanel = new AcRatePanel();
			panel.visible = false;
			addChild(panel);
			
			var rateButton:SimpleButton = _skin.controlBar.rate; 
			rateButton.addEventListener(MouseEvent.CLICK,openRatePanel);
			
			var me:SkinControl = this;
			function openRatePanel(event:MouseEvent):void
			{
				if (panel.visible)
				{
					panel.visible = false;
				}
				else
				{
					var target:DisplayObject = event.currentTarget as DisplayObject;
					var rect:Rectangle = target.getRect(me);
					panel.x = rect.x + target.width/2;
					panel.y = rect.y - 1;
					panel.visible = true;
				}
			}
			
			register(SIGNALCONST.SET_PLAYER_RATE_CHANGED,onSetRate);
			function onSetRate(rate:int,rates:Array,ratestr:Array):void
			{
				var str:String = ratestr[rate] || "清晰度";
				rateButton.upState["getChildAt"](1).text = str;
				rateButton.downState["getChildAt"](1).text = str;
				rateButton.overState["getChildAt"](1).text = str;
			}
		}
		
		private var inputFocusTimeout:int = -1;
		protected function sendComment(event:MouseEvent):void
		{
			Log.info("发送文字：",_inTextFiled.text,_inTxtDefault,beforeFousWord);
			if (requireLogin || inputLock || _inTextFiled.text.length == 0||this._inTxtDefault == this.beforeFousWord) return;
			
			var param:Object = {};
			param.text = _inTextFiled.text;
			param.type = modeSelect.danmakuMode;
			param.color = modeSelect.danmakuColor;
			param.fontSize = modeSelect.danmakuSize;
			if (AcConfig.getInstance().time_anchor)
				param.stime = focusTime;
			_inTextFiled.text = "";
			notify(SIGNALCONST.COMMENT_SEND,param);
			
			//发送完弹幕失去焦点
			inputFocusTimeout = setTimeout(function():void{
				if (stage.focus == _inTextFiled)
 					stage.focus = null;
					inText = beforeFousWord;
			},5000);
			
			if (inputCD > 0)
			{
				var ct:ColorTransform = new ColorTransform(0.5,0.5,0.5);				
				_skin.controlBar.sendText.enabled = false;
				_skin.controlBar.sendText.transform.colorTransform = ct;
				inputLock = true;
				
				setTimeout(function():void{
					_skin.controlBar.sendText.enabled = true;
					_skin.controlBar.sendText.transform.colorTransform = new ColorTransform();
					inputLock = false;
				},inputCD*1000);
			}
		}
		
		protected function setWebFull(event:MouseEvent):void
		{
			notify(SIGNALCONST.SET_WEB_FULLSCREEN_CHANGE, !_webscreen_state);
			event.stopPropagation();		
		}
		protected function setWebFullResponse(webstate:Boolean):void
		{
			_webscreen_state = webstate;
			_skin.fullsBtn.visible = !_webscreen_state;
			skin.normalScreen.visible = _webscreen_state;
//			_skin.webFull.visible = !_webscreen_state;
//			_skin.webNormal.visible = _webscreen_state;
//			_skin.inputBar.visible = PARAM.alwaysShowInput || _webscreen_state;
		}
//		protected function showWebFullBubble(event:MouseEvent):void
//		{
//			_skin.webFull.visible = true;
//		}
//		
//		protected function hideWebFullBubble(event:MouseEvent):void
//		{
//			if (!_skin.controlBar.fullScreen.hitTestPoint(mouseX,mouseY))
//			{
//				_skin.webFull.addEventListener(MouseEvent.MOUSE_OUT, hideWebFullBubble);
//				_skin.webFull.visible = false;
//			}
//		}
		private function commentOn(e:MouseEvent):void
		{
			notify(SIGNALCONST.SET_COMMENTSTATUS_CHANGE, false);
		}
		private function commentOff(e:MouseEvent):void
		{
			notify(SIGNALCONST.SET_COMMENTSTATUS_CHANGE, true);
		}
		private function onFullscreenChange2(e:FullScreenEvent):void
		{
			_skin.controlBar.alpha = e.fullScreen?0:1;
			if(e.fullScreen) {
				_screen_state = true;
				_webscreen_state = false;
//				_skin.inputBar.visible = PARAM.alwaysShowInput;
				_skin.controlBar.alpha = 1;
				hideBar(null);
			} else {
				_screen_state = false;
				setTimeout(function():void{
					_skin.controlBar.alpha = 1;
					if (_hideBarTW)	_hideBarTW.kill();
				},300);
			}
			_skin.fullsBtn.visible = !_screen_state;
			_skin.normalScreen.visible = _screen_state;			
			resize(stage.stageWidth,stage.stageHeight);			
			notify(SIGNALCONST.SET_DESKTOP_FULLSCREEN_CHANGE, _screen_state);
		}
		private function showBar(e:MouseEvent):void
		{
			if(_screen_state) {
				if (_hideBarTW) _hideBarTW.kill();
				TweenMax.to(_skin.controlBar, 0.2, {alpha:1});
				//_skin.controlBar.alpha = 1;
			}
		}
		private var _hideBarTW:TweenMax;
		private function hideBar(e:MouseEvent):void
		{
			if(_screen_state) {
				_hideBarTW = TweenMax.to(_skin.controlBar, 0.6, {alpha:0, delay:0.3});
			}
		}
		private function play(e:MouseEvent):void 
		{
			_play_state = true;
			_skin.controlBar.playBtn.visible = !_play_state;
			_skin.controlBar.pauseBtn.visible = _play_state;
			notify(SIGNALCONST.SET_PLAYSTATUS_CHANGE, _play_state);
		}
		private function pause(e:MouseEvent):void
		{
			_play_state = false;
			/* show play */
			_skin.controlBar.playBtn.visible = !_play_state;
			_skin.controlBar.pauseBtn.visible = _play_state;
			notify(SIGNALCONST.SET_PLAYSTATUS_CHANGE, _play_state);
		}
		protected function seek(e:MouseEvent):void
		{
			/* 先更改外观  */
			if(totalLength != 0) {
				/* 已播放  */
				skin.controlBar.progress.progressed.width = skin.controlBar.progress.mouseX;
				skin.controlBar.progress.spot.x = skin.controlBar.progress.mouseX;
				skin.controlBar.progress.spot2.x = skin.controlBar.progress.mouseX;
			}
			var pos:Number = skin.controlBar.progress.mouseX / skin.controlBar.progress.back.width;
			notify(SIGNALCONST.SET_POSITION_CHANGE, pos+PARAM.acInfo.startTime);
		}
		private function volumeOn(e:MouseEvent):void
		{
			_volume_state = true;			
			notify(SIGNALCONST.SET_SILENT_CHANGE, _volume_state);			
		}
		private function volumeOff(e:MouseEvent):void
		{
			_volume_state = false;
			notify(SIGNALCONST.SET_SILENT_CHANGE, _volume_state);
		}
		private function loopOn(e:MouseEvent):void
		{
			_loop_state = true;			
			notify(SIGNALCONST.SET_LOOP_CHANGE, _loop_state);
		}
		private function loopOff(e:MouseEvent):void
		{
			_loop_state = false;
			notify(SIGNALCONST.SET_LOOP_CHANGE, _loop_state);
		}
		private function volumeChange(e:MouseEvent):void
		{
			/* 先更改外观  */
			var pos:Number = 999;
			notify(SIGNALCONST.SET_VOLUME_CHANGE, pos);
		}
		private function fullScreen(e:MouseEvent):void
		{
			trace(AcConfig.getInstance().fullscreen_input);
			stage.displayState = AcConfig.getInstance().fullscreen_input?"fullScreenInteractive":StageDisplayState.FULL_SCREEN;
			if (e) e.stopPropagation();
		}
		private function normalScreen(e:MouseEvent):void
		{
			if (_webscreen_state)
			{
				notify(SIGNALCONST.SET_WEB_FULLSCREEN_CHANGE,false);
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;	
			}
			if (e) e.stopPropagation();
		}
		public function get skin():Skin
		{
			return _skin;
		}
		
		public function setInputCD(cd:int):void
		{
			if (cd >= 0)
				inputCD = cd;
		}
		
		public function setMiniMode(mini:Boolean):void
		{
			if (miniMode != mini)
			{
				miniMode = mini;
				
				if (miniMode)
				{
					_skin.controlBar.visible = false;
					pauseAnimate.visible = false;
					pauseAnimate2.visible = false;					
				}
				else
				{
					miniPause.visible = false;
					_skin.controlBar.visible = true;									
				}
			}
		}
	}
}