package com.acfun.PlayerCore.model.base
{
	/**
	 * 单个视频简易信息类 
	 * @author sky
	 * 
	 * 2013/7/25
	 */
	public class PartVideoInfo
	{
		public var rawObject:Object;
		/**
		 * 分段序号（0开始） 
		 */		
		public var index:int;
		/**
		 * 分段视频播放地址 
		 */		
		public var url:String;
		/**
		 * 分段视频长度（秒） 
		 */		
		public var duration:Number;
		/**
		 * 重试次数 
		 */		
		public var tryTimes:int;
		/**
		 * 视频清晰度 
		 */		
		public var rate:int;
		
		public function PartVideoInfo(rawObject:Object,index:int,url:String,duration:Number,tryTimes:int=0,rate:int=0)
		{
			this.rawObject = rawObject;
			this.index = index;
			this.url = url;
			this.duration = duration;
			this.tryTimes = tryTimes;
			this.rate = rate;
		}
	}
}