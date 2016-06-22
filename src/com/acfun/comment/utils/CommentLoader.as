package com.acfun.comment.utils
{
	import com.acfun.Utils.BlockLoader;
	import com.acfun.Utils.Util;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class CommentLoader extends EventDispatcher
	{
		public var url:String;		
		public var pageSize:int = 500;
		public var max:int = 500;
		public var callback:Function;
		public var pageSizeKey:String = "pageSize";
		public var pageNoKey:String = "pageNo";
		
		private var _pageNo:int;
		private var _loader:BlockLoader;
		
		public function CommentLoader()
		{
			super(null);
		}
		
		public function load(startPage:int=1):void
		{
			_pageNo = startPage;
			
			var loadUrl:String = url;
			loadUrl = Util.addUrlParam(loadUrl,pageSizeKey,pageSize);
			loadUrl = Util.addUrlParam(loadUrl,pageNoKey,_pageNo);
			
			if (_loader)
			{
				_loader.unload();
				_loader.removeEventListener(Event.COMPLETE,onComplete);
				_loader.removeEventListener("httploader_error",onError);
			}
			_loader = new BlockLoader(loadUrl,"",3,5000,null,false);
			_loader.addEventListener(Event.COMPLETE,onComplete);
			_loader.addEventListener("httploader_error",onError);
		}
		
		protected function onComplete(event:Event):void
		{
			if (!callback(_loader.data,_pageNo * pageSize > max,(_pageNo - 1) * pageSize > max))
			{
				dispatchEvent(event);
			}
			else
			{
				load(_pageNo+1);
			}
		}
		
		protected function onError(event:Event):void
		{
			dispatchEvent(event);
		}
	}
}