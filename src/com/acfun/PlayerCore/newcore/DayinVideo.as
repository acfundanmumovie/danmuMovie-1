package com.acfun.PlayerCore.newcore
{
	import com.acfun.PlayerCore.events.PlayerCoreStatusEvent;
	import com.acfun.Utils.Log;
	
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.H264Level;
	import flash.media.H264Profile;
	import flash.media.H264VideoStreamSettings;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class DayinVideo extends Sprite
	{
		private var netc:NetConnection;
		private var nets:NetStream;
		private var video:Video;
		public var _duration:Number =0;
		private var videoWidth:int = 16;
		private var videoHeight:int = 9;
		protected var _inited:Boolean = false;
		//////////////播放网络视频还是本地视频
		public var _playLocalVideo = false;//false为播放网络视频
		private var _dataWh:Number = 1;//视频的原始宽高比
		public var _localVideos:Array;//视频播放列表
		private var currentPlayId:uint =0;//当前播放视频id
		
		private var videoScrX:Number=480;//录制视频的水平分辨率276//480
		private var videoScrY:Number=360;//录制视频的垂直分辨率208//360
		private var videoFps:Number=10;//摄像头帧频25//10
		private var bt:uint = 21600;//带宽上线23000
		private var camQuality:uint = 80;//视频质量80
		private var cam:Camera;//本地摄像头
		private  var _vid2:Video;//本地摄像头用
		//直播
		private var _nc:NetConnection;
		private var _livePlayUrl:String =null;
		
		public function DayinVideo()
		{
			super();
		}
		
		public function start(source:String=null):void{	
			resetVideo()
			_inited = false;
			netc = new NetConnection();
			netc.connect(null);
			nets = new NetStream(netc);
			nets.bufferTime =5
			nets.addEventListener(IOErrorEvent.IO_ERROR, geterror);
			nets.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onMete);
			nets.addEventListener(NetStatusEvent.NET_STATUS,netStatus);
			nets.client = {"onMetaData":onMetaData};
			nets.useHardwareDecoder = false;
			nets.checkPolicyFile = true;
			var h264:H264VideoStreamSettings = new H264VideoStreamSettings();
			h264.setProfileLevel(H264Profile.MAIN,H264Level.LEVEL_1);
			nets.videoStreamSettings = h264;
			//nets.play("http://dm.aixifan.com/videos/"+source);
			if(_playLocalVideo)
			{
				if(_localVideos && _localVideos.length>0 ){
					if(_localVideos[currentPlayId].type =="click"){
						//trace("__currentVideoUrl:"+_localVideos[currentPlayId].url)
						nets.play(_localVideos[currentPlayId].url);
						Log.info("start:",source);
					}
				}
			}
			else
			{
				nets.play("http://dm.aixifan.com/videos/"+source);
				Log.info("start:","http://dm.aixifan.com/videos/"+source);
			}
			

			video = new Video();
			video.attachNetStream(nets);
			this.addChild(video);
			
		}
		
		public function isShow(bool:Boolean):void{
			Log.info("dayinVideo:",bool,nets);
			this.visible = bool;
			if(nets){
				if(!bool){
					nets.pause();
				}else{
					//nets.seek(0);
					nets.resume();
				}
			}
		}
		
		
		private function maxNum(a1:int,a2:int):int{
			var answer:int = 0;
			var i:int=1;
			while(i<=a1&&i<=a2){
				if(a1%i==0&&a2%i==0){
					answer=i;
				}
				i++;
			}
			return answer;
		}
		private function onMetaData(data:Object):void{
			_dataWh = data.width/data.height;
			/////////////
			_duration = data.duration;
			/*var seekNum:Number = uint(_duration -10)
			trace("seek视频总时长："+_duration)
			nets.seek(seekNum);*///测试
			
			var max:int = maxNum(data.width,data.height);
			videoWidth = data.width/max;
			videoHeight = data.height/max;
			if(!_inited)
			{
				_inited = true;
				sendInit();
			}
		}
		
		public function resize(width:Number, height:Number):void
		{
			//trace("-----------playerResize")
			var min:Number = Math.min(width/videoWidth,height/videoHeight);
			if(video){
				video.width = min * videoWidth;
				video.height = min * videoHeight;
				video.x = (width - video.width)/2;
				video.y = (height - video.height)/2;
			}
			////////////
			/*video.width = width;
			video.height = video.width/_dataWh;
			if(video.height >= height)
			{
			video.y = height - video.height;
			}
			else
			{
			video.y = (height - video.height)/2;
			}*/
			////////////////
			if(_vid2 && cam){
				cam.setMode(width,height,videoFps);
				_vid2.width = width;
				_vid2.height = height;
				_vid2.scaleX = -1;
				_vid2.x= width;
			}
		}
		
		private function sendInit():void{
			clearTimeout(clearTimerId);
			this.dispatchEvent(new PlayerCoreStatusEvent(PlayerCoreStatusEvent.LISTEN_TYPE,PlayerCoreStatusEvent.PLAYERCORE_STATUS_INIT));
		}
		private var clearTimerId:int;
		private function netStatus(e:NetStatusEvent):void{
			//trace("--NetStatusEvent:"+e.info.code)
			switch(e.info.code){
				case "NetStream.Play.Start":
				{	
					
					nets.pause();
					clearTimerId = setTimeout(sendInit,100);

					break;
				}
				case "NetStream.Buffer.Full":
				{
					
					break;
				}
				case "NetStream.Buffer.Empty":
				{
					
					break;
				}
				case "NetStream.Play.Stop":
				{					
					////////////////////////
					completeVideoDeal()
					break;
				}
				case "NetStream.Play.StreamNotFound":
				{
					//trace("--getStreamNotFound")
					completeVideoDeal()
					break;
				}
				default:
					Log.warn("DayinVideo:",e.info.code);
					break;
			}
		}
		
		///////////////////////当前视频播放完成或异常chuli
		private function completeVideoDeal():void
		{
			if(_playLocalVideo)
			{
				//nets.seek(0);//循环播
				currentPlayId++;
				if(currentPlayId ==_localVideos.length) 
				{
					currentPlayId=0;
				}
				
				if(video) video.clear()
				
				if(_localVideos[currentPlayId].type =="click"){
					//trace("--currentPlayId:"+currentPlayId+";"+"__currentVideoUrl:"+_localVideos[currentPlayId].url)
					nets.play(_localVideos[currentPlayId].url);
				}
			}
			else//后台操控
			{
				//notify(SIGNALCONST.VIDEO_END);
				this.dispatchEvent(new PlayerCoreStatusEvent(PlayerCoreStatusEvent.LISTEN_TYPE,PlayerCoreStatusEvent.PLAYERCORE_MEDIA_END));
			}
		}
		
		///////////////////////////////////开启显示本地摄像头
		public function locolVideo(camWidth_:Number=1024,camHeight_:Number=768):void{
			trace("添加本地摄像头")
			resetVideo()
			cam =Camera.getCamera();
			
			if(cam){
				var cameras:Array = Camera.names;
				if(cameras.length>1){
					var camId:uint = cameras.length -1
					cam=Camera.getCamera(camId.toString());
				}
				cam.setMode(camWidth_,camHeight_,videoFps);//设置分辨率和帧频，默认160,120,15
				
				cam.setKeyFrameInterval(10);
				//cam.setLoopback(true);
				cam.setQuality(bt,camQuality);
			}		
			
			/*_vid2=new Video(camWidth_,camHeight_);
			_vid2.attachCamera(cam);
			_vid2.scaleX=-1;
			_vid2.x=camWidth_;
			addChild(_vid2);*/
			video=new Video(camWidth_,camHeight_);
			video.attachCamera(cam);
			addChild(video);
		}
		
		////////////////////////////////////
		
		public function close():void{
			nets.removeEventListener(IOErrorEvent.IO_ERROR, geterror);
			nets.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onMete);
			nets.removeEventListener(NetStatusEvent.NET_STATUS,netStatus);
			
			if (nets)
				nets.close();
			if (netc)
				netc.close();
			if(video){
				this.removeChild(video);
				video = null;
			}
		}
		
		public function set volume(num:int):void{
//			nets.soundTransform = new SoundTransform(num/100);
			var transform:SoundTransform = nets.soundTransform;
			transform.volume = 0;
			nets.soundTransform = transform;
		}
		
		public function get time():uint{
			if(nets)
				return nets.time * 1000;
			else
				return 0;
		}
		
		public function set playing(bool:Boolean):void{
			if(nets){
				if(bool){
					nets.resume();
				}else{
					nets.pause();
				}
			}
		}
		
		private function geterror(e:IOErrorEvent):void{
			trace(e);
			completeVideoDeal()
		}
		
		private function onMete(e:AsyncErrorEvent):void{
			trace(e);
			completeVideoDeal()
		}
		
		//////////////////////////////////直播
		public function livePlay(fuq:String=null,livePlayUrl:String=null):void
		{
			//var str:String ="rtmp://103.244.233.164:1935/live/news"
			//trace(str.slice(str.lastIndexOf("/")+1))
			resetVideo()
			_livePlayUrl = livePlayUrl;
			_nc = new NetConnection()
			_nc.connect(fuq);
			_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandlerLive);
			_nc.addEventListener(NetStatusEvent.NET_STATUS,statusHandlerLive);
			
		}
		
		private function asyncErrorHandlerLive(e:AsyncErrorEvent):void
		{
			trace("livePlayError:"+e); 
		}
		
		//起始操作
		private function statusHandlerLive(e:NetStatusEvent):void
		{
			//trace(e.info.code);
			if (e.info.code == "NetConnection.Connect.Success")
			{
				trace("直播服务器连接成功");
				var nsq:NetStream = new NetStream(_nc);//有变化
				nsq.addEventListener(IOErrorEvent.IO_ERROR, geterror);
				nsq.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrorHandlerLive);
				nsq.bufferTime=5;
				nets.client = {"onMetaData":onMetaData};
				if(_livePlayUrl !=null)
				{
					nsq.play(_livePlayUrl);
				
					video = new Video();
					video.attachNetStream(nsq);
					this.addChild(video);
				}
			}
		}
		
		private function resetVideo():void
		{
			if(video){
				video.attachCamera(null);
				video.clear();
				this.removeChild(video);
			}
			
			if(cam){
				cam = null
			}
			
		}
	}
}


