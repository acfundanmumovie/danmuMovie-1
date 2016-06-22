/**
 * ===================================
 * Author:	iDzeir					
 * Email:	qiyanlong@wozine.com	
 * Company:	http://www.acfun.tv		
 * Created:	May 18, 2015 2:27:50 PM			
 * ===================================
 */

package com.acfun.net.analysis
{
	/**
	 * 统计接口文件
	 */	
	public interface IAnalysis
	{
		/**
		 * 统计的服务器地址 
		 */		
		function get url():String;
		/**
		 * 提交的统计消息，最后转换成为JSON字符串 
		 */		
		function get info():*;
	}
}