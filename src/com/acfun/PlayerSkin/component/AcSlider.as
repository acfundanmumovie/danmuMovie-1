package com.acfun.PlayerSkin.component
{
	import com.greensock.TweenLite;
	
	import fl.controls.BaseButton;
	import fl.controls.listClasses.CellRenderer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	[Event(name="change", type="flash.events.Event")]
	
	public class AcSlider extends Sprite
	{
		private const AUTO_HIDE_TIMEOUT:int = 1000;
		
		protected var spot:Sprite;
		protected var back:Sprite;
		protected var fore:Sprite;		
		protected var tip:Sprite;
		protected var sensingHeight:int = 12;
		
		private var tipAnimate:TweenLite;
		
		private var _position:Number = 0;
		
		private var tipEnable:Boolean;
		
		protected var isDragging:Boolean = false;
		
		private var min:Number = 0;
		private var max:Number = 1;
		
		public function AcSlider(spot:Sprite=null,back:Sprite=null,fore:Sprite=null,tipEnable:Boolean=true,tipSprite:Sprite=null)
		{
			super();
			
			//设置默认素材
			var slider:Slider = new Slider();
			this.spot = spot || slider.spot2;
			this.back = back || slider.back;
			this.fore = fore || slider.prog;			
			this.spot.y = this.back.height / 2;			
			addChild(this.back);
			addChild(this.fore);
			addChild(this.spot);
			
			this.tipEnable = tipEnable;
			if (this.tipEnable)
			{
				tip = tipSprite || new VolumeTip();
				tip.mouseEnabled = tip.mouseChildren = false;
				tip.visible = false;
				addChild(tip);
			}
			
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		}
		
		/**
		 * 滑块位置 （0~1） 
		 * 
		 */
		public function get position():Number
		{
			return min + _position * (max - min);
		}
		
		public function set position(value:Number):void
		{
			if (!isDragging)
			{
				if (value < min) value = min;
				if (value > max) value = max;
				
				_position = (value - min) / (max - min);
				
				fore.width = spot.x = back.width * _position;
			}
		}
		
		protected function onMouseDown(event:MouseEvent):void
		{
//			if (stage && isIn() && (!event || (!(event.target is CellRenderer) && !(event.target is BaseButton))))
			if (true)
			{
				if (mouseX <= back.width && mouseX >= 0) spot.x = mouseX;
				onMouseMove(event);
				
				spot.startDrag(true,new Rectangle(0,spot.y,back.width,0));
				stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
				isDragging = true;	
			}
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			var p:Number = spot.x / back.width;
			if (p < 0) p = 0;
			if (p > 1) p = 1;
			
			_position = p;
			fore.width = back.width * _position;
			
			if (tipEnable) 
			{
				showTip();
			}
			
			if (event) event.updateAfterEvent();			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			spot.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);			
			isDragging = false;
			setTimeout(function():void{
				tip.visible = false;			
			},AUTO_HIDE_TIMEOUT);
		}
		
		public function setWidth(w:int):void
		{
			back.width = w;
			position = _position;
			drawSensingRange(sensingHeight);
		}
		
		public function setHeight(h:int):void
		{
			back.height = h;
			fore.height = h;
			spot.y = back.height / 2;
			drawSensingRange(sensingHeight);
		}
		
		protected function getTipString():String
		{
			return int(position*100+0.5) + "%";
		}
		
		private var autoHideSeed:uint;
		public function showTip(msg:String=null,autoHide:Boolean=false,x:Number=NaN,y:Number=NaN):void
		{
			if (isNaN(x))
			{
				var rect:Rectangle = spot.getRect(this);
				x = rect.x + 3;
				y = rect.y - 5;
			}
			
			if (x < 0) x = 0;
			if (x > back.width) x = back.width;
			if (tipAnimate) tipAnimate.kill();			
			tip["tf"].text = msg?msg:getTipString();			
			tip.visible = true;			
			tipAnimate = TweenLite.to(tip,0.3,{x:x,y:y});
			tip["tf"].dispatchEvent(new Event(Event.CHANGE));
			
			clearTimeout(autoHideSeed);
			if (autoHide)
			{
				autoHideSeed = setTimeout(function():void{
					tip.visible = false;			
				},AUTO_HIDE_TIMEOUT);
			}
		}
		
		public function setRange(min:Number,max:Number):void
		{
			this.min = min;
			this.max = max;
		}
		
		protected function drawSensingRange(sensingHeight:int):void
		{
			//感应范围
			this.graphics.clear();
			this.graphics.beginFill(0,0);
			this.graphics.drawRect(0,-(sensingHeight-this.back.height)/2,this.back.width,sensingHeight);
			this.graphics.endFill();
		}
	}
}