package com.acfun.color
{
	public class TudouColor implements IColor
	{
		private var DISABLE_COLOR:uint = 0xf56900;
		private var OVER_COLOR:uint = 0x4d4d4d;
		private var SELECTED_COLOR:uint = 0xf56900;
		private var NORMAL_COLOR:uint = 0xbababa;
		private var RateColor:uint = 0xbababa;
		
		private var CellRenderFormatColor:uint = 0xc0c0c0 ;
		private var CellRenderFilterColor:uint = 0xc0c0c0 ;
		
		private var TCreaterColor:uint = 0xc0c0c0;
		
		private var CommentTFColor:uint = 0xc0c0c0;
		
		private var FaceTextColor:uint = 0xc0c0c0;
		public function TudouColor()
		{
		}
		public function getColor(colorName:String):uint
		{
			return this[colorName];
		}
	}
}