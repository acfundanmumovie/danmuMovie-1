package com.acfun.comment.display.base
{
	import com.acfun.comment.entity.CommentConfig;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.interfaces.IComment;
	import com.acfun.comment.utils.CommentFilter;
	import com.acfun.External.ConstValue;
	
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;

	public class Comment extends SimpleCommentEngine implements IComment
	{
		/** 持续时间 **/
		public var duration:Number;
		public var sendDuration:Number;
		
		/**
		 * 完成地调用的函数,无参数
		 */
		protected var _complete:Function;
		/** 配置数据 **/
		private var _item:SingleCommentData;
		/** 空间分配索引,记录所占用的弹幕空间层 **/
		protected var _index:int;
		/** 底部位置,为减少计算 **/
		protected var _bottom:int;
		/** 时计 **/
		protected var _tm:Timer;
		
		/**
		 * 构造方法
		 * @param	data 弹幕数据信息
		 */
		public static var repeatfilter:Boolean = false;
		public static const repeatfilterfree:int = 8;
		public static const splitlength:int = 8;
		
		/**
		 * 构造Text显示顺序
		 * flase正常显示，true反转显示
		 */
		//public var _textOrder:Boolean =false;
		
		public function Comment(data:SingleCommentData) 
		{
			_item = data;
			
			var _size:int = data.size;
			var _broder:Boolean = true;
			if(_size > 99)
			{
				_broder = false;
				_size -= 100;
			}
			
			var text:String = data.text;
			//trace("--_textOrder:"+_textOrder+";ConstValue.DIRECT:"+ConstValue.DIRECT)
			if(ConstValue._getTextOrder)
			{
				text = text.split("").reverse().join("");
			}
				
			repeatfilter = CommentFilter.getInstance().bRepfiliter;
			
			var filter:Array;
			var config:CommentConfig = CommentConfig.instance;
			if(_broder)
			{
				if(item.color == 0)
				{
					filter = [new GlowFilter(16777215, 1, 2,2,1.5,1)];
					//这个滤镜是不是应该加在this下的弹幕sp中?
				}
				else 
					filter = config.filter;
			}
			
			super(config.font, config.sizee * _size, data.color, config.bold,(data.border ? 0x66FFFF : -1),text,filter,false);
			
			this.cacheAsBitmap = true;
			
			
			
		}
		
		public function testFun(qwe:String ="ss"):void
		{
			trace("---qwe:"+qwe)
		}
		
		private var _py:int = 0;
		/**
		 * 设置空间索引和y坐标
		 **/
		public function setY(py:int,idx:int,trans:Function):void
		{
			this._py = py;
			this.y = trans(py,this);
			this._index = idx;
			this._bottom = py + this.height + 2;
		}
		
		override public function get y():Number
		{
			// TODO Auto Generated method stub
			return _py;
		}
		
		
		/** 
		 * 空间索引读取,在移除出空间时被空间管理者使用
		 **/
		public function get index():int
		{
			return this._index;
		}
		
		/**
		 * 底部位置,在空间检验时用到
		 **/
		public function get bottom():int
		{
			return this._bottom;
		}
		
		/**
		 * 右边位置
		 **/
		
		public function get right():int
		{
			return this.x + this.width;
		}
		
		/**
		 * 开始时间
		 **/
		public function get stime():Number
		{
			return this.item.stime;
		}
		
		/**
		 * 初始化,由构造函数最后调用
		 */
		
		/**
		 * 恢复播放
		 */
		public function resume():void
		{
			this._tm.start();
		}
		
		/**
		 * 暂停
		 */
		public function pause():void
		{
			this._tm.stop();
		}
		
		/**
		 * 开始播放
		 */
		public function start(from:Number=0):void
		{
			this._tm = new Timer(250,10);
			this._tm.addEventListener(TimerEvent.TIMER_COMPLETE,function (e:TimerEvent):void{completeHandler()});
			this._tm.start();
		}
		
		/**
		 * 时计结束事件监听
		 */
		public function completeHandler():void
		{
			this._complete();
		}
		
		/**
		 * 设置完成播放时调用的函数,调用一次仅一次
		 * @param	foo 完成时调用的函数,无参数
		 */
		public function set complete(foo:Function):void
		{
			this._complete = foo;
		}
		
		public function doComplete():void
		{
			this._tm.stop();
			this._tm.removeEventListener(TimerEvent.TIMER_COMPLETE,completeHandler);
			completeHandler();
		}
		
		public function get innerText():String
		{
			return _item.text;
		}
		
		public function get user():String
		{
			return _item.user;
		}
		public function get item():SingleCommentData
		{
			return _item;
		}
		
	}
}