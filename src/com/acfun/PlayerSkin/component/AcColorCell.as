package com.acfun.PlayerSkin.component
{
	import flash.display.Sprite;
	
	public class AcColorCell extends Sprite
	{
		public var color:uint;
		
		public function AcColorCell(color:uint,width:int,height:int)
		{
			super();
			
			this.color = color;
			this.buttonMode = true;
			this.mouseChildren = false;
			this.opaqueBackground = 0xffffff;
			this.cacheAsBitmap = true;
			
			graphics.lineStyle(0.1);
			graphics.beginFill(color);
			graphics.drawRect(0,0,width,height);
		}
	}
}