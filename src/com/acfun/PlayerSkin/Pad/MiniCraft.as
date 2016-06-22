package com.acfun.PlayerSkin.Pad
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * 其实相当于一个MovieClip 
	 * 需要背景可拉伸，但信息处于中间
	 * @author QB
	 * 
	 */
	public class MiniCraft extends Sprite
	{
		public var back:MovieClip;
		public var info:MovieClip;
		public function MiniCraft(info:MovieClip, back:MovieClip)
		{
			super();
			this.back = back;
			this.info = info;
			this.addChildAt(back,0);
			this.addChildAt(info,1);
		}
		public function resize(w:Number, h:Number):void {
			back.height = h;
			info.y = h / 2;
		}
	}
}