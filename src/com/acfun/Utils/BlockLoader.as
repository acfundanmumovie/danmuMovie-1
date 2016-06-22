package com.acfun.Utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	/**
	 *  加载完成
	 */	
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 *  加载出错 
	 */	
	[Event(name="httploader_error", type="flash.events.Event")]
	
	public class BlockLoader extends EventDispatcher
	{
		public static const HTTPLOADER_ERROR:String = "httploader_error";
		
		private var _url:String;
		
		private var _urlloader:URLLoader;
		
		private var _request:URLRequest;
		
		private var _dataFormat:String;
		
		private var _trytimes:int;
		
		private var _timeout:int;
		
		private var _timer:Timer;
		
		private var _event:Event;
		
		private var _loadonce:Boolean = false;
		
		private var _testFunc:Function;
		
		private var _random:Boolean;
		
		private var _log:Array;
		
		public function BlockLoader(url:String = "",dataFormat:String = "",trytimes:uint = 3,timeout:uint = 20000,testFunc:Function=null,random:Boolean=true)
		{
			_dataFormat = dataFormat;
			_trytimes = trytimes;
			_timeout = timeout;
			_url = url;
			_testFunc = testFunc;
			_random = random;
			_log = [];
			
			if (url.length > 0)
			{
				_request = new URLRequest(url);
				sendRequest();
			}
		}
		
		public function get data():* 
		{
			if (_urlloader)
				return _urlloader.data;			
			else
				return null;
		}
		
		public function load(request:URLRequest):void
		{
			_request = request;
			sendRequest();
		}
		
		public function get trytimes():int
		{
			return _trytimes;
		}
		
		public function get log():String
		{
			return _log.join("\n");
		}
		
		private function sendRequest():void
		{
			_urlloader = new URLLoader(_request);
			if (_dataFormat.length > 0) 
				_urlloader.dataFormat = _dataFormat;
			_urlloader.addEventListener(ProgressEvent.PROGRESS,progress);
			_urlloader.addEventListener(Event.COMPLETE,complete);
			_urlloader.addEventListener(IOErrorEvent.IO_ERROR,ioerror);
			_urlloader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityerror);
			
			_timer = new Timer(_timeout,1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimeout);
			_timer.start();
			
			_loadonce = true;
		}
		
		public function unload():void
		{
			try{
				_urlloader.removeEventListener(Event.COMPLETE,complete);
				_urlloader.removeEventListener(IOErrorEvent.IO_ERROR,ioerror);
				_urlloader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,securityerror);
				_urlloader.close();				
			}catch(e:Error){}
			
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimeout);
			_timer.reset();
		}
		
		private function progress(event:ProgressEvent):void
		{
			_timer.reset();
			_timer.start();
		}
		
		private function onTimeout(event:TimerEvent):void
		{
			var msg:String = "[BlockLoader]  读取 " + _request.url + " 时发生超时错误";
			_log.push(msg);
			Log.error(msg);
			reload();
		}
		
		private function securityerror(event:SecurityErrorEvent):void
		{
			_event = event;
			
			var msg:String = "[BlockLoader]  读取 " + _request.url + " 时发生安全策略错误";
			_log.push(msg);
			Log.error(msg);
			reload();
		}
		
		private function ioerror(event:IOErrorEvent):void
		{
			_event = event;
			
			var msg:String = "[BlockLoader]  读取 " + _request.url + " 时发生IO错误";
			_log.push(msg);
			Log.error(msg);
			reload();
		}
		
		private function complete(event:Event):void
		{
			if (_testFunc!=null && !_testFunc(_urlloader.data))
				reload();
			else
			{
				_timer.reset();
				dispatchEvent(event);
			}	
		}
		
		private function reload():void
		{
			_trytimes--;
			_timer.reset();
			if (_trytimes > 0)
			{
				try{
					_urlloader.close();
				}catch(e:Error){}									
				setTimeout(function():void{
					if (_urlloader)
					{
						if (_loadonce && _random)
						{
							_request.url = Util.addUrlParam(_url,"acran",Math.random());							
						}
						_urlloader.load(_request);						
						_timer.start();	
					}	
				},1000);
			}
			else
			{
				var msg:String = "[BlockLoader]  读取或解析" + _request.url + "失败";
				_log.push(msg);
				Log.error(msg);
				dispathError();
			}
		}
		
		private function dispathError():void
		{
			unload();
			
			dispatchEvent(new Event(HTTPLOADER_ERROR));
			if (_event && this.hasEventListener(_event.type))
				dispatchEvent(_event);
		}
	}
}