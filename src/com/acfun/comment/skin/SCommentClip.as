package com.acfun.comment.skin
{
	import com.acfun.External.ConstValue;
	import com.acfun.External.LocalStorage;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.PlayerSkin.Pad.CommentGrid;
	import com.acfun.PlayerSkin.Pad.T_Creater;
	import com.acfun.Utils.Util;
	import com.acfun.comment.communication.CommentHandler;
	import com.acfun.comment.communication.CommentServerEvent;
	import com.acfun.comment.control.CommentTime;
	import com.acfun.comment.display.CommentLayer;
	import com.acfun.comment.display.CommentView;
	import com.acfun.comment.entity.CommentType;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.utils.CommentFilter;
	import com.acfun.comment.utils.CommentUtils;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	import com.adobe.utils.StringUtil;
	
	import fl.data.DataProvider;
	import fl.events.ListEvent;
	
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	
	public class SCommentClip extends SClip
	{
		private var _main:CommentSpecial;
		
		private var _filter:CommentFilter;
		
		private var cmtGrid:CommentGrid;
		
		private var isLock:Boolean = false;
		
		private var _beforeFilterConfig:String;
		
		public function SCommentClip(main:CommentSpecial)
		{
			super();
			
			_main = main;
			
			_filter = CommentFilter.getInstance();
			
			this.addEventListener(KeyboardEvent.KEY_UP,gridHotKey);
			
			//title.addEventListener(MouseEvent.CLICK, onTitleClick);
			cmtGrid = T_Creater.gridCreate([["timeStr","text","name"],["时间"," 评论","名称"],[52,160]]);
			cmtGrid.getColumnAt(0).sortCompareFunction = timeStrCompare;
			cmtGrid.getColumnAt(0).sortDescending = true;			
			cmtGrid.getColumnAt(1).sortDescending = true;			
			cmtGrid.getColumnAt(1).labelFunction = function(item:SingleCommentData):String {
				return item.text.split(/\r|\n/,1)[0];
			};
			cmtGrid.dataProvider = new DataProvider();
			
			cmtGrid.rowHeight = cmtGrid.rowHeight + 2;
			var tf:TextFormat = new TextFormat("SimSun", 12, 0x676979);
			cmtGrid.setRendererStyle("textFormat", tf);
			cmtGrid.dataProvider = new DataProvider();
			addChild(cmtGrid);
			cmtGrid.x = 15;
			cmtGrid.y = 121;
			cmtGrid.height = 340;
			cmtGrid.width = 280;
			cmtGrid.addEventListener(ListEvent.ITEM_DOUBLE_CLICK,onItemDClick);
			cmtGrid.addEventListener(ListEvent.ITEM_CLICK,onItemClick);
			
			var fix:ContextMenuItem = new ContextMenuItem("修改弹幕");
			fix.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onfix);
			var copy:ContextMenuItem = new ContextMenuItem("复制弹幕");
			copy.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,oncopy);
			var prw:ContextMenuItem = new ContextMenuItem("预览弹幕");
			prw.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onprw);
			//			var ftm:ContextMenuItem = new ContextMenuItem("调整时间");
			//			ftm.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onftm);
			var del:ContextMenuItem = new ContextMenuItem("删除弹幕");
			del.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,ondel);
			var sav:ContextMenuItem = new ContextMenuItem("导出弹幕");
			sav.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onsav);
			var jgt:ContextMenuItem = new ContextMenuItem("导入弹幕");
			jgt.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onjgt);
			var rsd:ContextMenuItem = new ContextMenuItem("补发弹幕");
			rsd.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onrsd);
			var contextMenu:ContextMenu = new ContextMenu();
			contextMenu.hideBuiltInItems();
			contextMenu.customItems = [fix,copy,prw,del,sav,jgt,rsd];
			cmtGrid.contextMenu = contextMenu; 
			//cmtGrid.contextMenu.removeEventListener(ContextMenuEvent.MENU_SELECT,onMenuSelected);
			cmtGrid.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT,function (e:Event):void
			{
				del.enabled = copy.enabled = prw.enabled = fix.enabled = rsd.enabled = (cmtGrid.selectedIndex >= 0);
				sav.enabled = (cmtGrid.dataProvider.length>0)
			});
			title.text.text = "发送列表";
			
			preview_self.addEventListener(MouseEvent.CLICK, onCheck);
			preview_special.addEventListener(MouseEvent.CLICK, onCheck);
			rollS.addEventListener(MouseEvent.CLICK, onCheck);
			topS.addEventListener(MouseEvent.CLICK, onCheck);
			bottomS.addEventListener(MouseEvent.CLICK, onCheck);
			apply_lock.addEventListener(MouseEvent.CLICK, onCheck);
			sendB.addEventListener(MouseEvent.CLICK, onClickSend);
			exitB.addEventListener(MouseEvent.CLICK,onExit);
			commond.addEventListener(KeyboardEvent.KEY_UP,onCommond);
			show_grid.addEventListener(MouseEvent.CLICK,onShowGrid);
			
			var txf:TextFormat = new TextFormat();
			txf.color = 0x676979;
			txf.size = 12;
			preview_self.setStyle("textFormat",txf);
			preview_special.setStyle("textFormat",txf);
			rollS.setStyle("textFormat",txf);
			topS.setStyle("textFormat",txf);
			bottomS.setStyle("textFormat",txf);
			apply_lock.setStyle("textFormat",txf);
			sendB.setStyle("textFormat", txf);
			exitB.setStyle("textFormat", txf);
			show_grid.setStyle("textFormat", txf);
			
			preview_self.selected = false;
			preview_special.selected = true;
			rollS.selected = false;
			topS.selected = false;
			bottomS.selected = false;
			apply_lock.selected = true;
			show_grid.selected = false;
			
			//恢复现场
			getSavedComment();
			
			register(SIGNALCONST.COMMENT_LOCATION,onCommentLocation);
		}
		
		protected function onShowGrid(event:MouseEvent):void
		{
			var clip:CommentLayer = CommentView.instance.clip;
			if (show_grid.selected)
			{
				clip.graphics.clear();
				
				var i:int = 0;
				var n:int = 10;
				var sw:Number = ConstValue.SPECIAL_MODE_PLAYER_WIDTH;
				var sh:Number = ConstValue.SPECIAL_MODE_PLAYER_HEIGHT - ConstValue.PLAYER_SKIN_DEFAULT_HEIGHT;
				var dx:Number = sw / n;
				var dy:Number = sh / n;
				clip.graphics.lineStyle(1,0x00ff00,0.8);
				for (i=1;i<n;i++)
				{
					clip.graphics.moveTo(i*dx,0);
					clip.graphics.lineTo(i*dx,sh);
					clip.graphics.moveTo(0,i*dy);
					clip.graphics.lineTo(sw,i*dy);
				}
			}
			else
			{
				clip.graphics.clear();	
			}
		}
		
		protected function onItemClick(event:ListEvent):void
		{
			stage.focus = cmtGrid;
		}
		
		private function onCommentLocation(s:SingleCommentData):void
		{
			cmtGrid.selectedItem = s;
			cmtGrid.scrollToSelected();
		}
		
		protected function onItemDClick(event:ListEvent):void
		{
			notify(SIGNALCONST.SET_POSITION_CHANGE,event.item.stime);
		}
		
		/**
		 * 批量执行高级指令<br>
		 * 1、调整时间轴：+0.5 -0.5
		 * 2、打开图片弹幕功能:openpic
		 * 3、批量转换旧版弹幕为新版高级弹幕：convert,zh
		 * 4、加载已有高级弹幕：ntr
		 * 5、打开跳转链接功能：openurl
		 * 6、打开容器和遮罩功能：biu
		 * 
		 */		
		protected function onCommond(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ENTER)
			{
				var items:Array = cmtGrid.selectedItems;
				if (cmtGrid.selectedItem == null)
					items = cmtGrid.dataProvider.toArray();
				
				var text:String = StringUtil.trim(commond.text);
				if (StringUtil.beginsWith(text,"+") || StringUtil.beginsWith(text,"-"))
				{
					var num:Number = Number(text);
					if (!isNaN(num))
					{
						for each (var cmt:SingleCommentData in items)
						{
							cmt.fixtime(num);
							//先删除再插入，以保持timeline的有序状态
							CommentTime.instance.delcomment(cmt.index);
							CommentTime.instance.insert(cmt);
						}
						commond.text = "";					
						cmtGrid.invalidateList();
						saveComment(cmtGrid.dataProvider.toArray());
					}
				}
				else if (text == "openpic")
				{
					_main.openpic();
					commond.text = "";
				}
				else if (text == "convert" || text == "zh")
				{
					convertToNew();	
					commond.text = "";
				}
				else if (text == "ntr")
				{
					for each (var item:SingleCommentData in CommentTime.instance.getAllComments())
					{
						if (item.mode == CommentType.FIXED_POSITION_AND_FADE) 
							insertCmtList(item);
					}
					commond.text = "";
				}
				else if (text == "openurl")
				{
					_main.openurl();
					commond.text = "";
				}
				else if (text == "biu")
				{
					_main.biu();
					commond.text = "";
				}
			}
			event.stopImmediatePropagation();
		}
		
		public function init():void 
		{			
			_beforeFilterConfig = _filter.toString();
			
			onCheck(null);
			
			refreshStat();
		}
		
		public function refreshStat():void
		{
			title.CmtStat.text = "(" + cmtGrid.dataProvider.length + ")";
		}
		
		public function setHeight(height:Number):void
		{
			mbody.height = height - 30;
			cmtGrid.height = height - 250;
			info.y = cmtGrid.y + cmtGrid.height + 10;
			commondLabel.y = commond.y = info.y + 65;
			exitB.y = sendB.y = cmtGrid.y + cmtGrid.height + 104;
		}
		
		public function onfixrecall(sold:SingleCommentData,snew:SingleCommentData):void
		{
			snew.preview = false;
			cmtGrid.dataProvider.replaceItem(snew,sold);		
			
			CommentTime.instance.delcomment(sold.index);
			CommentTime.instance.insert(snew);
			refreshStat();
			saveComment(cmtGrid.dataProvider.toArray());
		}
		
		public function insertCmtList(cmt:SingleCommentData):void {
			//加入时间轴方便查看效果，但不发送到服务器
			cmt.preview = false;			
			CommentTime.instance.insert(cmt);
			//加入列表
			if (cmtGrid.dataProvider.getItemIndex(cmt) == -1)
				cmtGrid.dataProvider.addItemAt(cmt,0);			
			refreshStat();
			//导入lrc大量调用可能卡住！
//			if (save)
//				saveComment(cmtGrid.dataProvider.toArray());
		}
		
		protected function onExit(event:MouseEvent):void
		{
			//清除参考线
			show_grid.selected = false;
			CommentView.instance.clip.graphics.clear();
			//恢复之前的过滤设置
			_filter.fromString(_beforeFilterConfig);
			_main.dispose();
			saveComment([]);
		}
		
		protected function gridHotKey(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.A:
				{
					//ctrl+a全选
					if (event.ctrlKey)
						selectAll();
					break;
				}
				case Keyboard.DELETE:
				{
					ondel(null);
					break;
				}
			}
		}
		
		protected function onClickSend(event:MouseEvent):void
		{
			if (cmtGrid.selectedItems.length == 0)
				cmtGrid.selectedItems = cmtGrid.dataProvider.toArray();
			sendComment(cmtGrid.selectedItems);
		}
		
		protected function onrsd(event:ContextMenuEvent):void
		{
			var data:Array = cmtGrid.selectedItems;
			sendComment(data);
		}
		
		protected function onjgt(event:ContextMenuEvent):void
		{
			var fr:FileReference = new FileReference();
			fr.addEventListener(Event.SELECT,function():void{
				fr.load();
				fr.addEventListener(Event.COMPLETE,function():void{
					var json:String = fr.data.readUTFBytes(fr.data.bytesAvailable);
					parseComment(json);
				});
			});
			fr.browse([new FileFilter("Acfun弹幕文件(*.json)","*.json")]);
		}
		
		protected function onsav(event:ContextMenuEvent):void
		{
			var data:Array = cmtGrid.dataProvider.toArray();
			var sav:Array = [];
			for each (var s:SingleCommentData in data)
				sav.unshift(s.getencode());
			
			var fr:FileReference = new FileReference();
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(Util.encode(sav));
			fr.save(ba,CommentHandler.instance.vid + ".json");
		}
		
		protected function ondel(event:ContextMenuEvent):void
		{
			var data:Array = getSelectData();
			for each (var s:SingleCommentData in data)
			{
				cmtGrid.removeItem(s);
				CommentTime.instance.delcomment(s.index);
			}
			cmtGrid.selectedItems = null;
			refreshStat();
			saveComment(cmtGrid.dataProvider.toArray());			
		}
		
