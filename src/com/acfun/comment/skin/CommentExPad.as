package com.acfun.comment.skin 
{
	import com.acfun.External.SIGNALCONST;
	import com.acfun.Utils.SrtDecoder;
	import com.acfun.Utils.Util;
	import com.acfun.comment.control.CommentTime;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.utils.CommentUtils;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	import com.acfun.signal.unregister;
	import com.adobe.utils.StringUtil;
	
	import fl.controls.Button;
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.controls.List;
	import fl.data.DataProvider;
	import fl.events.ListEvent;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.utils.Base64Encoder;
	
	public class CommentExPad
	{
		private static var itemTables:Object = {'X':'x','Y':'y','Z':'z','COL':'c','ROX':'rx','ROZ':'d','ROY':'e','SX':'f','SY':'g','SZ':'sz','AP':'t','ME':'v','LF':'l'};
		private static var itemTablesValue:Object = {
			'X':[2000,-1000,0.1,0],
			'Y':[2000,-1000,0.1,0],
			'Z':[2000,-2000,0.1,0],
			'COL':[0,0,0,0],
			'RO':[3600,-3600,0.1,0],
			'ROY':[3600,-3600,0.1,0],
			'SX':[100,0,0.01,1],
			'SY':[100,0,0.01,1],
			'AP':[1,0,0.01,1],
			'ME':[7,0,1,3],
			'LF':[999,0,0.01,0]
		};//要求分度值倒数能整除其他数
		private var posBt:Button;
		private var postoBt:Button;
		private var B_addACT:Button;		
		private var B_fixACT:Button;		
		private var B_Prw:Button;
		private var B_Add:Button;
		private var Cmode:ComboBox;
		private var textIp:TextField;
		private var actionList:List;
		private var cm:ContextMenu;
		private var vispad:CommentEx;
		private var ActionArray:DataProvider;
		private var retype:int;
		private var sold:SingleCommentData;
		private var fixrecall:Function;
		private var dataFontNames:Object={};
		private var B_reset:Button;
		private var B_action_clear:Button;
		private var B_action_reset:Button;
		private var FRc:FileReference;
//		private var loader:Loader;
		private var C_tFont:ComboBox;
		private var T_tFilter:TextField;
		private var mode:int;
		private var B_tAct:CheckBox;
		private var textAL:TextField;		
		private var _fontlist:Array;		
		private var _main:CommentSpecial;
		
		public var viewArea:Sprite;		
		public var getPTime:Function;
		
		private function get ptime():Number
		{
			return getPTime != null ? getPTime() : 0; 
		}
		
		public function CommentExPad(main:CommentSpecial)
		{
			_main = main;
			vispad = new CommentEx();
			//vispad.tit.text.text = "高级弹幕制作"
			vispad.initc();
			var ids:Array = vispad.getIDs();
			posBt = ids['posBt'];
			postoBt = ids['postoBt'];
			B_addACT = ids['B_addACT'];
			B_fixACT = ids['B_fixACT'];
			actionList = ids['actionList'];
			B_action_reset = ids['B_action_reset'];
			B_action_clear = ids['B_action_clear'];
			B_Prw = ids['B_Prw'];
			B_Add = ids['B_Add'];
			B_reset = ids['B_reset'];
			textIp = ids['textIp'];
			Cmode = ids['Cmode'];
			C_tFont = ids['C_tFont'];
			T_tFilter = ids['T_tFilter'];
			B_tAct = ids['B_tAct'];
			textAL = ids['textAL'];
			mode = 0;
			ActionArray = new DataProvider;
			actionList	.dataProvider = ActionArray;
			actionList	.addEventListener(Event.ADDED,actList_creationCompleteHandler);
			
			B_Add	.addEventListener(MouseEvent.CLICK,post_clickHandler);			
			B_Prw	.addEventListener(MouseEvent.CLICK,prw_clickHandler)
			B_action_reset	.addEventListener(MouseEvent.CLICK,resetacts_clickHandler);
			B_action_clear	.addEventListener(MouseEvent.CLICK,clearacts_clickHandler);
			postoBt	.addEventListener(MouseEvent.CLICK,getposto_clickHandler);
			posBt	.addEventListener(MouseEvent.CLICK,getpos_clickHandler);
			B_reset	.addEventListener(MouseEvent.CLICK,reset_clickHandler);
			B_addACT.addEventListener(MouseEvent.CLICK,addact_clickHandler);
			B_fixACT.addEventListener(MouseEvent.CLICK,fixact_clickHandler);
			Cmode	.addEventListener(Event.CHANGE,mode_selectHandler);
			B_tAct	.addEventListener(Event.CHANGE,switch_clickHandler);
			retype = -1;
			vispad.getNowTime = function():Number{if(Cmode.value!='lrc'){return ptime; }else{return 0;}}
		}
		
		protected function switch_clickHandler(event:Event):void
		{
			textAL.visible = B_tAct.selected;
			actionList.visible = !B_tAct.selected;
			if(B_tAct.selected)	{encodeaction();}
			else {decodeaction();}
		}
		
		private function decodeaction():void
		{
			var itemtext:String;
			var i:int;
			ActionArray.removeAll();
			var items:Array = textAL.text.split('\r');
			var objitems:Object;
			for(i=0;i<items.length;i++)
			{
				itemtext = items[i];
				if(itemtext.length>2)
				{
					objitems = uncoLabel(itemtext);
					itemtext = doLabel(objitems);
					ActionArray.addItem({label:itemtext,sigdata:objitems});
				}
			}
		}
		
		private function encodeaction():void
		{
			var textret:String;
			var i:int;
			textret = "";
			if(ActionArray.length > 0)
			{
				var s:Array = new Array();
				var d:int = ActionArray.length;
				for(i=0;i<d;i++)
				{
					textret += ActionArray.getItemAt(i).label;
					textret += '\r'
				}
				textAL.text = textret;
			}
		}		
		
		
		protected function getPointXY(area:Sprite):void
		{
			register(SIGNALCONST.HOTEY_CANCEL,getPointEsc);
			
			var getPointTimer:uint;
			var getPointX:Number;
			var getPointY:Number;
			var getPointMark:Sprite;
			var mark:Sprite;
			
			function getPoint():void
			{
				mark = new Sprite;
				var gp:Graphics = mark.graphics;
				gp.beginFill(0x445566,0.2);
				gp.drawRect(0,0,area.width,area.height);
				gp.endFill();
				mark.buttonMode = true;
				area.stage.addChild(mark);
				mark.addEventListener(MouseEvent.MOUSE_MOVE,getPointReffData);
				mark.addEventListener(MouseEvent.CLICK,getpos_handler);
				mark.addEventListener(MouseEvent.MOUSE_DOWN,function(e:Event):void{e.stopImmediatePropagation();});
				getPointMark = mark;getPointX = -1;getPointY = -1;
				getPointTimer = setInterval(getPointReff,200);
			}
			
			function getPointReffData(event:MouseEvent):void
			{
				getPointX = event.localX;
				getPointY = event.localY;
			}
			
			function getpos_handler(event:MouseEvent):void
			{
				event.stopImmediatePropagation();
				mark.removeEventListener(MouseEvent.CLICK,getpos_handler);
				area.stage.removeChild(mark);
				clearInterval(getPointTimer);
				returnValue(event.localX/mark.width * 1000,event.localY/mark.height * 1000);
				unregister(SIGNALCONST.HOTEY_CANCEL,getPointEsc);
			}			
			
			function getPointReff():void
			{
				if(getPointX<0){return;}
				initCommentDataPre(getPointX/getPointMark.width * 1000,getPointY/getPointMark.height * 1000,200/1000);
			}
			
			function getPointEsc():void
			{
				mark.removeEventListener(MouseEvent.CLICK,getpos_handler);
				area.stage.removeChild(mark);
				clearInterval(getPointTimer);
				unregister(SIGNALCONST.HOTEY_CANCEL,getPointEsc);
			}
			
			getPoint();
		}
		
		protected function reset_clickHandler(event:MouseEvent):void		{vispad.resetvalue();}
		
		protected function getpos_clickHandler(event:MouseEvent):void
		{
			if(viewArea != null)
			{
				retype = 0;
				getPointXY(viewArea);
			}
			else{vispad.setXY(0,120,240);}
		}
		
		public function returnValue(rx:Number,ry:Number):void
		{if(retype >= 0){vispad.setXY(retype,rx,ry);retype=-1;}}
		
		protected function getposto_clickHandler(event:MouseEvent):void
		{
			if(viewArea != null)
			{
				retype = 1;
				getPointXY(viewArea);
			}
			else{vispad.setXY(1,240,680);}
		}
		
		public function get display():Sprite		{return vispad;	}
		
		public function openadv(b:Boolean):void
		{
			if(!(mode&1))
			{
				mode |= 1;
				vispad.setadvs(true);
			}
			
			if(!(mode&2) && b)
			{
				mode |= 2;
				Cmode.dataProvider.addItem({label:"图片",data:"pic"});
				vispad.stage.focus = Cmode;
			}
		}
		
		public function openurl():void
		{
			vispad.seturl(true);
		}
		
		public function biu():void
		{
			vispad.setbiu(true);
		}
		
		public function initCommentDataPre(cx:Number,cy:Number,ti:Number):void
		{
			var common:Object = vispad.getComData(true);
			var stt:Number = common.st;
			var singleData:SingleCommentData;
			var i:int;			
			var idx:String = Cmode.value;
			var commentObject:Object = vispad.getCommentObject();
			commentObject.p = {x:cx,y:cy};
			commentObject.l = ti;
			commentObject.bh = true;
			
			if(commentObject.w != null && commentObject.w.l != null)
			{commentObject.w.l = Util.decode(commentObject.w.l);}
			
			if(retype == 1)
			{
				var so:Object = vispad.getActData(false)
				commentObject.r = so.d;
				commentObject.k = so.e;
				commentObject.e = so.f;
				commentObject.f = so.g;
				commentObject.a = so.t;
				if(so.c != null){common.sc = so.c};
			}
			
			if(idx == 'pic')
			{
				commentObject.n = "";
				if(commentObject.w == null){commentObject.w = new Object;}
				commentObject.w.g = {d:textIp.text.replace(/\s/g,'')};
				
				singleData = CommentUtils.createNewComment({ 
					mode:SingleCommentData.FIXED_POSITION_AND_FADE,
					message:"{图片弹幕}",
					color:common.sc,
					size:common.sz,
					stime:stt,
					preview:true,
					addon:commentObject
				},false,true);				
				CommentTime.instance.insert(singleData);
				return;
			}
			if(idx == 'lrc'){commentObject.n = textIp.text.substr(0,textIp.text.indexOf("\r"));}
			else{commentObject.n = textIp.text.replace(/(\n)/g, "\r");}
			if(commentObject.n.length<1){commentObject.n = "示例文本";}
			
			singleData = CommentUtils.createNewComment({ mode:SingleCommentData.FIXED_POSITION_AND_FADE,message:commentObject.n,color:common.sc,size:common.sz,stime:stt,addon:commentObject,preview:true },false,true);
			CommentTime.instance.insert(singleData);
		}
		
		
		private function initCommentData(isPrev:Boolean = false):SingleCommentData
		{
			//构造SingleCommentData
			
			//构造初始化函数
			var common:Object = vispad.getComData(isPrev);
			var stt:Number = common.st;
			var singleData:SingleCommentData;			
			var obj:Object;
			var i:int;			
			var idx:String = Cmode.value; 
			
			if(stt < 0){stt = ptime;}
			if(idx == 'spc')
			{
				singleData = CommentUtils.createNewComment({ 
					mode:SingleCommentData.ECMA3_SCRIPT,
					message:textIp.text,
					color:common.sc,
					size:common.sz,
					stime:stt,
					preview:isPrev
					});
				return singleData;
			}
			var commentObject:Object = vispad.getCommentObject();			
			var freetimeset:Array = new Array;
			var freetimeget:Array = new Array;
			var freetimeadd:Number = 0;
			
			if(commentObject.w != null && commentObject.w.l != null)
			{
				try{commentObject.w.l = Util.decode(commentObject.w.l)}
				catch(e:Error){commentObject.w.l = null;}
			}
			
			if(ActionArray.length > 0)
			{
				var s:Array = new Array();
				var d:int = ActionArray.length;
				for(i=0;i<d;i++)
				{
					obj = ActionArray.getItemAt(i).sigdata;
					if(obj.l != null)
					{
						freetimeset.push(i);
						freetimeget.push(obj.l);
					}					
					s.push(obj);
				}
				commentObject.z = s;
			}
			
			var kl:uint = freetimeset.length;
			var k:uint;					
			var tmpti:Number;
			var tmptl:Number;
			
			if(idx == 'text')
			{
				commentObject.n = textIp.text.replace(/(\n)/g, "\r");
				
				singleData = CommentUtils.createNewComment({ 
					mode:SingleCommentData.FIXED_POSITION_AND_FADE,
					message:commentObject.n,
					color:common.sc,
					size:common.sz,
					stime:stt,
					preview:isPrev,
					addon:commentObject
				});				
				return singleData;
			}else if(idx == 'pic')
			{
				commentObject.n = "";
				if(commentObject.w == null){commentObject.w = new Object;}
				commentObject.w.g = {d:textIp.text.replace(/\s/g,'')};
				
//				var datas:Array = textIp.text.replace(/\s/g,'').split(',');
//				if(datas.length<3){return null;}				
//				commentObject.w.g = {w:datas[0],h:datas[1],d:datas[2]};
					
				singleData = CommentUtils.createNewComment({ 
					mode:SingleCommentData.FIXED_POSITION_AND_FADE,
					message:"{图片弹幕}",
					color:common.sc,
					size:common.sz,
					stime:stt,
					preview:isPrev,
					addon:commentObject
				});
				return singleData;
			}else if(idx == 'lrc')
			{
				if(commentObject.l!=null)
				{
					if(commentObject.l>0 && commentObject.l<10) 	{freetimeadd = commentObject.l;}
					delete commentObject.l;
				}
				
				var wors:Array;
				var keep:Number;
				
				var text:String = StringUtil.trim(textIp.text);
				if (text.indexOf("[") == 0)
					wors = declrc(text);
				else
					wors = decsrt(text);
				
				var words:String;
				var date:Date = new Date;
				var time:Number = date.time;
				
				for (i=0;i<wors.length;i++)
				{
					//obj.n 和 obj.l 应为 null
					obj = Util.copy(commentObject);
					
					tmptl = keep = wors[i][1]/1000 + freetimeadd;
					obj.n = wors[i][2];
					
					if(kl>0){			
						for(k=0;k<kl;k++)
							if (freetimeget[k] < 99 || freetimeget[k] > 100)
								keep -= freetimeget[k];
						
						if (keep < 0) keep = 0;
						
						for(k=0;k<kl;k++)
						{
							if (freetimeget[k] >= 99 && freetimeget[k] <= 100)
								tmpti = keep*(freetimeget[k]-99);
							else
								tmpti = freetimeget[k]
							obj.z[freetimeset[k]].l = tmpti;
							tmptl -= tmpti;
						}
					}
					
					if (tmptl < 0) tmptl = 0;
					obj.l = tmptl;
					
					singleData = CommentUtils.createNewComment({ 
						mode:SingleCommentData.FIXED_POSITION_AND_FADE,
						message:obj.n,
						color:common.sc,
						size:common.sz,
						stime:wors[i][0]/1000,
						time:time+=30000,
						preview:isPrev,
						addon:obj
					});					
					
					if (isPrev)
						return singleData;
					else
						_main.addToList(singleData);
				}
				_main.saveComments();
				return null;
			}
			return null;
		}
		
		public function declrc(s:String):Array
		{
			var lrcs:Array = s.split("\r");
			var wors:Array = new Array;
			var worts:Array = new Array;
			var lens:int=lrcs.length;
			var i:int,j:int,k:int;
			var infs:Array = new Array;
			
			function timedec(str:String):int
			{
				var tims:Array = str.split(":");
				var len:int = tims.length;
				var tnum:Number
				var ret:Number = 0;
				for(var i:int = 0;i<len;i++)
				{
					var lstr:String = tims[i];
					tnum = Number(lstr);
					if(!isNaN(tnum)){ret = ret*60 + tnum}
					else{return -1};
				}
				return int(ret*=1000);
			}
			
			for (i=0;i<lens;i++)
			{
				var lworts:Array = new Array;
				var slr:String = lrcs[i];
				var st:uint = 0;
				var cut:uint = 0;
				var tst:int;
				var val:int;
				while(slr.charAt(st) == '[')
				{
					tst = slr.indexOf(']',st);
					if(tst<0){break;}
					val = timedec(slr.substring(st+1,tst));
					if(val>=0){lworts.push(val)}
					else{infs.push(slr.substring(st+1,tst).split(':'))}
					st=tst+1;
				}
				wors[i]=slr.substr(st);
				worts[i]=lworts;
			}
			
			lens = worts.length;
			var retst:Array = new Array;
			var retsw:Array = new Array;
			for(i=0;i<lens;i++)
			{
				var arr:Array = worts[i];
				var tm:int;
				if(arr!=null)
				{
					var larr:int = arr.length;
					for(j=0;j<larr;j++)
					{
						tm = arr[j];
						k = retst.length-1;
						while(k>=0&&retst[k]>tm){k--;}
						retst.splice(++k,0,tm);
						retsw.splice(k,0,wors[i]);
					}
				}
				
			}
			
			lens = retst.length;
			var fixed:Array = new Array;
			j=0;
			retst.push(retst[lens-1]+5000);
			for(i=0;i<lens;i++)
			{
				var tw:String = retsw[i];
				var ts:int = retst[i];
				var tn:int = retst[i+1];
				if(tw != ""){fixed.push([ts,tn-ts,tw]);}
			}			
			return fixed;
		}
		
		public function decsrt(s:String):Array
		{
			return SrtDecoder.decode(s);
		}
		
		public function commentObjectRead(cmt:SingleCommentData):void
		{
			var obj:Object = cmt.addon;
			if(obj != null)
			{
				ActionArray.removeAll();
				textAL.text = "";
				var arr:Array = obj.z as Array;
				if(arr != null)
				{
					for each(var o:Object in arr)
					{ActionArray.addItem({label:doLabel(o),sigdata:o});}
					if(B_tAct.selected)	{encodeaction();}
				}
				if(obj.w!=null&&obj.w.g!=null)
				{
					textIp.text = obj.w.g.d;
					Cmode.selectedIndex = 3; /**图片在第几项**/
				}
				else	
				{
					textIp.text = (obj.n==null)?"":obj.n;
				}
				var common:Object = {sc:cmt.color,sz:cmt.size,st:cmt.stime}
				vispad.setComData(common);
				if(obj.w!=null)
				{
					var iadd:Object = new Object;
					if(obj.w.f!=null)
					{
						var fn:String = obj.w.f;
						if(dataFontNames[fn] != null)
						{iadd.fidx = dataFontNames[fn];}
						else
						{
							C_tFont.dataProvider.addItem({label:"缺:" + fn,data:fn});
							var idx:uint = C_tFont.dataProvider.length - 1;						
							dataFontNames[fn] = idx;
							iadd.fidx = idx;						
						}
					}
					if(obj.w.l!=null){iadd.ltxt = Util.encode(obj.w.l);}
				}
				vispad.setCommentObject(obj,iadd);
			}
			
		}
		
		protected function prw_clickHandler(event:MouseEvent):void
		{
			if(textIp.text == '')return;
			if(B_tAct.selected)	{decodeaction();}
			var data:SingleCommentData = initCommentData(true);
			if(data==null)	{mode_selectHandler(null);return;}
			data.border = true;
			CommentTime.instance.insert(data);
//			ControlBus.getInstance().sendCommentEvent(data,false);
		}
		
		protected function clearacts_clickHandler(event:MouseEvent):void
		{
			if(fixrecall != null){cancelfix();return;}
//			vispad.getActData();
			if(B_tAct.selected)	{textAL.text="";}
			else{ActionArray.removeAll();}
		}
		
		protected function resetacts_clickHandler(event:MouseEvent):void
		{
			vispad.getActData();
		}
		
		private function cancelfix():void
		{
			fixrecall = null;
			sold = null;
			B_action_clear.label = "清空动作";
			B_Add.label = "加入到弹幕列表->";
			Cmode.enabled = true;
		}
		
		public function close():void		{if(fixrecall != null){cancelfix();}}
		
		private function doLabel(item:Object):String
		{
			var stt:String = '';
			if(item.x != null)stt += 'X->' + item.x +  ';';
			if(item.y != null)stt += 'Y->' + item.y +  ';';
			if(item.z != null)stt += 'Z->' + item.z +  ';';
			if(item.c != null)stt += 'COL->' + item.c + ';';
			if(item.rx != null)stt += 'ROX->' + item.rx + ';';
			if(item.e != null)stt += 'ROY->' + item.e + ';';
			if(item.d != null)stt += 'ROZ->' + item.d + ';';
			if(item.f != null)stt += 'SX->' + item.f + ';';
			if(item.g != null)stt += 'SY->' + item.g + ';';
			if(item.sz != null)stt += 'SZ->' + item.sz + ';';
			if(item.t != null)stt += 'AP->' + item.t + ';';
			if(item.v != null)stt += 'ME:' + item.v + ';';
			if(item.l != null)stt += 'LF:' + item.l + ';';
			return stt;
		}
		
		private static function uncoLabel(word:String):Object
		{
			var item:Object = new Object;
			var items:Array = word.split(';');
			var lbs:Array;
			var i:int;
			for(i=0;i<items.length;i++)
			{
				lbs = (items[i] as String).split(/:|->/);
				if(lbs.length>=2 && itemTables[lbs[0]]!=null)
				{item[itemTables[lbs[0]]] = value(lbs[1],itemTablesValue[lbs[0]]);}
			}
			return item;
		}
		
		private static function value(val:Object,arr:Array = null):Object
		{
			if(arr == null || arr.length<2){return Number(val);}
			var max:Number = arr[0];
			var min:Number = arr[1];
			var evn:int = 1/arr[2];
			if(evn==0){return uint(val);}
			var ret:Number = Number(val);
			if(isNaN(ret)){return arr[3];}
			ret = Math.floor(ret*evn)/evn;
			if(ret>max){return max;}
			if(ret<min){return min;}
			return ret;
		}		
		
		
		private function contextMenu_menuSelect(evt:ContextMenuEvent):void 
		{
			setupContextMenu();
			///EventBus.getInstance().dispatchEvent(new MukioEvent(MukioEvent.PAUSE,null));
		}
		
		private function setupContextMenu():void
		{
			cm.customItems = [];
			if(actionList.selectedItem)
			{
				//var seIndex:int = 
				var deleteSelectedItem:ContextMenuItem = new ContextMenuItem("删除该动作", false);
				deleteSelectedItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, deleteSelectedItem_Handler);
				
				var moveUpSelectedItem:ContextMenuItem = new ContextMenuItem("前移该动作", false);
				moveUpSelectedItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveUpSelectedItem_Handler);
				
				var moveDownSelectedItem:ContextMenuItem = new ContextMenuItem("后移该动作", false);
				moveDownSelectedItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveDownSelectedItem_Handler);
				
				cm.customItems = [deleteSelectedItem,moveUpSelectedItem,moveDownSelectedItem];				
			}
		}
		
		protected function actList_creationCompleteHandler(event:Event):void
		{
			actionList.removeEventListener(Event.ADDED,actList_creationCompleteHandler);
			cm = new ContextMenu();
			cm.hideBuiltInItems();
			
			cm.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenu_menuSelect);
			actionList.contextMenu = cm;
			actionList.addEventListener(ListEvent.ITEM_CLICK, contextMenu_itemSelect);
			B_fixACT.enabled = false;			
			var fd:DataProvider = new DataProvider();
			for each (var font:Font in Font.enumerateFonts(true))
			{
				dataFontNames[font.fontName] = fd.length;
				fd.addItem({label:font.fontName,data:font.fontName});				
			}
			C_tFont.dataProvider = fd;
			C_tFont.selectedIndex = dataFontNames["黑体"];
			vispad.defFontIdx = C_tFont.selectedIndex;
			//if(mode<=0){vispad.setadvs(false);mode=0;}
		}
		
		protected function addact_clickHandler(event:MouseEvent):void
		{
			var myOBJ:Object = vispad.getActData();
			ActionArray.addItem({label:doLabel(myOBJ),sigdata:myOBJ});
			if(B_tAct.selected)	{encodeaction();}
		}
		
		protected function contextMenu_itemSelect(event:ListEvent):void
		{
			var obj:Object = event.item.sigdata;
			if(obj != null){vispad.setActData(obj);}
			B_fixACT.enabled = true;
		}
		
		protected function fixact_clickHandler(event:MouseEvent):void
		{
			var obj:Object = actionList.selectedItem;
			if(obj!=null && obj.sigdata!=null)
			{
				var myOBJ:Object = vispad.getActData();
				obj.label = doLabel(myOBJ);
				obj.sigdata = myOBJ;
				actionList.invalidateItem(obj);
				B_fixACT.enabled = false;
			}
		}
		
		public function fixcmt(s:SingleCommentData,rec:Function):Boolean
		{
			if(s.mode != SingleCommentData.FIXED_POSITION_AND_FADE){return false;}
			sold = s;
			fixrecall = rec;
			Cmode.selectedIndex = 0;
//			Cmode.enabled = false;
			commentObjectRead(sold);
			B_action_clear.label = "取消修改";
			B_Add.label = "确认修改";			
			return true;
		}
		
		private function deleteSelectedItem_Handler(evt:ContextMenuEvent):void
		{
			var sldx:int = actionList.selectedIndex;
			if(sldx>=0){ActionArray.removeItemAt(sldx);}
			B_fixACT.enabled = false;
			vispad.getActData();
			actionList.selectedItem = null;
		}
		
		private function moveUpSelectedItem_Handler(evt:ContextMenuEvent):void	{moveSelectedItem(actionList.selectedIndex,-1);}
		
		private function moveDownSelectedItem_Handler(evt:ContextMenuEvent):void	{moveSelectedItem(actionList.selectedIndex,1);}
		
		private function moveSelectedItem(sldx:int,pos:int):void
		{
			sldx+=pos;
			if(ActionArray.length>sldx && sldx>=0)
			{
				var se:Object = actionList.selectedItem;
				ActionArray.removeItemAt(sldx-pos);
				ActionArray.addItemAt(se,sldx);
				actionList.selectedIndex = sldx;
			}
		}
		
		protected function post_clickHandler(event:MouseEvent):void
		{
			if(textIp.text == "" && (!vispad.Name.enabled || vispad.Name.text == ""))
				return;
			if(B_tAct.selected)	{decodeaction();}
			var data:SingleCommentData = initCommentData(false);
			textIp.text = '';
			ActionArray.removeAll();
			if(fixrecall!=null && data!=null)
			{
				fixrecall(sold,data);
				cancelfix();
			}
			else if(data!=null)
			{
				_main.addToList(data);
				_main.saveComments();
			}
		}
		
		private function doitinit():void
		{
			FRc = new FileReference();
			FRc.addEventListener(Event.SELECT,function(event:Event):void{
				//为了春晚弹幕临时注掉
				if (FRc.size > 307200)
				{
					notify(SIGNALCONST.SKIN_SHOW_MESSAGE,"播放姬能塞下的最大图片体积为<b>300K</b>，\n大于<b>300K</b>的请使用图片软件处理之后重试。","16");
					Cmode.selectedIndex = 0;
				}
				else
				{
					FRc.load();
				}
			});
			FRc.addEventListener(Event.COMPLETE,function(e:Event):void{
//				loader.loadBytes(FRc.data);
				
				var tmp:ByteArray = new ByteArray();
				tmp.writeBytes(FRc.data,0,FRc.data.length);
				var base64text:Base64Encoder = new Base64Encoder();
				base64text.encodeBytes(tmp);
				textIp.text = base64text.drain();				
				tmp.clear();
			});
			
//			loader=new Loader();
//			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,readOK);
		}
		
