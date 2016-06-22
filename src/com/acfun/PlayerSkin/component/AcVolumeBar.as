package com.acfun.PlayerSkin.component
{
	import flash.display.Sprite;
	
	public class AcVolumeBar extends AcSlider
	{
		public function AcVolumeBar(spot:Sprite=null, back:Sprite=null, fore:Sprite=null, tipEnable:Boolean=true, tipSprite:Sprite=null)
		{
			tipSprite = tipSprite || new Tip();
			super(spot, back, fore, tipEnable, tipSprite);
			setHeight(4);
		}
		
		override protected function getTipString():String
		{
			if (position == 1)
			{
				return super.getTipString() + "(按↑键可继续放大音量至500%)";
			}
			else
			{
				return super.getTipString();	
			}
		}
	}
}

import flash.display.Sprite;
import flash.events.Event;
import flash.filters.BitmapFilterQuality;
import flash.filters.DropShadowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

class Tip extends Sprite
{
	public var tf:TextField;
	
	public function Tip()
	{
		tf = new TextField();
		tf.defaultTextFormat = new TextFormat("微软雅黑",12);
		tf.autoSize = TextFieldAutoSize.CENTER;
		tf.addEventListener(Event.CHANGE,onTextChange);
		addChild(tf);
		
		filters = [new DropShadowFilter(5,90,0,1,5,5,0.2,BitmapFilterQuality.HIGH)];		
	}
	
	protected function onTextChange(event:Event):void
	{
		tf.x = -tf.width / 2;
		tf.y = -tf.height;
		
		graphics.clear();
		graphics.beginFill(0xe9e9e9);
		graphics.drawRoundRect(-tf.width/2-2,-tf.height,tf.width+5,tf.height,10,10);
		graphics.endFill();
	}}