//		protected function onftm(event:ContextMenuEvent):void
//		{
//			// TODO Auto-generated method stub
//			
//		}
		
		protected function onprw(event:ContextMenuEvent):void
		{
			var data:Array = getSelectData();
			for each (var s:SingleCommentData in data)
			{
				s.border = true;				
				s.preview = true;
				CommentTime.instance.insert(s);
			}
		}
		
		protected function onfix(event:Event):void
		{
			try{
				_main.modify(cmtGrid.selectedItem as SingleCommentData);
			}catch(e:Error){}
		}
		
		protected function oncopy(event:ContextMenuEvent):void
		{
			try{
				_main.showData(cmtGrid.selectedItem as SingleCommentData);
			}catch(e:Error){}
		}
		
		protected function onCheck(event:MouseEvent):void
		{
			var showSpecial:Boolean = preview_special.selected;
			var showSelf:Boolean = preview_self.selected;
			var scroll:Boolean = rollS.selected;
			var top:Boolean = topS.selected;
			var bottom:Boolean = bottomS.selected;
			
			_filter.addItem("u="+CommentHandler.instance.commentUser,showSelf);
			
			var bs:Array = _filter.bSettings;			
			bs[1] = scroll;
			bs[2] = top;
			bs[3] = bottom;
			bs[5] = showSpecial;
			bs[9] = showSelf;
			_filter.bSettings = bs;
			
			isLock = apply_lock.selected;
		}
		
		private function getSelectData():Array
		{
			var data:Array = [];
			try{
				data = cmtGrid.selectedItems;
				
				if (data.length == 0)
				{
					selectAll();
					data = cmtGrid.selectedItems;
				}
			}catch(e:Error){}
			return data;
		}
		
		private function selectAll():void
		{
			cmtGrid.selectedItems = cmtGrid.dataProvider.toArray();
		}
		
		private function sendComment(data:Array):void
		{
			if (data.length > 0)
			{
				sendB.enabled = false;
				sendB.label = "正在发送...";
				exitB.enabled = false;
				
				for each (var s:SingleCommentData in data)
				{
					s.isLock = isLock;
				}
				
				CommentHandler.instance.directSend(Vector.<SingleCommentData>(data));
				CommentHandler.instance.addEventListener("send_error",sendError);
				//检测发送成功
				var num:int = data.length;
				var last:int;
				var count:int;
				var tm:uint = setInterval(function():void{										
					var buffer:Vector.<SingleCommentData> = CommentHandler.instance.getDirectSendBuffer();
					var array:Array = [];
					for each (var s:SingleCommentData in buffer)
						array.push(s);
					cmtGrid.selectedItems = array;
					if (array.length == last)
					{
						count++;
						if (count == 10)
						{
							//超时重发
//							CommentHandler.instance.directSend();
							count=0;
						}
						if (count == 1)
							saveComment(array);
					}
					else
					{
						count=0;
					}
					last = array.length;
					if (array.length > 10)
						cmtGrid.scrollToIndex(cmtGrid.dataProvider.getItemIndex(array[10]));
					if (array.length == 0)
					{
						CommentHandler.instance.removeEventListener("send_error",sendError);
						clearTimeout(tm);
						cmtGrid.scrollToIndex(cmtGrid.dataProvider.length);
						sendB.enabled = true;
						sendB.label = "发送";
						exitB.enabled = true;
						notify(SIGNALCONST.SKIN_SHOW_MESSAGE,"<b>已发送完成</b>\n共发送"+num+"条高级弹幕(￣︶￣)","32");
						saveComment(array);
					}
				},500);	
				
				function sendError(event:CommentServerEvent):void{
					CommentHandler.instance.removeEventListener("send_error",sendError);
					clearTimeout(tm);
					sendB.enabled = true;
					sendB.label = "发送";
					exitB.enabled = true;
					notify(SIGNALCONST.SKIN_SHOW_MESSAGE,event.data,"19");
				}
			}
			else
			{
				notify(SIGNALCONST.SKIN_SHOW_MESSAGE,"待发送列表中没有弹幕(￣︿￣)","45");
			}
		}
		
		public function saveComment(data:Array=null):void
		{
			if (data == null) data = cmtGrid.dataProvider.toArray();
			
			var save:Array = [];
			for each (var s:SingleCommentData in data)
				save.push(s.getencode());
			//存为压缩二进制大大节省空间
			var ba:ByteArray = new ByteArray();
			ba.writeObject(save);
			ba.compress();
			LocalStorage.setValue(LocalStorage.COMMENT_SPECIAL_SAVE,ba);
		}
		
		private function parseComment(json:*):void
		{		
			if (json == null) return;
			
			var data:Array = [];
			
			if (json is ByteArray)
			{
				var ba:ByteArray = json as ByteArray;
				ba.uncompress();
				data = ba.readObject();
				if (data.length > 0)
					notify(SIGNALCONST.SKIN_SHOW_MESSAGE,"上次未正常退出或未发送完毕，本次弹幕自动恢复\n如果不需要可以按<b>ctrl+a</b>全选，然后右键删除(￣︶￣)","06");
			}			
			else if (json is Array)
			{
				data = json;
			}			
			else if (json is String)
			{
				try
				{
					data = Util.decode(json,false);
				}
				catch (e:Error)
				{
					notify(SIGNALCONST.SKIN_SHOW_MESSAGE,"弹幕解析出错(￣︿￣)","42");
				}	
			}			
			
			data.reverse();
			
			var ts:Number = new Date().time;
			for each (var s:String in data)
			{
				var o:Object = Util.decode(s);
				//使用本地用户和时间覆盖
				o["time"] = ts;
				o["user"] = CommentHandler.instance.commentUser;
				var ss:SingleCommentData = CommentUtils.createNewComment(o,o.isLock);														
				if (ss.mode == SingleCommentData.FIXED_POSITION_AND_FADE)
				{
					ss.text = ss.addon["n"];
				}
				ss.border = false;
				insertCmtList(ss);
			}
			saveComment(cmtGrid.dataProvider.toArray());
		}
		
		private function getSavedComment():void
		{
			var save:ByteArray = LocalStorage.getValue(LocalStorage.COMMENT_SPECIAL_SAVE,null);
			parseComment(save);
		}
		
		private function convertToNew():void
		{
			for each (var s:SingleCommentData in cmtGrid.selectedItems)
			{
//				转换为新版
				if (s.addon["ver"]==null)	//旧版
				{
					s.addon["ver"] = ConstValue.SPECIAL_COMMENT_VERSION;
					s.addon["ovph"] = true;
				}
			}
			if (cmtGrid.selectedItems)
			{
				notify(SIGNALCONST.SKIN_SHOW_MESSAGE,"已成功转换所选的<font color='#ff0000'><b>"+cmtGrid.selectedItems.length+"</b></font>条弹幕！","51");	
			}
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
	}
	
}