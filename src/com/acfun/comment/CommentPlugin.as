package com.acfun.comment
{
	import com.acfun.External.AcConfig;
	import com.acfun.External.ConstValue;
	import com.acfun.External.JavascriptAPI;
	import com.acfun.External.LocalStorage;
	import com.acfun.External.PARAM;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.Utils.ClassLoader;
	import com.acfun.Utils.Log;
	import com.acfun.comment.communication.CommentHandler;
	import com.acfun.comment.communication.CommentServerEvent;
	import com.acfun.comment.control.CommentTime;
	import com.acfun.comment.display.CommentView;
	import com.acfun.comment.entity.CommentConfig;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.interfaces.ICommentPlugin;
	import com.acfun.comment.utils.CommentUtils;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	import flash.system.System;
	
	
	[Event(name="inputPluginLoadComplete", type="flash.events.Event")]
	
	/**
	 * 弹幕插件 
	 * @author sky
	 * 
	 */
	public class CommentPlugin extends Sprite implements ICommentPlugin
	{
		public static const COMMENT_PLUGIN_VERSION:String = "Comment Plugin V09.09.2014";
		
		public static var COMMENT_INPUT_PLUGIN:String = ConstValue.CONFIG_STATIC_URL + "/player/plugin/CommentInputDefault.swf?t=" + new Date().date + new Date().hours;
		
		private var _comment:CommentView;
		private var _handler:CommentHandler;
		private var _time:CommentTime;
		private var _input:Sprite;
		private var _container:DisplayObjectContainer;
		private var lastSendParam:Object;
		
		public function CommentPlugin()	
		{
			//Security.allowDomain("*");
			//Security.allowInsecureDomain("*");
		}
		
		public function getSetting():void{
			notify(SIGNALCONST.SKIN_SHOW_MORE_CONFIG);
		}
		
		public function init(cid:String,time:int,highAccuracy:Boolean=true):void
		{
			//register(SIGNALCONST.SET_CONFIG,setConfig);
			
			_comment = CommentView.instance;
			_handler = CommentHandler.instance;
			_time = CommentTime.instance;
			
			_comment.initPlugin(cid,time,highAccuracy);
			
			//handler listenner
			_handler.addEventListener(CommentServerEvent.INSERT_NEW_COMMENT,function(e:CommentServerEvent):void{ 
				notify(SIGNALCONST.COMMENT_NEW_COMMENT,e.data);
			});
			_handler.addEventListener(CommentServerEvent.ONLINE_LIST,function(e:CommentServerEvent):void{
				notify(SIGNALCONST.COMMENT_ONLINE_LIST,e.data);				 
			});
			_handler.addEventListener(CommentServerEvent.ONLINE_NUMBER,function(e:CommentServerEvent):void{
				notify(SIGNALCONST.COMMENT_ONLINE_NUMBER,e.data);				 
			});
			_handler.addEventListener(CommentServerEvent.AUTH_DATA,function(e:CommentServerEvent):void{
				notify(SIGNALCONST.COMMENT_SERVER_CONNECTED,e.data);				 
			});
			
			setConfig(AcConfig.getInstance());
		}
		
		public function setVideoLength(time:int):void{
			CommentHandler.instance.vlength = time;
		}
		
		public function add2stage(container:DisplayObjectContainer, width:Number, height:Number, includeInput:Boolean = true):void
		{
			_container = container;
			container.addChild(_comment);
			resize(width,height);
			
			if (includeInput)
			{				
				var me:CommentPlugin = this;
				if (Security.sandboxType != Security.REMOTE)
					COMMENT_INPUT_PLUGIN = "CommentInputDefault.swf";
				var cl:ClassLoader = new ClassLoader(COMMENT_INPUT_PLUGIN,function():void{
					var inputc:Class = cl.getClass("com.acfun.comment.skin.CommentInputDefault");
					_input = new inputc(me);
					_input.x = (width - _input.width)/2;
					_input.y = height;
					container.addChild(_input);
					dispatchEvent(new Event("inputPluginLoadComplete"));
				});
//				_input = new CommentInputC(this);
//				_input.x = (width - _input.width)/2;
//				_input.y = height;			
			}
		}		

		public function get playing():Boolean
		{
			return _comment.playing;
		}
		
		public function set playing(value:Boolean):void
		{
			_comment.playing = value;			
		}

		public function get show():Boolean
		{
			return _comment.showComment;
		}
		
		public function set show(value:Boolean):void
		{
			_comment.showComment = value;
		}
		
		public function get time():Number
		{
			return _comment.currentTime;
		}
		
		public function set time(value:Number):void
		{
			if (playing)
				_comment.time(value);
		}
		
		public function get cmtInput():Sprite
		{
			return _input;			
		}
		
		public function resize(width:Number, height:Number):void
		{
			_comment.resize(width,height);
		}
		
		public function send(param:Object):void
		{
			if (param != null && param.text && param.text != "")
			{
				var text:String = param.text;
				
				if (runCommand(text))
					return;
				//trace("--Atext:"+text)
				//\r换行
				text = text.replace(/\\r/g,"\r");
				//trace("--Btext:"+text)
				//空弹幕过滤
				if (text.search(/^\s*$/) == 0)
					return;
				
				if (lastSendParam == null)
				{
					lastSendParam = LocalStorage.getValue(LocalStorage.COMMENT_SEND_PARAM,{ type:"1",color:0xFFFFFF,fontSize:25 });
				}
				
				var mode:String = param.type || "1";
				var color:String = param.color || lastSendParam.color;
				var fontsize:int = param.fontSize || 25;
				
				//保存参数
				lastSendParam.type = mode;
				lastSendParam.color = color;
				lastSendParam.fontSize = fontsize;				
				LocalStorage.setValue(LocalStorage.COMMENT_SEND_PARAM,lastSendParam);
				Log.debug("save send param:",lastSendParam.color);
				
				//发送
				var data:Object = { mode:mode,color:color,size:fontsize,message:text,stime:param.stime || _comment.currentTime};		
				var cd:SingleCommentData = CommentUtils.createNewComment(data,false,true);				
				_handler.send(cd);
			}
		}
		
//		public function send(text:String, mode:String = "1", color:uint = 16777215, fontsize:int = 25, user:String = "", isLock:Boolean = false):void
//		{
//			if (runCommand(text))
//				return;
//			
//			//\r换行
//			text = text.replace(/\\r/g,"\r");
//			
//			//空弹幕过滤
//			if (text.search(/^\s*$/) == 0)
//				return;
//			
//			//保存发送参数							
//			LocalStorage.setValue(LocalStorage.COMMENT_SEND_PARAM,{type:mode,color:color,fontSize:fontsize});
//			
//			//发送
//			var data:Object = { mode:mode,color:color,size:fontsize,message:text,stime:_comment.currentTime,user:user };		
//			var cd:SingleCommentData = CommentUtils.createNewComment(data,isLock);
//			cd.border = true;
//			_handler.send(cd);
//		}		
		
		public function getAllComment():Vector.<SingleCommentData>
		{
			return _time.getAllComments();
		}
		
		public function refreshOnlineList():void
		{
			_handler.refreshOnlineList();
		}
		
		public function refreshOnlineNumber():void
		{
			_handler.refreshOnlineNumber();
		}
		
		public function set customValidate(value:Function):void
		{
			_time.customValidate = value;
		}
		
		public function get view():Sprite
		{
			return _comment;
		}
		
		public function setConfig(config:Object):void
		{
			CommentConfig.instance.setConfig(config);
		}
		
		private function runCommand(text:String):Boolean
		{
			//'#'开头是命令
			if (text.charAt(0) != "#")			
				return false;
			
			Log.info("执行命令：",text);
			
			var params:Array = text.toLowerCase().split(" ");
			var command:String = params.shift();
			
			switch(command)
			{
				case "#special":
				case "#搞基":
				case "#高级":
				case "#36d":
				case "#gj":
				{
					notify(SIGNALCONST.SPECIAL_COMMENT_EXPAND,true);
					break;
				}	
				case "#showlog":
				{
					Log.toggleShow(true);
					break;
				}
				case "#commentID":
				case "#cid":
				{
					//获取弹幕id
					System.setClipboard(getCommentId());
					break;
				}
				case "#vid":
				{
					if (params[0])
					{
						CommentHandler.instance.changeVid(params[0]);
					}
					else
					{
						System.setClipboard(PARAM.vid);	
					}
					break;
				}
				case "#answer":
				{
					Log.info("去答题秘籍");
					//JavascriptAPI.callJS(JavascriptAPI.PLAYER_READY);
					JavascriptAPI.callJS(JavascriptAPI.CALL_ACTION,{"action":"answer"});
					break;
				}
				default:
				{
					Log.info("未识别的命令：",text);
					break;
				}
			}
			return true;
		}
		
		public function getUser():String
		{
			return _handler.commentUser;
		}
		
		public function getAuthResult():Object
		{
			return _handler.commentAuthResult;
		}
		
		public function getCommentId():String
		{
			return _handler.vid;
		}
		
//		public function report(s:SingleCommentData):void
//		{
//			_handler.report(s);
//		}
//		
//		public function remove(s:SingleCommentData):void
//		{
//			_handler.remove(s);
//		}
//		
//		public function blockUser(user:String):void
//		{
//			_handler.blockUser(user);
//		}
	}
}