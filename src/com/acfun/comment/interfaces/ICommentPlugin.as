package com.acfun.comment.interfaces
{
	import com.acfun.comment.entity.SingleCommentData;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	public interface ICommentPlugin
	{
		/**
		 * 弹幕初始化 
		 * @param cid 弹幕id
		 * @param time 视频时长		 
		 * @param highAccuracy 是否使用高精度计时器（true：内部使用高精度计时器，false：依赖外部时间）
		 * 
		 */
		function init(cid:String,time:int,highAccuracy:Boolean=true):void
		
		function setVideoLength(time:int):void
		/**
		 * 弹幕添加到舞台 
		 * @param container 弹幕要添加到的容器
		 * @param width 弹幕显示范围宽度
		 * @param height 弹幕显示范围高度
		 * @param includeInput 是否显示默认输入框
		 * 
		 */
		function add2stage(container:DisplayObjectContainer,width:Number,height:Number,includeInput:Boolean = true):void;
		
		/**
		 * 重定义弹幕显示范围 
		 * @param width 弹幕显示范围宽度
		 * @param height 弹幕显示范围高度
		 * 
		 */
		function resize(width:Number,height:Number):void;
		
		
		/**
		 * 弹幕时间轴时间 
		 * 
		 */
		function get time():Number;
		function set time(value:Number):void;		
		
		/**
		 * 弹幕播放状态
		 * 
		 */
		function get playing():Boolean;		
		function set playing(value:Boolean):void;
		
		
		/**
		 * 弹幕是否显示 
		 * 
		 */
		function get show():Boolean;
		function set show(value:Boolean):void;
		
		/**
		 * 弹幕显示层
		 *
		 */
		function get view():Sprite;
		
		/**
		 * 默认输入框 
		 * 
		 */
		function get cmtInput():Sprite;
		
		/**
		 * 发送弹幕 
		 * @param text 发送文本内容
		 * @param mode 弹幕模式
		 * @param color 弹幕文字颜色
		 * @param fontsize 弹幕文字大小
		 * @param user 用户
		 * @param isLock 是否锁定弹幕
		 * 
		 */
//		function send(text:String, mode:String = "1", color:uint = 16777215, fontsize:int = 25, user:String = "", isLock:Boolean = false):void;
		function send(param:Object):void;
			
		
		/**
		 * 返回所有弹幕信息 
		 * 
		 */
		function getAllComment():Vector.<SingleCommentData>;
		
		/**
		 * 刷新在线人数列表 
		 * 
		 */
		function refreshOnlineList():void;
		
		/**
		 * 刷新在线人数 
		 * 
		 */
		function refreshOnlineNumber():void;		
		
		/**
		 * 设置弹幕参数 
		 * @param config 参数源
		 * 
		 */		
		function setConfig(config:Object):void;
		
		/**
		 * 获取弹幕服务器连接的USER（可用来判断是否登录） 
		 * 
		 */
		function getUser():String;
		
		/**
		 * 获取弹幕服务器认证信息 
		 * 
		 */		
		function getAuthResult():Object;
		/**
		 * 弹出设置窗口 
		 * 
		 */		
		function getSetting():void;
	}
}