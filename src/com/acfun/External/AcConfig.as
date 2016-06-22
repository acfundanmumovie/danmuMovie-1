package com.acfun.External
{
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	import com.acfun.comment.utils.LocalStorageManager;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	import com.hurlant.crypto.symmetric.NullPad;
	
	import flash.external.ExternalInterface;
	import flash.net.registerClassAlias;
	import flash.system.Capabilities;
	import flash.text.Font;
	import flash.text.FontType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	/**
	 * 播放器配置类（用户可自行配置） 
	 * @author sky
	 * 
	 */
	public class AcConfig
	{
		/** 皮肤  **/
		public var skin:String = "";
		/** 控制栏自动隐藏 **/
		public var controlbar_autohide:Boolean = false;
		
		/** 弹幕字体 **/
		public var comment_font_name:String = "黑体";
		/** 弹幕描边 **/
		public var comment_font_miaobian:int = 0;
		/** 弹幕加粗 **/
		public var comment_font_bold:Boolean = true;
		/** 字号缩放 **/
		public var comment_font_scale:Number = 1;
		/** 弹幕透明度 **/
		public var comment_alpha:Number = 1;
		/** 弹幕速度因子（0.1-2） **/
		public var comment_speed:Number = 0.7;
		/** 字幕保护 **/
		public var subtitle_protect:Boolean = false;
		/** 弹幕保护区范围  **/
		public var subtitle_protect_percent:Number = 0.2;		
		/** 旧版兼容 **/
		public var old_compatible:Boolean = false;
		/** 自动放大弹幕 **/
		public var auto_zoom:Boolean = false;
		/** 合并重复弹幕 **/
		public var comment_repeat_filter:Boolean = true;
		/** 弹幕兼容模式 **/
		public var comment_useTextField:Boolean = false;
		
		/** 画面质量  **/
		public var video_quality:int = 1;
		/** 启用时间锚点 **/
		public var time_anchor:Boolean = false;
		/** 连续发送  **/
		public var series_send:Boolean = false;
		/** 全屏请求输入 **/
		public var fullscreen_input:Boolean = false;
		/** 允许播放器搜索未缓冲部分（较费流量） **/
		public var seekto_unbuffered:Boolean = true;
		/** 自动切换分P **/
		public var auto_switch_p:Boolean = true;
		/** 双击全屏  **/
		public var doubleclick_fullscreen:Boolean = true;
		/** 双击网页全屏  **/
		public var doubleclick_webfullscreen:Boolean = false;
		/** 自动宽屏 **/
		public var auto_widescreen:Boolean = true;
		/** 宽屏高度限制  **/
		public var widescreen_height_limit:Boolean = false;
		/** 禁用快捷键 **/
		public var disable_hotkey:Boolean = false;
		/** 按shift生效（防止误操作） **/
		public var hotkey_shift:Boolean = false;
		/** 自动播放 **/
		public var auto_play:Boolean = false;
		/** 低内存模式 **/
		public var low_memory:Boolean = false;
		/** 占用内存阀值 **/
		public var max_use_memory_level:int = 0; 
		/** 尝试硬件加速 **/
		public var try_hardware_accelerate:Boolean = false;
		
		/** 右边栏设置收缩状态 **/
		public var rightpad_config_fold_state:Boolean = false;
		
		private static var _instance:AcConfig;
		
		public function AcConfig()
		{
			if (_instance != null)
				throw new Error("请使用getInstance()获取实例");
		}
		
		public static function getInstance():AcConfig
		{
			if (_instance == null)
			{
				_instance = new AcConfig();
				_instance.init();
			}
			return _instance;
		}
		
		private function init():void
		{
			var config:Object = LocalStorage.getValue(LocalStorage.PLAYER_CONFIG,{});		
			
			//纠正字体兼容问题
			if (config["comment_font_name"] && comment_font_name != config["comment_font_name"])
			{
				if (!Util.hasFont(config["comment_font_name"]))
				{
					Log.info("fix font ",config["comment_font_name"]);
					config["comment_font_name"] = "_serif";					 
				}	
			}
			
			//弹幕兼容模式默认值设置
			if (config["comment_useTextField"] == null)
			{
				if(Capabilities.os.indexOf("Windows") == -1)
				{
					config["comment_useTextField"] = true;
				}
			}
			
			onSetConfig(config);
			
			register(SIGNALCONST.SET_CONFIG,onSetConfig);
		}
		
		/**
		 * JS传入参数处理({config:object})
		 * 
		 */		
		public function saveConfig(param:Object):void
		{
			if (param != null)
			{
				var obj:Object = param.config;				
				notify(SIGNALCONST.SET_CONFIG,obj);	
			}
		}
		
		private function onSetConfig(config:Object):void
		{
			for (var key:String in config)
			{
				if (key in _instance)
					_instance[key] = config[key];
			}
			
			LocalStorage.setValue(LocalStorage.PLAYER_CONFIG,_instance);
		}
	}
}