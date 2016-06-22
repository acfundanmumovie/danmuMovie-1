package com.acfun.comment.control
{
	import com.acfun.External.ConstValue;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	import com.acfun.comment.control.manager.BottomCommentManager;
	import com.acfun.comment.control.manager.FixedPosCommentManager;
	import com.acfun.comment.control.manager.RScrollCommentManager;
	import com.acfun.comment.control.manager.RScrollGifManager;
	import com.acfun.comment.control.manager.ScriptCommentManager;
	import com.acfun.comment.control.manager.ScrollCommentManager;
	import com.acfun.comment.control.manager.base.CommentManager;
	import com.acfun.comment.display.CommentLayer;
	import com.acfun.comment.display.CommentView;
	import com.acfun.comment.entity.CommentType;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.interfaces.IComment;
	import com.acfun.comment.utils.CommentFilter;
	import com.acfun.signal.notify;
	
	import flash.events.Event;
	
	public class CommentTime
	{
		private static var _instance:CommentTime = null;
		private var timeLine:Vector.<SingleCommentData> = new Vector.<SingleCommentData>();
		private var currentComments:Vector.<IComment> = new Vector.<IComment>();
		private var position:Number;
		private var oldPosition:Number = -1;
		private var commentFilter:CommentFilter;
		public var mode_list:Array = [];
		public var pointer:int = 0;
		//public var prepare_stack:Vector.<IComment> = new Vector.<IComment>();		
		public var managers:Vector.<CommentManager> = new Vector.<CommentManager>(6);
		private var gif:RScrollGifManager;
		/** 自定义过滤函数（执行特殊要求的过滤）  **/
		public var customValidate:Function;
		
		public static function get instance():CommentTime
		{
			if(_instance == null){_instance = new CommentTime()};
			return _instance;
		}
		
		public function setclip(clip:CommentLayer):void
		{
			managers[0] = new CommentManager(clip.normal);				//顶
			managers[1] = new BottomCommentManager(clip.normal);		//低
			managers[2] = new ScrollCommentManager(clip.normal);		//滚
			managers[3] = new RScrollCommentManager(clip.normal);		//逆
			managers[4] = new FixedPosCommentManager(clip.special);		//特
			managers[5] = new ScriptCommentManager(clip.special);		//代
			managers[6] = new RScrollGifManager(clip.special);		//代
			gif = managers[6] as RScrollGifManager;
		}
		
		public function clear():void
		{
			timeLine = new Vector.<SingleCommentData>();
			pointer = 0;
			oldPosition = -1;
		}
		
		public function restartLine():void
		{
			timeLine = new Vector.<SingleCommentData>();
		}
		
		public function CommentTime()
		{
			if(_instance != null){throw new Error("该对象只能存在一个,请改用getInstance()获取");}
			//timeLine = new TreeInt();
			commentFilter = CommentFilter.getInstance();
			var run:Function = Util.runOnceIn(1000,validateAll);
			commentFilter.addEventListener(Event.CHANGE,run);
		}
		
		private function validateAll():void
		{
			for each (var s:SingleCommentData in timeLine)
			{
				s.validate();
			}
			notify(SIGNALCONST.PAD_REFRESH);
			Log.debug(this,"validateAll");
		}
		
		public function insert(data:SingleCommentData):void
		{
			/*
			* 拷贝副本
			*/
			data.on = false;
			/*
			* 如果带有边框,则立即呈现播放
			*/
			if (data.border) 
			{
				start(data);
				//推移时间头，注意时间控制
				oldPosition = CommentView.instance.currentTime + 0.1;
			}
			
			//带有preview属性则不插入时间轴，已存在则不要重复插♂入
			if (!data.preview && timeLine.indexOf(data) == -1)
			{
				/*
				* 得到插入位置
				*/
				//红黑树查找
				var p:int = Util.bsearch(this.timeLine, data, function(a:*, b:*):Number {
					if (a.stime < b.stime) 
					{
						return -1;
					}
					else
						if (a.stime > b.stime)
						{
							return 1;
						}
						else 
						{
							if (a.date < b.date)
							{
								return -1;
							}
							else if (a.date > b.date)
							{
								return 1;
							} 
							else 
							{
								return 0;
							}
						}
				});
				
				this.timeLine.splice(p, 0, data);
				if (data.stime <= this.position)
				{
					this.pointer++;
				}
			}
			//start_all();
			//假如弹幕过多，则应当删除以前的(已经于CCenter实现。)
		}
		
		public function delcomment(index:int):void
		{
			var i:int = searchCmt(index);
			if(i>=0){timeLine.splice(i,1);}
		}
		
		public function getcomment(index:int):SingleCommentData
		{
			var i:int = searchCmt(index);
			if(i>=0){return (timeLine[i]);}
			return null;
		}
		
		public function searchCmt(index:int):int
		{
			var i:int = timeLine.length-1;
			var data:SingleCommentData;
			for (;i>=0;i--)
			{
				data = timeLine[i];
				if(data != null && data.index == index)	{return i;}
			}
			return -1;
		}
		
		protected function seek(position:Number):void
		{
			this.pointer = Util.bsearch(this.timeLine, position, function(pos:*, data:*):Number 
			{
				if (pos < data.stime)		{return -1;}
				else if(pos > data.stime)	{return 1;}
				else						{return 0;}
			});			
		}
		protected function getData(index:int):SingleCommentData
		{
			if (index >= 0 && index < this.timeLine.length) 
			{
				return this.timeLine[index];
			}
			return null;
		}
		
		public function time(position:Number):void
		{
			this.position = position - 0.001;
			
			//if (this.pointer == this.timeLine.length || Math.abs(this.oldPosition - position) >= 2) {
			if (Math.abs(this.oldPosition - this.position) >= 2) {
				Log.info("jump",oldPosition,position);
				
				//				CommentView.instance.clearComment();
				
				this.seek(this.position);
				
				//高级弹幕处理
				for (var i:int=0;i<pointer;i++) 
				{
					var s:SingleCommentData = getData(i);
					if (s.mode == SingleCommentData.FIXED_POSITION_AND_FADE)
					{
						var start:Number = this.position - s.stime;
						if (start < s.specialDuration)
						{
							this.start(s,start);
						}	
					}
				}
			}
			this.oldPosition = this.position;
			
			if (this.timeLine.length <= this.pointer)
			{
				return;
			}
			
			for (; this.pointer < this.timeLine.length; this.pointer++ ) {
				if (this.getData(this.pointer)['stime'] <= this.position) 
				{
					//if (this.validate(this.getData(this.pointer)))
					//{						
					this.prepareStart(this.getData(this.pointer));
					//}
				}
				else 
				{
					break;
				}
			}
		}
		
		private function prepareStart(s:SingleCommentData):void
		{
			if (customValidate != null && !customValidate(s)) { return; }
			if (!s.border && !s.preview && s.filterType!=0){return;}
			if (validate(s))	{s.preview = false; start(s);}
		}
		private static function validate(data:SingleCommentData):Boolean
		{
			if (data['on'])	{return false;}
			return true;
			//return _filter.validate(data);
		}
		/*
		private function start_all():void
		{
		if($.isPlaying)
		{
		while(prepare_stack.length)
		{
		var cmt:IComment = prepare_stack.pop();
		cmt.start();
		}            
		}
		else
		{
		while(prepare_stack.length)
		{
		cmt = prepare_stack.pop();
		cmt.start();
		// 暂停时发送的弹幕,在显示后立即暂停
		cmt.pause();
		}            
		}
		}
		*/
		public function start(obj:SingleCommentData,from:Number=0):void
		{
			obj.mode = ConstValue.DIRECT == ConstValue.RIGHT?CommentType.FLOW_RIGHT_TO_LEFT:CommentType.FLOW_LEFT_TO_RIGHT;
			getCm(obj).start(obj,from);
		}
		
		public function start1(obj:SingleCommentData,from:Number=0):void{
			gif.start(obj,from);
		}
		
		public function getCm(obj:SingleCommentData):CommentManager
		{
			//0,顶 1,低 2,滚 3,逆 4,特 5,代
			var cm:CommentManager;
			switch(obj.mode)
			{
				case '1':
					cm = managers[2];
					break;
				case '2':
					cm = managers[2];
					break;
				case '3':
					cm = managers[2];
					break;
				case '4':
					cm = managers[1];
					break;
				case '5':
					cm = managers[0];
					break;
				case '6':
					cm = managers[3];
					break;
				case '7':
					cm = managers[4];
					break;
				case '10':
					cm = managers[5];
					break;
				default:
					cm = managers[2];
					break;
			}
			return cm;
		}
		
		public function getAllComments():Vector.<SingleCommentData>
		{
			return timeLine;
		}
		
		public function getCurrentComments():Vector.<IComment>
		{
			return currentComments;
		}
		
		public function addToCurrent(c:IComment):void
		{
			var i:int = currentComments.indexOf(c);			
			if (i == -1)
				currentComments.push(c);
			else
				currentComments.splice(i,1,c)[0].doComplete();
		}
		
		public function removeFromCurrent(c:IComment):void
		{
			var i:int = currentComments.indexOf(c);
			if (i != -1)
			{
				currentComments.splice(i,1);
			}
		}
	}
}


