package com.acfun.Utils
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;

	public class ClassLoader
	{
		private var _loader:Loader;
		
		public function ClassLoader(moduleUrl:String,onComplete:Function)
		{
			var context:LoaderContext;
			if (Security.sandboxType == Security.REMOTE)
				context = new LoaderContext(false,null,SecurityDomain.currentDomain);
			else
				context = new LoaderContext(); 
			
			_loader = new Loader();
			_loader.load(new URLRequest(moduleUrl),context);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function():void{
				throw new Error("module " + moduleUrl + " load failed!");
			});
		}
		
		public function hasClass(className:String):Boolean
		{
			return _loader && _loader.contentLoaderInfo.applicationDomain.hasDefinition(className);
		}
		
		public function getClass(className:String):Class
		{
			if (_loader)
			{
				return _loader.contentLoaderInfo.applicationDomain.getDefinition(className) as Class;
			}
			return null;
		}
		
		public function unload():void
		{
			_loader.unload();			
		}
	}
}