package com.acfun.PlayerSkin.Pad
{
	import com.acfun.External.PARAM;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.PlayerSkin.SkinConfig;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	
	import fl.data.DataProvider;
	import fl.events.ListEvent;
	
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	public class CommentPad extends Sprite
	{
		public var cmtGrid:CommentGrid;
		public var title:titleBtn;
		private var _commentVolume:Number = 0;
		private var _commentSum:Number = 0;
		private var _commentLocked:Number = 0;
		private var _commentPrepared:Boolean = false;
		
		private var _commentTF:commentSumShow = new commentSumShow();
		
		public function CommentPad()
		{
			super();
			init();
		}
		private function init():void {
			title = new titleBtn();
			title.info.text = "正在获取在线人数...";			
			cmtGrid = T_Creater.gridCreate([["timeStr","text"],["时间","评论"],[60,300]],null,false,true);
			cmtGrid.getColumnAt(0).sortCompareFunction = timeStrCompare;
			cmtGrid.getColumnAt(0).sortDescending = true;
			cmtGrid.getColumnAt(1).sortDescending = true;
			cmtGrid.getColumnAt(1).labelFunction = function(item:SingleCommentData):String {
				return item.text.split(/\r|\n/,1)[0];
			};
			cmtGrid.dataProvider = new DataProvider();
			cmtGrid.rowHeight = 24;
			
//			cmtGrid.blendMode = BlendMode.DARKEN;
			
			var tf:TextFormat = new TextFormat("微软雅黑", 12, 0x333333);
			cmtGrid.setRendererStyle("textFormat", tf);
			
			//显示弹幕数
			_commentTF.x = SkinConfig.RIGHT_WIDTH;
			_commentTF.tf.text = "正在获取弹幕...";
			cmtGrid.addChild(_commentTF);
			 
			
			// 填充弹幕列表的空白
//			for(var i:Number=0; i < void_danmaku_num; i++) {
//				var n:Object = new Object();
//				cmtGrid.dataProvider.addItemAt(n,0);
//			}
			
			addChild(title);
//			var loader:Loader = new Loader();
//			loader.load(new URLRequest("ac2.jpg"));
//			loader.alpha = 0.8;
//			addChild(loader);
			addChild(cmtGrid);			
			cmtGrid.y = title.height;
			cmtGrid.height = 388;
			cmtGrid.width = 334;
			cmtGrid.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onItem2Click);
			
			setupRightClick();
			
			register(SIGNALCONST.COMMENT_NEW_COMMENT, insertCmtList);
			register(SIGNALCONST.COMMENT_PREPARED, commentVolume);
			register(SIGNALCONST.COMMENT_ONLINE_NUMBER,showOnlineNum);
			register(SIGNALCONST.COMMENT_LOCATION,commentLocation);
			register(SIGNALCONST.COMMENT_DELETE,commentDelete);
			register(SIGNALCONST.COMMENT_DELETE_BY_USER,commentDeleteByUser);
			register(SIGNALCONST.PAD_REFRESH,padRefresh);
		}
		
		private function padRefresh():void
		{
			cmtGrid.invalidateList();
		}
		
		private function timeStrCompare(s1:SingleCommentData,s2:SingleCommentData):int
		{
			if (s1.stime > s2.stime)
				return -1;
			else if (s1.stime < s2.stime)
				return 1;
			else
				return 0;
		}
		
		private function commentDeleteByUser(user:String):void
		{
			for each (var item:SingleCommentData in cmtGrid.dataProvider.toArray())
			{
				if (item.user == user)
					cmtGrid.removeItem(item);
			}
			showCmtInfo();
		}
		
		private function commentDelete(items:Array):void
		{
			for each (var item:SingleCommentData in items)
			{
				cmtGrid.removeItem(item);
			}
			showCmtInfo();
		}
		
		private function commentLocation(s:SingleCommentData):void
		{
			cmtGrid.selectedItem = s;
			cmtGrid.scrollToSelected();
		}
		
		private function showOnlineNum(num:uint):void
		{
			title.info.text = "当前在线人数：" + num;
		}
		
		/**
		 * 弹幕列表弹幕双击事件
		 * 跳到弹幕发送的时间 
		 * @param event
		 * 
		 */
		protected function onItem2Click(event:ListEvent):void
		{
			var cmt:SingleCommentData = event.item as SingleCommentData;
			if(cmt) {
				notify(SIGNALCONST.SET_POSITION_CHANGE, cmt.stime);
			}
			
		}
		public function insertCmtList(cmt:SingleCommentData):void {
//			if(cmt.mode == SingleCommentData.FIXED_POSITION_AND_FADE || cmt.filterType != 0)	{
//				cmtGrid.dataProvider.addItem(cmt);				
//			} else {			
//				cmtGrid.dataProvider.addItemAt(cmt,0);
//			}
			if (_commentPrepared && cmt.mode != SingleCommentData.FIXED_POSITION_AND_FADE)
				cmtGrid.dataProvider.addItemAt(cmt,0);
			else
				cmtGrid.dataProvider.addItem(cmt);			
			cmt.isLock?_commentLocked++:_commentSum++
			showCmtInfo();
			
			if (PARAM.acInfo.isLive)
			{
				if (cmtGrid.dataProvider.length > 20000)
				{
					for (var i:int=0;i<2000;i++)
						cmtGrid.dataProvider.removeItemAt(cmtGrid.dataProvider.length-1);
				}
			}
		}
		public function commentVolume(baka:Object):void
		{
			_commentPrepared = true;
			_commentVolume = baka.size;
			showCmtInfo();
		}
		private function showCmtInfo():void 
		{
			_commentTF.tf.text = "当前弹幕数：" + (_commentSum + _commentLocked);
		}
		private function setupRightClick():void
		{
			var ct:ContextMenu = new ContextMenu();
			ct.hideBuiltInItems();
			ct.addEventListener(ContextMenuEvent.MENU_SELECT,onContextMenuSelected);
			cmtGrid.contextMenu = ct;			
		}
		
		private function onContextMenuSelected(e:ContextMenuEvent):void
		{
			var pointer:SingleCommentData = cmtGrid.selectedItem as SingleCommentData;
			
			if (pointer)
			{
				var nar:Array = [];
				var textCMI:ContextMenuItem = new ContextMenuItem('--复制内容>> '+ pointer.text.substr(0,20) + (pointer.text.length > 20 ? '...' : ''));
				textCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void
				{	
					System.setClipboard(pointer.text);
				});
				nar.push(textCMI);
				var userCMI:ContextMenuItem = new ContextMenuItem('--复制用户>> '+ pointer.user);
				userCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void
				{	
					System.setClipboard(pointer.user);
				});
				nar.push(userCMI);
				var dateCMI:ContextMenuItem = new ContextMenuItem('--复制时间>> '+ pointer.date);
				dateCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void
				{	
					System.setClipboard(pointer.date);
				});
				nar.push(dateCMI);
//				var filterCMI:ContextMenuItem = new ContextMenuItem('--屏蔽用户>> '+ pointer.user);
//				filterCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void
//				{	
//					notify(SIGNALCONST.COMMENT_USER_BLOCK,pointer.user);
//				});
//				nar.push(filterCMI);
				var reportCMI:ContextMenuItem = new ContextMenuItem('--屏蔽并举报>> '+ pointer.user);
				reportCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void
				{	
					notify(SIGNALCONST.COMMENT_REPORT,pointer);
				});
				nar.push(reportCMI);
				if (PARAM.userInfo.isAdmin || PARAM.userInfo.isUp)
				{
					var deleteCMI:ContextMenuItem = new ContextMenuItem('--删除弹幕>> '+ pointer.text.substr(0,20) + (pointer.text.length > 20 ? '...' : ''));
					deleteCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void
					{	
						notify(SIGNALCONST.COMMENT_DELETE,cmtGrid.selectedItems);						
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
				
				var mn:ContextMenu = e.target as ContextMenu;
				mn.customItems = nar;
			}
		}
	}
}