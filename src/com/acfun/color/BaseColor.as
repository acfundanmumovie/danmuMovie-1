package com.acfun.color
{
	public class BaseColor implements IColor
	{ 
		private var DISABLE_COLOR:uint = 0xe3e3e3;
		private var OVER_COLOR:uint = 0x000000;
		private var SELECTED_COLOR:uint = 0x3a9bd9;
		private var NORMAL_COLOR:uint = 0x8a8c8a;
		private var RateColor:uint = 0xFFFFFF;
		
		private var CellRenderFormatColor:uint = 3355443;
		private var CellRenderFilterColor:uint = 0xbbbbbb;
		
		private var TCreaterColor:uint = 0xffffff;
		private var CommentTFColor:uint = 0xffffff;
		private var FaceTextColor:uint = 0xffffff;
		public function BaseColor()
		{
		}
		
		public function getColor(colorName:String):uint{
			return this[colorName];
		}
	}
}