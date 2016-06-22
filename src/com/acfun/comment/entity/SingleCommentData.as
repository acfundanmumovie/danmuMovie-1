package com.acfun.comment.entity
{
	import com.acfun.External.PARAM;
	import com.acfun.Utils.Util;
	import com.acfun.comment.display.base.SimpleCommentEngine;
	import com.acfun.comment.interfaces.IComment;
	import com.acfun.comment.utils.CommentFilter;
	import com.adobe.utils.StringUtil;
	
	public class SingleCommentData
	{
		/**
		 * 评论基类，记录条评论
		 **/
		private var _mode:String;
		/** 记录评论是否已经被关键字检查 **/
		public var isChecked:Boolean = false;
		/** 补间类用 **/
		public var on:Boolean = false;
		/** 是不是本人发送的（有边界） **/
		public var border:Boolean = false;
		/** 字 **/
		private var _text:String;
		/** 色 **/
		private var _color:int;
		/** 大小 **/
		private var _size:int;
		/** 播放时间轴 **/
		private var _stime:Number;
		/** 发送时间 **/
		private var _timestamp:Number;
		/** 发送时间的字符串表示 **/
		private var _date:String;
		/** 发送者 **/
		private var _user:String;
		/** 是不是预览 **/
		private var _preview:Boolean;
		/** 锁定 **/
		private var _isLock:Boolean;
		/** 编号,内部调用用 **/
		private var _index:int;
		/** 弹幕id **/
		private var _commentid:String = "null";
		/** 新弹幕系统弹幕类型  0：非会员，1：锁定，2:会员，3: 合作**/
		private var _type:String = "";
		/** 过滤类别   0：正常，1：系统过滤，2：用户过滤，3：重复弹幕过滤 **/
		private var _filterType:int = 0;
		
		/** 特殊评论的附加选项 **/
		public var addon:Object;
		/** 特殊评论总时长 （滚动弹幕时长与窗口大小有关，无法事先计算） **/
		public var specialDuration:Number = 0;
		/** 特殊弹幕链接 **/
		public var url:String;
		
		public var strhash:String;
		
//		public var display:IComment;
		
		private var _c:String;
		private var _m:String;
		private var _timeStr:String;
		
		/** 从右往左的滚动弹幕,值为模式号的字符串 **/
		public static const FLOW_RIGHT_TO_LEFT:String = '1';
		/** 从左往右的滚动弹幕 **/
		public static const FLOW_LEFT_TO_RIGHT:String = '6';
		/** 顶部字幕 **/
		public static const TOP:String = '5';
		/** 底部字幕 **/
		public static const BOTTOM:String = '4';
		/** 固定字幕 **/
		public static const FIXED_POSITION_AND_FADE:String = '7';
		/** 脚本弹幕 **/
		public static const ECMA3_SCRIPT:String = '10';
		
		public static const CHAR_DISLODGES:String = '！. 。';
		
		public static const hashcalculate:Boolean = true;
		
		public static const CHAR_MAXS:int = 4;
		
		public static const STRING_LENGTH_MAXS:int = 30;
		
		public var deleted:Boolean = false;
		
		public var isTest:Boolean = false;
		
		public function SingleCommentData(mode:String,text:String,color:int,size:int,stime:Number,timestamp:Number,date:String,user:String,preview:Boolean,index:int,c:String,m:String,id:String,type:String,islock:Boolean = false,border:Boolean=false)
		{
			_commentid = id;
			_type = type;
			_mode = mode;
			_text = text;
			_color = color;
			_size = size;
			_stime = stime;
			_timestamp = timestamp;
			if(date != null)
			{
				_date = date;
			}
			else
			{
				var now:Date = new Date();
				now.setTime(timestamp);
				_date = Util.date(now);
			}
			_user = user;
			_preview = preview;
			_isLock = islock;
			_index = index;
			if(c == null)
			//stime : c[0],color : c[1],mode : c[2],size:c[3],user:c[4],time:c[5]
			{_c = _stime + "," + _color + "," + _mode + "," + _size + "," + _user + "," + _timestamp;}
			else			{_c = c;}
			
			if(m == null)	{_m = text;}
			else			{_m = m;}
			
			this.border = border;
			
			_timeStr = Util.digits(_stime-0);
			
			countsfill();
			
			validate();
		}
		
		public function validate():void
		{
//			_filterType = CommentFilter.getInstance().validate(this);
			_filterType = 0;
		}
		
		private function countsfill():void
		{
			if(_isLock || _mode == FIXED_POSITION_AND_FADE || border)
				return;
			
			var str:String = StringUtil.trim(_text);
			var length:int = str.length;
			var letters:Array = [];
			for (var i:int=0;i<length;i++)
			{
				var c:String = str.charAt(i);
				if (letters.indexOf(c) == -1)
					letters.push(c);
			}
			letters.sort();
			strhash = letters.join("");
		}	
		
		public function getencode():String
		{
			return Util.encode({mode:mode,
				color:color,
				size:size,
				stime:stime,
				user:user,
				message:getText(),
				time:timestamp,
				test:isTest?1:0
			});
		}
		
		public function fixtime(ti:Number):void
		{
			_stime+=ti;
			_timeStr = Util.digits(_stime-PARAM.acInfo.startTime);			
		}
		
		public function getText():String		{return mode!=FIXED_POSITION_AND_FADE?_text:Util.encode(addon);}

		public function to2String():String
		{
			var debug:String = "--------评论Dump信息--------\r\n";
			debug += "评论时间轴：" + stime.toString() + '[' + Util.digits(stime) + "]\r\n";
			debug += "评论字号：" + size.toString() + "\r\n";
			debug += "评论颜色：0x" + color.toString(16) + "\r\n";
			debug += "评论类型：" + mode + "\r\n";
			debug += "评论内容：" + text;
			return debug;
		}
		
		public function get mode():String		{return _mode;}
		public function set mode(value:String):void	{_mode = value;}
		public function get text():String		{return _text;}
		public function set text(val:String):void		{_text = val;}
		public function get color():int		{return _color;	}
		public function get size():int		{return _size;}
		public function get stime():Number	{return _stime;	}
		public function get timestamp():Number{return _timestamp;}
		public function get date():String		{return _date;}
		public function get user():String		{return _user;}
		public function set user(val:String):void		{_user = val;}
		public function get preview():Boolean	{return _preview;}
		public function set preview(val:Boolean):void	{ _preview = val; }
		public function get isLock():Boolean	{return _isLock;}
		public function set isLock(value:Boolean):void	{_isLock= value;}
		public function get index():int		{return _index;	}
		public function get orignStr():String	{return Util.encode({c : _c,m : _m});}
		public function get timeStr():String	{return _timeStr;}
		public function get commentid():String	{return _commentid;}
		public function get type():String	{return _type;}
		public function get filterType():int { return _filterType; }
		public function get name():String { return addon?addon.name:null; }
	}
}