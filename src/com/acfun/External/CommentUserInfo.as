package com.acfun.External
{
	import com.acfun.signal.register;

	public class CommentUserInfo
	{
		private var authObj:Object = {};
		
		public function CommentUserInfo()
		{
			register(SIGNALCONST.COMMENT_SERVER_CONNECTED,onGetInfo,null,99);
		}
		
		private function onGetInfo(authObj:Object):void
		{
			this.authObj = authObj;
		}
		
		public function get user():String
		{
			return authObj["uid"] || authObj['client'] || "unknow_user";
		}
		
		public function get isLogin():Boolean
		{
			return authObj["uid"];
		}
		
		public function get isAdmin():Boolean
		{
			return authObj["isAdmin"] && authObj["isAdmin"].toString().toLowerCase() == "true";
		}
		
		public function get isUp():Boolean
		{
			return isLogin && authObj["uid"] == PARAM.acInfo.userId;
		}
		
		public function get level():int
		{
			return authObj["lv"] || 0;
		}
	}
}