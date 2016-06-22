//package com.acfun.comment.control.manager.base
//{
//	import com.acfun.External.PARAM;
//	import com.acfun.Utils.Log;
//	import com.acfun.comment.control.CommentTime;
//	import com.acfun.comment.control.space.base.CommentSpaceManager;
//	import com.acfun.comment.display.CommentView;
//	import com.acfun.comment.display.base.Comment;
//	import com.acfun.comment.entity.CommentConfig;
//	import com.acfun.comment.entity.SingleCommentData;
//	import com.acfun.comment.event.CommentDataEvent;
//	import com.acfun.comment.interfaces.IComment;
//	import com.acfun.comment.interfaces.ICommentManager;
//	
//	import flash.display.DisplayObject;
//	import flash.display.Sprite;
//	
//	public class CommentManager implements ICommentManager
//	{
//		private var clip:Sprite;
//		private var config:CommentConfig;
//		protected var space_manager:CommentSpaceManager;
//		
//		/**
//		 *当前屏幕上的评论量 
//		 */
//		public var commentCount:uint = 0;
//		
//		public function CommentManager(s:Sprite)
//		{
////			clip = new Sprite();
////			clip.mouseEnabled = false;
////			clip.mouseChildren = false;
////			s.addChild(clip);
//			clip = s;
//			config = CommentConfig.instance;
//			this.setSpaceManager();
//			this.setModeList();
//		}
//		
//		/**
//		 * 设置要监听的模式
//		 **/
//		protected function setModeList():void
//		{
//			/** 因为本类管理顶部字幕,所以监听TOP消息 **/
//			CommentTime.instance.mode_list.push(CommentDataEvent.TOP);
//		}
//		
//		/**
//		 * 设置空间管理者
//		 **/
//		protected function setSpaceManager():void
//		{
//			this.space_manager = new CommentSpaceManager();
//		}
//		
//		
//		public function start(data:SingleCommentData,from:Number=0):void
//		{
//			/** 在终结前不再被渲染 **/
//			data.on = true; 
////			if (data.display == null)
////				data.display = getComment(data);
////			var cmt:IComment = data.display;
//			var cmt:IComment = getComment(data);
//			CommentTime.instance.addToCurrent(cmt);
//			Log.info("产生弹幕"+cmt.item.text);
//			cmt.complete = function():void {
//				Log.info("移除弹幕"+cmt.item.text);
//				if(cmt){
//					cmt.item.text =""
//					Log.info("空置弹幕"+cmt.item.text);
//				}
//				//////////
//				CommentTime.instance.removeFromCurrent(cmt);
//				complete(data);
//				removeFromSpace(cmt);
//				clip.removeChild(DisplayObject(cmt));
//				commentCount --;
//				cmt.complete = null;
//			};
//			commentCount ++;
//			add2Space(cmt);
//			/** 添加到舞台 **/
//			clip.addChild(DisplayObject(cmt));
//			cmt.start(from);
////			if(!PARAM.acInfo.isLive && !CommentView.instance.playing && data.border && data.addon==null)
////			{
////				cmt.pause();
////			}
//		}
//		
//		protected function add2Space(cmt:IComment):void
//		{
//			this.space_manager.add(Comment(cmt));
//		}
//		
//		/**
//		 * 空间回收
//		 **/
//		protected function removeFromSpace(cmt:IComment):void
//		{
//			this.space_manager.remove(Comment(cmt));
//		}
//		
//		/**
//		 * 获取弹幕对象
//		 * @param	data 弹幕数据
//		 * @return 弹幕呈现方法对象
//		 */
//		public function getComment(data:SingleCommentData):IComment
//		{
//			return new Comment(data);
//		}
//		
//		/**
//		 * 当一个弹幕完成播放动作时调用
//		 * @param	data 弹幕数据信息
//		 */
//		protected function complete(data:SingleCommentData):void
//		{
//			data.on = false;
//		}
//		
//		/**
//		 * 更改Manager的宽高参数,这些参数影响了弹幕的位置与大小
//		 * @param	width 宽度
//		 * @param	height 高度
//		 */
//		public function resize(width:Number, height:Number):void
//		{
//			this.space_manager.setRectangle(width,height);
//		}     
//	}
//}

