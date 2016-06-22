/**
* This class lets you play animated GIF files in AS3
* @author Thibault Imbert (bytearray.org)
* @version 0.6
*/

package com.gif {	
	import com.gif.decoder.GIFDecoder;
	import com.gif.errors.FileTypeError;
	import com.gif.events.FileTypeEvent;
	import com.gif.events.FrameEvent;
	import com.gif.events.GIFPlayerEvent;
	import com.gif.events.TimeoutEvent;
	import com.gif.frames.GIFFrame;
	
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.errors.ScriptTimeoutError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class Gif extends Bitmap
	{
		private var urlLoader:URLLoader;
		private var gifDecoder:GIFDecoder
		private var aFrames:Array;
		private var myTimer:Timer;
		private var iInc:int;
		private var iIndex:int;
		private var auto:Boolean;
		private var arrayLng:uint;
		
		/**
		 * 当前gif的key 值用于在_map中共享数据
		 */
		private var _key:String = "";
		
		static private var _map:Dictionary = new Dictionary(true);
		
		static private var _decoderMap:Dictionary = new Dictionary(true);
		/**
		 * 队列加载gif动态
		 */
		static private var _queue:Vector.<Object> = new Vector.<Object>();
		/**
		 * 加载执行标记
		 */
		static private var _excute:Boolean = false;
		
		public function Gif ( pAutoPlay:Boolean = true )
		{
			auto = pAutoPlay;
			iIndex = iInc = 0;
			
			myTimer = new Timer ( 0, 0 );
			aFrames = new Array();
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			urlLoader.addEventListener ( Event.COMPLETE, onComplete );
			urlLoader.addEventListener ( IOErrorEvent.IO_ERROR, onIOError );
			
			myTimer.addEventListener ( TimerEvent.TIMER, update );
			
			gifDecoder = new GIFDecoder();
			
		}
		
		private function onIOError ( pEvt:IOErrorEvent ):void
		{
			dispatchEvent ( pEvt );	
		}
		
		private function onComplete ( pEvt:Event ):void 
		{
			readStream ( pEvt.target.data );	
		}
		
		private function readStream ( pBytes:ByteArray ):void
		{
			var gifStream:ByteArray = pBytes;
			
			aFrames = new Array;
			iInc = 0;
			
			try 
			{
				gifDecoder.read ( gifStream );
				
				var lng:int = gifDecoder.getFrameCount();
				
				for ( var i:int = 0; i< lng; i++ ) 
					aFrames[int(i)] = gifDecoder.getFrame(i);
				
				arrayLng = aFrames.length;
				
				_map[_key] ||= aFrames;
				_decoderMap[_key] ||= gifDecoder;
				
				auto ? play() : gotoAndStop (1);
				
				dispatchEvent ( new GIFPlayerEvent ( GIFPlayerEvent.COMPLETE , aFrames[0].bitmapData.rect ) );
				handleMatcher();
			} catch ( e:ScriptTimeoutError )
			{	
				dispatchEvent ( new TimeoutEvent ( TimeoutEvent.TIME_OUT ) );
				
			} catch ( e:FileTypeError )
			{	
				dispatchEvent ( new FileTypeEvent ( FileTypeEvent.INVALID ) );
				
			} catch ( e:Error )
			{
				throw new Error ("An unknown error occured, make sure the GIF file contains at least one frame\nNumber of frames : " + aFrames.length);	
			}

		}
		
		private function update ( pEvt:TimerEvent ) :void
		{
			var delay:int = aFrames[ int(iIndex = iInc++ % arrayLng) ].delay;
			
			pEvt.target.delay = ( delay > 0 ) ? delay : 100;

			switch ( gifDecoder.disposeValue ) 
			{		
				case 1:
					if ( !iIndex ) 
						bitmapData = aFrames[ 0 ].bitmapData.clone();
					bitmapData.fillRect(bitmapData.rect,0x00000000);
					bitmapData.draw ( aFrames[ iIndex ].bitmapData, null,null,null ,null,true);
					break
				case 2:
					bitmapData = aFrames[ iIndex ].bitmapData;
					break;
			}
			
			dispatchEvent ( new FrameEvent ( FrameEvent.FRAME_RENDERED, aFrames[ iIndex ] ) );
		}
		
		private function concat ( pIndex:int ):int
		{	
			bitmapData.lock();
			for (var i:int = 0; i< pIndex; i++ ) 
				bitmapData.draw ( aFrames[ i ].bitmapData, null,null,null,null,true);
			bitmapData.unlock();
			
			return i;
		}
		
		/**
		 * Load any GIF file
		 *
		 * @return void
		*/
		public function load ( pRequest:URLRequest ):void
		{
			stop();
			_key = escape(pRequest.url);
			if (_map[_key])
			{
				//trace("从夫的：",_map[_key].length);
				aFrames = _map[_key];
				arrayLng = aFrames.length;
				gifDecoder.disposeValue = _decoderMap[_key].disposeValue;
				
				auto ? play() : gotoAndStop (1);
				handleMatcher()
				return;
			}	
			
			_queue.push({url:pRequest, gif:this});
			
			if (!_excute)
			{
				_excute = true;
				handleMatcher();	
			}
		}	
		
		internal function loadByQueue( pRequest:URLRequest ):void
		{
			stop();
			if (_map[_key])
			{
				//trace("从夫的：",_map[_key].length);
				aFrames = _map[_key];
				arrayLng = aFrames.length;
				gifDecoder.disposeValue = _decoderMap[_key].disposeValue;
				
				auto ? play() : gotoAndStop (1);
				handleMatcher()
				return;
			}	
			
			urlLoader.load(pRequest);			
		}
		
		private function handleMatcher():void
		{
			if (_queue.length > 0)
			{
				var matcher:Object = _queue.shift();
				matcher.gif.loadByQueue(matcher.url);
			}else {
				_excute = false;
			}
		}
		
		/**
		 * Load any valid GIF ByteArray
		 *
		 * @return void
		*/
		public function loadBytes ( pBytes:ByteArray ):void 
		{
			readStream ( pBytes );	
		}
		
		/**
		 * Start playing
		 *
		 * @return void
		*/
		public function play ():void
		{	
			if ( aFrames.length > 0 ) 
			{	
				if ( !myTimer.running ) 
				{
					myTimer.start();
				}
			} else throw new Error ("Nothing to play");
		}
		
		/**
		 * Stop playing
		 *
		 * @return void
		*/
		public function stop ():void
		{
			if ( myTimer.running ) 
				myTimer.stop();	
		}
		
		/**
		 * Returns current frame being played
		 *
		 * @return frame number
		*/
		public function get currentFrame ():int
		{
			return iIndex+1;	
		}
		
		/**
		 * Returns GIF's total frames
		 *
		 * @return number of frames
		*/
		public function get totalFrames ():int
		{	
			return aFrames.length;	
		}
				
		/**
		 * Returns how many times the GIF file is played
		 * A loop value of 0 means repeat indefinitiely.
		 *
		 * @return loop value
		*/
		public function get loopCount ():int
		{
			return gifDecoder.getLoopCount();	
		}
		
		/**
		 * Returns is the autoPlay value
		 *
		 * @return autoPlay value
		*/
		public function get autoPlay ():Boolean
		{
			return auto;	
		}
		
		/**
		 * Returns an array of GIFFrame objects
		 *
		 * @return aFrames
		*/
		public function get frames ():Array
		{
			return aFrames;	
		}
		
		/**
		 * Moves the playhead to the specified frame and stops playing
		 *
		 * @return void
		*/
		public function gotoAndStop (pFrame:int):void
		{
			if ( pFrame >= 1 && pFrame <= aFrames.length ) 	
			{
				if ( pFrame == currentFrame ) return;
				iIndex = iInc = int(int(pFrame)-1);
				
				switch ( gifDecoder.disposeValue ) 
				{
					case 1:
						bitmapData = aFrames[ 0 ].bitmapData.clone();
						bitmapData.draw ( aFrames[ concat ( iInc ) ].bitmapData );
						break
					case 2:
						bitmapData = aFrames[ iInc ].bitmapData;
						break;
				}
				
				if ( myTimer.running ) 
					myTimer.stop();
				
			} else throw new RangeError ("Frame out of range, please specify a frame between 1 and " + aFrames.length );
		}
		
		/**
		 * Starts playing the GIF at the frame specified as parameter
		 *
		 * @return void
		*/
		public function gotoAndPlay (pFrame:int):void
		{	
			if ( pFrame >= 1 && pFrame <= aFrames.length ) 
			{	
				if ( pFrame == currentFrame ) return;
				iIndex = iInc = int(int(pFrame)-1);
				
				switch ( gifDecoder.disposeValue ) 
				{	
					case 1:
						bitmapData = aFrames[ 0 ].bitmapData.clone();
						bitmapData.draw ( aFrames[ concat ( iInc ) ].bitmapData, null,null,null,null,true);
						break
					case 2:
						bitmapData = aFrames[ iInc ].bitmapData;
						break;		
				}
				if ( !myTimer.running ) myTimer.start();
				
			} else throw new RangeError ("Frame out of range, please specify a frame between 1 and " + aFrames.length );
		}
		
		/**
		 * Retrieves a frame from the GIF file as a BitmapData
		 *
		 * @return BitmapData object
		*/
		public function getFrame ( pFrame:int ):GIFFrame
		{
			var frame:GIFFrame;
			
			if ( pFrame >= 1 && pFrame <= aFrames.length ) 
				frame = aFrames[ pFrame-1 ];
			
			else throw new RangeError ("Frame out of range, please specify a frame between 1 and " + aFrames.length );
			
			return frame;	
		}
		
		/**
		 * Retrieves the delay for a specific frame
		 *
		 * @return int
		*/
		public function getDelay ( pFrame:int ):int
		{
			var delay:int;
			
			if ( pFrame >= 1 && pFrame <= aFrames.length )
				delay = aFrames[ pFrame-1 ].delay;
			
			else throw new RangeError ("Frame out of range, please specify a frame between 1 and " + aFrames.length );
			
			return delay;	
		}
		
		/**
		 * Dispose a GIFPlayer instance
		 *
		 * @return int
		*/
		public function dispose():void
		{
			stop();
			var lng:int = aFrames.length;
				
			for ( var i:int = 0; i< lng; i++ ) 
				aFrames[int(i)].bitmapData.dispose();
		}
	}
}