package com.acfun.comment.utils
{
	import com.acfun.External.SIGNALCONST;
	import com.acfun.Utils.Util;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.signal.register;


	/**
	 * @deprecated 以前计划的关键字云屏蔽类，现以废弃
	 * 
	 */
	public class KeywordsFilter
	{
		private static var _instance:KeywordsFilter;
		//关键字云屏蔽平台地址
		private static const COMMENT_KEYWORDS_SERVER:String = 'http://keywordsfilter.acfun.com/';
		private static const SO_KEY:String = 'keywords_filter';
		private var userArray:Vector.<String>;
		private var keywordsArray:Vector.<String>;
		private var modArray:Vector.<String>;
		public function KeywordsFilter()
		{
			userArray = new Vector.<String>();
			keywordsArray = new Vector.<String>();
			modArray = new Vector.<String>();
			readDataFromLocalObject();
			
//			register(SIGNALCONST.SET_KEYWORD_FILTER,onSet);
		}
		
		private function onSet(source:String):void
		{
			parseData(Util.decode(source,false));
		}
		
		public static function get Instance():KeywordsFilter
		{
			if(_instance == null)
			{
				_instance = new KeywordsFilter();
			}
			return _instance;
		}
		public function addKeyword(keyword:String,addToSharedObject:Boolean = false):void
		{
			if(addToSharedObject)
			{
				this.saveDataToLocalObject('keyword',keyword);
			}
			for each(var s:String in keywordsArray)
			{
				if(s == keyword)
				{
					return;
				}
			}
			keywordsArray.push(keyword);
		}
		public function removeKeyword(keyword:String,removeFromSharedObject:Boolean):void
		{
			if(removeFromSharedObject)
			{
				this.deleteDataFromLocalObject('keyword',keyword);
			}
			for(var i:int;i<keywordsArray.length;i++)
			{
				if(keywordsArray[i] == keyword)
				{
					keywordsArray.splice(i,1);
					return;
				}
			}
		}
		public function clearKeyword():void
		{
			keywordsArray.splice(0,keywordsArray.length);
		}
		public function addUser(user:String,addToSharedObject:Boolean = false):void
		{
			if(addToSharedObject)
			{
				this.saveDataToLocalObject('user',user);
			}
			for each(var s:String in userArray)
			{
				if(s == user)
				{
					return;
				}
			}
			userArray.push(user);
		}
		public function removeUser(user:String,removeFromSharedObject:Boolean = false):void
		{
			if(removeFromSharedObject)
			{
				this.deleteDataFromLocalObject('user',user);
			}
			for(var i:int;i<userArray.length;i++)
			{
				if(userArray[i] == user)
				{
					userArray.splice(i,1);
					return;
				}
			}
		}
		public function clearUser():void
		{
			userArray.splice(0,userArray.length);
		}
		public function addMode(mode:String):void
		{
			for each(var s:String in mode)
			{
				if(s == mode)
				{
					return;
				}
			}
			modArray.push(mode);
		}
		public function removeMode(mode:String):void
		{
			for(var i:int;i< modArray.length;i++)
			{
				if(modArray[i] == mode)
				{
					modArray.splice(i,1);
					return;
				}
			}
		}
		public function clearMode():void
		{
			modArray.splice(0,modArray.length);
		}
		public function validateCommentData(data:SingleCommentData):Boolean
		{
			for each(var mod:String in modArray)
			{
				if(mod == data.mode)
				{
					return false;
				}
			}
			if(!this.validataUser(data.user))
			{
				return false;
			}
			var txt:String = data.getText();
			for each(var str:String in keywordsArray)
			{
				if(txt.search(str) > -1)
				{
					return false;
				}
			}
			return true;
		}
		public function validataUser(data:String):Boolean
		{
			for each(var user:String in userArray)
			{
				if(data.indexOf(user))
				{
					return false;
				}
			}
			return true;
		}
		private function readDataFromLocalObject():void
		{
			//遍历
			try
			{
				var data:Object = LocalStorageManager.getValue(SO_KEY);
				parseData(data);
			}
			catch(e:Error)
			{
				
			}
		}
		
		private function parseData(data:Object):void
		{
			if(!data)
			{
				return;
			}
			var keys:Array = ['keyword','user'];
			for each(var key:String in keys)
			{
				var kArray:Array = data[key];
				if(!kArray)
				{
					continue;
				}
				for each(var keyword:String in kArray)
				{
					switch(key)
					{
						case 'keyword':
							this.addKeyword(keyword);
							break;
						case 'user':
							this.addUser(keyword);
							break;
						default:
							break;
					}
				}
			}
		}
		
		private function deleteDataFromLocalObject(key:String,value:String):void
		{
			try
			{
				//根据KV获取键值对
				var dataObj:Object = LocalStorageManager.getValue(SO_KEY);
				if(!dataObj)
				{
					return;
				}
				var dataArray:Array = dataObj[key];
				if(!dataArray)
				{
					return;
				}
				else
				{
					//在这里删除
					for(var i:int = 0;i < dataArray.length; i++)
					{
						if(dataArray[i] == value)
						{
							dataArray.splice(i,1);
							break;
						}
					}
					//dataArray.push(value);
					dataObj[key] = dataArray;
				}
				LocalStorageManager.setKV(SO_KEY,dataObj);
			}
			catch(e:Error)
			{
				//TODO:LogError;
			}
		}
		private function saveDataToLocalObject(key:String,value:String):void
		{
			try
			{
				//根据KV获取键值对
				var dataObj:Object = LocalStorageManager.getValue(SO_KEY);
				if(!dataObj)
				{
					dataObj = new Object();
				}
				var dataArray:Array = dataObj[key];
				if(!dataArray)
				{
					dataArray = new Array();
					dataArray.push(value);
					dataObj[key] = dataArray;
				}
				else
				{
					for each(var str:String in dataArray)
					{
						if(str == value)
						{
							return;
						}
					}
					dataArray.push(value);
					dataObj[key] = dataArray;
				}
				LocalStorageManager.setKV(SO_KEY,dataObj);
			}
			catch(e:Error)
			{
				//TODO:LogError;
			}
		}
	}
}