//		protected function readOK(event:Event):void
//		{
//			//旧版图片弹幕
//			var dis:DisplayObject = loader as DisplayObject;
//			var bitmapData:BitmapData = new BitmapData(dis.width, dis.height,true,0x000000);
//			bitmapData.draw(dis,null,dis.transform.colorTransform);			
//			var tmp:ByteArray = bitmapData.getPixels(new Rectangle(0,0,dis.width,dis.height));
//			tmp.deflate();
//			var base64text:Base64Encoder = new Base64Encoder;
//			base64text.encodeBytes(tmp);
//			var ret:String = dis.width + ',' + dis.height + ',' + base64text.drain();
//			textIp.text = ret;
//		}
		
		protected function mode_selectHandler(event:Event):void
		{	
			//event有可能为null;
			if(Cmode.value == 'lrc')
			{
				vispad.clearlifetime();
//				vispad.setComData({sc:16777215,sz:17});
//				vispad.setCommentObject({b:false,c:7,p:{x:500,y:1000}});
			}			
			else if(Cmode.value == 'pic')
			{
				if(FRc == null){doitinit();}
				FRc.browse([new FileFilter("图片弹幕文件(*.png,*.gif)","*.png;*.gif")]);
			}
			else if(Cmode.selectedIndex == 3)
			{
				textIp.text = "$.debug = true;//开启控制台\r$.out('Hello,World!');\r/**下面是一个循环示例**/\rfor(var i:int;i<5;i++)\r{\r  $.out('I:' + i);\r}\r/** 下面示例创造一个SingleComment **/\rvar sc:SimpleCommentEngine = $.createSingleComment('我也是一个评论');\r$.screen.addChild(sc);\rsc.x = 200;\rsc.y = 100;";
			}
		}
	}
}