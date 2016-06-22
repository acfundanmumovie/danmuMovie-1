package com.acfun.PlayerSkin
{
	import com.acfun.External.AcConfig;
	import com.acfun.External.ConstValue;
	import com.acfun.External.PARAM;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.PlayerSkin.component.AcProgressBar;
	import com.acfun.PlayerSkin.component.AcSlider;
	import com.acfun.PlayerSkin.component.AcVolumeBar;
	import com.acfun.signal.notify;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	 
	public class Skin extends Sprite
	{
		public var controlBar:ControlBar;
		public var playBtn:SimpleButton;
		public var pauseBtn:SimpleButton;
		public var volOnBtn:SimpleButton;
		public var volOffBtn:SimpleButton;
		public var loopOnBtn:SimpleButton;
		public var loopOffBtn:SimpleButton;
		public var fullsBtn:SimpleButton;
		public var normalScreen:SimpleButton;
		public var cmtOn:SimpleButton;
		public var cmtOff:SimpleButton;
//		public var logoBtn:SimpleButton;
		public var rate:SimpleButton;
		public var config:SimpleButton;
		public var progBar:AcProgressBar;
		public var volBar:AcSlider;
		
		public var face:SimpleButton;
		
		public var volPos:Number;
		public var progPos:Number;
		public var timeFix:uint;
		public var progShow:Boolean;
		public var onHide:Boolean;
		
		private var su:SkinControl;
		
		private var bufferedPos:Number  = 0;
		private var playedPos:Number = 0;
		
		public function Skin(su:SkinControl) 
		{
			this.su = su;
			
			controlBar = new ControlBar();			
			playBtn = controlBar.playBtn;
			face = controlBar.face;
			pauseBtn = controlBar.pauseBtn;
			pauseBtn.visible = false;
			volOnBtn = controlBar.volumeOn;
			volOffBtn = controlBar.volumeOff;
			volOffBtn.visible = false;
			loopOnBtn = controlBar.loopOn;
			loopOnBtn.visible = false;
			loopOffBtn = controlBar.loopOff;
			fullsBtn = controlBar.fullScreen;
			normalScreen = controlBar.normalScreen;
			normalScreen.visible = false;
			cmtOn =controlBar.cmtOn;
			cmtOff =controlBar.cmtOff;
			cmtOff.visible = false;
			config = controlBar.config;
			rate = controlBar.rate;
			var a:* = controlBar.getChildAt(0);
//			a.visible = false
			a.x = 0;
			a.width = 10;
//			a.graphics.beginFill(0xFF0000,1);
//			a.graphics.drawRect(0,0,20,20);
//			a.graphics.endFill();
			//音量条			
			volBar = new AcVolumeBar();
			volBar.setWidth(SkinConfig.VOLUME_BAR_WIDTH);
			volBar.addEventListener(Event.CHANGE,onVolChange);			
			controlBar.volBar.addChild(volBar);
			
			//进度条
			progBar = new AcProgressBar();
//			progBar.addEventListener(MouseEvent.ROLL_OVER, onProgOver);
//			progBar.addEventListener(MouseEvent.ROLL_OUT, onProgOut);
//			progBar.addEventListener(MouseEvent.CLICK, onMouseClick);
//			progBar.addEventListener(MouseEvent.MOUSE_MOVE,onProgMouseOver);
//			progBar.addEventListener(MouseEvent.ROLL_OUT,onMouseOut);
//			volBar.spot2.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown2);
//			volBar.addEventListener(MouseEvent.CLICK, onMouseClick2);
//			logoBtn.addEventListener(MouseEvent.CLICK,onLogoClick);			
			
			if (!PARAM.acInfo.isLive)
			{
				var index:int = controlBar.getChildIndex(controlBar.playBtn);
				controlBar.addChildAt(progBar,index+1);
			}		
			addChild(controlBar);
		}
		
		protected function onVolChange(event:Event):void
		{
			var pos:Number = volBar.position * 100;
			if (pos < 0) pos = 0;
			if (pos > 100) pos = 100;
			
			notify(SIGNALCONST.SET_VOLUME_CHANGE, pos);
		}
		
		
		public function resize(w:Number, h:Number):void
		{
			if (w < 300) 
			{
				//小于此宽度无法正常显示，并可能引发宽度计算错误，故隐藏
				this.visible = false;
				return;
			}
			else
			{
				this.visible = true;
			}
			var tw:Number = controlBar.back.width;
			y = h - ConstValue.PLAYER_SKIN_DEFAULT_HEIGHT;
			controlBar.back.width = w;
			progBar.setWidth(w);
			var ww:Number = w - tw;			
			controlBar.sendText.x += ww;
			volOnBtn.x += ww;
			volOffBtn.x += ww;
			volBar.x += ww;
			cmtOn.x += ww;
			cmtOff.x += ww;
			loopOffBtn.x += ww;
			loopOnBtn.x += ww;
			fullsBtn.x += ww; 
			normalScreen.x += ww;
			config.x += ww;
			rate.x += ww;
			
			
			var r:Number = controlBar.sendText.getRect(controlBar.input).right;
			if (r > 125)			
			{
				controlBar.input.bg.width = r;
				controlBar.input.timeAnchor.x = r - controlBar.sendText.width - 65;
				controlBar.input.inputText.width = controlBar.input.timeAnchor.x + (AcConfig.getInstance().time_anchor?0:controlBar.input.timeAnchor.width);
			}
			
			if (w < 540)
			{
				//小于该宽度  太拥挤 隐藏输入框
				controlBar.mode.visible = false;
				controlBar.face.visible = false;
				controlBar.sendText.visible = false;
				controlBar.input.visible = false;
			}
			else
			{
				controlBar.mode.visible = true;
				controlBar.face.visible = true;
				controlBar.sendText.visible = true;
				controlBar.input.visible = true;				
			}				
		}

//		public function onMouseClick(e:MouseEvent):void
//		{
//			progBar.progressed.width = progBar.mouseX;
//			/*throw*/
//			var pos:Number = progBar.mouseX / progBar.back.width*su.totalLength;
//			e.stopPropagation();
//			notify(SIGNALCONST.SET_POSITION_CHANGE, pos+PARAM.acInfo.startTime);
//		}
		
//		public function onMouseDown2(e:MouseEvent):void
//		{
//			volBar.spot2.startDrag(false, new Rectangle(0,volBar.spot2.y,volBar.back.width - volBar.spot2.width,0));
//			volBar.prog.width = volBar.spot2.x;
//			volBar.spot2.addEventListener(MouseEvent.MOUSE_UP,onMouseUp2);
//			stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp2);
//			volBar.spot2.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
//			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
//			
//			volumeTip.visible = true;
//			onMouseMove(null);
//		}
//		public function onMouseMove(e:MouseEvent):void
//		{
//			if(volBar.mouseX < 0){
//				volBar.prog.width = 0;
//			} else if(volBar.mouseX > volBar.back.width) {
//				volBar.prog.width = volBar.back.width;
//			} else {
//				volBar.prog.width = volBar.mouseX;
//			}
//			
//			var pos:Number = volBar.mouseX/volBar.back.width*100;
//			if (pos < 0) pos = 0;
//			if (pos > 100) pos = 100;
//			
//			//音量提示器
//			var rect:Rectangle = volBar.spot2.getRect(controlBar);
//			volumeTip.x = rect.x + rect.width/2;
//			volumeTip.y = rect.y - 5;
//			volumeTip.tf.text = Math.round(pos).toString();
//			
//			notify(SIGNALCONST.SET_VOLUME_CHANGE, pos);
//		}
//		public function onMouseUp2(e:MouseEvent):void
//		{
//			volBar.spot2.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp2);
//			stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp2);
//			volBar.spot2.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
//			stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
//			volBar.spot2.stopDrag();
//			
//			volumeTip.visible = false;
//		}
//		public function onMouseClick2(e:MouseEvent):void
//		{
//			if(volBar.mouseX < 0){
//				volBar.spot2.x = 0;
//				volBar.prog.width = 0;
//			} else if(volBar.mouseX > volBar.back.width) {
//				volBar.spot2.x = volBar.back.width;
//				volBar.prog.width = volBar.back.width;
//			} else {
//				volBar.spot2.x = volBar.mouseX;
//				volBar.prog.width = volBar.mouseX;
//			}
//			/*throw*/
//			var pos:Number = volBar.mouseX/volBar.back.width*100;
//			notify(SIGNALCONST.SET_VOLUME_CHANGE, pos);
//		}
//		protected function volumeChange(e:MouseEvent):void
//		{
//			/* 先更改外观  */
//			volBar.spot2.x = volBar.mouseX;
//			volBar.prog.width = volBar.mouseX;
//			var pos:Number = volBar.mouseX/volBar.back.width*100;
//			notify(SIGNALCONST.SET_VOLUME_CHANGE, pos);
//		}
	}
}