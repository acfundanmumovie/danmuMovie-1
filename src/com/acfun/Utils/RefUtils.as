/**
 * ===================================
 * Author:	iDzeir					
 * Email:	qiyanlong@wozine.com	
 * Company:	http://www.acfun.tv		
 * Created:	May 4, 2015 4:56:01 PM			
 * ===================================
 */

package com.acfun.Utils
{
	import flash.external.ExternalInterface;
	import flash.system.Security;
	
	public class RefUtils
	{
		private static var _vo:Object;
		
		/**
		 * 返回线上页面地址 
		 * @return 
		 * 
		 */		
		public static function get ref():String
		{
			var url:String = "";
			if(ExternalInterface.available)
			{
				try{
					url = ExternalInterface.call("function(){return windows.location.href}");
				}catch(e:Error){}
			}
			return url;
		}
		
		/**
		 * 返回域名地址 
		 * @return 
		 * 
		 */		
		public static function host():String
		{
			var url:String = "";
			if(ref!="")
			{
				url = ref.substring(0,ref.indexOf("?"));
			}
			return url;
		}
		
		private static function parse():Object
		{
			if(_vo)return _vo;
			_vo ||=  {};
			//本地永久打开测试面板
			if (Security.sandboxType != Security.REMOTE)_vo.debug = "1";
			if(ref&&ref!="")
			{
				var dataUrl:String = ref.substring(ref.indexOf("?")+1);
				var dataArr:Array = dataUrl.split("&");
				for(var i:uint = 0;i<dataArr.length;++i)
				{
					if(dataArr[i].indexOf("=")!=-1)
					{
						var params:Array = dataArr[i].split("=");
						_vo[params[0]] = params[1];
					}
				}
			}
			return _vo;
		}
		/**
		 * 获取key对应的url中的值 
		 * @param key
		 * @return 
		 * 
		 */		
		public static function getValueByKey(key:String):String
		{
			!_vo&&parse();
			if(valid(key))return _vo[key];
			throw new ArgumentError("不存在对应的key:"+key);
		}
		/**
		 * 验证key在url中是否存在 
		 * @param key
		 * @return 
		 * 
		 */		
		public static function valid(key:String):Boolean
		{
			return false;
			!_vo&&parse();
			return _vo.hasOwnProperty(key);
		}
	}
}