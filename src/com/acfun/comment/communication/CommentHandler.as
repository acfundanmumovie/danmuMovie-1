package com.acfun.comment.communication
{
	import com.acfun.External.ConstValue;
	import com.acfun.External.JavascriptAPI;
	import com.acfun.External.PARAM;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	import com.acfun.comment.control.CommentTime;
	import com.acfun.comment.display.CommentView;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.utils.AuthData;
	import com.acfun.comment.utils.CommentFilter;
	import com.acfun.comment.utils.CommentUtils;
	import com.acfun.net.PtoP;
	import com.acfun.net.analysis.AnalysisUtil;
	import com.acfun.net.analysis.errors.ACError;
	import com.acfun.net.analysis.errors.ErrorType;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	import com.acfun.test.CommentBox;
	import com.adobe.serialization.json.JSONParseError;
	import com.adobe.utils.StringUtil;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.Security;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import org.osflash.signals.Signal;
	
	/** 插入新弹幕  **/
	[Event(name="insert_newcomment", type="com.acfun.comment.communication.CommentServerEvent")]
	
	/** 在线人数  **/
	[Event(name="online_number", type="com.acfun.comment.communication.CommentServerEvent")]
	
	/** 在线人数列表 **/
	[Event(name="online_list", type="com.acfun.comment.communication.CommentServerEvent")]
	
	/** 认证信息  **/
	[Event(name="auth_data", type="com.acfun.comment.communication.CommentServerEvent")]
	
	/** 发送消息失败 **/
	[Event(name="send_error", type="com.acfun.comment.communication.CommentServerEvent")]
	
	public class CommentHandler extends EventDispatcher
	{
		//debug
//		public static var COMMENT_BASE_URI:String = 'ws://10.232.0.201:443';
//		public static var COMMENT_STATIC_FILE_URI:String = 'http://182.18.54.46:5008/V2';
		//正式
		public static var COMMENT_LOAD_PAGE_SIZE:int = 500;
		
		private static const connectwait:int = 20000; //连接超时
		private static const onlinewait:int = 10000;  //检测在线超时
		private var websocket:WebSocket;
		private static var banned:Boolean = false; // 用户被封禁，保留字段
		private var checkConnectionFlag:Boolean = false;
		private var droppedConnectionCount:int = 0;
		private var checkConnectionTimeOut:uint = 0;
		private var waitCheckConnectionTimeOut:uint = 0;
		private var reconnectCount:uint = 0;
		private var reconnectTimeoutSeed:uint;
		private var commentFilter:CommentFilter;
		private var sendBuffer:Vector.<String>;
		private var directSendBuffer:Vector.<SingleCommentData>;
		private var isUserAuthed:Boolean = false;
		private var lastCheckTime:Number = 0;
		private var online:uint = 1;
		public var vlength:int;
		protected var vNumber:int;
		protected var authResult:Object = {};
		/** commentid哈希表，防止重复 **/
		protected var commentIds:Object = {};
		
		protected var isSataicFileLoaded:Boolean = false;
		
		private static var _instance:CommentHandler;
		
		public var vid:String;
		
		///////////////
		public static var _onSignal:Signal;//广播事件，通知特殊弹幕点击数
		//private var _ptop:PtoP;
		
		//临时措施：同时往旧版弹幕服发一次
//		public var oldHandler:CommentHandlerOldSimple;
		
		//弹幕管理
		private var adminHandler:CommentHandlerAdmin;
			
		public function CommentHandler()
		{
//			Security.loadPolicyFile("xmlsocket://cj.aixifan.com:843");
//			Security.loadPolicyFile("http://cj.aixifan.com:843");
			Security.loadPolicyFile("xmlsocket://dm.aixifan.com:843");//主动请求安全文件
			// 这里暂时不初始化WebSocket			
//			keywordsFilter = KeywordsFilter.Instance;
			commentFilter = CommentFilter.getInstance();
			sendBuffer = new Vector.<String>();
			directSendBuffer = new Vector.<SingleCommentData>();
			lastCheckTime = new Date().time;
			/////////
			_onSignal=new Signal(String);
		//_ptop = new PtoP();
		}
		
		public static function get instance():CommentHandler
		{
			if(_instance == null)
			{
				_instance = new CommentHandler();
			}
			return _instance;
		}
		
		public function init(commentId:String,vlength:int):void
		{
			this.vid = commentId;
			this.vlength = vlength;
			this.vNumber = Math.round(vlength / 60) * 100;
			if (this.vNumber < 500) this.vNumber = 500;
			if(websocket != null)
			{
				abortAllOperations();
				// 强制关闭WS连接
				websocket.close(false);
			}
			var conn:String = "ws://dm.aixifan.com/ws/player";//ws://cj.aixifan.com/ws/player
//			Log.debug("连接到评论服务器：" , conn);
			websocket = new WebSocket(conn,'*',null,connectwait);			
			websocket.debug = false;
			this.connect();
			
			//旧版弹幕系统兼容
//			oldHandler = new CommentHandlerOldSimple();
//			oldHandler.init(commentId,vlength);
			
			register(SIGNALCONST.COMMENT_REPORT,report);
			register(SIGNALCONST.COMMENT_USER_BLOCK,blockUser);
			register(SIGNALCONST.COMMENT_DELETE,remove);
			register(SIGNALCONST.COMMENT_DELETE_BY_USER,removeAll);
			register(SIGNALCONST.COMMENT_LOCK_BY_USER,lockAll);
			register(SIGNALCONST.COMMENT_USER_BANNED,userBanned);
		}
		
		private function userBanned():void
		{
			if (!banned)
			{
				Log.info("you are banned!");
				notify(SIGNALCONST.SKIN_SHOW_MESSAGE,"您已因违规操作被临时禁言。\n如有疑问请联系客服。","19");
				banned = true;	
			}
		}
		
		public function insertNewComment(data:SingleCommentData):void
		{
			
			CommentTime.instance.insert(data);		
			dispatchEvent(new CommentServerEvent(CommentServerEvent.INSERT_NEW_COMMENT,data));
		}
		
//		public function reset(commentId:String='0',vlength:int = 500, userId:String=null, userCheckString:String=null,isLive:Boolean = false):void
//		{
//			init(commentId,vlength, userId, userCheckString,isLive);
//		}
		
		public function send(comment:SingleCommentData):void
		{
			//TODO: 建立队列
			comment.user = commentUser;
//			if(!keywordsFilter.validateCommentData(comment)){return;}
			
			sendBuffer.push(CommentUtils.createObjectStringToSend(comment));			
//			Log.debug("send buffer is ",sendBuffer.join("\n"));
			
			checkSendStack();
			
//			if (oldHandler)
//				oldHandler.send(comment);
		}
		
		private var lastText:String = "";
		private function checkRepeatComment(text:String):Boolean
		{
			text = StringUtil.trim(text);
			
			if (text == lastText) return true;
			
			if (text.length > 7)
			{
				if (text.substr(0,7) == lastText.substr(0,7))
					return true;
			}
			
			lastText = text;
			return false;
		}
		
		public function directSend(comments:Vector.<SingleCommentData>=null):void
		{
			if (banned) return;
			
			if (comments)			
			{
				directSendBuffer = directSendBuffer.concat(comments);
//				if (oldHandler)
//					oldHandler.directSend(comments);
			}
			
			if (directSendBuffer.length > 0)
			{
				if (websocket && websocket.connected && isUserAuthed)
				{
					var comment:SingleCommentData = directSendBuffer.shift();
					comment.border = false;				
					websocket.sendUTF(CommentUtils.createObjectStringToSend(comment));					
					notify(SIGNALCONST.COMMENT_NEW_COMMENT,comment);
				}
				else
				{
					//检测重连
					checkSendStack();
				}
			}			
		}
		
		public function getDirectSendBuffer():Vector.<SingleCommentData>
		{
			return directSendBuffer;
		}
		
		public function remove(comments:Array):void
		{
			if (PARAM.userInfo.isAdmin)
			{
				//管理员删除
//				if (oldHandler)
//					oldHandler.remove(comments);
				
				if (adminHandler)
					adminHandler.remove(comments);
			}
			else if (PARAM.userInfo.isUp)
			{
				//up主删除
				if (comments && comments.length > 0)
				{
					Log.info("delete comment number: ",comments.length);			
					sendBuffer.push(CommentUtils.createObjectStringToDelete((comments)));
					checkSendStack();
				}
			}
			
			//视觉上删除
			for each (var s:SingleCommentData in comments)
			{
				CommentTime.instance.delcomment(s.index);
				CommentView.instance.clearComment("i="+s.index);
			}
		}
		
		public function lock(comments:Array):void
		{
			if (adminHandler)
				adminHandler.lock(comments);
		}
		
		public function removeAll(user:String):void
		{
			remove(filterByUser(user));			
		}
		
		public function lockAll(user:String):void
		{
			lock(filterByUser(user));
		}
		
		private function filterByUser(user:String):Array
		{
			var comments:Array = [];
			for each (var s:SingleCommentData in CommentTime.instance.getAllComments())
			{
				if (s.user == user)
					comments.push(s);
			}
			return comments;
		}
		
		public function close():void
		{
			//TODO: implement function
		}
		
		public function refreshOnlineList():void
		{
			if(websocket == null || !(websocket.connected)){return;}
			var en:String = Util.encode({action : 'list',command:"WALLE DOES NOT HAVE PENNIS"});
			websocket.sendUTF(en);
		}
		
		public function refreshOnlineNumber():void
		{
			if(websocket == null || !(websocket.connected)){return;}
			var en:String = Util.encode({action : 'onlanNumber',command:"WALLE DOES NOT HAVE PENNIS"});
			websocket.sendUTF(en);
		}		
		
		// ----------------------------- 私有方法
		/**
		 * 终止所有操作 
		 * 
		 */		
		private function abortAllOperations():void
		{
//			isSataicFileLoaded = false;						
			removeWebsocketListeners();
			clearTimeout(checkConnectionTimeOut);
			checkConnectionFlag = false;
			clearTimeout(waitCheckConnectionTimeOut);
		}
		private function connect():void
		{
			isUserAuthed = false;
			addWebsocketListeners();
//			initConstants();
			websocket.connect();
		}
		private function checkSendStack():void
		{
			if(websocket == null)
			{
				Log.debug("websocket is null");
				reconnectCount = 0;
				reConnect();
				return;
			}
			if(!websocket.connected)
			{
				Log.debug("websocket is disconnected");
				reconnectCount = 0;
				reConnect();
				return;
			}
//			if(!isUserAuthed)
//			{
//				Log.debug("user not authed,re-auth");
//				sendAuthData();				
//				return;
//			}
//			if (directSendBuffer.length > 0)
//			{
//				directSend();
//			}
			if(new Date().time - this.lastCheckTime < 3000)
			{
				Log.debug("check date failed in 3s");
				return;
			}
			if(sendBuffer.length > 0)	//暂时取消重发机制，避免弹幕重复	
			{				
//				websocket.sendUTF(sendBuffer[0]);				
//				this.lastCheckTime = new Date().time;
//				Log.debug(sendBuffer[0]);
				
				var sendString:String = sendBuffer.pop();
				websocket.sendUTF(sendString);
				lastCheckTime = new Date().time;
			}
		}
		private function reConnect():void
		{
			this.isInit = true;
			removeWebsocketListeners();
			clearTimeout(checkConnectionTimeOut);
			checkConnectionFlag = false;
			clearTimeout(waitCheckConnectionTimeOut);
			reconnectCount++;
			if (reconnectCount < 6)
			{
				clearTimeout(reconnectTimeoutSeed);
				reconnectTimeoutSeed = setTimeout(function():void{
					Log.warn("断线重连");					
					init(vid,vlength);
				},Math.random()*5000*reconnectCount);
			}
		}
//		private function initConstants():void
//		{
//			this.droppedConnectionCount = 0;
//			// 设定下一次检查Connection的时间
//			if (PARAM.acInfo.isLive)
//				commentReady();
//			else
//				loadStaticFile();
//		}
		private function praseList(a:Array):void
		{
			
			try
			{
				CommentTime.instance.restartLine();
//				var locksize:int = a[1].length;
				var b:Array = [];
				for (var i:int=0;i<a.length;i++)
				{
						var cmd:Object = a[i];
						var info:String = cmd["c"];
						var message:String = cmd["m"];
						if(info)
						{
							var c:Array = info.split(',');
							var rTime:String = c[0];
							if(rTime.lastIndexOf("%") != -1){
								rTime = (int(rTime.replace("%","")) * vlength / 100).toString();
							}
							b.push({stime : rTime,color : c[1],mode : c[2],size:c[3],user:c[4],time:int(c[5])*1000,message:message,commentid:c[6],type:i.toString()});	
												
						}
				}
				b.sortOn("time",Array.NUMERIC);
				while(b.length > 0)
				{
					var obj:Object = b.pop();
					dispatchNewComment(obj,obj.type=="1");
				}
			}
			catch(e:JSONParseError)
			{
				Log.error("解析弹幕失败",e.getStackTrace());
				this.dispatchEvent(new CommentServerEvent(CommentServerEvent.PARSE_COMMENT_ERROR,e.message));
			}
		}
		
		private function checkConnection():void
		{
			clearTimeout(checkConnectionTimeOut);
			checkConnectionFlag = false;
			waitCheckConnectionTimeOut = setTimeout(waitCheckConnectionTimeout,onlinewait);
			websocket.ping();			
		}
		private function waitCheckConnectionTimeout():void
		{
			clearTimeout(waitCheckConnectionTimeOut);
			if(!checkConnectionFlag)
			{
				Log.info("掉线检测失败");
				if(this.droppedConnectionCount > 2 && reconnectCount < 2)
				{
					Log.error("重新连接");
					clearTimeout(checkConnectionTimeOut);
					this.reConnect();					
					return;
				}
				else
				{
					if(reconnectCount >= 2)
					{
						Log.error("三次重试失败");
					}
					else
					{
						Log.info("延迟5秒重试");
						this.droppedConnectionCount ++;
						clearTimeout(checkConnectionTimeOut);
						checkConnectionTimeOut = setTimeout(checkConnection,5000);
						return;
					}
				}
			}
			// 三次掉线，重连处理。
			Log.error("放弃重新连接服务器");
			
		}
		private function dispatchOnlineNumber(online:uint):void
		{
			this.online = online;
			this.dispatchEvent(new CommentServerEvent(CommentServerEvent.ONLINE_NUMBER,online));
			refreshPage();
		}
		private function onMessageSendFinished(value:* = null):void
		{
			//暂时取消重发机制，避免弹幕重复	
//			sendBuffer.shift();
//			directSendBuffer.shift();
			Log.info("发送成功，剩余条数：",sendBuffer.length,directSendBuffer.length);
			notify(SIGNALCONST.UPDATE_REMAIN_SENDS,value["msg"]);
			setTimeout(directSend,100);
		}
		private function dispatchOnlineList(online:Array):void
		{
			this.dispatchEvent(new CommentServerEvent(CommentServerEvent.ONLINE_LIST,online));
			this.dispatchEvent(new CommentServerEvent(CommentServerEvent.ONLINE_NUMBER,online.length));
		}
		private function dispatchReportOK(dat:Object):void
		{
			if (dat["request"] == "report")
			{
				//nothing
			}
			
			if (dat["request"] == "del")
			{
				notify(SIGNALCONST.SKIN_SHOW_INFO,"删除弹幕成功！");
			}
		}
		protected function dispatchNewComment(dat:Object,isLock:Boolean = false):void
		{
			//构造commentData吧			
			var cmtData:SingleCommentData = CommentUtils.createNewComment(dat,isLock);
			
			//防止重复弹幕
//			if (cmtData==null || commentIds[cmtData.commentid]) 
//			{
//				Log.debug("分块读取出现重复弹幕，过滤");
//				return;
//			}
			commentIds[cmtData.commentid] = true;
//			if(cmtData.filterType == 0)
//				cmtData.display = CommentTime.instance.getCm(cmtData).getComment(cmtData);
			if(cmtData.mode == SingleCommentData.FIXED_POSITION_AND_FADE || commentFilter.systemFil(cmtData.text) || cmtData.user == commentUser)
			{			
				insertNewComment(cmtData);
			}
		}
		
		/**
		 * 登陆ws验证 
		 * @param auth
		 */		
		private function dispatchAuthData(auth:Object):void
		{
			isUserAuthed = true;
			reconnectCount = 0;
			var authData:AuthData = new AuthData();
			var cilient:String = auth['client'];
			var cilient_ck:String = auth['client_ck'];
			if(cilient && (authData.Player_id != cilient || authData.Player_hash != cilient_ck))
			{
				authData.setAuth(cilient,cilient_ck);
				Log.info("改变Auth值",cilient,cilient_ck);				
			}
			else
			{
				Log.debug("用户特征未改变");
			}
			// = authData.Player_hash;
			authResult = auth;
			this.dispatchEvent(new CommentServerEvent(CommentServerEvent.AUTH_DATA,auth));
			
			if (authResult["disabled"].toString().toLowerCase() == "true")
			{
				//被封禁用户
				userBanned();
			}
			
			//认证之后显示在线人数
			refreshOnlineNumber();
			//定时刷新在线人数
			setInterval(refreshOnlineNumber,30000);
			//请求黑名单
//			requireBanList();
			
			if (isAdmin && adminHandler == null)
			{
				adminHandler = new CommentHandlerAdmin();
				adminHandler.init(vid,vlength);			
			}
		}
		// -----------------------------
		// ----------------------------- 异常处理
		
		
		private function addWebsocketListeners():void
		{
			Log.info("侦听器已被添加");
			websocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			websocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			websocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);//获取弹幕
			websocket.addEventListener(WebSocketEvent.PONG, handlePong);//心跳检测，在close前触发
			websocket.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);// IOError无需处理，将自动抛出Close事件
			websocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);// SecurityError无需处理，将自动抛出Close事件
			websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);// CONNECTION_FAIL 之后自动触发Close
			/*websocket.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void{
				trace(e);
			});*/
		}
		private function removeWebsocketListeners():void
		{
			Log.info("侦听器已被移除");
			websocket.removeEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			websocket.removeEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			websocket.removeEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			websocket.removeEventListener(WebSocketEvent.PONG, handlePong);
			websocket.removeEventListener(IOErrorEvent.IO_ERROR, handleIOError);// IOError无需处理，将自动抛出Close事件
			websocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);// SecurityError无需处理，将自动抛出Close事件
			websocket.removeEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);// CONNECTION_FAIL 之后自动触发Close
		}
		private function handleIOError(e:IOErrorEvent):void
		{
			Log.error("IO错误，请检查网络");
			AnalysisUtil.send(ACError.create({info:"连接ws失败：io错误->"+websocket.uri},ErrorType.WS_CONNECT_FAIL));
		}
		private function handleConnectionFail(e:WebSocketErrorEvent):void
		{
			Log.error("连接失败，请检查网络：",e.text);
			AnalysisUtil.send(ACError.create({info:"连接ws失败："+e.text+",->"+websocket.uri},ErrorType.WS_CONNECT_FAIL));
		}
		private function handleSecurityError(e:SecurityErrorEvent):void
		{
			Log.error("安全策略错误，请检查网络",e.text);
			AnalysisUtil.send(ACError.create({info:"连接ws失败：安全策略不允许访问,->"+websocket.uri},ErrorType.WS_CONNECT_FAIL));
		}
		
		// ----------------------------- Hanlders
		/**
		 * 收到了心跳检测信息 
		 * @param e 心跳
		 * 
		 */		
		private function handlePong(e:WebSocketEvent):void
		{
			trace("--收到心跳检测")
			checkSendStack();
			clearTimeout(checkConnectionTimeOut);
			droppedConnectionCount = 0;
			checkConnectionFlag = true;
			checkConnectionTimeOut = setTimeout(checkConnection,onlinewait);
			clearTimeout(waitCheckConnectionTimeOut);
		}
		/**
		 *  
		 * @param e
		 * 
		 */			
		private function handleWebSocketOpen(e:WebSocketEvent):void
		{
			Log.debug("WS已经打开");
			clearTimeout(checkConnectionTimeOut);
			droppedConnectionCount = 0;
			checkConnectionFlag = true;
			checkConnectionTimeOut = setTimeout(checkConnection,5000);
			clearTimeout(waitCheckConnectionTimeOut);
			// 准备Auth			
//			sendAuthData();
			if(isInit){
				isInit = false;
				websocket.sendUTF(Util.encode({"type":"init","index":ConstValue.SCREEN}));
			}
		}
		private var isInit:Boolean = true;
		public var source:String = "";
		public var pauseState:Boolean = false;
		public var player_status:int = 0;
		
		
		
