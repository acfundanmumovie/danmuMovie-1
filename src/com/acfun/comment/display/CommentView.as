package com.acfun.comment.display
{
	import com.acfun.External.PARAM;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.comment.CommentPlugin;
	import com.acfun.comment.communication.CommentHandler;
	import com.acfun.comment.control.CommentTime;
	import com.acfun.comment.entity.CommentConfig;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.interfaces.IComment;
	import com.acfun.comment.interfaces.ICommentManager;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	import com.adobe.utils.StringUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.getTimer;
	
	public class CommentView extends Sprite
	{
		private var _id:String = 'commentview';
		private static var _instance:CommentView = null;
		private var _cmtresize:Boolean = false;
		private var _clip:CommentLayer; 							// 真正的显示层  
		
		private var cmtConfig:CommentConfig;
		private var _managers:Vector.<ICommentManager>;
		private var _timeLine:CommentTime;
		private var _rootMenu:Array = null;
		
		public var currentTime:Number = 0;
		
		public var commentReady:Boolean = false;
		
		//右键菜单
		//		private var deleteMenu:ContextMenuItem;
		//		private var reportMenu:ContextMenuItem;
		
		private var _lastUpdateTime:Number = 0;
		
		public function CommentView()
		{
			//初始化弹幕显示层
			_clip = new CommentLayer();
			cmtConfig = CommentConfig.instance;
			_managers = new Vector.<ICommentManager>();
			_timeLine = CommentTime.instance;
			_timeLine.setclip(_clip);
			for (var i:int = 0;i < _timeLine.managers.length;i++)				
			{_managers.push(_timeLine.managers[i]);}
			
			register(SIGNALCONST.COMMENT_CLEAR,clearComment);
			register(SIGNALCONST.SET_POSITION_CHANGE,function():void{
				if (!PARAM.acInfo.isLive)
					clearComment(); 
			});
		}
		
		public static function get instance():CommentView
		{
			if(_instance == null)
			{
				_instance = new CommentView();
			}
			return _instance;
		}
		
		public function set cmtresize(b:Boolean):void {_cmtresize = b;resize(0,0);}
		
		public function clearComment(exp:String=""):void	
		{
			var key:String,value:String;
			if (exp && exp.length>0)
			{
				if (StringUtil.beginsWith(exp,"u="))
				{
					key = "user";
					value = StringUtil.remove(exp,"u=");
				}
				
				if (StringUtil.beginsWith(exp,"i="))
				{
					key = "index";
					value = StringUtil.remove(exp,"i=");
				}
			}
			
			var cc:Vector.<IComment> = CommentTime.instance.getCurrentComments();			
			if (key)
			{
				var temp:Vector.<IComment> = new Vector.<IComment>();
				for each (var c:IComment in cc)
				{
					if (key && c.item[key].toString() == value)
						temp.push(c);
				}
				cc = temp;
			}
			
			var l:int = cc.length;
			for (var i:int=0;i<l;i++)
			{
				cc[0].doComplete();
			}
		}
		
		public function initPlugin(commentId:String,vlength:int,highAccuracy:Boolean):void
		{
			this.addChild(_clip);
			
			//显示弹幕
			showComment = true;			
			//劫持右键菜单
			//setupRightClick();
			
			// --- 初始化收发器			
			CommentHandler.instance.init(commentId,vlength);
			
			if (highAccuracy)
			{
				addEventListener(Event.ENTER_FRAME,onEnterFrame);
			}
		}
		
		protected function onEnterFrame(event:Event):void
		{
			if (_lastUpdateTime > 0 && _playing && cmtConfig.visible)
			{
				_timeLine.time(currentTime + (getTimer() - _lastUpdateTime)/1000);
			}
		}
		
		private function setupRightClick():void
		{
			/*var ct:ContextMenu = new ContextMenu();
			ct.hideBuiltInItems();
			ct.addEventListener(ContextMenuEvent.MENU_SELECT,onContextMenuSelected);
			this.contextMenu = ct;*/
		}
		
		private function onContextMenuSelected(e:ContextMenuEvent):void
		{
			var p:Point = new Point(_clip.stage.mouseX,_clip.stage.mouseY);
			var nar:Array = [];
			var current:Vector.<IComment> = CommentTime.instance.getCurrentComments();
			var hits:Vector.<IComment> = current.filter(function callback(item:DisplayObject, index:int, array:*):Boolean{
				return item.hitTestPoint(p.x,p.y);  
			});
			
			if (hits.length > 0)
			{
				var pointer:IComment = hits[0];
				
				if (PARAM.acInfo.isLive)
				{
					var userCMI:ContextMenuItem = new ContextMenuItem('--复制用户>> '+ pointer.user);
					userCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void
					{
						System.setClipboard(pointer.user);
					});
					nar.push(userCMI);	
				}
				
				var copyCMI:ContextMenuItem = new ContextMenuItem('--复制>> '+ pointer.innerText.substr(0,20) + (pointer.innerText.length > 20 ? '...' : ''));
				copyCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void
				{
					System.setClipboard(pointer.innerText);
				});
				nar.push(copyCMI);
				
				//				var filterCMI:ContextMenuItem = new ContextMenuItem('--屏蔽用户>> ' + pointer.user + ' ('+ pointer.innerText.substr(0,5) + '...');
				//				filterCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void
				//				{
				//					pointer.doComplete();
				//					CommentHandler.instance.blockUser(pointer.user);
				//				});
				//				nar.push(filterCMI);
				
				var reportCMI:ContextMenuItem = new ContextMenuItem('--屏蔽并举报>> ' + pointer.user + ' ('+ pointer.innerText.substr(0,5) + '...');
				reportCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void
				{
					var cmi:SingleCommentData = pointer.item;
					if(cmi != null)
					{
						pointer.doComplete();
						CommentHandler.instance.report(cmi);
					}
				});
				nar.push(reportCMI);
				
				if (PARAM.userInfo.isAdmin || PARAM.userInfo.isUp)
				{
					var deleteCMI:ContextMenuItem = new ContextMenuItem('--删除弹幕>> ' + pointer.innerText.substr(0,20) + (pointer.innerText.length > 20 ? '...' : ''));
					deleteCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void{
						notify(SIGNALCONST.COMMENT_DELETE,[pointer.item]);
					});
					nar.push(deleteCMI);
					
					var deleteAllByUserCMI:ContextMenuItem = new ContextMenuItem('--删除该用户所有弹幕>> ' + pointer.user);
					deleteAllByUserCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void{
						notify(SIGNALCONST.COMMENT_DELETE_BY_USER,pointer.user);
					});
					nar.push(deleteAllByUserCMI);
					
					if (PARAM.userInfo.isAdmin)
					{
						var lockAllByUserCMI:ContextMenuItem = new ContextMenuItem('--锁定该用户所有弹幕>> ' + pointer.user);
						lockAllByUserCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void{
							notify(SIGNALCONST.COMMENT_LOCK_BY_USER,pointer.user);
						});
						nar.push(lockAllByUserCMI);	
					}
				}
				
				for each (var c2:IComment in hits)
				{
					var locationCMI:ContextMenuItem = new ContextMenuItem('--定位弹幕>>(' + c2.item.index + ")" + c2.innerText.substr(0,20) + (c2.innerText.length > 20 ? '...' : ''));
					locationCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void{
						notify(SIGNALCONST.COMMENT_LOCATION,_timeLine.getcomment(event.target.caption.match(/>>\((\d*)\)/)[1]));
					});
					nar.push(locationCMI);
				}
				
				//plugin version
				var version:ContextMenuItem = new ContextMenuItem(CommentPlugin.COMMENT_PLUGIN_VERSION,true,false);
				nar.push(version);
			}
			
			var mn:ContextMenu = e.target as ContextMenu;
			mn.customItems = nar;
		}
		
		public function get showComment():Boolean
		{
			return _clip.visible;
		}
		
		public function set showComment(i:Boolean):void
		{
			_clip.visible = i;
		}
		
		public function time(time:Number):void
		{
			if (currentTime != time)
			{
				currentTime = time;
				if(cmtConfig.visible == false){	return; }			
				_timeLine.time(currentTime);
				_lastUpdateTime = getTimer();
			}
		}
		
		private var _playing:Boolean = true;
		
		public function get playing():Boolean
		{
			return _playing;
		}
		
		public function set playing(value:Boolean):void
		{
			if (_playing != value)
			{
				_playing = value;
				
				if (!PARAM.acInfo.isLive)
				{
					var i:int;
					var current:Vector.<IComment> = CommentTime.instance.getCurrentComments();
					for(i = 0; i < current.length; i++)
					{
						if (value)
						{
							current[i].resume();
						}
						else
						{
							current[i].pause();	
						}
					}	
				}
				
				if (_playing)
					_lastUpdateTime = getTimer();
			}
		}
		
		private var _cwidth:Number = 976;
		private var _cheight:Number = 550;
		public function resize(width:Number=0, height:Number=0):void
		{
			var w:Number;
			var h:Number;
			if (width > 0 && height > 0)
			{
				w = width;
				h = height;
			}
			else
			{
				w = _cwidth;
				h = _cheight;
			}
			
			//保存原始宽高
			_cwidth = w;
			_cheight = h;
			
			if (CommentConfig.instance.subtitle_protect)
			{
				h = h * (1 - CommentConfig.instance.subtitle_protect_percent);
			}
			
			if(!_cmtresize)
			{
				for each(var manager:ICommentManager in _managers)
				{manager.resize(w,h);}
				
			}
			else
			{
				var i:int;
				var hs:Number = h;
				h = h/20*17;
				for(i = 0;i<4;i++)
				{(_managers[i] as ICommentManager).resize(w,h);}
				for(i = 4;i<_managers.length;i++)
				{(_managers[i] as ICommentManager).resize(w,hs);}
			}
			
			var s:Rectangle = new Rectangle(0,0,w,h);
			resetCmtfontResize(w,h);			
			_clip.scrollRect = s;
		}
		
		public function resetCmtfontResize(w:int = -1,h:int = 0):void
		{
			//			if(w < 0){w = player.controls.display.width;h = player.controls.display.height;}
			//			if(w == cmtConfig.width){$.cmtfontResize = 1}
			//			else if(w){$.cmtfontResize = cmtConfig.height/h}
		}
		
		//		private function seekHandler(evt:MediaEvent):void
		//		{
		//			var cc:Array = new Array();
		//			for(var i:int = 0; i < _clip.numChildren; i++)
		//			{
		//				var c:DisplayObject = _clip.getChildAt(i);
		//				if(c is IComment){cc.push(c);}
		//			}
		//			for each(var cs:IComment in cc)
		//			{IComment(cs).doComplete();}
		//		}
		
		public function get id():String				{return _id;}
		public function get cmtalpha():Number			
		{
			return _clip.normal.alpha;
		}
		public function set cmtalpha(a:Number):void	
		{
			_clip.normal.alpha = a;
		}
		public function get clip():CommentLayer
		{
			return _clip;
		}
	}
}


