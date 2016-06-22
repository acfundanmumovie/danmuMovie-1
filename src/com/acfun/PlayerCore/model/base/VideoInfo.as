package com.acfun.PlayerCore.model.base
{
	import com.acfun.External.AcConfig;
	import com.acfun.External.ConstValue;
	import com.acfun.External.PARAM;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.PlayerCore.model.interfaces.IVideoInfo;
	import com.acfun.Utils.BlockLoader;
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	import com.acfun.signal.notify;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	
	/**
	 * 视频信息读取完毕 
	 */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * 视频信息无法正常解析 
	 */	
	[Event(name="error", type="flash.events.Event")]
	
	/**
	 * 视频地址解析基类  不可new 
	 * @author sky
	 * 
	 * 2013/7/25 
	 */
	public class VideoInfo extends EventDispatcher implements IVideoInfo
	{	
//		private static const VIDEO_PARSE_API:String = "http://acfnic2.aliapp.com/index.php?vid=";
		protected static const VIDEO_PARSE_API:String = "http://jiexi.acfun.info/index.php?vid=";
		
		protected static var VIDEO_RATES_CODE:Array = ["C40","C30","C20","C10"];
		
		public static var VIDEO_RATES_STRING:Array = ["原画","超清","高清","流畅"];
			
		/** 视频id  **/
		protected var _vid:String;
		
		/** 视频源类型 **/
		protected var _type:String;
		
		/** 视频文件类型(flv/mp4) **/
		protected var _fileType:String;
		
		/** 跳段是否使用秒数（true：秒   false：字节) **/
		protected var _useSecond:Boolean = false;
		
		/** 跳段参数名 **/
		protected var _startParamName:String = "start";
		
		/** 服务器返回原始信息 **/
		protected var _rawInfo:Object = {};
		
		/** 分段视频地址 **/
		protected var _urlArray:Array = [];
		
		/** 每段视频长度，第一个为总长度，以毫秒为单位**/
		protected var _vtimems:Array = [];
		
		/** 视频码率信息 **/
		protected var _rateInfo:Array = [];
		
		/** 视频清晰度,对应VIDEO_LEVEL **/
		protected var _rate:int = 0;
		
		protected var _tryTimes:int = 0;
		
		protected var _success:Boolean = true;
		
		/** 获取视频信息是否成功 **/
		public function get success():Boolean
		{
			return _success;
		}
		
		protected var _msg:String = "";
		
		/** 获取信息结果  **/
		public function get msg():String
		{
			return _msg;
		}
		
		protected var _disableSeekJump:Boolean = false;
		/** 禁止跳段  **/
		public function get disableSeekJump():Boolean
		{
			return _disableSeekJump;
		}
				
		public function VideoInfo(vid:String,type:String)
		{
			_type = type;
			_vid = vid;
			
			load();
		}
		
		protected function dispatchError(msg:Object=null):void
		{
			_success = false;
			_msg = "可能视频源已被删除或失效。";
			if (msg is String)
				_msg = msg.toString();
			Log.error(_msg);
			dispatchEvent(new Event("error"));
		}
		
		protected function dispatchComplete():void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function load(nocache:Boolean=false):void
		{	
			var loader:BlockLoader = new BlockLoader(VIDEO_PARSE_API + PARAM.vid + (nocache?"&cache=no&acran="+Math.random():""),"",3,20000,Util.isJsonTestFunc);
			loader.addEventListener(Event.COMPLETE,function():void{
				_rawInfo = Util.decode(loader.data);
				
				if (_rawInfo.success)
				{
					_rateInfo = [];
					for (var i:int=0;i<VIDEO_RATES_CODE.length;i++)
					{
						if (VIDEO_RATES_CODE[i] in _rawInfo.result)
							_rateInfo.push(i);
					}
					
					setRate(AcConfig.getInstance().video_quality,nocache);					
				}
				else
				{
					Log.error(_rawInfo.message);
					dispatchError();
				}
			});
			loader.addEventListener("httploader_error",dispatchError);
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get fileType():String
		{
			return _fileType;
		}
		
		public function get vid():String
		{
			return _vid;
		}
		
		public function get rawInfo():Object
		{
			return _rawInfo;
		}
		
		public function get useSecond():Boolean
		{
			return _useSecond;
		}
		
		public function get status():String
		{
			return "";
		}
		
		public function get rateInfo():Array
		{
			return _rateInfo;
		}
		
		public function get rate():int
		{
			return _rate;
		}
		
		public function get rateString():String
		{
			return VIDEO_RATES_STRING[_rate];
		}
		
		public function get totalTime():Number
		{
			return _vtimems[0]/1000;
		}
		
		public function get count():int
		{
			return _vtimems.length-1;
		}
		
		public function get urls():Array		
		{
			return _urlArray;
		}
		
		public function get vtimes():Array		
		{
			return _vtimems;
		}
		
		public function getPartVideoInfo(onResult:Function,partIndex:int,partPosition:Number=0):void
		{
			if (!_success)
			{
				dispatchError(_msg);
				return;
			}
			
			//参数监测
			if (partIndex >= _urlArray.length)
			{
				Log.error("getPartVideoInfo参数错误");
				partIndex = 0;
			}
			
			//addParam处理
			var url:String = _urlArray[partIndex];
			var duration:Number = _vtimems[partIndex+1]/1000;
			if (_useSecond && (duration - partPosition) < 10)	//发现部分视频跳段的秒数太靠后（可能后面没有关键帧）的情况下，会返回错误（code500），比如优酷视频，在此做一个兼容，不允许跳到分段最后10秒内
				partPosition = duration - 10;
			if (partPosition > 0)				
				url = Util.addUrlParam(url,_startParamName,int(partPosition));
			
			var pvi:PartVideoInfo = new PartVideoInfo(	_rawInfo,
														partIndex,
														url,
														duration,
														_tryTimes,
														_rate);
			onResult(pvi);
		}
		
		public function getIndexOfPosition(position:Number):Array
		{
			var total:Number = 0;
			for (var i:int=1;i<_vtimems.length;i++)
			{
				total += int(_vtimems[i]);
				if (position < (total/1000))
				{
					var p:Number = position-(total-_vtimems[i])/1000;
					if (p < 0.5) p = 0;
					return [i-1,p];
				}
			}
			return [0,0];
		}
		
		public function setRate(rate:int,force:Boolean=false):Boolean
		{
			if (rate < 0 || rate > VIDEO_RATES_CODE.length)
				rate = 0;
			
			while(rate < VIDEO_RATES_CODE.length)
			{
				var rateString:String = VIDEO_RATES_CODE[rate]; 
				if (rateString in _rawInfo.result)
				{
					if (!force && rate == _rate && _urlArray.length != 0)
						return false;
					
					_rate = rate;
					notify(SIGNALCONST.SET_PLAYER_RATE_CHANGED,_rate,_rateInfo,VIDEO_RATES_STRING);
					
					_vtimems = [];
					_urlArray = [];
					
					_vtimems.push(_rawInfo.result[rateString].totalseconds * 1000);
					
					for each (var file:Object in _rawInfo.result[rateString].files)
					{
						_urlArray.push(file.url);
						_vtimems.push(file.seconds * 1000);	
						_fileType = file.type;
					}
					//mp4兼容
					if (_fileType == "mp4")
					{
						_useSecond = true;
						_startParamName = "start";
					}
					
					dispatchComplete();
					return true;
				}
				else
				{
					rate++;
				}
			}
			dispatchError();
			return false;
		}
		
		public function refresh():void
		{
			_tryTimes++;
			
			if (_tryTimes < 3)
			{
				//延迟2秒再重试
				setTimeout(function():void{
					Log.debug("[VideoInfo] refresh cache ! try ",_tryTimes);
					load(true);
				},4000);
			}
			else
			{
				_tryTimes = 0;
				dispatchError("超过重试次数。");				
				_success = true;
			}
		}
	}
}