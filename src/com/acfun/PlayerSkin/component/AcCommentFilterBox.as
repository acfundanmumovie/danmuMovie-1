package com.acfun.PlayerSkin.component
{
	import com.acfun.PlayerSkin.SkinConfig;
	import com.acfun.Utils.Util;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	[Event(name="change", type="flash.events.Event")]
	
	public class AcCommentFilterBox extends CommentFilterBox
	{
		private var changeEvent:Event = new Event(Event.CHANGE);
		
		public function get blockGuest():Boolean
		{
			return c0.selected;
		}

		public function set blockGuest(value:Boolean):void
		{
			c0.selected = value;
			c0.dispatchEvent(changeEvent);
		}

		public function get blockAll():Boolean
		{
			return c1.selected;
		}

		public function set blockAll(value:Boolean):void
		{
			c1.selected = value;
			c1.dispatchEvent(changeEvent);
		}
		
		public function AcCommentFilterBox()
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
		}
		
		protected function onClick(event:MouseEvent):void
		{
			dispatchEvent(changeEvent);
			event.stopPropagation();
		}
		
		public function hide(event:MouseEvent=null):void
		{
			this.visible = false;
		}
	}
}