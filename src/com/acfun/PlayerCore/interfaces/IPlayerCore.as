package com.acfun.PlayerCore.interfaces
{
	

	public interface IPlayerCore
	{
		/**
		 * 开始读取 
		 * @param startTime 开始时间
		 * 
		 */		
		function start(startTime:Number = 0):void
		
		/**
		 * 播放状态 
		 * 
		 */
		function get playing():Boolean;
		function set playing(value:Boolean):void;
		
		/**
		 * 音量 
		 * 
		 */
		function get volume():Number;
		function set volume(value:Number):void;
		
		/**
		 * 播放时间 （单位：秒）
		 * 
		 */
		function get time():Number;
		function set time(value:Number):void;
		
		
		/**
		 * 下载速度（单位：KB/S） 
		 * 
		 */
		function get speed():Number;
		
		/**
		 * 缓冲时长（单位：秒） 
		 * 
		 */
		function get buffTime():Number;
		
		/**
		 * 缓冲区内缓冲百分比（0-1） 
		 * 
		 */		
		function get buffPercent():Number;
		
		/**
		 * 缓冲状态
		 * 
		 */
		function get buffering():Boolean
		
		/**
		 * 视频总时长（单位：秒） 
		 * 
		 */
		function get videoLength():Number;
		
		/**
		 * 视频循环播放
		 *  
		 */		
		function get loop():Boolean;		
		function set loop(value:Boolean):void;
		
		/**
		 * 改变视频大小
		 * 
		 */
		function resize(width:Number,height:Number):void;
		
		/**
		 * 静音
		 * 
		 */
		function toggleSilent(isSilent:Boolean):void;
		
		/**
		 * 调整视频长宽比 
		 * @param type 0：原始    1：4比3  2:16比9  3：填充
		 * 
		 */		
		function setVideoRatio(type:int):void;
		
		/**
		 * 获取视频相关信息
		 * 
		 */		
		function getVideoInfo():String;
	}
}