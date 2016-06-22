/**
 * ===================================
 * Author:	iDzeir					
 * Email:	qiyanlong@wozine.com	
 * Company:	http://www.acfun.tv		
 * Created:	May 18, 2015 1:25:35 PM			
 * ===================================
 */

package com.acfun.net.analysis.errors
{
	import com.acfun.net.analysis.IAnalysis;
	
	import flash.utils.Dictionary;
	
	/**
	 * 错误统计类
	 */	
	public class ACError implements IAnalysis
	{
		/**
		 * 错误统计服务器的地址 
		 */		
		private var _url:String = "";
		/**
		 * 错误统计提交的信息 
		 */		
		private var _info:Object = null;
		/**
		 * 错误类型 
		 */		
		private var _type:int;
		
		private static var _pool:Dictionary = new Dictionary(true);
		
		/**
		 * 用工厂方式创建
		 */		
		public function ACError()
		{
			
		}
		
		/**
		 *  工厂方式返回错误信息类型
		 * @param info 错误信息
		 * @param type 错误类型
		 * @param host 提交的接口地址，默认是_url
		 * @return 
		 */		
		public static function create(info:* = null,type:int = ErrorType.UN_KNOW,host:String = null):ACError
		{
			var e:ACError = _pool[type]
			e ||= new ACError();
			e._info = info;
			e._type = type;
			host && (e._url = host);
			
			return e;
		}
		
		public function get type():int
		{
			return this._type;
		}
		
		public function get url():String
		{
			return _url;
		}
		
		public function get info():*
		{
			//打包错误类型
			_info.type = _type;
			return _info;
		}
	}
}