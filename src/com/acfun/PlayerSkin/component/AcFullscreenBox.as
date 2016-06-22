package com.acfun.PlayerSkin.component
{
	import com.acfun.External.AcConfig;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.PlayerSkin.SkinConfig;
	import com.acfun.Utils.Util;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	
	import fl.controls.RadioButton;
	
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[Event(name="change", type="flash.events.Event")]
	
	public class AcFullscreenBox extends FullscreenBox
	{
		private var changeEvent:Event = new Event(Event.CHANGE);
		
		public function get webFullscreen():Boolean
		{
			return c0.selected;
		}

		public function set webFullscreen(value:Boolean):void
		{
			c0.selected = value;
			c0.dispatchEvent(changeEvent);
		}

		public function get desktopFullscreen():Boolean
		{
			return c1.selected;
		}

		public function set desktopFullscreen(value:Boolean):void
		{
			c1.selected = value;
			c1.dispatchEvent(changeEvent);
			
			
		}
		
		public function AcFullscreenBox()
		{
			super();
			
			initComponent();
		}
		
		private function initComponent():void
		{
			Util.bindComponent(c0,t0,SkinConfig.SELECTED_COLOR);
			Util.bindComponent(c1,t1,SkinConfig.SELECTED_COLOR);			
			addEventListener(MouseEvent.ROLL_OUT,hide);
			addEventListener(MouseEvent.CLICK,onClick);
			addEventListener(MouseEvent.MOUSE_DOWN,function(event:MouseEvent):void{ event.stopImmediatePropagation(); });
			
			register(SIGNALCONST.SET_WEB_FULLSCREEN_CHANGE,onWebFs);
			register(SIGNALCONST.SET_DESKTOP_FULLSCREEN_CHANGE,onFs);
		}
		
		private function onFs(isFs:Boolean):void
		{
			desktopFullscreen = isFs;
		}
		
		private function onWebFs(isWebFs:Boolean):void
		{
			webFullscreen = isWebFs;
		}
		
		protected function onClick(event:MouseEvent):void
		{
			var target:Object = event.target;
			
			if (target == c0 || target == t0)
			{
				var c0s:Boolean = c0.selected;				
				desktopFullscreen = false;
				webFullscreen = false;
				notify(SIGNALCONST.SET_WEB_FULLSCREEN_CHANGE, c0s);
				
				dispatchEvent(changeEvent);
				
				hide();
			}
			
			if (target == c1 || target == t1)
			{
				var c1s:Boolean = c1.selected;				
				desktopFullscreen = false;
				webFullscreen = false;
				stage.displayState = c1s?(AcConfig.getInstance().fullscreen_input?"fullScreenInteractive":StageDisplayState.FULL_SCREEN):StageDisplayState.NORMAL;
				
				dispatchEvent(changeEvent);
				
				hide();
			}
			
			event.stopPropagation();
		}
		
		public function hide(event:MouseEvent=null):void
		{
			this.visible = false;
		}
	}
}