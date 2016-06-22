package com.acfun.External
{
	import flash.display.Stage;

	public class ConstValue
	{
		//播放器默认size
		public static const PLAYER_SKIN_DEFAULT_HEIGHT:int = 0;
		public static const PLAYER_SKIN_RIGHTPAD_WIDTH:int = 340;
		public static const SPECIAL_MODE_PLAYER_WIDTH:int  = 864;
		public static const SPECIAL_MODE_PLAYER_HEIGHT:int = 526;		
		public static const MINI_MODE_THRESHOLD_WIDTH:int  = 360;
		
		public static var MAX_SIZE:int = 40;
		public static var SCREEN:int = 1;
		//是否是游戏屏
		public static var PLAY_SCREEN:Boolean = false;
		//弹幕Z坐标
		public static var SINGALDANMU_Z:Number = 0;
		//增加弹幕显示区域宽度和高度增加或减少
		public static var RECT_WIDTH:Number = 0;
		public static var RECT_HEIGHT:Number = 0;
		//弹幕起始移动方向
		public static const RIGHT:String = "r";
		public static const LEFT:String = "l";
		public static var DIRECT:String = RIGHT;
		public static var _getTextOrder:Boolean = false;//文字是否要反转显示
		//表情缩放比例
		public static var EMTION_SCALE:Number = 1;
		//播放器状态
		public static const PLAYER_STATE_WIDE:String = "wide";
		public static const PLAYER_STATE_WEB_FULLSCREEN:String = "webfullscreen";
		public static const PLAYER_STATE_RIGHTPAD:String = "rightpad";
		public static const PLAYER_STATE_SPECIAL:String = "special";
		public static const PLAYER_STATE_MINI:String = "mini";
		
		//url配置
		public static const CONFIG_STATIC_URL:String = "http://cdn.aixifan.com";
		public static const CONFIG_HOST_URL:String = "http://www.acfun.tv";
		
		//底部提示文字
		public static const INFO_REPORT_STRING:String = "您已成功屏蔽并举报用户[uid:{uid}]，该用户将自动被加入至您的屏蔽列表。 <a href='event:goFilter'><font color='#3A9BD9'><u>管理我的屏蔽列表</u></font></a>";
		public static const INFO_BLOCK_STRING:String =  "您已屏蔽用户[uid:{uid}](如要举报请先登录），该用户将自动被加入至您的屏蔽列表。 <a href='event:goFilter'><font color='#3A9BD9'><u>管理我的屏蔽列表</u></font></a>";
		
		public static const INPUT_CD_GUEST:int = 30;
		public static const INPUT_CD_USER:int  = 3;
		
		public static const AC_BOMB_FOLDER:String = CONFIG_STATIC_URL + "/player/emotion/";
		public static const AC_PIC_URL:String = CONFIG_STATIC_URL + "/dotnet/20130418/ueditor/dialogs/emotion/images/ac/{num}.gif";
		
		public static const DOUBLE_CLICK_INTERVAL:int = 300;
		
		public static const PLAYER_VOLUME_MAX:int = 500;
		
		public static const MEMBER_MORE_FIVE:String = "今天还可发送%s条弹幕";
		public static const MEMBER_MORE_FIVE_CLOSE:String = "还可发送%s条";
		public static const MEMBER_LESS_FIVE:String = "今天还可发送<font color='#f76332'>%s</font>条弹幕,通过答题转正可无限制发送";
		public static const MEMBER_LESS_FIVE_CLOSE:String = "还可发送<font color='#f76332'>%s</font>条";
		public static const MEMBER_ZERO:String = "今日还可发送<font color='#f76332'>%s</font>条弹幕,通过答题转正可无限制发送，<font color='#3f9cd7'><a href='event:gotoExa'>去答题激活</a></font>";
		public static const MEMBER_ZERO_CLOSE:String = "还可发送<font color='#f76332'>%s</font>条"
		
		public static const REQUIRE_LOGIN_TIP:String = "发送弹幕请先<font color='#ff9304'><a href='event:login'>[登录]</a></font>哟。</b>";
		
		/** 高级弹幕版本(用以区分处理不同时期的高级弹幕),addon.ver=x **/
		public static const SPECIAL_COMMENT_VERSION:int = 2;
		
		public static var MAX_USE_MEMORY_ARRAY:Array = [104857600,209715200,419430400,int.MAX_VALUE];
		
		public static var STAGE:Stage;
		
//		public static var FCK:FlashCookie;
		
//		public static var LETV_CHANNEL_ID:String = "bcloud_123966";
		
		public function ConstValue()
		{
		}
	}
}