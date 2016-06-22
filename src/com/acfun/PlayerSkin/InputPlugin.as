package com.acfun.PlayerSkin
{
	import com.acfun.External.SIGNALCONST;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;

	public class InputPlugin extends InputBar
	{
		public function InputPlugin()
		{
			super();
			alart.visible = false;
			sendBtn.addEventListener(MouseEvent.CLICK, onSendClick);
			input.addEventListener(KeyboardEvent.KEY_UP,onEnter);
		}
		
		protected function onEnter(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ENTER)
				onSendClick(null);
		}
		
		protected function onSendClick(event:MouseEvent):void
		{
			input.text;
			notify(SIGNALCONST.COMMENT_SEND_SIMPLE, input.text);
			input.text = '';
		}
		public function resize(w:Number, h:Number = 0):void
		{
			this.y += 1;
			mm.width = w - ll.width*2;
			rr.x = mm.x +　mm.width;
			sendBtn.x = rr.x - 32;
			input.width = sendBtn.x - input.x - 5;
		}
	}
}