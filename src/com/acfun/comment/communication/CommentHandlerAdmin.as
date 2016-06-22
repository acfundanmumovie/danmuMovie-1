package com.acfun.comment.communication
{
	import com.acfun.External.JavascriptAPI;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	import com.acfun.comment.control.CommentTime;
	import com.acfun.comment.display.CommentView;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.utils.AuthData;
	import com.acfun.comment.utils.CommentUtils;
	import com.acfun.signal.notify;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.Security;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class CommentHandlerAdmin
	{
		private static const connectwait:int = 10000; //连接超时
		private static const onlinewait:int = 10000;  //检测在线超时
		private var websocket:WebSocket;
		protected static var COMMENT_BASE_URI:String = 'ws://danmaku-master.acfun.tv:446';
//		protected static var COMMENT_BASE_URI:String = 'ws://10.232.0.201:1446';
		private static var banned:Boolean = false; // 用户被封禁，保留字段
		private var checkConnectionFlag:Boolean = false;
		private var droppedConnectionCount:int = 0;
		private var checkConnectionTimeOut:uint = 0;
		private var waitCheckConnectionTimeOut:uint = 0;				
		private var reconnectCount:uint = 0;		
		private var sendBuffer:Vector.<String>;
		private var lastCheckTime:Number = 0;		
		private var vlength:int;				
		private var vid:String;		
		private var authResult:Object = {};
		private var isUserAuthed:Boolean = false;
		
		public function CommentHandlerAdmin()
		{
			sendBuffer = new Vector.<String>();			
		}
		
		public function init(commentId:String,vlength:int,isLive:Boolean = false):void
		{
			Security.loadPolicyFile("ws://danmaku-master.acfun.tv:843");
			
			this.vid = commentId;
			this.vlength = vlength;
			
			if(websocket != null)
			{
				removeWebsocketListeners();
				abortAllOperations();
				// 强制关闭WS连接
				websocket.close(false);
			}
			var conn:String = COMMENT_BASE_URI + '/' + commentId;			
			websocket = new WebSocket(conn,'*',null,connectwait);			
			websocket.debug = false;
			this.connect();
		}
		
		private function abortAllOperations():void
		{
			sendBuffer.splice(0,sendBuffer.length);
		}
		
		private function connect():void
		{
			isUserAuthed = false;
			addWebsocketListeners();			
			websocket.connect();
		}
		
		private function checkSendStack():void
		{
			if(websocket == null)
			{
				Log.debug("ws_admin,websocket is null");
				reConnect();
				return;
			}
			if(!websocket.connected)
			{
				Log.debug("ws_admin,websocket is disconnected");
				reConnect();				
				return;
			}
			if(!isUserAuthed)
			{
				Log.debug("ws_admin,user not authed,re-auth");
				sendAuthData();				
				return;
			}			
			if(new Date().time - this.lastCheckTime < 2000)
			{
				Log.debug("ws_admin,check date failed in 2s");
				return;
			}
			if(sendBuffer.length > 0)	//暂时取消重发机制，避免弹幕重复	
			{				
				var sendString:String = sendBuffer.pop();
				websocket.sendUTF(sendString);				
				lastCheckTime = new Date().time;				
			}
		}
		
		private function reConnect():void
		{
			Log.warn("ws_admin,断线重连");
			removeWebsocketListeners();
			clearTimeout(checkConnectionTimeOut);
			checkConnectionFlag = false;
			clearTimeout(waitCheckConnectionTimeOut);
			this.connect();
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
				Log.info("ws_admin,掉线检测失败");
				if(this.droppedConnectionCount > 2 && reconnectCount < 2)
				{
					Log.error("ws_admin,重新连接");
					clearTimeout(checkConnectionTimeOut);
					this.reConnect();
					reconnectCount++;
					return;
				}
				else
				{
					if(reconnectCount >= 2)
					{
						Log.error("ws_admin,三次重试失败");
					}
					else
					{
						Log.info("ws_admin,延迟5秒重试");
						this.droppedConnectionCount ++;
						clearTimeout(checkConnectionTimeOut);
						checkConnectionTimeOut = setTimeout(checkConnection,5000);
						return;
					}
				}
			}
			// 三次掉线，重连处理。
			Log.error("ws_admin,放弃重新连接服务器");
		}
		
		private function onMessageSendFinished():void
		{
			Log.info("ws_admin,操作成功！");
		}
		
		private function dispatchAuthData(auth:Object):void
		{
			//需要包装个Auth类？不需要吧
			isUserAuthed = true;
			var authData:AuthData = new AuthData();
			var cilient:String = auth['client'];
			var cilient_ck:String = auth['client_ck'];
			if(cilient && (authData.Player_id != cilient || authData.Player_hash != cilient_ck))
			{
				authData.setAuth(cilient,cilient_ck);
				Log.info("ws_admin,改变Auth值",cilient,cilient_ck);				
			}
			else
			{
				Log.debug("ws_admin,用户特征未改变");
			}			
			authResult = auth;			
		}
		
		private function addWebsocketListeners():void
		{
			Log.info("ws_admin,侦听器已被添加");
			websocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			websocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			websocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			websocket.addEventListener(WebSocketEvent.PONG, handlePong);
			websocket.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);// IOError无需处理，将自动抛出Close事件
			websocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);// SecurityError无需处理，将自动抛出Close事件
			websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);// CONNECTION_FAIL 之后自动触发Close
			websocket.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void{
				trace(e);
			});
		}
		private function removeWebsocketListeners():void
		{
			Log.info("ws_admin,侦听器已被移除");
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
			Log.error("ws_admin,IO错误，请检查网络");
		}
		private function handleConnectionFail(e:WebSocketErrorEvent):void
		{
			Log.error("ws_admin,连接失败，请检查网络");
		}
		private function handleSecurityError(e:SecurityErrorEvent):void
		{
			Log.error("ws_admin,安全策略错误，请检查网络");
		}
		
		// ----------------------------- Hanlders
		/**
		 * 收到了心跳检测信息 
		 * @param e 心跳
		 * 
		 */		
		private function handlePong(e:WebSocketEvent):void
		{
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
			Log.debug("ws_admin,WS已经打开");
			clearTimeout(checkConnectionTimeOut);
			droppedConnectionCount = 0;
			checkConnectionFlag = true;
			checkConnectionTimeOut = setTimeout(checkConnection,5000);
			clearTimeout(waitCheckConnectionTimeOut);
			// 准备Auth
			reconnectCount = 0;
			sendAuthData();
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
				var serverResponse:Object = Util.decode(e.message.utf8Data);				
				if(serverResponse)
				{
					if(serverResponse["action"])
					{
						return;
					}					
					var status:String = serverResponse["status"] as String;
					if(status)
					{
						//在线信息比较特殊，为节约带宽						
						switch(status)
						{
							case CommentServerResponseCode.SERVER_AUTHED:
								this.dispatchAuthData(Util.decode(serverResponse["msg"]));
								return;							
							case CommentServerResponseCode.SEND_OK:
								notify(SIGNALCONST.SKIN_SHOW_INFO,"锁定/删除操作成功！");
								onMessageSendFinished();
								return;
							case CommentServerResponseCode.SEND_FAIL_FORBIDDEN:
								onMessageSendFinished();
								return;
							case CommentServerResponseCode.SEND_FAIL_SERVER:
								onMessageSendFinished();
								return;							
						}
					}
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
			isUserAuthed = false;
			
			if(!banned && this.reconnectCount < 5)
			{
				reconnectCount++;
				this.reConnect();
			}
		}
		
		public function get commentUser():String
		{
			return authResult["uid"] || authResult['client'] || CommentUtils.UNKOWN_USER;
		}
		
		public function get commentAuthResult():Object
		{
			return authResult || {};
		}
		
		private function sendAuthData():void
		{
			var authData:AuthData = new AuthData();
			var handshakeData:Object = {};
			handshakeData['client'] = authData.Player_id;
			handshakeData['client_ck'] = authData.Player_hash;
			handshakeData['vid'] = this.vid;
			handshakeData['vlength'] = this.vlength;
			handshakeData['time'] = new Date().time;			
			handshakeData['uid'] = JavascriptAPI.getCookie("auth_key");
			handshakeData['uid_ck'] = JavascriptAPI.getCookie("auth_key_ac_sha1");
			if (isNaN(Number(handshakeData['uid'])) || handshakeData['uid']==null) delete handshakeData['uid'];
			if (isNaN(Number(handshakeData['uid_ck'])) || handshakeData['uid_ck']==null) delete handshakeData['uid_ck'];	
			Log.debug("ws_admin,播放器信息已加载： Client[" + handshakeData['client'] + "],[" + handshakeData['client_ck'] + "]");
			websocket.sendUTF(Util.encode({action : "auth",command:Util.encode(handshakeData)}));
		}
		
		public function get isAdmin():Boolean
		{
			return authResult["isAdmin"].toString().toLowerCase() == "true";
		}
		
		public function remove(comments:Array):void
		{
			if (comments && comments.length > 0)
			{
				Log.info("ws_admin,delete comment number: ",comments.length);			
				sendBuffer.push(createObjectString("del",comments));
				checkSendStack();
			}
		}
		
		public function lock(comments:Array):void
		{
			if (comments && comments.length > 0)
			{
				Log.info("ws_admin,lock comment number: ",comments.length);			
				sendBuffer.push(createObjectString("lock",comments));
				checkSendStack();
			}
		}
		
		private function createObjectString(action:String,cs:Array):String
		{
			return Util.encode({"action" : action , "command" : Util.encode(cs.map(
				function (item:SingleCommentData, index:int, array:Array):Object{
					return {"videoid":vid,"type":CommentUtils.TYPE_ARRAY[item.type],"commentid":item.commentid};
				}
			))});
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
	}
}