package com.acfun.External
{
	public class SIGNALCONST
	{
		/**
		 * 设置播放条位置 
		 */
		public static const SET_POSITION_CHANGE:String = "SET_POSITION_CHANGE";
		/**
		 * 设置音量 
		 */
		public static const SET_VOLUME_CHANGE:String = "SET_VOLUME_CHANGE";
		/**
		 * 设置静音 
		 */
		public static const SET_SILENT_CHANGE:String = "SET_SILENT_CHANGE";
		/**
		 * 设置循环
		 */
		public static const SET_LOOP_CHANGE:String = "SET_LOOP_CHANGE";
		/**
		 * 设置桌面全屏状态 
		 */
		public static const SET_DESKTOP_FULLSCREEN_CHANGE:String = "SET_DESKTOP_FULLSCREEN_CHANGE";
		/**
		 * 设置网页全屏状态 
		 */		
		public static const SET_WEB_FULLSCREEN_CHANGE:String = "SET_WEB_FULLSCREEN_CHANGE";
		/**
		 * 设置通用全屏状态
		 */		
		public static const SET_ALL_FULLSCREEN_CHANGE:String = "SET_ALL_FULLSCREEN_CHANGE";
		/**
		 * 播放器大小改变(width,height) 
		 */		
		public static const SET_SIZE_CHANGE:String = "SET_SIZE_CHANGE";
		/**
		 * 设置播放/暂停状态 
		 */
		public static const SET_PLAYSTATUS_CHANGE:String = "SET_PLAYSTATUS_CHANGE";		
		/**
		 * 设置弹幕显示/隐藏(bool)
		 */
		public static const SET_COMMENTSTATUS_CHANGE:String = "SET_COMMENTSTATUS_CHANGE";
		/**
		 * 设置参数更新(AcConfig)
		 */
		public static const SET_CONFIG:String = "set_config";
		/**
		 * 更新可发送剩余条数 
		 */		
		public static const UPDATE_REMAIN_SENDS:String = "updateRemainSends";
		/**
		 * 设置关键字过滤过滤(json String) 
		 */		
//		public static const SET_KEYWORD_FILTER:String = "set_keyword_filter";
		/**
		 * 设置弹幕类型屏蔽(json String) 
		 */		
		public static const SET_COMMENT_FILTER:String = "set_comment_filter";
		/**
		 * 设置视频比例(int)<br/>
		 * 0：原始<br/>
		 * 1：4比3<br/>
		 * 2:16比9<br/>
		 * 3：填充 <br/>
		 */		
		public static const SET_PLAYER_RATIO:String = "SET_PLAYER_RATIO";		
		/**
		 * 切换视频画质 (rate:int)<br/>
		 * 0：原画<br/>
		 * 1：超清<br/>
		 * 2：高清<br/>
		 * 3：流畅<br/>
		 */		
		public static const SET_PLAYER_RATE:String = "SET_PLAYER_RATE";
		/**
		 * 切换视频画质完成 (rate:int,rates:Array)<br/>
		 * 0：原画<br/>
		 * 1：超清<br/>
		 * 2：高清<br/>
		 * 3：流畅<br/>
		 */
		public static const SET_PLAYER_RATE_CHANGED:String = "SET_PLAYER_RATE_CHANGED";
		/**
		 * 输入颜文字 
		 */		
		public static const SET_FACE_TEXT:String = "SET_FACE_TEXT";
		/**
		 * 接收到新弹幕(SingleCommentData)
		 */
		public static const COMMENT_NEW_COMMENT:String = "comment_new_comment";
		
		/**
		 * 接收到在线列表(Array)
		 */
		public static const COMMENT_ONLINE_LIST:String = "comment_online_list";
		
		/**
		 * 接收到在线人数(uint)
		 */
		public static const COMMENT_ONLINE_NUMBER:String = "comment_online_number";
		
		/**
		 * 清除弹幕(void) 
		 */		
		public static const COMMENT_CLEAR:String = "comment_clear";
		
		/**
		 * 弹幕读取完毕( {data:SingleCommentData 数组,size:弹幕池大小} ）
		 */		
		public static const COMMENT_PREPARED:String = "comment_prepared";
		
		/**
		 * 弹幕服务器已连接并认证 
		 */		
		public static const COMMENT_SERVER_CONNECTED:String = "comment_server_connected";
		
		/**
		 *  弹幕发送（Object----param.text,param.type,param.color,param.fontSize)
		 */		
		public static const COMMENT_SEND:String = "comment_send";
			
		/**
		 *  简易弹幕发送（string)
		 */		
		public static const COMMENT_SEND_SIMPLE:String = "comment_send_simple";
		
		/**
		 *  弹幕举报（SingleCommentData)
		 */		
		public static const COMMENT_REPORT:String = "comment_report";
		
		/**
		 *  弹幕删除（SingleCommentData Array)
		 */		
		public static const COMMENT_DELETE:String = "comment_delete";
		
		/**
		 *  删除选择用户所有弹幕（String)
		 */		
		public static const COMMENT_DELETE_BY_USER:String = "comment_delete_by_user";
		
		/**
		 *  锁定选择用户所有弹幕（String)
		 */		
		public static const COMMENT_LOCK_BY_USER:String = "comment_lock_by_user";
		
		/**
		 *  用户屏蔽（String)
		 */		
		public static const COMMENT_USER_BLOCK:String = "comment_user_block";
		
		/**
		 *  弹幕定位（SingleCommentData)
		 */		
		public static const COMMENT_LOCATION:String = "comment_location";
		
		/**
		 *  用户封禁
		 */		
		public static const COMMENT_USER_BANNED:String = "comment_user_banned";
		
		/**
		 * 由Skin模块实现 
		 * 传入已加载时长
		 */
		public static const SKIN_BUFF_PROG:String = "SKIN_BUFF_PROG";
		/**
		 * 由Skin模块实现 
		 * 传入播放时长
		 */
		public static const SKIN_PLAY_PROG:String = "SKIN_PLAY_PROG";
		/**
		 * 由Skin模块实现 
		 * 传入视频播放与否
		 */
		public static const SKIN_PLAY_STATUS:String = "SKIN_PLAY_STATUS";
		/**
		 * 由Skin模块实现 
		 * 传入载入状态
		 */
		public static const SKIN_BUFF_STATUS:String = "SKIN_BUFF_STATUS";
		/**
		 * 由Skin模块实现 
		 * 传入全屏状态
		 */
		public static const SKIN_SREEN_STATUS:String = "SKIN_SREEN_STATUS";
		/**
		 * 由Skin模块实现 
		 * 传入视频长度
		 */
		public static const SKIN_VEDIO_LENGHT:String = "SKIN_VEDIO_LENGHT";
		/**
		 * 由Skin模块实现 
		 * 传入音量
		 */
		public static const SKIN_VOLUME_LENGHT:String = "SKIN_VOLUME_LENGHT";
		/**
		 * 由Skin模块实现
		 * 显示提示信息（SkinControl.showMessage(message:String, pic:String="", canClose:Boolean=true, onClose:Function=null))
		 */		
		public static const SKIN_SHOW_MESSAGE:String = "SKIN_SHOW_MESSAGE";
		/**
		 * 由Skin模块实现
		 * 显示提示信息（AcShowInfo.show(infoString:String,callback:Object = null,duration:int = 10000))
		 */		
		public static const SKIN_SHOW_INFO:String = "SKIN_SHOW_INFO";
		/**
		 * 由Skin模块实现
		 * 显示更多设置
		 */		
		public static const SKIN_SHOW_MORE_CONFIG:String = "SKIN_SHOW_MORE_CONFIG";
		/**
		 * 由Skin模块实现
		 * 显示推荐弹窗{isUped,isFavored}
		 */		
		public static const SKIN_SHOW_RECOMMEND:String = "skin_show_recommend";
		/**
		 * 由Skin模块实现
		 * 隐藏推荐弹窗
		 */		
		public static const SKIN_HIDE_RECOMMEND:String = "skin_hide_recommend";
		
		/**
		 * 右边栏大小改变，包括展开、收起(width,height) 
		 */		
		public static const PAD_SIZE_CHANGE:String = "PAD_SIZE_CHANGE";		
		/**
		 * 右边栏展开动画开始
		 */
		public static const PAD_SIZE_EXPAND_START:String = "PAD_SIZE_EXPAND_START";
		/**
		 * 右边栏收起动画结束
		 */
		public static const PAD_SIZE_PACKUP_END:String = "PAD_SIZE_PACKUP_END";
		/**
		 * 右面板展开按钮显示/隐藏 (state:Number)<br/>
		 * 			case 0: // 普通显示<br/>
					case 1: // 普通消失<br/>
					case 2: // 全屏消失<br/>
					case 3:	// 全屏显示<br/>
		 */		
		public static const PAD_EXPAND_BUTTON_SHOW:String = "PAD_EXPAND_BUTTON_SHOW";
		/**
		 * 刷新右侧面板 
		 */		
		public static const PAD_REFRESH:String = "PAD_REFRESH";
		
		/**
		 * 进入高级弹幕模式 
		 */		
		public static const SPECIAL_COMMENT_EXPAND:String = "SPECIAL_COMMENT_EXPAND";
		
		/**
		 * 按下ESC之后派发取消通知 
		 */		
		public static const HOTEY_CANCEL:String = "HOTEY_CANCEL";
		
		/**
		 * 开始播放 
		 */		
		public static const PLAYER_BEFORE_PLAY:String = "PLAYER_BEFORE_PLAY";
		
		/**
		 * 得到视频信息 ({width:xxx,height:xxx,rates:[0,1,2,3,4...]});
		 */		
		public static const VIDEO_INFO:String = "get_video_info";
		
		
		public static const GET_NEXT_VIDEO:String = "getNextVideo";
		public static const CHANGE_VIDEO:String = "changeVideo";
		
		public static const VIDEO_PAUSE:String = "video_pause";
		public static const VIDEO_VOLUME:String = "VIDEO_VOLUME";
		
		
		public static const VIDEO_START:String = "videoStart";
		public static const VIDEO_END:String = "videoEnd";
		
		public static const SOCKET_INIT:String = "SOCKET_INIT";
		
		public static const CHANGE_LOGO:String = "CHANGE_LOGO";
		
		public static const SEND_COMMENT:String = "SEND_COMMENT";
		public static const SEND_GIF:String = "SEND_GIF";
		
		public static const CHANGE_VIEW:String = "CHANGE_VIEW";
		
	}
}