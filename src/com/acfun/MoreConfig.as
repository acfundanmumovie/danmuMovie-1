package com.acfun
{
	import com.acfun.more.AcConfigPad;
	import com.acfun.more.AcFilterPad;
	
	import fl.controls.Button;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.Security;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	[SWF(frameRate="60",width="500",height="350",backgroundColor="#ffffff")]
	public class MoreConfig extends Sprite
	{
		private var confButton:Button;
		private var filterButton:Button;
		private var hotKeyButton:Button;
		
		private var confpad:AcConfigPad; 
		private var filterpad:AcFilterPad;
		private var hotKeypad:HotKeyPad;
		
		private var container:Sprite;
		
		public function MoreConfig(isOut:Boolean=true,panelIndex:int=0)
		{
			super();
			
			if (isOut)
			{
				//独立swf
				
//				Security.allowDomain("*");
//				Security.allowInsecureDomain("*");
				
				if (stage)
				{
					stage.scaleMode = StageScaleMode.NO_SCALE;
					stage.align = StageAlign.TOP_LEFT;
				}
			}
			else
			{
				//嵌入播放器
				var close:CloseButton = new CloseButton();				
				close.x = 470;
				close.y = 15;
				close.addEventListener(MouseEvent.CLICK,onClose);
				addChild(close);
				
				this.addEventListener(MouseEvent.CLICK,function(event:MouseEvent):void{ event.stopImmediatePropagation(); });
//				this.addEventListener(MouseEvent.MOUSE_MOVE,function(event:MouseEvent):void{ event.stopImmediatePropagation(); });
				this.addEventListener(MouseEvent.ROLL_OVER,function(event:MouseEvent):void{ Mouse.cursor = MouseCursor.AUTO; });
			}
			
			//绘制背景
			this.graphics.lineStyle(0,0,0);
			this.graphics.beginFill(0xffffff,0.9);
			this.graphics.drawRoundRect(0,0,500,350,3,3);
			this.graphics.endFill();
			this.scrollRect = new Rectangle(0,0,500,350);
			
			container = new Sprite();
			container.x = container.y = 15;
			this.addChild(container);
			
			confButton = new Button();
			confButton.mouseChildren = false;
			confButton.buttonMode = true;
			confButton.label = "播放器设置";
			confButton.toggle = true;
			confButton.addEventListener(MouseEvent.CLICK,function():void{ switchPanel(0); });
			
			filterButton = new Button();
			filterButton.mouseChildren = false;
			filterButton.label = "屏蔽与过滤";
			filterButton.toggle = true;
			filterButton.addEventListener(MouseEvent.CLICK,function():void{ switchPanel(1); });
			filterButton.x = 120;
			
			hotKeyButton = new Button();
			hotKeyButton.mouseChildren = false;
			hotKeyButton.label = "快捷键说明";
			hotKeyButton.toggle = true;
			hotKeyButton.addEventListener(MouseEvent.CLICK,function():void{ switchPanel(2); });
			hotKeyButton.x = 240;
			
			container.addChild(confButton);
			container.addChild(filterButton);
			container.addChild(hotKeyButton);
			
			confpad = new AcConfigPad(); 
			filterpad = new AcFilterPad();
			hotKeypad = new HotKeyPad();			
			confpad.visible = filterpad.visible = hotKeypad.visible = false;
			confpad.y = filterpad.y = hotKeypad.y = 35;
			
			container.addChild(confpad);
			container.addChild(filterpad);
			container.addChild(hotKeypad);
			
			switchPanel(panelIndex);
		}
		
		protected function onClose(event:MouseEvent):void
		{
			if (stage.contains(this))
			{
				stage.removeChild(this);
			}
		}
		
//		private function confPadShow(b:Boolean,tag:Object = null):void
//		{confpad.visible = b;}
//		
//		private function filterPadShow(b:Boolean,tag:Object = null):void
//		{filterpad.visible = b}
	
		private function switchPanel(index:int):void
		{
			var btf1:TextFormat = new TextFormat(null,13,0xffffff);
			var btf2:TextFormat = new TextFormat(null,13,0x3a9bd9);
			
			if (index == 0)
			{
				confButton.selected = true;
				confpad.visible = true;
				confButton.setStyle("textFormat",btf1);
				
				filterButton.selected = false;
				filterpad.visible = false;
				filterButton.setStyle("textFormat",btf2);
				
				hotKeyButton.selected = false;
				hotKeypad.visible = false;
				hotKeyButton.setStyle("textFormat",btf2);
			}
			
			if (index == 1)
			{
				confButton.selected = false;
				confpad.visible = false;
				confButton.setStyle("textFormat",btf2);
				
				filterButton.selected = true;
				filterpad.visible = true;
				filterButton.setStyle("textFormat",btf1);
				
				hotKeyButton.selected = false;
				hotKeypad.visible = false;
				hotKeyButton.setStyle("textFormat",btf2);
			}
			
			if (index == 2)
			{
				confButton.selected = false;
				confpad.visible = false;
				confButton.setStyle("textFormat",btf2);
				
				filterButton.selected = false;
				filterpad.visible = false;
				filterButton.setStyle("textFormat",btf2);
				
				hotKeyButton.selected = true;
				hotKeypad.visible = true;
				hotKeyButton.setStyle("textFormat",btf1);
			}
		}
	}
}