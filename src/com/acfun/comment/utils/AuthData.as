package com.acfun.comment.utils
{

	public class AuthData
	{
		private var _Player_id:String;
		private var _Player_hash:String;
		public static const KEY_NAME:String = 'auth_data';
		public function AuthData()
		{
			var playerObj:* = LocalStorageManager.getValue(KEY_NAME);
			if(playerObj)
			{
				_Player_id = playerObj['player_id'];
				_Player_hash = playerObj['player_hash'];
			}
		}
		public function get Player_id():String
		{
			return _Player_id || "";
		}
		public function get Player_hash():String
		{
			return _Player_hash || "";
		}
		public function setAuth(id:String,hash:String):void
		{
			_Player_id = id;
			_Player_hash = hash;
			LocalStorageManager.setKV(KEY_NAME,{player_id:id,player_hash:hash});
		}
	}
}