//		public function sendPlayStart():void{
//			websocket.sendUTF(Util.encode({"currentMachine":1,"type":"player_start"}));
//		}
		
		private var array:Array = [0xffff00,
			0xff0000,
			0x0000ff,
			0x0099ff,
			0x99ff00,
			0x8800ff,
			0x88ff00,
			0xff00ff,
			0xcc00ff];
		public function getColor():uint{
			if(Math.random() > 0.5){
				var i:int = Math.floor((Math.random() * array.length));
				return array[i];
			}else{
				return 0xFFFFFF;
			}
			
		}
		
		//通知服务器下一个屏幕显示文字弹幕
		public function sendNextComment(item:SingleCommentData,protectedDm:Boolean = true):void{
			if(ConstValue.PLAY_SCREEN && protectedDm) return;
			var obj:Object =Util.decode(item.getencode())//
			obj.msg = item.text;
			obj.color= item.color;
			websocket.sendUTF(Util.encode({"type":"sendDmToNext","data":obj}));
		}
		
		//通知服务器下一个屏幕表情弹幕
		public function sendNextGif(item:SingleCommentData,protectedDm:Boolean = true):void{
			if(ConstValue.PLAY_SCREEN && protectedDm) return;
			var obj:Object = {"msg":item.text};
			websocket.sendUTF(Util.encode({"type":"sendExToNext","data":obj}));
		}
		/**
		 * 接收到服务器的信息 
		 * @param e
		 * 
		 */		
		private function handleWebSocketMessage(e:WebSocketEvent):void
		{
			if(e.message && e.message.type == WebSocketMessage.TYPE_UTF8)
			{
				//预处理
				//trace("__decodeMes:"+e.message.utf8Data)
				var serverResponse:Object = Util.decode(e.message.utf8Data);				
				if(serverResponse)
				{
					var type:String = serverResponse["type"] as String;
					if(type){
						//trace("--type:"+type)
						switch(type){
							case "init":
								source = serverResponse.data["video_name"];
								player_status = serverResponse.data["player_status"];
								notify(SIGNALCONST.SOCKET_INIT);
								break;
							case "playerStatus":
								player_status = serverResponse.data;
								notify(SIGNALCONST.CHANGE_VIEW);
								break;
							case "expression"://发送表情弹幕
								
								var obj1:Object = serverResponse["data"];
								if(obj1 == null){
									return;
								}
								var obj:Object = new Object();
								obj.msg = obj1;
								//								obj["color"] = CommentHandler.instance.getColor();
								var cmtData:SingleCommentData = CommentUtils.createNewComment2(obj,false);
								if(ConstValue.PLAY_SCREEN){//play屏幕只显示play弹幕，普通弹幕直接通知下一屏幕显示
									sendNextGif(cmtData,false)
									//return;//sendNextGif
								}
								CommentTime.instance.start1(cmtData);
								//////////////////////
								///////////测试
								
								/*var specialStr:String = serverResponse["data"];
								
								if(specialStr =="lianmeng"){
									//var obj_:Object = {"msg":"lianmeng.gif"};
									//var cmtData_:SingleCommentData = CommentUtils.createNewComment2(obj_,false);
									_onSignal.dispatch('LIANMENG');
									sendNextGif(cmtData,false)
								}
								else if(specialStr =="buluo")
								{
									_onSignal.dispatch('BULUO');
									sendNextGif(cmtData,false)
								}*/
								///////////////////
								break;
							
							case "specialExpression"://发送表情弹幕
								/*var specialStr:String = serverResponse["data"];
								trace("--specialStr:"+specialStr)
								if(specialStr =="lianmeng"){
									_onSignal.dispatch('LIANMENG');
								}
								else if(specialStr =="buluo")
								{
									_onSignal.dispatch('BULUO');
								}*/
								//////////////////////////////////显示特殊表情
								/*var objs:Object = serverResponse["data"];
								if(objs == null){
									return;
								}
								var objSpe:Object = new Object();
								objSpe.msg = objs;
								var cmtDataS:SingleCommentData = CommentUtils.createNewComment2(objSpe,false);
								CommentTime.instance.start1(cmtDataS);*/
							
								break;
							
							case "sendDmToNext":
								var obj2:Object = serverResponse["data"];
								if(obj2 == null){
									return;
								}
								//								obj["color"] = CommentHandler.instance.getColor();
								var cmtData1:SingleCommentData = CommentUtils.createNewComment1(obj2,false);
								CommentTime.instance.start(cmtData1);
								break;
							case "sendExToNext":
								var obj3:Object = serverResponse["data"];
								if(obj3 == null){
									return;
								}
								var cmtData2:SingleCommentData = CommentUtils.createNewComment2(obj3,false);
								CommentTime.instance.start1(cmtData2);
								/////////////////
								/*var specialStr1:String = serverResponse["data"];
								trace("haha:"+specialStr1)
								if(specialStr1 =="lianmeng"){
									
									_onSignal.dispatch('LIANMENG');
									
								}
								else if(specialStr1 =="buluo")
								{
									_onSignal.dispatch('BULUO');
									
								}*/
								break;
//							case "next_video":
//								var array1:Array = serverResponse["data"] as Array;
//								nextVideoId = array1[0] as int;
//								nextSource = array1[1] as String;
//								notify(SIGNALCONST.GET_NEXT_VIDEO);
//								break;
//							case "video_change":
//								var array2:Array = serverResponse["data"] as Array;
//								currentVideoId = array2[0] as int;
//								source = array2[1] as String;
////								currentVideoId = serverResponse["data"] as int;
//								nextVideoId = 0;
//								nextSource = "";
//								clearTimeout(clearId);
//								notify(SIGNALCONST.CHANGE_VIDEO);
//							case "player_start":
////								currentVideoId = serverResponse["data"] as int;
//								break;
//							case "video_time":
//								break;
//							case "video_play":
//								pauseState = serverResponse["data"] as Boolean;
//								notify(SIGNALCONST.VIDEO_PAUSE);
//								break;
//							case "danmu_user":
//								var data:Array = serverResponse["data"] as Array;
//								if(data.length > 0){
//									praseList(data);
//								}else{
//									CommentTime.instance.restartLine();
//								}
//								
//								break;
							case "danmu_visitor"://发送文字弹幕
								///////////////////
								var obj4:Object = serverResponse["data"];
								if(obj4 == null){
									return;
								}
								//trace("--s:"+obj4.msg)
								//_ptop.sendMessage(obj4)
								
								var cmtData4:SingleCommentData = CommentUtils.createNewComment1(obj4,false);
								if(ConstValue.PLAY_SCREEN) {//play屏幕只显示play弹幕，普通弹幕直接通知下一屏幕显示
									sendNextComment(cmtData4,false);
									return;
								}
								CommentTime.instance.start(cmtData4);
								//CommentBox.instance.container(new Gif1());//添加新弹幕
								
								break;
//							case "screen_full":
//								screenState = serverResponse["data"] as Boolean;
//								notify(SIGNALCONST.VIDEO_SCREEN);
//								break;
//							case "volume":
//								volume = serverResponse["data"] as int;
//								notify(SIGNALCONST.VIDEO_VOLUME);
//								break;
//							case "isShowQR":
////								trace("aaaa");
//								isShowLogo = serverResponse["data"] as Boolean;
//								notify(SIGNALCONST.CHANGE_LOGO);
//								break;
							case "close":
								reConnect();
								break;
							case "error":
								reConnect();
								break;
						}
					}
					
					
					
//					var action:String = serverResponse["action"] as String;
//					if(action)
//					{
//						var c:Object;
//						switch(action)
//						{
//							case "post":
//							{
//								c = Util.decode(serverResponse["command"]);
//								if (c["user"] != commentUser){
//									var rTime:String = c.stime;
//									if(rTime.lastIndexOf("%") != -1){
//										rTime = (int(rTime.replace("%","")) * vlength / 100).toString();
//										c.stime = rTime;
//									}
////									this.dispatchNewComment(c,CommentUtils.getIsLock(c.islock));
//									var cmtData1:SingleCommentData = CommentUtils.createNewComment(c,CommentUtils.getIsLock(c.islock));
//									CommentTime.instance.prepareStart(cmtData1);
//								}else{
//									Log.debug("自己发送弹幕的广播，过滤");
//								}
//								break;
//							}
//							case "vow":
//							{
//								c = Util.decode(serverResponse["command"]);
//								c.mode = "6";	//作为逆向弹幕渲染
//								CommentTime.instance.start(CommentUtils.createNewComment(c));								
//								Log.debug("收到公告信息：",c.message);
//								break;
//							}
//							case "close":
//							{
//								//断线重连
//								Log.debug("服务端发送关闭连接指令");
//								websocket.close(false);
//								reconnectCount = 0;
//								reConnect();
//								break;
//							}
//							default:
//							{
//								Log.debug("未知action：",action);
//								break;
//							}
//						}
//						return;
//					}
					
//					var status:String = serverResponse["status"] as String;
//					if(status)
//					{
//						switch(status)
//						{
//							//在线信息比较特殊，为节约带宽
//							case CommentServerResponseCode.ONLINE_NUMBER:
//								this.dispatchOnlineNumber(serverResponse["msg"]);
//								return;
//							case CommentServerResponseCode.SERVER_AUTHED:
//								//登录验证
//								this.dispatchAuthData(Util.decode(serverResponse["msg"]));
//								return;
//							case CommentServerResponseCode.ONLINE_LIST:
//								this.dispatchOnlineList(Util.decode(serverResponse["msg"]));
//								return;
//							case CommentServerResponseCode.SEND_OK:
//								//发送弹幕返回
//								onMessageSendFinished(serverResponse);
//								return;
//							case CommentServerResponseCode.SEND_REPORT_OK:
//							case CommentServerResponseCode.SEND_REPORT_OK_2:
//								this.dispatchReportOK(Util.decode(serverResponse["msg"]));
//								return;
//							case CommentServerResponseCode.BAN_LIST:
//								onReceiveBanList(serverResponse["result"]);
//								return;
//							case CommentServerResponseCode.SEND_FAIL_FORBIDDEN:
//								userBanned();
//								return;
//							case CommentServerResponseCode.SEND_FAIL_FORBIDDEN_SPECIAL_LEVEL:
//							case CommentServerResponseCode.SEND_FAIL_FORBIDDEN_LEVEL:
//							case CommentServerResponseCode.SEND_FAIL_FORBIDDEN_GUEST:
//								Log.info("send fail! ",status);
//								notify(SIGNALCONST.SKIN_SHOW_MESSAGE,serverResponse["msg"],"19");
//								directSendBuffer = new Vector.<SingleCommentData>;
//								dispatchEvent(new CommentServerEvent(CommentServerEvent.SEND_ERROR,serverResponse["msg"]));
//								return;
//							case CommentServerResponseCode.SEND_FAIL_SENSITIVE:
//								Log.info("发送失败，服务器返回："+serverResponse["msg"]);
//								directSendBuffer = new Vector.<SingleCommentData>;
////								notify(SIGNALCONST.SKIN_SHOW_MESSAGE,"发送内容包含敏感词，发送不成功。","19");
//								dispatchEvent(new CommentServerEvent(CommentServerEvent.SEND_ERROR,"发送失败，服务器返回："+serverResponse["msg"]));
//								return;
//							case CommentServerResponseCode.SEND_FAIL_SERVER:
//								notify(SIGNALCONST.SKIN_SHOW_MESSAGE,"弹幕服务器发生故障，发送不成功。","19");
//								Log.info("send fail! ",status);
//								directSendBuffer = new Vector.<SingleCommentData>;
//								dispatchEvent(new CommentServerEvent(CommentServerEvent.SEND_ERROR,"弹幕服务器发生故障，发送不成功。"));
//								return;
//							case CommentServerResponseCode.SERVER_CLOSE:
//								Log.info("服务器关闭连接");
//								//不要重连
//								banned = true;
//								return;
//							case CommentServerResponseCode.SERVER_REDIRECT:
//								Log.info("302 : ",serverResponse["msg"]);
//								if (PARAM.acInfo.isLive)
//									COMMENT_BASE_URI_LIVE = serverResponse["msg"];
//								else
//									COMMENT_BASE_URI = serverResponse["msg"];
//								return;
//							default:
//								Log.warn("无法预知的操作 : ",status);
//						}
//					}
				}
			}
		}
		/**
		 * 关闭连接，有可能是服务器强制关闭的 
		 * @param e
		 * 
		 */		
		private function handleWebSocketClosed(e:WebSocketEvent):void
		{
			this.reConnect();
		}
		
		
		
		
		
		
		public function get commentUser():String
		{
			return authResult["uid"] || authResult['client'] || CommentUtils.UNKOWN_USER;
		}
		
		public function get commentAuthResult():Object
		{
			return authResult || {};
		}
	
		
		public function get isAdmin():Boolean
		{
			return authResult["isAdmin"] && authResult["isAdmin"].toString().toLowerCase() == "true";
		}
		
		public function report(s:SingleCommentData):void
		{
			if(commentAuthResult["uid"])
			{
//				var curl:String = PARAM.host + '/report.aspx#name='
//					+ encodeURIComponent(s.user) + ";from=" + CommentHandler.instance.vid
//					+ ";type=" + encodeURIComponent("弹幕") + ";proof=" + encodeURIComponent(s.to2String())
//					+ ";desc=" + encodeURIComponent("[" +  encodeURIComponent(Util.digits(s.stime).replace(":","-")) + "]弹幕内容违规");
//				navigateToURL(new URLRequest(curl),"_blank");
				
				//发送到云屏蔽
				var reportStr:String =  Util.encode({"action" : "report" , "command" : Util.encode(
					{"commentid":s.commentid,"type":CommentUtils.TYPE_ARRAY[s.type],"userid":commentAuthResult["uid"]}
				)});
				sendBuffer.push(reportStr);
				checkSendStack();
				
				notify(SIGNALCONST.SKIN_SHOW_INFO,ConstValue.INFO_REPORT_STRING.replace("{uid}",s.user),{goFilter:function():void{
					notify(SIGNALCONST.SKIN_SHOW_MORE_CONFIG,1);
				}});
			}
			else
			{
				notify(SIGNALCONST.SKIN_SHOW_INFO,ConstValue.INFO_BLOCK_STRING.replace("{uid}",s.user),{goFilter:function():void{
					notify(SIGNALCONST.SKIN_SHOW_MORE_CONFIG,1);
				}});
//				notify(SIGNALCONST.SKIN_SHOW_MESSAGE,"为保证举报真实有效，请先登录","08");
			}
			blockUser(s.user);
		}
		
		public function blockUser(user:String):void
		{
			var f:CommentFilter = CommentFilter.getInstance();
			f.addItem("u=" + user,true);
			f.savetoSharedObject();
		}
		
		//废弃
//		public function requireBanList():void
//		{
//			//command="" get all
//			sendBuffer.push(Util.encode({"command":"black.video_" + vid + ".user","action":"banlist"}));
//			checkSendStack();
//			Log.info("Require cloud ban list...");
//		}
		
		private function onReceiveBanList(list:Array):void
		{
			var f:CommentFilter = CommentFilter.getInstance();
			for each (var item:Object in list)
			{
				if (StringUtil.endsWith(item.namespace,".user"))
				{
					f.systemUIDsBK.push(item.value);
				}
				else if (StringUtil.endsWith(item.namespace,".word"))
				{
					f.systemWordBK.push(item.value);
				}
			}
			Log.info("Get ban list from cloud,items num is : " + list.length);
		}
		
		private function refreshPage():void
		{
			var length:int = CommentTime.instance.getAllComments().length;
			JavascriptAPI.callJS(JavascriptAPI.ONLINE_NUMBER,{num:(online + "," + length)});
		}
		
		public function changeVid(vid:String):void
		{
			if (this.vid != vid)
			{
				init(vid,vlength);
			}
		}
	}
}