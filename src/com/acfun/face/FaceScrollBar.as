package com.acfun.face
{
	import fl.controls.ScrollBar;
	import fl.events.ComponentEvent;
	
	import flash.events.MouseEvent;
	
	public class FaceScrollBar extends ScrollBar
	{
		public function FaceScrollBar()
		{
			super();
		}
		
		override protected function scrollPressHandler(arg0:ComponentEvent):void
		{
			// TODO Auto Generated method stub
			super.scrollPressHandler(arg0);
			arg0.stopPropagation();
		}
		
		override protected function handleThumbDrag(arg0:MouseEvent):void
		{
			// TODO Auto Generated method stub
		
			super.handleThumbDrag(arg0);
			arg0.stopPropagation();
		}
		
		override protected function thumbPressHandler(arg0:MouseEvent):void
		{
			// TODO Auto Generated method stub
			super.thumbPressHandler(arg0);
			arg0.stopPropagation();
		}
		
		override protected function thumbReleaseHandler(arg0:MouseEvent):void
		{
			// TODO Auto Generated method stub
			super.thumbReleaseHandler(arg0);
			arg0.stopPropagation();
		}
		
		
	}
}