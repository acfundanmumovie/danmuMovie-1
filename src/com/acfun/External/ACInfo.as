package com.acfun.External
{
	import com.acfun.Utils.BlockLoader;
	import com.acfun.Utils.Util;
	import com.acfun.net.analysis.errors.ACError;
	import com.acfun.net.analysis.errors.ErrorType;
	import com.acfun.net.analysis.AnalysisUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 *  加载完成
	 */	
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 *  加载出错 
	 */	
	[Event(name="httploader_error", type="flash.events.Event")]
	
	public class ACInfo extends EventDispatcher
	{
		public static const API:String = PARAM.host + "/video/getVideo.aspx?id=";
		
		public var rawObject:Object;
		public var id:String;
		public var contentId:String;
		public var createTime:String;
		public var sourceType:String;
		public var title:String;
		public var danmakuId:String;
		public var success:Boolean;
		public var sourceId:String;
		public var sourceUrl:String;
		public var result:String;
		public var startTime:Number=0;
		public var endTime:Number=0;
		public var allowDanmaku:Boolean=true;
		public var time:Number=0;
		/** up主id **/
		public var userId:String;
		/** 是否直播模式 **/
		public var isLive:Boolean = false;
		
		public function ACInfo(id:String="",type:String="acfun")
		{
			this.id = id;
			if (type == "acfun" && id.length > 0)
			{
				//记录主站api开始时间
//				OnlineLog.instance.start(OnlineLog.TIME_GET_VIDEO);
				
				var loader:BlockLoader = new BlockLoader(API + id,"",3,10000);			
				loader.addEventListener(Event.COMPLETE,onComplete);
				loader.addEventListener(BlockLoader.HTTPLOADER_ERROR,onError);
			}
			else
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		protected function onError(event:Event):void
		{
			dispatchEvent(event);
			
			AnalysisUtil.send(ACError.create({info:"服务器安全策略受限或者不存在接口",visitURL:API+id},ErrorType.IO_AC_INFO));
		}
		
		protected function onComplete(event:Event):void
		{
			//记录主站api完成时间
//			OnlineLog.instance.end(OnlineLog.TIME_GET_VIDEO);
//			if (event.target.trytimes > 1)
//			{
//				OnlineLog.instance.hasError = true;
//				OnlineLog.instance.extend.push(event.target.log);
//			}
			try{
				rawObject = Util.decode(event.target.data);
			}catch(e:Error){};
			
			success = rawObject["success"];
			if (success)
			{
				id = rawObject.id;
				contentId = rawObject.contentId || "201714";
				sourceId = rawObject.sourceId || rawObject.oldSourceId;
				sourceType = rawObject.sourceType || rawObject.oldSourceType;
				if (sourceType == "douyu")
					isLive = true;
				sourceUrl = rawObject.sourceUrl;
				createTime = rawObject.createTime;
				title = rawObject.title;
				danmakuId = rawObject.danmakuId;
				startTime = Number(rawObject.startTime) || 0;
				endTime = Number(rawObject.end) || 0;
				time = Number(rawObject.time) || 0;
				allowDanmaku = (rawObject.allowDanmaku != null && int(rawObject.allowDanmaku)==1)?false:true;
				userId = rawObject.userId;
			}
			else
			{
				result = rawObject.result;
				
				AnalysisUtil.send(ACError.create({info:"服务器返回错误视频信息",visitURL:API+id},ErrorType.FAIL_AC_INFO));
			}	
			
			dispatchEvent(event);
		}
	}
}