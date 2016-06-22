package com.acfun.test 
{ 
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
      
      
    public class LocalFileLoader extends EventDispatcher 
    { 
		public var _loader:Loader;
		private static var _instance:LocalFileLoader;
		private var _stageWidth:Number=0;
		private var _stageHeight:Number=0;
		public static var ERROR:String = "error"
		
        public function LocalFileLoader() 
        { 
              
        } 
		
		public static function get instance():LocalFileLoader
		{
			if(_instance ==null)
			{
				_instance = new LocalFileLoader();
			}
			return _instance;
		}
		
		public function browseFileSystem(loadUrl:String=null,getWidth:Number=0,getHeight:Number=0):void 
		{ 
			_stageWidth = getWidth;
			_stageHeight = getHeight;
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler); 
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler); 
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler) 
			if(loadUrl !=null)_loader.load(new URLRequest(loadUrl))
			
			
		}
          
        protected function ioErrorHandler(event:IOErrorEvent):void
		{ 
           // writeText("ioErrorHandler: " + event); 
			dispatchEvent(new Event(LocalFileLoader.ERROR)); 
        } 
          
        protected function securityErrorHandler(event:SecurityErrorEvent):void 
		{ 
          //  writeText("securityError: " + event); 
			dispatchEvent(new Event(LocalFileLoader.ERROR)); 
        } 
          
        protected function progressHandler(event:ProgressEvent):void 
		{ 
           // var file:FileReference = FileReference(event.target); 
           // writeText("progressHandler: bytesLoaded=" + event.bytesLoaded + "/" +event.bytesTotal); 
              
        } 
          
        protected function completeHandler(event:Event):void 
		{ 
            trace("loadJpgComplete")
			setLoaderY(_stageWidth,_stageHeight);
			
			//dispatchEvent(new Event(Event.COMPLETE)); 
        }
		
		public function setLoaderY(getWidth:Number=0,getHeight:Number=0):void
		{
			_loader.height = getHeight;
			_loader.scaleX = _loader.scaleY; 
			if(_loader.width >getWidth)
			{
				_loader.width =getWidth;
				_loader.scaleY = _loader.scaleX;
			}
			_loader.x =(getWidth - _loader.width) * .5;
			_loader.y= (getHeight - _loader.height) * .5;//_loader.
		}
          
       
    } 
} 