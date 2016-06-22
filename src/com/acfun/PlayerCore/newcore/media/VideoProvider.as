package com.acfun.PlayerCore.newcore.media
{
	import com.acfun.External.AcConfig;
	import com.acfun.External.ConstValue;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.PlayerCore.interfaces.IVideoProvider;
	import com.acfun.PlayerCore.model.base.VideoInfo;
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.StageVideo;
	import flash.media.Video;
	import flash.net.NetStream;
	
	public class VideoProvider extends Sprite implements IVideoProvider
	{
		protected var _video:*;
		protected var _useStageVideo:Boolean;
		protected var _videoInfo:VideoInfo;		
		protected var _isInit:Boolean = false;
		protected var _switchFlag:Boolean = false;
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		protected var _ratioType:int = 0;
		protected var _volume:Number = 100;
		protected var _volumeBak:Number = 100;
		protected var _loop:Boolean = false;
		protected var _playing:Boolean;
		
		public function VideoProvider(vi:VideoInfo)
		{
			super();
			
			_videoInfo = vi;
			
			this.mouseChildren = this.mouseChildren = false;
			
			_useStageVideo = false;
			_video = new Video();
			_video.smoothing = true;
			addChild(_video);
			
			ConstValue.STAGE.addEventListener("stageVideoAvailability",onStageVideoAvailability);
			
			register(SIGNALCONST.SET_PLAYER_RATE,switchRate);
			register(SIGNALCONST.SET_CONFIG,onSetConfig);
		}
		
		protected function onSetConfig(config:Object):void
		{
			if (config["try_hardware_accelerate"] != null)
			{
				switchVideo(config["try_hardware_accelerate"]);
			}
		}
		
		protected function onNsReady(event:Event):void
		{
			if (!_isInit)
			{
				_isInit = true;
				_video.attachNetStream(ns);
				dispatchEvent(new Event("VP_INIT"));
			}
			if (_switchFlag)
			{
				_switchFlag = false;				
				notify(SIGNALCONST.SKIN_SHOW_INFO,"已为您切换到" + _videoInfo.rateString + "画质。",null,2000);
			}
			notify(SIGNALCONST.VIDEO_INFO,{"width":_video.videoWidth,"height":_video.videoHeight});
		}
		
		protected function onPlayEnd(event:Event):void
		{
			//播放结束
			dispatchEvent(new Event("VP_PLAY_END"));
		}
		
		protected function onStageVideoAvailability(event:*):void
		{
			Log.debug("hardware accelerate availability: ",event.availability);
			switchVideo(event.availability == "available" && AcConfig.getInstance().try_hardware_accelerate)
		}
		
		protected function switchVideo(useStageVideo:Boolean):void
		{
			if (useStageVideo && (ConstValue.STAGE.stageVideos == null || ConstValue.STAGE.stageVideos.length == 0))
				return;
			
			if (this._useStageVideo != useStageVideo)
			{
				this._useStageVideo = useStageVideo;
				if (useStageVideo)
				{
					Log.info("use stage video!");
					if (_video && contains(_video))
					{
						removeChild(_video);
						_video.clear();
						_video = null;
					}
					_video = ConstValue.STAGE.stageVideos[0];
					_video.attachNetStream(ns);				
				}
				else
				{
					Log.info("use normal video!");
					_video = new Video();
					_video.smoothing = true;
					_video.attachNetStream(ns);
					addChild(_video);
				}
				resize(_width,_height);
			}
		}
		
		protected function get ns():NetStream
		{
			//TODO override
			return null;
		}
		
		protected function switchRate(rate:int):void
		{
			//TODO override
		}
		
		public function start(startTime:Number=0):void
		{
			//TODO override	
		}
		
		public function getVideoInfo():String
		{
			//TODO override
			return null;
		}
		
		public function resize(width:Number, height:Number):void
		{
			_width = width;
			_height = height;
			
//			this.graphics.clear();
//			if (video is Video)
//			{
//				this.opaqueBackground = 0;				
//				this.graphics.beginFill(0);
//			}
//			else
//			{
//				this.opaqueBackground = null;
//				this.graphics.beginFill(0,0);
//			}	
//			this.graphics.drawRect(0,0,width,height);
//			this.graphics.endFill();
			
			setVideoRatio(_ratioType);
		}
		
		public function setVideoRatio(type:int):void
		{
			_ratioType = type;
			
			if (_video == null) return;
			
			var vwidth:int = _video.videoWidth || (("meta" in ns) && ns["meta"].width) || _width;
			var vheight:int = _video.videoHeight || (("meta" in ns) && ns["meta"].height) || _height;			
			switch(type)
			{
				case 0:
				{
					//nothing
					break;
				}
				case 1:
				{
					vheight = vwidth * 3 / 4;
					break;
				}
				case 2:
				{
					vheight = vwidth * 9 / 16;
					break;
				}
				case 3:
				{
					vwidth = _width;
					vheight = _height;
					break;
				}
			}
			var rect:Rectangle = Util.getCenterRectangle(new Rectangle(0,0,_width,_height),new Rectangle(0,0,vwidth,vheight));
			if (_video is StageVideo)
			{
				_video.viewPort = rect;
			}
			else
			{
				_video.x = rect.x;
				_video.y = rect.y;
				_video.width = rect.width;
				_video.height = rect.height;
			}
		}
		
		public function toggleSilent(isSilent:Boolean):void
		{
			if (isSilent)
			{
				_volumeBak = _volume == 0 ? 50 : _volume;
				volume = 0;
			}
			else
			{
				volume = _volumeBak;
			}
		}
		
		public function get playing():Boolean
		{
			return _playing;
		}
		
		public function set playing(value:Boolean):void
		{
			if (value != _playing)
			{
				_playing = value;
				
				if (_playing)
					ns.resume();
				else
					ns.pause();
			}
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set volume(value:Number):void
		{
			_volume = value;
			ns.soundTransform = new SoundTransform(_volume/100);
		}
		
		public function get time():Number
		{
			//TODO override
			return 0;
		}
		
		public function set time(value:Number):void
		{
			//TODO override
		}
		
		public function get buffTime():Number
		{
			//TODO override
			return 0;
		}
		
		public function get buffPercent():Number
		{
			//TODO override
			return 0;
		}
		
		public function get buffering():Boolean
		{
			//TODO override
			return false;
		}
		
		public function get loop():Boolean
		{
			return _loop;
		}
		
		public function set loop(value:Boolean):void
		{
			_loop = value; 
		}
		
		public function get videoLength():Number
		{
			return 0;
		}
	}
}