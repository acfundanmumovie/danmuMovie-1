package  com.acfun.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	
	public class PtoP extends EventDispatcher 
	{
		private var nc:NetConnection;
        private var group:NetGroup;
		public static var _localNet:Boolean = false;
		private var _connectGroupSuccess:Boolean = false;
        //private var userName:String;
		public static var MESSAGE:String = "message"
		public var _viewState:uint = 1;//输出屏幕窗口显示状态
		
		public function PtoP() 
		{
			//网路文件地址：http://hi.baidu.com/ripen/item/d4a11db4783b879719469700
			//http://wenku.baidu.com/view/7319f6a0b0717fd5360cdcec.html
			// constructor code
			//Your (codename) Cirrus developer key is: 
			//7143ea177792d3f6b95f0006-3b233c02b7da

			//To connect to the Cirrus service, open an RTMFP NetConnection to: 
			//rtmfp://p2p.rtmfp.net/7143ea177792d3f6b95f0006-3b233c02b7da/
			connect();
		}
		//////////
		public function connect():void
            {
                nc=new NetConnection();
                nc.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
				if(_localNet)
				{
					nc.connect("rtmfp:");//rtmfp://p2p.rtmfp.net/7143ea177792d3f6b95f0006-3b233c02b7da/
				}
				else
				{
					nc.connect("rtmfp://p2p.rtmfp.net/ba4de3a43adc8ead6f58f9a9-a8a7f3feb72b/");
				}
				//nc.connect("rtmfp://p2p.rtmfp.net", "ba4de3a43adc8ead6f58f9a9-a8a7f3feb72b");
                //userName="user" + Math.round(Math.random() * 1000);
            }

            private function netStatus(event:NetStatusEvent):void
            {
                //writeText(event.info.code);
				trace(event.info.code)
                switch (event.info.code)
                {
                    case "NetConnection.Connect.Success":
                        setupGroup();
                        break;

                    case "NetGroup.Connect.Success":
						//这里发送消息不会被组员接收到
						
                        break;

                    case "NetGroup.Posting.Notify"://可以理解为有新消息，接收消息
                        receiveMessage(event.info.message)//此处广播推送消息此方法必须为public
						dispatchEvent(new Event(PtoP.MESSAGE))
                        break;
						
					case "NetGroup.Neighbor.Connect":
                       trace("join:"+event.info.peerID+";"+event.info.name)
					   _connectGroupSuccess = true;//这里发送消息k可以被组员接收到
					  // onNetGroupConnect();
                        break;
						
					case "NetGroup.Neighbor.Disconnect":
                    	trace("out:"+event.info.peerID+";"+event.info.name)
                        break;
						
					case "NetGroup.Connect.Closed":
                    	trace("close:"+event.info.peerID+";"+event.info.name)
                        break;
                }
            }

            private function setupGroup():void
            {
                var groupspec:GroupSpecifier=new GroupSpecifier("myGroup/acfunGroupOne");//多个文件此处必须唯一，相当于通信的name
                groupspec.postingEnabled=true;
				groupspec.serverChannelEnabled = true;//启用组内成员通讯功能
                groupspec.ipMulticastMemberUpdatesEnabled=true;
                groupspec.addIPMulticastAddress("225.225.225.0:30303");//Ipv4子网掩码：+ 一个大于1024的正整数
  				//多播地址至少以224为起始值，而端口要大于1024 - 即：224.0.0.0:1024当然越高越好 —— 唯一性。

                group=new NetGroup(nc, groupspec.groupspecWithAuthorizations());
                group.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
            }
			
			
			private function onNetGroupConnect():void
			{
				/*trace("首次执行发送")
				var msg:Object = new Object();
				msg.msg = "hello everyone"
				msg.userMessageId = nc.nearID;
				sendMessage(msg)*/
			}
			
			//发送消息
            public function sendMessage(getServerobject:Object =null):void
            {
				trace("sendMessage")
                var message:Object=getServerobject;
               
                //message.sender=group.convertPeerIDToGroupAddress(nc.nearID);//转换nearID的形式，暂时没什么用
				//message.sender= nc.nearID;
                message.userMessageId=Math.round(Math.random() * 1000);//给定一个随机数使每次发送的信息部通，否则相同信息重复发送发不过去
				
				if(_connectGroupSuccess)
				{
					//trace("__Asend")
                	group.post(message);//发送消息
					//此方法使用 info.code 属性中的 "NetGroup.Posting.Notify" 将 NetStatusEvent 发送到 NetGroup 的事件侦听器。
					//"NetGroup.Posting.Notify" 事件被调度到客户端和服务器上的 NetGroup。

               		receiveMessage(message);
				}
            }
			
			//接收消息
            public function receiveMessage(message:Object):void
            {
				if(message.msg && message.type =="viewState"){
					trace("收到并输出消息:"+message.msg)
					_viewState = message.msg
				}
				
                writeText(message.userMessageId + ": " + message.msg);
            }
			
			//打印消息
            private function writeText(txt:String):void
            {
                trace( txt + "\n");
            }

		////////////
	}
	
}

/////////////原文：
/*不过还没有测试能不能通过这样连接方式实现语音+视频的连接呢~这个纯粹是文本流的通讯方式，有空试一下！

怎么才能不通过Stratus在局域网（LAN）建立P2P连接呢？
建立一个IP多播连接。指定连接字符串“rtmfp”. 注意，这种方式不能用于一对一通讯。所以不需要设置NetStream为DIRECT_CONNECTIONS，但可以进行RTMFP Group的所有操作。
也即是：
netConnection.connect("rtmpf:");

一旦连接成功（返回NetConnection.Connect.Success）就可以通过GroupSpecifier建立NetGroup或NetStream.
再设置ipMulticastMemberUpdatesEnabled为true，负责点与点间建立本地的连接，各点使用多播地址和相应端口调用addIPMulticastAddress方法。

多播地址至少以224为起始值，而端口要大于1024 - 即：224.0.0.0:1024
当然越高越好 —— 唯一性。
groupspec.ipMulticastMemberUpdatesEnabled = true;
groupspec.addIPMulticastAddress("225.225.0.1:30303");


绕开了Stratus，也就不需要了在Adobe上注册一个Stratus Developer Key了~但同样也是建立P2P连接的！*/

