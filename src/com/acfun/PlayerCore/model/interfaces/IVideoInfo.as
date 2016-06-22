package com.acfun.PlayerCore.model.interfaces
{
	import flash.events.IEventDispatcher;
	
	public interface IVideoInfo
	{
		/**
		 * 获取视频源类型 (乐视合作源或者斗鱼直播源) 
		 * 
		 */
		function get type():String;
		
		/**
		 * 获取视频id 
		 * 
		 */
		function get vid():String;
		
		/**
		 * 获取服务器返回的原始信息		 
		 * 
		 */
		function get rawInfo():Object;
		
		/**
		 * 视频状态 
		 * 
		 */
		function get status():String;
		
		/**
		 * 获取视频码率信息 
		 * 
		 */
//		function get rateInfo():Array;		
		
		/**
		 * 获取视频总时长 
		 * 
		 */
		function get totalTime():Number;
		
		/**
		 * 获取分段数 
		 * 
		 */
		function get count():int;
		
		/**
		 * 得到 指定分段的视频信息
		 * @param onResult 返回结果(PartVideoInfo)		 
		 * @param partIndex 指定分段序号（0开始）
		 * @param partPosition 指定分段位置（秒或字节）
		 * 
		 */
		function getPartVideoInfo(onResult:Function,partIndex:int,partPosition:Number=0):void
		
		/**
		 * 根据时长计算分段 
		 * @param position 时长（秒）
		 * @return [分段序号，分段时长]
		 * 
		 */		
		function getIndexOfPosition(position:Number):Array
	}
}