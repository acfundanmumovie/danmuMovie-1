package com.acfun.PlayerSkin.component
{
	import com.acfun.Utils.Util;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[Event(name="complete", type="flash.events.Event")]
	
	public class AcProgressBar extends AcSlider
	{
		public static const NORMAL_HEIGHT:int = 3;
		public static const OVER_HEIGHT:int = 8;
		
		protected var buffered:Sprite;		
		protected var _buffer:Number;
		
		public var totalTime:Number = 300;
		
		public function AcProgressBar(spot:Sprite=null,back:Sprite=null,fore:Sprite=null,buffered:Sprite=null,sensingHeight:int=30)
		{
			var material:ProgressDragBar = new ProgressDragBar();
			this.buffered = buffered || material.buffered;
			this.buffered.width = 0;
			addChild(this.buffered);
			super(material.spot,material.back,material.progressed,true,new TimeTip());
			swapChildren(this.buffered,this.back);
			this.spot.visible = false;
			this.sensingHeight = sensingHeight;			
			setHeight(NORMAL_HEIGHT);
						
			addEventListener(MouseEvent.ROLL_OUT,onOut);
			addEventListener(MouseEvent.ROLL_OVER,onOver);
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			addEventListener(Event.ADDED_TO_STAGE,function():void{
				stage.addEventListener(Event.MOUSE_LEAVE,onOut);
			});
		}
		
		protected function onOver(event:MouseEvent):void
		{
			setHeight(OVER_HEIGHT);		
			this.spot.visible = true;
			showTip();
			onMouseMove(null);
		}
		
		protected function onOut(event:Event):void
		{
			if (!isDragging)
			{
				setHeight(NORMAL_HEIGHT);				
				this.spot.visible = false;
				tip.visible = false;
			}
		}
		
		override public function setHeight(h:int):void
		{
			this.y = -h;
			buffered.height = h;
			super.setHeight(h);
		}
		
		override protected function onMouseUp(event:MouseEvent):void
		{
			onMouseMove(event);
			super.onMouseUp(event);
			dispatchEvent(new Event(Event.COMPLETE));
		}	

		public function get buffer():Number
		{
			return _buffer;
		}

		public function set buffer(value:Number):void
		{
			if (value < 0) value = 0;
			if (value > 1) value = 1;
			
			_buffer = value;
			buffered.width = back.width * value;
		}
		
		override protected function getTipString():String
		{
			var pos:Number = mouseX / back.width;
			if (pos < 0) pos = 0;
			if (pos > 1) pos = 1;
			return Util.digits(pos*totalTime);
		}
		
		override public function showTip(msg:String=null,autoHide:Boolean=false,x:Number=NaN,y:Number=NaN):void
		{
			if (isNaN(x))
			{
				var x:Number = mouseX;
				var y:Number = spot.y - 5;	
			}
			
			if (x < tip.width/2) x = tip.width/2;
			if (x > back.width - tip.width/2) x = back.width - tip.width/2;
			super.showTip(msg,autoHide,x, y);
		}
		
		override protected function drawSensingRange(sensingHeight:int):void
		{
			//感应范围
			this.graphics.clear();
			this.graphics.beginFill(0,0);
			this.graphics.drawRect(0,-(sensingHeight+y),this.back.width,sensingHeight);
			this.graphics.endFill();
		}
	}
}