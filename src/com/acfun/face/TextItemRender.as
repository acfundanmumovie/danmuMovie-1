package com.acfun.face
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class TextItemRender extends Sprite
	{
		public var text:TextField
		public function TextItemRender(value:String)
		{
			super();
			this.graphics.beginFill(0xFF0000,0);
			this.graphics.drawRect(0,0,FaceText.FACE_WIDTH,40);
			this.graphics.endFill();
			
			text = new TextField();
			text.y = 0;
			text.height = 20;
			text.text = value;
			text.mouseEnabled = false;
			this.addChild(text);
			text.x = (FaceText.FACE_WIDTH -text.textWidth)/2;
			
			text.y = (40-text.textHeight)/2;
//			trace(text.x + "__" + text.y);
		}
	}
}