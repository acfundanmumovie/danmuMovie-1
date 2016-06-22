package com.acfun.PlayerSkin.component
{
	import com.acfun.External.ConstValue;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	
	import fl.core.UIComponent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class AcRatePanel extends RatePanel
	{
		private static const DISABLE_COLOR:uint = 0xe3e3e3;
		private static const OVER_COLOR:uint = 0x000000;
		private static const SELECTED_COLOR:uint = 0x3a9bd9;
		private static const NORMAL_COLOR:uint = 0x8a8c8a;
		
		private var itemArray:Array;
		private var rates:Array;
		private var rateStr:Array;
		
		public var rate:int;
		
		public function AcRatePanel()
		{
			super();
			
			addEventListener(MouseEvent.CLICK,function(event:MouseEvent):void{
				event.stopImmediatePropagation();
			});
			addEventListener(MouseEvent.ROLL_OUT,function():void{
				visible = false;
			});
			
			itemArray = [r0,r1,r2,r3];
			var tformat:TextFormat = new TextFormat("微软雅黑",14,NORMAL_COLOR);
			for each (var item:MovieClip in itemArray)
			{
				item["tf"].defaultTextFormat = tformat;
				item.mouseChildren = false;
				setDisable(item);
			}
		
			register(SIGNALCONST.SET_PLAYER_RATE_CHANGED,onSetRate);
		}
		
		private function onSetRate(rate:int,rates:Array,rateStr:Array):void
		{
			this.rates = rates;
			this.rate = rate;
			this.rateStr = rateStr;
			refresh();
		}
		
		protected function onClick(event:MouseEvent):void
		{
			rate = itemArray.indexOf(event.currentTarget);			
			refresh();
			notify(SIGNALCONST.SET_PLAYER_RATE,rate);
		}
		
		private function setDisable(item:MovieClip):void
		{
			item.removeEventListener(MouseEvent.CLICK,onClick);
			item.removeEventListener(MouseEvent.ROLL_OVER,onOver);
			item.removeEventListener(MouseEvent.ROLL_OUT,onOut);
			setColor(item,DISABLE_COLOR);
		}
		
		private function setSelected(item:MovieClip):void
		{
			item.removeEventListener(MouseEvent.CLICK,onClick);
			item.removeEventListener(MouseEvent.ROLL_OVER,onOver);
			item.removeEventListener(MouseEvent.ROLL_OUT,onOut);
			setColor(item,SELECTED_COLOR);
		}
		
		private function setNormal(item:MovieClip):void
		{
			item.addEventListener(MouseEvent.CLICK,onClick);
			item.addEventListener(MouseEvent.ROLL_OVER,onOver);
			item.addEventListener(MouseEvent.ROLL_OUT,onOut);
			setColor(item,NORMAL_COLOR);
		}
		
		protected function onOut(event:MouseEvent):void
		{
			setColor(event.currentTarget as MovieClip,NORMAL_COLOR);
		}
		
		protected function onOver(event:MouseEvent):void
		{
			setColor(event.currentTarget as MovieClip,OVER_COLOR);
		}
		
		private function setColor(item:MovieClip,color:uint):void
		{
			var tf:TextField = item["tf"];
			var format:TextFormat = tf.defaultTextFormat;
			format.color = color;
			tf.setTextFormat(format);
			
			//蛋疼的chrome这样设置颜色对设备文本无效！！
//			var colorT:ColorTransform = new ColorTransform();
//			colorT.color = color;
//			item.transform.colorTransform = colorT;
		}
		
		private function refresh():void
		{
			if (rates && rates.length > 0)
			{
				for (var i:int=0;i<itemArray.length;i++)
				{
					var item:MovieClip = itemArray[i] as MovieClip;
					item["tf"].text = rateStr[i];
					if (rate == i)
						setSelected(item);
					else if (rates.indexOf(i) == -1)
						setDisable(item);
					else
						setNormal(item);
				}
			}
		}
	}
}