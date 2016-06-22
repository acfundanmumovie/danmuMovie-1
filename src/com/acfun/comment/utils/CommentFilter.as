package com.acfun.comment.utils
{
	import com.acfun.External.ConstValue;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.Utils.BlockLoader;
	import com.acfun.Utils.Util;
	import com.acfun.comment.communication.CommentHandler;
	import com.acfun.comment.display.base.Comment;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.signal.register;
	import com.acfun.signal.unregister;
	import com.adobe.serialization.json.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	import flash.system.System;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * 弹幕过滤器类,把原来的文件改改就拿来用了
	 * @author aristotle9
	 **/
	public class CommentFilter extends EventDispatcher
	{
		/** 过滤器数据数组 **/
		private static const numberFilters:int = 3;
		/** 0：用户自定义过滤  1：云屏蔽 **/	
		private var fArr:Vector.<Array>;
		private var ids:int = 0;
		
		//private static var Mode:Array = ['mode', 'color', 'text'];
		public var bEnable:Boolean = true;
		public var bRegEnable:Boolean = false;
		public var bVSelected:Boolean = false;
		public var bIgnoreCase:Boolean = false;
		public var bGuest:Boolean = true;
		
		/** 
		 * 下列内容不存入SO----还是存吧
		 **/
		public var bRoll:Boolean = true;
		public var bTop:Boolean = true;
		public var bBottom:Boolean = true;
		public var blRoll:Boolean = true;
		public var bSpecial:Boolean = true;
		public var bChange:Boolean = false;
		public var bRepfiliter:Boolean = true;
		
		public var systemWordBK:Vector.<String> = new Vector.<String>();
		public var systemUIDsBK:Vector.<String> = new Vector.<String>();		
		
		private var strs:Array = new Array();
		private static var instance:CommentFilter;
		private static const TINE_SCAN:int = 3;
		private var exchangeTab:Array;
		private var blankTab:Vector.<String>;

		
		public function CommentFilter() 
		{
			if(instance != null)
			{
				throw new Error("class CommentFilter is a Singleton,please use getInstance()");
			}
			fArr = new Vector.<Array>(numberFilters);
			for(var i:int=0;i<numberFilters;i++)
			{fArr[i] = new Array();}
//            var sort:Sort = new Sort();
//            sort.fields = [new SortField('mode')];
//            fArr[0].sort = sort;
			initSystemArray();
			initSystemUidArray();
			loadFromSharedObject();
			
			register(SIGNALCONST.SET_COMMENT_FILTER,onSet);
		}
		
		private function onSet(source:Object):void
		{
			fromString(Util.encode(source));
		}
		
		private function initSystemArray():void
		{
			var md:Date = new Date;
			var url:String = ConstValue.CONFIG_STATIC_URL + '/player/filter/ban.json?'.concat(md.day.toString(16),md.hours.toString(16),int(md.minutes/5));
			var bl:BlockLoader = new BlockLoader(url);
			bl.addEventListener(Event.COMPLETE,Loader_CompleteHandler);
			bl.addEventListener(BlockLoader.HTTPLOADER_ERROR,Loader_ErrorHandler);
		}
		
		private function initSystemUidArray():void
		{
			var md:Date = new Date;
			var url:String = ConstValue.CONFIG_STATIC_URL + '/player/filter/blacklist.json?'.concat(md.day.toString(16),md.hours.toString(16),int(md.minutes/5));
			var bl:BlockLoader = new BlockLoader(url);
			bl.addEventListener(Event.COMPLETE,LoaderUid_CompleteHandler);
			bl.addEventListener(BlockLoader.HTTPLOADER_ERROR,LoaderUid_ErrorHandler);
		}
		/**
		 * 弹幕过滤:<br/>
		 * 通过(符合要求) true,<br/>
		 * 不通过(要屏蔽) false.
		 **/
		public function systemFil(str:String):Boolean
		{
			str = wordfilter(str);
			if(!systemWordBK){return true;}
			else
			{
				for each(var s:String in systemWordBK)
				{
					if(str.indexOf(s) >= 0)
						return false;	
				}
				return true;
			}
		}
		
		public function disableUserChk(ck:String):Boolean
		{
			ck = getId(ck);
			return (systemUIDsBK != null && systemUIDsBK.indexOf(ck)>=0);
		}
		
		private function getId(s:String):String
		{
			if(s == null){return CommentUtils.UNKOWN_USER}
			var a:Array = s.split('k');
			if(a.length>1){return a[1];}
			return s;
		}
		
		private function LoaderUid_CompleteHandler(evt:Event):void
		{
			var bl:BlockLoader = evt.target as BlockLoader;
			bl.removeEventListener(Event.COMPLETE,LoaderUid_CompleteHandler);
			bl.removeEventListener(BlockLoader.HTTPLOADER_ERROR,LoaderUid_ErrorHandler);
			try
			{
				var tmp:Array = Util.decode(evt.target.data);
				systemUIDsBK = new Vector.<String>;
				var id:String;
				for each (var a:String in tmp)
				{
					id = getId(a);
					systemUIDsBK.push(id);
				}
			}
			catch(err:Error){trace("格式错误1")}
		}
		
		private function LoaderUid_ErrorHandler(evt:Event):void
		{
			var bl:BlockLoader = evt.target as BlockLoader;
			bl.removeEventListener(Event.COMPLETE,LoaderUid_CompleteHandler);
			bl.removeEventListener(BlockLoader.HTTPLOADER_ERROR,LoaderUid_ErrorHandler);
		}
		
		private function Loader_CompleteHandler(evt:Event):void
		{
			var bl:BlockLoader = evt.target as BlockLoader;
			bl.removeEventListener(Event.COMPLETE,Loader_CompleteHandler);
			bl.removeEventListener(BlockLoader.HTTPLOADER_ERROR,Loader_ErrorHandler);
			try
			{
				var tmp:Array = Util.decode(evt.target.data);
				var len:int = tmp.length;
				var lenlast:int = tmp.length - 3;
				
				var exs:String;
				var exd:String;
				var blankstr:String = " 　,█";
				var i:int;
				var tag:String;
				
				var tstr:String
				if(tmp.length > 1)
				{
					tstr = tmp[tmp.length-1];
					if(tstr.length>3 && tstr.indexOf("blk")==0){blankstr = tstr.slice(3);}
					else if (tstr.length>0)
					{systemWordBK.push(blankstr);}
				}
				exchangeTab = initExchangeTab(blankstr,exs,exd);

				if(tmp.length > 2)
				{
					tstr = tmp[tmp.length-2];
					if(tstr.length>3 && tstr.indexOf("exd")==0){exd = tstr.slice(3);}
					else 
					{
						tstr = wordfilter(tstr);
						if (tstr.length>0)
						{systemWordBK.push(blankstr);}
					}
				}
				
				if(tmp.length > 3)
				{
					tstr = tmp[tmp.length-3];
					if(tstr.length>3 && tstr.indexOf("exs")==0){exs = tstr.slice(3);}
					else 
					{
						tstr = wordfilter(tstr);
						if (tstr.length>0)
						{systemWordBK.push(blankstr);}
					}
				}
				if(exs != null && exd != null)
				{exchangeTab = initExchangeTab(blankstr,exs,exd);}				
				
				for (i = 0; i < lenlast; i++) 
				{
					tag = wordfilter(tmp[i]);
					if(tag != null && tag.length > 0){systemWordBK.push(tag);}
				}
				if(systemWordBK == null){return;}
			}
			catch(err:Error){trace("格式错误2")}
		}
		
		private function initExchangeTab(blankstr:String, exs:String, exd:String):Array
		{
			var i:int;
			var retTab:Array = null;
			if(blankstr != null)
			{
				if(retTab == null){retTab = [];}
				for (i = blankstr.length - 1;i >= 0;i --)
				{retTab[blankstr.charAt(i)] = "";	}
			}
			
			if(exs != null && exd != null)
			{
				if(retTab == null){retTab = [];}
				for (i = Math.min(exs.length,exd.length) - 1;i >= 0;i --)
				{retTab[exs.charAt(i)] = exd.charAt(i);	}
			}
			return retTab;
		}
		
		private function wordfilter(ins:String):String
		{
			if(ins.length <= 1){return ins}
			ins = ins.toLowerCase();
			var charstrs:Array = ins.split("");
			var charstrd:Vector.<String> = new Vector.<String>();
			var len:int = charstrs.length;
			var i:int,j:int;
			var currChar:String;
			var searChar:String;
			if(exchangeTab != null)
			{
				for(i=0;i<len;i++)
				{
					currChar = charfix(charstrs[i]);
					searChar = exchangeTab[currChar];
					charstrd.push(searChar == null?currChar:searChar);
				}
			}
			else
			{
				for(i=0;i<len;i++)
				{charstrd.push(charfix(charstrs[i]));}
			}
			return charstrd.join('');
		}
		
		private function charfix(s:String):String
		{
			var code:Number = s.charCodeAt(0);
			if(isNaN(code)){return "";}
			var codei:uint = code;
			if(65281<=codei && codei<=65373){return String.fromCharCode(codei & 0xFF | 0x20)}
			return s;			
		}
		
		private function Loader_ErrorHandler(evt:Event):void
		{
			var bl:BlockLoader = evt.target as BlockLoader;
			bl.removeEventListener(Event.COMPLETE,Loader_CompleteHandler);
			bl.removeEventListener(BlockLoader.HTTPLOADER_ERROR,Loader_ErrorHandler);
		}
		
		public function filterSource(i:int=0):Array
		{
			return fArr[i];
		}
		
		/** 单件 **/
		public static function getInstance():CommentFilter
		{
			if(instance == null)
			{
				instance = new CommentFilter();
			}
			return instance;
		}
		
		public function setEnable(id:int, enable:Boolean, item:int=0):void
		{//because delete operate makes some fArr[0][id] to null,so has to search over
			var tarr:Array = fArr[item];
			for (var i:int = 0; i < fArr[0].length; i++)
			{
				if (tarr[i].id == id)
				{
					tarr[i].enable = enable;
					return;
				}
			}
		}
		
		public function get bSettings():Array	
		{return [bEnable,bRoll,bTop,bBottom,blRoll,bSpecial,bGuest,bChange,bRegEnable,bVSelected,bIgnoreCase,bRepfiliter]	}
		
		public function set bSettings(a:Array):void
		{
			bEnable	= a[0];
			bRoll	= a[1];
			bTop	= a[2];
			bBottom	= a[3];
			blRoll	= a[4];
			bSpecial	= a[5];
			bGuest		= a[6];
			bChange		= a[7]
			bRegEnable	= a[8];
			bVSelected	= a[9];
			bIgnoreCase	= a[10];
			bRepfiliter = a[11];
			dispatchEvent(new Event(Event.CHANGE));	
		}
		
//		public function getDebug():void
//		{
//			var ret:String = "";
//			ret += "开关状态:" + [Comment.repeatfilter.toString(),repfiliterTimer != 0].join() + "\r\n";
//			ret += "数组状态:" + strs.length.toString() + "\r\n";
//			ret += "数组内容:" + '\r\n';
//			var arrKV:String = "";
//			for (var a:String in strs)
//			{
//				arrKV += a;
//				arrKV += '\t'
//				arrKV += strs[a] + '\r\n';				
//			}
//			ret += arrKV;
//			System.setClipboard(ret);
//		}
		
		public function deleteItem(id:int,item:int=0):void
		{//because delete operate makes some fArr[0][id] to null, so has to search over
			var tarr:Array =  fArr[item];
			for (var i:int = 0; i < tarr.length; i++)
			{
				if (tarr[i].id == id)
				{
					tarr.splice(i,1);					
					dispatchEvent(new Event(Event.CHANGE));
					return;
				}
			}
		}
		
		public function savetoSharedObject():void
		{
			try
			{
				var cookie:SharedObject = SharedObject.getLocal("ACPlayerFilter", '/');
				cookie.data['CommentFilter'] = toString();
				cookie.flush();
			}
			catch (e:Error) { };
		}
		
		public function loadFromSharedObject():void
		{
			try
			{
				var cookie:SharedObject = SharedObject.getLocal("ACPlayerFilter", '/');
				fromString(cookie.data['CommentFilter']);
			}catch (e:Error) { };
		}
		
		override public function toString():String
		{
			var a:Array = [];
			a.push(fArr[0],bEnable,bRegEnable,bVSelected,bIgnoreCase,bGuest,bRepfiliter,bRoll,bTop,bBottom,blRoll,bSpecial,bChange);
			return Util.encode(a);
		}
		
		public function fromString(source:String):void
		{
			try
			{
				var a:Array = Util.decode(source,false);
				if(a [0]!=null)
				{
					fArr[0] = a[0];
					var i:int;
					var tarr:Array = fArr[0];
					for (i=0;i<tarr.length;i++)	{tarr[i].id = i;}
					ids = i;
				};
				if(a[1]!=null){bEnable = a[1];}
				if(a[2]!=null){bRegEnable = a[2];}
				if(a[3]!=null){bVSelected = a[3];}
				if(a[4]!=null){bIgnoreCase = a[4];}
				if(a[5]!=null){bGuest		= a[5];}
				if(a[6]!=null){bRepfiliter = a[6];}				
				if(a[7]!=null){bRoll		= a[7];}
				if(a[8]!=null){bTop			= a[8];}
				if(a[9]!=null){bBottom		= a[9];}
				if(a[10]!=null){blRoll		= a[10];}
				if(a[11]!=null){bSpecial	= a[11];}
				if(a[12]!=null){bChange		= a[12];}								
				dispatchEvent(new Event(Event.CHANGE));	
			} catch(e:Error){				
				dispatchEvent(new Event(Event.CHANGE));	
			}
		}
		
		public function addItem(keyword:String,enable:Boolean=true,item:int = 0):int
		{
			if(keyword == '' || !keyword) {return 0};
			var mod:int;
			var exp:String;
			
			if (keyword.length < 3)
			{
				mod = 2;
				exp = keyword;
			}
			else
			{
				var head:String = keyword.substr(0, 2);
				exp = keyword.substr(2);
				switch(head)
				{
					case 'm='://模式
						mod = 0;
						break;
					case 'c='://颜色
						mod = 1;
						break;
					case 't=':	//关键字
						mod = 2;
						break;
					case 'u='://用户
						mod = 3;
						break;
					case 's='://字体大小
						mod = 4;
						break;
					default:
						mod = 2;
						exp = keyword;
						break;
				}
			}
			return add(mod, exp, keyword,enable,item);
			//          fArr[0].refresh();
		}
		
		private function add(mode:int, exp:String, data:String,enable:Boolean=true,item:int=0):int
		{
			//扫描现有关键字串。
			var expString:String = String(exp).replace(/(\^|\$|\\|\.|\*|\+|\?|\(|\)|\[|\]|\{|\}|\||\/)/g,'\\$1');
			var tarr:Array = fArr[item];
			var ltarr:int = tarr.length;
			for(var i:int=0;i<ltarr;i++)
			{
//				if(fArr[0][i].data == data && fArr[0][i].normalExp == expString && fArr[0][i].mode == mode)
				//覆盖原有项
				if(tarr[i].data == data)
				{
					tarr.splice(i,1,{
						'mode':mode,
						'data':data,
						'exp':exp,
						'normalExp':expString,
						'id':tarr[i].id,
						'enable':enable
					});
					dispatchEvent(new Event(Event.CHANGE));
					return i;
				}
			}
			//增加新项
			tarr.push( { 
				'mode':mode,
				'data':data,
				'exp':exp,
				'normalExp':expString,
				'id':++ids,
				'enable':enable} );			
			dispatchEvent(new Event(Event.CHANGE));
			return ids;
		}
		
		
		public function byothers(item:SingleCommentData):Boolean
		{
			if (item.strhash && item.strhash.length > 0)
			{
				if (strs[item.strhash] == null)
				{
					strs[item.strhash] = [item];
					return true;
				}
				else if (strs[item.strhash] is Array)
				{
					if (strs[item.strhash].indexOf(item) == -1)
					{
						for each (var s:SingleCommentData in strs[item.strhash])
						{
							if (Math.abs(item.stime - s.stime) < 10)
								return false;
						}
						strs[item.strhash].push(item);
					}
				}	
			}
			return true;
		}
			
		/**
		 * 校验接口
		 * @param item 弹幕数据
		 * @return int 0：正常，1：系统过滤，2：用户过滤，3：重复弹幕过滤
		 **/
		public function validate(item:SingleCommentData):int
		{
			var mod:int = int(item.mode);
			if (mod <= 6 &&!systemFil(item.text))	{return 1;}
			if(systemUIDsBK.indexOf(getId(CommentHandler.instance.commentUser))==-1 && systemUIDsBK.indexOf(getId(item.user))>=0){return 1;}
			if (!bEnable || item.border)   {return 0;}
			if(!bRoll)		{if(mod < 4)return 2;}
			if(!bBottom)	{if(mod == 4)return 2;}
			if(!bTop)		{if(mod == 5)return 2;}
			if(!blRoll)		{if(mod == 6)return 2;}
			if(!bSpecial)	{if(mod > 6)return 2;}
			if(!bGuest)		{if(uint(item.user)==0) return 2;}
			if(bRepfiliter) {if(!byothers(item)) return 3;}
			if(bChange && mod<=6){item.mode = '1';}
			
			var res:Boolean = !bVSelected;
			var tarr:Array;
			
			for (var i:int = 0; i < fArr.length; i++)
			{
				tarr = fArr[i];
				for (var j:int=0; j < tarr.length; j++)
				{
					var tmp:Object = tarr[j];
					if (tmp == null)	{continue}
					if (!tmp.enable)	{continue;}
					if (tmp.mode == 0)	//模式
					{
						if (int(tmp.exp) == mod)
						{
							res = bVSelected;
							break;
						}
					}
					else if (tmp.mode == 1)	//颜色
					{
						if (parseInt(tmp.exp, 16) == item.color)
						{
							res = bVSelected;
							break;
						}
					}
						
					else if(tmp.mode == 3)//用户
					{
						if(tmp.exp == item.user)
						{
							res = bVSelected;
							break;
						}
					}
					else if(tmp.mode == 4)//字体大小
					{
						if(tmp.exp == item.size)
						{
							res = bVSelected;
							break;
						}
					}
					else
					{
						if (bRegEnable)
						{
							if (tmp.exp != "" && tmp.exp!=null && String(item.text).search(tmp.exp) != -1)
							{
								res = bVSelected;
								break;
							}
						}
						else
						{
							if (String(item.text).search(tmp.normalExp) != -1)
							{
								res = bVSelected;
								break;
							}
						}
					}
				}
			}
			return res ? 0 : 2;
		}
	}
}