package com.acfun.Utils
{
	import com.acfun.External.LocalStorage;
	import com.acfun.signal.register;
	import com.adobe.serialization.json.JSON;
	
	//import fl.controls.CheckBox;
	//import fl.controls.ColorPicker;
	//import fl.controls.LabelButton;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.Font;
	import flash.text.FontType;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	public class Util
	{
		public function Util()
		{}
		
		public static function date(now:Date=null) : String
		{
			if (now == null){now = new Date();}
			return now.getFullYear() + "-" + zeroPad(now.getMonth() + 1) + "-" + zeroPad(now.getDate()) + " " + zeroPad(now.getHours()) + ":" + zeroPad(now.getMinutes()) + ":" + zeroPad(now.getSeconds());
		}
		
		public static function date2(now:Date=null) : String
		{
			if (now == null){now = new Date();}
			return now.getFullYear() + zeroPad(now.getMonth() + 1) + zeroPad(now.getDate());
		}
		
		public static function zeroPad(number:*, width:int = 2):String {
			var ret:String = "" + number;
			while( ret.length < width )
				ret="0" + ret;
			return ret;
		}
		
		public static function digits(nbr:Number):String {
			var str:String = nbr<0?"-":"";
			nbr = int(Math.abs(nbr));
			var min:Number = Math.floor(nbr / 60);
			var sec:Number = Math.floor(nbr % 60);
			str += zeroPad(min) + ':' + zeroPad(sec);
			return str;
		}
		
		public static function covertToTime(number:int):String
		{
			var date:Date = new Date();
			date.time = number;			
			return "" + zeroPad(date.hoursUTC,2) + ":" + zeroPad(date.minutesUTC,2) + ":" + zeroPad(date.secondsUTC,2) + "." + zeroPad(date.millisecondsUTC,3); 
		}
		
		public static function addUrlParam(source:String,key:String,value:Object):String
		{
			if (key == null || key.length == 0)
				return source;
			
			var reg:RegExp = new RegExp(key+"=\\w*(?![^&])");
			if (reg.test(source))
				return source.replace(reg,key+"="+value); 
			else
				return source + (source.indexOf("?") == -1?"?":"&") + key + "=" + value;
		}
		/**
		 * 颜色数据转化为6位格式字符串 
		 * 
		 */		
		public static function convertToColorString(color:uint):String
		{
			var str:String = color.toString(16).toUpperCase();
			str = zeroPad(str,6);
			return str;
		}
		
		public static function bindComponent(button:Object,mc:MovieClip,color:uint):void
		{
			mc.buttonMode = true;
			mc.mouseChildren = false;
			
			/*var ct:ColorTransform = new ColorTransform();
			ct.color = color;
			
			button.addEventListener(Event.CHANGE,onChange);
			mc.addEventListener(MouseEvent.CLICK,function():void{
				button.selected = !button.selected;
				onChange(null);
			});
			
			onChange(null);
			
			function onChange(event:Event):void
			{
				if (button.selected)
					mc.transform.colorTransform = ct;
				else
					mc.transform.colorTransform = new ColorTransform();
			}*/
		}
		
		public static function hasFont(fontName:String):Boolean
		{
			var fonts:Array = Font.enumerateFonts(true);
			for each (var font:Font in fonts)
			{
				if (font.fontType == FontType.DEVICE && font.fontName == fontName)
					return true;
			}
			return false;
		}
		
		private static var saveTimeRecordPosition:int = -1; 
		public static function saveTimeRecord(vid:String,time:Number):void
		{
			var records:Array = LocalStorage.getValue(LocalStorage.VIDEO_TIME_RECORD,[]);
			if (saveTimeRecordPosition == -1)	//首次计算位置
			{
				for (var i:int=0;i<records.length;i++)				
					if (records[i].vid == vid)
						saveTimeRecordPosition = i;
				
				if (saveTimeRecordPosition == -1)
				{
					if (records.length >= 16)
					{
						records.shift();
						saveTimeRecordPosition = 15;	
					}
					else
					{
						saveTimeRecordPosition = records.length;	
					}
				}
			}
			
			records[saveTimeRecordPosition] = {vid:vid,time:time};
			LocalStorage.setValue(LocalStorage.VIDEO_TIME_RECORD,records,false);
		}
		
		public static function getTimeRecord(vid:String):Number
		{
			var records:Array = LocalStorage.getValue(LocalStorage.VIDEO_TIME_RECORD,[]);
			for (var i:int=0;i<records.length;i++)				
				if (records[i].vid == vid)
					return records[i].time;
			
			return 0;
		}
		
		public static function dragEnable(sprite:Sprite,controlSprite:Sprite,rect:Rectangle,stage:Stage):void
		{
			sprite.addEventListener(MouseEvent.MOUSE_DOWN,function(event:MouseEvent):void{
				if (event.target == controlSprite)
				{
					sprite.startDrag(false,rect);							
					stage.addEventListener(MouseEvent.MOUSE_UP,function():void{							
						stage.removeEventListener(MouseEvent.MOUSE_UP,arguments.callee);
						sprite.stopDrag();
					});	
				}
			});		
		}
		
		/**
		 * 对对象进行JSON序列化，兼容4.6
		 * @param 需要序列化的对象
		 * @return 序列化后的JSON字符串
		 * 
		 */
		public static function encode(input:Object):String {return com.adobe.serialization.json.JSON.encode(input);}
		
		/**
		 * 解析JSON字符串，兼容4.6
		 * @param input 需要反序列化对象
		 * @param strict 是否启用严格模式
		 * @return 序列化以后的对象
		 * 
		 */
		public static function decode(input:String,strict:Boolean=true):* {return com.adobe.serialization.json.JSON.decode(input,strict);}
		
		public static function getCenterRectangle(container:Rectangle,target:Rectangle):Rectangle
		{
			var sx:Number = 1;
			var sy:Number = 1;
			if (target.width > 0 && target.height > 0)			
			{
				sx = container.width / target.width;
				sy = container.height / target.height;	
			}
			
			var x:Number,y:Number,w:Number,h:Number;
			if (sx < sy)
			{
				w = target.width * sx;
				h = target.height * sx;
				x = 0;
				y = (container.height - h) / 2;
			}
			else
			{
				w = target.width * sy;
				h = target.height * sy;
				x = (container.width - w) / 2;
				y = 0;
			}
			return new Rectangle(x,y,w,h);
		}
		
		/**
		 * 二分插入 
		 * @param arr
		 * @param a
		 * @param fn
		 * 
		 */
		public static function binsert(arr:*, a:Object, fn:Function=null):void
		{
			if (fn == null) fn = numberCompare;
			var i:int = bsearch(arr, a, fn);
			arr.splice(i, 0, a);
		}
		/**
		 * 二分查找 
		 * @param arr
		 * @param a
		 * @param fn
		 * @return 查找的的Index(arr[index]>a>=arr[index-1])
		 * 
		 */		
		public static function bsearch(arr:*, a:Object,fn:Function=null):int
		{
			if (fn == null) fn = numberCompare;
			if (arr.length == 0)	{return 0;}
			if (fn(a, arr[0]) < 0)	{return 0;}
			
			if (fn(a, arr[arr.length - 1]) >= 0)	{return arr.length;}
			
			var low:int = 0;
			var hig:int = arr.length - 1;
			var i:int;
			var count:int = 0;
			while (low <= hig)
			{
				i = Math.floor((low + hig + 1) / 2);
				count++;
				
				if (fn(a,arr[i-1])>=0 &&fn(a,arr[i])<0)	{return i;}
				else if (fn(a, arr[i - 1]) < 0)			{hig = i - 1;}
				else if (fn(a, arr[i]) >= 0)			{low = i;}
				else {throw new Error('查找错误.');}
				
				if (count > 1000)
				{
					throw new Error('查找超时.');
					break;
				}
			}
			return -1;
		}
		
		public static function numberCompare(a:Number,b:Number):int
		{
			if (a > b) 		return 1;
			else if (a < b)	return -1;
			else			return 0;
		}
		
		public static function get isChromeFlash():Boolean
		{
			return Capabilities.manufacturer.indexOf("Google") != -1
		}
		
		public static function isJsonTestFunc(data:String):Boolean
		{
			var flag:Boolean = false;
			try
			{
				Util.decode(data);
				flag = true;
			}
			catch(e:Error)
			{
				Log.error("[JSON PARSE ERROR]",data);
			}
			return flag;
		}
		
		/** 深度拷贝 **/
		public static function copy(obj:*):*
		{
			registerClassAlias(obj.toString(),getDefinitionByName(getQualifiedClassName(obj)) as Class);			
			var ba:ByteArray = new ByteArray();
			ba.writeObject(obj);
			ba.position = 0;
			var copyObj:* = ba.readObject();
			ba.clear();
			return copyObj;
		}
		
		/**
		 * 一段时间内只执行一次 
		 * @param time 毫秒
		 * @param func 要执行的函数
		 * @param params 函数参数
		 * @return 生成的函数,可直接用作eventListener
		 * 
		 */		
		public static function runOnceIn(time:int,func:Function,...params):Function
		{
			var last:int=0;
			var seed:uint;
			
			function run(e:*):void
			{
				if (getTimer() - last < time)
				{
					clearTimeout(seed);
					seed = setTimeout.apply(null,[func,time].concat(params));
				}
				else
				{
					seed = setTimeout.apply(null,[func,time].concat(params));
				}
				last = getTimer();
			}
			
			return run;
		}
		
		/**
		 * 取得应用滤镜后的范围 
		 * @param source 目标对象
		 * @param filters 滤镜数组
		 * @return Rectangle范围
		 * 
		 */		
		public static function getFilterRect(source:DisplayObject,filters:Array):Rectangle
		{
			var rect:Rectangle = source.getRect(source);
			var data:BitmapData = new BitmapData(rect.width,rect.height);
			var filterRect:Rectangle = rect.clone();
			for each (var filter:BitmapFilter in filters)
			{
				var temp:Rectangle = data.generateFilterRect(rect,filter);
				filterRect = filterRect.union(temp);
			}
			data.dispose();
			return filterRect;
		}
		
		public static function colorPickerExtend(cp:Object):void
		{
			/*cp.addEventListener(Event.COPY,function(event:Event):void{
				System.setClipboard(cp.textField.text);
			});
			cp.addEventListener(Event.PASTE,function(event:Event):void{
				var text:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT).toString();
				cp.textField.text = text;
			});*/
		}
	}
}