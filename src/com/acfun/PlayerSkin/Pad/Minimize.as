package com.acfun.PlayerSkin.Pad
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class Minimize extends MovieClip
	{
		private static const SKIN_UP:Number = 0;
		private static const SKIN_OVER:Number = 1;
		private static const SKIN_DOWN:Number = 2;
		private  var words:Array;	// 存内容容器
		private  var backs:Array;	// 存背景的容器
		public static var onAnimate:Boolean = false;
		/**
		 * 为了做到按钮相应的效果，需要不同的MiniCraft组合
		 */
		public  var states:Vector.<MiniCraft>;
		private var state:Number;
		
		/**
		 * 构造一个可拉伸，无失真的SimpleButton
		 * @param w 信息内容(MovieClip)的数组，居中
		 * @param b 背景内容(MovieClip)的数组，可拉伸
		 * 
		 */
		public function Minimize(w:Array, b:Array)
		{
			super();
			init(w, b);
		}
		private function init(w:Array, b:Array):void {
			words = w;
			backs = b;
			states = new Vector.<MiniCraft>;
			state = SKIN_UP;
			for(var i:Number=0; i<words.length; i++) {	
				// 初始化MiniCraft并压入Vector
				var t:MiniCraft = new MiniCraft(words[i], backs[i]);
				t.buttonMode = true;
				t.visible = false;
				states.push(t);
				addChild(states[i]);
			}
			states[SKIN_UP].visible = true;
			addEventListener(MouseEvent.ROLL_OUT, pup);
			addEventListener(MouseEvent.ROLL_OVER, pover);
		}
		private function pup(event:MouseEvent):void {
			// 模仿按钮的“弹起”关键帧
			states[SKIN_OVER].visible = false;
			states[SKIN_UP].visible = true;
			state = SKIN_UP;			
		}
		private function pover(event:MouseEvent):void {
			// 模仿按钮的“指针”关键帧
			states[SKIN_UP].visible = false;
			states[SKIN_OVER].visible = true;
			state = SKIN_OVER;			
		}
		public function onAnimate(flag:Boolean):void {
			if(!flag) {
				states[SKIN_OVER].addEventListener(MouseEvent.MOUSE_OUT, pup);
				states[SKIN_UP].addEventListener(MouseEvent.MOUSE_OVER, pover);
			} else {
				states[SKIN_OVER].addEventListener(MouseEvent.MOUSE_OUT, pup);
				states[SKIN_UP].addEventListener(MouseEvent.MOUSE_OVER, pover);
			}
		}
		
		/**
		 * 因为是纵向的，所以仅设置高度 
		 * @param w
		 * @param h
		 * 
		 */
		public function resize(w:Number, h:Number):void {
			for(var i:Number=0; i < words.length; i++) {
				states[i].resize(w, h);
			}
		}
	}
}