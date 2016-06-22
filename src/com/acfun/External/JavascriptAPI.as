package com.acfun.External
{
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	
	import flash.external.ExternalInterface;

	public class JavascriptAPI
	{
		/** 发送弹幕  **/
//		public static const COMMENT_SEND:String = "sendComm";
		/** 显示/隐藏弹幕 **/
//		public static const COMMENT_TOGGLE_SHOW:String = "showComm";		
		/** 保存播放器设置  **/
//		public static const SAVE_PLAYER_CONFIG:String = "saveConfig";
		/** 弹幕屏蔽  **/
//		public static const CONFIG_COMMENT_FILTER:String = "commMute";
		/** 设置播放状态  
		 * 
		 * action:
            play
            pause
            jump,time
		 * **/
		public static const SET_PLAYER_STATUS:String = "play";
		/** 设置播放器迷你状态 **/
//		public static const SET_PLAYER_MINI:String = "mini";
		/** 外部及时传入该用户是否被封禁 **/
		public static const SET_USER_BAN:String = "ban";		
		/** 设置音量 **/
		public static const SET_VOLUME:String = "setVolume";
		/** 获取播放时间 **/
		public static const GET_TIME:String = "getTime";
		/** 弹出推荐窗口 {isUped: boolean, isFavored: boolean}
		 * 	isUped: 0/1	是否已赞 
		 * 	isFavored: 0/1 是否已收藏
		 * **/
		public static const SHOW_RECOMMEND:String = "showRecommend";
		
		/** 播放器初始化完毕 **/
		public static const PLAYER_READY:String = "f.ready";
		/** 开关灯 **/
		public static const LIGHT_ONOFF:String = "f.curtain";		
		/** 跳到弹幕输入框 **/
//		public static const JUMP_TO_INPUT:String = "f.iptFocus";		
		/** 关键字 过滤 **/
		//public static const CONFIG_KEYWORD_FILTER:String = "keywordFilter";
		/** 分享视频  **/
//		public static const SHARE_VIDEO:String = "f.share";
		/** 进入高级弹幕模式  **/
		public static const SPECIAL_GO:String = "f.spEnable";
		/** 在线人数
		 * 
		 * {num:"online,comments"}
		 * 
		 **/
		public static const ONLINE_NUMBER:String = "f.showOnline";
		/** 网页全屏 **/
		public static const WEB_FULLSCREEN:String = "f.webFullscreen";
		/** 桌面全屏 **/
		public static const DESKTOP_FULLSCREEN:String = "f.fullscreen";
		/** 切换到下一P **/
		public static const NEXT_P:String = "f.nextPart";
		/** 播放器状态抛出 
		 * status:
            start
            finish
            play
            pause
            lag
            bufferFinish
            jump,time
		 */
		public static const PLAYER_STATUS:String = "f.play";
		/**
		 * 弹出登录框 
		 * 
		 * action:
		 * 	login	弹出登录框
		 */		
		public static const CALL_ACTION:String = "f.call";
		
		/**
		 * 点赞 
		 */
		public static const CALL_UP:String = "f.up";
		
		/**
		 * 收藏 
		 */
		public static const CALL_FAVOR:String = "f.favor";
		
		/**
		 * 分享 
		 */
		public static const CALL_SHARE:String = "f.share";
		
		/**
		 * 弹出答题界面 
		 */		
		public static const CALL_ANSWER:String = "f.answer";
		
		
		
		public static var isReady:Boolean = false;
		
		public function JavascriptAPI()
		{}
		
		/**
		 * 调用JS方法 
		 * @param name JS方法名
		 * @param param JS方法参数（只支持一个参数，多参数建议作为一个object传送）
		 * @return JS执行结果
		 * 
		 */
		public static function callJS(name:String,param:Object = null):*			
		{	
			if (name == PLAYER_READY)
				isReady = true;
			
			if (!isReady) 
				return null;
			
			if (param == null)
				param = {};
			
			Log.debug("调用JS方法： ",name,Util.encode(param));
			if (ExternalInterface.available)
			{
				var re:*;
				try
				{
					re = ExternalInterface.call(name,param);
				}
				catch(e:Error)
				{
					Log.error("[JavascriptAPI] Security Error ",e.getStackTrace());
				}
				return re;
			}
			return null;
		}
		
		/**
		 * 添加JS回调 
		 * @param name JS回调方法名
		 * @param func 回调函数
		 * 
		 */		
		public static function addCall(name:String,func:Function):void
		{
			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.addCallback(name,func);	
				}
				catch(e:Error)
				{
					Log.error("[JavascriptAPI] Security Error ",e.getStackTrace());
				}
			}
		} 
		
		public static function getCookie(key:String=""):String
		{
			if (ExternalInterface.available)
			{
				var cookie:String;
				try
				{
					cookie = ExternalInterface.call("function(){ return document.cookie; }");
//					cookie = "auth_key=860009; auth_key_ac_sha1=-877862706; ac_username=sky0014;";
//					cookie = "auth_key=553437; auth_key_ac_sha1=1254899954; ac_username=sskkyy;";
				}
				catch(e:Error)
				{
					Log.error("[JavascriptAPI] Security Error ",e.getStackTrace());
				}
				if (cookie)
				{
					if (key == "")
					{
						return cookie;
					}	
					else
					{
						var reg:RegExp = new RegExp(key+"=([^;]*)");
						var m:Array = cookie.match(reg);
						if (m && m[1])
							return m[1];
					}	
				}
			}
			return null;
		}
	}
}