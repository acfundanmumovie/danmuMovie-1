package com.acfun.PlayerCore.newcore
{
	import com.acfun.External.AcConfig;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.PlayerCore.events.PlayerCoreStatusEvent;
	import com.acfun.PlayerCore.interfaces.IPlayerCore;
	import com.acfun.PlayerCore.model.base.VideoInfo;
	import com.acfun.Utils.Log;
	import com.acfun.net.analysis.errors.ACError;
	import com.acfun.net.analysis.errors.ErrorType;
	import com.acfun.net.analysis.AnalysisUtil;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	public class LetvPlayerCore extends Sprite implements IPlayerCore
	{
		//http://yuntv.letv.com/bcloud.swf?uu=2d8c027396&vu=d30aee5e30&auto_play=1&gpcflag=1
		private static const LETV_SDK:String = "http://yuntv.letv.com/bcloud.swf";
		
		/** 乐视支持的码率  **/
//		public static const LETV_RATES_ARRAY:Array = ["yuanhua","1080p","720p","1300","1000","350"];
		public static const LETV_RATES_ARRAY:Array = ["yuanhua","1300","1000","350"];
			
		public static const LETV_RATES_OBJECT:Object = {"350":"流畅","1000":"高清","1300":"超清","720p":"720P","1080p":"1080P","yuanhua":"原画"};
			
		private var _vu:String;
		
		private var _player:DisplayObject;
		
		private var _api:Object;
		
		private var _param:Object = {uu:"2d8c027396",auto_play:1,skinnable:0,pu:"8e7e683c11"};
		
		private var _buffering:Boolean = false;
		
		private var _playing:Boolean = false;
		
		private var _volume:Number = 1;
		
		private var _videoInfo:Object;
		
		private var _loop:Boolean;
		
		private var _startTime:Number = 0;
		
		private var _rates:Array;
		
		private var _isSwithRate:Boolean;
		
		public function LetvPlayerCore(vu:String)
		{
			this.mouseChildren = false;
			this.mouseEnabled = false;
			
			_vu = vu;
			_param["vu"] = _vu;
			_isSwithRate = false;
			
			register(SIGNALCONST.SET_PLAYER_RATE,onSwitchRate);
			register(SIGNALCONST.SET_CONFIG,onSetConfig);
		}
		
		private function onSetConfig(config:Object):void
		{
			if (config["try_hardware_accelerate"] != null)
			{
				_api.setGpu(config["try_hardware_accelerate"]);
			}
		}
		
		private function onSwitchRate(rate:int):void
		{
			if (rate < LETV_RATES_ARRAY.length && _api.getDefinition() != LETV_RATES_ARRAY[rate])
			{	
				_api.setDefinition(LETV_RATES_ARRAY[rate]);	
				notify(SIGNALCONST.SET_PLAYER_RATE_CHANGED,rate,_rates,VideoInfo.VIDEO_RATES_STRING);
				notify(SIGNALCONST.SKIN_SHOW_INFO,"正在切换画质...",null,0);
				_isSwithRate = true;
			}
		}
		
		public function start(startTime:Number=0):void
		{
			_startTime = startTime;
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function():void{
				//letv sdk加载失败，可能是广告屏蔽等原因
				Log.error("letv sdk加载失败！");
				dispatchEvent(new PlayerCoreStatusEvent(PlayerCoreStatusEvent.LISTEN_TYPE,PlayerCoreStatusEvent.PLAYERCORE_STATUS_ERROR,"letv sdk加载失败\n您可以尝试关闭广告屏蔽插件\n或者更改浏览器的广告屏蔽设置。"));
				
				AnalysisUtil.send(ACError.create({info:"letv sdk加载失败，可能是广告屏蔽等原因",visitURL:LETV_SDK},ErrorType.IO_LETV_SDK));
			});
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void{
				Log.info("letv sdk加载成功！");
				_player = loader.content;
				_api = _player["api"];				
				_api.addEventListener("playState",onPlayerState);
				//开始时间
				if (startTime > 0)
					_param["start"] = startTime;
				//默认码率
				_param["rate"] = LETV_RATES_ARRAY[AcConfig.getInstance().video_quality];
				_api["setFlashvars"](_param);
				addChild(_player);
			});
			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = new ApplicationDomain();//播放器需要被放到一个安全域中
			if(context.hasOwnProperty("allowCodeImport"))
			{
				context["allowCodeImport"] = true;//允许播放器内部代码执行
			}    
			loader.load(new URLRequest(LETV_SDK),context);
		}
		
		private var isInit:Boolean = false;
		private function onPlayerState(event:*):void
		{
			switch(event["state"])
			{
				case "loopOnKernel":
					this.dispatchEvent(new PlayerCoreStatusEvent(PlayerCoreStatusEvent.LISTEN_TYPE,PlayerCoreStatusEvent.PLAYERCORE_MEDIA_TIMER));					
					break;
//				case "videoAuthValid":
				case "videoStartReady":
					_videoInfo = _api.getVideoSetting();
					if (!isInit)
					{
						isInit = true;
						
						_rates = [];
						var rates:Object = _api.getDefinitionList();
						for (var rate:String in rates)
						{
							var index:int = LETV_RATES_ARRAY.indexOf(rate)
							if (index != -1)
								_rates.push(index);
						}
						
						_api.setDefinition(LETV_RATES_ARRAY[AcConfig.getInstance().video_quality]);
						_api.pauseVideo();
						notify(SIGNALCONST.SET_PLAYER_RATE_CHANGED,LETV_RATES_ARRAY.indexOf(_api.getDefinition()),_rates,VideoInfo.VIDEO_RATES_STRING);
						
						this.dispatchEvent(new PlayerCoreStatusEvent(PlayerCoreStatusEvent.LISTEN_TYPE,PlayerCoreStatusEvent.PLAYERCORE_STATUS_INIT));
					}
					else
					{
						if (_isSwithRate)
						{
							_isSwithRate = false;
							//切换清晰度成功						
							notify(SIGNALCONST.SKIN_SHOW_INFO,"已为您成功切换画质。",null,2000);
							playing = _playing;
						}
					}
					notify(SIGNALCONST.VIDEO_INFO,{"width":_videoInfo.width,"height":_videoInfo.height});
					break;
				case "videoStart":
					//多发一次 以免高级弹幕错位
					_videoInfo = _api.getVideoSetting();
					notify(SIGNALCONST.VIDEO_INFO,{"width":_videoInfo.width,"height":_videoInfo.height});
					break;
				case "videoEmpty":
					_buffering = true;
					playing = _playing;
					this.dispatchEvent(new PlayerCoreStatusEvent(PlayerCoreStatusEvent.LISTEN_TYPE,PlayerCoreStatusEvent.PLAYERCORE_STATUS_BUFFERING));
					break;
				case "videoFull":
					_buffering = false;
					playing = _playing;
					this.dispatchEvent(new PlayerCoreStatusEvent(PlayerCoreStatusEvent.LISTEN_TYPE,PlayerCoreStatusEvent.PLAYERCORE_STATUS_BUFFER_END));
					break;
				case "videoStop":
					_buffering = false;
					this.dispatchEvent(new PlayerCoreStatusEvent(PlayerCoreStatusEvent.LISTEN_TYPE,PlayerCoreStatusEvent.PLAYERCORE_MEDIA_TIMER));
					this.dispatchEvent(new PlayerCoreStatusEvent(PlayerCoreStatusEvent.LISTEN_TYPE,PlayerCoreStatusEvent.PLAYERCORE_MEDIA_END));					
					break;				
				case "errorInConfig":
				case "errorInLoadPlugins":
				case "errorInKernel":
					this.dispatchEvent(new PlayerCoreStatusEvent(PlayerCoreStatusEvent.LISTEN_TYPE,PlayerCoreStatusEvent.PLAYERCORE_STATUS_ERROR,"乐视返回错误，错误代码：" + event.dataProvider.errorCode + "\n请联系管理员"));					
					break;
				case "videoStart":					
					_buffering = false;
					break;
				default:
					this.dispatchEvent(new PlayerCoreStatusEvent(PlayerCoreStatusEvent.LISTEN_TYPE,PlayerCoreStatusEvent.PLAYERCORE_UNKNOWN_STATUS,"未知状态:"+event["state"]));
					break;
			}
		}
		
		public function get playing():Boolean
		{
			return _playing;
		}
		
		public function set playing(value:Boolean):void
		{
			if (value)
				_api.resumeVideo();
			else
				_api.pauseVideo();
			_playing = value;
		}
		
		public function get volume():Number
		{
			return _api.getVideoSetting()["volume"] * 100;
		}
		
		public function set volume(value:Number):void
		{
			_volume = value/100;
			_api.setVolume(_volume);
		}
		
		public function get time():Number
		{
			return _api.getVideoTime();
		}
		
		public function set time(value:Number):void
		{
			_api.seekTo(value);
			playing = _playing;
		}
		
		public function get speed():Number
		{
			return 0;
		}
		
		public function get buffTime():Number
		{
			if (_videoInfo)
				return _api.getLoadPercent()*videoLength;
			else
				return 0;
		}
		
		public function get buffering():Boolean
		{
			return _buffering;
		}
		
		public function get videoLength():Number
		{
			if (_videoInfo)
				return _videoInfo["duration"];
			else
				return 0;
		}
		
		public function resize(width:Number, height:Number):void
		{
			if (_api)
			{
				var rect:Rectangle = new Rectangle(0,0,width,height);
				_api.setVideoRect(rect);
				setVideoRatio(_ratio);	
			}
		}
		
		public function toggleSilent(isSilent:Boolean):void
		{
			if (isSilent)
				_api.setVolume(0);
			else
				_api.setVolume(_volume);
		}
		
		public function get loop():Boolean
		{
			return _loop;
		}
		
		public function set loop(value:Boolean):void
		{
			_loop = value;
			_api.setAutoReplay(_loop);
		}
		
		private var _ratio:int = 0;
		public function setVideoRatio(type:int):void
		{
			_ratio = type;
			switch(type)
			{
				case 1:
				{
					_api.setVideoScale(4/3);					
					break;
				}
				case 2:
				{
					_api.setVideoScale(16/9);
					break;
				}
				case 3:
				{
					_api.setVideoScale(width/height);
					break;
				}	
				default:
				{
					_api.setVideoScale(0);
					break;
				}
			}
		}
		
		public function get buffPercent():Number
		{
			return _api?_api.getBufferPercent():0;	
		}
		
		public function getVideoInfo():String
		{
			var vi:String = "";
			if (_api)
			{
				vi += "此信息可能不可靠\n";				
				vi += "视频尺寸：" + _videoInfo.width + "×" + _videoInfo.height + "\n";
				vi += "视 频 源：乐视云\n";			
				vi += "清 晰 度：" + LETV_RATES_OBJECT[_videoInfo.definition] + "\n";				
			}			
			return vi;
		}
	}
}