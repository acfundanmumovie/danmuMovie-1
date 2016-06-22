package com.acfun.comment.communication
{
	public class CommentServerResponseCode
	{
		public static const SEND_REPORT_OK:String = '102';
		public static const SEND_REPORT_OK_2:String = '101';
		
		public static const SERVER_AUTHED:String = '202';
		public static const BAN_LIST:String = '210';
		public static const SEND_OK:String = '200';
		
		/** 服务器地址重定向 **/
		public static const SERVER_REDIRECT:String = '302';
		
		/** 禁言  **/
		public static const SEND_FAIL_FORBIDDEN:String = '401';
		/**高级弹幕等级限制**/
		public static const SEND_FAIL_FORBIDDEN_SPECIAL_LEVEL:String = '401.3';
		/**普通弹幕等级限制**/
		public static const SEND_FAIL_FORBIDDEN_LEVEL:String = '401.6';
		/**游客限制**/
		public static const SEND_FAIL_FORBIDDEN_GUEST:String = '401.9';
		/** 敏感词  **/
		public static const SEND_FAIL_SENSITIVE:String = '403';
		/** 服务器主动关闭（不重连）  **/
		public static const SERVER_CLOSE:String = '404';
		
		public static const SEND_FAIL_SERVER:String = '500';
		
		public static const ONLINE_NUMBER:String = '600';
		public static const ONLINE_LIST:String = '601';
		
		public function CommentServerResponseCode()
		{
		}
	}
}