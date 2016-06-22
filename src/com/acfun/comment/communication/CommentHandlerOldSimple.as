package com.acfun.comment.communication
{
	import com.acfun.External.JavascriptAPI;
	import com.acfun.External.PARAM;
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	import com.acfun.comment.control.CommentTime;
	import com.acfun.comment.display.CommentView;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.utils.AuthData;
	import com.acfun.comment.utils.CommentUtils;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class CommentHandlerOldSimple
	{
		private static const connectwait:int = 5000; //连接超时
		private var websocket:WebSocket;
		protected static var COMMENT_BASE_URI:String = 'ws://comment.acfun.tv:443';
		private static var banned:Boolean = false; // 用户被封禁，保留字段
		private var checkConnectionFlag:Boolean = false;
		private var droppedConnectionCount:int = 0;
		private var checkConnectionTimeOut:uint = 0;
		private var waitCheckConnectionTimeOut:uint = 0;				
		private var reconnectCount:uint = 0;		
		private var sendBuffer:Vector.<String>;
		private var directSendBuffer:Vector.<SingleCommentData>;
		private var isUserAuthed:Boolean = false;
		private var lastCheckTime:Number = 0;
		private var authResult:Object = {};
		private var vlength:int;
		private var vNumber:int;		
		public var vid:String;
		
		public function CommentHandlerOldSimple()
		{
			sendBuffer = new Vector.<String>();
			directSendBuffer = new Vector.<SingleCommentData>();
		}
		
		public function init(commentId:String,vlength:int,isLive:Boolean = false):void
		{
			this.vid = PARAM.acInfo.danmakuId;
			this.vlength = vlength;
			this.vNumber = Math.round(vlength / 60) * 100;
			if (this.vNumber < 500) this.vNumber = 500;
			
			if(websocket != null)
			{
				removeWebsocketListeners();
				abortAllOperations();
				// 强制关闭WS连接
				websocket.close(false);
			}
			var conn:String = COMMENT_BASE_URI + '/' + vid;
//			Security.loadPolicyFile(COMMENT_BASE_URI);
			websocket = new WebSocket(conn,'*',null,connectwait);			
			websocket.debug = false;
			this.connect();
		}
		
		public function send(comment:SingleCommentData):void
		{
			//TODO: 建立队列
			comment.user = commentUser;
			
			Log.debug("ws2,prepare to send danmaku",comment.orignStr);
			
			sendBuffer.push(createObjectStringToSend(comment));			
			checkSendStack();
		}
		
		public function directSend(comments:Vector.<SingleCommentData>=null):void
		{
			if (comments)			
			{
				directSendBuffer = directSendBuffer.concat(comments);				
			}
			
			if (directSendBuffer.length > 0)
			{
				if (websocket && websocket.connected && isUserAuthed)
				{
					var comment:SingleCommentData = directSendBuffer.shift();
					comment.border = false;				
					websocket.sendUTF(createObjectStringToSend(comment));
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
		
		// ----------------------------- 私有方法
		/**
		 * 终止所有操作 
		 * 
		 */		
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
				Log.debug("ws2,websocket is null");
				reConnect();
				return;
			}
			if(!websocket.connected)
			{
				Log.debug("ws2,websocket is disconnected");
				reConnect();				
				return;
			}
			if(!isUserAuthed)
			{
				Log.debug("ws2,user not authed,re-auth");
				sendAuthData();				
				return;
			}
			if (directSendBuffer.length > 0)
			{
				directSend();
			}
			if(new Date().time - this.lastCheckTime < 3000)
			{
				Log.debug("ws2,check date failed in 3s");
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
			Log.warn("ws2,断线重连");
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
			waitCheckConnectionTimeOut = setTimeout(waitCheckConnectionTimeout,5000);
			websocket.ping();
		}
		
		private function waitCheckConnectionTimeout():void
		{
			clearTimeout(waitCheckConnectionTimeOut);
			if(!checkConnectionFlag)
			{
				Log.info("ws2,掉线检测失败");
				if(this.droppedConnectionCount > 2 && reconnectCount < 2)
				{
					Log.error("ws2,重新连接");
					clearTimeout(checkConnectionTimeOut);
					this.reConnect();
					reconnectCount++;
					return;
				}
				else
				{
					if(reconnectCount >= 2)
					{
						Log.error("ws2,三次重试失败");
					}
					else
					{
						Log.info("ws2,延迟5秒重试");
						this.droppedConnectionCount ++;
						clearTimeout(checkConnectionTimeOut);
						checkConnectionTimeOut = setTimeout(checkConnection,5000);
						return;
					}
				}
			}
			// 三次掉线，重连处理。
			Log.error("ws2,放弃重新连接服务器");
		}
		
		private function onMessageSendFinished():void
		{
			Log.info("ws2,评论发送成功，剩余条数：",sendBuffer.length,directSendBuffer.length);			
			directSend();
		}
		
		private function dispatchAuthData(auth:Object):void
		{
			//需要包装个Auth类？不需要吧
			isUserAuthed = true;
			var authData:AuthData = new AuthData();
			var cilient:String = auth['client'];
			var cilient_ck:String = auth['client_ck'];
			if(authData.Player_id != cilient || authData.Player_hash != cilient_ck)
			{
				authData.setAuth(cilient,cilient_ck);
				Log.info("ws2,改变Auth值",cilient,cilient_ck);				
			}
			else
			{
				Log.debug("ws2,用户特征未改变");
			}
			// = authData.Player_hash;
			authResult = auth;			
		}
		// -----------------------------
		// ----------------------------- 异常处理
		
		
		private function addWebsocketListeners():void
		{
			Log.info("ws2,侦听器已被添加");
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
			Log.info("ws2,侦听器已被移除");
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
			Log.error("ws2,IO错误，请检查网络");
		}
		private function handleConnectionFail(e:WebSocketErrorEvent):void
		{
			Log.error("ws2,连接失败，请检查网络");
		}
		private function handleSecurityError(e:SecurityErrorEvent):void
		{
			Log.error("ws2,安全策略错误，请检查网络");
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
			checkConnectionTimeOut = setTimeout(checkConnection,5000);
			clearTimeout(waitCheckConnectionTimeOut);
		}
		/**
		 *  
		 * @param e
		 * 
		 */			
		private function handleWebSocketOpen(e:WebSocketEvent):void
		{
			Log.debug("ws2,WS已经打开");
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
			Log.debug("ws2,播放器信息已加载： Client[" + handshakeData['client'] + "],[" + handshakeData['client_ck'] + "]");
			websocket.sendUTF(Util.encode({action : "auth",command:Util.encode(handshakeData)}));
		}
		
		public function get isAdmin():Boolean
		{
			return authResult["isAdmin"].toString().toLowerCase() == "true";
		}
		
		private function createObjectStringToSend(c:SingleCommentData,action:String="post"):String
		{			
			return Util.encode({"action" : action,"command":Util.encode({mode:c.mode,
				color:c.color,
				size:c.size,
				stime:c.stime,
				user:commentUser,
				message:c.getText(),				
				time:(new Date().time),
				islock : c.isLock ? "1":"0"})});		
		}
		
		public function remove(comments:Array):void
		{
			if (comments && comments.length > 0)
			{
				Log.info("ws2,delete comment number: ",comments.length);			
				sendBuffer.push(createObjectStringToDelete(comments));
				checkSendStack();
			}
		}
		
		public function createObjectStringToDelete(cs:Array):String
		{
			return Util.encode({"action" : "delete" , "command" : Util.encode(cs.map(
				function (item:SingleCommentData, index:int, array:Array):String{
					return item.orignStr;
				}
			))});
		}
	}
}