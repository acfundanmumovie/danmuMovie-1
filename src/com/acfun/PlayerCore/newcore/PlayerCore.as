package com.acfun.PlayerCore.newcore
{
	import com.acfun.PlayerCore.events.PlayerCoreStatusEvent;
	import com.acfun.PlayerCore.interfaces.IPlayerCore;
	import com.acfun.PlayerCore.model.base.VideoInfo;
	import com.acfun.PlayerCore.model.base.VideoType;
	import com.acfun.PlayerCore.model.platform.DouyuVideoInfo;
	import com.acfun.PlayerCore.model.platform.IqiyiVideoInfo;
	import com.acfun.PlayerCore.model.platform.Ku6VideoInfo;
	import com.acfun.PlayerCore.model.platform.LetvCloudVideoInfo;
	import com.acfun.PlayerCore.model.platform.LetvNormalVideoInfo;
	import com.acfun.PlayerCore.model.platform.PPSVideoInfo;
	import com.acfun.PlayerCore.model.platform.PPTVVideoInfo;
	import com.acfun.PlayerCore.model.platform.QQVideoInfo;
	import com.acfun.PlayerCore.model.platform.SinaVideoInfo;
	import com.acfun.PlayerCore.model.platform.SohuVideoInfo;
	import com.acfun.PlayerCore.model.platform.TudouVideoInfo;
	import com.acfun.PlayerCore.model.platform.YoukuVideoInfo;
	import com.acfun.PlayerCore.newcore.media.HlsVideoProvider;
	import com.acfun.PlayerCore.newcore.media.HttpVideoProvider;
	import com.acfun.PlayerCore.newcore.media.LiveVideoProvider;
	import com.acfun.PlayerCore.newcore.media.VideoProvider;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	[Event(name="PLAYERCORE_STATUS", type="com.acfun.PlayerCore.events.PlayerCoreStatusEvent")]
	
	public class PlayerCore extends Sprite implements IPlayerCore
	{
		private var provider:VideoProvider;
		private var videoInfo:VideoInfo;
		private var vid:String;
		private var type:String;		
		private var sendTimer:Timer;
		
		public function PlayerCore(vid:String = null,type:String="ku6")
		{
			super();
			
			this.mouseChildren = false;
			this.mouseEnabled = false;
			
			this.vid = vid;
			this.type = type;
		}
		
		public function start(startTime:Number = 0):void
		{
			switch(type)
			{
				case VideoType.DOUYU:
				{
					videoInfo = new DouyuVideoInfo(vid);
					break;
				}
				default:
				{
					error("不支持的视频类型");
					return;
				}
			}
			
			videoInfo.addEventListener(Event.COMPLETE,function():void{
				videoInfo.removeEventListener(Event.COMPLETE,arguments.callee);
//				if (videoInfo.fileType == "m3u8")
//					provider = new HlsVideoProvider(videoInfo);
//				else
				if (videoInfo.fileType == "live")
					provider = new LiveVideoProvider(videoInfo);
				else
				{
					error("不支持的视频类型");
					return;
				}
				provider.start(startTime);
				provider.addEventListener("VP_INIT",function():void{
					dispatchEvent(new PlayerCoreStatusEvent("PLAYERCORE_STATUS",PlayerCoreStatusEvent.PLAYERCORE_STATUS_INIT));
				});
				provider.addEventListener("VP_PLAY_END",function():void{
					dispatchEvent(new PlayerCoreStatusEvent("PLAYERCORE_STATUS",PlayerCoreStatusEvent.PLAYERCORE_MEDIA_TIMER));
					dispatchEvent(new PlayerCoreStatusEvent("PLAYERCORE_STATUS",PlayerCoreStatusEvent.PLAYERCORE_MEDIA_END));
				});
				addChild(provider);
				
				sendTimer = new Timer(500);
				sendTimer.addEventListener(TimerEvent.TIMER,sendLoop);
				sendTimer.start();
			});
			videoInfo.addEventListener("error",function():void{
//				videoInfo.removeEventListener("error",arguments.callee);
				error(videoInfo.msg);
			});	
		}
		
		private function error(msg:String):void
		{
			dispatchEvent(new PlayerCoreStatusEvent("PLAYERCORE_STATUS",PlayerCoreStatusEvent.PLAYERCORE_STATUS_ERROR,"<b>错误:视频源解析失败。</b>\n" + msg));	
		}
		
		private function sendLoop(event:TimerEvent = null):void
		{
			dispatchEvent(new PlayerCoreStatusEvent("PLAYERCORE_STATUS",PlayerCoreStatusEvent.PLAYERCORE_MEDIA_TIMER));
		}
		
		public function get playing():Boolean
		{
			return provider.playing;
		}
		
		public function set playing(value:Boolean):void
		{
			provider.playing = value;
		}
		
		public function get volume():Number
		{
			return provider.volume;
		}
		
		public function set volume(value:Number):void
		{
			provider.volume = value;
		}
		
		public function get time():Number
		{
			return provider ? provider.time : 0;
		}
		
		public function set time(value:Number):void
		{
			provider.time = value;
		}
		
		public function get speed():Number
		{
			return 0;
		}
		
		public function get buffTime():Number
		{
			return provider ? provider.buffTime : 0;
		}
		
		public function get buffPercent():Number
		{
			return provider ? provider.buffPercent : 0;
		}
		
		public function get buffering():Boolean
		{
			return provider ? provider.buffering : true;
		}
		
		public function get videoLength():Number
		{
			return provider.videoLength;
		}
		
		public function get loop():Boolean
		{
			return provider.loop;
		}
		
		public function set loop(value:Boolean):void
		{
			provider.loop = value;
		}
		
		public function resize(width:Number, height:Number):void
		{
			provider && provider.resize(width,height);
		}
		
		public function toggleSilent(isSilent:Boolean):void
		{
			provider && provider.toggleSilent(isSilent);
		}
		
		public function setVideoRatio(type:int):void
		{
			provider && provider.setVideoRatio(type);
		}
		
		public function getVideoInfo():String
		{
			return provider.getVideoInfo();
		}
		
	}
}