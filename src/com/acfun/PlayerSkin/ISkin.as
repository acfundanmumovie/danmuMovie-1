package com.acfun.PlayerSkin
{
	public interface ISkin
	{
		/**
		 * 设置视频总长
		 * 
		 */
		function vLength(value:Number):void;
		
		/**
		 * 设置已缓冲的秒数
		 * 
		 */
		function bufferedSecond(value:Number):void;
		
		/**
		 * 设置已播放的秒数
		 * 
		 */
		function playedSecond(value:Number):void;
		/**
		 * 设置音量条外观
		 * 
		 */
		function setVolumeBar(value:Number,showTip:Boolean=false):void;
		
		/**
		 * 设置播放状态
		 * 
		 */
		function togglePlaying(playing:Boolean):void;
		
		/**
		 * 设置全屏状态
		 * 
		 */
		function toggleFullscreen(isFullscreen:Boolean):void;
		
		/**
		 * 显示缓冲动画
		 * 
		 */
		function toggleBuffering(isBuffering:Boolean):void;
		
		/**
		 * 显示信息 
		 * @param message 要显示的文本
		 * @param pic     AC娘头像文件名
		 * @param canClose 可否关闭
		 * @param onClose 关闭之后执行的函数		 
		 * 
		 */
		function showMessage(message:String,pic:String="",canClose:Boolean=true,onClose:Function=null):void;
		
		/**
		 * 设置输入冷却时间（秒） 
		 * @param cd 秒
		 * 
		 */
		function setInputCD(cd:int):void;
	}
}