///////////////////
package com.acfun.comment.control.manager.base
{
	import com.acfun.External.ConstValue;
	import com.acfun.External.PARAM;
	import com.acfun.Utils.Log;
	import com.acfun.comment.control.CommentTime;
	import com.acfun.comment.control.space.base.CommentSpaceManager;
	import com.acfun.comment.display.CommentView;
	import com.acfun.comment.display.base.Comment;
	import com.acfun.comment.entity.CommentConfig;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.event.CommentDataEvent;
	import com.acfun.comment.interfaces.IComment;
	import com.acfun.comment.interfaces.ICommentManager;
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class CommentManager implements ICommentManager
	{
		private var clip:Sprite;
		private var config:CommentConfig;
		protected var space_manager:CommentSpaceManager;
		////////////////
		private var _count:uint =0; 
		private var _writeDataText:String ="";
		public static var _inDanMu:Boolean =false;//正式弹幕还是预制弹幕
		private var _setDanMuZ:Boolean = false;//弹幕Z坐标是正还是负，true则Z坐标为正
		private var _dmCount:int = 0;//记录屏幕弹幕数量
		public static var _getStageHeight:int =0;
		///////////////
		/**
		 *当前屏幕上的评论量 
		 */
		public var commentCount:uint = 0;
		
		public function CommentManager(s:Sprite)
		{
//			clip = new Sprite();
//			clip.mouseEnabled = false;
//			clip.mouseChildren = false;
//			s.addChild(clip);
			clip = s;
			config = CommentConfig.instance;
			this.setSpaceManager();
			this.setModeList();
		}
		
		/**
		 * 设置要监听的模式
		 **/
		protected function setModeList():void
		{
			/** 因为本类管理顶部字幕,所以监听TOP消息 **/
			CommentTime.instance.mode_list.push(CommentDataEvent.TOP);
		}
		
		/**
		 * 设置空间管理者
		 **/
		protected function setSpaceManager():void
		{
			this.space_manager = new CommentSpaceManager();
		}
		
		///////////////////
		private function timeHandle(e:TimerEvent):void{
			_count++;
		}
		
		public function star2(data:SingleCommentData,from:Number=0):void
		{
			data.on = true; 
		}
		//////////////////
		
		public function start(data:SingleCommentData,from:Number=0):void
		{
			/** 在终结前不再被渲染 **/
			data.on = true; 
			
			////////////////////////
			//_count =0;
			//
			//var timer1:Timer = new Timer(1000);
			//timer1.addEventListener(TimerEvent.TIMER,timeHandle);
			//timer1.start()
			//trace("--A:_writeDataText:"+_writeDataText+";data.text:"+data.text)
			//if(_count<10)
			//{
			//	if(_writeDataText ==data.text.toString())
			//	{
			//		trace("短期相同表情不发")
			//	}
			//	else
			//	{
			//		trace("--D")
			//		var cmt:IComment = getComment(data);
			//		CommentTime.instance.addToCurrent(cmt);
			//		Log.info("产生弹幕"+cmt.item.text);
			//		cmt.complete = function():void {
			//			Log.info("移除弹幕"+cmt.item.text);
			//			if(cmt){
			//				cmt.item.text =""
			//				Log.info("空置弹幕"+cmt.item.text);
			//			}
			//			CommentTime.instance.removeFromCurrent(cmt);
			//			complete(data);
			//			removeFromSpace(cmt);
			//			clip.removeChild(DisplayObject(cmt));
			//			commentCount --;
			//			cmt.complete = null;
			//		};
			//		commentCount ++;
			//		add2Space(cmt);
			//		//添加到舞台 
			//		clip.addChild(DisplayObject(cmt));
			//		cmt.start(from);
			//	}
			//}
			//else
			//{
			//	trace("--B")
			//	cmt = getComment(data);
			//	CommentTime.instance.addToCurrent(cmt);
			//	Log.info("产生弹幕"+cmt.item.text);
			//	cmt.complete = function():void {
			//		Log.info("移除弹幕"+cmt.item.text);
			//		if(cmt){
			//			cmt.item.text =""
			//			Log.info("空置弹幕"+cmt.item.text);
			//		}
			//		CommentTime.instance.removeFromCurrent(cmt);
			//		complete(data);
			//		removeFromSpace(cmt);
			//		clip.removeChild(DisplayObject(cmt));
			//		commentCount --;
			//		cmt.complete = null;
			//	};
			//	commentCount ++;
			//	add2Space(cmt);
			//	//添加到舞台 
			//	clip.addChild(DisplayObject(cmt));
			//	cmt.start(from);
			//}
			//_writeDataText = data.text.toString();
			//trace("--_writeDataText:"+_writeDataText)
			///////////////////////
			
			var cmt:IComment = getComment(data);
			///////////////////设置弹幕3D感觉
			var mm:DisplayObject = DisplayObject(cmt);
			
				if(_getStageHeight !=0)
				{
					//trace("mmHeight:"+mm.height+";lines:"+Math.floor(_getStageHeight/mm.height))
					var dmLines:int = Math.floor(_getStageHeight/mm.height)
					if(_dmCount> dmLines*2)
					{
						//trace("add 3D_Z")
						
						mm.z = Math.random()* ConstValue.SINGALDANMU_Z;
					}
				}
			
			/*if(_setDanMuZ){
				_setDanMuZ = false;
				mm.z = Math.random()*200;
			}else{
				_setDanMuZ = true;
				mm.z = Math.random()* -200;
			}*/
			
			////////////////////
			CommentTime.instance.addToCurrent(cmt);
			//Log.info("产生弹幕"+cmt.item.text);
			//trace("产生弹幕"+cmt.item.text)
			_dmCount++;
			cmt.complete = function():void {
				//Log.info("移除弹幕"+cmt.item.text);
				//trace("移除弹幕"+cmt.item.text)
				_dmCount--;
				
				CommentTime.instance.removeFromCurrent(cmt);
				complete(data);
				removeFromSpace(cmt);
				clip.removeChild(DisplayObject(cmt));
				commentCount --;
				cmt.complete = null;
			};
			
			/////////////////给测试弹幕加延迟显示
			//trace("--_inDanMu:"+_inDanMu)
			if(_inDanMu)//预制弹幕
			{
					var exampleSprite:Sprite = new Sprite();
					var delayNum:Number = Math.ceil(Math.random() *10);
					
					if(commentCount<10)
					{
						commentCount ++;
						TweenLite.to(exampleSprite,0.1,{visible:true,delay:delayNum,onComplete:function(){add2Space(cmt);clip.addChild(DisplayObject(cmt));cmt.start(from);}});
					}
			}
			else//用户发送弹幕
			{
				//commentCount ++;
				add2Space(cmt);
				//添加到舞台 
				clip.addChild(DisplayObject(cmt));
				cmt.start(from);
			}
			//////////////////
		}
		
		protected function add2Space(cmt:IComment):void
		{
			this.space_manager.add(Comment(cmt));
		}
		
		/**
		 * 空间回收
		 **/
		protected function removeFromSpace(cmt:IComment):void
		{
			this.space_manager.remove(Comment(cmt));
		}
		
		/**
		 * 获取弹幕对象
		 * @param	data 弹幕数据
		 * @return 弹幕呈现方法对象
		 */
		public function getComment(data:SingleCommentData):IComment
		{
			return new Comment(data);
		}
		
		/**
		 * 当一个弹幕完成播放动作时调用
		 * @param	data 弹幕数据信息
		 */
		protected function complete(data:SingleCommentData):void
		{
			data.on = false;
		}
		
		/**
		 * 更改Manager的宽高参数,这些参数影响了弹幕的位置与大小
		 * @param	width 宽度
		 * @param	height 高度
		 */
		public function resize(width:Number, height:Number):void
		{
			this.space_manager.setRectangle(width,height);
		}     
	}
}