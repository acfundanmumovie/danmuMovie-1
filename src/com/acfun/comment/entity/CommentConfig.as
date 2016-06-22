package com.acfun.comment.entity
{
	import com.acfun.External.PARAM;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	import com.acfun.comment.control.CommentTime;
	import com.acfun.comment.display.CommentView;
	import com.acfun.comment.utils.CommentFilter;
	import com.acfun.signal.register;
	
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.system.Capabilities;
	import flash.text.Font;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;

	public class CommentConfig
	{
		//调整弹幕放大倍率的参考尺寸
		private var _width:int = 540;
		private var _height:int = 400;
		//调整特殊弹幕层的参考尺寸
		private var _spwidth:int = 540;
		private var _spheight:int = 399;	//不是420;	
		private static var _instance:CommentConfig = null;
		private var _visible:Boolean = true;
		public  var autoResize:Boolean = true;
		public var bold:Boolean = true;
		private var defstr:String = '微软雅黑,SimHei';//微软雅黑,SimHei
		private var _font:String='微软雅黑,SimHei,';//微软雅黑,SimHei,
		public var sizee:Number = 1;
		private var filters:Array = [[new GlowFilter(0, 0.7, 3,3)],[new DropShadowFilter(2, 45, 0, 0.6)],[new GlowFilter(0, 0.85, 4, 4, 3, 1, false, false)]];
		public var filter:Array;
//		public var alpha:Number=1;
		public var repeatfilter:Boolean = false;
		public var spsizelock:Boolean = false;
		public var spcacheAsBitmap:Boolean = false;
		/** 速度因子:0.1-2 **/
		public var speede:Number = 0.7;
		public var speede2:Number = .9;
		
		/*
		{label:"仅描边",data:[new GlowFilter(0, 0.7, 3,3)]},
		{label:"45度投影",data:[new DropShadowFilter(2, 45, 0, 0.6)]},
		{label:"深度投影",data:[new GlowFilter(0, 0.85, 4, 4, 3, 1, false, false)]}
		*/
		
		/** 宽度 **/
		public function get width():int					{return _width;}
		/** 高度 **/
		public function get height():int					{return _height;}		
		/** 特殊弹幕宽度 **/
		public function get spwidth():int					{return _spwidth;}
		/** 特殊弹幕高度 **/
		public function get spheight():int				{return _spheight;}	
		public function set filterIndex(value:int):void	{if(value>=0){filter = filters[value];}}
		public function get font():String					{return _font;}
		public function set font(f:String):void			{_font = f;}
		public function get visible():Boolean				{return _visible;}
		public function set visible(value:Boolean):void	{_visible = value;}

		public static function get instance():CommentConfig
		{
			if(_instance == null){_instance = new CommentConfig();}
			return _instance;
		}
		
		public function CommentConfig()
		{
			filterIndex = 0;
			
			register(SIGNALCONST.SET_DESKTOP_FULLSCREEN_CHANGE,function(isFullscreen:Boolean):void{
				cmtfontFxsize = isFullscreen ? 0.5:1;
			});
		}
		
		/**
		 *字体大小 
		 */
		public var cmtfontResize:Number = 1;
		/**
		 *字体全屏大小？ 
		 */
		public var cmtfontFxsize:Number = 1;
		/**
		 *是否使用Flash内置的TextFeild作为弹幕输出源 
		 */
		public var useTextFeild:Boolean = false;
		
		/**
		 * 流播放，不加载弹幕 
		 */
		public var isStreamVideoAct:Boolean = false;
		
		/** 字幕保护 **/
		public var subtitle_protect:Boolean = false;
		/** 弹幕保护区范围  **/
		public var subtitle_protect_percent:Number = 0.2;
		
		public function setConfig(config:Object):void
		{
			if (config["comment_font_name"] != null)
			{
				//_font = config["comment_font_name"];
				//_font += ",_serif,_sans";
				Log.info("[CommentConfig] set font ",_font);
			}
			if (config["comment_font_miaobian"] != null)
				filterIndex = config["comment_font_miaobian"];
			if (config["comment_font_bold"] != null)
				bold = config["comment_font_bold"];
			if (config["comment_font_scale"] != null)
				sizee = config["comment_font_scale"];
			if (config["comment_alpha"] != null)			
				CommentView.instance.cmtalpha = config["comment_alpha"];
			if (config["comment_speed"] != null)
				//speede = config["comment_speed"];
			if (config["auto_zoom"] != null)
				autoResize = config["auto_zoom"];
			if (config["old_compatible"] != null)
				spsizelock = config["old_compatible"];			
			if (config["subtitle_protect_percent"] != null)
				subtitle_protect_percent = config["subtitle_protect_percent"];
			if (config["subtitle_protect"] != null)
			{
				subtitle_protect = config["subtitle_protect"];
				CommentView.instance.resize();
			}
			if (config["comment_repeat_filter"] != null)
			{
				CommentFilter.getInstance().bRepfiliter = config["comment_repeat_filter"];
				CommentFilter.getInstance().dispatchEvent(new Event(Event.CHANGE));
//				CommentFilter.getInstance().savetoSharedObject();
			}
			if (config["comment_useTextField"] != null)
			{
				useTextFeild = config["comment_useTextField"];
				Log.debug("[CommentConfig] comment_useTextField=",useTextFeild);
			}
			
//			for each (var s:SingleCommentData in CommentTime.instance.getAllComments())
//			{
//				s.display = null;
//			}
		}
	}
}