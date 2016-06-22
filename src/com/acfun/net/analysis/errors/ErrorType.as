/**
 * ===================================
 * Author:	iDzeir					
 * Email:	qiyanlong@wozine.com	
 * Company:	http://www.acfun.tv		
 * Created:	May 18, 2015 1:49:32 PM			
 * ===================================
 */

package com.acfun.net.analysis.errors
{
	
	public class ErrorType
	{
		//====错误类型====
		/**
		 * 未定义错误类型 
		 */		
		public static const UN_KNOW:int = 1000;
		/**
		 * 未知来源视频 
		 */		
		public static const UN_KNOW_SOURCE:int = 1001;
		/**
		 * 加载乐视sdk失败 
		 */		
		public static const IO_LETV_SDK:int = 1002;
		/**
		 * 加载视频信息错误
		 */		
		public static const IO_AC_INFO:int = 1003;
		/**
		 * 服务器返回错误视频信息 
		 */		
		public static const FAIL_AC_INFO:int = 1004;
		/**
		 * 乐视播放器内部错误信息反馈 
		 */		
		public static const LETV_PLAYSTATUS_ERROR:int = 1005;
		/**
		 * 加载历史弹幕失败 
		 */		
		public static const LOAD_STATIC_COMMENT_FAIL:int = 1006;
		/**
		 * 连接websocket服务器失败 
		 */		
		public static const WS_CONNECT_FAIL:int = 1007;
		//==============
	}
}