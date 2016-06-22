package com.acfun.PlayerSkin.Pad
{
	import com.acfun.External.SIGNALCONST;
	import com.acfun.signal.notify;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	// 也许应该把浙西东西都丢到数组里，但考虑到效率也就懒得优雅&可拓展了
	public class RadioManager extends BiliBili
	{
		public const BILI_0:Number = 0;
		public const BILI_16_9:Number = 1;
		public const BILI_4_3:Number = 2;
		public const BILI_FULL:Number = 3;
		private var elements:Vector.<MovieClip>;
		private var strs:Array;
		private var funcs:Array;
		private var _state:Number=0;
		public function RadioManager():void {
			super();
			elements = new Vector.<MovieClip>;
			elements.push(origin);
			elements.push(origin1);
			elements.push(p169);
			elements.push(p1691);
			elements.push(p43);
			elements.push(p431);
			elements.push(full);
			elements.push(full1);
			strs = ['默认', '4:3','16:9', '填充'];
			funcs = [on0Clk, on169Clk, on43Clk, onFullClk];
			for(var i:Number=0; i<elements.length; i++) {
				elements[i].buttonMode = true;
				var j:Number = Math.floor(i/2);
				elements[i].text.text = strs[j];
				elements[i].addEventListener(MouseEvent.CLICK, funcs[j]);
			}
			origin.visible = p1691.visible = p431.visible = full1.visible = false;
		}
		private function loveBilibili(id:Number):void {
			if(id != _state) {
				trace(_state);
				notify(SIGNALCONST.SET_PLAYER_RATIO, id);
				elements[_state*2].visible = true;
				elements[_state*2+1].visible = false;
				_state = id;
				switch(id) {
					case 0:
						origin.visible = false;
						origin1.visible = true;
						break;
					case 1:
						p169.visible = false;
						p1691.visible = true;
						break;
					case 2:
						p43.visible = false;
						p431.visible = true;
						break;
					case 3:
						full.visible = false;
						full1.visible = true;
						break;
					default:
						break;
				}
			}
		}
		protected function on0Clk(event:MouseEvent):void {
			loveBilibili(0);
		}
		protected function on169Clk(event:MouseEvent):void {
			loveBilibili(1);
		}
		protected function on43Clk(event:MouseEvent):void {
			loveBilibili(2);
		}
		protected function onFullClk(event:MouseEvent):void {
			loveBilibili(3);
		}
	}
}