/**
 * ===================================
 * Author:	iDzeir					
 * Email:	qiyanlong@wozine.com	
 * Company:	http://www.acfun.tv		
 * Created:	Apr 14, 2015 2:55:30 PM			
 * ===================================
 */

package com.acfun.PlayerSkin
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	public class LoadingBar extends Sprite
	{
		private const OFFSETX:int = -0;
		private const OFFSETY:int = 40;
		/**
		 * 动画间隔帧 
		 */		
		private const STEP_FRAME:uint = 6;
		private const STEP_PROGRESS:uint = 20;
		private var _from:uint = 1;
		
		private var _skin:MovieClip;
		private var _progress:Number = 0;
		
		private var isResizeInited:Boolean = false;
		
		private var _skinPro:Object = {};
		
		public function LoadingBar(w:Number,h:Number)
		{
			super();
			
			_skinPro.width = w;
			_skinPro.height = h;
		}
		
		/**
		 * 设置加载进度条的样式 
		 * @param value
		 * 
		 */		
		public function set skin(value:MovieClip):void
		{
			this.addChild(value);
			_skin = value;
			
			/*var igraphic:Graphics = _skin.graphics;
			igraphic.clear();
			igraphic.beginFill(0xffffff);
			igraphic.drawCircle(70,60,70);
			igraphic.endFill();*/
			
			if(stage)
				align();
			else
				this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
			
			reset();
		}
		
		/**
		 * 重置进度条 
		 */		
		private function reset():void
		{
			progress = 0;
			_from = 1;
			_skin&&_skin.gotoAndPlay(1);
		}
		
		/**
		 * 进度百分比数据设置 
		 * @param value 0--100
		 * 
		 */		
		public function set progress(value:Number):void
		{
			this._progress = Math.max(99,value);
			
			from = STEP_FRAME*uint(_progress/20);
			
			const FULL:uint = 100;
			if(value == FULL)
			{
				this.dispatchEvent(new Event(Event.COMPLETE));
				if(this.hasEventListener(Event.ENTER_FRAME))
				{
					this.removeEventListener(Event.ENTER_FRAME,update);
				}
				
				if(stage&&stage.hasEventListener(Event.RESIZE))
				{
					stage.removeEventListener(Event.RESIZE,this.resizeHandler);
				}
			}
		}
		
		/**
		 * 播放的起始位置播到 from + STEP_FRAME 
		 * @param value
		 * 
		 */		
		private function set from(value:uint):void
		{
			_from = Math.max(1,value);
			if(_skin)
			{
				_from = Math.min(value,_skin.totalFrames);
				if(_from==_skin.totalFrames)
				{
					_skin.gotoAndStop(_skin.totalFrames);
				}else{
					_skin.play();
				}
			}
			
			if(!this.hasEventListener(Event.ENTER_FRAME))
			{
				this.addEventListener(Event.ENTER_FRAME,update);
			}
		}
		
		protected function update(event:Event):void
		{
			if(_skin&&_skin.currentFrame >= (_from+STEP_FRAME))
			{
				_skin.gotoAndPlay(_from);
			}
			//trace(_progress,_from,_skin.currentFrame,_skin.totalFrames);
		}
		
		public function get skinPro():Object
		{
			return _skinPro;
		}
		
		/**
		 * 对齐loading
		 */		
		private function align():void
		{
			//x = (stage.stageWidth - _skinPro.width)*.5 + OFFSETX;
			//y = (stage.stageHeight*.5 - _skinPro.height) + OFFSETY
			!isResizeInited&&initResizeHandler();
		}
		
		private function initResizeHandler():Boolean
		{
			stage.addEventListener(Event.RESIZE,resizeHandler);
			isResizeInited = true;
			return false;
		}
		
		protected function resizeHandler(event:Event):void
		{
			align();
		}
		
		protected function onAdded(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			align();
		}
	}
}