package com.acfun.PlayerCore.newcore.media
{
	import com.acfun.External.SIGNALCONST;
	import com.acfun.PlayerCore.model.base.VideoInfo;
	import com.acfun.Utils.Log;
	import com.acfun.signal.notify;
	
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class LiveVideoProvider extends VideoProvider
	{
		private var _nc:NetConnection;
		private var _ns:NetStream;
		private var _meta:Object;
		private var _buffering:Boolean;
		
		public function LiveVideoProvider(vi:VideoInfo)
		{
			super(vi);
		}
		
		protected function onNetStatus(event:NetStatusEvent):void
		{
			switch(event.info.code)
			{
				case "NetStream.Play.Start":
				{				
					onNsReady(null);
					break;
				}
				case "NetStream.Buffer.Full":
				{
					_buffering = false;
					break;
				}
				case "NetStream.Buffer.Empty":
				{
					_buffering = true;
					break;
				}
				case "NetStream.Play.Stop":
				{	
					close();					
//					dispatchEvent(new Event("VP_PLAY_END"));
//					notify(SIGNALCONST.SKIN_SHOW_MESSAGE,"直播被断开，您可以尝试刷新页面重试。","25");
					Log.info(this,"直播被断开");
					break;
				}
				case "NetStream.Play.StreamNotFound":
				{
					close();
					Log.info(this,"直播流未找到");
					break;
				}
			}
			trace("[LiveVideoProvider] ",event.info.code);
		}
		
		override protected function get ns():NetStream
		{
			return _ns;
		}
		
		override public function start(startTime:Number=0):void
		{
			close();
			
			var playurl:String = _videoInfo.urls[0];
			if (playurl.indexOf("rtmp")==0)
			{
				//rtmp
				var index:int = playurl.lastIndexOf("/");
				var rtmp:String = playurl.substring(0,index);
				var play:String = playurl.substring(index+1);
				_nc = new NetConnection();
				_nc.client = {};
				_nc.addEventListener(NetStatusEvent.NET_STATUS,function(event:NetStatusEvent):void{
					switch (event.info.code) 
					{ 
						case "NetConnection.Connect.Success": 
							_ns = new NetStream(_nc);
							_ns.client = {"onMetaData":onMetaData};
							_ns.bufferTime = 0;
							_ns.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
							_ns.play(play);
							_video.attachNetStream(_ns);
							break;
					} 
				});
				_nc.connect(rtmp);
			}
			else
			{
				//http flv
				_nc = new NetConnection();
				_nc.connect(null);			
				_ns = new NetStream(_nc);
				_ns.client = {"onMetaData":onMetaData};
				_ns.bufferTime = 1;
				_ns.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
				_ns.play(playurl);
				_video.attachNetStream(_ns);
			}
			//默认播放
			notify(SIGNALCONST.SET_PLAYSTATUS_CHANGE,true);
			_playing = true;
		}
		
		override public function get buffPercent():Number
		{
			return ns.bufferLength / ns.bufferTime;
		}
		
		override public function get buffTime():Number
		{
			return 0;
		}
		
		override public function get buffering():Boolean
		{
			return _buffering;
		}
		
		override public function getVideoInfo():String
		{
			var vi:String = "";
			vi += "此信息可能不可靠\n";
			vi += "直播模式\n";			
			vi += "视频尺寸：" + _video.videoWidth + "×" + _video.videoHeight + "\n";
			vi += "视频标称码率：" + Math.round(_meta.videodatarate) + " Kbps\n";
			vi += "音频标称码率：" + Math.round(_meta.audiodatarate) + " Kbps\n";
			vi += "瞬时码率：" + Math.round(ns.info.playbackBytesPerSecond*8/1024) + " Kbps\n";
			vi += "播放帧率：" + Math.round(ns.currentFPS) + " Fps\t\t";
			vi += "标称帧率：" + Math.round(_meta.framerate) + " Fps\n";
			vi += "视 频 源：" + _videoInfo.type + "\n";
			vi += "清 晰 度：" + _videoInfo.rateString + "\n";
			return vi;
		}
		
		override public function get time():Number
		{
			return ns.time;
		}
		
		override public function set time(value:Number):void
		{
			//nothing,直播流不可跳进度
		}
		
		override public function get videoLength():Number
		{
			return 0;
		}
		
		protected function onMetaData(meta:Object):void
		{
			this._meta = meta;
		}
		
		override protected function switchRate(rate:int):void
		{
			_videoInfo.setRate(rate);
			_videoInfo.addEventListener(Event.COMPLETE,function():void{
				_videoInfo.removeEventListener(Event.COMPLETE,arguments.callee);
				start();
			});
			
			_switchFlag = true;
			notify(SIGNALCONST.SKIN_SHOW_INFO,"正在切换到" + _videoInfo.rateString + "画质...",null,0);
		}
		
		override public function set playing(value:Boolean):void
		{
			if (value != _playing)
			{
				_playing = value;
				
				if (_playing)
				{
					_videoInfo.refresh();
					_videoInfo.addEventListener(Event.COMPLETE,function():void{
						_videoInfo.removeEventListener(Event.COMPLETE,arguments.callee);
						start();
					});
				}
				else
				{
					close();
				}
			}
		}
		
		protected function close():void
		{
			if (_ns)
				_ns.close();
			if (_nc)
				_nc.close();
		}
	}
}